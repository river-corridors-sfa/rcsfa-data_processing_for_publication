# ==============================================================================
#
# Format sensor data following the Goldman et al. (2021) reporting format for 
# Ecosystem Respiration data package
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 30 October 2024
#
# ==============================================================================

library(tidyverse)
# library(crayon)
library(readxl)

rm(list=ls(all=T))

# =========================== User inputs ======================================

setwd('C:/Brieanne/GitHub/SSS_metabolism/Stream_Metabolizer/Inputs/Sensor_Files')

# ========================== data base dirs ====================================

headers_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Sensor_Header_Rows.xlsx'

inst_methods_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Installation_Methods.xlsx'

# ========================== read/get files =====================================

headers <- read_xlsx(headers_dir, sheet = 'SSS_ER') %>%
  filter(Sensor == 'input')

inst_methods <- read_xlsx(inst_methods_dir)

files <- list.files('.', full.names = T, '.csv')

# ========================== loop through files=================================

for (file in files) {
  
  data <- read_csv(file) %>%
    mutate(DateTime = paste0(' ', as.character(DateTime)))
  
  # ============== filter for different baro methods ===========================
  
  if(unique(data$Site_ID) %in% c('S18R', 'S29', 'S34R', 'S39', 'S42', 'S48R', 'S56', 'T05P', 'W10')){
    
    headers_filter <- headers %>%
      filter(InstallationMethod_ID != 'BaroExtrap_01')
    
  }else {
  
  headers_filter <- headers %>%
    filter(InstallationMethod_ID != 'TreeRope_01')
  
  }
  # ============== filter for different minidot methods ========================
  
  if(unique(data$Site_ID) %in% c('S22RR', 'S23', 'S24', 'S29', 'S31', 'S32', 'S34R', 'S36', 
                         'S41R', 'S43', 'S49R', 'S50P', 'S51', 'S54', 'S55', 'S56', 
                         'S57', 'S58', 'T02', 'T03', 'T07', 'T41', 'U20', 'W10', 'W20')){
    
    headers_filter <- headers_filter %>%
      filter(InstallationMethod_ID != 'Minidot_03')
    
  }else {
    
    headers_filter <- headers_filter %>%
      filter(InstallationMethod_ID != 'Minidot_04')
    
  }
  
  # ============== filter for different depth methods ========================
  
  if(unique(data$Site_ID) %in% c('W20')){
    
    headers_filter <- headers_filter %>%
      filter(InstallationMethod_ID != 'Depth_01'|InstallationMethod_ID != 'Depth_03')
    
  }else if(unique(data$Site_ID) %in% c('T07')){
    
    headers_filter <- headers_filter %>%
      filter(InstallationMethod_ID != 'Depth_01'|InstallationMethod_ID != 'Depth_02')
    
  }else {
    
    headers_filter <- headers_filter %>%
      filter(InstallationMethod_ID != 'Depth_02'|InstallationMethod_ID != 'Depth_03')
    
  }
  
  # ============== add header rows ========================
  
  data_cols <- data %>%
    select(-DateTime, -Parent_ID, -Site_ID) %>%
    colnames()
  
  headers_filter <- headers_filter %>%
    arrange(factor(Column_Header, levels = data_cols))%>%
    mutate(header = paste0('# ', Column_Header,"; ", Unit, "; ", InstallationMethod_ID, "; ",Instrument_Summary, ".")) %>%
    select(header)
  
  data_headers <- tibble(header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary') %>%
    add_row(headers_filter)
  
  n_rows <- nrow(data_headers) + 2
  
  data_headers <- data_headers %>%
    add_row(header = paste0('# HeaderRows_', n_rows),
            .before = 1)%>%
    mutate(header = str_replace_all(header, '\\..', '.'))
  
  write_csv(data_headers, file, col_names = F)
  
  write_csv(data, file, col_names = T, append = T)
  
}


