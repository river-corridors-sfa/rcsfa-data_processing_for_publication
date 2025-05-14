# test-create_dd.R #############################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-02
# Date Updated: 2025-05-13

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
  my_flmd <- create_flmd(directory = my_data_package_dir, dp_keyword = "example_data_package", query_header_info = F)
  
  # returns a tibble
  expect_s3_class(create_dd(files_df = my_files, flmd_df = my_flmd), "tbl_df")
  
  # returns a tibble that must include required cols
  result = create_dd(files_df = my_files, flmd = my_flmd)
  expect_true(all(c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Missing_Value_Code") %in% names(result)))

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
  expect_equal(object = class(result$Missing_Value_Code),
               expected = "character")

  # returns a tibble that adds placeholders when add_boye_headers = T and add_flmd_dd_headers = T
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = T, add_flmd_dd_headers = T, include_filenames = T) %>% filter(str_detect(associated_files, "\\bboye template\\b|\\bflmd template\\b|\\bdd template\\b")) %>% select(Column_or_Row_Name),
               expected = tibble(Column_or_Row_Name = c("Analysis_DetectionLimit", "Analysis_Precision", "Column_or_Row_Name", "Column_or_Row_Name_Position", "Data_Status", "Data_Type", "Definition", "File_Description", "File_Name", "File_Path", "Header_Rows", "MethodID_Analysis", "MethodID_DataProcessing", "MethodID_Inspection", "MethodID_Preparation", "MethodID_Preservation", "MethodID_Storage", "Missing_Value_Code", "Standard", "Unit", "Unit_Basis")))

  # populates Missing_Value_Code column  with '"-9999"; "N/A"; "": NA"'
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = T) %>% select(Missing_Value_Code) %>% unique() %>% pull(),
               expected = '"N/A"; "-9999"; ""; "NA"')

  # returns a tibble with all column headers
  expect_equal(object = create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = F) %>% select(Column_or_Row_Name),
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


### expected warnings ##########################################################


### expected errors ############################################################








my_data_package_dir

test_file <- "/private/var/folders/d6/4f4_84915p70pj00fr84zdz40000gn/T/RtmpxNK92W/example_data_package/data/file_c.csv"
test_file <- "/private/var/folders/d6/4f4_84915p70pj00fr84zdz40000gn/T/RtmpxNK92W/example_data_package/data/example_boye.csv"
test_Column_or_Row_Name_Position <- 1
read_csv(test_file, col_names = F, comment = "#", n_max = test_Column_or_Row_Name_Position) %>% 
  slice(test_Column_or_Row_Name_Position) %>% 
  pivot_longer(everything(), values_to = "Column_or_Row_Name") %>% 
  select(Column_or_Row_Name)



  
  
read_lines(test_file) %>% 
  pull(1)


line <- read_lines(test_file, skip_empty_rows = FALSE)[test_Column_or_Row_Name_Position]
strsplit(line, ",")[[1]] %>% tibble(cols = .)






































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




