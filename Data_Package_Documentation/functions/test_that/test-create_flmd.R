# test-create_flmd_skeleton_v2.R ###############################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-04-24
# Date Updated: 2025-05-08

# Objective

# Directions



### Prep Script ################################################################

rm(list=ls(all=T))

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
  expect_s3_class(create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F), "tbl_df")

  # returns a tibble that must include required cols
  result = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F)
  expect_true(all(c("File_Name", "File_Description", "Standard", "Header_Rows", "Column_or_Row_Name_Position", "File_Path") %in% names(result)))

  # returns a tibble that includes all files in dir
  expect_equal(object = create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F, add_placeholders = F) %>% select(File_Name, File_Path), 
               expected = tibble(File_Name = c("example_boye.csv", "example_goldman.csv", "file_a.csv", "file_b.csv", "01_script.R"),
                                 File_Path = c("/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/scripts")))

  # returns a tibble where the columns have the correct class
  result <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", query_header_info = F)
  
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
    # if no headers... then == 1 (index starts at the column header row, not the row the data start on)
    # if boye... then == 1
    # if goldman... then == 1
    # if other... then == user input (because read_csv is reading in without col names, the col names end up being on row 1)
  # expect_equal(object = create_flmd(),
  #              expected = )
  # 
})

### expected edge cases ########################################################


### expected warnings ##########################################################


### expected errors ############################################################




















### test-create_flmd.R #########################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-04-24
# Date Updated: 2025-04-29

# Objective

# Directions


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(rlog)
library(devtools) # for sourcing in functions
library(testthat) # for testing
library(fs) # for temp dir creation

# load functions
source("./Data_Package_Documentation/functions/create_flmd.R")

# create temporary testing directory
create_test_dir <- function(root = tempdir()) {
  # Create root data package directory
  base_dir <- file.path(root, "example_data_package")
  fs::dir_create(base_dir)
  
  # Create subdirectories
  fs::dir_create(file.path(base_dir, "data"))
  fs::dir_create(file.path(base_dir, "scripts"))
  
  # Create example files with optional content
  readr::write_lines("This is a PDF placeholder.", file.path(base_dir, "readme_example_data_package.pdf"))
  
  # Data file in data/
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(10, 20, 30)),
    file.path(base_dir, "data", "file_a.csv")
  )
  
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(40, 50, 60)),
    file.path(base_dir, "file_flmd.csv")
  )
  
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(70, 80, 90)),
    file.path(base_dir, "file_dd.csv")
  )
  
  # R script in scripts/
  readr::write_lines(
    c("# Example R script", "print('Hello world')"),
    file.path(base_dir, "scripts", "01_script.R")
  )
  
  return(base_dir)
}

# system(paste("open", shQuote(create_test_dir()))) # open on mac
# shell.exec(create_test_dir()) # open on windows


### tests for get_flmd_rows() ##################################################

# expected typical inputs
test_that("expected typical inputs", {
  
  data_package_dir <- create_test_dir()
  
  # get_flmd_rows() returns a tibble
  expect_s3_class(get_flmd_rows(directory = data_package_dir), "tbl_df")
  
  # get_flmd_rows() returns a tibble with 2 columns (File_Name and File_Path)
  expect_named(object = get_flmd_rows(directory = data_package_dir), 
              expected = c("File_Name", "File_Path"))
  
  # get_flmd_rows() returns a tibble that includes all files in dir
  expect_equal(object = get_flmd_rows(directory = data_package_dir), 
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "file_flmd.csv", "file_dd.csv", "file_a.csv", "01_script.R"),
                                 File_Path = c("/example_data_package", "/example_data_package", "/example_data_package", "/example_data_package/data", "/example_data_package/scripts")))

})
  
  # get_flmd_rows() returns a tibble that adds placeholders when placeholder_rows_to_add = c("readme", "flmd", "dd")
  # get_flmd_rows() uses the dp_keyword to name placeholders
  # get_flmd_rows() includes include files
  # get_flmd_rows() excludes exclude files
  
# expected edge cases
test_that("expected edge cases", {})
  # get_flmd_rows() includes . files when include_dot_files = T
  # get_flmd_rows() returns empty tibble if there are no files

# expected warnings
test_that("expected warnings", {})
  # get_flmd_rows() warns when removing excluded files
  # get_flmd_rows() warns if placeholder_rows_to_add input is not in controlled vocab

# expected errors
test_that("expected errors", {})
  # get_flmd_rows() errors if directory doesn't exist
  # get_flmd_rows() errors if required inputs (directory and dp_keyword) aren't provided



### tests for get_flmd_cols() ##################################################

# expected typical inputs
test_that("expected typical inputs", {
  
  data_package_dir <- create_test_dir()
  flmd <- get_flmd_rows(data_package_dir)
  
  # get_flmd_cols() returns a tibble where nrow() == nrow(flmd_base)
  expect_equal(object = get_flmd_cols(flmd_base = flmd) %>% nrow(),
               expected = flmd %>% nrow())
  
  # get_flmd_cols() returns a tibble where ncol() = cols_to_add + 2
  expect_equal(object = get_flmd_cols(flmd_base = flmd, cols_to_add = my_flmd_cols) %>% ncol(), 
               expected = length(my_flmd_cols) + 2)
  
  # get_flmd_cols() returns a tibble that must include columns File_Name and File_Path
  result = get_flmd_cols(flmd_base = flmd, cols_to_add = my_flmd_cols)
  expect_true(all(c("File_Name", "File_Path") %in% names(result)))
  
  # get_flmd_cols() returns a tibble where the new columns have the correct class
  result <- get_flmd_cols(flmd_base = flmd, cols_to_add = my_flmd_cols)
  
  expect_equal(object = class(result$File_Name), 
               expected = "character")
  expect_equal(object = class(result$Definition), 
               expected = "character")
  expect_equal(object = class(result$Standard), 
               expected = "character")
  expect_equal(object = class(result$Missing_Value_Codes), 
               expected = "character")
  expect_equal(object = class(result$Header_Rows), 
               expected = "numeric")
  expect_equal(object = class(result$Column_or_Row_Name_Position), 
               expected = "numeric")
  expect_equal(object = class(result$File_Path), 
               expected = "character")
})


# expected edge cases
test_that("expected edge cases", {})
  # Returns a tibble when a subset of the required columns names are included

  # Returns the unchanged input tibble if no columns are specified

# expected warnings
test_that("expected warnings", {})
  # If the cols_to_add input vector is not part of the controlled vocab, then warn the user that the column will not be added

  # If the input vector does not include all default cols, then warn the user that some of the required columns will noto be included

# expected errors
test_that("expected errors", {})
  # If the flmd_base input vector does not include the columns File_Name and File_Path, then error and terminate the script


### tests for get_flmd_cells() ##################################################

# expected typical inputs
test_that("expected typical inputs", {
  
  data_package_dir <- create_test_dir()
  my_flmd_base <- get_flmd_rows(data_package_dir)
  my_flmd <- get_flmd_cols(flmd_base = my_flmd_base)
  my_flmd_cols <- c("Definition", "Standard", "Missing_Value_Codes", "Header_Rows", "Column_or_Row_Name_Position")
  
  # If the input vector cols_to_populate includes "Standard"..., 
  # ... then populate the Standard column with "ESS-DIVE CSV v1" if the File_Name file extension is ".csv" or ".tsv"
  # ... then populate the Standard column with "ESS-DIVE FLMD v1; ESS-DIVE CSV v1" if the File_Name ends with "*flmd.csv" or "*dd.csv"
  # ... then populate the Standard column with "N/A" if the file extension is not ".csv" or ".tsv"
  
  expect_equal(object = get_flmd_cells(flmd_base = my_flmd, cols_to_populate = my_flmd_cols) %>% select(File_Name, Standard),
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "file_flmd.csv", "file_dd.csv", "file_a.csv", "01_script.R"),
                                 Standard = c("N/A", "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", "ESS-DIVE CSV v1", "N/A")))
  
  # If the input vector cols_to_populate includes "Misisng_Value_Codes"..., 
  # ... then populate the Missing_Value_Codes column  with '"-9999"; "N/A"; "": NA"' if the File_Name file extension is ".csv" or ".tsv
  # ... then populate the Missing-Value_Codes column with "N/A" if the file extension is not ".csv" or ".tsv"
  
  expect_equal(object = get_flmd_cells(flmd_base = my_flmd, cols_to_populate = my_flmd_cols) %>% select(File_Name, Missing_Value_Codes),
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "file_flmd.csv", "file_dd.csv", "file_a.csv", "01_script.R"),
                                 Missing_Value_Codes = c("N/A", '"-9999"; "N/A"; "": NA"', '"-9999"; "N/A"; "": NA"', '"-9999"; "N/A"; "": NA"', "N/A")))
  
})



  # For Column_or_Row_Position...
  # For Header_Rows...

# expected edge cases
test_that("expected edge cases", {})
  # Returns the unchanged input tibble if no columns are specified

# expected warnings
test_that("expected warnings", {})
  # If a column from cols_to_populate isn't in flmd_base, then warn the user that the column is missing from the DF and won't be populated
  # If tabular files are present, then warn the user that the Boye and Goldman standards (if applicable) need to be manually added to the flmd

# expected errors
test_that("expected errors", {})




