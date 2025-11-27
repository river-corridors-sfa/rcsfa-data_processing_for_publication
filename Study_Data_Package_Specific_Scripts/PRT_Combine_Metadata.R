# ==============================================================================
#
# Combining all of the metadata sheets for PRT
#
# Status: In progress
#
# next steps:
# - remove unnecessary columns 
# - reorder columns
# - add veg to combine
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
  rename(Parent_ID = GW_Parent_ID)

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

veg <- gsheet2tbl(veg_link)

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

# =================================== combine ==========================


combine <- deploy  %>%
  bind_rows(sw_exo) %>%
  bind_rows(gw) %>%
  bind_rows(precip)


combine_clean <- combine %>%
  # some columns were not included in later metadata because they do not change,
  # we want to populate these for all visits though so populating those
  group_by(Site_ID) %>%
  fill(Stream_Hydrogeomorphology, Stream_Gradient, .direction = "down") %>%
  ungroup() %>%
 # clean up lat/long
  mutate(Latitude = as.numeric(str_remove_all(Latitude, '\\[M01\\] |\\[M02\\] |\\[M03\\] |\\[SF01\\] |\\[NF01\\] ')),
         Longitude = as.numeric(str_remove_all(Longitude, '\\[M01\\] |\\[M02\\] |\\[M03\\] |\\[SF01\\] |\\[NF01\\] ')))
  # reorganize column headers
  



















