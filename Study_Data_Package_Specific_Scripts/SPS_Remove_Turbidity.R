# ==============================================================================
#
# Remove turbidity from SPS Sensor dp (v3)
# 
# ==============================================================================
#
# Author: Brieanne Forbes 
# 5 March 2024
#
# ==============================================================================

library(tidyverse)
library(fs)

rm(list=ls(all=T))

# ================================= User inputs ================================

dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/SFA_SpatialStudy_2021_SensorData_v3/SFA_SpatialStudy_2021_SensorData_v3/MantaRiver'

# ================================= find files ================================

files <- list.files(dir, '.csv', full.names = T, recursive = T)

# ============================== remove turbidity =============================

for (file in files) {
  
  top <- read_csv(file, n_max = 1, col_names = F)
  
  n_header <- top %>%
    pull() %>%
    str_extract('[:digit:]+') %>%
    as.numeric() - 2
  
  header <- read_csv(file, skip = 1, n_max = n_header, col_names = F) %>%
    filter(!str_detect(X1, 'Turbidity'))
  

    
  data <- read_csv(file, comment = '#') %>%
    select(-contains('Turbidity')) 
  
  if('DateTime' %in% colnames(data)){
  
  data <- data %>%
    mutate(DateTime = str_c(' ', as.character(DateTime)))
    
  } else if('Date' %in% colnames(data)){
    
    data <- data %>%
      mutate(Date = str_c(' ', as.character(Date)))
    
    ph_columns <- grep("pH", names(data), value = TRUE)
    
    data <- data %>%
      mutate_at(vars(ph_columns), ~ifelse(. == 0, -9999, .))
    
  }
  
  new_n <- nrow(header) + 2
  
  top <- top %>%
    mutate(X1 = str_replace(X1, '[:digit:]+', as.character(new_n)))
  
  file_dir <- dirname(file)
  
  file_name <- path_file(file)
  
  new_name <- str_c(file_dir, '/v2_',file_name )
  
  write_csv(top, new_name, col_names = F, append = F)
  
  write_csv(header, new_name, col_names = F, append = T)
  
  write_csv(data, new_name, col_names = T, append = T)
  
}
