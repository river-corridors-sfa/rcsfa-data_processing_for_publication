# ==============================================================================
#
# Check vial IDs in metadata to look for duplicates
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 29 April 2022
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

#read in metatdata and rename column with vial Id, removes na rows 
temporal_metadata <- read_csv('Z:/RC2/08_IGSN/Archive/RC2_temporal_metadata_with_siteID.csv') %>%
  rename('vial_ID' = 'Site_Vial_ID_(4_digit_numeric_code)') %>%
  filter(!is.na(vial_ID))

spatial_metadata <- read_csv('Z:/RC2/04_Spatial_Study/06_Metadata/RC2 Spatial Study (Responses) - Form Responses 1(updated 2022-02-01).csv')%>%
  rename('vial_ID' = 'Site_Vial_ID_(SPS_4_digit_numeric_code)') %>%
  filter(!is.na(vial_ID))


# ============================== find duplicates =============================

#returns a data frame with any vial ID that is listed more than once
temporal_duplicates <- temporal_metadata %>%
  group_by(vial_ID) %>%
  count()%>%
  filter(n != 1)

temporal_duplicates <- paste(temporal_duplicates$vial_ID, collapse = ', ')

spatial_duplicates <- spatial_metadata %>%
  group_by(vial_ID) %>%
  count()%>%
  filter(n != 1)

spatial_duplicates <- paste(spatial_duplicates$vial_ID, collapse = ', ')

#returns a message in console
if (temporal_duplicates %in% ""){
  print('No duplicates in temporal dataset')
} else {
  paste('Temporal Vial(s)', temporal_duplicates, 'is/are duplicated')
}

if (spatial_duplicates %in%  ""){
  print('No duplicates in spatial dataset')
} else {
  paste('spatial Vial', spatial_duplicates, 'is duplicated')
}


