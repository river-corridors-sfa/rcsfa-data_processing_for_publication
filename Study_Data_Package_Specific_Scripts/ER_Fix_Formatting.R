# ==============================================================================
#
# Fix date format and column header in stream metabolizer outputs
#
# Status: In progress
#
# known issue: 
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 26 June 2023
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

# =========================== User inputs ======================================

dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Ecosystem_Respiration_Data_Package/SSS_Ecosystem_Respiration_Data_Package/'

# =========================== list files =======================================

all_files <- list.files(dir, '.csv', full.names = T, recursive = T)

dates <- all_files[grepl('daily',all_files)]

headers <- all_files[grepl('full',all_files)]

# =============================== fix ==========================================

for (date in dates) {
  
  data <- read_csv(date) %>%
    mutate(Date = paste(' ', as.character(Date)))
  
  write_csv(data, date)
  
}

rm(data)

for(header in headers){
  
  data <- read_csv(header) %>%
    # rename(Depth = depth) %>%
    mutate(Date = paste(' ', as.character(Date)),
           solar_time = paste(' ', as.character(solar_time)))
  
  write_csv(data, header)
  
}












