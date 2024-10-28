# ==============================================================================
#
# Check that all sample IDs in a data package are in the data, metadata, and IGSNs
#
# Status: Complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 6 Sept 2022
#
# ==============================================================================

library(tidyverse)
library(crayon)
library(fs)

# ================================= User inputs ================================

dp_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package/BSLE_Data_Package'

#one data type used to find the data file
data_type <- c('NPOC', 'CN', 'EEMs', 'pH')

study_code <- 'BSLE'

# ================================= find files ================================

igsn <- read_csv(list.files(dp_dir, 'IGSN', full.names = T, recursive = T), skip = 1) %>%
  select(Sample_Name)

combine_data <- igsn

for (i in data_type) {
  
  data <- read_csv(list.files(dp_dir, data_type, full.names = T, recursive = T), skip = 2) %>%
    filter(str_detect(Sample_Name, study_code)) %>%
    select(Sample_Name)
  
  combine_data <- combine_data %>%
    add_row(data)
  
}


metadata <- list.files(dp_dir, 'Burn_and_Laboratory_Metadata', full.names = T, recursive = T) %>%
  read_csv() %>%
  select(Sample_Name)

parent_metadata <- list.files(dp_dir, 'Burn_and_Laboratory_Metadata', full.names = T, recursive = T) %>%
  read_csv() %>%
  select(Parent_ID) %>%
  rename(Sample_Name = Parent_ID)

eems <- tibble('Sample_Name' = list.files(dp_dir, 'RamNorm', recursive = T, full.names = F)%>%
                 path_file())

abs <- tibble('Sample_Name' = list.files(dp_dir, 'Abs', recursive = T, full.names = F)%>%
                path_file())

combine_data <- combine_data %>%
  add_row(metadata) %>%
  add_row(parent_metadata)%>%
  add_row(eems) %>%
  add_row(abs)


# =============================== combine and count ============================

combine_data$Sample_Name <- gsub('_filt0.2', '', as.character(combine_data$Sample_Name))
combine_data$Sample_Name <- gsub('_filt0.7', '', as.character(combine_data$Sample_Name))
combine_data$Sample_Name <- gsub('_unfilt', '', as.character(combine_data$Sample_Name))
combine_data$Sample_Name <- gsub('_solid', '', as.character(combine_data$Sample_Name))
combine_data$Sample_Name <- gsub('_DilCorr_IFE_RamNorm.dat', '', as.character(combine_data$Sample_Name))
combine_data$Sample_Name <- gsub('_DilCorr_Abs.dat', '', as.character(combine_data$Sample_Name))


count <- combine_data %>% 
  count(Sample_Name)%>%
  arrange(n, Sample_Name)

bad <- count %>% 
  filter(n < 3)

# ============ write warning if less than three of each sample =================

if(nrow(bad) > 0){
  
  defaultW <- getOption("warn")
  options(warn = -1)
  
  error <- red $ bold
  
  cat(error('NOT ALL SAMPLES ARE IN EVERY FILE'))
    
  options(warn = defaultW)
  
}

