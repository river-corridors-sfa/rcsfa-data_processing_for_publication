### CM_SSS_metadata_check_coords.R #############################################
# Date Created: 2023-10-18
# Date Updated: 2023-10-25
# Author: Bibi Powers-McCormack
# Objective: Compare coordinates from field metadata with the coordinates identified by the model. Update field metadata based on errors noticed.

# Curation Notes
  # This script was created and run after *_metadata_curation.R
  # This script shouldn't need to be run again. It now serves as documentation for what changes were made. 
  # Any edits to the metadata should use the output of this file as an input. 

  # cm_sss_field_metadata = field metadata as pulled from the DP folder
  # cm_sss_field_metadata_v3_sites = field metadata filtered for the new sites (new = newly added since v2)
  # cm_sss_field_metadata_df_01 = full metadata after fixing Site_IDs or coords for 3 sites


# Code that might be useful in other contexts
  # function for assessing coordinates could be adapted for other coordinate checks


### Prepare Script #############################################################
library(tidyverse)
library(data.table) # for using fread
library(sf) # for checking coords
library(mapview) # for checking coords


# clear global environment 
rm(list = ls())



### Load Data ##################################################################
# load model generated sites
model_generated_Sites_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\model_generated_geospatial_locations.csv"
model_generated_sites_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\model_generated_geospatial_locations__predicted_sites_ranking_CONUS_updated_no_dup_RAxyso.csv"
model_generated_sites_filepath <- file.choose()
model_generated_sites <- fread(model_generated_sites_filepath)

# load CM SSS site metadata
cm_sss_field_metadata_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v3_CM_SSS_Data_Package\\v3_CM_SSS_Field_Metadata.csv"
cm_sss_field_metadata_filepath <- file.choose()
cm_sss_field_metadata <- read_csv(cm_sss_field_metadata_filepath)


### Create cleaned coordinate list ###################################

# clean up CM SSS

# filter for only new sites
cm_sss_field_metadata_v3_sites <- cm_sss_field_metadata %>% 
  filter(Sample_Date > "2023-04-24")

# confirm that sample and minidot coords are equal
cm_sss_field_metadata_v3_sites %>% 
  mutate(same_lat = case_when(Sample_Latitude == miniDOT_Latitude ~ TRUE),
         same_long = case_when(Sample_Longitude == miniDOT_Longitude ~ TRUE)) %>% 
  select(Parent_ID, same_lat, same_long) %>% 
  View() # all equal


# clean up model generated
model_coords_df_01 <- model_generated_sites %>% 
  select(7, 2, 1) %>% # select only coords
  rename(Site_ID = GL_id,
         Model_Latitude = lat,
         Model_Longitude = lon) %>% 
  mutate(Site_ID = paste0("MP-", Site_ID)) %>% # fix Site_ID
  arrange(Site_ID) %>% 
  filter(Site_ID %in% cm_sss_field_metadata_v3_sites$Site_ID) # filter model coords for only sites that were sampled at

# coordinate join
coordinate_pairs_df_01 <- cm_sss_field_metadata_v3_sites %>% 
  select(Parent_ID, Site_ID, Sample_Latitude, Sample_Longitude) %>% # grab only coords cols
  left_join(model_coords_df_01, by = "Site_ID") %>% # join model coords
  arrange(Site_ID) %>% 
  filter(!is.na(Model_Latitude)) # keep only coords that have model coords to compare to



### Coordinate Function ########################################################

# create function to assess model vs sample coordinate pairs
assess_mapcoords <- function(df, Site_ID) {
  current_site <- Site_ID
  
  # filter df to inputed site
  current_df <- df %>% 
    filter(Site_ID == current_site) %>% 
    print()
  
  # separate out each coordinate pair
  coords_model <- st_as_sf(current_df, coords = c("Model_Longitude", "Model_Latitude"), crs = 4326)
  coords_sample <- st_as_sf(current_df, coords = c("Sample_Longitude", "Sample_Latitude"), crs = 4326)
  
  # display map
  current_mapcoords <- 
    mapview(coords_model, col.regions = "green", map.types = "Esri.WorldImagery", zcol = "Site_ID") +
    mapview(coords_sample, col.regions = "yellow", map.types = "Esri.WorldImagery", zcol = "Site_ID")
  
  return(current_mapcoords)
  
}



### Assess Coordinates #########################################################
print(model_coords$Site_ID)

assess_mapcoords(coordinate_pairs_df_01, "MP-100019") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-100607") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-100607") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-100667") # 1 mile apart # okay
assess_mapcoords(coordinate_pairs_df_01, "MP-100981") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-100984") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-101276") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-101336") # 10 miles apart # okay
assess_mapcoords(coordinate_pairs_df_01, "MP-101584") # sampled in field? # brie told him to sample upstream - need to figure out which way is upstream # okay
assess_mapcoords(coordinate_pairs_df_01, "MP-101898") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-101929") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-102203") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-102321") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-102355") # 50 miles apart # this was supposed to be 102358, fix and check again
assess_mapcoords(coordinate_pairs_df_01, "MP-102420") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-102534") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-102602") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-102944") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-103021") # 50 miles apart # coordinates were wrong; correct coords from the physical metadata sheet are: 34.42521, -81.60461
assess_mapcoords(coordinate_pairs_df_01, "MP-103034") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-103224") # looks good
assess_mapcoords(coordinate_pairs_df_01, "MP-103380") # looks good
# add MP_101897 (fix underscore to dash)



### Fix Coordinates ############################################################

# fix coordinates and/or sites after talking with Brie
cm_sss_field_metadata_df_01 <- cm_sss_field_metadata %>% 
  mutate(Site_ID = case_when(Site_ID == "MP-102355" ~ "MP-102358", # fixes CM_083
                             Site_ID == "MP_101897" ~ "MP-101897", # fixes CM_112
                             TRUE ~ Site_ID),
         Sample_Latitude = case_when(Site_ID == "MP-103021" ~ 34.42521, TRUE ~ Sample_Latitude), # fixes coords for site CM_100
         Sample_Longitude = case_when(Site_ID == "MP-103021" ~ -81.60461, TRUE ~ Sample_Longitude), # fixes coords for site CM_100
         miniDOT_Latitude = case_when(Site_ID == "MP-103021" ~ 34.42521, TRUE ~ miniDOT_Latitude), # fixes coords for site CM_100
         miniDOT_Longitude = case_when(Site_ID == "MP-103021" ~ -81.60461, TRUE ~ miniDOT_Longitude)) # fixes coords for site CM_100


# confirm corrections

# join model coords based on updated Site_IDs
model_coords_df_02 <- model_generated_sites %>% 
  select(7, 2, 1) %>% # select only coords cols
  rename(Site_ID = GL_id,
         Model_Latitude = lat,
         Model_Longitude = lon) %>% 
  mutate(Site_ID = paste0("MP-", Site_ID)) %>% # fix Site ID naming
  arrange(Site_ID) %>% 
  filter(Site_ID %in% cm_sss_field_metadata_df_01$Site_ID) # filter model coords for only sites that were sampled at

# coordinate join again
coordinate_pairs_df_02 <- cm_sss_field_metadata_df_01 %>% 
  select(Parent_ID, Site_ID, Sample_Latitude, Sample_Longitude) %>% 
  left_join(model_coords_df_02, by = "Site_ID") %>% 
  arrange(Site_ID)

# assess updates sites
assess_mapcoords(coordinate_pairs_df_02, "MP-102358") # okay
assess_mapcoords(coordinate_pairs_df_02, "MP-103021") # looks good
assess_mapcoords(coordinate_pairs_df_02, "MP-101897") # looks good



### Export Metadata ############################################################
write_csv(cm_sss_field_metadata_df_01, paste0("v3_CM_SSS_Field_Metadata_", Sys.Date(),".csv"))

# after exporting, manually fixed the date formatting



