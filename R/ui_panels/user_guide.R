user_guide_panel <- function() {
  tabPanel(
    "User guide",
    gov_main_layout(
      gov_row(
        column(
          12,
          tags$div(HTML('<h1 class="govuk-heading-l"> 16-18 English and maths progress by
                              prior attainment matrix </h1>')),
          br(),
          br()
        ),

        ## Left panel -------------------------------------------------------

        column(
          12,
          div(
            div(
              class = "panel panel-info",
              div(
                class = "panel-heading",
                style = "color: white;font-size: 18px;font-style: bold;
                background-color: #1d70b8;",
                tags$div(HTML('<h2 class="govuk-heading-m"> Information </h2>'))
              ),
              div(
                class = "panel-body",
                tags$div(
                  tags$div(HTML('<h3 class="govuk-heading-s"> Introduction </h3>')),
                  p("Welcome to the 16-18 English and maths progress matrix app."),
                  p("The 16-18 English and maths progress matrix is a tool that can be used to
            visualise the breakdown of KS4 average prior attainment and 16-18 attainment in English or maths
            for students in scope for the 16-18 English and maths progress measure."),
                  p("Within the Matrix Dashboard, a choice of academic year, subject, and sex can be selected and the
            built in chart will be updated to reflect the users choices.
            The chart can be displayed with or without colour highlighting. The colour option can be helpful
            to identify different groups of students based on the selected option. Cells can be coloured corresponding to the progress
            students' make during the 16-18 phase: positive (green), negative (red), remaining at the same level (yellow). Cells can also
            be coloured by whether or not a grade 4 or above was achieved by the end of the 16-18 phase."),
                  p("The data in this app are subject to suppression. Where data for a given prior or 16-18 attainment group have been suppressed,
                    the total number of students for that is still shown. Prior and 16-18 attainment totals have been adjusted to match the sum of the unsuppressed cells."),
                  p("To begin using the app please navigate to the ", actionLink("link_to_dashboard_tab", "Matrix Dashboard tab.")),
                  br(),
                )
              )
            )
          ),
        ),

        ## Right panel ------------------------------------------------------

        column(
          12,
          div(
            div(
              class = "panel panel-info",
              div(
                class = "panel-heading",
                style = "color: white;font-size: 18px;font-style: bold;
                background-color: #1d70b8;",
                tags$div(HTML('<h2 class="govuk-heading-m"> Context and purpose </h2>'))
              ),
              div(
                class = "panel-body",
                tags$div(HTML('<h3 class="govuk-heading-s"> Statistical Release </h3>')),
                p(
                  "A full breakdown of national English and maths progress measures can be found in the ",
                  actionLink("parent_publication", parent_pub_name), " statistical release."
                ),
                # p("English and maths progress measures were temporarily paused from 2021/22 to 2023/24 due to alternative
                #   grading standards awarded at KS4 during the Covid-19 pandemic and our commitment to not include results from
                #   qualifications awarded between January 2020 and August 2021."),
                br(),
                tags$div(HTML('<h3 class="govuk-heading-s"> Guidance sources </h3>')),
                p(
                  actionLink("CoF_em_quals", "Guidance on the maths and English Condition of Funding"),
                  " sets out the full list of qualification types equivalent to GCSE grade 9-4 for the purpose of prior attainment."
                ),
                p("A comprehensive list of points to be used in performance measures can be found here: ", actionLink("em_quals_1618", "English and maths progress measure qualifications.")),
                p("Additional information about the 16-18 English and maths progress
            measure can be found in the ", actionLink("parent_tech_guide", "16 to 18 accountability measures technical guidance.")),
              )
            )
          )
        )
      )
    )
  )
}
