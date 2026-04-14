library(dplyr)
library(DBI)
library(odbc)
library(dbplyr)
library(readr)
library(tidyr)

acad_year <- 202425
indicator_file <- "[KS5_RESTRICTED].[Outputs].[PupilIndicators_POST16_202425A]"

con <- DBI::dbConnect(
  odbc::odbc(),
  driver = "SQL Server",
  server = "VMT1PR-DHSQL02"
)

EM_students <- tbl(
  con,
  sql(paste0(
    "
  select PUPILID,
         SEX,
         BASE_pts_E, BEST_E, BASE_pts_M, BEST_M, PROG_EXEMPT_E, PROG_EXEMPT_M--, NO_ENTRIES_E, NO_ENTRIES_M
    from",
    indicator_file,
    "
  where [TRIGGER]=1 and RECTYPE = 5 and COND in (1,2,3,4,5,6,7) and (PROG_EXEMPT_E is not null OR PROG_EXEMPT_M is not null)"
  ))
) %>%
  collect()

dbDisconnect(con)

pivoted_data <- EM_students %>%
  pivot_longer(
    cols = c(
      BASE_pts_E,
      BASE_pts_M,
      BEST_E,
      BEST_M,
      PROG_EXEMPT_E,
      PROG_EXEMPT_M
    ),
    names_to = c(".value", "subject"),
    names_pattern = "(.*)_(E|M)"
  ) %>%
  filter(!is.na(PROG_EXEMPT))

sex_data <- pivoted_data %>%
  group_by(SEX, subject, BASE_pts, BEST, PROG_EXEMPT) %>%
  summarise(student_count = n(), .groups = "drop") %>%
  filter(SEX %in% c("F", "M"))

total_data <- pivoted_data %>%
  group_by(subject, BASE_pts, BEST, PROG_EXEMPT) %>%
  summarise(student_count = n(), .groups = "drop") %>%
  mutate(SEX = "All")

all_data <- bind_rows(sex_data, total_data) %>%
  mutate(
    academic_year = acad_year,
    SEX = case_when(
      SEX == "F" ~ "Female",
      SEX == "M" ~ "Male",
      TRUE ~ SEX
    ),
    subject = case_when(
      subject == "E" ~ "English",
      subject == "M" ~ "Maths",
      TRUE ~ subject
    ),
    BEST = replace_na(as.character(BEST), "No entry")
  ) %>%
  rename_with(tolower) %>%
  rename(
    points_prior = base_pts,
    points_1618 = best,
    progress_score = prog_exempt
  ) %>%
  relocate(student_count, .after = "academic_year") %>%
  relocate(academic_year, .before = "sex") %>%
  relocate(subject, .before = "sex") %>%
  arrange(academic_year, sex, subject, points_prior, points_1618)

## MISSING INTERACTIONS

list_of_chars <- all_data %>%
  select(sex) %>%
  distinct(sex) %>%
  arrange(sex) %>%
  pull(sex)

# Get distinct prior values across base_pts_m and base_pts_e
list_of_priors <- all_data %>%
  select(points_prior) %>%
  distinct(points_prior) %>%
  arrange(points_prior) %>%
  pull(points_prior)

# Get distinct attainment values across best_m and best_e
list_of_attainment <- all_data %>%
  select(points_1618) %>%
  distinct(points_1618) %>%
  arrange(points_1618) %>%
  pull(points_1618)

# Build skeleton df with all combinations
skeleton_df <- tidyr::crossing(
  academic_year = acad_year,
  subject = c("English", "Maths"),
  sex = list_of_chars,
  points_prior = list_of_priors,
  points_1618 = list_of_attainment
)

all_data_complete <- all_data %>%
  full_join(
    skeleton_df,
    by = c(
      "academic_year" = "academic_year",
      "subject" = "subject",
      "sex" = "sex",
      "points_prior" = "points_prior",
      "points_1618" = "points_1618"
    )
  ) %>%
  mutate(
    student_count = case_when(
      is.na(student_count) ~ 0,
      TRUE ~ student_count
    ),
    progress_score = case_when(
      is.na(progress_score) ~
        as.numeric(points_1618) - as.numeric(points_prior),
      TRUE ~ progress_score
    )
  ) %>%
  arrange(academic_year, sex, subject, points_prior, points_1618)

## Expect all_data_complete to be longer than skeleton (if not the same size).
## This is because there are some progress scores that are not just best-prior (see specs RE cond=4).

totals_prior <- all_data_complete %>%
  select(sex, subject, points_prior, student_count) %>%
  group_by(sex, subject, points_prior) %>%
  summarise(student_count = sum(student_count)) %>%
  mutate(
    points_1618 = "All",
    progress_score = "z",
    academic_year = acad_year
  )

totals_1618 <- all_data_complete %>%
  select(sex, subject, points_1618, student_count) %>%
  group_by(sex, subject, points_1618) %>%
  summarise(student_count = sum(student_count)) %>%
  mutate(
    points_prior = "All",
    progress_score = "z",
    academic_year = acad_year
  )

all_data_complete_with_totals <- rbind(
  all_data_complete,
  totals_prior,
  totals_1618
) %>%
  mutate(
    id_col_prior = paste0(academic_year, subject, sex, points_prior),
    id_col_1618 = paste0(academic_year, subject, sex, points_1618)
  )

# SUPPRESSION

groups_to_suppress_prior <- all_data_complete %>%
  group_by(academic_year, subject, sex, points_prior, points_1618) %>%
  summarise(num_stud = sum(student_count)) %>%
  group_by(academic_year, subject, sex, points_prior) %>%
  summarise(
    non_zero_groups = sum(num_stud > 0), # Same logic as n_distinct(groups)=2 but would need the total to work properly which we don't include here.
    .groups = "drop"
  ) %>%
  mutate(supp_flag = non_zero_groups == 1) %>%
  group_by(academic_year, subject, points_prior) %>%
  mutate(sec_supp_flag = any(supp_flag & sex %in% c("Female", "Male"))) %>%
  ungroup() %>%
  filter(supp_flag | (sec_supp_flag & sex %in% c("Female", "Male"))) %>%
  mutate(id_col = paste0(academic_year, subject, sex, points_prior)) %>%
  select(id_col)

groups_to_suppress_1618 <- all_data_complete %>%
  group_by(academic_year, subject, sex, points_prior, points_1618) %>%
  summarise(num_stud = sum(student_count)) %>%
  group_by(academic_year, subject, sex, points_1618) %>%
  summarise(
    non_zero_groups = sum(num_stud > 0),
    .groups = "drop"
  ) %>%
  mutate(supp_flag = non_zero_groups == 1) %>%
  group_by(academic_year, subject, points_1618) %>%
  mutate(sec_supp_flag = any(supp_flag & sex %in% c("Female", "Male"))) %>%
  ungroup() %>%
  filter(supp_flag | (sec_supp_flag & sex %in% c("Female", "Male"))) %>%
  mutate(id_col = paste0(academic_year, subject, sex, points_1618)) %>%
  select(id_col)

to_remove_priors <- all_data_complete_with_totals %>%
  filter(
    (id_col_prior %in% groups_to_suppress_prior$id_col),
    student_count != 0,
    points_1618 != "All"
  ) %>%
  mutate(id_col_prior_rem = paste0(academic_year, subject, sex, "All")) %>%
  select(
    id_col_prior,
    student_count,
    id_col_1618,
    id_col_prior_rem
  )

to_remove_1618 <- all_data_complete_with_totals %>%
  filter(
    (id_col_1618 %in% groups_to_suppress_1618$id_col),
    student_count != 0,
    points_prior != "All"
  ) %>%
  mutate(id_col_1618_rem = paste0(academic_year, subject, sex, "All")) %>%
  select(
    id_col_1618,
    student_count,
    id_col_prior,
    id_col_1618_rem
  )

all_data_complete_with_totals_supp_prep <- all_data_complete_with_totals %>%
  left_join(
    to_remove_priors %>%
      select(id_col_1618, id_col_prior_rem, remove_prior = student_count),
    by = c("id_col_1618", "id_col_prior" = "id_col_prior_rem")
  ) %>%
  left_join(
    to_remove_1618 %>%
      select(id_col_prior, id_col_1618_rem, remove_1618 = student_count),
    by = c("id_col_prior", "id_col_1618" = "id_col_1618_rem")
  ) %>%
  mutate(
    student_count = student_count -
      coalesce(remove_prior, 0) -
      coalesce(remove_1618, 0)
  ) %>%
  select(
    -remove_prior,
    -remove_1618,
    -id_col_prior,
    -id_col_1618
  )

all_data_suppressed <- all_data_complete_with_totals_supp_prep %>%
  mutate(
    id_col_prior = paste0(academic_year, subject, sex, points_prior),
    id_col_1618 = paste0(academic_year, subject, sex, points_1618)
  ) %>%
  mutate(
    student_count = case_when(
      id_col_prior %in% groups_to_suppress_prior$id_col & points_1618 != "All" ~
        "c",
      id_col_1618 %in% groups_to_suppress_1618$id_col & points_prior != "All" ~
        "c",
      TRUE ~ as.character(student_count)
    ),
    progress_score = case_when(
      id_col_prior %in% groups_to_suppress_prior$id_col & points_1618 != "All" ~
        "c",
      id_col_1618 %in% groups_to_suppress_1618$id_col & points_prior != "All" ~
        "c",
      TRUE ~ as.character(progress_score)
    )
  ) %>%
  select(
    -id_col_prior,
    -id_col_1618
  )

#############################################################################
## QA checks

## Should match frontend national count.
all_data_complete %>%
  filter(sex == "All") %>%
  group_by(subject) %>%
  summarise(number_of_students = sum(student_count))

# 2024/25A - English 88,043. Maths 124,669. Matches

## Where student_count is suppressed, progress_score should be too. Vice versa.
## Should be 0 rows.
all_data_suppressed %>%
  filter(
    (student_count == "c" & progress_score != "c") |
      (student_count != "c" & progress_score == "c")
  )

# 2024/25A - 0 rows

## Want to ensure row/column totals sum to displayed row/column total to ensure suppression cannot be unpicked.
func_qa_matching_totals <- function(data, points_major, points_minor) {
  data %>%
    filter(sex == "All", {{ points_major }} != "All") %>%
    group_by({{ points_major }}) %>%
    summarise(
      total_students = sum(
        if_else({{ points_minor }} != "All", as.numeric(student_count), 0),
        na.rm = TRUE
      ),
      all_row_students = sum(
        if_else({{ points_minor }} == "All", as.numeric(student_count), 0),
        na.rm = TRUE
      ),
      diff = total_students - all_row_students,
      .groups = "drop"
    )
}

## Diff column should be 0.
func_qa_matching_totals(all_data_suppressed, points_prior, points_1618)
func_qa_matching_totals(all_data_suppressed, points_1618, points_prior)

# 2024/25A - All diffs=0

## Find rows that have been altered by suppression.
## Are these expected? Cross check using previously generated "to_remove_" id cols.
## Should be 0 rows.
all_data_complete_with_totals %>%
  select(-id_col_prior, -id_col_1618, -progress_score) %>%
  mutate(student_count = as.character(student_count)) %>%
  anti_join(
    all_data_suppressed %>% select(-progress_score),
    by = colnames(.)
  ) %>%
  rename(pre_student_count = student_count) %>%
  left_join(
    all_data_suppressed %>% select(-progress_score),
    by = setdiff(
      colnames(all_data_suppressed),
      c("student_count", "progress_score")
    )
  ) %>%
  rename(post_student_count = student_count) %>%
  mutate(
    id_col_prior = paste0(academic_year, subject, sex, points_prior),
    id_col_1618 = paste0(academic_year, subject, sex, points_1618)
  ) %>%
  filter(
    !(id_col_prior %in%
      to_remove_priors$id_col_prior |
      id_col_prior %in% to_remove_priors$id_col_prior_rem |
      id_col_1618 %in% to_remove_1618$id_col_1618 |
      id_col_1618 %in% to_remove_1618$id_col_1618_rem)
  )

# 2024/25A - 0 rows

## Check number of suppressed items for each prior/1618 grouping.

## Where a prior row is suppressed, expect 16 instances of suppression.
all_data_suppressed %>%
  filter(student_count == "c") %>%
  group_by(academic_year, subject, sex, points_prior) %>%
  summarise(supp_group_count = n()) %>%
  mutate(id_col_prior = paste0(academic_year, subject, sex, points_prior)) %>%
  filter(supp_group_count > 1) %>%
  mutate(
    expected_supp_group_count = case_when(
      id_col_prior %in% groups_to_suppress_prior$id_col ~ 16,
      TRUE ~ NA
    )
  ) %>%
  select(-id_col_prior)

# 2024/25A - 4 rows suppressed (Matches groups_to_suppress_prior). Each have 16 suppression instances.

## Where a 1618 column is suppressed, expect 10 instances of suppression.
all_data_suppressed %>%
  filter(student_count == "c") %>%
  group_by(academic_year, subject, sex, points_1618) %>%
  summarise(supp_group_count = n()) %>%
  mutate(id_col_1618 = paste0(academic_year, subject, sex, points_1618)) %>%
  filter(supp_group_count > 1) %>%
  mutate(
    expected_supp_group_count = case_when(
      id_col_1618 %in% groups_to_suppress_1618$id_col ~ 10,
      TRUE ~ NA
    )
  ) %>%
  select(-id_col_1618)

# 2024/25A - 2 columns suppressed (Matches groups_to_suppress_1618). Each have 10 suppression instances.

#############################################################################

write_csv(
  all_data_suppressed,
  file = paste0("./data/EM_progress_", acad_year, ".csv")
)
