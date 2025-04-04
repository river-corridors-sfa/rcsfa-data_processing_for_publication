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

file <- "C:/Users/forb086/Downloads/MONet Project Report_March2025.csv"

# ================================= get coords ================================

data <- read_csv(file)

# coords <- geo(data$Institution, method = 'osm', full_results = T)

coords2 <- geo(data$Institution, method = 'arcgis', full_results = T)

combine <- coords2 %>%
  select(address, lat, long, score) %>%
  add_column(data) %>%
  rename(Institution = address)

write_csv(combine, "C:/Users/forb086/Downloads/MONet Project Report_March2025_Geocoded.csv")

