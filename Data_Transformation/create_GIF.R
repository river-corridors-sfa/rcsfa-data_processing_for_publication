# ==============================================================================
#
# Create a gif from png files
#
# Status: will need to be edited when ran with real data
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 3 April 2023
#
# ==============================================================================

library(tidyverse)
library(magick)

# ================================= User inputs ================================

dir <- 'C:/Brieanne/GitHub/ICON-ModEx_Open_Manuscript/Sector_GIF/Final_Figs/'

out_name <- 'WHONDRS_ICON-ModEx.gif'

# ============================= get files and make gif =========================

files <- list.files(dir, full.names = T)[1:19]


# code used for icon modex maps ----
# files %>%
#   image_read() %>%
#   image_join() %>%
#   image_animate(fps = 2) %>%
#   image_write(paste0(dir, out_name))

# code used for RMP gif; the files were very high res so need to reduce res so it doesnt take hours to run ----

# Define target resolution
target_size <- "3840x2160"

# Read, resize, and process images
optimized_images <- lapply(files, function(f) {
  image_read(f) %>%
    image_scale(target_size)
})

# Animate with correct FPS (1 frame per second)
animation <- image_animate(image_join(optimized_images), fps = 0.25)

# Save the animation
image_write(animation, path = paste0(dir, 'WHONDRS_ICON-ModEx_Slower.gif'), quality = 100)

# need to figure out how to save as mp4

