### test-update_landing_page_authors.R #########################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-11
# Date Updated: 2025-03-11

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

#### tests that function runs as expected for typical inputs and edge cases ---- 
  
# correctly formatted docx

# test various name formats
  # there are 3 types: 1. first middle last; 2. first last; 3. last

# [1] all first middle last 

# [2] first last

# [3] only last

# [123] mixed (first middle, first last, last)

# [12] mixed (first middle last, first last)

# [13] mixed (first middle last, last)

# [23] mixed (first last, last)


#### tests that function throws errors/warnings as expected ----

# no names listed

# no start/end markers in docx

# instructions or non-names included in docx

# authors listed last, first

# docx file missing


### Tests for `get_author_spreadsheet_info()` ##################################

#### tests that function runs as expected for typical inputs and edge cases ---- 


#### tests that function throws errors/warnings as expected ----


### Tests for `update_landing_page_authors()` ##################################

#### tests that function runs as expected for typical inputs and edge cases ---- 


#### tests that function throws errors/warnings as expected ----


