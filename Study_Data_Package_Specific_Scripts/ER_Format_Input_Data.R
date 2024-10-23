# ==============================================================================
#
# Format data following the Goldman et al. (2021) reporting format for 
# Ecosystem Respiration data package
#
# Status: in progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 2 May 2023
#
# ==============================================================================

library(tidyverse)
library(readxl)

rm(list=ls(all=T))

# =========================== User inputs ======================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Documents/GitHub/SSS_metabolism/StreamMetabolizer_runs/final_results/'

# ========================== data base dirs ====================================

headers_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Sensor_Header_Rows.xlsx'

inst_methods_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Installation_Methods.xlsx'

# ========================== read/get files =====================================

headers <- read_xlsx(headers_dir, sheet = 'ER')

slope <- read_csv(list.files(dir, full.names = T, 'SSS_Slope.csv'))

flow_vel <- read_csv(list.files(dir, full.names = T, 'flow_vel'))
  

# ========================== combine and add headers ===========================

combine <- slope %>%
  full_join(flow_vel)%>%
  select(Site_ID, COMID, Slope, Discharge, Velocity)

data_cols <- combine %>%
  select(-Site_ID) %>%
  colnames()

headers_filter <- headers %>%
  filter(Sensor == 'k600_input') %>%
  arrange(factor(Column_Header, levels = data_cols))%>%
  mutate(header = paste0('# ', Column_Header,"; ", Unit, "; ", InstallationMethod_ID, "; ",Instrument_Summary, ".")) %>%
  select(header)

data_headers <- tibble(header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary') %>%
  add_row(headers_filter)

n_rows <- nrow(data_headers) + 2

data_headers <- data_headers %>%
  add_row(header = paste0('# HeaderRows_', n_rows),
          .before = 1)

out_file <- str_c(dir, 'SSS_Slope_Discharge_Velocity.csv')

write_csv(data_headers, out_file, col_names = F)

write_csv(combine, out_file, col_names = T, append = T)