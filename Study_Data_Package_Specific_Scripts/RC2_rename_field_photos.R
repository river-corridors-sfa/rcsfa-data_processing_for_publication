# ==============================================================================
#
# Rename field photos based on date and site for Temporal Study (RC2)
#
# 
# Status: Complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 6 May 2025
#
# ==============================================================================

library(tidyverse)
library(tools)
library(magick)
library(rsvg)
library(fs)

# ================================= User inputs ================================

photo_dir <- 'Z:/RC2/03_Temporal_Study/05_Field_Photos'

out_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2022-2024_SensorData/RC2_TemporalStudy_2022-2024_FieldPhotos/'

study_code <- 'RC2'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, recursive = T, full.names = T)

file_list <- file_list[ !grepl('.db',file_list)]

file_list <- file_list[ !grepl('Archive',file_list)]
file_list <- file_list[ !grepl('Other',file_list)]
file_list <- file_list[ !grepl('Temp pictures',file_list)]
file_list <- file_list[ !grepl('.txt',file_list)]

for (i in file_list){
  
  date <- unlist(str_split(i, '/')) [5] %>%
    str_remove_all("-")
  
  site <- unlist(str_split(i, '/')) [6]
  
  extension <- file_ext(i)
  
  subfolder_files <- list.files(dirname(i), full.names = T)
  
  subfolder_count <- tibble(
    file = subfolder_files)%>%
    mutate(number = 1:n())
  
  subfolder <- dirname(i)
  
  number <- subfolder_count %>%
    filter(file %in% i) %>%
    pull(number) %>%
    as.numeric()

  out_file <- paste(out_dir,'/', study_code, '_', site,'_', date,'_EnvContext_', number,'.', extension , sep = '')
  
  
  if(extension == 'heic'|extension == 'HEIC'){
    
    photo_read <- magick::image_read(i)
    
    out_file <- out_file %>%
      str_replace(., '.heic', '.jpeg')%>%
      str_replace(., '.HEIC', '.jpeg')
    
    image_write(photo_read, out_file, format = 'jpeg')
    
  } else {
    
    file.copy(i, out_file)
    
  }
}



