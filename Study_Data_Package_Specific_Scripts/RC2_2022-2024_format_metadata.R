# ==============================================================================
#
# Format Temporal field metadata for 2022-2024 data package
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 19 March 2025
#
# ==============================================================================

library(tidyverse)
library(gsheet)

# =============================== User inputs ==================================

metadata_link <- 'https://docs.google.com/spreadsheets/d/1xJ0lxSHbDck8L_9VOvaLdQLKGIPG0MYZKUKd5KeM6Zs/edit?usp=sharing'

dp_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2022-2024_SampleData/RC2_TemporalStudy_2022-2024_SampleData/'

# =============================== read in metadata ==============================

metadata <- read_csv(construct_download_url(metadata_link), skip = 1) %>% 
  select(where(~ !all(is.na(.)))) %>%
  select(`Location...2`, `Site_Vial_ID_(4_digit_numeric_code)`,  `Field_Staff_[first_name_last_name]...53`, 
         `Date_[mm/dd/yyyy]...4`,`Time_Zone...5`, `Time_Arriving_[24_hr_hh:mm]...6`, `Time_Leaving_[24_hr_hh_mm]...7`,
         `Latitude_[dd]`, `Longitude_[dd]`, 
         # `GPS_Accuracy_[ft]`, 
         # `Manta_Time_Turned_On_[24_hr_hh:mm]...30`,
         # `Manta_Start_Time_[24_hr_hh:mm]...31`,`Manta_End_Time_[24_hr_hh:mm]...32`, `Manta_Time_Turned_Off_[24_hr_hh:mm]...33`,
         # `Manta_Serial_Number...34`, `BaroTROLL_Time_Turned_On_[24-hr_hh:mm]...35`,`BaroTROLL_Start_Time_[24_hr_hh:mm]...36`,
         # `BaroTroll_End_Time_[24_hr_hh:mm]...37`, `BaroTroll_Time_Turned_Off_[24_hr_hh:mm]...38`, 
         # `BaroTroll_Serial_Number...39`, YSI_Serial_Number, 
         `Notes...51`
         ) %>%
  rename(Site_Name = `Location...2`, 
         Sample_Name = `Site_Vial_ID_(4_digit_numeric_code)`,  
         Field_Staff = `Field_Staff_[first_name_last_name]...53`, 
         Date =  `Date_[mm/dd/yyyy]...4`, 
         Time_Zone = `Time_Zone...5`,
         Time_Arriving = `Time_Arriving_[24_hr_hh:mm]...6`, 
         Time_Leaving = `Time_Leaving_[24_hr_hh_mm]...7`,
         Latitude = `Latitude_[dd]`, 
         Longitude =`Longitude_[dd]`, 
         # GPS_Accuracy = `GPS_Accuracy_[ft]`, 
         # Manta_Time_Turned_On = `Manta_Time_Turned_On_[24_hr_hh:mm]...30`,
         # Manta_Start_Time = `Manta_Start_Time_[24_hr_hh:mm]...31`,
         # Manta_End_Time = `Manta_End_Time_[24_hr_hh:mm]...32`, 
         # Manta_Time_Turned_Off = `Manta_Time_Turned_Off_[24_hr_hh:mm]...33`,
         # Manta_SN = `Manta_Serial_Number...34`, 
         # BaroTROLL_Time_Turned_On = `BaroTROLL_Time_Turned_On_[24-hr_hh:mm]...35`,
         # BaroTROLL_Start_Time_ = `BaroTROLL_Start_Time_[24_hr_hh:mm]...36`,
         # BaroTroll_End_Time = `BaroTroll_End_Time_[24_hr_hh:mm]...37`, 
         # BaroTroll_Time_Turned_Off = `BaroTroll_Time_Turned_Off_[24_hr_hh:mm]...38`, 
         # BaroTroll_SN = `BaroTroll_Serial_Number...39`, 
         # YSI_SN = YSI_Serial_Number, 
         Notes = `Notes...51`) %>%
  mutate(Date = mdy(Date),
         Site_ID = case_when(Site_Name == 'American River' ~ 'T06',
                             Site_Name == 'Little Naches' ~ 'T05P',
                             Site_Name == 'Naches- Craig Road 2' ~ 'T42',
                             Site_Name == 'Union Gap' ~ 'T03',
                             Site_Name == 'Mabton' ~ 'T02',
                             Site_Name == 'Kiona' ~ 'T07'),
         .before = everything()) %>%
  filter(Date > '2022-04-07') %>%
  mutate(Date = paste0(' ', Date))%>%
  mutate(Latitude = case_when(Site_Name == 'American River' ~ '46.97777',
                             Site_Name == 'Little Naches' ~ '46.98904',
                             Site_Name == 'Naches- Craig Road 2' ~ '46.72895',
                             Site_Name == 'Union Gap' ~ '46.530817',
                             Site_Name == 'Mabton' ~ '46.232095',
                             Site_Name == 'Kiona' ~ '46.255319'),
         Longitude = case_when(Site_Name == 'American River' ~ '-121.16953',
                              Site_Name == 'Little Naches' ~ '-121.09921',
                              Site_Name == 'Naches- Craig Road 2' ~ '-120.71431',
                              Site_Name == 'Union Gap' ~ '-120.470337',
                              Site_Name == 'Mabton' ~ '-119.999901',
                              Site_Name == 'Kiona' ~ '-119.47405'),
         Field_Staff = str_replace_all(Field_Staff, ',', ';'),
         Field_Staff = str_replace(Field_Staff, 'Erica_Bakker  Kali_Cornwell', 'Erica_Bakker; Kali_Cornwell'),
         Field_Staff = str_replace(Field_Staff, 'Erica_Bakker   Brianna_Gonzalez', 'Erica_Bakker; Brianna_Gonzalez'),
         Parent_ID = paste0('RC2_', Sample_Name), .after = 'Site_Name')  %>%
  select(-Sample_Name)
  
write_csv(metadata, paste0(dp_dir, 'RC2_Sample_2022-2024_Field_Metadata.csv'))
