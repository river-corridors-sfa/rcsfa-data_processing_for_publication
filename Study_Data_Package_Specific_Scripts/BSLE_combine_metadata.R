# ==============================================================================
#
# Combine BSLE metadata
#
# Status: In progress. 
# ==============================================================================
#
# Author: Brieanne Forbes
# 26 Sept 2022
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

burn <- read_csv('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Metadata_and_Protocols_v1/BSLE_Burn_Metadata.csv',
                 na = c('N/A', '-9999'))

lab <- read_csv('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Metadata_and_Protocols_v1/BSLE_Laboratory_Metadata.csv',
                na = c('N/A', '-9999'))

mapping <- read_csv('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Metadata_and_Protocols_v1/BSLE_Solid_Char_Metadata.csv',
                    na = c('N/A', '-9999'))


# ================================ combine ==============================

combine <- full_join(burn, lab, by = 'Burn_Code')

combine2 <- full_join(combine, mapping) %>%
  arrange(Burn_Code) %>%
  mutate(Feedstock_Species.z = coalesce(Feedstock_Species.x, Feedstock_Species.y),
         Feedstock_Species = coalesce(Feedstock_Species.z, Feedstock_Species),
         Feedstock_Status.z = coalesce(Feedstock_Status.x, Feedstock_Status.y),
         Feedstock_Status = coalesce(Feedstock_Status.z, Feedstock_Status),
         Land_Coverage_Category.z = coalesce(Land_Coverage_Category.x, Land_Coverage_Category.y),
         Land_Coverage_Category = coalesce(Land_Coverage_Category.z, Land_Coverage_Category),
         Burn_Treatment.z = coalesce(Burn_Treatment.x, Burn_Treatment.y),
         Burn_Treatment = coalesce(Burn_Treatment.z, Burn_Treatment),
         Moisture.z = coalesce(Moisture.x, Moisture.y),
         Moisture = coalesce(Moisture.z, Moisture)) %>%
  select(Burn_Code, Parent_ID, Sample_ID, Feedstock_Species, Land_Coverage_Category, 
         Feedstock_Status, Moisture, Burn_Treatment, Burn_Date, Burn_Start_Time_PST, 
         Flame_Start_Time_PST, '300_degC_Grab_Time_PST', '600_degC_Grab_Time_PST', 
         Flame_End_Time_PST,  Burn_End_Time_PST,  Max_Temp_degC, Dry_Fuel_Weight_Added, 
         Aprox_Char_Weight, Burn_Notes, Char_type, Burn_Severity, Burn_Duration, Char_Max_Temp, 
         Leach_Date, Char_Leached, Leachate_Volume) %>%
  rename(Max_Burn_Temp = Max_Temp_degC,
         Dry_Fuel_Before_Burn_Weight = Dry_Fuel_Weight_Added,
         Aprox_Char_After_Burn_Weight = Aprox_Char_Weight)%>%
  arrange(Burn_Code, Parent_ID, Sample_ID)


write_csv(combine2, 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package/BSLE_Metadata_and_Protocols_v1/BSLE_Burn_and_Laboratory_Metadata.csv')
