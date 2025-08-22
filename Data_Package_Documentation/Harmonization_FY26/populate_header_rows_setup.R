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
# 2. Warns the user if the input file and data files don't match 
# 3. Returns a list with the data file(s) containing populated header rows

# ================================ User Inputs =================================

## ---- Required ----

# Select the formatted data file(s) you would like to format. Only formatted csv files are supported. 
# Use shift or ctrl to select multiple files.
user_data_files <- choose.files()

# Select the header row input file. You must use the specified format (see XYZ).
user_header_row_input_file <- file.choose()

# ============================== read in files =================================

user_data_dfs <- map(user_data_files, read_csv)

# name the list elements with file names
names(user_data_dfs) <- user_data_files

# =============================== run function =================================

populated_data <- populate_header_rows(data_dfs = user_data_dfs, 
                                        header_row_input_file = user_header_row_input_file)

# ========================= output populated data files ========================

# overwrites existing file with populated file
iwalk(populated_data, ~ write_csv(.x, .y))

