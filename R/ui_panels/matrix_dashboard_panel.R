matrix_dashboard_panel <- function() {
  tabPanel(
    value = "matrix_dashboard",
    "Matrix dashboard",
    gov_main_layout(
      gov_row(
        column(
          width = 12,
          heading_text(
            "16-18 English and maths progress by prior attainment matrix",
            size = "m",
            level = 2
          )
        ),
        # input selection --------------------------------------------------
        column(
          width = 12,
          layout_columns(
            selectizeInput(
              inputId = "dropdown_academicyr",
              label = "Academic year",
              choices <- paste0(
                substr(sort(unique(raw_data$academic_year)), 1, 4),
                "/",
                substr(
                  sort(unique(raw_data$academic_year)),
                  5,
                  nchar(sort(unique(raw_data$academic_year)))
                )
              )
            ),
            selectizeInput(
              inputId = "dropdown_subject",
              label = "Subject",
              choices <- choices_subject
            ),
            selectizeInput(
              inputId = "dropdown_sex",
              label = "Sex",
              choices <- raw_data %>%
                select(sex) %>%
                distinct() %>%
                pull() %>%
                sort(.)
            ),
            # checkboxInput(
            # inputId = "select_colour",
            # label = "Display table in colour?",
            # value = TRUE
            selectizeInput(
              inputId = "select_colour",
              label = "Highlighting style",
              choices <- choices_colour
            )
          )
        ),
        # data download --------------------------------------------------
        gov_row(
          column(
            width = 12,
            download_button(
              outputId = "download_data",
              button_label = "Download underlying data"
            )
          )
        ),
        # matrix table output --------------------------------------------------
        gov_row(
          column(
            width = 12,
            tags$h2(textOutput("reactive_matrix_title_out"), class = "govuk-heading-m"),
            gov_row(
              column(
                width = 12,
                tableOutput("progress_table_out")
              )
            )
          )
        )
      )
    )
  )
}
