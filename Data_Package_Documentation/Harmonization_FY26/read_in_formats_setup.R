# ==============================================================================
#
# Set up script for read_in_formats_function.R. This function is meant to read 
# in data and metadata that are formatted in compliance with the 
# Soil, Sediment, Water and/or Hydrologic Monitoring reporting formats
#
# Status: needs review
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

# this link will have to be updated once the function moves to the ESS-DIVE repo
source('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_Documentation/Harmonization_FY26/read_in_formats_function.R')

# ================================ User Inputs =================================

## ---- Required ----

# Select the data file(s) you would like the read in
user_data_files <- choose.files()

## ---- Optional ----

# Select the associated methods file. 
# If you do not want to pull information from the methods file, put NA
user_methods_file <- file.choose()

# Enter missing values codes for selected files. 
# Default is user_missing_value_codes == c('N/A', '-9999')
# If indicating missing value codes and "N/A" and/or "-9999" is used, you must still include them.  
# Example: c('N/A', '-9999', 'NA', ''). 
user_missing_value_codes <- NULL

# =============================== Documentation ================================
# 
# This function is meant to ingest v2 of the soil, sediment, and water chemistry 
# and hydrologic monitoring reporting formats and the associated methods file. For
# each file input, the output of the function will include:
#   - data = the data file with metadata header rows removed
#   - metadata = the metadata header rows extracted from the data file 
#   - long_metadata = a pivoted long version of the metadata header rows; if a methods file 
#                   was provided, this will include additional details from that file
#   - metadata_transposed =  the metadata header rows extracted from the data file but transposed
#                          so that each row is the metadata for a column
#                          
# The output includes the metadata in three formats to allow flexibility. The user 
# can choose what is the most useful. 
#
# =============================== run function =================================

all_data <- read_in_formats(data_files = user_data_files,
                            methods_file = user_methods_file,
                            missing_value_codes = user_missing_value_codes)

