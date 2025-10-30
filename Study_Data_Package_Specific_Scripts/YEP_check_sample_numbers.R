# ==============================================================================
#
# check sample numbers in YEP dp
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 27 Oct 2025
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

# ================================= User inputs ================================

sample_metadata <- "Z:/00_ESSDIVE/01_Study_DPs/YEP_Data_Package/YEP_Data_Package/YEP_Sample_Name_Metadata.csv" %>%
  read_csv()%>%
  select(Sample_Name)

resp <- "Z:/00_ESSDIVE/01_Study_DPs/YEP_Data_Package/YEP_Data_Package/YEP_Sample_Data/YEP_Sediment_Incubations_Respiration_Rates.csv" %>%
  read_csv(skip = 2, na = c('N/A', '-9999')) %>%
  filter(!is.na(Sample_Name))%>%
  select(Sample_Name)

do <- "Z:/00_ESSDIVE/01_Study_DPs/YEP_Data_Package/YEP_Data_Package/YEP_Sample_Data/RespirationRateCalculation/YEP_Sediment_Respiration_Raw_Dissolved_Oxygen.csv" %>%
  read_csv(skip = 2, na = c('N/A', '-9999')) %>%
  filter(!is.na(Sample_Name)) %>%
  select(Sample_Name)
  
moi <- "Z:/00_ESSDIVE/01_Study_DPs/YEP_Data_Package/YEP_Data_Package/YEP_Sample_Data/YEP_Sediment_Gravimetric_Moisture.csv" %>%
  read_csv(skip = 2, na = c('N/A', '-9999')) %>%
  filter(!is.na(Sample_Name))%>%
  select(Sample_Name)

ocn <- "Z:/00_ESSDIVE/01_Study_DPs/YEP_Data_Package/YEP_Data_Package/YEP_Sample_Data/YEP_Sediment_NPOC_TN.csv" %>%
  read_csv(skip = 2, na = c('N/A', '-9999')) %>%
  filter(!is.na(Sample_Name))%>%
  select(Sample_Name)

dwa <- "Z:/00_ESSDIVE/01_Study_DPs/YEP_Data_Package/YEP_Data_Package/YEP_Sample_Data/YEP_Sediment_Water_Mass_Volume.csv" %>%
  read_csv(skip = 2, na = c('N/A', '-9999')) %>%
  filter(!is.na(Sample_Name))%>%
  select(Sample_Name)


# ================================= User inputs ================================

resp_check <- sample_metadata %>%
  add_column(file = 'sample metadata') %>%
  filter(str_detect(Sample_Name, 'INC')) %>%
  full_join(resp %>%
              add_column(file = 'resp'), 
            by = 'Sample_Name')

do_check <- sample_metadata %>%
  add_column(file = 'sample metadata') %>%
  filter(str_detect(Sample_Name, 'INC')) %>%
  full_join(do %>%
              add_column(file = 'do') %>%
              distinct(), 
            by = 'Sample_Name')

moi_check <- sample_metadata %>%
  add_column(file = 'sample metadata') %>%
  filter(str_detect(Sample_Name, 'MOI')) %>%
  full_join(moi %>%
              add_column(file = 'moi') %>%
              distinct(), 
            by = 'Sample_Name')

ocn_check <- sample_metadata %>%
  add_column(file = 'sample metadata') %>%
  filter(str_detect(Sample_Name, 'OCN|SOC')) %>%
  full_join(ocn %>%
              add_column(file = 'ocn') , 
            by = 'Sample_Name')

dwa_check <- sample_metadata %>%
  add_column(file = 'sample metadata') %>%
  filter(str_detect(Sample_Name, 'SED|INC|STR')) %>%
  full_join(dwa %>%
              add_column(file = 'dwa') , 
            by = 'Sample_Name')

