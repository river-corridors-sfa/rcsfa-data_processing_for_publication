# ==============================================================================
#
# Query archived dps to get list of flmd and dds to populate database with 
# 
# Bibi will add publish date manually and use as an input to the function 
#
# ==============================================================================
#
# Brieanne Forbes
# 22 May 2025
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

# ================================= User inputs ================================

study_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED'

outdir <- 'C:/Users/forb086/Documents/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/All_dd_flmd_as_of_2025-06-05.csv'

# ================================= find files ================================

study_files <- list.files(study_dir, pattern = "(_dd\\.csv|_flmd\\.csv)$", full.names = T, recursive = T)

# ================================= remove unwanted files ======================

all_files <-  tibble(archived_dd_flmd = study_files)

filtered <- all_files %>%
  mutate(sans_dir = str_remove(archived_dd_flmd, study_dir)) %>%
  filter(!str_detect(sans_dir, regex("archive", ignore_case = TRUE))) %>%
  filter(!str_detect(sans_dir, 'prelim_dd.csv'))%>%
  filter(!str_detect(sans_dir, 'prelim_flmd.csv')) %>%
  filter(sans_dir != '/SSS_Data_Package_v3/v2_SSS_dd.csv')%>%
  filter(sans_dir != '/SSS_Data_Package_v3/v2_SSS_flmd.csv')%>%
  filter(!str_detect(sans_dir, 'D50')) %>%
  filter(sans_dir != '/RC2_TemporalStudy_2021-2022_SampleData_v3/v2_RC2_Sample_dd.csv') %>%
  filter(sans_dir != '/RC2_TemporalStudy_2021-2022_SampleData_v3/v2_RC2_Sample_flmd.csv') %>%
  mutate(date_file_modified = as.Date(file.info(archived_dd_flmd)$mtime))

anti <- anti_join(all_files, filtered)


write_csv(filtered, outdir)
