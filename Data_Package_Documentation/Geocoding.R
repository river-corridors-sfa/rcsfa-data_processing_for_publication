# ==============================================================================
#
# Get coords from institution 
#
# Status: in progress
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 28 July 2023
#
# ==============================================================================

library(tidygeocoder)
library(tidyverse)

# ================================= User inputs ================================

file <- "C:/Users/forb086/Downloads/1000 Soils Institutions_EBG.csv"

# ================================= get coords ================================

data <- read_csv(file)

# coords <- geo(data$Institution, method = 'osm', full_results = T)

coords2 <- geo(data$institution, method = 'arcgis', full_results = T)

combine <- coords2 %>%
  select(address, lat, long) %>%
  add_column(data) %>%
  select(-address)

write_csv(combine, "C:/Users/forb086/Downloads/1000 Soils Institutions_EBG_Geocoded.csv")

