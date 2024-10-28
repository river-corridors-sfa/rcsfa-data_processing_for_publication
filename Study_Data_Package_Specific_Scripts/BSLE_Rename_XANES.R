# ==============================================================================
#
# Rename columns for BSLE v4 
# 
# Status: Incomplete
#
# Notes: 
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 18 July 2024
rm(list=ls(all=TRUE))

setwd("C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v4")

library(tidyverse)
library(lubridate)

# ================================= find files ================================

n_xanes <- read_csv('./Review/N_Xanes/BSLE_N_Xanes_Processed_Final_2023Sept06.csv')

corrected <- n_xanes %>%
  rename_with(~ str_remove(., '_corrected'))%>%
  rename_with(~ str_replace(., 's', '-solid'))%>%
  rename_with(~ str_replace(., 'L$', 'ABC-filt0.2'))

write_csv(corrected, './v4_BSLE_Data_Package/v4_BSLE_Data/BSLE_XANES/BSLE_N-XANES.csv')

paste(colnames(corrected), collapse = ',')