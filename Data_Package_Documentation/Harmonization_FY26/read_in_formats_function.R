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

# ============================ read_in_formats function ===========================

read_in_formats <- function(data_files, 
                            methods_file = NA,
                            missing_value_codes = 'default'){
  
  
  ## ---- initiate output list ----
  output <- list()

  ## ---- define missing value codes ----
  if(length(user_missing_value_codes) == 1 && user_missing_value_codes == "default"){
    
    missing_value_codes <- c('N/A', '-9999')
    
  } else{
    
    missing_value_codes <- user_missing_value_codes
  } # end off missing value codes
  
  log_info(paste0("Using the following missing value codes: ", paste(missing_value_codes, collapse = ', ')))
  
  ## ---- loop through files ----
  for(data_file in data_files){
    
    log_info(paste0("Parsing file ", match(data_file, data_files), " of ", length(data_files)))
    
    # read in data, skipping metadata rows, changing all missing value codes to NA, drop field_name column
    data <- read_csv(data_file, comment = '#', na = missing_value_codes, show_col_types = F) %>%
      select(-matches("field_name", ignore.case = TRUE))
    
    # read in metadata rows, changing all missing value codes to NA
    metadata <- read_csv(data_file, na = missing_value_codes, show_col_types = F) %>%
      filter(if_any(matches("field_name", ignore.case = TRUE), ~ str_starts(.x, "#"))) %>%
      rename_with(~ str_remove(.x, "^#"), starts_with("#")) %>%
      mutate(across(matches("field_name", ignore.case = TRUE), ~ str_remove(.x, "#"))) 
    
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
    
    if(!is.na(methods_file)){ # if a methods file exists, it will append the information to the long_metadata
      
      methods <- read_csv(methods_file, na = missing_value_codes, show_col_types = F)
      
      long_metadata <- long_metadata  %>%
        rename_with(~ case_when(
          tolower(.x) == "method_id" ~ "method_id", # renames column if capitalized differently
          TRUE ~ .x
        )) %>%
        left_join(methods, by = c('value' = 'method_id'))%>% # join long data to methods
        select(where(~ !all(is.na(.x)))) # drop columns that are all na
      
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

## ---- output list of (meta)data ----
return(output)
  
  } # end of for loop
  
}