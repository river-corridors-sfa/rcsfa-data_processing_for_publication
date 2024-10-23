# ==============================================================================
#
# Check sample name in IGSN spreadsheet to look for duplicates. 
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 29 April 2022
#
# ==============================================================================

library(tidyverse)
library(readxl)

# ================================= User inputs ================================

#read in igsn spreadsheet and rename column, removes na rows 
igsn <- read_xls('Z:/RC2/08_IGSN/template_1650385621_samples.xls', skip = 1) %>%
  rename(sample_name='Sample Name') %>%
  filter(!is.na(sample_name))

# ============================== find duplicates =============================


#returns a data frame with any sample name that is listed more than once
duplicates <- igsn %>%
  group_by(sample_name) %>%
  count() %>%
  filter(n != 1)

duplicates <- paste(duplicates$sample_name, collapse = ', ')


#returns a message in console
if (duplicates %in% ""){
  print('No duplicates in IGSN spreadsheet')
} else {
  paste('Sample(s) ', duplicates, 'is/are duplicated')
}




