# ==============================================================================
#
# Rename field photos based on date and site for Second Spatial Study (SSS)
#
# 
# Status: In Progress. If an archive folder is created, need to update the code to skip archive pictures
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 2 August 2022
#
# ==============================================================================

library(tidyverse)
library(tools)
library(magick)
library(rsvg)
library(fs)

# ================================= User inputs ================================

photo_dir <- 'Z:/RC2/05_Spatial_Study_2022/01_FieldPhotos/01_RawData/Cotton_Strip_Photos_and_Videos'

out_dir <- 'Z:/RC2/05_Spatial_Study_2022/01_FieldPhotos/02_FormattedData/'

study_code <- 'SSS'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, recursive = T, full.names = T)

file_list <- file_list[ !grepl('.db',file_list)]

for (i in file_list){
  
  date <- unlist(str_split(i, '/')) [7] %>%
    str_remove_all("-")
    
  site <- unlist(str_split(i, '/')) [8]
  
  extension <- file_ext(i)
  
  subfolder_files <- list.files(dirname(i), full.names = T)
  
  subfolder_count <- tibble(
    file = subfolder_files)
  
  subfolder_count <- subfolder_count %>%
    add_column(number = 1:nrow(subfolder_count))
  
  subfolder <- dirname(i)
  
  number <- subfolder_count %>%
    filter(file %in% i) %>%
    select(number) %>%
    pull() %>%
    as.numeric()
  
  if (str_detect(i, 'Grain_Size_Grid_Photos') == TRUE) {
    out_file <- paste(out_dir, '/', study_code, '_', site,'_', date,'_GrainSize_', number,'.', extension, sep = '')
    
  } else if (str_detect(i, 'Environmental_Context_Photos') == TRUE) {
    out_file <- paste(out_dir,'/', study_code, '_', site,'_', date,'_EnvContext_', number,'.', extension , sep = '')
  
  } else if (str_detect(i, 'Underwater') == TRUE) {
    out_file <- paste(out_dir,'/', study_code, '_', site,'_', date,'_EnvContext_', number,'.', extension , sep = '')
    
  } else if (str_detect(i, 'Metadata_Sheet_Photos') == TRUE) {
    out_file <- paste(out_dir,'/', study_code, '_', site,'_', date,'_MetadataSheet_', number,'.', extension , sep = '')
    
  } else if (str_detect(i, 'People_Working_Photos') == TRUE) {
    out_file <- paste(out_dir,'/', study_code, '_', site,'_', date,'_PeopleWorking_', number,'.', extension , sep = '')
  } else if (str_detect(i, 'Cotton_Strip_Photos_and_Videos') == TRUE) {
    out_file <- paste(out_dir,'/', study_code, '_', site,'_', date,'_CottonStrip_', number,'.', extension , sep = '')
  }
  
  
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



