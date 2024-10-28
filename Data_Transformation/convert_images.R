# ==============================================================================
#
# Change photo file type from heic to jpeg and remove collaborator name
#
# Status: In progress
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 1 Dec 2022
#
# ==============================================================================

library(tidyverse)
library(magick)
library(rsvg)
library(fs)

# ================================= User inputs ================================

photo_dir <- 'C:/Brieanne/SSS_Environmental_Context_Photos/Formatted/'

out_dir <- 'C:/Brieanne/SSS_Environmental_Context_Photos/Formatted/'

# ================================= convert photo ==============================

photos <- list.files(photo_dir, '.HEIC|.heic', full.names = T, recursive = T)

for (photo in photos) {
  
  photo_read <- magick::image_read(photo)

  file_name <- path_file(photo) %>%
    str_replace(., '.heic', '.jpeg')%>%
    str_replace(., '.HEIC', '.jpeg')

  new_name <- paste0(out_dir, file_name)
  
  # new_name <- photo %>%
  #   str_replace(., '.heic', '.jpeg')%>%
  #   str_replace(., '.HEIC', '.jpeg')
  # 
  
  image_write(photo_read, new_name, format = 'jpeg')
  
}


