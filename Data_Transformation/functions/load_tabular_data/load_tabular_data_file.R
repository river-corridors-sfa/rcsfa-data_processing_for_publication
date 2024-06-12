### load_tabular_data_file.R ###################################################
# Date Created: 2024-04-19
# Date Updated: 2024-04-19
# Author: Bibi Powers-McCormack

# Objective: Reads in input metadata file and uses it to correctly read in the file 

# Inputs: 
  # input_metadata_report df (the return of the generate_input_metadata.R function)

# Outputs: 
  # df from the file path provided

# Assumptions: 
  # the file extension is .csv or .tsv
  # there is a single data matrix
  # the file is organized with column headers (not row headers)
  # there can be header rows above and/or below the column headers


### load_tabular_data_file function ############################################

load_tabular_data_file <- function(input_metadata_report_df){
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(fs)
  
  current_input_report <- input_metadata_report_df
  
  # initialize empty list to store dfs in
  load_tabular_data_files <- list(
    input_metadata_report = input_metadata_report_df
  )
  
  for (i in 1:nrow(current_input_report)) {
    
    # extract values from user inputs
    
    # get current file path
    current_file_path <- current_input_report[i, 1]
    
    # get current file name
    current_file_name <- current_input_report[i, 2]
    
    # get current header position
    current_column_or_row_name_position <- current_input_report[i, 3]
    
    # get current header row count
    current_header_rows <- current_input_report[i, 4]
    
    # get file extension
    current_file_extension <- fs::path_ext(current_file_path)
    
    # calculate values needed for reading in data
    number_of_rows_to_skip_before_headers <- current_column_or_row_name_position - 1
    
    # read in data file
    log_info(paste0("Reading in file ", i, " of ", nrow(current_input_report), ": '", current_file_name, "'"))
    
    if (current_file_extension == "tsv") {
      
      # read in tsv
      current_data <- read_tsv(current_file_path, show_col_types = F, name_repair = "minimal", col_names = T, skip = number_of_rows_to_skip_before_headers)
      
    } else if (current_file_extension == "csv") {
      
      # read in csv
      current_data <- read_csv(current_file_path, show_col_types = F, name_repair = "minimal", col_names = T, skip = number_of_rows_to_skip_before_headers)
      
    }
    
    # trim off any header rows between column headers and data matrix
    current_data <- current_data %>% 
      tail(-current_header_rows)
   
    
    # add df to list
    load_tabular_data_files[[current_file_name]] <- as.data.frame(current_data)
    
  }
  
  log_info("load_tabular_data_file complete.")
  
  return(load_tabular_data_files)
  
  
}

file_path <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/PROJECTS/Get IGSNs for Joan Use Case/ECA2_Sediment/ECA2_NPOC_TN_Moisture.csv"
input_report <- generate_input_metadata(file_path)
DATA_ARE_LOADED_IN_WOOHOO <- load_tabular_data_file(input_report)




