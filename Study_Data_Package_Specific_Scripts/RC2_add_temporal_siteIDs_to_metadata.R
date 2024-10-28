# ==============================================================================
#
# Match RC2 temporal site ID (from site master list) to location (from metadata).
# Metadata did not include actual site ID
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

# read in site master list and filter unnecesary columns and rows of NA
sites <- read_csv('Z:/RC2/mapping layers/022522_all_sites_NHD_streamline_matched_v2.csv') %>%
  select(site_ID, extra_name) %>%
  filter(!is.na(extra_name))
  
# read in metadata
metadata <- read_csv('Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/RC2_TemporalStudy_2021-2022_SensorData/RC2_TemporalStudy_2021-2022_SensorDataPackage/Field_Metadata.csv')

# output directory for metadata with site ID
metadata_outdir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/RC2_TemporalStudy_2021-2022_SensorData/RC2_TemporalStudy_2021-2022_SensorDataPackage/Field_Metadata_Site_ID_added.csv'

#output directory for list of temporal sites
#sites_outdir <- 'C:/Brieanne/RC2_temporal_sites.csv'

# ==================== rename extra_names to match location ====================

metadata$Site_ID[metadata$Site_ID == 'Little Naches'] <- 'Little Naches at Nile'
metadata$Site_ID[metadata$Site_ID == 'Naches - Craig Road 2'] <- 'Naches River Craig Road 2'
metadata$Site_ID[metadata$Site_ID == 'Union Gap'] <- 'Yakima at Union Gap'
metadata$Site_ID[metadata$Site_ID == 'Kiona'] <- 'Yakima at Kiona'
metadata$Site_ID[metadata$Site_ID == 'Mabton'] <- 'Yakima at Mabton'
metadata$Site_ID[metadata$Site_ID == 'Naches - Craig Road 1'] <- 'Naches River Craig Road 1'

# ==================================== combine =================================

# na rows
#extra_rows <- 194:293

# join the metadata and site, move the site ID to proper location and remove na
# rows
metadata <- metadata %>%
  left_join(sites, by = c("Site_ID" = "extra_name")) %>%
  relocate(site_ID, .before = "Site_ID") 

# %>%
#   slice(-extra_rows)


# ================================= write file =================================

# write the files
write_csv(metadata, metadata_outdir)
write_csv(sites, sites_outdir)
