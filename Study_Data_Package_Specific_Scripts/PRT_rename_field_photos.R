# ==============================================================================
#
# Rename PRT field photos
# 
# Status: complete
# 
# Note: renamed all env context photos/videos through Nov trip
# v2: nov-june 2026
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 22 Dec 2025 (updated for v2 on 24 July 2026)
#
# ==============================================================================

library(tidyverse)
library(av)
library(tools)

rm(list=ls(all=T))

# ================================= User inputs ================================

photo_dir <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/03_FieldPhotos/Environmental_Context_Photos'

outdir <- 'Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Field_Photos'

cutoff_date <- '2025-11-21'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, full.names = T, recursive = T)

file_names <- tibble(input = file_list) %>%
  mutate(ext = file_ext(input),
         site = str_extract(input, "[A-Z]+\\d+[A-Z]*"),
         date = str_extract(input, "\\d{4}-\\d{2}-\\d{2}")) %>%
  filter(date > ymd(cutoff_date)) %>%
  group_by(site, date) %>%
  mutate(replicate = row_number()) %>%
  ungroup() %>%
  mutate(output_ext = case_when(
    tolower(ext) %in% c("m4v", "mov", "mp4") ~ "mp4",
    TRUE ~ ext
  ),
  output = paste0(outdir, '/PRT_', site, '_', date, '_EnvContext-',
                  replicate, '.', output_ext))


for (i in 1:nrow(file_names)){

  input_file <- file_names %>%
    slice(i) %>%
    pull(input)
 
  new_name <- file_names %>%
   filter(input == input_file ) %>%
   pull(output)

  
  if(str_detect(input_file, 'm4V|MOV')){
    
    av_video_convert(input_file, new_name) 
    
  } else{
    
    
    file.copy(input_file, new_name)
  }

}



