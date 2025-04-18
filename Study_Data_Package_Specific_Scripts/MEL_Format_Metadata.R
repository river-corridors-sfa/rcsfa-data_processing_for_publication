# ==============================================================================
#
# Format MEL field metadata for data package
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 17 April 2025
#
# ==============================================================================

library(tidyverse)
library(gsheet)

rm(list=ls(all=T))

# =============================== User inputs ==================================

metadata_link <- 'https://docs.google.com/spreadsheets/d/1J2bRi52rVxo7xFe-7APxPGbxtaf0-F4sj3BjZ2hkmUE/edit?usp=sharing'

out_file <- 'Y:/MEL/MEL_Data_Package_Staging/MEL_Data_Package/MEL_Field_Metadata.csv'

# =============================== read in metadata ==============================


metadata <- read_csv(construct_download_url(metadata_link)) %>%
  select(-Timestamp, -Email, -29, -30, -31, -32, -33, -"Stream name") %>%
  rename(Hydrograph_Online = "If the hydrograph from your site is available online, provide the link",
         Contact_First_Name = "First Name",
         Contact_Last_Name = "Last Name",
         Organization = "Organization/Institution",
         Site_Name = "Site name",
         Sample_Date = "Date of sampling",
         Sample_Start_Time = "Sampling Start Time",
         Time_Zone = "Local time zone written out fully.",
         Parent_ID = "Core ID in the format \"MEL_##_COR\"", 
         MONet_Sample_ID = "MONet Sample ID",
         Latitude ="Latitude of sediment/soil sampling (decimal degrees)",
         Longitude ="Longitude of sediment/soil sampling (decimal degrees)",
         Elevation_m = "Elevation",
         Weather = "General weather conditions during sampling",
         Terrain_Gradient = "General gradient of terrain",
         General_Vegetation = "General vegetation type (select up to 2 if mixed)",
         Soil_or_Sediment_Texture ="Dominant soil/sediment texture",
         Soil_or_Sediment_Type ="Dominant soil/sediment type",
         Canopy_Coverage = "Canopy coverage",
         Ground_Plant_Coverage ="Ground vegetation coverage of low stature plants",
         Days_Since_Inundation = "Number of days since inundation",
         Water_Type = "Water Type",
         Notes = "Additional Notes" )%>%
  mutate(Notes = str_remove(Notes, "\\[.*"),
         Notes = case_when(Notes == '' ~ 'N/A',
                           TRUE ~ Notes),
         Sample_Date = paste0(" ", mdy(Sample_Date)),
         Parent_ID =str_remove(Parent_ID, '_COR'))

write_csv(metadata, out_file)
