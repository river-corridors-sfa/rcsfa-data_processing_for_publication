# ==============================================================================
#
# fix method ID for sensor summary files for the SSS data package
#
# 
# Status: In Progress. 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 15 March 2023
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

minidot_file <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/04_Minidot/03_ProcessedData/Minidot_Summary_Statistics.csv'
  
baro_file <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/08_AtmosphericPressure/03_ProcessedData/BarotrollAtm_Summary_Statistics.csv'

minidot_outdir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Data_Package/miniDOT/Plots_and_Summary_Statistics/SSS_Minidot_Summary_Statistics.csv'

baro_outdir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Data_Package/BarotrollAtm/Plots_and_Summary_Statistics/SSS_BarotrollAtm_Summary_Statistics.csv'

# ============================== fix minidot ===================================

minidot_headers <- read_csv(minidot_file, col_names = F, n_max = 9, col_select = 1) %>%
  mutate('X1' = str_replace(X1, 'Minidot_03', 'See_Column_InstallationMethod_ID'))

wiper <- c('S22RR', 'S23', 'S24', 'S29', 'S31', 'S32', 'S34R', 'S36', 
           'S41R', 'S43', 'S49R', 'S50P', 'S51', 'S54', 'S55', 'S56', 
           'S57', 'S58', 'T02', 'T03', 'T07', 'T41', 'U20', 'W10', 'W20')

minidot_data <- read_csv(minidot_file, skip = 9) %>%
  mutate('InstallationMethod_ID' = ifelse(Site_ID %in% wiper, 'Mindot_04', 'Minidot_03'),
         Date = paste0(" ", Date))

write_csv(minidot_headers, minidot_outdir, col_names = F)

write_csv (minidot_data, minidot_outdir, col_names = T, append = T)

# ============================== fix barotroll ===================================

baro_headers <- read_csv(baro_file, col_names = F, n_max = 7, col_select = 1) %>%
  mutate('X1' = str_replace(X1, 'TreeRope_01', 'See_Column_InstallationMethod_ID'))

real <- c('S18R', 'S29', 'S34R', 'S39', 'S42', 'S48R', 'S56', 'T05P', 'W10')

baro_data <- read_csv(baro_file, skip = 7) %>%
  mutate('InstallationMethod_ID' = ifelse(Site_ID %in% real, 'TreeRope_01', 'BaroExtrap_01'),
         Date = paste0(" ", Date))

write_csv(baro_headers, baro_outdir, col_names = F)

write_csv (baro_data, baro_outdir, col_names = T, append = T)





