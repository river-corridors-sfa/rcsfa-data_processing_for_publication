# ==============================================================================
#
# Rename STL photos
#
# Status: In progress. 
#
# notes: fix files with periods in file name and add .jpg
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 21 October 2022
#
# ==============================================================================

library(tidyverse)
library(fs)

# ================================= User inputs ================================

dir <- 'C:/Brieanne/STL_SitePhotos'

outdir <- 'C:/Brieanne/STL_SitePhotos/renamed'

study <- 'STL_'


# ================================= rename ================================

files <- list.files(dir, recursive = T, full.names = T)

for (file in files) {
  
  file_name <- path_file(file)
  
  new_name <- str_replace(file_name, ' ', '_') %>%
    str_replace('\\(', '')%>%
    str_replace('\\)', '')%>%
    str_replace('\\(1\\)', '_1')%>%
    str_replace('\\(2\\)', '_2')%>%
    str_replace('\\(3\\)', '_3')
  
  new_dir <- paste(outdir, '/', paste0(study, new_name), sep = '' )
  
  file.copy(file, new_dir)
  
}
