# ==============================================================================
#
# Function to read in data and metadata that are formatted in compliance with the 
# Soil, Sediment, Water and/or Hydrologic Monitoring reporting formats
#
# Status:  needs review
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#
# ==============================================================================

require(pacman)
p_load(tidyverse,
       rlog)

# ================================ Documentation ===============================

# Inputs: 
# - data_files = required; list of absolute file path(s) of data files that are compliant with the reporting formats 
# - methods_file = optional; default = NA; methods file associated with the data file(s)
# - missing_value_codes = optional; default = c('N/A', '-9999'); list of codes that indicate missing values
  
# Outputs: 
# List that includes the following for each input file
#   - data = the data file with metadata header rows removed
#   - metadata = the metadata header rows extracted from the data file 
#   - long_metadata = a pivoted long version of the metadata header rows; if a methods file 
#                   was provided, this will include additional details from that file
#   - metadata_transposed =  the metadata header rows extracted from the data file but transposed
#                          so that each row is the metadata for a column

# ============================ read_in_formats function ========================

read_in_formats <- function(data_files, 
                            methods_file = NA,
                            missing_value_codes = NULL){
  
  ## ---- Input validation ----
  # Check that data_files is provided and not empty
  if(missing(data_files) || length(data_files) == 0) {
    stop("data_files parameter is required and cannot be empty")
  }
  
  # Check file existence
  missing_files <- data_files[!file.exists(data_files)]
  if(length(missing_files) > 0) {
    stop(paste("Files not found:", paste(missing_files, collapse = ", ")))
  }
  
  # Validate that all files are CSV files
  non_csv_files <- data_files[!grepl("\\.csv$", data_files, ignore.case = TRUE)]
  if(length(non_csv_files) > 0) {
    stop(paste("Only CSV files are supported. Non-CSV files found:", paste(non_csv_files, collapse = ", ")))
  }
  
  # Check methods file if provided
  if(!is.na(methods_file)) {
    if(!file.exists(methods_file)) {
      stop(paste("Methods file not found:", methods_file))
    }
    if(!grepl("\\.csv$", methods_file, ignore.case = TRUE)) {
      stop(paste("Methods file must be a CSV file:", methods_file))
    }
  }
  
  ## ---- initiate output list ----
  output <- list()
  
  ## ---- define missing value codes ----
  if(is.null(missing_value_codes)){
    
    missing_value_codes <- c('N/A', '-9999')
    
  }
  
  log_info(paste0("Using the following missing value codes: ", paste(missing_value_codes, collapse = ', ')))
  
  ## ---- loop through files ----
  for(data_file in data_files){
    
    log_info(paste0("Parsing file ", match(data_file, data_files), " of ", length(data_files)))
    
    # Enhanced error handling for file reading
    tryCatch({
      # read in data, skipping metadata rows, changing all missing value codes to NA, drop field_name column
      data <- read_csv(data_file, comment = '#', na = missing_value_codes, show_col_types = F) %>%
        select(-matches("field_name", ignore.case = TRUE))
      
      # read in metadata rows, changing all missing value codes to NA
      metadata <- read_csv(data_file, na = missing_value_codes, show_col_types = F) %>%
        filter(if_any(matches("field_name", ignore.case = TRUE), ~ str_starts(.x, "#"))) %>%
        rename_with(~ str_remove(.x, "^#"), starts_with("#")) %>%
        mutate(across(matches("field_name", ignore.case = TRUE), ~ str_remove(.x, "#"))) 
      
    }, error = function(e) {
      log_error(paste("Failed to read file:", data_file, "Error:", e$message))
      next  # Skip to next file if this one fails
    })
    
    # Check if data was successfully read
    if(!exists("data") || nrow(data) == 0) {
      log_warn(paste("No data found in file:", data_file))
      next
    }
    
    # Check if metadata was found
    if(!exists("metadata") || nrow(metadata) == 0) {
      log_warn(paste("No metadata found in file:", data_file))
      # Create empty metadata structure to maintain consistency
      metadata <- tibble()
    }
    
    tryCatch({
      long_metadata <- metadata %>%
        select(-any_of(c("methods_deviation", "notes")))%>%
        rename(metadata_piece = any_of(c("field_name", "Field_Name"))) %>%
        pivot_longer(cols = -metadata_piece,
                     names_to = 'column_name')
      
      # transpose metadata so that the column names become a column and the metadata 
      # pieces are columns
      metadata_transposed <- metadata %>%
        column_to_rownames(var = names(.)[1]) %>%  
        t() %>%                                    
        as.data.frame() %>%                        
        rownames_to_column('column_name') %>%                  
        as_tibble()
      
    }, error = function(e) {
      log_error(paste("Failed to process metadata for file:", data_file, "Error:", e$message))
      # Create empty structures if metadata processing fails
      long_metadata <- tibble()
      metadata_transposed <- tibble()
    })
    
    if(!is.na(methods_file)){ # if a methods file exists, it will append the information to the long_metadata
      
      tryCatch({
        methods <- read_csv(methods_file, na = missing_value_codes, show_col_types = F)
        
        long_metadata <- long_metadata  %>%
          rename_with(~ case_when(
            tolower(.x) == "method_id" ~ "method_id", # renames column if capitalized differently
            TRUE ~ .x
          )) %>%
          left_join(methods, by = c('value' = 'method_id'))%>% # join long data to methods
          select(where(~ !all(is.na(.x)))) # drop columns that are all na
        
      }, error = function(e) {
        log_error(paste("Failed to read or join methods file:", methods_file, "Error:", e$message))
        # Continue without methods data
      })
      
    } # end of methods file
    
    ### ---- create output ----
    # get name of file
    file_name <- basename(data_file)
    
    # add data and metadata to the output
    output[[file_name]] <- list(
      data = data,
      metadata = metadata,
      long_metadata = long_metadata,
      metadata_transposed = metadata_transposed,
      full_file_path = data_file
    )
    
    # Clean up temporary variables for next iteration
    if(exists("data")) rm(data)
    if(exists("metadata")) rm(metadata)
    if(exists("long_metadata")) rm(long_metadata)
    if(exists("metadata_transposed")) rm(metadata_transposed)
    
  } # end of for loop
  
  ## ---- output list of (meta)data ----

  return(output)
  
}