#==============================================================================
#
# Function for populating the metadata headers in the soil, sediment, 
# water chemistry or hydrologic monitoring formats. 
#
# Status: needs review
#
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 29 August 2025
#
# ==============================================================================

require(pacman)
p_load(tidyverse,
       cli,
       rChoiceDialogs)

# ================================ Documentation ===============================

# This function populates the metadata headers rows to comply with ESS-DIVE soil, sediment, 
# water chemistry, and hydrologic monitoring reporting formats (v2).

# This function:
# 1. Loops through the file and uses the input file to populate header rows in the data files 
# 2. Warns the user if the input file and data files don't match 
# 3. Returns a list with the data file(s) containing populated header rows

# Inputs: 
# - data_dfs = required; list of formatted data frames 
# - header_row_input_file = required; file path of header row input file

# Outputs: 
#  - list of 
#         > data files with header rows populated 
#         > warnings for complying with the reporting formats

# Usage Examples:
# populate_header_rows(data_frame_list, "C://header_row_input.csv")
# ============================ populate_header_rows function ========================

populate_header_rows <- function(data_dfs, 
                                 header_row_input_file){
  
  
  # Validate inputs
  if(!file.exists(header_row_input_file)) {
    stop("Header row input file does not exist: ", header_row_input_file)
  }
  if(length(data_dfs) == 0) {
    stop("No data frames provided")
  }
  
  
  # initilize output list
  output_list <- list()
  
  # initilize warnings
  warnings <- tibble(directory = dirname(names(data_dfs)),
                      file_name = basename(names(data_dfs)),
                      populate_empty_cells = 0,
                      populate_header_rows = 0,
                      ignored_extra_header_input = 0)
 
   # read in header row input
  header_row_input_all <- read_csv(header_row_input_file, show_col_types = F) %>%
    mutate(file_path = file.path(directory, file_name),
           file_path = normalizePath(file_path))
  

  
  for(file in names(data_dfs)){
    
    data_file <- data_dfs[[file]]
    
    data_directory <- dirname(file)
    
    data_file_name <- basename(file)
    
    column_names <- colnames(data_file)

    header_row_input <- header_row_input_all %>%
      filter(file_path == file)
  
  header_row_input_long <- header_row_input %>%
    select(-file_path, -directory, -file_name) %>%
    mutate(across(everything(), as.character)) %>%
    pivot_longer(-column_name) %>%
    filter(!is.na(value))%>%
    mutate(name = paste0("#", name))
  
  
  
  if(nrow(header_row_input) == 0){
    
    cli_alert_danger('The current file was not found within the header rows input file: ')
    cli_alert_info(file)
    
    stop('Function terminating.')
    
  }else{ 
    
    if(all(header_row_input$column_name %in%column_names)){ # check if all header rows in input file are in data file
      
      for(col in unique(header_row_input_long$column_name)) {
        lookup_data <- header_row_input_long %>% 
          filter(column_name == col)
        
        data_file <- data_file %>%
          mutate(!!col := case_when(
            !!sym(names(data_file)[1]) %in% lookup_data$name ~ 
              lookup_data$value[match(!!sym(names(data_file)[1]), lookup_data$name)],
            TRUE ~ !!sym(col)
          ))
      }  # end of for loop to populate header rows
      
      if(any(grepl("\\[USER MUST POPULATE\\]", data_file))){ # check if any header rows were not populated and alert
        
        warnings <- warnings %>%
          mutate(populate_header_rows = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                  TRUE ~ populate_header_rows))
        
      } # end check if any header rows were not populated and alert
      
    } else{
      
      cli_alert_danger('The input file does not contain all column names that are in the data file. ')
      stop('Function terminating.')
      
    } # end of check if all header rows in input file are in data file
    

    if(data_file %>% 
       summarise(across(everything(), ~ any(is.na(.x) | .x == "" | str_trim(.x) == ""))) %>%
       any()){    # check if any cells are empty
      
      warnings <- warnings %>%
        mutate(populate_empty_cells = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                               TRUE ~ populate_empty_cells))
      
    }    # end of check if any cells are empty

    header_row_column_check <-  column_names[column_names != "\"#field_name\""]
    header_row_column_check <-  header_row_column_check[header_row_column_check != "methods_deviation"]
    header_row_column_check <-  header_row_column_check[header_row_column_check != "notes"]
    
    if(!all(header_row_column_check %in% header_row_input$column_name)){ # check if data file contains all columns in input
      
      warnings <- warnings %>%
        mutate(ignored_extra_header_input = case_when((directory == data_directory & file_name == data_file_name) ~ 1,
                                                TRUE ~ ignored_extra_header_input))
      
    }# end of check if data file contains all columns in input
    
    
  } # end of file found
  
  output_list[[file]] <- data_file
  
  output_list[['Warnings']] <- warnings
  
  } # end for loop
  
  return(output_list)
  
}
