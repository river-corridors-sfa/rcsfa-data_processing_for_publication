### test-update_landing_page_authors.R #########################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-11
# Date Updated: 2025-03-14

# Objective: 
# This script contains the tests for the functions in `update_landing_page_authors.R`.

# Instructions: 
# Every time updates are made to `update_landing_page_authors.R`, return to this script to confirm all tests still pass. 
# To run this script: 
  # Open `update_landing_page_authors.R` and source all functions. 
  # Run the entirety of this script

### Prep Script ################################################################

# load libraries for testing
library(tidyverse)
library(testthat)

# load function dependencies
library(tidyverse)
library(rlog)
library(officer) # for reading in docx files
library(readxl) # for reading in excel files
library(janitor) # for cleaning up col headers
library(glue)
library(devtools) # for sourcing in script
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API


### Tests for `get_authors_from_essdive_metadata()` ############################

# create temp testing env
temp_directory <- tempdir()
log_info(paste0("Opening temp directory: ", temp_directory))
shell.exec(temp_directory)

# define docx defaults
docx_default_text <- fp_text(font.family = "Calibri", font.size = 11)
docx_bold_text <- fp_text(font.family = "Calibri", font.size = 11, bold = TRUE)

# function to add above essdive text
add_header_text <- function(docx) {
  
  docx <- docx %>% 
    body_add_fpar(fpar(ftext("ESS-DIVE Metadata for [insert brief/short title] Data Package", prop = docx_bold_text), fp_p = fp_par(text.align = "center"))) %>% 
    body_add_fpar(fpar(ftext("Title:", prop = docx_bold_text))) %>% 
    body_add_fpar(fpar(ftext("[Insert title]", prop = docx_default_text))) %>%
    body_add_par("") %>% 
    body_add_par("Alternative Identifiers:") %>% 
    body_add_par("[Leave blank unless you have a DOI for this data from elsewhere already] ") %>% 
    body_add_par("") %>% 
    body_add_par("Abstract:") %>% 
    body_add_par("[Insert abstract. This should be identical to the one you put in your data package readme file. We recommend copying the “summary” and “data package structure” sections from your readme and pasting them both here one after the other. Do not use special characters. If shortcuts work for you, use “Alt+34” for the “ (quotation mark); use “Alt+39” for the ' (apostrophe); use “Alt+45” for dash or hyphen. When you upload your package, pay close attention to any special characters. You may need to manually fix them.]  ") %>% 
    body_add_par("") %>% 
    body_add_par("Keywords:") %>% 
    body_add_par("[List each keyword on a new line]") %>% 
    body_add_par("ESS-DIVE CSV File Formatting Guidelines Reporting Format") %>% 
    body_add_par("ESS-DIVE File Level Metadata Reporting Format") %>% 
    body_add_par("") %>% 
    body_add_par("Data variables:") %>% 
    body_add_par("[List each variable/parameter on a new line]") %>% 
    body_add_par("") %>% 
    body_add_par("Pub date:") %>% 
    body_add_par("[Leave blank if you want the date to be the date it is actually published. Otherwise use the format YYYY-MM-DD]") %>% 
    body_add_par("") %>% 
    body_add_par("Data usage rights:") %>% 
    body_add_par("[Choose either Creative Commons Public Domain or Creative Commons Attribution]") %>% 
    body_add_par("") %>% 
    body_add_par("Project:") %>% 
    body_add_par("River Corridor and Watershed Biogeochemistry SFA") %>% 
    body_add_par("") %>% 
    body_add_par("Funding org:") %>% 
    body_add_par("U.S. DOE > Office of Science > Biological and Environmental Research (BER)") %>% 
    body_add_par("") %>% 
    body_add_par("DOE Contracts:") %>% 
    body_add_par("DOE Award #54737") %>% 
    body_add_par("") %>% 
    body_add_par("Related reference:") %>% 
    body_add_par("[Insert any related references to manuscripts, other data packages, and reporting formats.] ") %>% 
    body_add_par("Agarwal, D., Cholia, S., Hendrix, V. C., Crystal-Ornelas, R., Snavely, C., Damerow, J., & Varadharajan. (2022). ESS-DIVE Reporting Format for Dataset Metadata. Environmental Systems Science Data Infrastructure for a Virtual Ecosystem (ESS-DIVE), ESS-DIVE repository. https://doi.org/10.15485/1866026") %>% 
    body_add_par("Velliquette, T., Welch, J., Crow, M., Devarakonda, R., Heinz, S., Crystal-Ornelas, R. (2021). ESS-DIVE Reporting Format for Comma-separated Values (CSV) File Structure. Environmental Systems Science Data Infrastructure for a Virtual Ecosystem (ESS-DIVE), ESS-DIVE Repository. https://doi.org/10.15485/1734841") %>% 
    body_add_par("Velliquette, T., Welch, J., Crow, M., Devarakonda, R., Heinz, S., Crystal-Ornelas, R. (2021). ESS-DIVE Reporting Format for File-level Metadata. Environmental Systems Science Data Infrastructure for a Virtual Ecosystem (ESS-DIVE), ESS-DIVE Repository. https://doi.org/10.15485/1734840") %>% 
    body_add_par("") %>% 
    body_add_par("Principal investigator:") %>% 
    body_add_par("Scheibe") %>% 
    body_add_par("") %>% 
    body_add_par("Contact name: ") %>% 
    body_add_par("[Insert contact first name and last name or last name. ]") %>% 
    body_add_par("") %>% 
    body_add_par("Contact email:") %>% 
    body_add_par("[Insert contact email]") %>% 
    body_add_par("") %>% 
    body_add_par("Creators:")
  
  return(docx)
} # end of add_header_text()

# function to add default creator text
add_default_creator_text <- function(docx) {
  
  docx <- docx %>% 
    body_add_par("[List each data package author – one per row. You can list only the last name or you can list the full name.]")
  
  return(docx)  
  
} # end of add_default_creator_text()

# function to add below essdive text
add_footer_text <- function(docx) {
  
  docx <- docx %>% 
    body_add_par("") %>% 
    body_add_par("Start date:") %>% 
    body_add_par("[Insert start date of the study as YYYY-MM-DD or leave blank if not applicable]") %>% 
    body_add_par("") %>% 
    body_add_par("End date:") %>% 
    body_add_par("[Insert end date of the study as YYYY-MM-DD or leave blank if not applicable]") %>% 
    body_add_par("") %>% 
    body_add_par("Location description:") %>% 
    body_add_par("[You have two options. Either write “refer to metadata spreadsheet” which will tell the code to automatically pull location description information from the associated spreadsheet; or you can write a description here for one location, follow example “Columbia River, WA, USA”]") %>% 
    body_add_par("") %>% 
    body_add_par("Coordinates:") %>% 
    body_add_par("[You have two options. If you have more than one location, write “refer to metadata spreadsheet” which will tell the code to automatically pull location description information from the associated spreadsheet; or if you have one location, you can write a description here; please write latitude and longitude in two lines following example:") %>% 
    body_add_par("“Latitude.deg=46.16") %>% 
    body_add_par("Longitude.deg=-116.18”]") %>% 
    body_add_par("") %>% 
    body_add_par("Methods:") %>% 
    body_add_par("[Write a very brief summary of the methods associated with your data package. In addition to the summary, you can point to methods information in your data package or in your manuscript.]")
  
  return(docx)
} # end of add_footer_text()

# template for how to use the above functions
# essdive_metadata_template <- read_docx() %>% 
#   add_header_text() %>% 
#   add_default_creator_text() %>% 
#   body_add_par("EXAMPLE AUTHORS GO HERE") %>% 
#   add_footer_text()
# 
# print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))


#### tests that function runs as expected for typical inputs and edge cases ---- 
  
# test correctly formatted docx with various name inputs
  # there are 3 types of name formats: 1. first middle last; 2. first last; 3. last

# [1] all first middle last 
test_that("authors are imported correctly [1]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Alice Marie Johnson") %>% 
    body_add_par("Benjamin Lee Carter") %>% 
    body_add_par("Charlotte Ann Thompson") %>% 
    body_add_par("Daniel James Rodriguez") %>% 
    body_add_par("Emily R. Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Alice Marie Johnson", 
                                     "Benjamin Lee Carter", 
                                     "Charlotte Ann Thompson", 
                                     "Daniel James Rodriguez", 
                                     "Emily R. Martinez"),
                            first_name = c("Alice", "Benjamin", "Charlotte", "Daniel", "Emily"),
                            middle_name = c("Marie", "Lee", "Ann", "James", "R."),
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# [2] first last
test_that("authors are imported correctly [2]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Alice Johnson") %>% 
    body_add_par("Benjamin Carter") %>% 
    body_add_par("Charlotte Thompson") %>% 
    body_add_par("Daniel Rodriguez") %>% 
    body_add_par("Emily Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Alice Johnson", 
                                     "Benjamin Carter", 
                                     "Charlotte Thompson", 
                                     "Daniel Rodriguez", 
                                     "Emily Martinez"),
                            first_name = c("Alice", "Benjamin", "Charlotte", "Daniel", "Emily"),
                            middle_name = NA_character_,
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# [3] only last
test_that("authors are imported correctly [3]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Johnson") %>% 
    body_add_par("Carter") %>% 
    body_add_par("Thompson") %>% 
    body_add_par("Rodriguez") %>% 
    body_add_par("Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Johnson", 
                                     "Carter", 
                                     "Thompson", 
                                     "Rodriguez", 
                                     "Martinez"),
                            first_name = NA_character_,
                            middle_name = NA_character_,
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# [123] mixed (first middle, first last, last)
test_that("authors are imported correctly [123]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Alice Marie Johnson") %>% 
    body_add_par("Benjamin Carter") %>% 
    body_add_par("Thompson") %>% 
    body_add_par("Daniel Rodriguez") %>% 
    body_add_par("Emily R. Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Alice Marie Johnson", 
                                     "Benjamin Carter", 
                                     "Thompson", 
                                     "Daniel Rodriguez", 
                                     "Emily R. Martinez"),
                            first_name = c("Alice", "Benjamin", NA_character_, "Daniel", "Emily"),
                            middle_name = c("Marie", NA_character_, NA_character_, NA_character_, "R."),
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# [12] mixed (first middle last, first last)
test_that("authors are imported correctly [12]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Alice Marie Johnson") %>% 
    body_add_par("Benjamin Carter") %>% 
    body_add_par("Charlotte Ann Thompson") %>% 
    body_add_par("Daniel James Rodriguez") %>% 
    body_add_par("Emily Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Alice Marie Johnson", 
                                     "Benjamin Carter", 
                                     "Charlotte Ann Thompson", 
                                     "Daniel James Rodriguez", 
                                     "Emily Martinez"),
                            first_name = c("Alice", "Benjamin", "Charlotte", "Daniel", "Emily"),
                            middle_name = c("Marie", NA_character_, "Ann", "James", NA_character_),
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# [13] mixed (first middle last, last)
test_that("authors are imported correctly [13]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Johnson") %>% 
    body_add_par("Benjamin Lee Carter") %>% 
    body_add_par("Charlotte Ann Thompson") %>% 
    body_add_par("Rodriguez") %>% 
    body_add_par("Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Johnson", 
                                     "Benjamin Lee Carter", 
                                     "Charlotte Ann Thompson", 
                                     "Rodriguez", 
                                     "Martinez"),
                            first_name = c(NA_character_, "Benjamin", "Charlotte", NA_character_, NA_character_),
                            middle_name = c(NA_character_, "Lee", "Ann", NA_character_, NA_character_),
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# [23] mixed (first last, last)
test_that("authors are imported correctly [23]", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Alice Johnson") %>% 
    body_add_par("Carter") %>% 
    body_add_par("Thompson") %>% 
    body_add_par("Daniel Rodriguez") %>% 
    body_add_par("Martinez") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Alice Johnson", 
                                     "Carter", 
                                     "Thompson", 
                                     "Daniel Rodriguez", 
                                     "Martinez"),
                            first_name = c("Alice", NA_character_, NA_character_, "Daniel", NA_character_),
                            middle_name = NA_character_,
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# extra white space
test_that("authors are imported correctly when there are extra spaces", {
  
  # create ess-dive metadata file (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Alice Marie  Johnson") %>% 
    body_add_par("Benjamin  Lee  Carter") %>% 
    body_add_par("Charlotte Ann Thompson   ") %>% 
    body_add_par(" Daniel  James Rodriguez") %>% 
    body_add_par("Emily  R.  Martinez ") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Alice Marie Johnson", 
                                     "Benjamin Lee Carter", 
                                     "Charlotte Ann Thompson", 
                                     "Daniel James Rodriguez", 
                                     "Emily R. Martinez"),
                            first_name = c("Alice", "Benjamin", "Charlotte", "Daniel", "Emily"),
                            middle_name = c("Marie", "Lee", "Ann", "James", "R."),
                            last_name = c("Johnson", "Carter", "Thompson", "Rodriguez", "Martinez"))
  
  # run function 
  expect_equal(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})


#### tests that function throws errors/warnings as expected ----

# no names listed
test_that("errors if no authors found", {
  
  # create ess-dive metadata file with no line (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- "ERROR. No names detected."
  
  # run function 
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
  
  # create ess-dive metadata file with empty line (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- "ERROR. No names detected."
  
  # run function 
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# no start/end markers in docx
test_that("errors if no start or end markers", {
  
  # create ess-dive metadata file with no end pattern (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- "ERROR. Start or end pattern not found, or they are in the wrong order."
  
  # run function 
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
  
  # create ess-dive metadata file with no pattern (expected input)
  essdive_metadata_template <- read_docx()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- "ERROR. Start or end pattern not found, or they are in the wrong order."
  
  # run function 
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# instructions or non-names included in docx
test_that("errors if instructions are still included in file", {
  
  # create ess-dive metadata file with instructions still in docx (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    add_default_creator_text() %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- "ERROR. Data package instructions are still in document. Delete the instructions and try again."
  
  # run function 
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# authors listed last, first
test_that("errors if authors names are in wrong order (last, first)", {
  
  # create ess-dive metadata file with names listed as last, first (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Johnson, Alice M.") %>% 
    body_add_par("Thompson, Charlotte") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- "ERROR. Commas detected in names; authors likely listed in incorrect format. Reformat to `first middle last` and try again."
  
  # run function 
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})

# authors listed as four names (e.g., John Michael David Smith)
test_that("warning if authors names include more than 3 parts", {
  
  # create ess-dive metadata file with names listed as last, first (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    body_add_par("Johnson") %>% 
    body_add_par("Charlotte Thompson") %>% 
    body_add_par("John Michael David Smith") %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- tibble(name = c("Johnson", 
                                     "Charlotte Thompson", 
                                     "John Michael David Smith"),
                            first_name = c(NA_character_, "Charlotte", "John"),
                            middle_name = NA_character_,
                            last_name = c("Johnson", "Thompson", "Smith"))
  
  # run function 
  expect_equal(object = suppressWarnings(get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx"))),
               expected = expected_output)
  expect_warning(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")),
                 expected = "WARNING: When names with more than 3 parts were detected, 
                 only the first and last names were retained and any additional names were ignored. 
                 Review the affected names and manually adjust them if necessary.")
  
})

# docx file missing
test_that("errors if .docx input file isn't found", {
  
  # create ess-dive metadata with default template (expected input)
  essdive_metadata_template <- read_docx() %>% 
    add_header_text() %>% 
    add_default_creator_text() %>% 
    add_footer_text()
  
  print(essdive_metadata_template, target = paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # intentionally remove the file we just created
  file.remove(paste0(temp_directory, "/essdive_metadata_template.docx"))
  
  # this is what the function should return
  expected_output <- paste0("Error: could not find ", temp_directory, "/essdive_metadata_template.docx file")
  
  # run function
  expect_error(object = get_authors_from_essdive_metadata(essdive_metadata_file = paste0(temp_directory, "/essdive_metadata_template.docx")), 
               expected = expected_output)
  
})


### Tests for `get_author_spreadsheet_info()` ##################################

#### tests that function runs as expected for typical inputs and edge cases ---- 

# all names are in author spreadsheet

# some names are in author spreadsheet

# no names are in author spreadsheet

# middle name in author spreadsheet, but not in ess-dive list

# middle name in ess-dive list, but not in author spreadsheet


#### tests that function throws errors/warnings as expected ----

# author spreadsheet doesn't have required cols

# 


### Tests for `update_landing_page_authors()` ##################################

#### tests that function runs as expected for typical inputs and edge cases ---- 


#### tests that function throws errors/warnings as expected ----


