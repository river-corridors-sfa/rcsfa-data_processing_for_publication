# ==============================================================================
# format SSS data in the Goldman format for publishing to ESS-DIVE
#
# Status: In progress. 
# ==============================================================================
#
# Author: Brieanne Forbes 
# 1 March 2023
#
# ==============================================================================

library(tidyverse)


# ================================= User inputs ================================

baro_hobo_in <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/SSS_Data_Processing/2 - SSS_BaroTROLL_HOBO_Trimmed/'
  
baro_out <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/08_AtmosphericPressure/04_PublishReadyData/'
  
hobo_out <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/09_HOBO/04_PublishReadyData/'

minidot_in <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/04_Minidot/03_ProcessedData/'

minidot_out <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/04_Minidot/05_PublishReadyData/'

metadata <- read_csv('C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/06_Metadata/SSS_Metadata_Deploy_Sample_Retrieve_2023-03-03.csv')%>%
  mutate(Site_ID = case_when(Site_ID == 'S63P' ~ 'S63',
                             Site_ID == 'S55' ~ 'S55N',
                             Site_ID == 'S56' ~ 'S56N',
                             Site_ID == 'T41' ~ 'T42',
                             TRUE ~ Site_ID)) # fix site id errors

header_rows <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/13_DataPackage_Files/SSS_Sensor_HeaderRows.csv'

# ================================ format baro ==============================

baro_hobo_files <- list.files(baro_hobo_in, '.csv', full.names = T)

baro_headers_filter <- header_rows %>% 
  read_csv(skip = 1) %>%
  filter(InstallationMethod_ID == 'TreeRope_01')%>%
  filter(Sensor == 'BaroTroll')

baro_extrap_headers <- header_rows %>% 
  read_csv(skip = 1) %>%
  filter(InstallationMethod_ID == 'BaroExtrap_01')%>%
  filter(Sensor == 'BaroTroll')


for (baro in baro_hobo_files) {
  
  site <- unlist(str_split(baro, '_')) [7]
  
  parent_id <- metadata %>%
    filter(Site_ID == site) %>%
    select(Site_Vial_ID) %>%
    pull()
  
  baro_data <- read_csv(baro) %>% 
    select(Date_Time, BaroTROLL_Barometric_Pressure_mBar, BaroTROLL_Temperature_degC) %>%
    rename(DateTime = Date_Time,
           Pressure = BaroTROLL_Barometric_Pressure_mBar,
           Air_Temperature = BaroTROLL_Temperature_degC) %>%
    add_column(Parent_ID = parent_id,
               Site_ID = site, 
               .after = 'DateTime') %>%
    mutate(DateTime = as.character(paste0(" ", lubridate::as_datetime(DateTime))),
           Pressure = round(Pressure, 1),
           Air_Temperature = round(Air_Temperature, 3)) 
  
  if (site %in% c('S18R', 'S29', 'S34R', 'S39', 'S42', 'S48R', 'S56', 'T05P', 'W10')){
    
    baro_headers <- baro_headers_filter %>%
      mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
      select(full_header) %>% 
      add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
      add_row(full_header = '# HeaderRows_6', .before = 1)
    
  } else{
    
    baro_headers <- baro_extrap_headers %>%
      mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
      select(full_header) %>% 
      add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
      add_row(full_header = '# HeaderRows_6', .before = 1)
  }
  

  
  baro_file_name <- paste0(baro_out, parent_id, "_Air_Press_Temp.csv")
  
  write_csv(baro_headers, baro_file_name ,col_names = F)
  
  write_csv(baro_data, baro_file_name, append = T, col_names = T)
}
  
  # ================================ format hobo ==============================
  
  hobo_headers_filter <- header_rows %>% 
    read_csv(skip = 1) %>%
    filter(Sensor == 'Hobo')
  
  
  for (hobo in baro_hobo_files) {
    
    site <- unlist(str_split(hobo, '_')) [7]
    
    parent_id <- metadata %>%
      filter(Site_ID == site) %>%
      select(Site_Vial_ID) %>%
      pull()
    
    hobo_data <- read_csv(hobo) %>% 
      select(Date_Time, HOBO_Temperature_degC, HOBO_Absolute_Pressure_Adjust_mbar) %>%
      rename(DateTime = Date_Time,
             Absolute_Pressure = HOBO_Absolute_Pressure_Adjust_mbar,
             Temperature = HOBO_Temperature_degC) %>%
      add_column(Parent_ID = parent_id,
                 Site_ID = site, 
                 .after = 'DateTime') %>%
      mutate(DateTime = as.character(paste0(" ",lubridate::as_datetime(DateTime))),
             Absolute_Pressure = round(Absolute_Pressure, 1),
             Temperature = round(Temperature, 3))
    
    hobo_headers <- hobo_headers_filter %>%
      mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
      select(full_header) %>% 
      add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
      add_row(full_header = '# HeaderRows_6', .before = 1)
    
    hobo_file_name <- paste0(hobo_out, parent_id, "_Water_Press_Temp.csv")
    
    write_csv(hobo_headers, hobo_file_name ,col_names = F)
    
    write_csv(hobo_data, hobo_file_name, append = T, col_names = T)
    
  }


# ================================ format minidot ==============================

minidot_headers_filter <- header_rows %>% 
  read_csv(skip = 1) %>%
  filter(Sensor == 'Minidot' & InstallationMethod_ID == 'Minidot_03')

miniwiper_headers_filter <- header_rows %>% 
  read_csv(skip = 1) %>%
  filter(Sensor == 'Minidot' & InstallationMethod_ID == 'Minidot_04')

minidot_files <- list.files(minidot_in, 'trimmed', full.names = T)


for (minidot in minidot_files) {
  
  site <- unlist(str_split(minidot, '_')) [5]
  
  parent_id <- metadata %>%
    filter(Site_ID == site) %>%
    select(Site_Vial_ID) %>%
    pull()
  
  minidot_data <- read_csv(minidot) %>% 
    select(DateTime, BV_volt, Temp_degC, DO_mg_l, DO_perc_sat) %>%
    rename(Battery = BV_volt,
           Temperature = Temp_degC,
           Dissolved_Oxygen = DO_mg_l,
           Dissolved_Oxygen_Saturation = DO_perc_sat) %>%
    mutate(DateTime = as.character(paste0(" ",lubridate::as_datetime(DateTime))),
           Battery = round(Battery, 2),
           Temperature = round(Temperature, 2),
           Dissolved_Oxygen = round(Dissolved_Oxygen, 3),
           Dissolved_Oxygen_Saturation = round(Dissolved_Oxygen_Saturation, 2)) %>%
    add_column(Site_ID = site, .before = 'DateTime') %>%
    add_column(Parent_ID = parent_id, .before = 'Site_ID')
  
  if (site %in% c('S22RR', 'S23', 'S24', 'S29', 'S31', 'S32', 'S34R', 'S36', 
                  'S41R', 'S43', 'S49R', 'S50P', 'S51', 'S54', 'S55', 'S56', 
                  'S57', 'S58', 'T02', 'T03', 'T07', 'T41', 'U20', 'W10', 'W20')){
    
    minidot_headers <- miniwiper_headers_filter %>%
      mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
      select(full_header) %>% 
      add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
      add_row(full_header = '# HeaderRows_8', .before = 1)
    
  } else{
  
  minidot_headers <- minidot_headers_filter %>%
    mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
    select(full_header) %>% 
    add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
    add_row(full_header = '# HeaderRows_8', .before = 1)
  }
  
  minidot_file_name <- paste0(minidot_out,'v2_', parent_id, "_Water_DO_Temp.csv")
  
  write_csv(minidot_headers, minidot_file_name ,col_names = F)
  
  write_csv(minidot_data, minidot_file_name, append = T, col_names = T)
  
}
