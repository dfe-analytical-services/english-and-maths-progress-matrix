library(shinytest2)

test_that("{shinytest2} recording: english-and-maths-progress-matrix", {
  app <- AppDriver$new(test_path("../.."),
    name = "english-and-maths-progress-matrix",
    height = 1305, width = 2259
  )
  app$expect_values()
  app$set_inputs(navlistPanel = "matrix_dashboard")
  app$expect_values()
  app$set_inputs(dropdown_subject = "Maths")
  app$expect_values()
})
