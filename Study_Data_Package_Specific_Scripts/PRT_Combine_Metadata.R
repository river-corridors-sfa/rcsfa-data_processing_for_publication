# ==============================================================================
#
# Combining all of the metadata sheets for PRT
#
# Status: In progress
#
# next steps:
# - confirm guage isnt mispelled anywhere (guage)
# - add info about rain gauge obstructions to notes (peter wrote info, jake providing measurments)
# ==============================================================================
#
# Author: Brieanne Forbes 
# 26 Nov 2025
#
# ==============================================================================
library(tidyverse) 
library(gsheet)

rm(list=ls(all=T))

# =================================== user input ===============================
deploy_link <- 'https://docs.google.com/spreadsheets/d/1xlAzs6bjV7yzWHqEAK55cjWj595yzz9tsr6gIQSgeKU/edit?usp=sharing'

sw_exo_link <- 'https://docs.google.com/spreadsheets/d/1n1yLYtAyI73BNjFVA3Go1wVuilkccrc-v5yt16TROq4/edit?usp=sharing'

gw_link <- 'https://docs.google.com/spreadsheets/d/1AcYRmTxNxZz0q4p54kgZi9UMrXg8JxbhIXRwVlDkQFc/edit?usp=sharing'

precip_link <- 'https://docs.google.com/spreadsheets/d/1YZnEdO1S0yrEXd4kil20QWOb6YwpBZHCabcORfB9LDM/edit?usp=sharing'

veg_link <- 'https://docs.google.com/spreadsheets/d/1El9aFTLLs-ImZaouFSa2AHEv1__JtmAH2OLJAM53i8c/edit?usp=sharing'

# =================================== read in gsheets ==========================

deploy <- gsheet2tbl(deploy_link) %>%
  rename(Time_Arriving_PST = Time_Start_PST,
         Time_Leaving_PST = Time_End_PST,
         Casing_Angle_At_Deployment = Casing_Angle)%>%
  mutate(Latitude = as.character(Latitude),
         Longitude = as.character(Longitude),
         Metadata_Type = 'EXO and BaroTROLL deployment')

sw_exo <- gsheet2tbl(sw_exo_link) %>%
  rename(Casing_Angle_At_Deployment = Casing_Angle_Of_Redeployment,
         Metadata_Type = Sample_Type)%>%
  mutate(Time_Arriving_PST = as.character(Time_Arriving_PST),
         Time_Leaving_PST = as.character(Time_Leaving_PST),
         Metadata_Type = 'Surface water; EXO and BaroTROLL download') 

gw <- gsheet2tbl(gw_link) %>%
  mutate(Time_Arriving_PST = as.character(Time_Arriving_PST),
         Time_Leaving_PST = as.character(Time_Leaving_PST),
         # when input is "No change", make NA so fill can fill in last answer
         Terrain_Gradient = case_when(Terrain_Gradient == 'No change' ~ NA,
                                      TRUE ~ Terrain_Gradient),
         Vegetation = case_when(Vegetation == 'No change' ~ NA,
                                      TRUE ~ Vegetation),
         Latitude = as.character(Latitude),
         Longitude = as.character(Longitude)) %>%
  select(-'Click this to skip the spring/well section') %>%
  group_by(Site_ID) %>%
  fill(Terrain_Gradient, Vegetation, .direction = "down") %>%
  ungroup() %>%
  rename(Parent_ID = GW_Parent_ID,
         Metadata_Type = Sample_Type)%>%
  #change all US/MD/DS to Rep1/2/3
  rename_with(~ str_replace_all(.x, c("US" = "Rep1", "MS" = "Rep2", "DS" = "Rep3"))) %>%
  # add location of replicates for samples that were originally marked U/M/D 
  mutate(Rep1_Location = case_when(Date < '2025-12-11' ~ 'Upstream',
                                   TRUE ~ Rep1_Location),
         Rep2_Location = case_when(Date < '2025-12-11' ~ 'Midstream',
                                   TRUE ~ Rep2_Location),
         Rep3_Location = case_when(Date < '2025-12-11' ~ 'Downstream',
                                   TRUE ~ Rep3_Location))

precip <- gsheet2tbl(precip_link)%>%
  mutate(Time_Arriving_PST = as.character(Time_Arriving_PST),
         Time_Leaving_PST = as.character(Time_Leaving_PST),
         Latitude = as.character(Latitude),
         Longitude = as.character(Longitude),
         # when input is "No change", make NA so fill can fill in last answer
         Terrain_Gradient = case_when(Terrain_Gradient == 'No change' ~ NA,
                                      TRUE ~ Terrain_Gradient),
         Vegetation = case_when(Vegetation == 'No change' ~ NA,
                                TRUE ~ Vegetation),
         Metadata_Type = case_when(!is.na(Parent_ID) ~ 'Precipitation; Rain gauge download',
                                   is.na(Parent_ID) ~ 'Rain gauge deployment',
                                 TRUE ~ NA)) %>%
  select(-"Where there changes to the obstructions?") %>%
  rename(Precipitation_Sampler_Bottle1_Fullness = "Precipitation_Sampler_Bottle_Fullness [Bottle 1]",
         Precipitation_Sampler_Bottle2_Fullness = "Precipitation_Sampler_Bottle_Fullness [Bottle 2]",
         Precipitation_Sampler_Bottle3_Fullness = "Precipitation_Sampler_Bottle_Fullness [Bottle 3]",
         Precipitation_Sampler_Bottle4_Fullness = "Precipitation_Sampler_Bottle_Fullness [Bottle 4]",
         Precipitation_Sampler_Bottle5_Fullness = "Precipitation_Sampler_Bottle_Fullness [Bottle 5]"  ) %>%
  mutate(across(where(is.numeric), ~na_if(.x, -9999))) %>%
  group_by(Site_ID) %>%
  fill(Rain_Gauge_Height, 
       NE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object, 
       NE_Tallest_Object_Distance_From_Gauge,
       SE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
       SE_Tallest_Object_Distance_From_Gauge,
       SW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
       SW_Tallest_Object_Distance_From_Gauge,
       NW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
       NW_Tallest_Object_Distance_From_Gauge,
       Vegetation,
       Terrain_Gradient,
       .direction = "down") %>%
  ungroup()

veg <- gsheet2tbl(veg_link) %>% 
  rename_with(~ str_replace_all(.x, c(" \\[" = "_", "\\]" = "")))%>%
  rename(Time_Arriving_PST = Time_Start_PST,
         Time_Leaving_PST = Time_End_PST)%>%
  mutate(Time_Arriving_PST = as.character(Time_Arriving_PST),
         Time_Leaving_PST = as.character(Time_Leaving_PST)) %>%
  add_column(Metadata_Type = 'Vegetation')

# =================================== fix spc/temp ==========================
# move SW spc/temp from GW metadata to SW metadata

gw_sw <- gw %>%
  filter(!is.na(SW_Specific_Conductance),
         !is.na(SW_Water_Temperature),
         SW_Specific_Conductance != -9999,
         SW_Water_Temperature != -9999) %>%
  select(SW_Parent_ID, SW_Specific_Conductance, SW_Water_Temperature)

sw_exo <- sw_exo %>%
  left_join(gw_sw, 
            by = c('Parent_ID' = 'SW_Parent_ID')) %>%
  mutate(
    Specific_Conductance = coalesce(Specific_Conductance, SW_Specific_Conductance),
    Water_Temperature = coalesce(Water_Temperature, SW_Water_Temperature)
  ) %>%
  select(-SW_Specific_Conductance, -SW_Water_Temperature)

gw <- gw %>%
  select(-SW_Specific_Conductance, -SW_Water_Temperature)

rm(gw_sw)

# =================================== combine ==========================


combine <- deploy  %>%
  bind_rows(sw_exo) %>%
  group_by(Site_ID) %>%
  fill(Stream_Gradient, Stream_Hydrogeomorphology, .direction = "down") %>%
  ungroup() %>%
  bind_rows(gw) %>%
  bind_rows(precip) %>%
  bind_rows(veg)


combine_clean <- combine %>%
  # remove polygon ID, timestamp, and hypotenuse distances 
  # removing hypot. distances because we werent able to calculate height since horizontal was longer than hypot - probably due to error of range finder 
  select(-Polygon_ID, -Timestamp, 
         -NE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
         -SE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
         -SW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
         -NW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object
         ) %>%
  # some columns were not included in later metadata because they do not change,
  # we want to populate these for all visits though so populating those
  group_by(Site_ID) %>%
  fill(Stream_Hydrogeomorphology, Stream_Gradient, .direction = "down") %>%
  ungroup() %>%
 # clean up lat/long
  mutate(Latitude = as.numeric(str_remove_all(Latitude, '\\[M01\\] |\\[M02\\] |\\[M03\\] |\\[SF01\\] |\\[NF01\\] |\\[G01\\] |\\[G02\\] |\\[M01A\\] ')),
         Longitude = as.numeric(str_remove_all(Longitude, '\\[M01\\] |\\[M02\\] |\\[M03\\] |\\[SF01\\] |\\[NF01\\] |\\[G01\\] |\\[G02\\] |\\[M01A\\] '))) %>%
  # clean up column names
  rename(Surface_Water_Parent_ID = SW_Parent_ID,
         Camera_Height = Camera_Height_cm,
         Point_A_Depth = Point_A_Depth_cm,
         Point_B_Depth = Point_B_Depth_cm,
         Point_C_Depth = Point_C_Depth_cm,
         Point_D_Depth = Point_D_Depth_cm,
         Point_E_Depth = Point_E_Depth_cm,
         Depth_At_Sensor = Depth_At_Sensor_cm,
         Distance_Between_Sonde_and_Casing = Distance_Between_Sonde_and_Casing_cm,
         River_Width = River_Width_m,
         DO_Good_QC_Score = `Good_QC_Score [DO]`,
         fDOM_Good_QC_Score = `Good_QC_Score [fDOM]`,
         pH_Good_QC_Score = `Good_QC_Score [pH]`,
         SpC_Good_QC_Score = `Good_QC_Score [SpC]`,
         Turbidity_Good_QC_Score = `Good_QC_Score [Turbidity]`,
         NE_Horizontal_Distance_Tallest_Obstruction =  NE_Tallest_Object_Distance_From_Gauge,
         SE_Horizontal_Distance_Tallest_Obstruction =  SE_Tallest_Object_Distance_From_Gauge,
         NW_Horizontal_Distance_Tallest_Obstruction =  NW_Tallest_Object_Distance_From_Gauge,
         SW_Horizontal_Distance_Tallest_Obstruction =  SW_Tallest_Object_Distance_From_Gauge
         ) %>%
  # add in calibration info for deployment, all were lab calibrated (except M01) with the usual standard
  mutate(
    Calibration = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'Lab calibration', 
                            TRUE ~ Calibration),
    Probes_Calibrated = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'pH, SpC, DO, Turbidity, fDOM', 
                                  TRUE ~ Probes_Calibrated),
    across(ends_with('_Good_QC_Score'), 
           ~ case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'Yes', 
                       TRUE ~ .x)),
    pH_Standard = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'Fisher (4.01, 7.00, and 10.01)', 
                            pH_Standard == 'Fisher 7.00, 10.01' ~  'Fisher (7.00, 10.01)',
                            TRUE ~ pH_Standard),
    DO_Standard = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'Tap Water', 
                            TRUE ~ DO_Standard),
    SpC_Standard = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'YSI (1000 us/cm)', 
                             TRUE ~ SpC_Standard),
    fDOM_Standard = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'VWR (300 QSU/100 RFU)', 
                              TRUE ~ fDOM_Standard),
    Turbidity_Standard = case_when(Date %in% c('2024-11-16', '2024-11-17', '2024-11-18') ~ 'YSI (124 FNU)', 
                                   TRUE ~ Turbidity_Standard)
  ) %>%
  arrange(Date)
        

final_metadata <- combine_clean %>%
  select(Parent_ID, Metadata_Type, Site_ID, Date, Time_Arriving_PST, Time_Leaving_PST, Latitude, Longitude, GPS_Accuracy_ft,
         Field_Crew, Weather, Dominant_Sediment_Type, Water_Status, Canopy_Coverage, Macrophyte_Coverage,
         Algal_Mat_Coverage, Vegetation, Stream_Hydrogeomorphology, Stream_Gradient, 
         Ground_Coverage, Terrain_Gradient, River_Width, 
         Depth_At_Sensor, Point_A_Depth, Point_B_Depth, Point_C_Depth, Point_D_Depth, Point_E_Depth, 
         Specific_Conductance, Water_Temperature, Surface_Water_Parent_ID, Rep1_Specific_Conductance, Rep1_Water_Temperature, 
         Rep1_Side_of_Stream, Rep1_Horizontal_Distance_To_Stream_Edge, Rep1_Vertical_Distance_Stream_To_Ground, 
         Rep1_Sampling_Depth, Rep1_Depth_To_GW, Rep2_Specific_Conductance, Rep2_Water_Temperature, Rep2_Side_of_Stream, 
         Rep2_Horizontal_Distance_To_Stream_Edge, Rep2_Vertical_Distance_Stream_To_Ground, Rep2_Sampling_Depth, 
         Rep2_Depth_To_GW, Rep3_Specific_Conductance, Rep3_Water_Temperature, Rep3_Side_of_Stream, 
         Rep3_Horizontal_Distance_To_Stream_Edge, Rep3_Vertical_Distance_Stream_To_Ground, 
         Rep3_Sampling_Depth, Rep3_Depth_To_GW, Distance_Between_Rep1_and_Rep2, 
         Distance_Between_Rep2_and_Rep3, Rep1_Location, 
         Rep2_Location, Rep3_Location,  
         contains('Precipitation_Sampler'),
         contains('Site_ID_'),
         contains('Moisture_Conditions_'),
         contains('Surrounding_Burn_Severity_'),
         Notes)

final_sensor_metadata <- combine_clean %>%
  select(Site_ID, Date, Metadata_Type, EXO_Time_Start_PST, EXO_Time_End_PST, BaroTROLL_Time_Start_PST, BaroTROLL_Time_End_PST,
         Casing_Angle_At_Arrival, Casing_Angle_At_Deployment, Distance_Between_Sonde_and_Casing, 
         Sonde_SN, Wiper_SN, FDOM_SN, DO_SN, SpC_Temp_SN, Turbidity_SN, pH_SN, 
         BaroTROLL_SN, Calibration, Probes_Calibrated, pH_Good_QC_Score, 
         SpC_Good_QC_Score, DO_Good_QC_Score, Turbidity_Good_QC_Score, fDOM_Good_QC_Score, pH_Standard, 
         SpC_Standard, DO_Standard, Turbidity_Standard, fDOM_Standard,Rain_Gauge_Logger_SN, Rain_Gauge_Tipping_Bucket_SN, 
         Rain_Gauge_Height, Rain_Gauge_Time_Start_PST, Rain_Gauge_Time_End_PST, 
         NE_Horizontal_Distance_Tallest_Obstruction, SE_Horizontal_Distance_Tallest_Obstruction,  
         SW_Horizontal_Distance_Tallest_Obstruction, NW_Horizontal_Distance_Tallest_Obstruction,
         Notes ) %>%
  # filter out rows without sensor metadata
  filter(!Metadata_Type %in% c('Ground water - push points', 'Ground water - well', 'Ground water - spring', 'Precipitation; Rain gauge download', 'Vegetation'))

# Reminder: I will probably need to filter out early game cam metadata since the pics were bad,
# need to figure this out later 
final_game_cam_metadata <- combine_clean %>%
  select(Site_ID, Date, Metadata_Type, Game_Camera_SN, Camera_Height, Notes)

verify_split <- function(original_df, df1, df2, df3) {
  original_cols <- names(original_df)
  df1_cols <- names(df1)
  df2_cols <- names(df2)
  df3_cols <- names(df3)
  
  # Find shared columns between all three
  shared_all <- Reduce(intersect, list(df1_cols, df2_cols, df3_cols))
  
  # Find shared columns between pairs
  shared_df1_df2 <- setdiff(intersect(df1_cols, df2_cols), shared_all)
  shared_df1_df3 <- setdiff(intersect(df1_cols, df3_cols), shared_all)
  shared_df2_df3 <- setdiff(intersect(df2_cols, df3_cols), shared_all)
  
  # Find unique columns in each df
  all_shared <- c(shared_all, shared_df1_df2, shared_df1_df3, shared_df2_df3)
  df1_unique <- setdiff(df1_cols, c(df2_cols, df3_cols))
  df2_unique <- setdiff(df2_cols, c(df1_cols, df3_cols))
  df3_unique <- setdiff(df3_cols, c(df1_cols, df2_cols))
  
  # Check coverage
  all_split_cols <- c(df1_unique, df2_unique, df3_unique, all_shared)
  missing_cols <- setdiff(original_cols, all_split_cols)
  
  cat("=== SPLIT VERIFICATION ===\n")
  cat("Original columns:", length(original_cols), "\n")
  cat("DF1 columns:", length(df1_cols), "(", length(df1_unique), "unique)\n")
  cat("DF2 columns:", length(df2_cols), "(", length(df2_unique), "unique)\n")
  cat("DF3 columns:", length(df3_cols), "(", length(df3_unique), "unique)\n")
  cat("Shared across all 3:", length(shared_all), "\n")
  cat("Shared DF1-DF2:", length(shared_df1_df2), "\n")
  cat("Shared DF1-DF3:", length(shared_df1_df3), "\n")
  cat("Shared DF2-DF3:", length(shared_df2_df3), "\n\n")
  
  if (length(missing_cols) == 0) {
    cat("✅ ALL COLUMNS ACCOUNTED FOR!\n")
  } else {
    cat("❌ MISSING COLUMNS:", paste(missing_cols, collapse = ", "), "\n")
  }
  
  if (length(shared_all) > 0) {
    cat("\n📎 Shared across all 3:", paste(shared_all, collapse = ", "), "\n")
  }
  if (length(shared_df1_df2) > 0) {
    cat("📎 Shared DF1-DF2:", paste(shared_df1_df2, collapse = ", "), "\n")
  }
  if (length(shared_df1_df3) > 0) {
    cat("📎 Shared DF1-DF3:", paste(shared_df1_df3, collapse = ", "), "\n")
  }
  if (length(shared_df2_df3) > 0) {
    cat("📎 Shared DF2-DF3:", paste(shared_df2_df3, collapse = ", "), "\n")
  }
  
  return(list(
    missing = missing_cols,
    shared_all = shared_all,
    shared_df1_df2 = shared_df1_df2,
    shared_df1_df3 = shared_df1_df3,
    shared_df2_df3 = shared_df2_df3,
    df1_unique = df1_unique,
    df2_unique = df2_unique,
    df3_unique = df3_unique
  ))
}

# Run the verification with three data frames
result <- verify_split(combine_clean, final_metadata, final_sensor_metadata, final_game_cam_metadata)
