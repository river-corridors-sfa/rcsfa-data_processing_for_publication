# ==============================================================================
#
# Combine STL metadata with SpC
#
# Status: In Progress. 
# 
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 7 Sept 2022
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

metadata <- read_csv('Z:/Campaign C/Hydropeaking_Network/WHONDRS_and_Non-WHONDRS_Data/03_Metadata/WHONDRS_STL_Metadata_formatted.csv')
  
spc <- read_csv('Z:/Campaign C/Hydropeaking_Network/WHONDRS_Sampling_Campaigns/WHONDRS_STL/WHONDRS_YSI_MAL2021.csv', skip = 3 )%>% 
  select("Station", "Temp","Pression","DO%","DO mg/L","SPC","pH","Turbidity")

outdir <- 'Z:/Campaign C/Hydropeaking_Network/WHONDRS_and_Non-WHONDRS_Data/03_Metadata/WHONDRS_STL_Metadata_formatted_combined.csv'

# ==================================== Join ====================================

spc$Station <- gsub(',', '.', spc$Station)

join <- metadata %>%
  full_join(spc, by = c('Site_Name' = 'Station')) %>%
  filter(!is.na(Site_Name))

write_csv(join, outdir, na = 'N/A')
