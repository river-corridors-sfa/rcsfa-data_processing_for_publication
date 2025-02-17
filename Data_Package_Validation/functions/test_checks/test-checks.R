### test-checks.R ##############################################################
# Date Created: 2024-10-11
# Date Updated: 2024-12-11
# Author: Bibi Powers-McCormack

# Objective: Create a test driven development script to validate checks.R

# Directions: 
  # 1. Open `data_package_checks.R` and run the `Prep Script` chunk.
  # 2. Open `checks.R` and run the `Checks Inputs` and `Checks Functions` chunks. 
  # 3. Return to this script and run this script. 

# Status: in progress
  # write out rest of testing data - use "bad_data" folder as an example
  # write out tests for each function
  # run tests and write down bugs at top of checks.R list
  # go through bugs and use test script to attempt to solve
  # test example data packages in study and manuscript data package folder
  # as more errors come up, add examples to test_checks.R file
  # repeat

  # delete `create testing data` section? not sure if i need it? 
  # update `status` section of this script

### Prep script ################################################################

# load libraries
library(tidyverse)
library(testthat)
library(hms)


# ### Create testing data ########################################################
# 
# testing_data <- list(
#   # directory names with no errors
#   directory_no_errors = c("folder1/foldera", "folder1/folderb", "folder_2", "folder3/foldera", "folder3/folderb", "folder3/folder-c"),
#   
#   # directory names with special characters
#   directory_error_with_spaces = c("folder1/folder a", "folder1/folderb", "folder 2", "folder3/foldera", "folder 3/folder b", "folder3/folderc"),
#   directory_error_with_specialchrs = c("folder1/folder$a", "folde?r1/folderb", "folder__2", "folder3/foldera", "folder3/folderb", "folder3/folderc"),
#   
#   # file names with no errors
#   file_names_no_errors = c("data_file_1.csv", "data_file_2.csv", "data_file_3.csv", "script_1.R", "script_2.R"),
#   
#   # file name empty
#   file_names_error_empty = c("data_file_1.csv", "data_file_2.csv", "data_file_3.csv", "", "script_1.R", "script_2.R"),
#   
#   # file names with special characters
#   file_names_no_errors = c("data_file_1.csv", "data_file_$2.csv", "0123_data_file_3.csv", "script-1.R", "script_2+.R"),
#   
#   # file names with proprietary extensions
#   file_names_no_errors = c("data_file_1.docx", "data_file_2.xlsx", "data_file_3.doc", "script_1.R", "script_2.R"),
#   
#   # file names with duplicates
#   file_names_error_empty = c("data_file_1.csv", "data_file_2.csv", "data_file_2.csv", "", "script_1.R", "script_2.R"),
#   
#   # tabular data with no errors
#   tabular_data_no_errors = tibble(col_chr = c("apple", "banana", "grape", "N/A", "", "kiwi", "melon", "berry", "peach", "plum"), # Character column
#                                   col_num = c(1.1, 2.5, -9999, 4.2, 5.9, 6.3, 7.7, 8.1, NA, 10.5), # Numeric column
#                                   col_log = c(TRUE, FALSE, TRUE, TRUE, FALSE, NA, FALSE, TRUE, FALSE, TRUE), # Logical column
#                                   col_date = as.Date(c("2024-01-01", "2024-01-05", "2024-01-10", "2024-01-15", "2024-01-20", "2024-01-25", "2024-01-30", "2024-02-05", "2024-02-10", "2024-02-15")), # Date column
#                                   col_mixed = as.character(c(10, "twenty", 30, "forty", 50, "N/A", 70, "eighty", 90, "one hundred")), # Mixed data (numeric and text)
#                                   col_datetime = ymd_hms(c("2024-01-01 12:34:56", "2024-01-05 06:12:43", NA, "2024-01-15 18:45:12", "2024-01-20 23:59:59", "2024-01-25 08:30:15", "2024-01-30 09:25:32", "2024-02-05 21:16:18", "2024-02-10 11:11:11", "2024-02-15 16:45:50")), # Date-time column
#                                   col_time = as_hms(c("12:00:00", "06:15:45", "14:30:25", "18:00:00", "23:45:00", "08:05:15", "09:15:00", "21:45:25", "11:59:59", "16:10:00"))), # Time-only column)
#   
#   # tabular data with column header special characters
#   tabular_data_error_with_header_special_chrs = tibble(),
#   
#   # tabular data with column header empty
#   tabular_data_error_with_header_empty = tibble(), 
#   
#   # tabular data with column header duplicates
#   tabular_data_error_with_header_empty = tibble()
#   
#   # [add data for range report checks]
#   
#   
# )


### Run tests ##################################################################


#### all files ####

test_that("required file strings are present", {
  
  # test for when there are no errors in input
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example_flmd.csv", "readme_example.pdf", "example_dd.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", TRUE, "includes required files", "example_flmd.csv", ".*flmd\\.csv$", "all_file_names", "example_flmd.csv",
                       "required", TRUE, "includes required files", "example_dd.csv", ".*dd\\.csv$", "all_file_names", "example_dd.csv",
                       "required", TRUE, "includes required files", "readme_example.pdf", "^readme.*\\.pdf$", "all_file_names", "readme_example.pdf"))
  
  # test for when readme, flmd, and dd are missing
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example2.csv", "example3.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", FALSE, "includes required files", NA_character_, ".*flmd\\.csv$", "all_file_names", NA_character_,
                       "required", FALSE, "includes required files", NA_character_, ".*dd\\.csv$", "all_file_names", NA_character_,
                       "required", FALSE, "includes required files", NA_character_, "^readme.*\\.pdf$", "all_file_names", NA_character_))
  
  # test for when only flmd and dd are present
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example_flmd.csv", "example_dd.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", TRUE, "includes required files", "example_flmd.csv", ".*flmd\\.csv$", "all_file_names", "example_flmd.csv",
                       "required", TRUE, "includes required files", "example_dd.csv", ".*dd\\.csv$", "all_file_names", "example_dd.csv",
                       "required", FALSE, "includes required files", NA_character_, "^readme.*\\.pdf$", "all_file_names", NA_character_))
  
  # test for when readme file doesn't begin with "readme"
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example_flmd.csv", "example_readme.pdf", "example_dd.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", TRUE, "includes required files", "example_flmd.csv", ".*flmd\\.csv$", "all_file_names", "example_flmd.csv",
                       "required", TRUE, "includes required files", "example_dd.csv", ".*dd\\.csv$", "all_file_names", "example_dd.csv",
                       "required", FALSE, "includes required files", NA_character_, "^readme.*\\.pdf$", "all_file_names", NA_character_))
  
})


#### folders ####
test_that("no special characters are present in directory names", {
  
  # test for when there are no errors in input
  expect_equal(object = check_for_no_special_chrs(input = "example/directory", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "directory_name",
                                                  file = "example.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no special characters", "example/directory", "none", "directory_name", "example.csv"))
  
  # test for when there are special characters in input
  expect_equal(object = check_for_no_special_chrs(input = "example/directory name/with (spaces)", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "directory_name",
                                                  file = "example.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no special characters", "example/directory name/with (spaces)", "space", "directory_name", "example.csv",
                                  "strongly recommended", FALSE, "no special characters", "example/directory name/with (spaces)", "space", "directory_name", "example.csv",
                                  "strongly recommended", FALSE, "no special characters", "example/directory name/with (spaces)", "(", "directory_name", "example.csv",
                                  "strongly recommended", FALSE, "no special characters", "example/directory name/with (spaces)", ")", "directory_name", "example.csv"))
  
  # test for when source is entered incorrectly
  expect_error(object = check_for_no_special_chrs(input = "example/directory", 
                            invalid_chrs = input_parameters$special_chrs,
                            data_checks_table = initialize_checks_df(),
                            source = "directory",
                            file = "example.csv"))
})


#### files ####
test_that("no special characters are present in file names", {
  
  # test for when there are no errors in input
  expect_equal(object = check_for_no_special_chrs(input = "example_filename.csv",
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "file_name",
                                                  file = "example_filename.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no special characters", "example_filename.csv", "none", "file_name", "example_filename.csv"))
  
  # test for when there are special characters in input
  expect_equal(object = check_for_no_special_chrs(input = "/example filename.csv", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "file_name",
                                                  file = "example filename.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no special characters", "/example filename.csv", "/", "file_name", "example filename.csv",
                                  "strongly recommended", FALSE, "no special characters", "/example filename.csv", "space", "file_name", "example filename.csv"))
  
  # test for when source is entered incorrectly
  expect_error(object = check_for_no_special_chrs(input = "example_filename.csv", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "File_name",
                                                  file = "example_filename.csv"))
  
  
})

test_that("no proprietary file extensions are present in file names", {
  
  # test for when there are no proprietary files in input
  expect_equal(object = check_for_no_proprietary_files(input = "example_file_name.csv", 
                                                       invalid_extensions = input_parameters$non_proprietary_extensions, 
                                                       data_checks_table = initialize_checks_df(), 
                                                       source = "file_name", 
                                                       file = "example_file_name.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no proprietary files", "example_file_name.csv", "none", "file_name", "example_file_name.csv"))
  
  # test for when there are proprietary files in input
  expect_equal(object = check_for_no_proprietary_files(input = "example file_name.xlsx", 
                                                       invalid_extensions = input_parameters$non_proprietary_extensions, 
                                                       data_checks_table = initialize_checks_df(), 
                                                       source = "file_name", 
                                                       file = "example file_name.xlsx"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no proprietary files", "example file_name.xlsx", ".xlsx", "file_name", "example file_name.xlsx"))
  
  
})

test_that("file names are unique", {
  
  # test for when there are no duplicate file names
  expect_equal(object = check_for_unique_names(input = "example1.csv",
                                               all_names = c("example1.csv", "example2.csv", "example3.csv"),
                                               source = "file_name",
                                               file = "example1.csv"), 
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no duplicate names", "example1.csv", "example1.csv x1", "file_name", "example1.csv"))
  
  # test for when there are duplicate file names
  expect_equal(object = check_for_unique_names(input = "example1.csv",
                                               all_names = c("example1.csv", "example1.csv", "example3.csv"),
                                               source = "file_name",
                                               file = "example1.csv"), 
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no duplicate names", "example1.csv", "example1.csv x2", "file_name", "example1.csv"))
  
  # test for when source is entered incorrectly
  expect_error(object = check_for_unique_names(input = "example1.csv",
                                               all_names = c("example1.csv", "example2.csv", "example3.csv"),
                                               source = "File_name",
                                               file = "example1.csv"))
  
})


#### tabular data - checks ####

test_that("no special chracters are present in column names", {
  
  # test for when there are no special characters in input
  expect_equal(object = check_for_no_special_chrs(input = "example_column_name",
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "column_header",
                                                  file = "example_filename.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no special characters", "example_column_name", "none", "column_header", "example_filename.csv"))
  
  # test for when there are special characters in input
  expect_equal(object = check_for_no_special_chrs(input = "column with space", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "column_header",
                                                  file = "example_filename.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no special characters", "column with space", "space", "column_header", "example_filename.csv",
                                  "strongly recommended", FALSE, "no special characters", "column with space", "space", "column_header", "example_filename.csv"))
  
  expect_equal(object = check_for_no_special_chrs(input = "column$specialchr", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "column_header",
                                                  file = "example_filename.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no special characters", "column$specialchr", "$", "column_header", "example_filename.csv"))
  
  expect_equal(object = check_for_no_special_chrs(input = "", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "column_header",
                                                  file = "example_filename.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no special characters", "", "column_header is empty", "column_header", "example_filename.csv"))
  
})

test_that("column names are unique", {
  
  # test for when there are unique column headers
  expect_equal(object = check_for_unique_names(input = "col_chr",
                                               all_names = c("col_chr", "col$num", "col_log"),
                                               source = "column_header",
                                               file = "example1.csv"), 
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no duplicate names", "col_chr", "col_chr x1", "column_header", "example1.csv"))
  
  expect_equal(object = check_for_unique_names(input = "col$num",
                                               all_names = c("col_chr", "col$num", "col_log"),
                                               source = "column_header",
                                               file = "example1.csv"), 
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no duplicate names", "col$num", "col$num x1", "column_header", "example1.csv"))
  

  # test for when there are duplicate column headers
  expect_equal(object = check_for_unique_names(input = "col_chr",
                                               all_names = c("col_chr", "col_chr", "col$num"),
                                               source = "column_header",
                                               file = "example1.csv"), 
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no duplicate names", "col_chr", "col_chr x2", "column_header", "example1.csv"))
  
  # test for when there are duplicate column headers where the substring of a shorter column header is included in another col name
  expect_equal(object = check_for_unique_names(input = "col", 
                                               all_names = c("col", "col_chr", "another_name"),
                                               source = "column_header", 
                                               file = "example1.csv"),
              expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                 "strongly recommended", TRUE, "no duplicate names", "col", "col x1", "column_header", "example1.csv"))
  
  # test for when there's a combination of duplicate col names and substring matches
  expect_equal(object = check_for_unique_names(input = "col", 
                                               all_names = c("col", "col_chr", "col", "another_name", "another_col"),
                                               source = "column_header", 
                                               file = "example1.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", FALSE, "no duplicate names", "col", "col x2", "column_header", "example1.csv"))
})


#### checks summary ####

test_that("checks only pass when all items meet the passing criteria", {
  
  
  
  
})


#### tabular data - range reports ####

test_that("column type is identified as either character, numeric, logical, Date, hms, POSIXct, or mixed", {
  
  testing_df <- tibble(
    chr_column = c("apple", "banana", "cherry", "date"),
    numeric_column = c(42.7, 23.1, 67.3, 89.0),
    logical_column = c(TRUE, FALSE, TRUE, FALSE),
    date_column = as.Date(c("2024-01-01", "2024-02-14", "2024-03-15", "2024-04-22")),
    hms_column = hms::as_hms(c("12:30:45", "08:15:00", "19:00:30", "05:45:15")),
    date_time_column = as.POSIXct(c("2024-01-01 12:00:00", "2024-02-01 15:30:00", "2024-03-01 08:45:00", "2024-04-01 22:15:00"), format = "%Y-%m-%d %H:%M:%S"),
    mixed_column = c("ABC", "123", "DEF", "456")
  )
  
  result <- create_range_report(input_df = testing_df,
                                input_df_name = "testing", 
                                report_table = initialize_report_df(),
                                missing_value_codes = input_parameters$missing_value_codes) %>% 
    select(column_name, column_type)
  
  expected <- tibble(
    column_name = c("chr_column", "numeric_column", "logical_column", "date_column", "hms_column", "date_time_column", "mixed_column"),
    column_type = c("character", "numeric", "logical", "Date", "hms", "POSIXct", "mixed"))
  
  expect_equal(object = result, 
               expected = expected)
  
})

test_that("the number of missing rows are correctly reported", {
  
  testing_df <- tibble(
    id = 1:8,                                     
    name = c("Alice", "Bob", "Charlie", "Dana", "Eve", "Frank", "Grace", "Hank"), 
    score = c(95, 87, 78, 82, NA, 91, -9999, -9999),
    passed = c(TRUE, TRUE, TRUE, FALSE, NA, TRUE, FALSE, NA),
    date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", NA, "2024-01-08")),
    time_logged = hms::as_hms(c("12:34:56", "13:45:56", NA, "15:30:45", "10:00:00", NA, "11:23:10", "14:50:00")),
    category = factor(c("A", "B", "A", "C", "B", NA, "A", "C")), 
    notes = c(NA, "Good performance", "Average", "N/A", "Excellent", "N/A", "Needs improvement", "")
  )
  
  result <- create_range_report(input_df = testing_df,
                                input_df_name = "testing", 
                                report_table = initialize_report_df(),
                                missing_value_codes = input_parameters$missing_value_codes) %>% 
    select(column_name, num_missing_rows)
  
  expected <- tibble(
    column_name = c("id", "name", "score", "passed", "date", "time_logged", "category", "notes"),
    num_missing_rows = c(0, 0, 3, 2, 1, 2, 1, 4))
  
  expect_equal(object = result,
               expected = expected)
  
})

test_that("numerical min and max ranges are correctly reported", {
  
  testing_df <- tibble(
    date = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07", "2024-01-08", "2024-01-09", "2024-01-10")),
    time_logged = hms::as_hms(c("12:00:00", "14:30:00", "09:45:00", "11:15:00", "16:00:00", "08:20:00", "13:10:00", "10:40:00", "15:30:00", "17:50:00")),
    datetime = as.POSIXct(c("2024-01-01 12:00:00", "2024-01-02 14:30:00", "2024-01-03 09:45:00", "2024-01-04 11:15:00", "2024-01-05 16:00:00", "2024-01-06 08:20:00", "2024-01-07 13:10:00", "2024-01-08 10:40:00", "2024-01-09 15:30:00", "2024-01-10 17:50:00")),
    value1 = c(42, 28, 50, -67, 83, 23, 56, 90, 77, 55),
    value2 = c(5, 8, 6, 10, 7, 9, 4, 11, 12, 3),
    value3 = c(0.5, 0.7, 0.3, 0.8, 0.6, 0.9, 0.4, -1.0, 0.2, 0.75),
    value4 = c(100, -200, 300, 400, 500, 600, 700, 800, 900, 1000),
    value5 = c(15, 12, 19, 11, 14, 10, 17, 16, 13, 18),
    value6 = c("GHI", 25, 20, 22, "JKL", 27, -24, 26, "MNO", "MNO"),
    value7 = c(50, -60, 70, 80, 90, 100, 110, 120, 130, 140)
  )
  
  result <- create_range_report(input_df = testing_df,
                                input_df_name = "testing", 
                                report_table = initialize_report_df(),
                                missing_value_codes = input_parameters$missing_value_codes) %>% 
    select(column_name, range_min, range_max, num_negative_rows)
  
  expected <- tibble(
    column_name = c("date", "time_logged", "datetime", "value1", "value2", "value3", "value4", "value5", "value6", "value7"),
    range_min = c("2024-01-01", "08:20:00", "2024-01-01 12:00:00", -67, 3, -1, -200, 10, -24, -60),
    range_max = c("2024-01-10", "17:50:00", "2024-01-10 17:50:00", 90, 12, 0.9, 1000, 19, 27, 140),
    num_negative_rows = c(NA, NA, NA, 1, 0, 1, 1, 0, 1, 1)
  )
  
  expect_equal(object = result, 
               expected = expected)
  
})
