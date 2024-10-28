# ==============================================================================
# format cotton strip data for publishing
#
# Status: In progress. 
# ==============================================================================
#
# Author: Brieanne Forbes 
# 10 March 2023
#
# ==============================================================================

library(tidyverse)
library(readxl)

# ================================= User inputs ================================

data <- read_csv('C:/Users/forb086/OneDrive - PNNL/Documents/GitHub/CottonStripPaper/data/cotton.strip.data.for.package.csv') 

mapping <- read_excel('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Cotton_Strips/20230303_Mapping_Raw_Cotton_Strips_SBR_SSS.xlsx')

outfile <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Data_Package/SSS_Data_Package/SSS_CottonStrip_TensileStrength_DecayRate_temp.csv'

# ============================== format and combine ============================

format_data <- data %>%
  select(Sample_ID, Replicate.ID, Tensile.Strength, Total_Inc_Days, Decay_Rate) %>%
  mutate(Sample_Name = paste0(Sample_ID, "_COT-", Replicate.ID), .before = Tensile.Strength) %>%
  select(-Sample_ID, -Replicate.ID)

format_map <- mapping %>%
  select(Randomized_ID, Replicate.ID, Method_Deviation, Appearance_Notes) %>%
  mutate(Sample_Name = paste0(Randomized_ID, "-", Replicate.ID), .before = Method_Deviation) %>%
  select(-Randomized_ID, -Replicate.ID)

combine <- format_data %>%
  full_join(format_map) %>%
  mutate(Decay_Rate = round(Decay_Rate, 4),
         Total_Inc_Days = round(Total_Inc_Days, 4))

write_csv(combine, outfile)
