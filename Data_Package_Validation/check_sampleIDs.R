# ==============================================================================
#
# Check that all sample IDs in a data package are in the data, metadata, and IGSNs
#
# Status: needs to be updated
#
# note: not set up for multiple data files, can also check for duplicate IDs in this script
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

dp_dir <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SFA_SpatialStudy_2021_SampleData/SFA_SpatialStudy_2021_SampleData'

#one data type used to find the data file
data_type <- 'Summary'

study_code <- 'SPS'

# ================================= find files ================================

igsn_file <- list.files(dp_dir, 'IGSN', full.names = T, recursive = T)[1]

igsn <- read_csv(igsn_file , skip = 1) %>%
  select(Sample_Name)

data_file <- list.files(dp_dir, data_type, full.names = T, recursive = T)[1]

data <- read_csv(data_file, skip = 2) %>%
  filter(str_detect(Sample_Name, study_code)) %>%
  select(Sample_Name)

metadata_file <- list.files(dp_dir, 'Metadata', full.names = T)

metadata <- read_csv(metadata_file) %>%
  select(Sample_Name)

icr_files <- list.files(dp_dir, '.xml', recursive = T, full.names = T)

# # =============================== combine and count ============================

igsn$Sample_Name <- gsub('_RNA', '', as.character(igsn$Sample_Name))
# data$Sample_Name <- gsub('-1', '', as.character(data$Sample_Name))
# data$Sample_Name <- gsub('-2', '', as.character(data$Sample_Name))
# data$Sample_Name <- gsub('-3', '', as.character(data$Sample_Name))
data$Sample_Name <- gsub('_ICR', '', as.character(data$Sample_Name))
data$Sample_Name <- gsub('_OCN', '', as.character(data$Sample_Name))

igsn <- igsn %>%
  distinct(Sample_Name)

igsn_temp <- igsn %>%
  mutate(Sample_Name = paste0(Sample_Name,'-2'))

igsn_temp2 <- igsn %>%
  mutate(Sample_Name = paste0(Sample_Name,'-3'))

igsn <- igsn %>%
  mutate(Sample_Name = paste0(Sample_Name,'-1')) %>%
  add_row(igsn_temp) %>%
  add_row(igsn_temp2)

data <- data %>%
  distinct(Sample_Name)

# data_temp <- data %>%
#   mutate(Sample_Name = paste0(Sample_Name,'-2'))
# 
# data_temp2 <- data %>%
#   mutate(Sample_Name = paste0(Sample_Name,'-3'))
# 
# data <- data %>%
#   mutate(Sample_Name = paste0(Sample_Name,'-1')) %>%
#   add_row(data_temp) %>%
#   add_row(data_temp2)

metadata <- metadata %>%
  distinct(Sample_Name)

metadata_temp <- metadata %>%
  mutate(Sample_Name = paste0(Sample_Name,'-2'))

metadata_temp2 <- metadata %>%
  mutate(Sample_Name = paste0(Sample_Name,'-3'))

metadata <- metadata %>%
  mutate(Sample_Name = paste0(Sample_Name,'-1')) %>%
  add_row(metadata_temp) %>%
  add_row(metadata_temp2)

icr_file_names <- tibble(Sample_Name = as.character())

for (file in icr_files) {
  
  file_name <- path_file(file) %>%
    str_replace('.xml', '')%>%
    str_replace('_p\\d{1,2}','')
  
  icr_file_names <- icr_file_names %>%
    add_row(Sample_Name = file_name)
  
  
}

icr_file_names <- icr_file_names %>%
  mutate(Sample_Name = str_replace_all(Sample_Name, c( '_ICR' = '', 
                                                       # '-1' = '',
                                                       # '-2' = '',
                                                       # '-3' = ''
                                                       )))

combine <- igsn %>%
  add_row(data) %>%
  add_row(metadata)%>%
  add_row(icr_file_names)%>%
  distinct()

# ================== make tibble of sample IDs and files =======================

samples <- tibble(Sample_Name = combine$Sample_Name,
                  metadata_check = 'FALSE',
                  igsn_check = 'FALSE',
                  data_check = 'FALSE',
                  icr_check ='FALSE') 

for (sample in samples$Sample_Name) {
  
  if (sample %in% metadata$Sample_Name){
    
    samples <- samples %>%
      mutate(metadata_check = ifelse(Sample_Name == sample, 'TRUE', metadata_check))
    
  }
  
  if (sample %in% igsn$Sample_Name){
    
    samples <- samples %>%
      mutate(igsn_check = ifelse(Sample_Name == sample, 'TRUE', igsn_check))
    
  }
  
  if (sample %in% data$Sample_Name){
    
    samples <- samples %>%
      mutate(data_check = ifelse(Sample_Name == sample, 'TRUE', data_check))
    
  }
    
  if (sample %in% icr_file_names$Sample_Name){
    
    samples <- samples %>%
      mutate(icr_check = ifelse(Sample_Name == sample, 'TRUE', icr_check))
    
  }  
  
}


bad_samples <- samples %>%
  filter_all(any_vars(. == 'FALSE'))

write_csv(bad_samples, paste0(dp_dir, '/missing_samples.csv'))
