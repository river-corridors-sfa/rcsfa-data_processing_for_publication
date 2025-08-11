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

source()

# ================================ User Inputs =================================

unformatted_data_file <- choose.files()

method_rows <- 'method_id'

method_rows <- c('method_id_analysis', 'method_id_inspection', 'method_id_storage', 'method_id_preservation', 'method_id_preparation', 'method_id_dataprocessing')


outdir <- unique(dirname(unformatted_data_file))
