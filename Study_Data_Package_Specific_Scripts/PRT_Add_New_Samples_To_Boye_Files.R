# ==============================================================================
#
# Add new samples into PRT boye files
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 31 July 2026
#
# ==============================================================================
library(tidyverse) 

rm(list=ls(all=T))

# =================================== npoc ===============================

new_path <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/NPOC_TN/05_PublishReadyData/PRT_Water_NPOC_TN_Boye_2026-07-27.csv'

new_file <- read_csv(new_path,
                     skip = 2) %>%
  filter(Sample_Name != 'N/A'&Sample_Name != '-9999') %>%
  filter(!str_detect(Sample_Name, 'ICR'))

old_path <- "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/PRT_Water_NPOC_TN.csv"

old_file <- read_csv(old_path,
                     skip = 2) %>%
  filter(Sample_Name != 'N/A'&Sample_Name != '-9999')

new_samples <- new_file %>%
  anti_join(
    old_file,
    by = "Sample_Name"
  )


metadata <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Field_Metadata.csv") %>%
  select(Parent_ID, Metadata_Type)

combined_file <- bind_rows(old_file, 
                           new_samples) %>% 
  mutate(Parent_ID = str_extract(Sample_Name, "^[^_]+")) %>%
  left_join(metadata) %>%
  mutate(Metadata_Type = case_when(is.na(Metadata_Type) & str_detect(Sample_Name, 'SOI') ~ 'Soil',
                                   is.na(Metadata_Type) & str_detect(Sample_Name, 'V') ~ 'Vegetation',
                                   TRUE ~ Metadata_Type),
         Material = case_when(str_detect(Metadata_Type, 'Soil') ~ 'Soil',
                              str_detect(Sample_Name, 'Vegetation') ~ 'Plant Structure',
                                   TRUE ~ Material))

veg <- combined_file %>%
  filter(Metadata_Type == 'Vegetation')

sw <- combined_file %>%
  filter(str_detect(Metadata_Type, 'Surface water'))

gw <- combined_file %>%
  filter(str_detect(Metadata_Type, 'Ground water'))

soil <-  combined_file %>%
  filter(str_detect(Metadata_Type, 'Soil'))

write_csv(veg, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/PRT_Vegetation_NPOC_TN.csv",
          append = T,
          col_names = F)

write_csv(sw, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/v2_PRT_SurfaceWater_NPOC_TN.csv",
          append = T,
          col_names = F)

write_csv(gw, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/v2_PRT_Groundwater_NPOC_TN.csv",
          append = T,
          col_names = F)

write_csv(soil, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/PRT_Soil_NPOC_TN.csv",
          append = T,
          col_names = F)

# =================================== iso ===============================

new_path <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/ISO/05_PublishReadyData/PRT_Water_ISO_Boye_2026-08-13.csv'

new_file <- read_csv(new_path,
                     skip = 2) %>%
  filter(Sample_Name != 'N/A'&Sample_Name != '-9999') %>%
  filter(!str_detect(Sample_Name, 'ICR'))

old_path <- "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/PRT_Water_Isotopes.csv"

old_file <- read_csv(old_path,
                     skip = 2) %>%
  filter(Sample_Name != 'N/A'&Sample_Name != '-9999')

new_samples <- new_file %>%
  anti_join(
    old_file,
    by = "Sample_Name"
  )


metadata <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Field_Metadata.csv") %>%
  select(Parent_ID, Metadata_Type)

combined_file <- bind_rows(old_file, 
                           new_samples) %>% 
  mutate(Parent_ID = str_extract(Sample_Name, "^[^_]+")) %>%
  left_join(metadata) %>%
  mutate(Metadata_Type = case_when(is.na(Metadata_Type) & str_detect(Sample_Name, 'SOI') ~ 'Soil',
                                   is.na(Metadata_Type) & str_detect(Sample_Name, 'V') ~ 'Vegetation',
                                   TRUE ~ Metadata_Type),
         Material = case_when(str_detect(Metadata_Type, 'Soil') ~ 'Soil',
                              str_detect(Sample_Name, 'Vegetation') ~ 'Plant Structure',
                              TRUE ~ Material))


sw <- combined_file %>%
  filter(str_detect(Metadata_Type, 'Surface water'))

gw <- combined_file %>%
  filter(str_detect(Metadata_Type, 'Ground water'))

soil <-  combined_file %>%
  filter(str_detect(Metadata_Type, 'Soil'))


write_csv(sw, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/v2_PRT_SurfaceWater_Isotopes.csv",
          append = T,
          col_names = F)

write_csv(gw, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/v2_PRT_Groundwater_Isotopes.csv",
          append = T,
          col_names = F)

write_csv(soil, 
          "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package_v2/v2_PRT_Data_Package/v2_PRT_Sample_Data/PRT_Soil_Isotopes.csv",
          append = T,
          col_names = F)


