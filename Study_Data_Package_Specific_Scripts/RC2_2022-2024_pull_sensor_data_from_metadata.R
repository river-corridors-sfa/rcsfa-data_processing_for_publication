# ==============================================================================
#
# Pull Temporal 2022-2024 sensor data from the metadata
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 20 May 2025
#
# ==============================================================================

library(tidyverse)
library(gsheet)

# =============================== User inputs ==================================

metadata_link <- 'https://docs.google.com/spreadsheets/d/1xJ0lxSHbDck8L_9VOvaLdQLKGIPG0MYZKUKd5KeM6Zs/edit?usp=sharing'

dp_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2022-2024_SensorData/RC2_TemporalStudy_2022-2024_SensorData/'

# =============================== read in metadata ==============================

metadata <- read_csv(construct_download_url(metadata_link), skip = 1) %>% 
  select(where(~ !all(is.na(.)))) %>%
  select(`Location...2`, `Site_Vial_ID_(4_digit_numeric_code)`, `Date_[mm/dd/yyyy]...4`,
         `Manta_Time_Turned_On_[24_hr_hh:mm]...30`,
         `Manta_Start_Time_[24_hr_hh:mm]...31`,`Manta_End_Time_[24_hr_hh:mm]...32`, `Manta_Time_Turned_Off_[24_hr_hh:mm]...33`,
         `Manta_Serial_Number...34`, `BaroTROLL_Time_Turned_On_[24-hr_hh:mm]...35`,`BaroTROLL_Start_Time_[24_hr_hh:mm]...36`,
         `BaroTroll_End_Time_[24_hr_hh:mm]...37`, `BaroTroll_Time_Turned_Off_[24_hr_hh:mm]...38`,
         `BaroTroll_Serial_Number...39`, YSI_Serial_Number,
         `SpC_[uS/cm]-1`,`pH-1`,
          `TDS_[ppm]-1`,`Temperature_[degC]-1`,`SpC_[uS/cm]-2`,
         `pH-2`,`TDS_[ppm]-2`,`Temperature_[degC]-2`,
          `SpC_[uS/cm]-3`,`pH-3`,`TDS_[ppm]-3`,`Temperature_[degC]-3`,
         `Time_[24_hr_hh:mm]-1`,`Time_[24_hr_hh:mm]-2`,
          `Time_[24_hr_hh:mm]-3`,
         `YSI_Time_[24_hr_hh:mm]-1`,`YSI_Temperature_[degC]-1`,`YSI_[mmHg]-1`,
          `YSI_DO_[%Sat]-1`,`YSI_DO_[mg/L]-1`,`YSI_Time_[24_hr_hh:mm]-2`,
         `YSI_Temperature_[degC]-2`,`YSI_[mmHg]-2`,`YSI_DO_[%Sat]-2`,
         `YSI_DO_[mg/L]-2`
         ) %>%
  rename(Date = `Date_[mm/dd/yyyy]...4`,
         Site_Name = `Location...2`, 
         Sample_Name = `Site_Vial_ID_(4_digit_numeric_code)`,  
         Manta_Time_Turned_On = `Manta_Time_Turned_On_[24_hr_hh:mm]...30`,
         Manta_Start_Time = `Manta_Start_Time_[24_hr_hh:mm]...31`,
         Manta_End_Time = `Manta_End_Time_[24_hr_hh:mm]...32`,
         Manta_Time_Turned_Off = `Manta_Time_Turned_Off_[24_hr_hh:mm]...33`,
         Manta_SN = `Manta_Serial_Number...34`,
         BaroTROLL_Time_Turned_On = `BaroTROLL_Time_Turned_On_[24-hr_hh:mm]...35`,
         BaroTROLL_Start_Time_ = `BaroTROLL_Start_Time_[24_hr_hh:mm]...36`,
         BaroTroll_End_Time = `BaroTroll_End_Time_[24_hr_hh:mm]...37`,
         BaroTroll_Time_Turned_Off = `BaroTroll_Time_Turned_Off_[24_hr_hh:mm]...38`,
         BaroTroll_SN = `BaroTroll_Serial_Number...39`,
         YSI_SN = YSI_Serial_Number,
         Ultrameter_Specific_Conductance_1 = `SpC_[uS/cm]-1`,
         Ultrameter_pH_1 = `pH-1`,
         Ultrameter_Total_Dissolved_Solids_1 = `TDS_[ppm]-1`,
         Ultrameter_Temperature_1 = `Temperature_[degC]-1`,
         Ultrameter_Specific_Conductance_2 = `SpC_[uS/cm]-2`,
         Ultrameter_pH_2 = `pH-2`,
         Ultrameter_Total_Dissolved_Solids_2 = `TDS_[ppm]-2`,
         Ultrameter_Temperature_2 = `Temperature_[degC]-2`,
         Ultrameter_Specific_Conductance_3 = `SpC_[uS/cm]-3`,
         Ultrameter_pH_3 = `pH-3`,
         Ultrameter_Total_Dissolved_Solids_3 = `TDS_[ppm]-3`,
         Ultrameter_Temperature_3 = `Temperature_[degC]-3`,
         Ultrameter_Time_1 = `Time_[24_hr_hh:mm]-1`,
         Ultrameter_Time_2 = `Time_[24_hr_hh:mm]-2`,
         Ultrameter_Time_3 = `Time_[24_hr_hh:mm]-3`,
         YSI_Time_1 = `YSI_Time_[24_hr_hh:mm]-1`,
         YSI_Temperature_1 = `YSI_Temperature_[degC]-1`,
          # = `YSI_[mmHg]-1`,  # not included in year 1 dp
         YSI_Dissolved_Oxygen_Saturation_1 = `YSI_DO_[%Sat]-1`,
         YSI_Dissolved_Oxygen_1 = `YSI_DO_[mg/L]-1`,
         YSI_Time_2 = `YSI_Time_[24_hr_hh:mm]-2`,
         YSI_Temperature_2 = `YSI_Temperature_[degC]-2`,
          # = `YSI_[mmHg]-2`, # not included in year 1 dp
         YSI_Dissolved_Oxygen_Saturation_2 = `YSI_DO_[%Sat]-2`,
         YSI_Dissolved_Oxygen_2 = `YSI_DO_[mg/L]-2`) %>%
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
  mutate(Parent_ID = paste0('RC2_', Sample_Name), .after = 'Site_Name')  %>%
  select(-Sample_Name, -Site_Name)

baro_manta_metadata <- metadata %>%
  select(Site_ID, Parent_ID, Date, contains('Manta'), contains('BaroTroll'))
  
write_csv(baro_manta_metadata, 'Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2022-2024_SensorData/Baro_Manta_Metadata.csv')

# pressure is all -9999 bc ecosense probe doesnt measure preasure, okay to remove

ysi <- metadata %>%
  select(Site_ID, Parent_ID, Date, contains('YSI'))%>%
  select(Site_ID, Parent_ID, Date, contains('Time'), contains('Temp'), contains('Dissolved_Oxygen_Saturation'), contains('Dissolved_Oxygen'))

write_csv(ysi, paste0(dp_dir, 'RC2_2022-2024_YSI_EcoSense_Temp_DO.csv'))

ultra <- metadata %>%
  select(Site_ID, Parent_ID, Date, contains('Ultrameter')) %>%
  select(Site_ID, Parent_ID, Date, contains('Time'), contains('Specific_Conductance'), contains('pH'), contains('Total_Dissolved_Solids'), contains('Temp'))

write_csv(ultra, paste0(dp_dir, 'RC2_2022-2024_Ultrameter_SpC_pH_TDS_Temp.csv'))
