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

manuscript_dir <- 'Z:/00_ESSDIVE/03_Manuscript_DPs/00_ARCHIVE-WHEN-PUBLISHED'

outdir <- 'C:/Users/forb086/Documents/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/All_dd_flmd_as_of_2025-05-22.csv'

# ================================= find files ================================

study_files <- list.files(study_dir, pattern = "(_dd\\.csv|_flmd\\.csv)$", full.names = T, recursive = T)

manuscript_files <- list.files(manuscript_dir, pattern = "(_dd\\.csv|_flmd\\.csv)$", full.names = T, recursive = T)

# ================================= remove unwanted files ======================

all_files <-  tibble(archived_dd_flmd = c(study_files, manuscript_files))

filtered <- all_files %>%
  mutate(sans_dir = str_remove(archived_dd_flmd, study_dir),
         sans_dir = str_remove(sans_dir, manuscript_dir)) %>%
  filter(!str_detect(sans_dir, regex("archive", ignore_case = TRUE))) %>%
  filter(!str_detect(sans_dir, 'prelim_dd.csv'))%>%
  filter(!str_detect(sans_dir, 'prelim_flmd.csv')) %>%
  filter(sans_dir != '/SSS_Data_Package_v3/v2_SSS_dd.csv') %>%
  mutate(date_modified = as.Date(file.info(archived_dd_flmd)$mtime),
        date_published = "")


anti <- anti_join(all_files, filtered)


write_csv(filtered, outdir)
