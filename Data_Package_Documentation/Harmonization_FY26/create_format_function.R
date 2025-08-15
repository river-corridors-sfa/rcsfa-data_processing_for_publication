# ==============================================================================
#
# Function for formatting the users data in the soil, sediment, 
# water chemistry or hydrologic monitoring formats. 
#
# Status: in progress
#
# - make header rows  say "[USER MUST POPULATE]" instead of blank
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#
# ==============================================================================

require(pacman)
p_load(tidyverse,
       rlog,
       tools,
       cli)

# ================================ Documentation ===============================

# This function formats raw data files to comply with ESS-DIVE soil, sediment, 
# water chemistry, and hydrologic monitoring reporting formats (v2).

# This function:
# 1. Adds a 'field_name' column as the first column
# 2. Creates metadata header rows with standard field names
# 3. Validates data for empty cells and provides warnings
# 4. Outputs formatted file with metadata rows that need to be populated

# Inputs: 
# - unformatted_data_file = required; vector of file path(s) to CSV data files (files must be in wide format)
# - outdir = optional; output directory path. Default: same directory as input files
# - method_rows = optional; method ID row names to include in metadata headers.
#                 Default: NULL (uses 'method_id' only)
#                 Examples: 'method_id' OR c('method_id_analysis', 'method_id_storage')

# Outputs: 
# - CSV file(s) in specified directory with format: [originalname]_Formatted_YYYY-MM-DD.csv
# - Files contain metadata header rows (empty, to be populated) + formatted data

# Usage Examples:
# create_format("C://data.csv")  # Basic usage
# create_format(c("C://file1.csv", "C://file2.csv"), outdir = "C://output")  # Multiple files
# create_format("C://data.csv", method_rows = c("method_id_analysis", "method_id_storage"))# Multiple method id rows
# ============================ create_format function ========================

create_format <- function(unformatted_data_file,
                          outdir = NULL,
                          method_rows = NULL){


  ## ---- Input validation ----
  
  # Check that unformatted_data_file is provided and not empty
  if(missing(unformatted_data_file) || length(unformatted_data_file) == 0) {
    stop("unformatted_data_file parameter is required and cannot be empty")
  }
  
  # Validate that all files are CSV files
  non_csv_files <- unformatted_data_file[!grepl("\\.csv$", unformatted_data_file, ignore.case = TRUE)]
  if(length(non_csv_files) > 0) {
    stop(paste("Only CSV files are supported. Non-CSV files found:", paste(non_csv_files, collapse = ", ")))
  }
  
  # Validate outdir if provided
  if(!is.null(outdir)) {
    if(length(outdir) > 1) {
      stop("outdir must be a single directory path")
    }
    if(!dir.exists(outdir)) {
      stop(paste("Output directory does not exist:", outdir))
    }
  } else if(is.null(outdir)){
    outdir <- unique(dirname(unformatted_data_file))
    
    if(length(outdir)<1){
      
      stop("Input files are in multiple directories.\nOnly one directory can be used for the output.\nNo out directory was provided.")
    }
    
  }
  
  
  ## ---- loop through files ----
  for (file in unformatted_data_file) {
    
    log_info(paste0("Formatting file ", match(file, unformatted_data_file), " of ", length(unformatted_data_file)))

    data <- tryCatch({
      suppressWarnings(read_csv(file, na = character(), show_col_types = F))
    }, error = function(e) {
      stop(paste("Failed to read file:", basename(file), "-", e$message))
    })
    
    formatted_data <- data %>%
      add_column('field_name' = 'N/A', .before = 1)
    
    
    column_names <- data %>%
      add_column('#field_name', .before = 1) %>%
      colnames()
    
    
    ### ---- create header ----
    if(is.null(method_rows)){
      
      method_rows <- 'method_id'
      
    }

    
    row_headers <- c("#unit", "#unit_basis", method_rows, "#analysis_detection_limit", "#analysis_precision", "#data_status")

    header_rows <- tryCatch({
      tibble(
        `#field_name` = row_headers,
        !!!map(column_names[-1], ~ rep('', length(row_headers))) %>% 
          setNames(column_names[-1])
      ) %>%
        # add "#" to any rows if they are missing
        mutate(`#field_name` = case_when(
          str_starts(`#field_name`, "#") ~ `#field_name`,
          TRUE ~ paste0("#", `#field_name`)
        )) %>%
        # fill in methods_deviations, notes, sample_name, IGSN with N/A
        mutate(across(matches("methods_deviation|notes|sample_name|igsn", ignore.case = TRUE), ~ 'N/A'))
    }, error = function(e) {
      stop(paste("Failed to create header rows:", e$message))
    })
    
    ### ---- checks ----
    # check for missing values and asks if wish to proceed if cell is empty
    
   missing_value_check <- data %>% 
      summarise(across(everything(), ~ any(is.na(.x) | .x == "" | str_trim(.x) == ""))) %>%
      any()
    
    if(missing_value_check == TRUE){
      
      cli_alert_danger('ALERT: There are empty cells in your dataset, do you wish to proceed with outputting the formatted data?')
      
      user_input <- readline(prompt = "Y/N?: ") 
      
      if(tolower(user_input) == 'n'){
        
        stop('Function terminating. Data not outputted.')
        
        
      } else{
        
        cli_alert_warning('REMINDER: To comply with the reporting format, you must fill in the empty cells.')
        cli_alert('For missing values, it is recommended to use -9999 for numeric columns and N/A for character columns.')
        
      }
      
    }
    
    # if sample column exists, check for duplicates 
    if(any(str_detect(column_names, 'sample'))){   
     
      sample_dup_check <-  data %>%
        select(contains('sample')) %>%
        summarise(across(everything(), ~ any(duplicated(.x)))) 
      
      overall_check <- sample_dup_check %>%
        summarise(any_duplicates_found = any(c_across(everything()))) %>%
        pull()
      
      if(overall_check == TRUE){
        
        cli_alert_danger(paste0(
          'ALERT: There are duplicate values in the following sample column(s): ',
          paste0(sample_dup_check %>%
                   select(where( ~ .x == TRUE)) %>%
                   colnames(), collapse = ', ')
        ))
        
      }
      
       
    }
    ### ---- compile column names for reminders ----
    
    if(match(file, unformatted_data_file) == 1){
      
      all_colnames <- as_tibble(column_names)
      
    } else {
      
      all_colnames <- all_colnames %>%
        add_row(value = column_names)
      
    }

    
    ### ---- write files ----
    
    # write file to outdir, append "Formatted" and date to file name
    out_file <- file.path(outdir, paste0(file_path_sans_ext(basename(file)), '_Formatted_', Sys.Date(), '.csv'))
    
    tryCatch({
      write_csv(header_rows, out_file)
      write_csv(formatted_data, out_file, append = T, col_names = T, na = '')
    }, error = function(e) {
      stop(paste("Failed to write output file:", basename(out_file), "-", e$message))
    })
    
    
    cli_alert_success(paste0(file_path_sans_ext(basename(file)), '_Formatted_', Sys.Date(), '.csv', ' has been outputted.'))

    
  }
  
  all_colnames <- all_colnames %>%
    distinct %>%
    pull() %>%
    tolower()
  

  ### ---- reminder ----
  #reminder to check datetime column format

  if(any('datetime' %in% all_colnames)){

    cli_alert_warning('REMINDER: Check the DateTime format. It is recommended to use YYYY-MM-DD hh:mm:ss and report the UTC offset in the unit.')

  }

  #reminder to check date column format

  if(any('date' %in% all_colnames)){

    cli_alert_warning('REMINDER: Check the date format. It is recommended to use YYYY-MM-DD.')

  }

  #reminder to include precision and utc offset in time column unit
  if(any('time' %in% all_colnames)){

    cli_alert_warning('REMINDER: It is recommended to report the precision (hh; hh:mm; hh:mm:ss) and the UTC offset in the unit for your time column.')

  }

  #reminder to include coordinate reference system in lat/long column unit
  if(any('latitude' %in% all_colnames)|any('longitude' %in% all_colnames)){

    cli_alert_warning('REMINDER: For your latitude and/or longitude column, it is recommended to report the coordinate reference system in the unit. Reminder to use the Locations Reporting Format if appropriate.')

  }

  #reminder to use samples reporting format
  if(any(str_detect(all_colnames, 'sample'))){

    cli_alert_warning('REMINDER: Use the Samples Reporting Format if appropriate.')

  }

  #reminder to use controlled vocab for material column
  if(any('material' %in% all_colnames)){

    cli_alert_warning('REMINDER: Use the controlled vocab from the Samples Reporting Format for the material column.')

  }


  cli_alert_danger('REMINDER: YOU MUST NOW POPULATE THE METADATA HEADER ROWS IN THE OUTPUTTED FILES.')
  

  }

