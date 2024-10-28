# ==============================================================================
#
# Make table of SSS minidot correction factors 
#
# Status: 
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 7 February 2024
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

metadata <-
  read_csv(
    'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/06_Metadata/SSS_Metadata_Deploy_Sample_Retrieve_2023-03-03.csv', 
    na = c('N/A', -9999, 'NA')
  ) %>%
  mutate(Site_ID = case_when(Site_ID == 'S63P' ~ 'S63',
                             Site_ID == 'S55' ~ 'S55N',
                             Site_ID == 'S56' ~ 'S56N',
                             Site_ID == 'T41' ~ 'T42',
                             TRUE ~ Site_ID))

DO_offset_file <- 'Z:/RC2/01_Sensor_Calibration_and_Correction_Files/01_Minidot.bucket/05_MiniDotCorrectionFactors/minidot_correction_factors_2024-02-06.csv' %>%
  read_csv()

DO_offset_file_recent <- 'Z:/RC2/01_Sensor_Calibration_and_Correction_Files/01_Minidot.bucket/05_MiniDotCorrectionFactors/minidot_correction_factors_MOST_RECENT_2024-02-06.csv' %>%
  read_csv()

# ======================= Get SN and filter offset =============================

SNs <- paste0('7450-',unique(metadata$Deploy_Minidot_SN))

SSS_cfs <- DO_offset_file %>%
  filter(serial_number %in% SNs)

mc_SNs <- tibble(SNs = metadata$"Manual_Chamber_MiniDot_SN-1") %>%
  add_row(SNs = as.character(metadata$"Manual_Chamber_MiniDot_SN-2"))%>%
  add_row(SNs = as.character(metadata$"Manual_Chamber_MiniDot_SN-3")) 

mc_SNs <- paste0('7450-',unique(mc_SNs$SNs))

mc_SSS_cfs <- DO_offset_file %>%
  filter(serial_number %in% mc_SNs)

write_csv(SSS_cfs, 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/04_Minidot/Correction_Factor_Checks/SSS_correction_factor_check.csv')
write_csv(mc_SSS_cfs, 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/04_Minidot/Correction_Factor_Checks/SSS_correction_factor_check_MC.csv')
