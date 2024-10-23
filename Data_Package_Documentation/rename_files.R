# ==============================================================================
#
# Rename ICR files
#
# Status: In progress. 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 24 August 2022
#
# ==============================================================================

library(tidyverse)
library(fs)
library(tools)

# ================================= User inputs ================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v2/BSLE_Data_Package_v2/BSLE_Data_v2/BSLE_FTICR/FTICR_Data'

# study <- 'YDE'


# ================================= rename ================================

files <- list.files(dir,  recursive = T, full.names = T)

for (file in files) {
  
  dir <- path_dir(file)
  
  file_name <- path_file(file) %>%
    str_remove('.txt')
  
  # rep <- unlist(str_split(file_name, '-'))[2]
  
  ext <- file_ext(file)
  
  # new_name <- str_remove(file_name, ".+(?=BSLE)")
  # new_name <- str_remove(new_name, "(?<=Blank[:digit:]{2}).+")
  
  new_name <- str_c(file_name, "-filt0.2")
  
  new_dir <- paste0(dir, '/', new_name, ".", ext)
  
  file.rename(file, new_dir)
  
}

