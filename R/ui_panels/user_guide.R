user_guide_panel <- function() {
  tabPanel(
    "User guide",
    gov_main_layout(
      gov_row(
        column(
          12,
          heading_text(
            "16-18 English and maths progress by prior attainment matrix",
            size = "l",
            level = 1
          )
        )
      ),

      ## Left panel -------------------------------------------------------

      column(
        12,
        bslib::card(
          bslib::card_header(
            heading_text("Information", size = "m", level = 2)
          ),
          bslib::card_body(
            heading_text("Introduction", size = "s", level = 3),
            gov_text(
              "Welcome to the 16-18 English and maths progress matrix app."
            ),
            gov_text(
              "The 16-18 English and maths progress matrix is a tool that can be used to
            visualise the breakdown of KS4 average prior attainment and 16-18 attainment in English or maths
            for students in scope for the 16-18 English and maths progress measure."
            ),
            gov_text(
              "Within the Matrix Dashboard, a choice of academic year, subject, and sex can be selected and the
            built in chart will be updated to reflect the users choices.
            The chart can be displayed with or without colour highlighting. The colour option can be helpful
            to identify different groups of students based on the selected option. Cells can be coloured corresponding to the progress
            students' make during the 16-18 phase: positive (green), negative (red), remaining at the same level (yellow). Cells can also
            be coloured by whether or not a grade 4 or above was achieved by the end of the 16-18 phase."
            ),
            gov_text(
              "The data in this app are subject to suppression. Where data for a given prior or 16-18 attainment group have been suppressed,
                    the total number of students for that is still shown. Prior and 16-18 attainment totals have been adjusted to match the sum of the unsuppressed cells."
            ),
            gov_text(
              "To begin using the app please navigate to the ",
              actionLink("link_to_dashboard_tab", "Matrix Dashboard tab.")
            )
          )
        )
      ),

      ## Right panel ------------------------------------------------------

      column(
        12,
        bslib::card(
          bslib::card_header(
            heading_text("Context and purpose", size = "m", level = 2)
          ),
          bslib::card_body(
            heading_text("Statistical Release", size = "s", level = 3),
            gov_text(
              "A full breakdown of national English and maths progress measures can be found in the ",
              external_link(parent_publication, "parent_publication"),
              " statistical release."
            ),
            # gov_text("English and maths progress measures were temporarily paused from 2021/22 to 2023/24 due to alternative
            #   grading standards awarded at KS4 during the Covid-19 pandemic and our commitment to not include results from
            #   qualifications awarded between January 2020 and August 2021."),
            heading_text("Guidance sources", size = "s", level = 3),
            gov_text(
              actionLink(
                "CoF_em_quals",
                "Guidance on the maths and English Condition of Funding"
              ),
              " sets out the full list of qualification types equivalent to GCSE grade 9-4 for the purpose of prior attainment."
            ),
            gov_text(
              "A comprehensive list of points to be used in performance measures can be found here: ",
              actionLink(
                "em_quals_1618",
                "English and maths progress measure qualifications."
              )
            ),
            gov_text(
              "Additional information about the 16-18 English and maths progress measure can be found in the ",
              actionLink(
                "parent_tech_guide",
                "16 to 18 accountability measures technical guidance."
              )
            )
          )
        )
      )
    )
  )
}
