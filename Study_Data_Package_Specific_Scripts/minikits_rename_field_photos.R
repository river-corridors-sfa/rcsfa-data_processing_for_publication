# ==============================================================================
#
# Rename minikit field photos
#
# 
# Status: Complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 21 August 2025
#
# ==============================================================================

library(tidyverse)
library(magick)

# ================================= User inputs ================================

photo_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_Minikits/WHONDRS_Minikits_Site_Environmental_Photos'

# ============================== rename the images =============================

file_list <-  list.files(photo_dir, full.names = T)
file_list <- file_list[ !grepl('.db',file_list)]
file_list <- file_list[ !grepl('Not renamed',file_list)]

file_names <- tibble(file_name = basename(file_list)) %>%
  mutate(new_name = str_replace_all(file_name, c(
    "(?i)Sample " = "S000",
    "(?i) - across" = "-across",
    "(?i) - data" = "-data",
    "-Data" = "-data",
    "(?i) - down" = "-down",
    "-Down" = "-down",
    "(?i) - up" = "-up",
    "-Up" = "-up",
    "-upstream" = "-up",
    "(?i) - sed" = "-sed",
    "(?i) - pH" = "-ph",
    "-pH" = "-ph",
    "-17" = "17",
    "-19" = "19",
    "-sediment" = "-sed",
    "-Sediment" = "-sed",
    "-sed 2" = "-sed2"
  ))) %>%
  mutate(new_name = str_replace(new_name, " - .*(?=\\.[^.]+$)", ""),
         new_name = case_when(new_name == 'S000145-sed .jpg' ~ 'S000145-sed.jpg',
                              TRUE ~ new_name))



for (i in file_list){
  
 new_name <- file_names %>%
   filter(file_name == basename(i)) %>%
   pull(new_name)
  
  out_file <- paste0(photo_dir,'/Renamed','/', new_name)
  
  file.rename(i, out_file)

}

# ======================== for photos without parent ID in name ================

library(exifr)  # Main package for reading EXIF data
library(fs)     # For file system operations
library(av)

new_list <- list.files(file.path(photo_dir,'Not renamed'), full.names = T)

metadata_combined <- tibble(file_name = as.character(),
                            datetime = as.character(),
                            latitude = as.numeric(),
                            longitude = as.numeric(),
                            altitude = as.numeric(),
                            coords = as.character())

for (j in new_list) {
  
  
  # Extract only location-relevant metadata
  location_metadata <- exifr::read_exif(j, 
                                        tags = c("GPS*", "DateTime*", "FileName")) %>%
    as_tibble() %>%
    # Extract just filename without path
    mutate(
      file_name = fs::path_file(SourceFile),
      coords = paste0(GPSLatitude, ', ', GPSLongitude)
    )%>%
    # Clean and select key columns
    select(
      file_name,
      datetime = DateTimeOriginal,
      latitude = GPSLatitude,
      longitude = GPSLongitude,
      altitude = GPSAltitude,
      coords
    ) 
  
  metadata_combined <- metadata_combined %>%
    bind_rows(location_metadata)
  
  if(str_detect(j, 'heic|HEIC')){
    
    photo_read <- magick::image_read(j)
    
    # this rewrites with the same extension, if I reuse this code make sure to fix this
    # image_write(photo_read, j, format = 'jpeg')
    
  } 
  
  
}

mov <- new_list[grepl('.MOV',new_list)]

av_video_convert(mov, str_replace(mov, 'MOV', 'mp4'))


write_csv(metadata_combined, file.path(photo_dir, 'Photo_Metdata.csv'))
