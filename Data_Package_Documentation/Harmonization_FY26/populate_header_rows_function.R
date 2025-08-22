#==============================================================================
#
# Function for populating the metadata headers in the soil, sediment, 
# water chemistry or hydrologic monitoring formats. 
#
# Status: in progress
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 17 August 2025
#
# ==============================================================================

require(pacman)
p_load(tidyverse,
       cli)

# ================================ Documentation ===============================

# This function populates the metadata headers rows to comply with ESS-DIVE soil, sediment, 
# water chemistry, and hydrologic monitoring reporting formats (v2).

# This function:
# 1. 
# 2.
# 3. 
# 4. 

# Inputs: 
# 

# Outputs: 
# 

# Usage Examples:
# 
# ============================ populate_header_rows function ========================

populate_header_rows <- function(data_df, 
                                 header_row_input_file){

  header_row_input <- read_csv(header_row_input_file) %>%
    mutate(file_path = file.path(paste0(directory, '\\',file_name))) %>%
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
        
        data_df <- data_df %>%
          mutate(!!col := case_when(
            !!sym(names(data_df)[1]) %in% lookup_data$name ~ 
              lookup_data$value[match(!!sym(names(data_df)[1]), lookup_data$name)],
            TRUE ~ !!sym(col)
          ))
      }  # end of for loop to populate header rows
      
      if(any(grepl("\\[USER MUST POPULATE\\]", data_df))){ # check if any header rows were not populated and alert
        
        cli_alert_danger('NOT ALL HEADER ROWS WERE POPULATED BECAUSE THEY WERE MISSING FROM THE INPUT FILE.')
        cli_alert_danger('YOU MUST POPULATE THE REMAINING HEADER ROWS AFTER IT IS OUTPUTTED.')
        
      } # end check if any header rows were not populated and alert
      
    } else{
      
      cli_alert_danger('The input file does not contain all header rows in the data file. ')
      stop('Function terminating.')
      
    } # end of check if all header rows in input file are in data file
    
    header_row_column_check <-  column_names[column_names != "\"#field_name\""]
    header_row_column_check <-  header_row_column_check[header_row_column_check != "methods_deviation"]
    header_row_column_check <-  header_row_column_check[header_row_column_check != "notes"]
    
    if(!all(header_row_column_check %in% header_row_input$column_name)){ # check if data file contains all columns in input
      
      cli_alert_warning('The input file contains column names that are not in the data file and are being ignored.')
      
    }# end of check if data file contains all columns in input
    
    
  } # end of file found
  
  return(data_df)
  
}
