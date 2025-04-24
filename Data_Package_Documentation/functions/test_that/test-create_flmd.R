### test-create_flmd.R #########################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-04-24
# Date Updated: 2025-04-24

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
source("./Data_Package_Documentation/functions/create_flmd.R.R")

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
    file.path(base_dir, "data", "file_b.csv")
  )
  
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(70, 80, 90)),
    file.path(base_dir, "data", "file_c.csv")
  )
  
  # R script in scripts/
  readr::write_lines(
    c("# Example R script", "print('Hello world')"),
    file.path(base_dir, "scripts", "01_script.R")
  )
  
  return(base_dir)
}

system(paste("open", shQuote(create_test_dir()))) # open on mac
shell.exec(create_test_dir()) # open on windows


### tests for get_flmd_rows() ##################################################

# expected typical inputs
test_that("expected typical inputs", {
  
  # get_flmd_rows() returns a tibble
  expect_s3_class(get_flmd_rows(directory = data_package_dir), "tbl_df")
  
  # get_flmd_rows() returns a tibble with 2 columns (File_Name and File_Path)
  expect_named(object = get_flmd_rows(directory = data_package_dir), 
              expected = c("File_Name", "File_Path"))
  
  # get_flmd_rows() returns a tibble that includes all files in dir
  expect_equal(object = get_flmd_rows(directory = data_package_dir), 
               expected = tibble(File_Name = c("readme_example_data_package.pdf", "file_a.csv", "file_b.csv", "file_c.csv", "01_script.R"),
                                 File_Path = c("/example_data_package", "/example_data_package/data", "/example_data_package/data", "/example_data_package/data", "/example_data_package/scripts")))

})
  
  # get_flmd_rows() returns a tibble that adds placeholders when placeholder_rows_to_add = T
  # get_flmd_rows() uses the dp_keyword to name placeholders
  # get_flmd_rows() includes include files
  # get_flmd_rows() excludes exclude files
  # get_flmd_rows() excludes exclude files
  
    
  # directory
  data_package_dir <- create_test_dir()
  
  # this is what the function should return
  
  # run function
  expect_equal(object = get_flmd_rows(directory = data_package_dir), 
               expected = expected_output)
  


# expected edge cases
  # returns empty tibble if there are no files

# expected warnings
  # warns when removing excluded files

# expected errors
  # errors if directory doesn't exist
  # errors if required files (directory and dp_keyword) aren't provided








