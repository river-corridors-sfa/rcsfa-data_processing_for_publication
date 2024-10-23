### resolve_CM_SSS_Site_IDs.R ##################################################
# Date Created: 2023-10-26
# Date Updated: 2023-10-30
# Author: Bibi Powers-McCormack
# Objective: Replace v3 Site_IDs with the Site_IDs in the google drive; check coordinates of each site afterwards to confirm; fix coords/site IDs accordingly; export new (corrected) version of v3 metadata

# Curation Notes
  # This script shouldn't need to be run agian. It now serves as documentation for what chagnes were made.   
  # The Google Drive has since been manually updated, so this script will no longer be able to complete the fixes as it had originally done. 
  # Any edits to the metadata should use the output fo this file as an input.

  # field_metadata_df_01 = field metadata updated with site IDs from google drive
  # field_metadata_df_02 = field metadata updated with corrected site IDs and coords after reviewing each site on the map

# Code that might be useful in other contexts
  # function for assessing coordinates could be adapted for other coordinate checks


### Prep #######################################################################

# load libraries
library(tidyverse)
library(gsheet) # used to load in google sheets
library(data.table) # for using fread
library(daff) # to compare dfs
library(sf) # for checking coords
library(mapview) # for checking coords
library(clipr) # to copy to clipboard

# load data
# load in google drive metadata
gd_metadata <- gsheet2tbl("https://docs.google.com/spreadsheets/d/14g_vLiGnF9vp9T9jlsbxFKLYB5TX6kF8N73WOvsBkiE/edit#gid=1075453003") %>% 
  .[1:114, ]

# load in v3 field metadata
field_metadata_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v3_CM_SSS_Data_Package\\v3_CM_SSS_Field_Metadata.csv"
field_metadata_filepath <- file.choose()
field_metadata <- read_csv(field_metadata_filepath)

# load model generated sites
model_generated_sites_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\model_generated_geospatial_locations__predicted_sites_ranking_CONUS_updated_no_dup_RAxyso.csv"
model_generated_sites_filepath <- file.choose()
model_generated_sites <- fread(model_generated_sites_filepath)


### Replace v3 Site_IDs with gd Site_IDs #######################################

# pull gd Site_ID and Parent_ID from gd
gd_df_01 <- gd_metadata %>% 
  select(Sample_Kit_ID, Site_ID) %>%  # keep only Parent_ID and Site_ID
  arrange(Sample_Kit_ID) %>%  # sort by Parent_ID
  rename(gd_Site_ID = Site_ID, # rename
         Parent_ID = Sample_Kit_ID)

# Replace v3 field metadata Site_IDs with gd Site IDs
field_metadata_df_01 <- field_metadata %>% 
  left_join(gd_df_01) %>% # join gd Site_IDs to v3
  select(1:15, gd_Site_ID, everything()) %>% 
  select(-Site_ID) %>% # drop v3 Site_IDs
  rename(Site_ID = gd_Site_ID)

### Prepare data for coordinate checks #########################################

# prepare v3 data
# see how many samples have mis-matched sample and minidot coords
sample_vs_minidot_coords <- field_metadata_df_01 %>% 
  select(Parent_ID, Site_ID, Sample_Latitude, Sample_Longitude, 
         miniDOT_Latitude, miniDOT_Longitude) %>% 
  mutate(match_lat = case_when(Sample_Latitude == miniDOT_Latitude ~ "they match!"),
         match_long = case_when(Sample_Longitude == miniDOT_Longitude ~ "they match!")) %>% 
  filter(is.na(match_lat) | is.na(match_long))

# select v3 cols for coordinate checks 
coordinate_checks_field_metadata <- field_metadata_df_01 %>% 
  select(Parent_ID, Site_ID, Sample_Latitude, Sample_Longitude)

# prepare "master" coords data
coordinate_checks_model <- model_generated_sites %>% 
  select(7, 2, 1) %>% # select only coords
  rename(Model_Site_ID = GL_id,
         Model_Latitude = lat,
         Model_Longitude = lon) %>% 
  mutate(Model_Site_ID = paste0("MP-", Model_Site_ID)) %>% # fix Site_ID
  arrange(Model_Site_ID)


### Coordinate Function ########################################################

# create function to assess model vs sample coordinate pairs
# this function requires the following dfs
  # coordinate_checks_model
  # coordinate_checks_field_metadata


assess_mapcoords <- function(df, Parent_ID) {
  current_parent_id <- Parent_ID
  
  # filter df to inputed site
  current_df <- df %>% 
    filter(Parent_ID == current_parent_id) %>% 
    print()
  
  # pull out Site_ID from given Parent_ID
  current_site <- current_df %>% 
    select(Site_ID) %>% 
    as.character()
  
  # extract matching Site_ID from model
  current_model_site <- coordinate_checks_model %>% 
    filter(Model_Site_ID == current_site)
  
  # separate out each coordinate pair
  coords_current_model <- st_as_sf(current_model_site, coords = c("Model_Longitude", "Model_Latitude"), crs = 4326)
  coords_model <- st_as_sf(coordinate_checks_model, coords = c("Model_Longitude", "Model_Latitude"), crs = 4326)
  coords_current_sample <- st_as_sf(current_df, coords = c("Sample_Longitude", "Sample_Latitude"), crs = 4326)
  coords_samples <- st_as_sf(coordinate_checks_field_metadata, coords = c("Sample_Longitude", "Sample_Latitude"), crs = 4326)
  
  # display map
  current_mapcoords <- 
    mapview(coords_model, col.regions = "blue", map.types = "Esri.WorldImagery") + 
    mapview(coords_samples, col.regions = "yellow", map.types = "Esri.WorldImagery", zcol = "Site_ID") +
    mapview(coords_current_model, col.regions = "green", map.types = "Esri.WorldImagery", zcol = "Model_Site_ID") +
    mapview(coords_current_sample, col.regions = "red", map.types = "Esri.WorldImagery", zcol = "Site_ID")
  
  return(current_mapcoords)
  
}

# map all model and sample together
coords_model <- st_as_sf(coordinate_checks_model, coords = c("Model_Longitude", "Model_Latitude"), crs = 4326)
coords_sample <- st_as_sf(coordinate_checks_field_metadata, coords = c("Sample_Longitude", "Sample_Latitude"), crs = 4326)
map <- 
  # mapview(coords_model, col.regions = "blue", zcol = "Model_Site_ID") +
  mapview(coords_sample, col.regions = "red", map.types = "USGS.USImageryTopo", zcol = "Parent_ID")
map


### Assess Coordinates #########################################################
# get list of parent IDs to assess
coordinate_checks_field_metadata %>% 
  select(Parent_ID) %>% 
  write_clip()

read_clip()

# assess each parent ID - good = the red point is closer to the green point than any blue points
# colors
  # blue = all model coords
  # yellow = all sites where sampling occured
  # red = the current site that's being investigated
  # green = the model site that has a matching MP Site_ID

assess_mapcoords(coordinate_checks_field_metadata, "CM_001") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_002") # 5 miles away - okay
assess_mapcoords(coordinate_checks_field_metadata, "CM_003") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_004") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_005") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_007") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_008") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_009") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_010") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_011") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_012") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_013") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_014") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_015") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_016") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_017") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_025") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_026") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_027") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_028") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_032") # 1000 miles apart; closer to MP-101583 - change this one
assess_mapcoords(coordinate_checks_field_metadata, "CM_033") # the next closest MP is next to another sample - change to SP-13
assess_mapcoords(coordinate_checks_field_metadata, "CM_034") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_035") # closer to MP-101735 - change this one
assess_mapcoords(coordinate_checks_field_metadata, "CM_037") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_038") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_039") # good - CM_026 is really close to this one and they share the same MP - okay that these are duplicated because this site was returned to (also sampled for CM_026)
assess_mapcoords(coordinate_checks_field_metadata, "CM_041") # closer to MP-101143 - switch these
assess_mapcoords(coordinate_checks_field_metadata, "CM_042") # closer to MP-101142 - switch these
assess_mapcoords(coordinate_checks_field_metadata, "CM_043") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_062") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_063") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_064") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_068") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_069") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_070") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_072") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_075") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_076") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_077") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_078") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_079") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_080") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_081") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_082") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_083") # closer to MP-102358 - change this one
assess_mapcoords(coordinate_checks_field_metadata, "CM_084") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_085") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_088") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_089") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_090") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_091") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_092") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_093") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_094") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_095") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_096") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_100") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_101") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_105") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_106") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_107") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_108") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_111") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_112") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_113") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_114") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_115") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_116") # good
assess_mapcoords(coordinate_checks_field_metadata, "CM_117") # good

# coordinate issues identified from assessment that need to be resolved
  # CM_104 needs coords checked - it's in asia. needs a neg added to long
  # CM_026 and CM_039* share the same MP # (MP-102338), should change *? - no change bc they forgot to collect sediment and went back
  # CM_032*, CM_035*, and CM_043 share the same MP # (MP-102063), should change *?
    # change CM_032 to MP-101583
    # change CM_035 to MP-101735
  # CM_033 - make this SP-13
    # CM_021 - make this MP-102464 (SP-10 will go bye-bye)
  # CM_083 - change to MP-102358
  # CM_041 and CM_042 MPs need to be switched
    # CM_041 changed to MP-101143
    # CM_042 changed to MP-101142


### Fix coordinates ############################################################

field_metadata_df_02 <- field_metadata_df_01 %>% 
  mutate(
    
    # fix Site IDs
    Site_ID = case_when(Parent_ID == "CM_032" ~ "MP-101583",
                        Parent_ID == "CM_035" ~ "MP-101735",
                        Parent_ID == "CM_033" ~ "SP-13",
                        Parent_ID == "CM_021" ~ "MP-102464",
                        Parent_ID == "CM_083" ~ "MP-102358",
                        Parent_ID == "CM_041" ~ "MP-101143",
                        Parent_ID == "CM_042" ~ "MP-101142",
                        TRUE ~ Site_ID),
    
    # fix Lats
    # no changes
    
    # fix Longs
    Sample_Longitude = case_when(Parent_ID == "CM_104" ~ -79.08539,
                                 TRUE ~ Sample_Longitude)
    )


### Clean up global environment ################################################
field_metadata <- field_metadata_df_02

# List all objects in the global environment
all_objects <- ls()

# Remove all objects except for "metadata" df
objects_to_remove <- setdiff(all_objects, "field_metadata")
rm(list = objects_to_remove)
rm(all_objects)
rm(objects_to_remove)



### Export corrected v3 Field Metadata #########################################

# export filepath
out_dir <- paste0("v3_CM_SSS_Field_Metadata_", Sys.Date(), ".csv")

# export
write_csv(field_metadata, out_dir)
  # after export, manually convert 2 date cols to chr and remove date from export

