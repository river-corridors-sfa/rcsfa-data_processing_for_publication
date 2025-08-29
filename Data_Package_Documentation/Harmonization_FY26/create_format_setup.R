# ==============================================================================
#
# Set up script for create_format.R function
#
# Status: needs review
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 29 August 2025
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
# 4. Returns a data frame of reminders for complying with the reporting formats (see below for descriptions)

# After running:
# 1. Review reminders and take an actions necessary

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
user_populate_header_rows <- FALSE
user_populate_header_rows <- TRUE

# If you would like to populate header rows, enter the path to the header row input file
# Default (NULL) = the file will output with header rows that need to be populated
# Can use file.choose() to find file path 
user_populate_header_rows_input <- NULL
user_populate_header_rows_input <- file.choose()
# =============================== run function =================================

format <- create_format(unformatted_data_file = user_unformatted_data_file,
                        method_rows = user_method_rows,
                        outdir = user_outdir,
                        populate_header_rows_indicate = user_populate_header_rows,
                        populate_header_rows_input = user_populate_header_rows_input)
# view reminders
view(format$Reminders)

# ============================= Reminders =================================
# The reminders are meant to help the user comply with the reporting formats. 
# We recommend the user take action when applicable. 

# The directory is included in case there are multiple files with the same name. If 
# there are not duplicate file names, this column can be disregarded

# The column names indicate the reminder. The rows indicate the file. 0 indicates
# the reminder is NOT applicable to the associated file. 1 indicates the reminder
# is applicable to the associated file.

# Definitions: 
# - confirm_date_format: there is a date column in your file; it is recommended 
#                        to format dates as YYYY-MM-DD
# - confirm_time_format: there is a time column in your file; it is recommended 
#                        to format time as hh:mm:ss [ASK AMY ABOUT THIS]
# - confirm_datetime_format: there is a datetime column in your file; it is  
#                       recommended to format dates as YYYY-MM-DD hh:mm:ss 
# - report_utc_offset: there is a datetime or time column in your file; it is 
#                      recommended to specify the UTC offset in the unit
# - use_sample_rf: there is a sample column; you must comply with the Sample 
#                   Reporting Format  
# - confirm_material_vocab: there is a material column; it is recommended to use 
#                           the controlled vocab specified in the Sample Reporting Format  
# - fix_duplicate_sample: there is a duplicate within a sample column; this may 
#                         be okay depending on your data structure
# - use_location_rf: there is a latitude and/or longitude column; you must comply 
#                    with the Location Reporting Format
# - report_crs: there is a latitude and/or longitude column; it is recommended to
#               report the coordinate reference system in the unit
# - populate_empty_cells: there are empty cells in you file; it is recommended to 
#                         -9999 for numeric columns and N/A for non-numeric columns
# - populate_header_rows: there are cells in the header rows that must be populated
# -ignored_extra_header_input: if provided, the header rows input file contained 
#                              additional information that was ignored 







