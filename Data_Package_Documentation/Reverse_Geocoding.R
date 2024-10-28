# ==============================================================================
#
# Get city from lat/long
#
# Status: complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 9 Dec 2022
#
# ==============================================================================

library(tidygeocoder)
library(tidyverse)

# ================================= User inputs ================================

file <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_CM_Data_Package/WHONDRS_CM_Data_Package/WHONDRS_CM_Field_Metadata.csv'

# ================================= get address ================================

coords <- read_csv(file) %>%
  select(Sample_Kit_ID, Sample_Latitude, Sample_Longitude) %>%
  filter(str_detect(Sample_Kit_ID, 'SSS'))

rev <- coords %>%
  reverse_geocode(lat = Sample_Latitude, long = Sample_Longitude, method = 'osm')
