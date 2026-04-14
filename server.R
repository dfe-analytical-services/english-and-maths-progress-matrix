# -----------------------------------------------------------------------------
# This is the server file.
#
# Use it to create interactive elements like tables, charts and text for your
# app.
#
# Anything you create in the server file won't appear in your app until you call
# it in the UI file. This server script gives examples of plots and value boxes
#
# There are many other elements you can add in too, and you can play around with
# their reactivity. The "outputs" section of the shiny cheatsheet has a few
# examples of render calls you can use:
# https://shiny.rstudio.com/images/shiny-cheatsheet.pdf
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# -----------------------------------------------------------------------------
server <- function(input, output, session) {
  # The template uses bookmarking to store input choices in the url. You can
  # exclude specific inputs (for example extra info created for a datatable
  # or plotly chart) using the list below, but it will need updating to match
  # any entries in your own dashboard's bookmarking url that you don't want
  # including.
  setBookmarkExclude(c(
    "cookies", "link_to_app_content_tab",
    "tabBenchmark_rows_current", "tabBenchmark_rows_all",
    "tabBenchmark_columns_selected", "tabBenchmark_cell_clicked",
    "tabBenchmark_cells_selected", "tabBenchmark_search",
    "tabBenchmark_rows_selected", "tabBenchmark_row_last_clicked",
    "tabBenchmark_state",
    "plotly_relayout-A",
    "plotly_click-A", "plotly_hover-A", "plotly_afterplot-A",
    ".clientValue-default-plotlyCrosstalkOpts"
  ))

  observe({
    # Trigger this observer every time an input changes
    reactiveValuesToList(input)
    session$doBookmark()
  })

  onBookmarked(function(url) {
    updateQueryString(url)
  })

  observe({
    if (input$navlistPanel == "dashboard") {
      change_window_title(
        session,
        paste0(
          site_title, " - ",
          input$choicesAcYr, ", ",
          input$choicesSubject, ", ",
          input$choicesSex
        )
      )
    } else {
      change_window_title(
        session,
        paste0(
          site_title, " - ",
          input$navlistPanel
        )
      )
    }
  })

  # Cookies logic -------------------------------------------------------------
  output$cookies_status <- dfeshiny::cookies_banner_server(
    input_cookies = shiny::reactive(input$cookies),
    parent_session = session,
    google_analytics_key = google_analytics_key
  )

  dfeshiny::cookies_panel_server(
    input_cookies = shiny::reactive(input$cookies),
    google_analytics_key = google_analytics_key
  )


  # FOR THE APP ---------------------------------------------------------------
  observeEvent(input$link_to_dashboard_tab, {
    updateTabsetPanel(session, "navlistPanel", selected = "matrix_dashboard")
  })


  # reactive progress table data ----------------------------------------------
  reactive_progress_data <- reactive({
    raw_data %>%
      filter(sex == input$dropdown_sex & academic_year == gsub("/", "", input$dropdown_academicyr) & subject == input$dropdown_subject)
  })


  progress_table <- reactive({
    progress_tab(reactive_progress_data(), input$select_colour)
  })

  output$progress_table_out <- renderText({
    progress_table()
  })


  ## reactive matrix table title ----------------------------------------------
  reactive_matrix_title <- reactive({
    paste0(
      "Matrix of prior attainment and progress point scores in ", input$dropdown_subject,
      " by students at the end of 16-18 studies in ", input$dropdown_academicyr, "."
    )
  })

  output$reactive_matrix_title_out <- renderText({
    reactive_matrix_title()
  })


  observeEvent(input$go, {
    toggle(id = "div_a", anim = T)
  })


  # link in the user guide panel back to the main panel -----------------------
  observeEvent(input$link_to_app_content_tab, {
    updateTabsetPanel(session, "navlistPanel", selected = "dashboard")
  })

  # download the underlying data button --------------------------------------
  output$download_data <- downloadHandler(
    filename = "EM_matrix_underlying_data.csv",
    content = function(file) {
      write.csv(raw_data, file, , row.names = FALSE)
    }
  )

  # Wrap a plot with a larger spinner
  with_gov_spinner <- function(ui_element, spinner_type = 6, size = 1, color = "#1d70b8") {
    shinycssloaders::withSpinner(
      ui_element,
      type = spinner_type,
      color = color,
      size = size,
      proxy.height = paste0(250 * size, "px")
    )
  }

  # navigation link within text --------------------------------------------
  observeEvent(input$nav_link, {
    shiny::updateTabsetPanel(session, "navlistPanel", selected = input$nav_link)
  })

  # Dynamic label showing custom selections -----------------------------------
  output$dropdown_label <- renderText({
    paste0("Current selections: ", input$selectPhase, ", ", input$selectArea)
  })

  # footer links -----------------------
  shiny::observeEvent(input$accessibility_statement, {
    shiny::updateTabsetPanel(session, "navlistPanel", selected = "a11y_panel")
  })

  shiny::observeEvent(input$use_of_cookies, {
    shiny::updateTabsetPanel(session, "navlistPanel", selected = "cookies_panel_ui")
  })

  shiny::observeEvent(input$support_and_feedback, {
    shiny::updateTabsetPanel(session, "navlistPanel", selected = "support_panel_ui")
  })
}
