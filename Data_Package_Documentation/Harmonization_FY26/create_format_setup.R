# ==============================================================================
#
# Set up script for create_format.R function
#
# Status: in progress
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#
# ==============================================================================

rm(list=ls(all=T))

# this link will have to be updated once the function moves to the ESS-DIVE repo
source('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_Documentation/Harmonization_FY26/create_format_function.R')

# ================================ Documentation ===============================

# This script helps the user setup the inputs needed for the create_format_function.R 
# function, which is meant to format data files to follow  v2 of the soil, sediment, 
# and water chemistry and hydrologic monitoring reporting formats.

# This function:
# 1. Adds required 'field_name' column
# 2. Creates metadata header rows (unit, method_id, detection_limit, etc.)
# 3. Outputs formatted file with "_Formatted_YYYY-MM-DD" suffix

# After running:
# 1. Open the formatted file
# 2. Fill in the metadata header rows (marked with #)
# 3. Review and populate any missing data values

# ================================ User Inputs =================================

## ---- Required ----

# Select the data file(s) you would like to format. Only csv files in wide format are supported. 
# Use shift or ctrl to select multiple files.
user_unformatted_data_file <- choose.files()

## ---- Optional ----

# Indicate the method_id row(s) you would like to include in metadata headers. 
# Default (NULL) = includes only 'method_id' row
# Options:
#   NULL                            -> uses 'method_id' only
#   'method_id'                     -> same as NULL
#   c('method_id_analysis', 
#     'method_id_storage', 
#     'method_id_preservation', 
#     'method_id_preparation', 
#     'method_id_dataprocessing')    -> multiple method rows
user_method_rows <- NULL

# Enter the path to folder where you would like the formatted files to output. 
# Default (NULL) = saves to same directory as input files
# Can use chose.dir() to find folder path 
user_outdir <- NULL

# =============================== run function =================================

create_format(unformatted_data_file = user_unformatted_data_file,
              method_rows = user_method_rows,
              outdir = user_outdir)

