# ==============================================================================
#
# Script to read in data and metadata that are formatted in compliance with the 
# Soil, Sediment, Water and/or Hydrologic Monitoring reporting formats
#
# Status: in progress
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

# ================================ User Inputs =================================

# Select the data file(s) you would like the read in
data_files <- choose.files()

# Select the associated methods file
methods_file <- file.choose()

# ================================ User Inputs =================================