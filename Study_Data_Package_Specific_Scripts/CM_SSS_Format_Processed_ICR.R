# ==============================================================================
#
# Format CM/SSS processed ICR data
#
# Status: In progress
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

dir <- 'C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/PRELIMINARY_Core-MS_Processed_ICR_Legacy_Data'

out_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR'

# ================================= get files ================================

cm_data <- list.files(dir, 'CM.*Data',full.names = T, recursive = T) %>%
  read_csv()

sss_data <- list.files(dir, 'SSS.*Data',full.names = T, recursive = T) %>%
  read_csv()

data <- cm_data %>%
  full_join(sss_data)

cm_mol <- list.files(dir, 'CM.*Mol.csv',full.names = T, recursive = T) %>%
  read_csv()

sss_mol <- list.files(dir, 'SSS.*Mol.csv',full.names = T, recursive = T) %>%
  read_csv()

mol <- cm_mol %>%
  bind_rows(sss_mol)

cm_calib <- list.files(dir, 'CM.*Calibration',full.names = T, recursive = T)%>%
  read_csv()

sss_calib <- list.files(dir, 'SSS.*Calibration',full.names = T, recursive = T)%>%
  read_csv()

calib <- cm_calib %>%
  bind_rows(sss_calib)

# ============================ fix names ==========================

data_formatted <- data %>%
  select(-`SSS025_SED-3_p075.corems`) %>% # remove because there was a rerun
  rename_with(~ str_remove(.x, "\\.corems")) %>% # remove ".corems" from sample names
  rename_with(~ str_remove(.x, "_[^_]*$")) %>% # remove IAT from sample names
  rename(Calibrated_Mass = `Calibrated m/z`) %>% 
  mutate_all(~replace_na(., 0))


mol_formatted <- mol %>%
  select(-`Molecular Formula`) %>%
  rename(Calibrated_Mass = `Calibrated m/z`,
        Is_Isotopologue = `Is Isotopologue`,
        Heteroatom_Class = `Heteroatom Class`,
        Calculated_Mass = `Calculated m/z`,
        Error_ppm = `m/z Error (ppm)`) %>%
  mutate_all(function(x) if(is.numeric(x)) ifelse(is.na(x), -9999, x) else ifelse(is.na(x), 'N/A', x))

calib_formatted <- calib %>%
  rename(Sample_Name = Sample,
         Calibration_Points = "Cal. Points",
         Calibration_Threshold = "Cal. Thresh.",
         Calibration_RMSE =  'Cal. RMS Error (ppm)',
         Calibration_Order = "Cal. Order" )%>% 
  mutate(Sample_Name = str_remove(Sample_Name, "_[^_]*$")) # remove IAT from sample names
  

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

# returns none, meaning the lists match
anti_join(processed, xml)

# ============================ write files ==========================

write_csv(sed_data, 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/CM_SSS_Sediment_Core-MS_Processed_ICR_Data.csv')

write_csv(water_data, 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/CM_SSS_Water_Core-MS_Processed_ICR_Data.csv')

write_csv(sed_calib, 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/CM_SSS_Sediment_Core-MS_Processed_ICR_Calibration.csv')

write_csv(water_calib, 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/CM_SSS_Water_Core-MS_Processed_ICR_Calibration.csv')

write_csv(mol_formatted, 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/FTICR/CM_SSS_Core-MS_Processed_ICR_Mol.csv')
