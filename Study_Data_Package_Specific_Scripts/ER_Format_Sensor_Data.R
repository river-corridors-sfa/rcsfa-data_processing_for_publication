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
# 8 February 2024
#
# ==============================================================================

library(tidyverse)
# library(crayon)
library(readxl)

rm(list=ls(all=T))

# =========================== User inputs ======================================

data_dir <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/SSS_Data_Processing/4 - SSS_MiniDOT_with_Depth/'

published_coords <- 'C:/Users/forb086/Downloads/v2_SSS_Data_Package/v2_SSS_Field_Metadata.csv'

out_dir <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/SSS_Data_Processing/5 - Publish_Ready_StreamMetabolizer_Input/'

# ========================== data base dirs ====================================

headers_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Sensor_Header_Rows.xlsx'

inst_methods_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Installation_Methods.xlsx'

# ========================== read/get files =====================================

headers <- read_xlsx(headers_dir, sheet = 'SSS_ER')

inst_methods <- read_xlsx(inst_methods_dir)

files <- list.files(data_dir, full.names = T, '.csv')

coords <- read_csv(published_coords) %>%
  select(Site_ID, Latitude, Longitude)
  

# ========================== loop through files=================================

for (file in files) {
  
  data <- read_csv(file) %>%
    select(DateTime, Parent_ID, Site_ID, miniDOT_Temperature, miniDOT_Dissolved_Oxygen, Baro_Pressure, Depth_m) %>%
    rename(Temperature = miniDOT_Temperature,
           Dissolved_Oxygen = miniDOT_Dissolved_Oxygen,
           Pressure = Baro_Pressure,
           Depth = Depth_m) %>%
    mutate(Pressure = round(Pressure, 1), #pressure in millibar, was previously converted to mmHg
           Depth = round(Depth, 2),
           Dissolved_Oxygen = round(Dissolved_Oxygen, 2),
           DateTime = paste0(' ', as.character(DateTime)),
           Site_ID = case_when(Site_ID == 'S63P' ~ 'S63',
                               Site_ID == 'S55' ~ 'S55N',
                               Site_ID == 'S56' ~ 'S56N',
                               Site_ID == 'T41' ~ 'T42',
                               TRUE ~ Site_ID))
  
  site_coords <- coords %>%
    filter(Site_ID == unique(data$Site_ID)) %>%
    select(-Site_ID)
  
  data <- data %>% 
    add_column(.after = 'Site_ID',
               site_coords)
  
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
  
  data_cols <- data %>%
    select(-DateTime, -Parent_ID, -Site_ID) %>%
    colnames()
  
  headers_filter <- headers_filter %>%
    arrange(factor(Column_Header, levels = data_cols))%>%
    mutate(header = paste0('# ', Column_Header,"; ", Unit, "; ", InstallationMethod_ID, "; ",Instrument_Summary, ".")) %>%
    select(header)
  
  data_headers <- tibble(header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary') %>%
    add_row(headers_filter) %>%
    head(7)
  
  n_rows <- nrow(data_headers) + 2
  
  data_headers <- data_headers %>%
    add_row(header = paste0('# HeaderRows_', n_rows),
            .before = 1)%>%
    mutate(header = str_replace_all(header, '\\..', '.'))

  out_file <- str_c(out_dir,'v2_', unique(data$Parent_ID), '_Temp_DO_Press_Depth.csv', sep = '')
  
  write_csv(data_headers, out_file, col_names = F)
  
  write_csv(data, out_file, col_names = T, append = T)
  
}


