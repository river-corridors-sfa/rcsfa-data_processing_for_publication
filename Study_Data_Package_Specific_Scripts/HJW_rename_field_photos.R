# ==============================================================================
#
# Rename HJW field photos
#
# Status: In progress
#
# Notes: code set up but waiting to run until field metadata is finalized; should check everything working as expected before fully running 
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 31 Dec 2025
#
# ==============================================================================

library(tidyverse)
library(magick)

# ================================= User inputs ================================

photo_dir <- "C:/Users/forb086/Downloads/Site Photos_WHONDERS"

metadata <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_HJW_Data_Package/WHONDRS_HJW_Data_Package/HJW_Field_Metadata.csv" %>%
  read_csv()

out_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_HJW_Data_Package/WHONDRS_HJW_Field_Photos'

# ============================== wrangle file names =============================

file_list <-  list.files(photo_dir, full.names = T, recursive = T)
file_list <- file_list[ !grepl('.docx',file_list)]
file_list <- file_list[ !grepl('Site 82',file_list)] # no samples from site 82, skipping photos 

file_names <- tibble(path = file_list,
                     file_name = basename(file_list),
                     site = basename(dirname(file_list))) %>%
  mutate(site_fixed = str_replace(site, 'Site 83 overview pics', '83'),
         site_fixed = str_replace(site_fixed, 'Site 178 overview photos', '178'),
         site_fixed = str_replace(site_fixed, 'WS3 1-30cm', 'WS3-1'),
         site_fixed = str_replace(site_fixed, 'WS1_S', 'WS1-'),
         site_fixed = str_replace(site_fixed, 'WS3_S', 'WS3-'),
         indicator = case_when(str_detect(tolower(file_name), 'sed') ~ 'sed',
                               str_detect(tolower(file_name), 'down') ~ 'down',
                               str_detect(tolower(file_name), 'up') ~ 'up',
                               str_detect(tolower(file_name), 'bank') ~ 'sed',
                               str_detect(tolower(file_name), 'shore') ~ 'sed',
                               str_detect(tolower(file_name), 'bed') ~ 'sed',
                               str_detect(tolower(file_name), 'vertical') ~ 'sed',
                               str_detect(tolower(file_name), 'across') ~ 'across',
                               str_detect(tolower(file_name), 'stream') ~ 'across',
                               str_detect(tolower(file_name), 'data') ~ 'data',
                               str_detect(tolower(file_name), 'sheet') ~ 'data',
                               TRUE ~ '')) %>%
  group_by(site_fixed) %>%
  mutate(
    # Create sequential numbers only for files without descriptive indicators
    needs_number = indicator == '',
    sequential_num = cumsum(needs_number),
    # Assign numbers only to files that need them
    indicator = ifelse(needs_number, as.character(sequential_num), indicator)
  ) %>%
  # Handle duplicates of descriptive indicators
  group_by(site_fixed, indicator) %>%
  mutate(
    occurrence = row_number(),
    is_duplicate = n() > 1
  ) %>%
  ungroup() %>%
  mutate(
    # Create final indicator
    final_indicator = case_when(
      # For single occurrence descriptive indicators, keep as-is  
      !str_detect(indicator, "^[0-9]+$") & !is_duplicate ~ indicator,
      # For duplicate descriptive indicators, add 1, 2, 3, etc.
      !str_detect(indicator, "^[0-9]+$") & is_duplicate ~ paste0(indicator, occurrence),
      # Keep numeric indicators (from empty original indicators) as-is
      TRUE ~ indicator
    )
  ) 

combine <- metadata %>%
  select(Parent_ID, Site_ID) %>%
  full_join(file_names%>%
              select(path, site_fixed, final_indicator), by = c('Site_ID' = 'site_fixed'))

new_names <- combine %>%
  mutate(ext = tools::file_ext(path),
         output_ext = case_when(
           tolower(ext) == 'heic' ~ "jpeg",
           TRUE ~ ext
         ),
    new_name = paste0(Parent_ID, "_Site", Site_ID, '-', final_indicator,".", output_ext))

# ============= output mapping of file names to send to yunxiang ===============

mapping <- new_names %>%
  mutate(original_name = str_remove(path, 'C:/Users/forb086/Downloads/')) %>%
  select(original_name, new_name)

write_csv(mapping, file.path(str_remove(out_dir, '/WHONDRS_HJW_Field_Photos'), 'HJW_Photo_Name_Mapping_For_Yunxiang.csv'))

# ============================== rename the images =============================

for (i in file_list){
  
 new_name <- new_names %>%
   filter(path == i) %>%
   pull(new_name)
  
  out_file <- file.path(out_dir, new_name)
  
  if(str_detect(i, 'heic|HEIC')){ # convert images if they are heic, otherwise just output into shared drive folder 
    
    photo_read <- magick::image_read(j)
    
    image_write(photo_read, new_name, format = 'jpeg')
    
  } else{
    
  file.copy(i, out_file) 
    
  }

}

