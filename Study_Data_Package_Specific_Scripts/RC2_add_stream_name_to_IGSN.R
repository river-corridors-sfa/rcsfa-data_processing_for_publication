# ==============================================================================
#
# Match stream name to the site ID for RC2 site/parent IGSN registration
#
# Status: Complete. Unsure how to input and export as xls. Stream name info 
# copy and pasted over
#
# ==============================================================================
#
# Author: Brieanne Forbes
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

# read in site master sheet and filter out unnecessary columns
sites <- read_csv('C:/Brieanne/022522_all_sites_NHD_streamline_matched_v2.csv') %>%
  select(site_ID, stream_nam)

# read in site IGSN
igsn <- read_csv('C:/Brieanne/template_1650385048_site.csv')


# ==================== join ====================

# match site ID and stream name, forgot to note the number of headers which
# explains the weird column names in the left_join
igsn <- igsn %>%
  left_join(sites, by = c('Object Type:'='site_ID'))

# ==================== write file ====================

# write file
write_csv(igsn, 'C:/Brieanne/stream_name.csv' )
