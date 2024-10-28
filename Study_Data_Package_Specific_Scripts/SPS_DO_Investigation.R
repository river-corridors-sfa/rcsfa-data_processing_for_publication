
minidot_files_dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/SFA_SpatialStudy_2021_SensorData_v3/v3_SFA_SpatialStudy_2021_SensorData/MinidotManualChamber/Data'

minidot_files <- list.files(minidot_files_dir, '.csv', recursive = T, full.names = T)

combined <- tibble(site = as.character(),
                   SN = as.numeric(),
                   # DO_Slope = as.character(),
                   bad_slope = as.numeric())

for (minidot_file in minidot_files) {
  
  data <- read_csv(minidot_file, comment = '#') %>%  
    mutate(unix = as.numeric(DateTime))
  
  lm <- lm(data$Dissolved_Oxygen ~ data$unix)
  
  slope <- summary(bad_lm)$coefficients[2]
  
  row <- tibble(site = unique(data$Site_ID),
                SN = unique(data$Minidot_SN),
                DO_Slope = slope)
  
  combined <- combined %>%
    add_row(row)
  
}

format <- combined %>%
  rename(Slope = bad_slope) %>%
  mutate(Slope_per_day = Slope*(24*60*60))


ERwc <- format %>%
  select(-SN) %>%
  group_by(site) %>%
  summarise(ERwc = mean(as.numeric(Slope_per_day), na.rm = T))

write_csv(ERwc, 'Z:/RC2/04_Spatial_Study_2021/Water_Column_Respiration_Re-Workup/SPS_ERwc_corrected.csv')
