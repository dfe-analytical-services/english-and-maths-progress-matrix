# -----------------------------------------------------------------------------
# This is the ui file. Use it to call elements created in your server file into
# the app, and define where they are placed, and define any user inputs.
#
# Other elements like charts, navigation bars etc. are completely up to you to
# decide what goes in. However, every element should meet accessibility
# requirements and user needs.
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# The documentation for GOV.UK components can be found at:
#
#    https://github.com/moj-analytical-services/shinyGovstyle
#
# -----------------------------------------------------------------------------

ui <- function(input, output, session) {
  bslib::page_fluid(
    # shinya11y::use_tota11y(),
    # Set application metadata ------------------------------------------------
    tags$head(HTML("<title>16-18 English and maths progress matrix</title>")),
    tags$head(tags$link(rel = "shortcut icon", href = "dfefavicon.png")),
    use_shiny_title(),
    useShinyjs(),
    tags$html(lang = "en"),
    tags$head(
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "gov_table_style.css"
      )
    ),
    # Add meta description for search engines
    meta() %>%
      meta_general(
        application_name = "16-18 English and maths progress matrix",
        description = "16-18 English and maths progress matrix",
        robots = "index,follow",
        generator = "R-Shiny",
        subject = "stats development",
        rating = "General",
        referrer = "no-referrer"
      ),

    # Custom disconnect function ----------------------------------------------
    # Variables used here are set in the global.R file
    dfeshiny::custom_disconnect_message(
      links = sites_list,
      publication_name = parent_pub_name,
      publication_link = parent_publication
    ),

    # Load javascript dependencies --------------------------------------------
    shinyjs::useShinyjs(),
    shinyGovstyle::full_width_overrides(),
    # Cookies -----------------------------------------------------------------
    # Setting up cookie consent based on a cookie recording the consent:
    dfeshiny::dfe_cookies_script(),
    dfeshiny::cookies_banner_ui(
      name = "16-18 English and maths progress matrix"
    ),

    # Skip_to_main -------------------------------------------------------------
    # Add a 'Skip to main content' link for keyboard users to bypass navigation.
    # It stays hidden unless focussed via tabbing.
    shinyGovstyle::skip_to_main(),

    # Google analytics --------------------------------------------------------
    tags$head(includeHTML(("google-analytics.html"))),

    # Header ------------------------------------------------------------------
    shinyGovstyle::header(
      org_name = "Department for Education",
      service_name = "16-18 English and maths progress matrix"
    ),

    # Beta banner -------------------------------------------------------------
    shinyGovstyle::banner(
      "beta banner",
      "Beta",
      "This dashboard is in beta phase and we are still reviewing performance and reliability."
    ),
    gov_main_layout(
      bslib::navset_hidden(
        id = "pages",
        nav_panel(
          "dashboard",
          ## Main dashboard ---------------------------------------------------
          # Nav panels --------------------------------------------------------------
          shiny::navlistPanel(
            "",
            id = "navlistPanel",
            widths = c(2, 8),
            well = FALSE,
            # Content for these panels is defined in the R/ui_panels/ folder
            user_guide_panel(),
            matrix_dashboard_panel()
          )
        ),
        nav_panel(
          value = "accessibility_statement",
          "Accessibility",
          layout_columns(
            col_widths = c(-2, 8, -2),

            # Add in back link
            actionLink(
              class = "govuk-back-link",
              style = "margin: 0",
              "accessibility_to_dashboard",
              "Back to dashboard"
            ),
            dfeshiny::a11y_panel(
              dashboard_title = "16-18 English and maths progress matrix",
              dashboard_url = site_primary, ## <-------------------------------------------------- UPDATE
              date_tested = "14th April 2026",
              date_prepared = "14th April 2026",
              date_reviewed = "14th April 2026",
              issues_contact = "attainment.statistics@education.gov.uk",
              publication_name = "A level and other 16 to 18 results",
              publication_slug = "a-level-and-other-16-to-18-results",
              non_accessible_components = c(
                "Some navigation elements are not announced correctly by screen readers.",
                "Focus highlighting is limited within the dashboard."
              ),
              specific_issues = c(
                "Focus styling is missing which means that some features on the app do not change colour to indicate they have been selected.",
                "Heading image and link are not labelled appropriately"
              )
            )
          )
        ),
        nav_panel(
          value = "cookies_statement",
          "Cookies",
          layout_columns(
            col_widths = c(-2, 8, -2),

            # Add backlink
            actionLink(
              class = "govuk-back-link",
              style = "margin: 0",
              "cookies_to_dashboard",
              "Back to dashboard"
            ),
            cookies_panel_ui(google_analytics_key = google_analytics_key)
          )
        ),
        nav_panel(
          value = "support",
          "Support and feedback",
          # Set up column layout to center it -----------------------------------------
          layout_columns(
            col_widths = c(-2, 8, -2),

            # Add in back link
            actionLink(
              class = "govuk-back-link",
              style = "margin: 0",
              "support_to_dashboard",
              "Back to dashboard"
            ),
            support_panel(
              team_email = "attainment.statistics@education.gov.uk",
              repo_name = "https://github.com/dfe-analytical-services/english-and-maths-progress-matrix", ## <----------------------------- UPDATE
              publication_name = "A level and other 16 to 18 results",
              # publication_slug = "a-level-and-other-16-to-18-results",
              form_url = "https://forms.office.com/e/Sa4ULADzx4"
            )
          )
        )
      )
    ),

    # Footer ------------------------------------------------------------------
    shinyGovstyle::footer(
      full = TRUE,
      links = c(
        "Support",
        "Accessibility statement",
        "Cookies statement"
      )
    )
  )
}
