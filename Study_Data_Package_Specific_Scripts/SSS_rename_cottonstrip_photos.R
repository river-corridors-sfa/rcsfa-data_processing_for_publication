# ==============================================================================
#
# Rename cotton strip photos and videos for Second Spatial Study (SSS) data package
#
# 
# Status: In Progress. 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 2 August 2022
#
# ==============================================================================

library(tidyverse)
library(tools)

# ================================= User inputs ================================

photo_dir <- 'C:/Brieanne/Cotton_Strip_Photos_and_Videos'

out_dir <- 'C:/Brieanne/Cotton_Strip_Photos_and_Videos/Formatted'

metadata <- read_csv('C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/06_Metadata/SSS_Metadata_Deploy_Sample_Retrieve_2023-03-03.csv')

# comment out line 55 for grid photos or line 54 for environmental context photos

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, recursive = T, full.names = T)

# number_of_files <- tibble(
#   dir = dirname(file_list)) %>% 
#   count(dir) 



for (i in file_list){
  
  site <- unlist(str_split(i, '/')) [5]
  extension <- file_ext(i)
  
  parent_id <- metadata %>% 
    filter(Site_ID == site) %>%
    select(Site_Vial_ID) %>%
    pull()
  
  subfolder <- dirname(i)
  
  subfolder_files <- list.files(subfolder , full.names = T)
  
  subfolder_count <- tibble(
    file = subfolder_files)
  
  subfolder_count <- subfolder_count %>%
    add_column(number = 1:nrow(subfolder_count))
  
  number <- subfolder_count %>%
    filter(file %in% i) %>%
    select(number) %>%
    pull()
  
  out_file <- paste(out_dir, '/', parent_id, '_CottonStrip_', number,'.', extension, sep = '')

  
  file.copy(i, out_file)
}



