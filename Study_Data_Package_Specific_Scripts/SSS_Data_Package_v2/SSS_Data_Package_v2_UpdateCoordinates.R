### SSS_Data_Package_v2_UpdateCoordinates.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: 2023-07-31 by Bibi Powers-McCormack
# Date Updated: 2023-08-21 by Bibi Powers-McCormack

# Objective: Using the geospatial data package (v2) as the source of truth, compare and update SSS coordinates


# Inputs: 
# Outputs: 


### FILE SET UP ##############################

# Load libraries
library(tidyverse)

# set working directory
getwd()

# Load functions


# Load data

# load v2 geospatial data; this will be the source of truth for all coordinates
geospatial_df_01 <- read_csv("./v2_RCSFA_Geospatial_Data_Package/v2_RCSFA_Geospatial_Site_Information.csv")

# load SSS data files that have site IDs and coordinates
sss_field_metadata_df_01 <- read_csv("./v2_SSS_Data_Package/v2_SSS_Field_Metadata.csv")

sss_igsn_df_01 <- read_csv("./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv", skip = 1)


### PREP SITE COORDINATES DFS ##############################


# extract complete list of coordinates from the 2 SSS data dfs
sss_field_metadata_df_02 <- sss_field_metadata_df_01 %>% 
  select(
    Site_ID,
    Latitude,
    Longitude,
    Sediment_Latitude,
    Sediment_Longitude
  ) %>% 
  distinct() %>% 
  rename(
    Latitude_Metadata = Latitude,
    Longitude_Metadata = Longitude,
    Sediment_Latitude_Metadata = Sediment_Latitude,
    Sediment_Longitude_Metadata = Sediment_Longitude
  )

sss_igsn_df_02 <- sss_igsn_df_01 %>% 
  select(
    Locality,
    Latitude,
    Longitude
  ) %>% 
  rename(
    Site_ID = Locality,
    Latitude_IGSN = Latitude,
    Longitude_IGSN = Longitude) %>% 
  distinct()

# extract distinct list of sites from SSS data

SSS_sites <- sss_field_metadata_df_02 %>% 
  distinct(Site_ID)

# extract list from geospatial, keeping only SSS sites
geospatial_df_02 <- geospatial_df_01 %>% 
  select(
    Site_ID,
    Latitude,
    Longitude
  ) %>% 
  filter(.$Site_ID %in% SSS_sites$Site_ID)

# export coordinates to manually plot on the Google Maps map
  # after I uploaded the coordinates to Google Maps, I deleted these 3 file out of the working directory (which is why you won't find them anywhere)
  # I plotted each of the 3 files as a separate layer and labeled by Site ID. I then zoomed into each point to confirm that all 3 files placed the coordinates in the same general vacinity. There were 48 sites.

write_csv(geospatial_df_02, paste0(Sys.Date(), "_geospatial_googlemapscomparison.csv"))
write_csv(sss_field_metadata_df_02, paste0(Sys.Date(), "_fieldmetadata_googlemapscomparison.csv"))
write_csv(sss_igsn_df_02, paste0(Sys.Date(), "_igsn_googlemapscomparison.csv"))


### COMPARE SITE COORDINATES ##############################

# After manually comparing on the map, I also ran rounding checks. I compared each of the 2 SSS dfs to the geospatial coordinates using the below script. I adjusted the digit = # value to be 2, 3, 4 and also compared without rounding to get an idea for how close the coordinatees are to each other and to see if there are any that I should return to check on the map.

# compare geospatial sites to field metadata
geospatial_vs_fieldmetadata_df_01 <- geospatial_df_02 %>% 
  # join field metadata to geospatial
  left_join(sss_field_metadata_df_02) %>% 
  
  # round all coordinates to 3 decimal points
  mutate(Latitude_Metadata = round(Latitude_Metadata, digits = 4),
         Longitude_Metadata = round(Longitude_Metadata, digits = 4),
         Latitude = round(Latitude, digits = 4),
         Longitude = round(Longitude, digits = 4)) %>%
  
  # determine if the lat long values between dfs are equal
  mutate(lat_equal = case_when(Latitude_Metadata == Latitude ~ TRUE, TRUE ~ FALSE),
         long_equal = case_when(Longitude_Metadata == Longitude ~ TRUE, TRUE ~ FALSE)) %>%
  
  # filter the df by removing all sites where the coordinates match
  filter(lat_equal != TRUE | long_equal != TRUE)



# compare geospatial sites to IGSN
geospatial_vs_igsn_df_01 <- geospatial_df_02 %>% 
  # join IGSN to geospatial
  left_join(sss_igsn_df_02) %>% 
  
  # round all coordinates to 3 decimal points
  mutate(Latitude_IGSN = round(Latitude_IGSN, digits = 4),
         Longitude_IGSN = round(Longitude_IGSN, digits = 4),
         Latitude = round(Latitude, digits = 4),
         Longitude = round(Longitude, digits = 4)) %>%
  
  # determine if the lat long values between dfs are equal
  mutate(lat_equal = case_when(Latitude_IGSN == Latitude ~ TRUE, TRUE ~ FALSE),
         long_equal = case_when(Longitude_IGSN == Longitude ~ TRUE, TRUE ~ FALSE)) %>%
  
  # filter the df by removing all sites where the coordinates match
  filter(lat_equal != TRUE | long_equal != TRUE)


### STATUS REPORT: COORDINATES THAT NEED TO BE CHANGED ##############################

# The SSS DP has 2 files with coordinates: v2_SSS_Field_Metadata.csv and v2_SSS_Metadata_IGSN-Mapping.csv
# The v2_SSS_Field_Metadata.csv file has 2 sediment locatoins that need to be updated to match the v2_SSS_Field_Metadata.csv location coordinates file
# The v2_SSS_Metadata_IGSN-Mapping.csv file has 2 sites that need to be updated to match the v2_SSS_Field_Metadata.csv locaiton coordinates file

# The coordinates in the IGSN df are incorrect for 2 sites and need to be updated to match the location coordinates listed in the field metadata
  # Site ID S15 in IGSN needs to be changed from 47.46363 -121.1073 to 47.3636 -121.1073
  # Site ID S47R in IGSN needs to be changed from 46.6674 -121.094 to 46.62141 -121.3027

# The sediment coordinates in the Field Metadata df are incorrect for 2 sites and need to be updated to match the location coordinates listed in the field metadata
  # Site ID S15 in the sediment location needs to be changed from 47.46361 -121.1073 to 47.36363 -121.1073
  # Site ID S47R in the sediment location needs to be changed from 46.66737 -121.094 to 46.62141 -121.3027

# Clean up global environment in preparation for making updates
rm(geospatial_df_01)
rm(geospatial_df_02)
rm(geospatial_vs_fieldmetadata_df_01)
rm(geospatial_vs_igsn_df_01)
rm(SSS_sites)



### UPDATE SITE COORDINATES ##############################

# update v2_SSS_Metadata_IGSN-Mapping.csv
sss_igsn_df_03 <- sss_igsn_df_01 %>% 
  mutate(
    
  # change latitudes
    Latitude = case_when((Locality == "S15" ~ 47.36363), 
                         (Locality == "S47R" ~ 46.62141),
                          TRUE ~ Latitude),
  # change longitudes
    Longitude = case_when((Locality == "S15" ~ -121.1073), 
                          (Locality == "S47R" ~ -121.3027),
                           TRUE ~ Longitude),
  
  # mutate to change column type by pasting a space in front of dates; doing this because excel turns these into a date format if there isn't a space. We want to keep it in this written format, so adding a sapce ahead to indicate that it's a character/text field (not date)                 
    Collection_Date = paste0(" ", Collection_Date))


# update v2_SSS_Field_Metadata.csv sediment column
sss_field_metadata_df_03 <- sss_field_metadata_df_01 %>% 
  mutate(
    
    # change sediment latitudes
    Sediment_Latitude = case_when((Site_ID == "S15" ~ 47.36363), 
                                  (Site_ID == "S47R" ~ 46.62141),
                                  (Site_ID == "S48R" ~ 46.64568),
                                  TRUE ~ Sediment_Latitude),
    # change sediment longitudes
    Sediment_Longitude = case_when((Site_ID == "S15" ~ -121.1073), 
                                   (Site_ID == "S47R" ~ -121.3027),
                                   (Site_ID == "S48R" ~ -121.2511),
                                   TRUE ~ Sediment_Longitude),
    
    # mutate to change column type by pasting a space in front of dates; doing this because excel turns these into a date format if there isn't a space. We want to keep it in this written format, so adding a sapce ahead to indicate that it's a character/text field (not date)                 
    Deploy_Date = paste0(" ", Deploy_Date),
    Sample_Date = paste0(" ", Sample_Date),
    Retrieve_Date = paste0(" ", Retrieve_Date))

# clean up global environment, removing all files that won't be exported
rm(sss_field_metadata_df_01)
rm(sss_field_metadata_df_02)
rm(sss_igsn_df_01)
rm(sss_igsn_df_02)



### EXPORT NEW .CSV FILES ############################## 

# read in SSS IGSN headers; doing this because these headers were skipped when initially reading in the file and we need to add this info back on when the file is exported
sss_igsn_headers_df_01 <- read_csv("./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv", col_names = FALSE) %>% 
  head(1)

# write out IGSN header file to same as input file path with version appended to it
write_csv(sss_igsn_headers_df_01, "./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv", col_names = FALSE, na = "")

# write out IGSN data to append to header
write_csv(sss_igsn_df_03, paste0("./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv"), col_names = TRUE, append = TRUE)


# write out field metadata (which doesn't have any header rows)
write_csv(sss_field_metadata_df_03, "./v2_SSS_Data_Package/v2_SSS_Field_Metadata.csv")

