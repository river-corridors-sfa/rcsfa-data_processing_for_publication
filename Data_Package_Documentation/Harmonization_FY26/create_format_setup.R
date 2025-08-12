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
# 
# This function is meant to format data files to follow  v2 of the soil, sediment, 
# and water chemistry and hydrologic monitoring reporting formats.
# It will add the field_name column as well as the metadata header rows and output in 
# the indicated folder. Once outputted, the user should populate the metadata 
# header rows after running the function.

# ================================ User Inputs =================================

## ---- Required ----

# Select the data file(s) you would like to format
user_unformatted_data_file <- choose.files()

## ---- Optional ----

# Indicate the method_id row(s) you would like to include. 
# This could be one (i.e. 'method_id') or multiple (i.e. c('method_id_analysis', 
#                                                         'method_id_inspection', 
#                                                         'method_id_storage', 
#                                                         'method_id_preservation', 
#                                                         'method_id_preparation', 
#                                                         'method_id_dataprocessing'))
# If left NULL, it will include the 'method_id' row only.
user_method_rows <- NULL

# Enter the path to folder where you would like the formatted files to output. 
# If left NULL, it will default to the directory of the input. 
user_outdir <- NULL


# =============================== run function =================================

create_format(unformatted_data_file = user_unformatted_data_file,
              method_rows = user_method_rows,
              outdir = user_outdir)

