# ==============================================================================
#
# Rename BSLE photos from "char name' to 'parent id'
#
# Status: Complete
#
# Note: 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 2 Sept 2022
#
# ==============================================================================

library(tidyverse)
library(fs)
library(tools)

# ================================= User inputs ================================

photos_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Photos/2021_char_photos/'
  
metadata <- read_csv('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Metadata_and_Protocols/BSLE_Leaching_Metadata.csv')

out_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Photos/'

# ============================ list files and rename ===========================

photos <- list.files(photos_dir, full.names = T)

metadata$Char_Name <- gsub('Burn', 'burn', as.character(metadata$Char_Name))

for (photo in photos) {
  file_name_full <- path_file(photo)
  
  file_name <- file_path_sans_ext(file_name_full)
  
  ext <- file_ext(file_name_full)
  
  char_metadata <- metadata %>%
    filter(Char_Name == file_name)
    
    new_file_name <-
      paste(unique(char_metadata$Parent_ID), '_Char_Photo', sep = '')
    
    new_file_dir <- paste(out_dir, new_file_name, '.', ext, sep = '')
    
    file_copy(photo, new_file_dir)
    
  
}

