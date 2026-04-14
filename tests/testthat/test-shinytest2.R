library(shinytest2)

test_that("{shinytest2} recording: english-and-maths-progress-matrix", {
  app <- AppDriver$new(
    test_path("../.."),
    name = "english-and-maths-progress-matrix",
    height = 1305, width = 2259,
    load_timeout = 360 * 1000,
    timeout = 360 * 1000
  )

  app$wait_for_idle(500)
  app$expect_values()

  app$set_inputs(navlistPanel = "matrix_dashboard", wait_ = FALSE)
  app$wait_for_idle(500)
  app$expect_values()

  app$set_inputs(dropdown_academicyr = "2024/25", wait_ = FALSE)
  app$wait_for_idle(500)
  app$expect_values()

  app$set_inputs(dropdown_subject = "English", wait_ = FALSE)
  app$wait_for_idle(500)
  app$expect_values()

  app$set_inputs(
    dropdown_subject = "Maths",
    dropdown_sex = "Female",
    wait_ = FALSE
  )
  app$wait_for_idle(500)
  app$expect_values()
})
