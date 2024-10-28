# ==============================================================================
#
# Match site ID to boat in St. Lawrence metadata
#
# Status: Complete 
#
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 19 May 2022
#
# ==============================================================================

library(tidyverse)
library(flextable)
library(lubridate)

# ================================= User inputs ================================

metadata <- read_csv('Z:/Campaign C/Hydropeaking_Network/WHONDRS_and_Non-WHONDRS_Data/03_Metadata/WHONDRS_STL_Metadata.csv', na = c('N/A', ''))

lookup <- read_csv('Z:/Campaign C/Hydropeaking_Network/WHONDRS_and_Non-WHONDRS_Data/03_Metadata/WHONDRS_STL_Metadata_boat_lookup.csv')

outfile <- 'Z:/Campaign C/Hydropeaking_Network/WHONDRS_and_Non-WHONDRS_Data/03_Metadata/WHONDRS_STL_Metadata_formatted.csv'

# ======================================= merge ================================

metadata$Site_Name <- gsub(',', '.', as.character(metadata$Site_Name))

merge <- metadata %>%
  left_join(lookup, by = c("Site_Name" = "Station")) %>%
  relocate("Sample ID", .after = 'Site_Name')

merge$`Sample ID` <- sprintf("%03d",merge$`Sample ID`)

merge$`Sample ID` <- paste('STL_', merge$`Sample ID`, sep = '')

merge_out <- merge %>%
  select(-c("Optional: sample ID group", "...15", "Latitude","Longitude" ))%>%
  rename(Sample_ID = 'Sample ID',
         Water_Color = "WaterColor",
         Shoreline_Photo = "Photo taken of shoreline?",
         Water_Color_Photo = "Photo taken of water color?",
         Latitude =  "Lat DD",
         Longitude =  "Long DD",
         Shore_Percent_Agriculture = Shore_Pct_Agriculture,
         Shore_Percent_Urban = Shore_Pct_Urban,
         Shore_Percent_Vegetation = Shore_Pct_Vegetation,
         Turbulance = 'Optional: turbulence of water',
         Water_Temperature = "Water_Temp") %>%
 mutate(Water_Color_Description = case_when(Water_Color %in% 'CBL' ~ 'Green_blue',
                                            Water_Color %in% 'TCH' ~ 'Dark_brown_chocolate',
                                            Water_Color %in% 'TGB' ~ 'Gray_brown',
                                            Water_Color %in% 'CCC' ~ 'Brown_coca-cola',
                                            Water_Color %in% 'TCH;TGB' ~ 'Dark_brown_chocolate_gray'),
        Turbidity = case_when(Water_Color %in% 'CBL' ~ 'Clear',
                                            Water_Color %in% 'TCH' ~ 'Turbid',
                                            Water_Color %in% 'TGB' ~ 'Turbid',
                                            Water_Color %in% 'CCC' ~ 'Clear',
                                            Water_Color %in% 'TCH;TGB' ~ 'Turbid')) %>%
  relocate(Water_Color_Description, .after = Water_Color)%>%
  relocate(Turbidity, .after = Water_Color_Description) %>%
  select(-Water_Color) %>%
  rename(Water_Color = Water_Color_Description)

# %>%
#  mutate(across(everything(), as.character))

merge_out$Time <- format(lubridate::parse_date_time(merge_out$Time, c('HMS', 'HM')), '%H:%M')
merge_out$Date <- mdy(merge_out$Date)

merge_out$Boat <- paste(merge_out$Boat, 'Boat', sep = '_')

# header <- read_csv('Z:/Campaign C/Hydropeaking_Network/WHONDRS_and_Non-WHONDRS_Data/03_Metadata/WHONDRS_STL_Metadata.csv') %>%
#   filter(row_number() == 1)
# 
# header <- header %>%
#   select(-c("Optional: sample ID group", "...15", "Latitude","Longitude" ))%>%
#   rename(Water_Color = "WaterColor",
#          Shoreline_Photo = "Photo taken of shoreline?",
#          Water_Color_Photo = "Photo taken of water color?",
#          Latitude =  "Lat DD",
#          Longitude =  "Long DD",
#          Shore_Percent_Agriculture = Shore_Pct_Agriculture,
#          Shore_Percent_Urban = Shore_Pct_Urban,
#          Shore_Percent_Vegetation = Shore_Pct_Vegetation,
#          Turbulance = 'Optional: turbulence of water',
#          Water_Temperature = "Water_Temp") %>%
#   mutate(across(everything(), as.character))
# 
# merge_out <- merge_out  %>%
#   add_row(header, .before = 1)


write_csv(merge_out, outfile, na = 'N/A')
