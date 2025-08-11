# ==============================================================================
#
# create_format.R function for formatting the users data in the soil, sediment, 
# water chemistry or hydrologic monitoring formats. 
#
# Status: in progress
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#

# Notes
# - add ability to have long data 
# - add logging 
# - add more documentation 
# ==============================================================================

require(pacman)
p_load(tidyverse,
       rlog,
       tools)

# ================================ Documentation ===============================

# Inputs: 
#      - unformatted_data_file = required; unformatted data file 
#      - outdir = optional; default is dir of input files
#      - method_rows = row names for methods; could be one (i.e. 'method_id') or 
#       multiple (i.e. c(c('method_id_analysis', 'method_id_inspection', 'method_id_storage', 'method_id_preservation', 'method_id_preparation', 'method_id_dataprocessing')))

# Outputs: 
#     - formatted file will output to the indicated outdir; it will retain the original file name with "Formatted" and the date appended. 
# 

# ============================ create_format function ========================

create_format <- function(unformatted_data_file,
                          outdir = NULL,
                          method_rows = 'method_id'){
  
  
  if(is.null(outdir)){
    
    outdir <- unique(dirname(unformatted_data_file))
    
    # need to add validation that provided outdir is a path that exists and errors if outdir give more than one 
    
  }
  
  
  ## ---- loop through files ----
  for (file in unformatted_data_file) {
    
    data <- read_csv(file)
    
    formatted_data <- data %>%
      add_column('field_name' = 'N/A', .before = 1)
    
    column_names <- data %>%
      add_column('#field_name', .before = 1) %>%
      colnames()

    
    row_headers <- c("#unit", "#unit_basis", method_rows, "#analysis_detection_limit", "#analysis_precision", "#data_status")
    
    # Create the header
    header_rows <- tibble(
      `#field_name` = row_headers,
      !!!map(column_names[-1], ~ rep('', length(row_headers))) %>% 
        setNames(column_names[-1])
    ) %>%
      # add "#" to any rows if they are missing
      mutate(`#field_name` = case_when(
        str_starts(`#field_name`, "#") ~ `#field_name`,
        TRUE ~ paste0("#", `#field_name`)
      )) %>%
      # fill in methods_devitaions, notes, sample_name, IGSN with N/A
      mutate(across(matches("methods_deviation|notes|sample_name|igsn", ignore.case = TRUE), ~ 'N/A'))
    
    
    # write file to outdir, append "Formatted" and date to file name
    out_file <- file.path(outdir, paste0(file_path_sans_ext(basename(file)), '_Formatted_', Sys.Date(), '.csv'))
    
    write_csv(header_rows, out_file)
    
    write_csv(formatted_data, out_file, append = T, col_names = T)

    
  }
  
  

}