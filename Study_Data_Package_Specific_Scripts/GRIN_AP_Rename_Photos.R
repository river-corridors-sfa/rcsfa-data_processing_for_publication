# ==============================================================================
#
# Rename grain size photos from Allison Pfeiffer for GRIN
#
# 
# Status: In progress
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 19 October 2026
#
# ==============================================================================

library(tidyverse)
library(exifr)

rm(list=ls(all=T))

# ================================= User inputs ================================

photo_dir <- 'C:/Users/forb086/Downloads/GrainSize_PFDFchannels_toshare'

options(exifr.exiftoolcommand = paste0("C:/Users/forb086/OneDrive - PNNL/Documents/exiftool/exiftool.exe"))
configure_exiftool()

setwd(photo_dir)

# # ============================== find locations file ===========================
# commenting out because the file was created and modified, using the modified file moving forward
# 
# coords <- list.files(photo_dir, 'locations.csv', full.names = T) %>%
#   read_csv()
# 
# # ============================== list photos ===========================
# 
# photos <- list.files(photo_dir, 'jpg', recursive = T)
# 
# # ============================= map photos to coords ===========================
# 
# photos_mapping <- tibble(
#   Photo = photos
# ) %>%
#   mutate(
#     Photo = str_replace_all(Photo, "\\\\", "/"),
#     Photo = str_remove(Photo, "^\\./"),
#     Photo = if_else(
#       str_starts(Photo, "GrainSize/"),
#       Photo,
#       str_c("GrainSize/", Photo)
#     ),
#     match_id = basename(Photo) %>%
#       str_remove(regex("\\.jpe?g$", ignore_case = TRUE)) %>%
#       str_remove(regex("(alternate|close|_nowater|_water)$",
#                        ignore_case = TRUE)) %>%
#       str_to_lower()
#   ) %>%
#   group_by(match_id) %>%
#   summarise(Photo = str_c(Photo, collapse = "; "), .groups = "drop")
# 
# coords_mapped <- coords %>%
#   mutate(
#     match_id = SiteID %>%
#       str_to_lower() %>%
#       str_replace_all("__", "_") %>%
#       str_replace("qsd", "gsd") %>%
#       str_replace("^on_gsd_", "on_") %>%
#       str_replace("^tu_gsd_?", "tumalt_") %>%
#       str_replace("^br_", "brunette_") %>%
#       str_replace("^du[nm]_", "dunsmore_")
#   ) %>%
#   full_join(photos_mapping, by = "match_id") %>%
#   select(-match_id, -GlobalID)
# 
# write_csv(coords_mapped, file.path(photo_dir, 'coords_mapped_to_files.csv'))

# ============================== find locations file ===========================

coords_mapped <- list.files(photo_dir, 'coords_mapped_to_files_MW.csv', full.names = T) %>%
  read_csv() 

parent_id_assign <- coords_mapped %>%
  filter(!is.na(Latitude)) %>%
  filter(!is.na(Photo)) %>%
  separate_longer_delim(Photo, delim = "; ") %>%
  filter(!str_detect(Photo, 'alternate')) %>%
  mutate(
    Parent_ID = sprintf("GRIN_AP_%03d", row_number()),
    Date = map(Photo, ~ read_exif(.x)$DateTimeOriginal) %>%
      map_chr(~ if (length(.x) == 0 || is.na(.x[1])) NA_character_ else .x[1])  %>%
      as_date()
  )

for (file in parent_id_assign$Photo) {
  
  exif <- read_exif(file)
  
  date <- parent_id_assign %>% 
    filter(Photo == file) %>%
    pull(Date)
  
  parent_id <- parent_id_assign %>% 
    filter(Photo == file) %>%
    pull(Parent_ID)
  
  new_name <- str_c(parent_id,"_", date, '_USA_Sediment_Photo.jpg')
  
  file.copy(file, file.path('Renamed', new_name))
  

}  

clean_coords <- parent_id_assign %>%
  add_column(First_Name = 'Megan',
             Last_Name = 'Wilson',
             Email = 'wilso466@wwu.edu',
             Affiliation = 'Western Washington University',
             Coordinate_Units = 'decimal degrees',
             Country = 'United_States',
             Notes = 'Provided by Allison Pfeiffer (pfeiffa@wwu.edu)')%>%
  mutate(Stream_Name = case_when(str_detect(SiteID, 'tu_') ~ 'Tumalt Creek',
                                 str_detect(SiteID, 'on_') ~ 'Oneonta Creek',
                                 str_detect(SiteID, 'bc_') ~ 'Big Creek',
                                 TRUE ~ 'N/A'),
         Date = str_c(" ", as.character(Date))) %>%
  select(Parent_ID, First_Name, Last_Name, Email, Affiliation, Date, Stream_Name, Site_Name = SiteID, Latitude, Longitude,Coordinate_Units,Country,Notes) 

write_csv(clean_coords, 'WHONDRS_GRIN_AP_Field_Metadata.csv')
