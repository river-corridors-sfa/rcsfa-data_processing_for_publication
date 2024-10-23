# ==============================================================================
#
# BSLE combine NPOC and TN
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 2 August 2023
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

npoc <- read_csv('./BSLE_NPOC_NEW.csv')

tn <- read_csv('./BSLE_TN_NEW.csv')

# =================================== format ================================

npoc_fix <- npoc %>% 
  mutate(Sample_ID = str_remove(Sample_ID, '-DOC'),
         Sample_ID = str_remove(Sample_ID, '_DOC')) %>%
  rename(npoc_flag = Flags)

tn_fix <- tn %>% 
  mutate(Sample_ID = str_remove(Sample_ID, '-TN'),
         Sample_ID = str_remove(Sample_ID, '_TN'),
         Sample_ID = str_remove(Sample_ID, '-DOC'),
         Sample_ID = str_remove(Sample_ID, '_DOC')) %>%
  rename(tn_flag = Flags)

merge <- npoc_fix %>%
  full_join(tn_fix, by = 'Sample_ID') %>%
  mutate(npoc_flag = if_else(npoc_flag == 'DTL_000;DTL_000', 'DTL_000', npoc_flag),
         tn_flag = if_else(tn_flag == 'DTL_000;DTL_000', 'DTL_000', tn_flag),
         npoc_flag = if_else(is.na(npoc_flag), 'N/A', npoc_flag),
         tn_flag = if_else(is.na(tn_flag), 'N/A', tn_flag),
         Methods_Deviation = str_c(npoc_flag, tn_flag, sep = '; '),
         Methods_Deviation = str_remove_all(Methods_Deviation, '; N/A'),
         Methods_Deviation = str_remove_all(Methods_Deviation, 'N/A;'),
         Methods_Deviation = str_replace(Methods_Deviation, 'DTL_000; DTL_000', 'DTL_000'),
         NPOC_mg_C_per_L = if_else(is.na(NPOC_mg_C_per_L), '-9999', NPOC_mg_C_per_L),
         TN_mg_N_per_L = if_else(is.na(TN_mg_N_per_L), '-9999', TN_mg_N_per_L)) %>%
  select(-NPOC_Outlier, -TN_Outlier, -tn_flag, -npoc_flag) %>%
  rename(Sample_Name = Sample_ID)

write_csv(merge, 'NPOC_TN_NEW.csv')
