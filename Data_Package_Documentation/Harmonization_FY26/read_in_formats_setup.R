# ==============================================================================
#
# Set up script for read_in_formats_function.R
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

# this link will have to be updated once the function moves to the ESS-DIVE repo
source()

# ================================ User Inputs =================================

## ---- Required ----

# Select the data file(s) you would like the read in
user_data_files <- choose.files()

## ---- Optional ----

# Select the associated methods file. 
# If you do not want to pull information from the methods file, put NA
user_methods_file <- file.choose()

# Enter missing values codes for selected files. 
# Default is user_missing_value_codes == c('N/A', '-9999'), indicate this by writing 'default'
# If indicating missing value codes and "N/A" and/or "-9999" is used, you must still include them.  
# Example: c('N/A', '-9999', 'NA', ''). 
user_missing_value_codes <- 'default'

# =============================== run function =================================




