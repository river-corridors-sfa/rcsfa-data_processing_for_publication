### CM_SSS_rename_and_copy_raw_FTICR_folders.R #################################
# Date Created: 2024-10-29
# Date Updated: 2024-10-30
# Author: Bibi Powers-McCormack

# Objective: 

# Assumptions: 
  # this only copies CM and SSS files
  # original files are left unaltered


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(devtools)

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/create_rename_and_copy_folders_v1/Data_Transformation/functions/rename_and_copy_folders.R")


### Confirm files are ready to be moved ########################################

# see if there are any .xml files present
directory <- "Z:/Large_File_Storage_For_Raw_Instrument_Data/UA FTICR Bruker SolariX 9T"

xml_file_names <- list.files(directory, pattern = "\\.xml$", recursive = T, full.names = T) %>% 
  tibble(file_path = .)

# filter out entries that contain "2020-Usethis.m" in the path
filtered_xml_file_names <- xml_file_names %>%
  filter(!str_detect(file_path, "2020-Usethis\\.m"))



### Create lookup df from mapping file #########################################
# use the combined mapping file as the base for the lookup df


CM_SSS_lookup_df






### Run function ###############################################################

rename_and_copy_folders(CM_SSS_lookup_df)