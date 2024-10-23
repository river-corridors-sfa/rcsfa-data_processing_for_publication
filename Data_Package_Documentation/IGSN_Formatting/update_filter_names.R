# ==============================================================================
#
# Add "_RNA" to vial ID for filters in IGSN samples spreadsheet. Change the 
# "append" variable for other vocabulary
#
# Status: complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 2 May 2022
#
# ==============================================================================

library(tidyverse)
library(readxl)
library(writexl)

# ================================= User inputs ================================

igsn <- read_xls('Z:/RC2/08_IGSN/template_1650385621_samples_TEST.xls', skip=1)

igsn_out_dir <- 'Z:/RC2/08_IGSN/template_1650385621_samples_TEST__filter_rename.csv'

append = '_RNA'

# ============================== update names =============================

# selects rows of filters, creates new name with append, deletes old row, and 
# renames everything to match IGSN spreadsheet
filters <- igsn %>%
  rename( field_name ="Field name (informal classification)",
          sample_name = 'Sample Name')%>%
  filter( field_name == 'Filter') %>%
  mutate(new_name = paste(sample_name, append, sep = ''), .after= sample_name) %>%
  select(-sample_name) %>%
  rename('Sample Name' = new_name,
         "Field name (informal classification)" = field_name)
# selects samples that are not filters  
other_samples <- igsn %>%
  rename( field_name ="Field name (informal classification)")%>%
  filter( field_name != 'Filter') %>%
  rename("Field name (informal classification)" = field_name)
  
#combines filters and other_samples
combine <- other_samples %>%
  bind_rows(filters)

combine$`Collection date` <- gsub(' UTC', '', as.character(combine$`Collection date`))

# writes csv file
# once done, paste in first row from original template and convert to .xls
write_csv(combine, igsn_out_dir)

# ============================ don't use this method ===========================
# creates new column with the updated name for filters only; have to copy and 
# paste in
#
# igsn_out <- igsn %>%
#   rename(field_name='Field name (informal classification)',
#          sample_name = 'Sample Name') %>%
#   mutate(new_name = case_when(field_name == 'Filter' ~ paste(sample_name, '_RNA', sep = '')))%>%
#   relocate(new_name, .after = sample_name)
#
# write_csv(igsn_out, igsn_out_dir)
#
