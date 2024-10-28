# ==============================================================================
#
# Add IGSNs into data files that are not in the Boye format
#
# Status: In progress. 
#
# Note: only works for parent ID with six characters
# ==============================================================================
#
# Author: Brieanne Forbes
# 9 Nov 2023
#
# ==============================================================================

library(tidyverse)
library(crayon)

rm(list=ls(all=T))

# ================================= User inputs ================================

file <- file.choose()

#appended on IGSN sample name: Sediment, Water, or RNA
material <- 'Sediment'

# ================================== read files ================================

data <- read_csv(file, skip = 2) %>%
  filter(!Sample_Name %in% c('N/A', '-9999')) %>%
  mutate(Parent_ID = str_extract(Sample_Name, '.{6}'))

igsn <- read_csv(list.files(dp_dir, 'IGSN', full.names = T), skip = 1) %>%
  select(Sample_Name, IGSN) %>%
  filter(str_detect(Sample_Name, material)) %>%
  mutate(Parent_ID = str_extract(Sample_Name, '.{6}')) %>%
  select(-Sample_Name)

# =========================== add IGSN and write out ===========================

combine <- data %>%
  left_join(igsn, by = 'Parent_ID') %>%
  relocate(IGSN, .after = 'Sample_Name') %>%
  select(-Parent_ID)

if(NA %in% combine$IGSN){
  
  cat(
    red$bold(
      'Wait! Some samples are missing IGSNs'
    )
  )
  
}

write_csv(combine, file)
