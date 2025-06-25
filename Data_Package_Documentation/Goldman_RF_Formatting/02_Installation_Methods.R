# ==============================================================================
#
# Pull and compile installation methods from sensor data following the 
# Goldman et al. (2021) reporting format 
#
# Status: In progress
#
# known issue: 
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 21 June 2023
#
# ==============================================================================

library(tidyverse)
library(readxl)

rm(list=ls(all=T))

# =========================== User inputs ======================================

data_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2022-2024_SensorData/RC2_TemporalStudy_2022-2024_SensorData/New folder/'

study_code <- 'RC2_2022-2024'

inst_database_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Installation_Methods.xlsx'

# ===================== read in database find files ============================

inst_database <- read_xlsx(inst_database_dir)

csv <- list.files(data_dir, '.csv',full.names = T, recursive = T)

combine <- tibble(InstallationMethod_ID = as.character())

for (i in csv) {
  
  test <- read_csv(i, n_max = 1, col_names = F) %>% 
    select(X1) %>%
    pull()
  
  if(str_detect(test,'# HeaderRows_') == TRUE){
    
    n_rows <- str_extract(test, '[:digit:]+') %>%
      as.numeric() %>%
      -3
    
    headers <- read_csv(i, skip = 2, n_max = n_rows, col_names = F) %>%
      separate(X1, into = c('Column_Header','Unit','InstallationMethod_ID','Instrument_Summary'), sep = '; ' ) 
    
    IDs <- headers %>%
      select(InstallationMethod_ID)
    
    combine <- combine %>%
      add_row(IDs)
    
  }
  
}

filter_combine <- combine %>%
  filter(InstallationMethod_ID != 'N/A') %>%
  distinct()

filter_inst <- inst_database %>%
  filter(InstallationMethod_ID %in% filter_combine$InstallationMethod_ID) %>% 
  select(InstallationMethod_ID, InstallationMethod_Description) %>%
  arrange(InstallationMethod_ID)

outname <- paste0(data_dir, study_code, '_Installation_Methods.csv') 

write_csv(filter_inst, outname)




