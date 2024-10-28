# ==============================================================================
#
# Rename DBP ICR files
#
# Status: complete 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 14 November 2022
#
# ==============================================================================

library(tidyverse)
library(fs)

# ================================= User inputs ================================

dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_DBP_Data_Package/WHONDRS_DBP_Data_Package/FTICR/FTICR_RawData'

mapping <- read_csv('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC4/BoyeFiles_byStudyCode/WHONDRS_DBP/ICR_mapping.csv')

# ================================= rename ================================

files <- list.files(dir, pattern = '.xml', recursive = T, full.names = T)

for (file in files) {
  
  file_name <- path_file(file) %>%
    str_remove('.xml')
  
  new_name <- mapping %>%
    filter(new == file_name)%>%
    select(publish)%>%
    pull()
  
  new_dir <- paste0(dir, '/', new_name,'.xml')
  
  file.rename(file, new_dir)
  
}
