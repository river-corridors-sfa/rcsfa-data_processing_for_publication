# ==============================================================================
#
# Match parent IGSN to sample by site ID for IGSN sample registration
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
#
# ==============================================================================

library(tidyverse)
library(readxl)

# ================================= User inputs ================================

# read in parent IGSN file. Filter out unnecessary columns and rename IGSN to 
# Parent IGSN for easy merge
parent <- read_xls('Z:/IGSN/CM_IGSN_Site_Registered.xls', skip = 1) %>%
  select("Sample Name", "IGSN" ) %>%
  rename("Parent IGSN"="IGSN")

# read in sample IGSN spreadsheet, removing parent IGSN column so it can be added
# from "parent"
igsn <- read_xls('Z:/IGSN/CM_IGSN_Samples_ToBeRegistered.xls', skip = 1) %>%
  select(-"Parent IGSN")

headers <- read_xls('Z:/IGSN/CM_IGSN_Samples_ToBeRegistered.xls', n_max = 1, col_names = F)

# Sample IGSN spreadsheet output directory
igsn_out_dir <- ('Z:/IGSN/CM_IGSN_Samples_ToBeRegistered.csv')

# ==================================== join ====================================

#join by site ID and move column to correct placement
igsn_out <- igsn %>%
  left_join(parent, by = c('Locality' = 'Sample Name')) %>%
  relocate("Parent IGSN", .before = "Release Date")

#write headers
write_csv(headers, igsn_out_dir)

#write the file
write_csv(igsn_out, igsn_out_dir, na = '')

