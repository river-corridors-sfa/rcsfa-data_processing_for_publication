# ==============================================================================
#
# Function for formatting the users data in the soil, sediment, 
# water chemistry or hydrologic monitoring formats. 
#
# Status: needs review
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 29 August 2025
#
# ==============================================================================

require(pacman)
p_load(tidyverse,
       rlog,
       tools,
       cli,
       tcltk)

# ================================ Documentation ===============================

# This function formats raw data files to comply with ESS-DIVE soil, sediment, 
# water chemistry, and hydrologic monitoring reporting formats (v2).

# This function:
# 1. Adds a 'field_name' column as the first column
# 2. Creates metadata header rows with standard field names
# 3. Validates data  and provides reminders for complying with the reporting formats
# 4. Outputs formatted file with metadata rows that need to be populated

# Inputs: 
# - unformatted_data_file = required; vector of file path(s) to CSV data files (files must be in wide format)
# - outdir = optional; output directory path. Default: same directory as input files
# - method_rows = optional; method ID row names to include in metadata headers.
#                 Default: NULL (uses 'method_id' only)
#                 Examples: 'method_id' OR c('method_id_analysis', 'method_id_storage')
# - populate_header_rows_indicate = optional; T/F; indicate if you would like to populate the header rows with the input file
#                 Default: FALSE (header rows will not be populated)
# - populate_header_rows_input = optional; must provide if populate_header_rows_indicate == T; Path to the header row input file
#                 Default: NULL 

# Outputs: 
# - CSV file(s) in specified directory with format: [originalname]_Formatted_YYYY-MM-DD.csv
#           > Files contain metadata header rows (empty, to be populated) + formatted data
# - reminders for complying with the reporting formats

# Usage Examples:
# create_format("C://data.csv")  # Basic usage
# create_format(c("C://file1.csv", "C://file2.csv"), outdir = "C://output")  # Multiple files
# create_format("C://data.csv", method_rows = c("method_id_analysis", "method_id_storage"))# Multiple method id rows
# ============================ create_format function ========================

create_format <- function(unformatted_data_file,
                          outdir = NULL,
                          method_rows = NULL,
                          populate_header_rows_indicate = F,
                          populate_header_rows_input = NULL){


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
    
    if(length(outdir)>1){
      
      stop("Input files are in multiple directories.\nOnly one directory can be used for the output.\nNo out directory was provided.")
    }
    
  }
  
  #initialize reminders
  reminders <- tibble(directory = dirname(unformatted_data_file),
                      file_name = basename(unformatted_data_file),
                      populate_empty_cells = 0,
                      populate_header_rows = 0,
                      ignored_extra_header_input = 0,
                      confirm_date_format = 0,
                      confirm_time_format = 0,
                      report_utc_offset = 0,
                      confirm_datetime_format = 0,
                      use_sample_rf = 0,
                      confirm_material_vocab = 0,
                      fix_duplicate_sample = 0,
                      use_location_rf = 0,
                      report_crs = 0
                      )
  
  ## ---- loop through files ----
  for (file in unformatted_data_file) {
    
    data_directory <- dirname(file)
    
    data_file_name <- basename(file)
    
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
        !!!map(column_names[-1], ~ rep('[USER MUST POPULATE]', length(row_headers))) %>% 
          setNames(column_names[-1])
      ) %>%
        # add "#" to any rows if they are missing
        mutate(`#field_name` = case_when(
          str_starts(`#field_name`, "#") ~ `#field_name`,
          TRUE ~ paste0("#", `#field_name`)
        )) %>%
        # fill in methods_deviations, notes, sample_name, IGSN with N/A
        mutate(across(matches("methods_deviation|notes|sample_name|igsn|material", ignore.case = TRUE), ~ 'N/A'))
    }, error = function(e) {
      stop(paste("Failed to create header rows:", e$message))
    })
    
    ### ---- populate header rows ----
    
    if(populate_header_rows_indicate == T){
      
      if(is.null(populate_header_rows_input)){
        
        cli_alert_danger('Header rows input file not provided.')
        
        stop('Function terminating. Data not outputted.')
        
      }
      
      # make list for input
      header_row_list <- list()
      header_row_list[[file]] <- header_rows
      
      
      populated_header_rows <- populate_header_rows(data_dfs = header_row_list,
                                          header_row_input_file = populate_header_rows_input)
      #extract header rows from list 
      header_rows <- populated_header_rows[[file]]
      
      # join reminders
      reminders <- reminders %>%
        left_join(populated_header_rows$Reminders, by = c('directory', 'file_name')) %>%
        mutate(across(ends_with('.x'), ~ pmax(.x, 
                                              get(str_replace(cur_column(), '\\.x$', '.y')), na.rm = TRUE),
                      .names = "{str_replace(.col, '\\\\.x$', '')}")) %>%
        select(-ends_with('.x'), -ends_with('.y'))
      
    } # end of populating header rows
    

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

    
    
    ## ---- reminder ----
    
    #### empty cells ----
    
    if(formatted_data %>% 
       summarise(across(everything(), ~ any(is.na(.x) | .x == "" | str_trim(.x) == ""))) %>%
       any()){    # check if any cells are empty
      
      reminders <- reminders %>%
        mutate(populate_empty_cells = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                TRUE ~ populate_empty_cells))
      
    }    # end of check if any cells are empty
    
    #### sample ----
    if(any(str_detect(column_names, 'sample'))){   
      
      reminders <- reminders %>%
        mutate(use_sample_rf = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                         TRUE ~ use_sample_rf))
      
      sample_dup_check <-  data %>%
        select(contains('sample')) %>%
        summarise(across(everything(), ~ any(duplicated(.x)))) 
      
      overall_check <- sample_dup_check %>%
        summarise(any_duplicates_found = any(c_across(everything()))) %>%
        pull()
      
      if(overall_check == TRUE){
        
        reminders <- reminders %>%
          mutate(fix_duplicate_sample = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                  TRUE ~ fix_duplicate_sample))
        
      }
      
      
    } # end sample  
    
    ### datetime ----
    
    if(any('datetime' %in% colnames(formatted_data))){
      
      reminders <- reminders %>%
        mutate(confirm_datetime_format = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                   TRUE ~ confirm_datetime_format),
               report_utc_offset = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                             TRUE ~ report_utc_offset))
      
    } # end of datetime
    
    ### date ----
    
    if(any('date' %in% colnames(formatted_data))){
      
      reminders <- reminders %>%
        mutate(confirm_date_format = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                               TRUE ~ confirm_date_format))
      
    }
    
    ### time ----
    if(any('time' %in% colnames(formatted_data))){
      
      reminders <- reminders %>%
        mutate(confirm_time_format = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                               TRUE ~ confirm_time_format),
               report_utc_offset = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                             TRUE ~ report_utc_offset))
    }
    
    ### lat/long ----
    if(any('latitude' %in% colnames(formatted_data))|any('longitude' %in% colnames(formatted_data))){
      
      reminders <- reminders %>%
        mutate(report_crs = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                      TRUE ~ report_crs))
    }
    
    ### material ----
    if(any('material' %in% colnames(formatted_data))){
      
      reminders <- reminders %>%
        mutate(confirm_material_vocab = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                  TRUE ~ confirm_material_vocab))
      
    }
    
    if(populate_header_rows_indicate == F){
      
      reminders <- reminders %>%
        mutate(populate_header_rows = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                  TRUE ~ populate_header_rows)) %>%
        select(-ignored_extra_header_input)
    }
    
    
  } # end file loop
  
  return(reminders)

  } # end function

