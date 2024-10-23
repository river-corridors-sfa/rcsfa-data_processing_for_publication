# ==============================================================================
#
# Subset and format d50 and O2 consumption data for the SSS ecosystem respiration
#
# Status: in progress
#
#
# known issue: 
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 12 June 2023 2022
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

sites_file <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Ecosystem_Respiration_Data_Package/SSS_Ecosystem_Respiration_Data_Package/SSS_Water_Sediment_Total_Respiration.csv'

geospatial_file <- 'C:/Users/forb086/Downloads/v2_RCSFA_Geospatial_Data_Package/v2_RCSFA_Geospatial_Site_Information.csv'

d50_file <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Ecosystem_Respiration_Data_Package/dataHUC17_May29_2020.rds'

o2_consump_file <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Ecosystem_Respiration_Data_Package/nhd_CR_stream_annual_o2_consum_df.csv'

outdir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Ecosystem_Respiration_Data_Package/SSS_Ecosystem_Respiration_Data_Package/'

# ================================= read data in ===============================

sites <- read_csv(sites_file, skip = 8) %>%
  select(Site_ID, Parent_ID)
  
geospatial <- read_csv(geospatial_file) %>%
  select(Site_ID, COMID)

d50 <- read_rds(d50_file) %>%
  select(comid_nhd, D50_m) %>%
  rename(COMID = comid_nhd)

o2_consump <- read_csv(o2_consump_file) %>%
  select(COMID, tot_o2_cons_g_m2_day)

# =================================== subset ===================================

comids <- sites %>%
  left_join(geospatial)

merge <- comids %>%
  left_join(d50) %>%
  left_join(o2_consump)%>%
  select(-COMID) %>%
  rename(Total_Oxygen_Consumed_g_per_m2_per_day = tot_o2_cons_g_m2_day) %>%
  mutate(Total_Oxygen_Consumed_g_per_m2_per_day = case_when(is.na(Total_Oxygen_Consumed_g_per_m2_per_day) ~ -9999,
                                                            TRUE ~ Total_Oxygen_Consumed_g_per_m2_per_day),
         D50_m = signif(D50_m, 3),
         Total_Oxygen_Consumed_g_per_m2_per_day = round(Total_Oxygen_Consumed_g_per_m2_per_day, 3))

out_file <- paste0(outdir, 'SSS_ER_d50_TotalOxygenConsumed.csv')

write_csv(merge, out_file)
