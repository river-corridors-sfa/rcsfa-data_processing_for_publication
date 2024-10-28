# ==============================================================================
#
# Format SSS Respiration data package files to follow csv reporting format 
# (fix column headers and missing values)
#
# Status: in progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 19 May 2023
#
# ==============================================================================

library(tidyverse)
library(lubridate)

# =========================== User inputs ======================================

dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Respiration_Data_Package'

# ============================ list files ======================================

# sensor <- list.files(dir, 'Temp_DO_Press_Depth', full.names = T, recursive = T)

SM <- list.files(dir, 'SM_final', full.names = T, recursive = T)

SM <- SM[ !grepl('.Rmd',SM)]

# SM <- SM[grepl('daily',SM)]

# ============================ fix formatting ==================================


for (file in SM) {
  
  data <- read_csv(file) %>%
    select(-starts_with('DO_R2'))
  
  # 
  # if('solar.time' %in% colnames(data)){
  #   
  #   data <- data %>%
  #     rename(solar_time = solar.time) %>%
  #     mutate(solar_time = paste0(" ", as.character(as_datetime(solar_time))))
  #   
  # }
  # 
  # names(data) <- gsub('.', 'point', names(data), fixed = T)
  # 
  # if('Warning' %in% colnames(data)){
  #   
  #   data <- data %>%
  #     mutate(Warning = replace_na('N/A')) 
  #   
  # }
  # 
  # 
  # if('warnings' %in% colnames(data)){
  #   
  #   data <- data %>%
  #     mutate(warnings = replace_na('N/A')) 
  #   
  # }
  # 
  # if('time_index' %in% colnames(data)){
  #   
  #   data <- data %>%
  #     mutate(time_index = replace_na('N/A'),
  #            date_index = replace_na('N/A')) 
  #   
  # }
  # 
  # 
  # data <- data %>%
  #   mutate(across(where(is.character), replace_na, replace = 'N/A')) %>%
  #   mutate(across(where(is.numeric), replace_na, replace = -9999))
  # 
  # if('date' %in% colnames(data)){
  #   
  #   data <- data %>%
  #     rename(Date = date) %>%
  #     mutate(Date = paste0(" ", as.character(ymd(Date))))
  #   
  # }
  # 
  # if('date_index' %in% colnames(data)){
  # 
  #   data <- data %>%
  #     select(-date_index, -time_index)
  #   
  # 
  # 
  # }
  #   
  
  write_csv(data, file) 
  
}
