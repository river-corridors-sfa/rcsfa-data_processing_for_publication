# test-create_flmd_skeleton_v2.R ###############################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-04-24
# Date Updated: 2025-05-16

# Objective:
# Verify that `create_flmd()` behaves as expected under a variety of conditions.
# This includes checking that the function makes sure it has the correct inputs,
# returns the correct output, and is able to handle edge cases, warnings, and
# errors. This script sets up temporary test files and directories, runs the
# tests, and cleans up after itself to ensure consistent test behavior.

# Directions: 
# Whenever you make changes to `create_flmd()`, rerun this script to ensure all
# existing tests still pass. Add new tests as needed to verify that your updates
# work as expected and haven't broken any existing functionality.


### Prep Script ################################################################

# clear global env and restart R session
rm(list=ls(all=T))
rstudioapi::restartSession()

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

  # returns a tibble
  expect_s3_class(create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F), "tbl_df")

  # returns a tibble that must include required cols
  result = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F)
  expect_true(all(c("File_Name", "File_Description", "Standard", "Header_Rows", "Column_or_Row_Name_Position", "File_Path") %in% names(result)))

  # returns a tibble that includes all files in dir
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F) %>% select(File_Name, File_Path), 
               expected = tibble(File_Name = c("example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "01_script.R"),
                                 File_Path = c("/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/scripts")))

  # returns a tibble where the columns have the correct class
  result <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F)
  
  expect_equal(object = class(result$File_Name), 
               expected = "character")
  expect_equal(object = class(result$File_Description), 
               expected = "character")
  expect_equal(object = class(result$Standard), 
               expected = "character")
  expect_equal(object = class(result$Header_Rows), 
               expected = "numeric")
  expect_equal(object = class(result$Column_or_Row_Name_Position), 
               expected = "numeric")
  expect_equal(object = class(result$File_Path), 
               expected = "character")

  # returns a tibble that adds placeholders when add_placeholders = T and uses the dp_keyword input to name the placeholders
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = T) %>% select(File_Name, File_Path),
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "example_data_package_flmd.csv", "example_data_package_dd.csv", "example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "01_script.R"),
                                 File_Path = c("/example_data_package", "/example_data_package", "/example_data_package", "/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/scripts")))

  # includes included files
  expect_equal(object = create_flmd(files_df = get_files(directory = my_data_package_dir, include_files = c("data/file_b.csv", "data/example_boye.csv")), dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F) %>% select(File_Name, File_Path), 
               expected = tibble(File_Name = c("example_boye.csv", "file_b.csv"),
                                 File_Path = c("/example_data_package/data", "/example_data_package/data")))

  # excludes excluded files
  expect_equal(object = create_flmd(files_df = get_files(directory = my_data_package_dir, exclude_files = c("data/file_b.csv", "data/example_boye.csv")), dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F) %>% select(File_Name, File_Path), 
               expected = tibble(File_Name = c("example_goldman.csv", "file_a.csv", "01_script.R"),
                                 File_Path = c("/example_data_package/data", "/example_data_package/data", "/example_data_package/scripts")))

  # populates the Standard column based on https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/RF_FLMD_Standard_Terms.csv
    # populates the Standard column with "ESS-DIVE CSV v1" if the File_Name file extension is ".csv" or ".tsv"
    # populates the Standard column with "ESS-DIVE FLMD v1; ESS-DIVE CSV v1" if the File_Name ends with "*flmd.csv" or "*dd.csv"
    # populates the Standard column with "N/A" if the file extension is not ".csv" or ".tsv"
  
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = T) %>% select(File_Name, Standard),
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "example_data_package_flmd.csv", "example_data_package_dd.csv", "example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "01_script.R")) %>% 
                 mutate(Standard = case_when(File_Name %in% c("readme_example_data_package.pdf", "01_script.R") ~ "N/A",
                                             File_Name %in% c("example_data_package_flmd.csv", "example_data_package_dd.csv") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1",
                                             File_Name %in% c("example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv") ~ "ESS-DIVE CSV v1")))

  # populates Boye and Goldman standards only if query_header_info = T
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = T, add_placeholders = T) %>% select(File_Name, Standard),
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "example_data_package_flmd.csv", "example_data_package_dd.csv", "example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "01_script.R")) %>% 
                          mutate(Standard = case_when(File_Name %in% c("readme_example_data_package.pdf", "01_script.R") ~ "N/A",
                                             File_Name %in% c("example_data_package_flmd.csv", "example_data_package_dd.csv") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1",
                                             File_Name %in% c("file_a.csv", "file_b.csv") ~ "ESS-DIVE CSV v1",
                                             File_Name %in% c("example_boye.csv") ~ "ESS-DIVE Water-Soil-Sediment Chem v1; ESS-DIVE CSV v1",
                                             File_Name %in% c("example_goldman.csv") ~ "ESS-DIVE Hydrologic Monitoring v1; ESS-DIVE CSV v1")))

  # populates the Header_Rows column based on ...
    # if no headers... then == 1 (Header_Rows are the number of rows above the row the data start on, including the column names but excluding any row that begins with "#")
    # if boye... then == the number indicated in cell B2 (after #Header_Rows)
    # if goldman... then == 1
    # if other... then == user input - 1 (because the user gives the row the start start on and Header_Rows = data_start - 1)
  
  # add another data file
  add_example_data_with_header_rows(my_data_package_dir)
  my_files <- get_files(directory = my_data_package_dir)
  
  # test with 1 boye, 1 goldman, 1 normal, 1 with a header row below col names
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = T, add_placeholders = F) %>% select(File_Name, Header_Rows), 
               expected = tibble(File_Name = c("example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "file_c.csv", "01_script.R"), 
                                 Header_Rows = c(5, 1, 1, 1, 1, -9999)))

  # populates the Column_or_Row_Name_Position column based on ...
    
    # if query_header_info = T
      # if no headers... then == 1 (index starts at the column header row, not the row the data start on)
      # if boye... then == 1
      # if goldman... then == 1
      # if other... then == user input (because read_csv is reading in without col names, the col names end up being on row 1)
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = T, add_placeholders = F) %>% select(File_Name, Column_or_Row_Name_Position),
               expected = tibble(File_Name = c("example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "file_c.csv", "01_script.R"),
                                 Column_or_Row_Name_Position = c(1, 1, 1, 1, 1, -9999)))
  
  # if query_header_info = F
    # -9999 if not tabular
    # NA if tabular
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F) %>% select(File_Name, Column_or_Row_Name_Position),
               expected = tibble(File_Name = c("example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "file_c.csv", "01_script.R"),
                                 Column_or_Row_Name_Position = c(NA, NA, NA, NA, NA, -9999)))
  
  # remove all test files
  unlink(my_data_package_dir, recursive = T, force = T)

})

### expected edge cases ########################################################

test_that("expected typical inputs", {
  
  # create data
  my_data_package_dir <- create_test_dir()
  add_example_data(my_data_package_dir)
  add_example_script(my_data_package_dir)
  add_example_dot_files(my_data_package_dir)
  
  my_files <- get_files(directory = my_data_package_dir, include_dot_files = T)
  
 # returns tibble that includes . files if include_dot_files = T
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F) %>% select(File_Name),
               expected = tibble(File_Name = c(".hidden_file_a.txt", ".hidden_file_b.txt", "file_a.csv", "file_b.csv", "01_script.R")))
  
  # remove all test files
  unlink(my_data_package_dir, recursive = T, force = T)
  
})


### expected warnings ##########################################################

test_that("expected warnings", {
  
  # 2025-05-14 note: using log_warn() instead of base R's warning(), so test_that
  # is unable to run warning checks
  
  # warns when excluding files

  # if tabular files are present and query_header_info = F, then warn the user that the Boye and Goldman standards (if applicable) need to be manually added to the FLMD
  
})


### expected errors ############################################################

test_that("expected errors", {
  
  # create data
  my_data_package_dir <- create_test_dir()
  add_example_data(my_data_package_dir)
  add_example_script(my_data_package_dir)
  add_example_dot_files(my_data_package_dir)
  
  my_files <- get_files(directory = my_data_package_dir, include_dot_files = T)
  
  
  # errors if files_df doesn't include required cols
  expect_error(object = create_flmd(files_df = get_files(directory = my_data_package_dir) %>% 
                                      select(absolute_dir, file), dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F), 
               regexp = "Function terminating.")
  
  # errors if add_boye_headers, add_flmd_dd_headers, and include_file_names are not either T or F
  expect_error(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = "YES"),
               regexp = "Function terminating.")
  
  expect_error(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", add_placeholders = "YES"),
               regexp = "Function terminating.")
  
  # remove all test files
  unlink(my_data_package_dir, recursive = T, force = T)
  
})
  
  
