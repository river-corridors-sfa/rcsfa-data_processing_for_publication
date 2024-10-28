# ==============================================================================
#
# Move optode photos and txt files from the share point to the ECA shared drive
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 24 April 2023
#
# ==============================================================================

library(tidyverse)
library(fs)

rm(list=ls(all=T))

# ================================= User inputs ================================

sharepoint <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/ECA/Optode multi reactor/'

sharedrive <- 'Y:/Optode_multi_reactor/'

# ================================= find photos ================================

photos <- list.files(sharepoint, '.tif', recursive = T, full.names = T)

txt_files <- list.files(paste0(sharepoint, 'Optode_multi_reactor_incubation/'), '.txt', recursive = T, full.names = T)

txt_files <- txt_files[ !grepl('calfactor',txt_files)]

# ================================= move photos ================================
# 
# for (photo in photos) {
#   
#   file_new_path <- photo %>%
#     str_replace(sharepoint, sharedrive)
#   
#   file_name <- path_file(file_new_path)
#   
#   dir <- file_new_path %>%
#     str_remove(file_name)
#   
#   dir_create(dir)
#   
#   file.rename(photo, file_new_path)
#   
# }

# Create a progress bar
pb <- txtProgressBar(min = 0, max = length(txt_files), style = 3)

for (txt in txt_files) {
  
  file_new_path <- txt %>%
    str_replace(sharepoint, sharedrive)
  
  file_name <- path_file(file_new_path)
  
  dir <- file_new_path %>%
    str_remove(file_name)
  
  dir_create(dir)
  
  file.rename(txt, file_new_path)
  
  index <- match(txt, txt_files)
  
    # Update the progress bar
    setTxtProgressBar(pb, index)


  
  }
  
  
  # Close the progress bar
  close(pb)
  