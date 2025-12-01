# ==============================================================================
#
# Pull COMID for geospatial data package
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 1 Dec 2025
#
# ==============================================================================
require(pacman)
p_load(tidyverse,
       sf,
       nhdplusTools) 

rm(list=ls(all=T))
# =================================== user input ===============================
input <- "Z:/00_ESSDIVE/01_Study_DPs/Cross-RCSFA_Geospatial_Data_Package_v5/v5_comid_code_input.csv"

# =================================== find files ===============================
sites <- read_csv(input) %>%
  distinct(site, .keep_all = TRUE) %>%
  # dplyr::select('site','latitude','longitude') %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Get stream names and COMIDs
get_comid_and_name <- function(i) {
  point_geom <- st_sfc(sites$geometry[[i]], crs = st_crs(sites))
  comid_result <- discover_nhdplus_id(point = point_geom)
  
  if(length(comid_result) > 0 && !is.na(comid_result)) {
    flowline <- get_nhdplus(comid = comid_result, realization = "flowline")
    if(nrow(flowline) > 0) {
      gnis_name <- flowline$gnis_name[1]  # Changed to lowercase
    } else {
      gnis_name <- NA
    }
  } else {
    comid_result <- NA
    gnis_name <- NA
  }
  
  return(data.frame(comid = comid_result, gnis_name = gnis_name, stringsAsFactors = FALSE))
}

# Apply to all sites
results_df <- map_dfr(1:nrow(sites), get_comid_and_name)

# Final dataset
sites_final <- sites %>%
  mutate(
    longitude = st_coordinates(.)[,1],
    latitude = st_coordinates(.)[,2]
  ) %>%
  st_drop_geometry() %>%
  bind_cols(results_df) %>%
  mutate(check = case_when(is.na(comid) ~ NA,
                           TRUE ~ Physiographic_Feature_Name == gnis_name))

# if check == FALSE, go to https://epa.maps.arcgis.com/apps/webappviewer/index.html?id=074cfede236341b6a1e03779c2bd0692 
# to see if the COMID is incorrect

write_csv(sites_final, file.path(dirname(input), 'geospatial_output.csv'))



