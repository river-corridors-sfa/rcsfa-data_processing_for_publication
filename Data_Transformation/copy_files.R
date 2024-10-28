# ==============================================================================
#
# Copy files from share drive to local
#
# Status: Complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 26 February 2024
#
# ==============================================================================

library(tidyverse)
library(fs)

# ================================= User inputs ================================

sharedrive <- 'Z:/RC2/09_River_Monitoring_Photos/01_Site_Photos/02_FormattedData'

local <- 'C:/Users/forb086/OneDrive - PNNL/Documents/RMP_Photos'

# =================================== copy files ===============================

files <- list.files(sharedrive, full.names = T)

files <- files[!grepl('Archive', files)]

copied <- list.files(local, full.names = T) %>%
  tibble() %>%
  rename(word = 1) %>%
  mutate(word = str_remove(word, local),
         word = str_remove(word, '/'))

for(file in files){
  
  name <- path_file(file)
  
  if(name %in% copied$word){
    
    
  } else {
    
    new_dir <- file %>%
      str_replace(sharedrive, local)
    
    file.copy(file, new_dir)
    
  }
  
  
}
