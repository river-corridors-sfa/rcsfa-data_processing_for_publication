### CM_SSS_rename_and_copy_raw_FTICR_folders.R #################################
# Date Created: 2024-10-29
# Date Updated: 2024-11-19
# Author: Bibi Powers-McCormack

# Objective: 
  # use the CM and SSS mapping files to create rename and move .d folders

# Assumptions: 
  # this only copies CM and SSS files
  # original files are left unaltered
  # removes samples where `Accumulation_Time` is NA
  # removes samples where "OMIT" is included in the Notes column
  # convert ion accumulation time to have "p" replace the decimal point
  # uses the analyte code to determine the sub folder (ICR = water; SED = sediment)
  # use the combined mapping file as the base for the lookup df
  # confirms that all samples that will be moved match the boye file in the data packages


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
# uses the analyte code to determine the sub folder (ICR = water; SED = sediment)

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
# drop rows that say OMIT in the Notes column and those that are missing an ion accumulation time and those that have "Blk" in their sample name
  filter(!is.na(Accumulation_Time)) %>% 
  filter(is.na(Notes) | !str_detect(Notes, "\\bOMIT\\b")) %>% 
  filter(!str_detect(Sample_ID, "Blk")) %>% 
  
  # convert IAT to IAT_p
  rowwise() %>% 
  mutate(iat_p = convert_IAT(Accumulation_Time)) %>% 
  ungroup() %>% 
  
  # identify sub folder based on analyte code
  mutate(analyte_subdir = case_when(str_detect(Sample_ID, "ICR") ~ "Water",
                                    str_detect(Sample_ID, "SED") ~ "Sediment")) %>% 
  
  # select needed cols
  select(Randomized_ID, Sample_ID, iat_p, analyte_subdir)

# print the files that were removed
source_mapping_file_cm %>% 
  filter(is.na(Accumulation_Time)) %>% 
  filter(is.na(Notes) | !str_detect(Notes, "\\bOMIT\\b"))
  

mapping_file_sss <- source_mapping_file_sss %>%
  # drop rows that say OMIT in the Notes column and those that are missing an ion accumulation time and those that have "Blk" in their sample name
  filter(!is.na(Accumulation_Time)) %>% 
  filter(is.na(Notes) | !str_detect(Notes, "\\bOMIT\\b")) %>% 
  filter(!str_detect(Sample_ID, "Blk")) %>% 
  
  # convert IAT to IAT_p
  rowwise() %>% 
  mutate(iat_p = convert_IAT(Accumulation_Time)) %>% 
  ungroup() %>% 
  
  # identify sub folder based on analyte code
  mutate(analyte_subdir = case_when(str_detect(Sample_ID, "ICR") ~ "Water",
                                    str_detect(Sample_ID, "SED") ~ "Sediment")) %>% 
  
  # select needed cols
  select(Randomized_ID, Sample_ID, iat_p, analyte_subdir)

# print the files that were removed
source_mapping_file_sss %>% 
  filter(is.na(Accumulation_Time)) %>% 
  filter(is.na(Notes) | !str_detect(Notes, "\\bOMIT\\b"))


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
  anti_join(mapping_file, by = join_by(source_folder == randomized_id_dot_d)) 
# I checked these against the original mapping files. The following are okay to be omitted: 
  # CM_O1 - BLK
  # CM_O98 - BLK
  # CM_P1 - BLK
  # CM_P98 - BLK
  # CM_Q01 - BLK
  # CM_Q98 - BLK
  # CM_R54 - omit
  # CM_R82 - omit
  # CM_R98 - BLK
  # CM_S120_RR - omit
  # CM_S123_RR - omit
  # CM_S135_RR - BLK
  # CM_S136_RR - omit
  # CM_S138_RR - BLK

# show the files that are in the filtered mapping file but we don't have a folder
mapping_file %>% 
  anti_join(source_dirs_df, by = join_by(randomized_id_dot_d == source_folder)) # none
  

# create look up df 
CM_SSS_lookup_df <- mapping_file %>% # uses mapping file as source of truth for which files to move
  
  # join mapping file
  left_join(source_dirs_df, by = join_by(randomized_id_dot_d == source_folder)) %>% 

  # create destination col
  rowwise() %>% 
  mutate(destination = paste0(out_dir, "/", out_dir_relative)) %>% 
  
  # pull out sample_id info
  separate(., Sample_ID, into = c("sample", "rep"), sep = "-", remove = F) %>% 
  separate(., sample, into = c("parent_id", "analyte"), sep = 6, remove = T) %>% 
  mutate(analyte = str_replace(analyte, "_", "")) %>% 
  separate(., parent_id, into = c("study_code", "parent_id_id"), sep = 3, remove = F) %>% 
  mutate(study_code = str_replace(study_code, "_", "")) %>% 
  select(-parent_id_id)


# confirms that all samples that will be moved match the boye file in the data packages
test_that("All sediment samples are present", {
  
  # read in boye sediment file - this is the source of truth for which samples we should have
  boye <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/CM_SSS_Sediment_FTICR_Methods.csv", skip = 2, na = c("N/A", "-9999")) %>%
    filter(!is.na(Sample_Name)) %>%
    filter(Sample_Name != "") %>% 
    filter(!is.na(`FTICR-MS`)) %>% 
    arrange(Sample_Name)
  
  # filter lookup to only include sediment samples
  sed_filter <- CM_SSS_lookup_df %>%
    filter(str_detect(Sample_ID, "SED")) %>% 
    arrange(Sample_ID)
  
  # compares the boye sample names with those in the lookup 
  expect_equal(boye$Sample_Name, sed_filter$Sample_ID)
  
  # join look up to boye to look if there are issues
  boye_lookup_join <- boye %>% 
    left_join(CM_SSS_lookup_df, by = join_by(Sample_Name == Sample_ID))

})

test_that("All water samples are present", {
  
  # read in boye water file - this is the source of truth for which samples we should have
  boye <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/CM_SSS_Water_FTICR_Methods.csv", skip = 2, na = c("N/A", "-9999")) %>%
    filter(!is.na(Sample_Name)) %>%
    filter(Sample_Name != "") %>% 
    filter(!is.na(`FTICR-MS`)) %>% 
    arrange(Sample_Name)
  
  # filter lookup to only include sediment samples
  water_filter <- CM_SSS_lookup_df %>%
    filter(str_detect(Sample_ID, "ICR")) %>% 
    arrange(Sample_ID)
  
  # compares the boye sample names with those in the lookup
  expect_equal(boye$Sample_Name, water_filter$Sample_ID)
  
  # join look up to boye to look if there are issues
  boye_lookup_join <- boye %>% 
    left_join(CM_SSS_lookup_df, by = join_by(Sample_Name == Sample_ID))
  
})
  

# clean up 
CM_SSS_lookup_df <- CM_SSS_lookup_df %>% 
  select(source, destination)


### Run function ###############################################################

rename_and_copy_folders(CM_SSS_lookup_df)


### Test that it ran correctly #################################################

test_that("folders were correctly copied and renamed", {
  
  # uses the FTICR file names as the source of truth for checking
  
  raw_water_files <- list.files('Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/CM_SSS_FTICR_Raw_Data/Water_FTICR_Raw_Data') %>%
    tibble() %>%
    mutate(across(where(is.character), ~ gsub("\\.d", "", .))) %>% 
    pull(.) %>% 
    sort()
  
  raw_sed_files <- list.files('Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/CM_SSS_FTICR_Raw_Data/Sediment_FTICR_Raw_Data') %>%
    tibble() %>%
    mutate(across(where(is.character), ~ gsub("\\.d", "", .))) %>% 
    pull(.) %>% 
    sort()
  
  xml_water_files <-  list.files('Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/Water_FTICR_Data') %>%
    tibble()%>%
    mutate(across(where(is.character), ~ gsub("\\.xml", "", .))) %>% 
    pull(.) %>% 
    sort()
  
  xml_sed_files <- list.files('Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/Sediment_FTICR_Data') %>%
    tibble() %>%
    mutate(across(where(is.character), ~ gsub("\\.xml", "", .))) %>% 
    pull(.) %>% 
    sort()
  
  expect_equal(xml_water_files, raw_water_files)
  expect_equal(xml_sed_files, raw_sed_files)

  # if they don't return zero, then you can use this to see what's different  
  water_diff <- setdiff(xml_water_files, raw_water_files) # should return 0 if passes check
  sed_diff <- setdiff(xml_sed_files, raw_sed_files) # should return 0 if passes check
  
})
