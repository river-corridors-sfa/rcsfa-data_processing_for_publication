# ==============================================================================
#
# Rename minikit field photos
#
# 
# Status: Complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 21 August 2025
#
# ==============================================================================

library(tidyverse)
library(magick)

# ================================= User inputs ================================

photo_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_Minikits/WHONDRS_Minikits_Site_Environmental_Photos'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, full.names = T)
file_list <- file_list[ !grepl('.db',file_list)]
file_list <- file_list[ !grepl('Not renamed',file_list)]

file_names <- tibble(file_name = basename(file_list)) %>%
  mutate(new_name = str_replace_all(file_name, c(
    "(?i)Sample " = "S000",
    "(?i) - across" = "-across",
    "(?i) - data" = "-data",
    "-Data" = "-data",
    "(?i) - down" = "-down",
    "-Down" = "-down",
    "(?i) - up" = "-up",
    "-Up" = "-up",
    "-upstream" = "-up",
    "(?i) - sed" = "-sed",
    "(?i) - pH" = "-ph",
    "-pH" = "-ph",
    "-17" = "17",
    "-19" = "19",
    "-sediment" = "-sed",
    "-Sediment" = "-sed",
    "-sed 2" = "-sed2"
  ))) %>%
  mutate(new_name = str_replace(new_name, " - .*(?=\\.[^.]+$)", ""),
         new_name = case_when(new_name == 'S000145-sed .jpg' ~ 'S000145-sed.jpg',
                              TRUE ~ new_name))



for (i in file_list){
  
 new_name <- file_names %>%
   filter(file_name == basename(i)) %>%
   pull(new_name)
  
  out_file <- paste0(photo_dir,'/Renamed','/', new_name)
  
  file.rename(i, out_file)

}



