# ==============================================================================
# format SSS sonar data in the Goldman format for publishing to ESS-DIVE
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

sonar_dir <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/10_Sonar/04_PublishReadyData/'

metadata <- read_csv('C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/06_Metadata/SSS_Metadata_Deploy_Sample_Retrieve_2023-03-03.csv')

header_rows <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/13_DataPackage_Files/SSS_Sensor_HeaderRows.csv'

# ================================ filter headers ==============================

kayak_header <- read_csv(header_rows, skip = 1) %>%
  filter(InstallationMethod_ID == 'Sonar_01')

kayak_header <- kayak_header %>%
  mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
  select(full_header) %>% 
  add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
  add_row(full_header = '# HeaderRows_11', .before = 1)

jetboat_header <- read_csv(header_rows, skip = 1) %>%
  filter(InstallationMethod_ID == 'Sonar_02')

jetboat_header <- jetboat_header %>%
  mutate(full_header = paste0("# ", Column_Header,"; ", Unit,"; ", InstallationMethod_ID,"; ", Instrument_Summary)) %>%
  select(full_header) %>% 
  add_row(full_header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary', .before = 1) %>% 
  add_row(full_header = '# HeaderRows_11', .before = 1)


# ================================ format S23 ==============================

s23G <- list.files(sonar_dir, '51G', full.names = T)

s23B <- list.files(sonar_dir, '53B|50B', full.names = T) 

S23B_data <- read_csv(s23B[1]) %>%
  add_row(read_csv(s23B[2])) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
         ) %>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS047',
             Site_ID = 'S23',
             .before = 'Time') %>% 
  arrange(Time)

S23G_data <- read_csv(s23G) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS047',
             Site_ID = 'S23',
             .before = 'Time')%>% 
  arrange(Time) %>%
  filter(Time < 4000000000)

write_csv(kayak_header, paste0(sonar_dir, 'SSS047_Water_Depth_Kayak1.csv'), col_names = F)

write_csv(S23B_data, paste0(sonar_dir, 'SSS047_Water_Depth_Kayak1.csv'), append = T, col_names = T)

write_csv(kayak_header, paste0(sonar_dir, 'SSS047_Water_Depth_Kayak2.csv'), col_names = F)

write_csv(S23G_data, paste0(sonar_dir, 'SSS047_Water_Depth_Kayak2.csv'), append = T, col_names = T)


# ================================ format S34R ==============================

S34RG <- list.files(sonar_dir, '00G', full.names = T)

S34RB <- list.files(sonar_dir, '59B', full.names = T) 

S34RB_data <- read_csv(S34RB) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS025',
             Site_ID = 'S34R',
             .before = 'Time')%>% 
  arrange(Time) 

S34RG_data <- read_csv(S34RG) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS025',
             Site_ID = 'S34R',
             .before = 'Time')%>% 
  arrange(Time) 

write_csv(kayak_header, paste0(sonar_dir, 'SSS025_Water_Depth_Kayak1.csv'), col_names = F)

write_csv(S34RB_data, paste0(sonar_dir, 'SSS025_Water_Depth_Kayak1.csv'), append = T, col_names = T)

write_csv(kayak_header, paste0(sonar_dir, 'SSS025_Water_Depth_Kayak2.csv'), col_names = F)

write_csv(S34RG_data, paste0(sonar_dir, 'SSS025_Water_Depth_Kayak2.csv'), append = T, col_names = T)


# ================================ format S36 ==============================

S36G <- list.files(sonar_dir, '56G', full.names = T)

S36B <- list.files(sonar_dir, '55B', full.names = T) 

S36B_data <- read_csv(S36B) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS026',
             Site_ID = 'S36',
             .before = 'Time')%>% 
  arrange(Time)  %>%
  filter(Time < 4000000000)

S36G_data <- read_csv(S36G) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS026',
             Site_ID = 'S36',
             .before = 'Time')%>% 
  arrange(Time) 

write_csv(kayak_header, paste0(sonar_dir, 'SSS026_Water_Depth_Kayak1.csv'), col_names = F)

write_csv(S36B_data, paste0(sonar_dir, 'SSS026_Water_Depth_Kayak1.csv'), append = T, col_names = T)

write_csv(kayak_header, paste0(sonar_dir, 'SSS026_Water_Depth_Kayak2.csv'), col_names = F)

write_csv(S36G_data, paste0(sonar_dir, 'SSS026_Water_Depth_Kayak2.csv'), append = T, col_names = T)

# ================================ format T02 ==============================

T02U <- list.files(sonar_dir, '12.48.46', full.names = T)

T02D <- list.files(sonar_dir, '14.47.29', full.names = T) 

T02D_data <- read_csv(T02D) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS014',
             Site_ID = 'T02',
             .before = 'Time')%>% 
  arrange(Time) 

T02U_data <- read_csv(T02U) %>%
  select(-gps_speed_kph) %>%
  rename(Time = time1,
         Framesize = framesize,
         GPS_Speed = gps_speed,
         Longitude_mercator = lon_enc,
         Latitude_mercator = lat_enc,
         Longitude = longitude,
         Latitude = latitude, 
         Water_Depth = water_depth_m
  )%>%
  mutate(GPS_Speed = round(GPS_Speed, 4),
         Water_Depth = round(Water_Depth, 4)) %>%
  add_column(Parent_ID = 'SSS014',
             Site_ID = 'T02',
             .before = 'Time')%>% 
  arrange(Time) %>%
  filter(Time < 4000000000)

write_csv(jetboat_header, paste0(sonar_dir, 'SSS014_Water_Depth_Downstream.csv'), col_names = F)

write_csv(T02D_data, paste0(sonar_dir, 'SSS014_Water_Depth_Downstream.csv'), append = T, col_names = T)

write_csv(jetboat_header, paste0(sonar_dir, 'SSS014_Water_Depth_Upstream.csv'), col_names = F)

write_csv(T02U_data, paste0(sonar_dir, 'SSS014_Water_Depth_Upstream.csv'), append = T, col_names = T)
