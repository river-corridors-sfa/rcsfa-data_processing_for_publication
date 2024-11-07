### CM_SSS_rename_and_copy_raw_FTICR_folders.R #################################
# Date Created: 2024-10-29
# Date Updated: 2024-11-06
# Author: Bibi Powers-McCormack

# Objective: 

# Assumptions: 
  # this only copies CM and SSS files
  # original files are left unaltered


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(devtools)
library(testthat)

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_and_copy_folders.R")


### Confirm files are ready to be moved ########################################
# all .xml files that aren't in a "2020-Usethis.md" subfolder should be removed

# see if there are any .xml files present
directory <- "Z:/Large_File_Storage_For_Raw_Instrument_Data/UA FTICR Bruker SolariX 9T"

xml_file_names <- list.files(directory, pattern = "\\.xml$", recursive = T, full.names = T) %>% 
  tibble(file_path = .)  # yes, 1750 xmls present

# filter out entries that contain "2020-Usethis.m" in the path
filtered_xml_file_names <- xml_file_names %>% # all of them are within 2020-Usethis.m folders, this result should be zero
  filter(!str_detect(file_path, "2020-Usethis\\.m")) # all files look good and ready for next step


### Prepare to make lookup file ################################################

# function to rename ion accumulation times
convert_IAT <- function(IAT) {
  
  # objective: take an ion accumulation time and replace the decimal point with a "p" (for "point")
  # inputs: single numeric vector
  # outputs: single character vector that replaces the decimal with "p"
  
  # convert IAT to number
  IAT <- as.numeric(IAT)
  
  # split into 2 parts, separated by decimal
  before_p <- str_extract(IAT, "^\\d+")
    
  after_p <- str_extract(IAT, "(?<=\\.)\\d+")
  
  # if either are NA, convert to ""
  if (is.na(before_p)) {
    before_p <- ""
  }
  
  if (is.na(after_p)) {
    after_p <- ""
  }
  
  # if not a whole number, don't include anything before the p
  if (before_p == 0){
    before_p <- ""
  }
  
  # put new string together
  
  IAT_p <- paste0(before_p, "p", after_p)
  
  return(IAT_p)
  
}

test_that("IAT converts to 'p' correctly", {
  
  expect_equal(convert_IAT(0.01), "p01")
  expect_equal(convert_IAT(1.00), "1p")
  expect_equal(convert_IAT(0.45), "p45")
  expect_equal(convert_IAT(2.50), "2p5")
  expect_equal(convert_IAT(.3), "p3")

})

# read in mapping file


# convert IAT to IAT_p


# select needed cols (sample name, randomized id, IAT_p)


### Create lookup df from mapping file #########################################
# use the combined mapping file as the base for the lookup df

# create directories
in_dir <- "Z:/Large_File_Storage_For_Raw_Instrument_Data/UA FTICR Bruker SolariX 9T"
out_dir <- "Z:/Large_File_Storage_For_Raw_Instrument_Data/UA FTICR Bruker SolariX 9T/CM_SSS_Renamed_Raw_Data"

# list all folders
source_dirs <- list.dirs(in_dir, recursive = F, full.names = T) %>% # get all parent folders
  .[str_detect(., "CM|SSS")] %>%  # filter for parent (SHIP) files that have CM or SSS in them
  list.dirs(., recursive = F) %>% # get all sub folders from those parent dirs
  .[str_detect(., "CM|SSS")]  # filter those for CM or SSS


CM_SSS_lookup_df <- tibble(source = source_dirs) %>% 
  
  # get sample name from folder
  mutate(source_folder = basename(source))

  # join mapping file

  # create destination col


### Run function ###############################################################

rename_and_copy_folders(CM_SSS_lookup_df)