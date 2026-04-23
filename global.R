# -----------------------------------------------------------------------------
# This is the global file.
#
# Use it to store functions, library calls, source files etc.
#
# Moving these out of the server file and into here improves performance as the
# global file is run only once when the app launches and stays consistent
# across users whereas the server and UI files are constantly interacting and
# responsive to user input.
#
# Library calls ---------------------------------------------------------------
shhh <- suppressPackageStartupMessages # It's a library, so shhh!

# Core shiny and R packages
shhh(library(shiny))
shhh(library(bslib))
shhh(library(rstudioapi))

# Custom packages
shhh(library(dfeR))
shhh(library(dfeshiny))
shhh(library(shinyGovstyle))

# Creating charts and tables
shhh(library(ggplot2))
shhh(library(DT))
shhh(library(sf))
shhh(library(leaflet))
shhh(library(htmltools))
shhh(library(reactable))
shhh(library(svglite))
shhh(library(afcharts))
shhh(library(ggrepel))
shhh(library(showtext))
shhh(library(openxlsx))

# Data and string manipulation
shhh(library(dplyr))
shhh(library(stringr))
shhh(library(ggiraph))
shhh(library(purrr)) # for reading in data (map_df)
shhh(library(readr)) # for reading in data (read_csv)
shhh(library(kableExtra)) # for progress matrix (cell_spec)

# Shiny extensions
shhh(library(shinyjs))
shhh(library(tools))
shhh(library(shinytitle))
shhh(library(xfun))
shhh(library(metathis))
shhh(library(shinyalert))

# Dependencies needed for testing or CI but not for the app -------------------
# Including them here keeps them in renv but avoids the app needlessly loading
# them, saving on load time.
if (FALSE) {
  shhh(library(shinytest2))
  shhh(library(chromote))
  shhh(library(rsconnect))
  shhh(library(testthat))
  shhh(library(devtools))
  shhh(library(shinya11y))
}

# Source scripts --------------------------------------------------------------

# Source any scripts here. Scripts may be needed to process data before it gets
# to the server file or to hold custom functions to keep the main files shorter
#
# It's best to do this here instead of the server file, to improve performance.

# Source script for loading in data
source("R/read_data.R")

# Source custom functions script
source("R/helper_functions.R")

gbp <- enc2utf8("\u00A3")

# Source all files in the ui_panels folder
lapply(list.files("R/ui_panels/", full.names = TRUE), source)

# Set global variables --------------------------------------------------------

site_title <- "English and Maths Progress Matrix" # name of app
parent_pub_name <- "A level and other 16 to 18 results" # name of source publication
parent_publication <- "https://explore-education-statistics.service.gov.uk/find-statistics/a-level-and-other-16-to-18-results" # link to source publication
parent_tech_guide <- "https://www.gov.uk/government/publications/16-to-19-accountability-headline-measures-technical-guide"
CoF_em_quals <- "https://www.gov.uk/government/publications/16-to-19-funding-maths-and-english-condition-of-funding"
em_quals_1618 <- "https://www.gov.uk/government/publications/16-to-18-english-and-maths-progress-measure-qualifications"


# Set the URLs that the site will be published to
site_primary <- "https://department-for-education.shinyapps.io/english-and-maths-progress-matrix/"

# Combine URLs into list for disconnect function
# We can add further mirrors where necessary. Each one can generally handle
# about 2,500 users simultaneously
sites_list <- c(site_primary)

# Set the key for Google Analytics tracking
google_analytics_key <- "S28X368HT7" ## <--------------------------------------------------------------------------------- UPDATE

# End of global variables -----------------------------------------------------

# Enable bookmarking so that input choices are shown in the url ---------------
enableBookmarking("url")

# Fonts for charts ------------------------------------------------------------
font_add("dejavu", "www/fonts/DejaVuSans.ttf")
register_font(
  "dejavu",
  plain = "www/fonts/DejaVuSans.ttf",
  bold = "www/fonts/DejaVuSans-Bold.ttf",
  italic = "www/fonts/DejaVuSans-Oblique.ttf",
  bolditalic = "www/fonts/DejaVuSans-BoldOblique.ttf"
)
showtext_auto()


# extract lists for use in drop downs -----------------------------------------
choices_subject <- c("English", "Maths")

choices_colour <- c("Progress", "Grade 4+", "No colour")
