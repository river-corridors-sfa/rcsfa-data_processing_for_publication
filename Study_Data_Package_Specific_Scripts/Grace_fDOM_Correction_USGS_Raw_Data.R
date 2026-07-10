#
# Extract USGS raw data for Grace to use to test her fdom corrections
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 30 June 2026
#
# ==============================================================================
library(tidyverse) 

rm(list=ls(all=T))

# ============================ User Inputs =====================================

raw_file <- "C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/EXO/01_RawData/M01/L0_0_M01_2026-03-13.csv"

# ============================ read and filter =================================

raw_data <- read_csv(raw_file)

grace_data <- raw_data %>%
  select(date_mm_dd_yyyy, time_hh_mm_ss, temp_c, turbidity_fnu, fdom_rfu) %>%
  mutate(date_mm_dd_yyyy = mdy(date_mm_dd_yyyy)) %>%
  filter(date_mm_dd_yyyy >= as_date('2026-02-06'))%>%
  filter(date_mm_dd_yyyy <= as_date('2026-06-30')) 

write_csv(grace_data, 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/07_fDOM_Corrections/USGS_Raw_Data/USGS_Raw_Data_Filtered.csv')




