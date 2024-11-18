### CM_SSS_rename_and_copy_raw_FTICR_folders.R #################################
# Date Created: 2024-10-29
# Date Updated: 2024-11-18
# Author: Bibi Powers-McCormack

# Objective: 
  # use the CM and SSS mapping files to create rename and move .d folders

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
  filter(!str_detect(file_path, "2020-Usethis\\.m")) 

print(filtered_xml_file_names) # all files look good and ready for next step


### Prepare to make lookup file ################################################
# removes samples where `Accumulation_Time` is NA
# removes samples where "OMIT" is included in the Notes column
# convert ion accumulation time to have "p" replace the decimal point
# use the analyte code to determine the sub folder (ICR = water; SED = sediment)

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

# read in mapping files
source_mapping_file_cm <- read_csv("C:/Users/powe419/OneDrive - PNNL/Documents - Core Richland and Sequim Lab-Field Team/Data Generation and Files/RC4/FTICR/03_ProcessedData/CM_Data_Processed_FTICR/CM_Mapping.csv")

source_mapping_file_sss <- read_csv("C:/Users/powe419/OneDrive - PNNL/Documents - Core Richland and Sequim Lab-Field Team/Data Generation and Files/RC2/FTICR/03_ProcessedData/SSS_Data_Processed_FTICR/SSS_Mapping.csv")


# clean mapping files
mapping_file_cm <- source_mapping_file_cm %>% 
# drop rows that say OMIT in the Notes column and those that are missing an ion accumulation time
  filter(!is.na(Accumulation_Time)) %>% 
  filter(is.na(Notes) | !str_detect(Notes, "\\bOMIT\\b")) %>% 
  
  # convert IAT to IAT_p
  rowwise() %>% 
  mutate(iat_p = convert_IAT(Accumulation_Time)) %>% 
  ungroup() %>% 
  
  # identify sub folder based on analyte code
  mutate(analyte_subdir = case_when(str_detect(Sample_ID, "ICR") ~ "Water",
                                    str_detect(Sample_ID, "SED") ~ "Sediment")) %>% 
  
  # select needed cols
  select(Randomized_ID, Sample_ID, iat_p, analyte_subdir)
  

mapping_file_sss <- source_mapping_file_sss %>%
  # drop rows that say OMIT in the Notes column and those that are missing an ion accumulation time
  filter(!is.na(Accumulation_Time)) %>% 
  filter(is.na(Notes) | !str_detect(Notes, "\\bOMIT\\b")) %>% 
  
  # convert IAT to IAT_p
  rowwise() %>% 
  mutate(iat_p = convert_IAT(Accumulation_Time)) %>% 
  ungroup() %>% 
  
  # identify sub folder based on analyte code
  mutate(analyte_subdir = case_when(str_detect(Sample_ID, "ICR") ~ "Water",
                                    str_detect(Sample_ID, "SED") ~ "Sediment")) %>% 
  
  # select needed cols
  select(Randomized_ID, Sample_ID, iat_p, analyte_subdir)


# combine into single file
mapping_file <- mapping_file_cm %>% 
  add_row(mapping_file_sss) %>% 
  arrange(Sample_ID) %>% 
  mutate(out_dir_relative = paste0(analyte_subdir, "_FTICR_Raw_Data/", Sample_ID, "_", iat_p, ".d"),
         randomized_id_dot_d = paste0(Randomized_ID, ".d"))


### Create lookup df from mapping file #########################################
# use the combined mapping file as the base for the lookup df

# create directories
in_dir <- "Z:/Large_File_Storage_For_Raw_Instrument_Data/UA FTICR Bruker SolariX 9T"
out_dir <- "Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/CM_SSS_FTICR_Raw_Data"

# list all folders
source_dirs <- list.dirs(in_dir, recursive = F, full.names = T) %>% # get all parent folders
  .[str_detect(., "CM|SSS")] %>%  # filter for parent (SHIP) files that have CM or SSS in them
  list.dirs(., recursive = F) %>% # get all sub folders from those parent dirs
  str_subset(., "/CM_|/SSS_")  # filter those for CM or SSS

# convert folders into df
source_dirs_df <- tibble(source = source_dirs) %>% 
  mutate(source_folder = basename(source))


# show the files that we have a .d folder for but is not included in the filtered mapping files
source_dirs_df %>% 
  anti_join(mapping_file, by = join_by(source_folder == randomized_id_dot_d)) # I checked these against the original mapping file. CM_R54, CM_R82, CM_S120, CM_S123, and CM_S_136 are all okay to be omitted.

# show the files that are in the mapping file but we don't have a folder
mapping_file %>% 
  anti_join(source_dirs_df, by = join_by(randomized_id_dot_d == source_folder)) # none
  

# create look up df 
CM_SSS_lookup_df <- mapping_file %>% # uses mapping file as source of truth for which files to move
  
  # join mapping file
  left_join(source_dirs_df, by = join_by(randomized_id_dot_d == source_folder)) %>% 

  # create destination col
  rowwise() %>% 
  mutate(destination = paste0(out_dir, "/", out_dir_relative)) 
  

# check counts
test_that("CM has 113 samples (3 reps each for water and for sediment)", {
 
  # filter lookup to only include CM samples
  cm_filter <- CM_SSS_lookup_df %>% 
    filter(str_detect(Sample_ID, "CM_"))
  
  expect_equal((113*3*2), nrow(cm_filter) + 9) 
  
  # 9 (parent ids) known missing: 
    # CM_025_SED-1
    # CM_025_SED-2
    # CM_025_SED-3
    # CM_026_SED-1
    # CM_026_SED-2
    # CM_026_SED-3
    # CM_029_SED-1
    # CM_029_SED-2
    # CM_029_SED-3
    # CM_030_SED-1
    # CM_030_SED-2
    # CM_030_SED-3
    # CM_070_SED-3
    # CM_006_ICR-1
    # CM_033_ICR-3
    # CM_080_ICR-3
    # CM_085_ICR-1
    # CM_085_ICR-2
    # CM_085_ICR-3
  
})

test_that("SSS has 48 samples (3 reps each for water and for sediment)", {
  
  # filter lookup to only include SSS samples
  sss_filter <- CM_SSS_lookup_df %>% 
    filter(str_detect(Sample_ID, "SSS"))
  
  expect_equal((48*3*2), nrow(sss_filter) + 1) 
  
  # 1 known missing: SSS038_SED-1
  
  
})


# clean up 
CM_SSS_lookup_df <- CM_SSS_lookup_df %>% 
  select(source, destination)


### Run function ###############################################################

rename_and_copy_folders(CM_SSS_lookup_df)