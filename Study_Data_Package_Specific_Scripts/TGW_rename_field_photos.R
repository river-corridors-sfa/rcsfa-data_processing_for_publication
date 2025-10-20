# ==============================================================================
#
# Rename TGW field photos
#
# 
# Status: Complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 3 Sept 2025
#
# ==============================================================================

library(tidyverse)
library(magick)

# ================================= User inputs ================================

photo_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/TGW_Data_Package/TGW_Data_Package/TGW_Field_Photos'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, full.names = T)
file_list <- file_list[ !grepl('.db',file_list)]

file_names <- tibble(file_name = basename(file_list)) %>%
  mutate(new_name = str_replace(file_name, " - .*(?=\\.[^.]+$)", ""),
         new_name = str_replace_all(new_name, c("TGA" = "TGW",
                                                "THW" = "TGW",
                                                '.heic'= '.jpeg',
                                                '.HEIC'= '.jpeg')))



for (i in file_list){
  
  
  new_name <- file_names %>%
    filter(file_name == basename(i)) %>%
    pull(new_name)
  
  out_file <- paste0(photo_dir,'/', new_name)
  
  if(str_detect(i, 'heic|HEIC')){
    
    photo_read <- magick::image_read(i)
    
    image_write(photo_read, out_file, format = 'jpeg')
    
  } else{

  
  file.rename(i, out_file)
  }

}
 


