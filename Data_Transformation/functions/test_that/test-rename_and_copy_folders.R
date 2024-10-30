### test-rename_and_copy_folders.R #############################################
# Date Created: 2024-10-29
# Date Updated: 2024-10-29
# Author: Bibi Powers-McCormack

# this script generates test data and then uses it to check the functionality of
# the rename_and_copy_folder.R function


### Prep script ################################################################

# load libraries
library(tidyverse)
library(devtools)
library(testthat)
library(rlog)

# source in function
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/create_rename_and_copy_folders_v1/Data_Transformation/functions/rename_and_copy_folders.R")

### Create testing data ########################################################

# create testing source data
temp_directory <- tempdir()
log_info(paste0("Opening temp directory: ", temp_directory))
shell.exec(temp_directory)

# create source sub folders
temp_source_folder <- paste0(temp_directory, "/source")
temp_destination_folder <- paste0(temp_directory, "/destination")


create_testing_data <- function() {
  
  if (dir.exists(temp_source_folder)) {
    # if source folder exists, remove it
    unlink(temp_source_folder, recursive = T)
  }
  
  if (dir.exists(temp_destination_folder)) {
    # if destination folder exists, remove it
    unlink(temp_destination_folder, recursive = T)
  }
  
  dir.create(temp_source_folder)
  
  # create source sample files in a nested format
  temp_sample_names <- c("A", "B", "C", "D")
  
  for (sample in temp_sample_names) {
    
    # create folder for each sample
    current_temp_folder <- paste0(temp_source_folder,"/Sample", sample)
    dir.create(file.path(current_temp_folder))
    
    # create files for each sample
    for (rep in 1:3) {
      
      current_temp_file_path <- paste0(current_temp_folder, "/sample", sample, "-", rep, ".csv")
      file.create(current_temp_file_path)
    } # end of loop to create files for each sample
  } # end of loop to create sample folders
  
  
} # end of function



### Run tests ##################################################################

test_that("1. files in the destination folder match the names of the files in the lookup df", {
  
  # create testing data
  create_testing_data()
  
  # create additional source files and folders
  dir.create(paste0(temp_source_folder, "/Sample123"))
  dir.create(paste0(temp_source_folder, "/Sample123456"))
  file.create(paste0(temp_source_folder, "/Sample123/SampleE.md"))
  
  # create testing input lookup df
  test_lookup <- tibble(source = c(paste0(temp_directory, "/source/SampleA"),
                                   paste0(temp_directory, "/source/SampleB"),
                                   paste0(temp_directory, "/source/SampleC"),
                                   paste0(temp_directory, "/source/SampleD"),
                                   paste0(temp_directory, "/source/Sample123")),
                        destination = c(paste0(temp_directory, "/destination/Sample1"),
                                        paste0(temp_directory, "/destination/Sample2"),
                                        paste0(temp_directory, "/destination/Sample3"),
                                        paste0(temp_directory, "/destination/Sample4"),
                                        paste0(temp_directory, "/destination/SampleABC")))
  test_lookup
  
  
  # run function
  function_output <- rename_and_copy_folders(test_lookup)
  
  # get output of function
  output <- list.dirs(paste0(temp_directory, "/destination"), full.names = T, recursive = T)[-1] # gets dirs and removes the first one (which is the parent dir)
  
  # test that function ran
  expect_equal(function_output, NULL)
  
  # test that the sub folders in the destination directory match the folder names listed in the lookup df
  expect_equal(output, test_lookup$destination)
  
  # test that destination file names still equal the source file names (making sure that the file names weren't renamed)
  expect_equal(sort(basename(list.files(paste0(temp_directory, "/destination"), recursive = T))), 
               sort(basename(list.files(paste0(temp_directory, "/source"), recursive = T))))
  
})


test_that("2. function errors when lookup df col headers are incorrect", {
  
  # create testing data
  create_testing_data()
  
  # create input
  test_lookup <- tibble(source = c(paste0(temp_directory, "/source/SampleA"),
                                   paste0(temp_directory, "/source/SampleB"),
                                   paste0(temp_directory, "/source/SampleC"),
                                   paste0(temp_directory, "/source/SampleD")),
                        output = c(paste0(temp_directory, "/destination/Sample1"),
                                        paste0(temp_directory, "/destination/Sample2"),
                                        paste0(temp_directory, "/destination/Sample3"),
                                        paste0(temp_directory, "/destination/Sample4")))
  
  # this is what the function should return
  expected_output <- "ERROR. Your lookup df does not include the correct column names. The input requires c(`source`, `destination`)."
  
  # run function and test that the sub folders in the destination directory match the folder names listed in the lookup df
  expect_error(rename_and_copy_folders(test_lookup), expected_output, fixed = T)
  
})


test_that("3. function handles extra columns in the input", {
  
  # create testing data
  create_testing_data()
  
  # create input
  test_lookup <- tibble(source = c(paste0(temp_directory, "/source/SampleA"),
                                   paste0(temp_directory, "/source/SampleB"),
                                   paste0(temp_directory, "/source/SampleC"),
                                   paste0(temp_directory, "/source/SampleD")),
                        destination = c(paste0(temp_directory, "/destination/Sample1"),
                                        paste0(temp_directory, "/destination/Sample2"),
                                        paste0(temp_directory, "/destination/Sample3"),
                                        paste0(temp_directory, "/destination/Sample4")),
                        notes = c("note1", "note2", "note3", "note4"))
  
  # this is what the function should return
  expected_output <- NULL
  
  # run function and test that the sub folders in the destination directory match the folder names listed in the lookup df
  expect_equal(rename_and_copy_folders(test_lookup), expected_output)
  
})


test_that("4. function copies only desired sub-folders when there are additional folders in the source", {
  
  # create testing data
  create_testing_data()
  
  # create additional source files and folders - mirror format of ICR files
  dir.create(paste0(temp_source_folder, "/SHIPDATE"))
  dir.create(paste0(temp_source_folder, "/CM_SSS_Renamed_Raw_Data"))
  dir.create(paste0(temp_source_folder, "/SHIPDATE/CM_001.d"))
  dir.create(paste0(temp_source_folder, "/SHIPDATE/PE_001.d"))
  file.create(paste0(temp_source_folder, "/SHIPDATE/CM_001.d/SampleE.md"))
  file.create(paste0(temp_source_folder, "/SHIPDATE/CM_001.d/SampleF.md"))
  file.create(paste0(temp_source_folder, "/SHIPDATE/PE_001.d/SampleG.md"))
  
  # create input
  test_lookup <- tibble(source = c(paste0(temp_directory, "/source/SHIPDATE/CM_001.d")),
                        destination = c(paste0(temp_directory, "/source/CM_SSS_Renamed_Raw_Data/Sample1.d")))
  
  # this is what the function should return
  expected_output <- NULL
  
  # run function and test that the only the folders in the lookup are copied over
  expect_equal(rename_and_copy_folders(test_lookup), expected_output)
  
  
})


test_that("5. function creates all destination directories, even if they don't already exist", {
  
  # create testing data
  create_testing_data()
  
  # create additional source data - (you have to create each dir and sub dir separately)
  dir.create(paste0(temp_source_folder, "/SHIPDATE"))
  dir.create(paste0(temp_source_folder, "/SHIPDATE/CM_00A.d"))
  file.create(paste0(temp_source_folder, "/SHIPDATE/CM_00A.d/SampleG.md"))
  dir.create(paste0(temp_source_folder, "/SHIPDATE/CM_00B.d"))
  file.create(paste0(temp_source_folder, "/SHIPDATE/CM_00B.d/SampleH.md"))
  
  # create destination folders
  # dir.create(paste0(temp_source_folder, "/CM_SSS_notcreated")) # not creating a dir where CM_001.d will be copied
  dir.create(paste0(temp_source_folder, "/CM_SSS_created")) # this creates a dir where CM_002.d will be copied
  
  # create input
  test_lookup <- tibble(source = c(paste0(temp_directory, "/source/SHIPDATE/CM_00A.d"),
                                   paste0(temp_directory, "/source/SHIPDATE/CM_00B.d")),
                        destination = c(paste0(temp_directory, "/source/CM_SSS_notcreated/Sample1.d"),
                                        paste0(temp_directory, "/source/CM_SSS_created/Sample2.d")))
  
  # this is what the function should return
  expected_output <- NULL
  
  # run function and test that directories are created if they don't already exist
  expect_equal(rename_and_copy_folders(test_lookup), expected_output)
  
  
})

test_that("6. function won't overwrite existing data in a destination folder if stuff already lives there", {
  
  # create testing data
  create_testing_data()
  
  # create destination folders
    # this example has A already in the destination and the function copies B
  dir.create(paste0(temp_destination_folder)) # this creates the destination folder
  dir.create(paste0(temp_destination_folder, "/CM_SSS")) # this creates a dir where SampleB will be copied
  dir.create(paste0(temp_destination_folder, "/CM_SSS/Sample1")) # this creates dir where A will already exist
  file.create(paste0(temp_destination_folder, "/CM_SSS/Sample1/sampleA-1.csv"),
              paste0(temp_destination_folder, "/CM_SSS/Sample1/sampleA-2.csv"),
              paste0(temp_destination_folder, "/CM_SSS/Sample1/sampleA-3.csv"))
  
  # create input
  test_lookup <- tibble(source = c(paste0(temp_directory, "/source/SampleB"),
                                   paste0(temp_directory, "/source/SampleD")),
                        destination = c(paste0(temp_directory, "/destination/CM_SSS/Sample2.d"),
                                        paste0(temp_directory, "/destination/CM_SSS/Sample4.d")))
  
  # this is what the function should return
  expected_output <- NULL
  
  # run function and test that if a destination already has files in it, this function won't delete them
  expect_equal(rename_and_copy_folders(test_lookup), expected_output)
  expect_equal(sort(basename(list.files(temp_destination_folder, recursive = T))), c("sampleA-1.csv", "sampleA-2.csv", "sampleA-3.csv", 
                                                                                     "sampleB-1.csv", "sampleB-2.csv", "sampleB-3.csv", 
                                                                                     "sampleD-1.csv", "sampleD-2.csv", "sampleD-3.csv"))
})
