# comma separating function ---------------------------------------------------
cs_num <- function(value) {
  format(as.numeric(value), big.mark = ",", trim = TRUE)
}

# progress table function -----------------------------------------------------
progress_tab <- function(x, colourTable) {
  prepped_data <- x %>%
    filter(
      points_prior != "All",
      points_1618 != "All"
    ) %>%
    mutate(
      points_prior = as.numeric(points_prior),
      points_1618 = as.numeric(points_1618),
      student_count = as.numeric(student_count),
      progress_score = as.numeric(progress_score)
    )

  totals_data <- x %>%
    filter(points_prior == "All" | points_1618 == "All")

  progress_table <- prepped_data %>%
    mutate(
      all_prog = student_count * progress_score,
      pos_prog = ifelse(
        student_count == "c",
        NA,
        ifelse(points_1618 > points_prior, student_count, 0)
      ),
      neg_prog = ifelse(
        student_count == "c",
        NA,
        ifelse(
          points_1618 < points_prior | is.na(points_1618),
          student_count,
          0
        )
      ),
      same_prog = ifelse(
        student_count == "c",
        NA,
        ifelse(points_1618 == points_prior, student_count, 0)
      ),
      four_prog = ifelse(
        student_count == "c",
        NA,
        ifelse(points_1618 >= 4, student_count, 0)
      )
    ) %>%
    group_by(points_prior) %>%
    summarise(
      mean_prog = round_five_up(
        sum(all_prog, na.rm = TRUE) / sum(student_count, na.rm = TRUE),
        3
      ),
      positive_progress = paste0(
        format(
          round_five_up(
            sum(pos_prog, na.rm = TRUE) *
              100 /
              sum(student_count, na.rm = TRUE),
            1
          ),
          nsmall = 1
        ),
        "%"
      ),
      same_score = paste0(
        format(
          round_five_up(
            sum(same_prog, na.rm = TRUE) *
              100 /
              sum(student_count, na.rm = TRUE),
            1
          ),
          nsmall = 1
        ),
        "%"
      ),
      negative_progress = paste0(
        format(
          round_five_up(
            sum(neg_prog, na.rm = TRUE) *
              100 /
              sum(student_count, na.rm = TRUE),
            1
          ),
          nsmall = 1
        ),
        "%"
      ),
      four_progress = paste0(
        format(
          round_five_up(
            sum(four_prog, na.rm = TRUE) *
              100 /
              sum(student_count, na.rm = TRUE),
            1
          ),
          nsmall = 1
        ),
        "%"
      )
    ) %>%
    mutate(points_prior = as.character(points_prior)) %>%
    bind_rows(
      prepped_data %>%
        mutate(
          all_prog = student_count * progress_score,
          pos_prog = ifelse(points_1618 > points_prior, student_count, 0),
          neg_prog = ifelse(
            points_1618 < points_prior | is.na(points_1618),
            student_count,
            0
          ),
          same_prog = ifelse(points_1618 == points_prior, student_count, 0),
          four_prog = ifelse(points_1618 >= 4, student_count, 0)
        ) %>%
        summarise(
          mean_prog = round_five_up(
            sum(all_prog, na.rm = TRUE) / sum(student_count, na.rm = TRUE),
            3
          ),
          positive_progress = paste0(
            format(
              round_five_up(
                sum(pos_prog, na.rm = TRUE) *
                  100 /
                  sum(student_count, na.rm = TRUE),
                1
              ),
              nsmall = 1
            ),
            "%"
          ),
          same_score = paste0(
            format(
              round_five_up(
                sum(same_prog, na.rm = TRUE) *
                  100 /
                  sum(student_count, na.rm = TRUE),
                1
              ),
              nsmall = 1
            ),
            "%"
          ),
          negative_progress = paste0(
            format(
              round_five_up(
                sum(neg_prog, na.rm = TRUE) *
                  100 /
                  sum(student_count, na.rm = TRUE),
                1
              ),
              nsmall = 1
            ),
            "%"
          ),
          four_progress = paste0(
            format(
              round_five_up(
                sum(four_prog, na.rm = TRUE) *
                  100 /
                  sum(student_count, na.rm = TRUE),
                1
              ),
              nsmall = 1
            ),
            "%"
          )
        ) %>%
        mutate(points_prior = "All")
    ) %>%
    mutate(
      mean_prog = case_when(
        is.na(mean_prog) ~ "c",
        TRUE ~ as.character(mean_prog)
      ),
      positive_progress = case_when(
        positive_progress == "NaN%" ~ "c",
        TRUE ~ as.character(positive_progress)
      ),
      same_score = case_when(
        same_score == "NaN%" ~ "c",
        TRUE ~ as.character(same_score)
      ),
      negative_progress = case_when(
        negative_progress == "NaN%" ~ "c",
        TRUE ~ as.character(negative_progress)
      ),
      four_progress = case_when(
        four_progress == "NaN%" ~ "c",
        TRUE ~ as.character(four_progress)
      )
    )

  tab_num_matrix <- prepped_data %>%
    mutate(
      points_1618 = ifelse(is.na(points_1618), "No.entry", points_1618)
    ) %>%
    group_by(points_prior, points_1618) %>%
    summarise(students = sum(student_count)) %>%
    ungroup() %>%
    arrange(points_prior, points_1618)

  all_tot <- totals_data %>%
    filter(points_1618 != "All") %>%
    select(student_count, points_1618) %>%
    tidyr::pivot_wider(
      names_from = points_1618,
      values_from = student_count
    ) %>%
    mutate(across(everything(), as.numeric)) %>%
    mutate(
      Total = rowSums(across(everything())),
      points_prior = "All",
      across(everything(), as.character)
    ) %>%
    rename(No.entry = `No entry`) %>%
    mutate(across(1:length(names(.)) - 1, cs_num))

  complete_matrix <- tab_num_matrix %>%
    tidyr::pivot_wider(
      names_from = points_1618,
      values_from = students,
      values_fill = 0
    ) %>%
    select(points_prior, No.entry, everything()) %>%
    mutate(points_prior = as.character(points_prior)) %>%
    left_join(
      totals_data %>%
        select(points_prior, student_count) %>%
        filter(points_prior != "All") %>%
        mutate(
          points_prior = as.character(as.numeric(points_prior)),
          student_count = as.character(student_count)
        ) %>%
        rename(Total = student_count),
      by = "points_prior"
    ) %>%
    mutate(across(2:length(names(.)), cs_num))

  if (colourTable == "Progress") {
    for (ii in names(complete_matrix)[
      !is.na(as.numeric(names(complete_matrix)))
    ]) {
      complete_matrix <- complete_matrix %>%
        mutate(
          !!ii := cell_spec(
            pull(.[, ii]),
            "html",
            background = ifelse(
              as.numeric(points_prior) > as.numeric(ii),
              "red",
              ifelse(
                as.numeric(points_prior) == as.numeric(ii),
                "orange",
                "green"
              )
            ),
            color = "white"
          )
        )
    }

    complete_matrix <- complete_matrix %>%
      {
        if ("No.entry" %in% names(.)) {
          mutate(
            .,
            No.entry = cell_spec(
              No.entry,
              "html",
              background = "red",
              color = "white"
            )
          )
        } else {
          .
        }
      }
  }

  if (colourTable == "Grade 4+") {
    for (ii in names(complete_matrix)[
      !is.na(as.numeric(names(complete_matrix)))
    ]) {
      complete_matrix <- complete_matrix %>%
        mutate(
          !!ii := cell_spec(
            pull(.[, ii]),
            "html",
            background = ifelse(4 <= as.numeric(ii), "green", "red"),
            color = "white"
          )
        )
    }
    complete_matrix <- complete_matrix %>%
      {
        if ("No.entry" %in% names(.)) {
          mutate(
            .,
            No.entry = cell_spec(
              No.entry,
              "html",
              background = "red",
              color = "white"
            )
          )
        } else {
          .
        }
      }
  }

  if (colourTable == "No colour") {
    complete_matrix <- complete_matrix
  }

  complete_matrix %>%
    bind_rows(all_tot) %>%
    mutate(points_prior = stringr::str_trim(points_prior)) %>%
    left_join(progress_table, by = "points_prior") %>%
    select(
      points_prior,
      No.entry,
      sort(names(.)[!is.na(as.numeric(names(.)))]),
      Total,
      mean_prog,
      positive_progress,
      same_score,
      negative_progress,
      four_progress
    ) %>%
    mutate(across(
      all_of(c("No.entry", names(.)[!is.na(as.numeric(names(.)))])),
      ~ str_replace(., "NA", "c")
    )) %>%
    plyr::rename(
      replace = c(
        "No.entry" = "No entry",
        "points_prior" = "Prior points",
        "mean_prog" = "Average progress (change in point score)",
        "positive_progress" = "Proportion improving their point score",
        "same_score" = "Proportion keeping the same point score",
        "negative_progress" = "Proportion lowering their point score",
        "four_progress" = "Proportion achieving a grade 4 or above"
      ),
      warn_missing = FALSE
    ) %>%
    kable(
      escape = F,
      format = "html",
      align = "c",
      format.args = list(big.mark = ",")
    ) %>%
    kable_styling(bootstrap_options = c("striped", "hover"), full_width = F) %>%
    scroll_box(width = "100%")
}
