# ==============================================================================
#
# Split S19S Processed ICR into water and sediment 
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 4 May 2026
#
# ==============================================================================

library(tidyverse) 

rm(list=ls(all=T))

# =================================== user input ===============================

data_file <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_S19S_Sediment_v10/Processed_Clean_S19S_Water_Field_sediments_9-29_Data.csv'

# =================================== read and split ============================

data <- read_csv(data_file) %>%
  rename(Mass = 1)

sed <- data %>%
  select(Mass, contains('Sed')|contains('SED'))

water <- data %>%
  select(Mass, !contains('Sed')|!contains('SED'))

# =================================== compare to xml files ============================

FieldSediment_xml <-  list.files('Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_S19S_Sediment_v10/v10_WHONDRS_S19S_Sediment/WHONDRS_S19S_Sediment_FTICR_Data_And_Instructions/WHONDRS_S19S_FTICR_FieldSediment_Data') %>%
  tibble(FieldSediment_xml = .) %>%
  mutate(sample_name = str_remove(FieldSediment_xml, '.xml'),
         sample_name = str_remove(sample_name, "_p\\d+"),
         sample_name = str_replace(sample_name, '_D', '-D'),
         sample_name = str_replace(sample_name, 'Sed-Field', 'Sed_Field'))
  
IncubationConditionsSediment_xml <-  list.files('Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_S19S_Sediment_v10/v10_WHONDRS_S19S_Sediment/WHONDRS_S19S_Sediment_FTICR_Data_And_Instructions/WHONDRS_S19S_FTICR_IncubationConditionsSediment_Data')%>%
  tibble(IncubationConditionsSediment_xml = .) %>%
  mutate(sample_name = str_remove(IncubationConditionsSediment_xml, '.xml'),
         sample_name = str_remove(sample_name, "_p\\d+"))

water_xml <-  list.files('Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_SW_v7/v7_WHONDRS_S19S_SW/WHONDRS_S19S_SW_FTICR_Data_And_Instructions/FTICR_Data') %>%
  tibble(water_xml = .) %>%
  mutate(sample_name = str_remove(water_xml, '.xml'),
         sample_name = str_remove(sample_name, "_p\\d+"))


check_samples <- tibble(processed_sample_name = colnames(data %>% select(-Mass))) %>%
  mutate(sample_name = str_remove(processed_sample_name, "_p\\d+"), .before = everything())  %>%
  full_join(FieldSediment_xml) %>%
  full_join(IncubationConditionsSediment_xml) %>%
  full_join(water_xml) %>%
  mutate(has_xml = case_when(is.na(FieldSediment_xml) & is.na(IncubationConditionsSediment_xml) & is.na(water_xml) ~ FALSE,
                             TRUE ~ TRUE)) %>%
  arrange(sample_name)

# all processed data has an xml with the fixes in 39/40
# 54 samples have an xml but are not in processed data, need to figure out why

missing_processed <- check_samples %>%
  filter(is.na(processed_sample_name),
         !str_detect(sample_name, 'INC')) 
