# ==============================================================================
#
# Seperate and clean NVY metadata
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 21 Sept 2026
#
# ==============================================================================
library(tidyverse) 
library(gsheet)

rm(list=ls(all=T))

# =================================== user input ===============================

link <- 'https://docs.google.com/spreadsheets/d/1l_XU8p9xLVrpHK64YGDomkDvB_FBz0-pfENI2qAiVqo/edit?usp=drive_link'

# =================================== read in gsheets ==========================

metadata <- gsheet2tbl(link) %>%
  select(-Timestamp, -Polygon_ID, -Reference_Distance_A, -Reference_Distance_B, -Distance_to_Sensors...63) %>%
  rename(Distance_to_Sensors = Distance_to_Sensors...62) %>%
  mutate(
    Latitude = as.numeric(str_remove(Latitude, "^\\[[^]]+\\]\\s*")),
    Longitude = as.numeric(str_remove(Longitude, "^\\[[^]]+\\]\\s*"))) %>%
  mutate(
    across(
      c(Time_Arriving_PST, Time_Leaving_PST),
      ~ stringr::str_extract(.x, "\\d{1,2}:\\d{2}")
    )
  ) %>%
  mutate(GPS_Accuracy_ft = na_if(GPS_Accuracy_ft, -9999),
         Field_Crew = str_replace_all(Field_Crew, ",", ";"),
         Field_Crew = str_replace(Field_Crew, "Justice", "Justice Saxby"),
         Field_Crew = str_replace(Field_Crew, "Grace and Alejandro", "Grace Tiegs; Alejandro Jivanjee")) %>%
  group_by(Site_ID) %>%
  fill(GPS_Accuracy_ft, .direction = "down") %>%
  ungroup() %>%
  mutate(Date = as.character(str_c(' ', Date)),
         across(contains(c("Date", "Time")), ~ replace_na(as.character(.x), "-9999")),
         across(contains(c("SN", "Weather")), ~ ifelse(.x == "-9999", "N/A", .x)),
         across(where(is.character), ~ ifelse(is.na(.x), "N/A", .x)),
         across(where(is.numeric), ~ ifelse(is.na(.x), -9999, .x)))

# =================================== game cam ==========================

game_cam_clean <- metadata %>%
  select(Site_ID, Date, Time_Arriving_PST, Time_Leaving_PST, Latitude, Longitude, 
         GPS_Accuracy_ft, Field_Crew, Weather, River_Width, Depth_At_Sensor_cm, 
         matches("^Point_[A-E]_Depth_cm$"), contains('GameCamera'), Distance_to_Reference, 
         Distance_to_Sensors, Reference_Object, Water_Status, Notes)

write_csv(game_cam_clean, 'Z:/00_ESSDIVE/01_Study_DPs/NVY_GameCamera_Data_Package/NVY_GameCamera_Data_Package/NVY_GameCamera_Field_Metadata_new.csv')
