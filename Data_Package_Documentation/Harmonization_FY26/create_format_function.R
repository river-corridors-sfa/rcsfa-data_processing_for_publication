# ==============================================================================
#
# Function for formatting the users data in the soil, sediment, 
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
# - add ability to have long data - need to discuss w amy
# ==============================================================================

require(pacman)
p_load(tidyverse,
       rlog,
       tools,
       cli)

# ================================ Documentation ===============================
# Inputs: 
#      - unformatted_data_file = required; unformatted data file 
#      - outdir = optional; default is dir of input files
#      - method_rows = row names for methods; could be one (i.e. 'method_id') or 
#       multiple (i.e. c('method_id_analysis', 'method_id_inspection', 'method_id_storage', 'method_id_preservation', 'method_id_preparation', 'method_id_dataprocessing'))

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
    
    log_info(paste0("Formatting file ", match(file, unformatted_data_file), " of ", length(unformatted_data_file)))
    
    data <- read_csv(file, na = character())
    
    formatted_data <- data %>%
      add_column('field_name' = 'N/A', .before = 1)
    
    # if(towlower(input_format) == 'long'){
    #   
    #   
    #   
    # 
    #   
    # }
    
    column_names <- data %>%
      add_column('#field_name', .before = 1) %>%
      colnames()
    
    
    ### ---- create header ----
    if(is.null(method_rows)){
      
      method_rows <- 'method_id'
      
    }

    
    row_headers <- c("#unit", "#unit_basis", method_rows, "#analysis_detection_limit", "#analysis_precision", "#data_status")

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
    
    ### ---- checks ----
    # check for missing values and asks if wish to proceed if cell is empty
    
   missing_value_check <- data %>% 
      summarise(across(everything(), ~ any(is.na(.x) | .x == "" | str_trim(.x) == ""))) %>%
      any()
    
    if(missing_value_check == TRUE){
      
      cli_alert_danger('There are emtpy cells in your dataset, do you wish to proceed with outputting the formatted data?')
      
      user_input <- readline(prompt = "Y/N?: ") 
      
      if(tolower(user_input) == 'n'){
        
        stop('Function terminating. Data not outputted.')
        
        
      } else{
        
        cli_alert_warning('To comply with the reporting format, you must fill in the empty cells.')
        cli_alert('For missing values, it is recommended to use -9999 for numeric columns and N/A for character columns.')
        
      }
      
    }
    
    
    ### ---- reminder ----
    #reminder to check datetime column format
    
    if(any('datetime' %in% tolower(colnames(data)))){
      
      cli_alert_warning('Reminder to check the DateTime format. It is recommended to use YYYY-MM-DD hh:mm:ss and report the UTC offset in the unit.')
      
    }
    
    #reminder to check date column format
    
    if(any('date' %in% tolower(colnames(data)))){
      
      cli_alert_warning('Reminder to check the date format. It is recommended to use YYYY-MM-DD.')
      
    }
    
    #reminder to include precision and utc offset in time column unit
    if(any('time' %in% tolower(colnames(data)))){
      
      cli_alert_warning('You have a time column. It is recommended to report the precision (hh; hh:mm; hh:mm:ss) and the UTC offset in the unit.')
      
    }
    
    #reminder to include coordinate reference system in lat/long column unit
    if(any('latitude' %in% tolower(colnames(data)))|any('longitude' %in% tolower(colnames(data)))){
      
      cli_alert_warning('You have a latitude and/or longitude column. It is recommended to report the coordinate reference system in the unit.')
      
    }
    
    
    ### ---- write files ----
    
    # write file to outdir, append "Formatted" and date to file name
    out_file <- file.path(outdir, paste0(file_path_sans_ext(basename(file)), '_Formatted_', Sys.Date(), '.csv'))
    
    write_csv(header_rows, out_file)
    
    write_csv(formatted_data, out_file, append = T, col_names = T, na = '')
    
    cli_alert_success('File has been outputted. The user should now populate the metadata header rows.')

    
  }
  
  

  }
