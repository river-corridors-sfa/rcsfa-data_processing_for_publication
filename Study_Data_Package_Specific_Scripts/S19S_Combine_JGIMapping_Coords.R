# ==============================================================================
#
# Combine S19S coords with JGI mapping file
#
# Status: in progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 20 Jan 2026
#
# ==============================================================================

library(tidyverse)


rm(list=ls(all=T))


# =========================== user inputs ====================================

sed_jgi <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_Sediment_v9/v9_WHONDRS_S19S_Sediment/WHONDRS_S19S_Sediment_Metadata/WHONDRS_S19S_Sediment_JGI-Mapping.csv" %>%
  read_csv()

wat_jgi <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_SW_v7/v7_WHONDRS_S19S_SW/WHONDRS_S19S_SW_JGI-Mapping.csv" %>%
  read_csv()

metadata <- 'Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_SW_v7/v7_WHONDRS_S19S_SW/v4_WHONDRS_S19S_Metadata.csv' %>%
  read_csv() %>%
  select(Sample_ID, MS_Latitude_dec.deg, MS_Longitude_dec.deg)

# =========================== combine ====================================

jgi <- sed_jgi %>%
  bind_rows(wat_jgi) %>%
  mutate(Sample_ID = str_remove(Sample_ID, 'WHONDRS-'))

combine <- jgi %>%
  left_join(metadata)

# =========================== write ====================================

write_csv(combine, './S19S_JGI_Coords.csv')
