# ==============================================================================
#
# Combining all of the metadata sheets for PRT
#
# Status: In progress
#
# next steps:
# - change pushpoints to 1, 2, 3 and add column to indicate where sample was taken
# - add veg metadata and combine
# - reorder columns 
# - split sensor, game cam, rain gauge into its own file
#
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
         Longitude = as.character(Longitude))

sw_exo <- gsheet2tbl(sw_exo_link) %>%
  mutate(Time_Arriving_PST = as.character(Time_Arriving_PST),
         Time_Leaving_PST = as.character(Time_Leaving_PST)) %>%
  rename(Casing_Angle_At_Deployment = Casing_Angle_Of_Redeployment)

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
  rename(Parent_ID = GW_Parent_ID)%>%
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
         Sample_Type = case_when(!is.na(Parent_ID) ~ 'Precipitation',
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

# veg <- gsheet2tbl(veg_link)

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
  bind_rows(gw) %>%
  bind_rows(precip)


combine_clean <- combine %>%
  # remove polygon ID
  select(-Polygon_ID) %>%
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
  )



# %>%
#   # calculate height of obstructions using hypotenuse, distance, and eye height (asumming Jake's eye height)
#   # introducing NA when horizontal is greter than hypoteneuse 
#   mutate(NE_Height_Tallest_Obstruction = sqrt(NE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object^2 - NE_Horizontal_Distance_Tallest_Obstruction^2) + 1.6,
#          SE_Height_Tallest_Obstruction = sqrt(SE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object^2 - SE_Horizontal_Distance_Tallest_Obstruction^2) + 1.6,
#          NW_Height_Tallest_Obstruction = sqrt(NW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object^2 - NW_Horizontal_Distance_Tallest_Obstruction^2) + 1.6,
#          SW_Height_Tallest_Obstruction = sqrt(SW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object^2 - SW_Horizontal_Distance_Tallest_Obstruction^2) + 1.6
#   ) %>%
#   select(-NE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
#          -SE_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
#          -NW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object,
#          -SW_Hypotenuse_Distance_From_Guage_To_Top_of_Tallest_Object)



















