# ==============================================================================
#
# Rename minikit field photos
#
# 
# Status: In progress
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 26 Sept 2025
#
# ==============================================================================

library(tidyverse)
library(magick)

# ================================= User inputs ================================

photo_dir <- 'C:/Users/forb086/Downloads/TAP_Field_Photos'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, full.names = T)
file_list <- file_list[ !grepl('.db',file_list)]

file_names <- tibble(file_name = basename(file_list)) %>%
  mutate(new_name = file_name,
         new_name = str_replace(new_name, " - .*(?=\\.[^.]+$)", ""),
         new_name = str_replace(new_name, "_picture_across_stream-", "-across"),
         new_name = str_replace(new_name, "_picture_across_stream", "-across"),
         new_name = str_replace(new_name, "_picture_close_up_sediment", "-sed"),
         new_name = str_replace(new_name, "picture_downstream", "-down"),
         new_name = str_replace(new_name, "_picture_downstream", "-down"),
         new_name = str_replace(new_name, "_picture-downstream", "-down"),
         new_name = str_replace(new_name, "_picture_of_ph_strip", "-ph"),
         new_name = str_replace(new_name, "_picture_upstream", "-up"),
         new_name = str_replace(new_name, " pH", "ph"),
         new_name = str_replace(new_name, "pH", "ph"),
         new_name = str_replace(new_name, "Sed", "sed"),
         new_name = str_replace(new_name, "accross", "across"),
         new_name = str_replace(new_name, "_", "-"),
         new_name = str_replace(new_name, "--", "-"),
         new_name = str_replace(new_name, "Tap", "TAP"),
         new_name = str_replace_all(new_name, c('.heic'= '.jpeg',
                                                '.HEIC'= '.jpeg')))  %>%
  mutate(new_name = str_replace(new_name, "(TAP)(\\d+)", function(x) {
    number <- as.numeric(str_extract(x, "\\d+"))
    sprintf("TAP%03d", number)
  }))

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



