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
          gov_row(
            column(
              width = 6,
              selectizeInput(
                inputId = "dropdown_academicyr",
                label = "Select an academic year:",
                choices <- paste0(
                  substr(sort(unique(raw_data$academic_year)), 1, 4),
                  "/",
                  substr(
                    sort(unique(raw_data$academic_year)),
                    5,
                    nchar(sort(unique(raw_data$academic_year)))
                  )
                )
              )
            ),
            column(
              width = 6,
              selectizeInput(
                inputId = "dropdown_subject",
                label = "Choose a subject:",
                choices <- choices_subject
              )
            ),
            column(
              width = 6,
              selectizeInput(
                inputId = "dropdown_sex",
                label = "Choose a sex:",
                choices <- raw_data %>%
                  select(sex) %>%
                  distinct() %>%
                  pull() %>%
                  sort(.)
              )
            ),
            column(
              width = 6,
              # checkboxInput(
              # inputId = "select_colour",
              # label = "Display table in colour?",
              # value = TRUE
              selectizeInput(
                inputId = "select_colour",
                label = "Display table in colour?",
                choices <- choices_colour
              )
            )
          ),
          # data download --------------------------------------------------
          gov_row(
            column(
              width = 12,
              paste("Download the underlying data for this dashboard:"),
              br(),
              downloadButton(
                outputId = "download_data",
                label = "Download data",
                icon = NULL,
                class = "gov-uk-button-secondary"
              )
            )
          )
        ),
        # matrix table output --------------------------------------------------
        gov_row(
          column(
            width = 12,
            h2(textOutput("reactive_matrix_title_out")),
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
