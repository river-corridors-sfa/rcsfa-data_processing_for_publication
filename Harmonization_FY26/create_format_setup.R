# ==============================================================================
#
# Set up script for create_format.R function
#
# Status: complete
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 29 August 2025
#
# ==============================================================================

rm(list=ls(all=T))

# this link will have to be updated once the function moves to the ESS-DIVE repo
source('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Harmonization_FY26/create_format_function.R')
source('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Harmonization_FY26/populate_header_rows_function.R')

# ================================ Documentation ===============================

# This script helps the user setup the inputs needed for the create_format_function.R 
# function, which is meant to format data files to follow  v2 of the soil, sediment, 
# and water chemistry and hydrologic monitoring reporting formats.

# This function:
# 1. Adds required 'field_name' column
# 2. Creates metadata header rows (unit, method_id, detection_limit, etc.)
# 3. Outputs formatted file with "_Formatted_YYYY-MM-DD" suffix
# 4. Returns a data frame of warnings for complying with the reporting formats (see below for descriptions)

# After running:
# 1. Review warnings and take an actions necessary

# ================================ User Inputs =================================

## ---- Required ----

# Select the data file(s) you would like to format. Only csv files in wide format are supported. 
# Use shift or ctrl to select multiple files (if choosing multiple files, they must be within the same folder).
user_unformatted_data_file <- rchoose.files()

## ---- Optional ----

# Indicate the method_id row(s) you would like to include in metadata headers. 
# Default (NULL) = includes only 'method_id' row
# Options:
#   NULL                            -> uses 'method_id' only
#   'method_id'                     -> same as NULL
#   c('method_id_preservation',
#    'method_id_storage',
#    'method_id_preparation',
#     'method_id_analysis',
#     'method_id_dataprocessing',
#     'method_id_deployment',
#     'method_id_calibration')    -> example of multiple method rows
user_method_rows <- NULL


# Enter the path to folder where you would like the formatted files to output. 
# Default (NULL) = saves to same directory as input files
# Can use chose.dir() to find folder path 
user_outdir <- NULL

# Indicate if you would like to populate the header rows with the input file
# Default (FALSE) = the file will output with header rows that need to be populated
user_populate_header_rows <- TRUE
# If you would like to populate header rows, enter the path to the header row input file
# Default (NULL) = the file will output with header rows that need to be populated
# Can use file.choose() to find file path 
user_populate_header_rows_input <- file.choose()
# =============================== run function =================================

warnings <- create_format(unformatted_data_file = user_unformatted_data_file,
                           method_rows = user_method_rows,
                           outdir = user_outdir,
                           populate_header_rows_indicate = user_populate_header_rows,
                            populate_header_rows_input = user_populate_header_rows_input)
# view warnings 
view(warnings)# see the function instructions for a description of the warnings 

