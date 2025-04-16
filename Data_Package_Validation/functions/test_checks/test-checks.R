### test-checks.R ##############################################################
# Date Created: 2024-10-11
# Date Updated: 2024-12-11
# Author: Bibi Powers-McCormack

# Objective: Create a test driven development script to validate checks.R

# Directions: 
  # 1. Open `data_package_checks.R` and run the `Prep Script` chunk.
  # 2. Open `checks.R` and run the `Checks Inputs` and `Checks Functions` chunks. 
  # 3. Return to this script and run this script. 

# Status: complete

### Prep script ################################################################

# load libraries
library(tidyverse)
library(testthat)
library(hms)

### Run tests ##################################################################


#### all files ####

test_that("required file strings are present", {
  
  # test for when there are no errors in input
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example_flmd.csv", "readme_example.pdf", "example_dd.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", TRUE, "includes required files", "example_flmd.csv", ".*flmd\\.csv$", "all_file_names", "example_flmd.csv",
                       "required", TRUE, "includes required files", "example_dd.csv", ".*dd\\.csv$", "all_file_names", "example_dd.csv",
                       "required", TRUE, "includes required files", "readme_example.pdf", "(?i).*readme.*\\.pdf$", "all_file_names", "readme_example.pdf"))
  
  # test for when readme, flmd, and dd are missing
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example2.csv", "example3.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", FALSE, "includes required files", NA_character_, ".*flmd\\.csv$", "all_file_names", NA_character_,
                       "required", FALSE, "includes required files", NA_character_, ".*dd\\.csv$", "all_file_names", NA_character_,
                       "required", FALSE, "includes required files", NA_character_, "(?i).*readme.*\\.pdf$", "all_file_names", NA_character_))
  
  # test for when only flmd and dd are present
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example_flmd.csv", "example_dd.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", TRUE, "includes required files", "example_flmd.csv", ".*flmd\\.csv$", "all_file_names", "example_flmd.csv",
                       "required", TRUE, "includes required files", "example_dd.csv", ".*dd\\.csv$", "all_file_names", "example_dd.csv",
                       "required", FALSE, "includes required files", NA_character_, "(?i).*readme.*\\.pdf$", "all_file_names", NA_character_))
  
  # test for when readme file doesn't begin with "readme"
  expect_equal(check_for_required_file_strings(input = c("example.csv", "example_flmd.csv", "example_readme.pdf", "example_dd.csv"), required_file_strings = input_parameters$required_file_strings),
               tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                       "required", TRUE, "includes required files", "example_flmd.csv", ".*flmd\\.csv$", "all_file_names", "example_flmd.csv",
                       "required", TRUE, "includes required files", "example_dd.csv", ".*dd\\.csv$", "all_file_names", "example_dd.csv",
                       "required", TRUE, "includes required files", "example_readme.pdf", "(?i).*readme.*\\.pdf$", "all_file_names", "example_readme.pdf"))
  
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
  
  expect_equal(object = check_for_no_special_chrs(input = "example/directory-name/with-hyphens", 
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = initialize_checks_df(),
                                                  source = "directory_name",
                                                  file = "example.csv"),
               expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                  "strongly recommended", TRUE, "no special characters", "example/directory-name/with-hyphens", "none", "directory_name", "example.csv"))
  
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
               expected = tibble(requirement = "strongly recommended",
                                 pass_check = FALSE,
                                 assessment = "no special characters",
                                 input = "",
                                 value = "column_header is empty",
                                 source = "column_header",
                                 file = "example_filename.csv"))
  
  # test that empty column headers pass this check because they are evaluated in another (separate) check
  expect_equal(object = check_for_no_special_chrs(input = "EMPTY_COLUMN_HEADER",
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  source = "column_header", 
                                                  file = "example_filename.csv"),
               expected = tibble(requirement = "strongly recommended", 
                                 pass_check = TRUE, 
                                 assessment = "no special characters",
                                 input = "EMPTY_COLUMN_HEADER",
                                 value = "none",
                                 source = "column_header", 
                                 file = "example_filename.csv"))
  
  
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
  
  # test that empty column headers pass this check because they are evaluated in another (separate) check
  expect_equal(object = check_for_unique_names(input = "EMPTY_COLUMN_HEADER", 
                                               all_names = c("col", "col_chr", "col", "another_name", "another_col", "EMPTY_COLUMN_HEADER", "EMPTY_COLUMN_HEADER"),
                                               source = "column_header", 
                                               file = "example1.csv"),
               expected = tibble(requirement = factor(), 
                                 pass_check = logical(),
                                 assessment = factor(),
                                 input = character(),
                                 value = character(),
                                 source = character(),
                                 file = character()))
  
})

test_that("no empty column headers exist", {
  
  # test for when there are no empty column headers
  expect_equal(object = check_for_empty_column_headers(input = "col_header", 
                                                    data_checks_table = initialize_checks_df(),
                                                    source = "column_header", 
                                                    file = "example_filename.csv"),
              expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                            "strongly recommended", TRUE, "no empty column headers", "col_header", "col_header", "column_header", "example_filename.csv"))
  
  # test for when there is 1 empty column header
  expect_equal(object = check_for_empty_column_headers(input = "EMPTY_COLUMN_HEADER", 
                                                    data_checks_table = initialize_checks_df(),
                                                    source = "column_header", 
                                                    file = "example_filename.csv"),
              expected = tribble(~requirement, ~pass_check, ~assessment, ~input, ~value, ~source, ~file,
                                            "strongly recommended", FALSE, "no empty column headers", "EMPTY_COLUMN_HEADER", "EMPTY_COLUMN_HEADER", "column_header", "example_filename.csv"))
  
  
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


#### check_data_package() ####

test_that("check_data_package() checks", {
  
  # 2025-04-11 note from Bibi: I never wrote checks for the function
  # (check_data_package()) that combines all the "check_for_..." functions.
  # Leaving this space here to indicate that checks didn't exist, but
  # could/should be developed in the future if changes need to be made to that
  # function.

  
})