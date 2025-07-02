### identify_coords_bounding_box.R #############################################
# Date Created: 2023-12-27
# Author: Bibi Powers-McCormack

# Objective: Input a df of coordinates and output a tibble that contains the corners of a rectangular bounding box

# Inputs:
# df with coordinates in columns "latitude" and "longitude"

# Outputs:
# tibble with corners of the bounding box


### Function ###################################################################

identify_coords_bounding_box <- function(coords_df) {
  
  # load libraries
  library(tidyverse)
  
  current_coords_df <- coords_df
  
  # select only coords cols
  current_coords_df <- current_coords_df %>% 
    select(latitude, longitude)
  
  # create skeleton output df
  coords_bounding_box <- tribble(
    ~position, ~latitude, ~longitude,
    "NW", max(current_coords_df$latitude), min(current_coords_df$longitude),
    "NE", max(current_coords_df$latitude), max(current_coords_df$longitude),
    "SE", min(current_coords_df$latitude), max(current_coords_df$longitude),
    "SW", min(current_coords_df$latitude), min(current_coords_df$longitude)
  )
  
  view(coords_bounding_box)
  return(coords_bounding_box)
  
}