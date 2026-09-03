matrix_dashboard_panel <- function() {
  tabPanel(
    value = "matrix_dashboard",
    "Matrix dashboard",
    gov_main_layout(
      gov_row(
        column(
          width = 12,
          bslib::card(
            bslib::card_header(
              heading_text(
                "16-19 English and maths progress by prior attainment matrix",
                size = "m",
                level = 2
              )
            ),
            bslib::card_body(
              # input selection --------------------------------------------------
              layout_column_wrap(
                width = 1 / 4,
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
                selectizeInput(
                  inputId = "select_colour",
                  label = "Highlighting style",
                  choices <- choices_colour
                )
              ),
              # data download --------------------------------------------------
              gov_row(
                column(
                  width = 12,
                  downloadButton(
                    outputId = "download_data",
                    label = "Download underlying data (CSV, 50KB)",
                    icon = icon("download"),
                    class = "btn-primary"
                  )
                )
              )
            )
          )
        )
      ),
      # matrix table output --------------------------------------------------
      gov_row(
        column(
          width = 12,
          bslib::card(
            bslib::card_header(
              uiOutput("reactive_matrix_title")
            ),
            bslib::card_body(
              tableOutput("progress_table_out")
            )
          )
        )
      )
    )
  )
}
