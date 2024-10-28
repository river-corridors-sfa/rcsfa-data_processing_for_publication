# ==============================================================================
#
# Rename river monitoring photos with site ID and date/time
#
# Status: complete
#
# Note: If no bursts were taken, the photo will still have "-1" appended. If HD 
# photos are downloaded from the website, it will cause issues.
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 9 June 2023
#
# ==============================================================================

library(tidyverse)
library(tools)
library(magick)
library(tesseract)
library(crayon)

rm(list=ls(all=T))

# ================================= User inputs ================================

RMP_dir <- 'Z:/RC2/09_River_Monitoring_Photos/01_Site_Photos/'

#put date of most recent folder for script to look in 
date <- '2024-03-28'
  
# =================================== outdir ===================================

outdir <- paste0(RMP_dir, '02_FormattedData/')

# =============================== list photos ================================

photos <- list.files(paste0(RMP_dir, "01_RawData/"), full.names = T, recursive = T)

#only looks in photos within date folder
photos <- photos[grepl(date,photos)]

#skip already renamed files
photos <- photos[!grepl('-raw',photos)]

#skip thumbnail hidden files
photos <- photos[!grepl('Thumbs',photos)]

#skip txt files (readmes)
photos <- photos[!grepl('.txt',photos)]

#skip archived files
photos <- photos[!grepl('Archive',photos)]

#skip people working files
photos <- photos[!grepl('PeopleWorking_Photos',photos)]

#skip installation photos
photos <- photos[!grepl('Photos_Of_Installation',photos)]

# ==================== loop through and rename each photo ======================

for (photo in photos) {
  site <- unlist(str_split(photo, '/')) [7]
  
  if (str_detect(photo, 'NoCell_Camera') == TRUE) {
    datetime <- file.info(photo) %>%
      select(mtime) %>%
      pull()
    
  } else {
    
    if (str_detect(photo, 'HD') == TRUE) {
      
      datetime <- file.info(photo) %>%
        select(mtime) %>%
        pull()
      
    } else{
    
    read_photo <- image_read(photo)
    
    width <- image_info(read_photo) %>%
      select(width)%>%
      pull()
    
    if(width == 1920){
      
      image_text <- read_photo %>%
        image_convert(type = 'Grayscale') %>%
        image_crop("550x50+5+1031")%>%
        image_resize("3000x") %>%
        ocr()
      
    }else if(width == 720){
    
    image_text <- read_photo %>%
      image_convert(type = 'Grayscale') %>%
      image_deskew() %>%
      image_crop("210x21+0+387") %>%
      image_resize("3000x") %>%
      ocr()
    
    } else{
      
      break
      
    }
    
    datetime <- image_text %>%
      str_remove('\\n') %>%
      mdy_hm()
    
  }}
  
  datetime_character <- datetime %>%
    as.character() %>%
    str_replace(' ', '_') %>%
    str_replace_all(':', "") %>%
    str_replace_all('-', "") %>%
    str_c(., "PST")
  
  #if there is an issue with the datetime, it does not move or rename photo
  if (is.na(datetime_character)) {
    cat(red('THERE IS AN ISSUE WITH A PHOTO DATE TIME\n'))
    break
    
  } else{
    ext <- file_ext(photo)
    
    if(exists('last_photo_time') == FALSE){
      rep <- '1'
      
    } else {
    # check to see if last photo was in the same burst
    time_elapsed_secs <-
      abs(as.numeric(difftime(last_photo_time, datetime, units = 'secs')))
    
    # if time since last photo was within 10 mintes, add 1 to rep number
    if (time_elapsed_secs < 600) {
      rep <- as.character(last_photo_rep + 1)
      
      datetime_character <- last_photo_time_character
      
    } else{
      # otherwise, it is the first photo in burst and is named rep 1
      rep <- '1'
      
    }
    }
    
    # adds indicator of reference photo if needed 
    if (str_detect(photo, 'Reference_Photo') == TRUE) {
      file_name <- paste0(outdir,"RMP_",site,"_",datetime_character, "_RefPhoto-",rep,".",ext)
      
    } else {
      file_name <- paste0(outdir,"RMP_",site,"_",datetime_character,"-",rep,".",ext)
      
    }
    
    file_copy <- file.copy(photo, file_name, overwrite = T)
    
    if(file_copy == FALSE){
      
      cat(red('FILE DID NOT COPY\n'))
      break
      
    }
    
    # appends -raw to files that have already been renamed so that they are not renamed again
    append <- photo %>%
      str_remove(ext) %>%
      str_remove('\\.') %>%
      paste0('-raw.', ext)

    file.rename(photo, append)
    
    last_photo_time <- datetime
    
    last_photo_time_character <- datetime_character
    
    last_photo_rep <- file_name %>%
      str_extract('[:digit:]{1}(?=\\.)') %>%
      as.numeric()
    
  }
}
