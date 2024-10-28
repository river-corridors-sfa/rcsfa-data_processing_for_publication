# ==============================================================================
#
# Rename DBP processed ICR sample names in file
#
# Status: In progress. 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 14 February 2023
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

data_dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_DBP_Data_Package/WHONDRS_DBP_Data_Package/FTICR/FTICR_ProcessedData'

mapping <- read_csv('C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC4/BoyeFiles_byStudyCode/WHONDRS_DBP/ICR_mapping.csv')

# ================================= rename columns==============================

data <- read_csv(list.files(data_dir, 'Data', full.names = T))

columns <- data %>%
  select(-Mass)%>%
  colnames()

new <- data %>%
  select(Mass)


for (i in columns) {
  
  
  new_name <- mapping %>% filter(old == i) %>%
    select(publish) %>%
    pull()
  
  column <- data %>%
    select(i) %>%
    rename(!!new_name := i)
  
  new <- new %>%
    add_column(column)
  
    
    }

write_csv(new, 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_DBP_Data_Package/WHONDRS_DBP_Data_Package/FTICR/FTICR_ProcessedData/Processed_Leonard_Data_Fixed.csv')  
  
  