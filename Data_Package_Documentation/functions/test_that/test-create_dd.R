# test-create_dd.R #############################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-02
# Date Updated: 2025-05-22

# Objective:
# Verify that `create_dd()` behaves as expected under a variety of conditions.
# This includes checking that the function makes sure it has the correct inputs,
# returns the correct output, and is able to handle edge cases, warnings, and
# errors. This script sets up temporary test files and directories, runs the
# tests, and cleans up after itself to ensure consistent test behavior.

# Directions: 
# Whenever you make changes to `create_dd()`, rerun this script to ensure all
# existing tests still pass. Add new tests as needed to verify that your updates
# work as expected and haven't broken any existing functionality.


### Prep Script ################################################################

# clear global env, restart R session, and clear console
rm(list=ls(all=T))
rstudioapi::restartSession()
cat("\014")

# set wd
current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("../../..")

# load libraries
library(tidyverse)
library(rlog)
library(devtools) # for sourcing in functions
library(testthat) # for testing
library(fs) # for temp dir creation

# load functions
source("./Data_Package_Documentation/functions/create_flmd.R")
source("./Data_Package_Documentation/functions/create_dd.R")

# source in testing data
source("./Data_Package_Documentation/functions/test_that/example_data_for_flmd_dd_tests.R")

# system(paste("open", shQuote(create_test_dir()))) # open on mac
# shell.exec(create_test_dir()) # open on windows


### expected typical inputs ####################################################
test_that("expected typical inputs", {
  
  # create data
  my_data_package_dir <- create_test_dir()
  add_example_data(my_data_package_dir)
  add_example_script(my_data_package_dir)
  add_example_boye(my_data_package_dir)
  add_example_goldman(my_data_package_dir)
  
  my_files <- get_files(directory = my_data_package_dir)
  my_flmd <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F)
  
  # returns a tibble
  expect_s3_class(create_dd(files_df = my_files, flmd_df = my_flmd), "tbl_df")
  
  # returns a tibble that must include required cols
  result = create_dd(files_df = my_files, flmd = my_flmd)
  expect_true(all(c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type", "Missing_Value_Code") %in% names(result)))

  # returns a tibble where the columns have the correct class
  result <- create_dd(files_df = my_files, flmd_df = my_flmd)

  expect_equal(object = class(result$Column_or_Row_Name),
               expected = "character")
  expect_equal(object = class(result$Unit),
               expected = "character")
  expect_equal(object = class(result$Definition),
               expected = "character")
  expect_equal(object = class(result$Data_Type),
               expected = "character")
  expect_equal(object = class(result$Term_Type),
               expected = "character")
  expect_equal(object = class(result$Missing_Value_Code),
               expected = "character")

  # returns a tibble that adds placeholders when add_boye_headers = T and add_flmd_dd_headers = T
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = T, add_flmd_dd_headers = T, include_filenames = T) %>% filter(str_detect(associated_files, "\\bboye template\\b|\\bflmd template\\b|\\bdd template\\b")) %>% select(Column_or_Row_Name),
               expected = tibble(Column_or_Row_Name = c("Analysis_DetectionLimit", "Analysis_Precision", "Column_or_Row_Name", "Column_or_Row_Name_Position", "Data_Status", "Data_Type", "Definition", "File_Description", "File_Name", "File_Path", "Header_Rows", "MethodID_Analysis", "MethodID_DataProcessing", "MethodID_Inspection", "MethodID_Preparation", "MethodID_Preservation", "MethodID_Storage", "Missing_Value_Code", "Standard", "Term_Type", "Unit", "Unit_Basis")))

  # populates Missing_Value_Code column  with '"-9999"; "N/A"; "": NA"'
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = T, add_flmd_dd_headers = F) %>% select(Missing_Value_Code) %>% unique() %>% pull(),
               expected = '"N/A"; "-9999"; ""; "NA"')

  # returns a tibble with all column headers
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = F, add_flmd_dd_headers = F) %>% select(Column_or_Row_Name),
               expected = tibble(Column_or_Row_Name = c("00602_TN_mg_per_L_as_N", "00681_NPOC_mg_per_L_as_C", "Battery",
                                                        "DateTime", "Dissolved_Oxygen", "Dissolved_Oxygen_Saturation",
                                                        "Field_Name", "ID",  "id",  "Material",  "Methods_Deviation", "Name",
                                                        "Parent_ID",  "Passed",  "Sample_Name", "Score", "Site_ID", "Temperature",
                                                        "value")))

  # if FLMD is not provided (it's NA and not a tibble), then it assumes data are
  # read in where header_rows = 1 and column_or_row_name_position = 1
  expect_equal(object = create_dd(files_df = my_files) %>% select(Column_or_Row_Name),
               expected = tibble(Column_or_Row_Name = c("00602_TN_mg_per_L_as_N", "00681_NPOC_mg_per_L_as_C", "Battery",
                                                        "DateTime", "Dissolved_Oxygen", "Dissolved_Oxygen_Saturation",
                                                        "Field_Name", "ID",  "id",  "Material",  "Methods_Deviation", "Name",
                                                        "Parent_ID",  "Passed",  "Sample_Name", "Score", "Site_ID", "Temperature",
                                                        "value")))
  

})

### expected edge cases ########################################################

test_that("expected edge cases", {
  
  # create data
  my_data_package_dir <- create_test_dir()
  add_example_data(my_data_package_dir)
  add_example_script(my_data_package_dir)
  add_example_boye(my_data_package_dir)
  add_example_goldman(my_data_package_dir)
  
  my_files <- get_files(directory = my_data_package_dir)
  my_flmd <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F)
  
  
  # returns 2 additional columns (header_count and associated_files) if include_filenames = T
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, include_filenames = T) %>% names(.), 
               expected = c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type", "Missing_Value_Code", "header_count", "associated_files"))
  
})


### expected warnings ##########################################################

test_that("expected warnings", {
  
  # create data
  my_data_package_dir <- create_test_dir()
  add_example_data(my_data_package_dir)
  add_example_script(my_data_package_dir)
  add_example_boye(my_data_package_dir)
  add_example_goldman(my_data_package_dir)
  
  my_files <- get_files(directory = my_data_package_dir)
  my_flmd <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F)
  
  # 2025-05-14 note: removed R's base warning() code from function and replaced
  # it with log_warn(). This means that the test_that expect_warning() tests no
  # longer work - this is why they are commented out
  
  # warns if joining the flmd results in some files not matching up
  # expect_warning(object = create_dd(files_df = my_files, flmd_df = my_flmd),
  #                regexp = "Created the DD after user acknowledged possible discrepency between tabular files and FLMD.")
  
  # warns that function will assume no header rows are present if FLMD is not a data frame
  # expect_warning(object = create_dd(files_df = my_files),
  #                regexp = "Created the DD assuming headers are on the first row.")
  
 
})

### expected errors ############################################################

test_that("expected errors", {
  
  # create data
  my_data_package_dir <- create_test_dir()
  add_example_data(my_data_package_dir)
  add_example_script(my_data_package_dir)
  add_example_boye(my_data_package_dir)
  add_example_goldman(my_data_package_dir)
  
  my_files <- get_files(directory = my_data_package_dir)
  my_flmd <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F)
  
  # errors if files_df doesn't include required cols
  expect_error(object = create_dd(files_df = get_files(directory = my_data_package_dir) %>% 
                                    select(absolute_dir, file), 
                                  flmd_df = my_files), 
               regexp = "Function terminating.")
  
  # errors if add_boye_headers, add_flmd_dd_headers, and include_file_names are not either T or F
  expect_error(object = create_dd(files_df = my_files, add_boye_headers = "YES"),
               regexp = "Function terminating.")
  
  expect_error(object = create_dd(files_df = my_files, add_flmd_dd_headers = "YES"),
               regexp = "Function terminating.")
  
  expect_error(object = create_dd(files_df = my_files, include_filenames = "YES"),
               regexp = "Function terminating.")
  
  # errors if FLMD doesn't include required cols
  expect_error(object = create_dd(files_df = my_files, flmd_df = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F) %>% 
                                    select(File_Name, File_Path)), 
               regexp = "Function terminating.")

})


