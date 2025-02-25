# ==============================================================================
#
# Format AV1 processed ICR data
#
# Status: Complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 18 Feb 2025
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

# ================================= User inputs ================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/PRELIMINARY_Core-MS_Processed_ICR_Legacy_Data/AV1_XML_120324'

out_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package/Sample_Data/FTICR'

# ================================= get files ================================

data <- list.files(dir, 'Data',full.names = T) %>%
  read_csv()

mol <- list.files(dir, 'Mol.csv',full.names = T) %>%
  read_csv()

calib <- list.files(dir, 'Calibration',full.names = T)%>%
  read_csv()

# ============================ fix names ==========================
# do we want to keep the IAT in the name?  okay to remove
# keep blks? keep
# okay to change first column name? yes but keep calbirated in name

data_formatted <- data %>%
  rename_with(~ str_remove(.x, "\\.corems")) %>% # remove ".corems" from sample names
  rename_with(~ str_remove(.x, "_[^_]*$")) %>% # remove IAT from sample names
  rename(Calibrated_Mass = `Calibrated m/z`) %>%
  select(-contains('AV1_003'))%>% # remove kits we arent publishing
  select(-contains('AV1_018'))



# not sure how to subset down sed/water? same file for
# need to figure out if I can rename to match other dps, at least make machine readable  
# sent message to bob/vgc
mol_formatted <- mol %>%
  select(-`Molecular Formula`) %>%
  rename(Calibrated_Mass = `Calibrated m/z`,
        Is_Isotopologue = `Is Isotopologue`,
        Heteroatom_Class = `Heteroatom Class`,
        Calculated_Mass = `Calculated m/z`,
        Error_ppm = `m/z Error (ppm)`) %>%
  mutate_all(function(x) if(is.numeric(x)) ifelse(is.na(x), -9999, x) else ifelse(is.na(x), 'N/A', x))

#keep IAT in sample name?  okay to remove
calib_formatted <- calib %>%
  rename(Sample_Name = Sample,
         Calibration_Points = "Cal. Points",
         Calibration_Threshold = "Cal. Thresh.",
         Calibration_RMSE =  'Cal. RMS Error (ppm)',
         Calibration_Order = "Cal. Order" )%>% 
  mutate(Sample_Name = str_remove(Sample_Name, "_[^_]*$")) %>% # remove IAT from sample names
  filter(!str_detect(Sample_Name, 'AV1_003'))%>% # remove kits we arent publishing
  filter(!str_detect(Sample_Name, 'AV1_018'))
  

# ============================ separate sed and water ==========================

sed_data <- data_formatted %>%
  select(Calibrated_Mass, contains('SED'))%>%
  filter(rowSums(.[, -1]) != 0) # filter out rows where all are 0 

water_data <- data_formatted %>%
  select(Calibrated_Mass, contains('ICR'))%>%
  filter(rowSums(.[, -1]) != 0) # filter out rows where all are 0 

sed_calib <- calib_formatted %>%
  filter(str_detect(Sample_Name, 'SED'))

water_calib <- calib_formatted %>%
  filter(str_detect(Sample_Name, 'ICR'))

# keeping one mol file, not splitting 

# ============================ compare to xml files ==========================

# all sed samples from each list are in the other
setequal(sed_data %>%select(-Calibrated_Mass)%>%colnames(),
        sed_calib$Sample_Name)

sed_xml <- list.files(paste0(out_dir, '/Sediment_XML_Files')) %>%
  str_remove("\\.xml")%>%
  str_remove("_[^_]*$")

processed <-  tibble(Sample_Name = sed_calib$Sample_Name)

xml <-  tibble(Sample_Name = sed_xml)

#returns none, meaning the lists match
anti_join(processed, xml)

# all water samples from each list are in the other
setequal(water_data %>%select(-Calibrated_Mass)%>%colnames(),
        water_calib$Sample_Name)

water_xml <- list.files(paste0(out_dir, '/Water_XML_Files')) %>%
  str_remove("\\.xml")%>%
  str_remove("_[^_]*$")

processed <-  tibble(Sample_Name = water_calib$Sample_Name)

xml <-  tibble(Sample_Name = water_xml)

# Good after removing AV1_003 and AV1_018 from the processed data
anti_join(processed, xml)

# ============================ write files ==========================

write_csv(sed_data, 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package/Sample_Data/FTICR/WHONDRS_AV1_Sediment_Core-MS_Processed_ICR_Data.csv')

write_csv(water_data, 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package/Sample_Data/FTICR/WHONDRS_AV1_Water_Core-MS_Processed_ICR_Data.csv')

write_csv(sed_calib, 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package/Sample_Data/FTICR/WHONDRS_AV1_Sediment_Core-MS_Processed_ICR_Calibration.csv')

write_csv(water_calib, 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package/Sample_Data/FTICR/WHONDRS_AV1_Water_Core-MS_Processed_ICR_Calibration.csv')

write_csv(mol_formatted, 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package/Sample_Data/FTICR/WHONDRS_AV1_Core-MS_Processed_ICR_Mol.csv')
