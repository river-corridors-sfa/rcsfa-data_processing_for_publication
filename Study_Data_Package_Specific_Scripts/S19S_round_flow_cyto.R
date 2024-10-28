# ==============================================================================
#
# round S19S flow cytometry data 
#
# Status: 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 23 Jan 2023
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

file <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_S19S_SW_v4/WHONDRS_S19S_SW_v4/WHONDRS_S19S_SW_FlowCytometry.csv'

outfile <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_S19S_SW_v4/WHONDRS_S19S_SW_v4/WHONDRS_S19S_SW_FlowCytometry_round.csv'

# ================================= round data ===============================

data <- read_csv(file) %>%
  mutate(Total_Bacteria_cells_per_liter = format(signif(Total_Bacteria_cells_per_liter, 3), scientific = F),
         Total_Photorophs_cells_per_liter = format(signif(Total_Photorophs_cells_per_liter, 3), scientific = F),
         Total_Heterotrophs_cells_per_liter = format(signif(Total_Heterotrophs_cells_per_liter, 3), scientific = F))

write_csv(data, outfile)
