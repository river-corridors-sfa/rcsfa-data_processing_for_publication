# ==============================================================================
#
# Rename PRT field photos
# 
# Status: In progress
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 22 Dec 2025
#
# ==============================================================================

library(tidyverse)
library(av)
library(tools)

rm(list=ls(all=T))

# ================================= User inputs ================================

photo_dir <- 'C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Study_PRT/03_FieldPhotos/Environmental_Context_Photos'

outdir <- 'Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package/PRT_Field_Photos'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, full.names = T, recursive = T)

file_names <- tibble(input = file_list) %>%
  mutate(ext = file_ext(input),
         site = str_extract(input, "[A-Z]+\\d+[A-Z]*"),
         date = str_extract(input, "\\d{4}-\\d{2}-\\d{2}")) %>%
  group_by(site, date) %>%
  mutate(replicate = row_number()) %>%
  ungroup() %>%
  mutate(output_ext = case_when(
    tolower(ext) %in% c("m4v", "mov", "mp4") ~ "mp4",
    TRUE ~ ext
  ),
  output = paste0(outdir, '/PRT_', site, '_', date, '_EnvContext-',
                  replicate, '.', output_ext))


for (i in file_list){

  
 new_name <- file_names %>%
   filter(input == i ) %>%
   pull(output)

  
  if(str_detect(i, 'm4V|MOV')){
    
    av_video_convert(i, new_name) 
    
  } else{
    
    
    file.copy(i, new_name)
  }

}



