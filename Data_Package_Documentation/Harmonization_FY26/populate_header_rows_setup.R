# ==============================================================================
#
# Set up script for create_format.R function
#
# Status: in progress
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 22 August 2025
#
# ==============================================================================

rm(list=ls(all=T))

# this link will have to be updated once the function moves to the ESS-DIVE repo
source('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_Documentation/Harmonization_FY26/populate_header_rows_function.R')

# ================================ Documentation ===============================

# This script helps the user setup the inputs needed for the populate_header_rows_function.R 
# function, which is meant to populate the header rows to follow  v2 of the soil, sediment, 
# and water chemistry and hydrologic monitoring reporting formats.

# This function:
# 1. Loops through the file and uses the input file to populate header rows in the data files 
# 2. Returns a list with the data file(s) containing populated header rows and reminders for 
#    complying with the reporting formats (see below for descriptions)
# NOTE: The function will terminate if an unformatted file is missing from the input file or
#       if the input file does not contain all column headers that are in the data file. 

# ================================ User Inputs =================================

## ---- Required ----

# Select the formatted data file(s) you would like to format. Only formatted csv files are supported. 
# Use shift or ctrl to select multiple files.
user_data_files <- choose.files()

# Select the header row input file. You must use the specified format (see XYZ).
user_header_row_input_file <- file.choose()

# ============================== read in files =================================

user_data_dfs <- map(user_data_files, ~read_csv(.x, na = character(), show_col_types = FALSE))

# name the list elements with file names
names(user_data_dfs) <- user_data_files

# =============================== run function =================================

populated_data <- populate_header_rows(data_dfs = user_data_dfs, 
                                        header_row_input_file = user_header_row_input_file)

# ========================= output populated data files ========================

output_files <- populated_data[names(populated_data) != "Reminders"]

# overwrites existing file with populated file
iwalk(output_files, ~ write_csv(.x, .y, na = ''))

view(populated_data$Reminders)

# ============================= Reminders =================================
# The reminders are meant to help the user comply with the reporting formats. 
# We recommend the user take action when applicable. 

# The directory is included in case there are multiple files with the same name. If 
# there are not duplicate file names, this column can be disregarded

# The column names indicate the reminder. The rows indicate the file. 0 indicates
# the reminder is NOT applicable to the associated file. 1 indicates the reminder
# is applicable to the associated file.

# Definitions: 
# - populate_empty_cells: there are empty cells in you file; it is recommended to 
#                         -9999 for numeric columns and N/A for non-numeric columns
# - populate_header_rows: there are cells in the header rows that must be populated
# -ignored_extra_header_input: if provided, the header rows input file contained 
#                              additional information that was ignored 