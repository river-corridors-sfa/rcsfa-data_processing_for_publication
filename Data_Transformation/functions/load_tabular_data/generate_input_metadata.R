### generate_input_metadata.R ##################################################
# Date Created: 2024-04-19
# Date Updated: 2024-04-19
# Author: Bibi Powers-McCormack

# Objective: 
  # Temporarily read in a file
  # Ask user to indicate the location of header rows and the data matrix 
  # Return a df with that metadata

# Inputs: 
  # file path
  # user inputs provided via inline prompts

# Outputs: 
  # input_metadata_report df that returns 4 cols
    # file_path
    # file_name
    # column_or_row_name_position
    # header_rows

# Assumptions: 
  # the file extension is .csv or .tsv
  # there is a single data matrix
  # the file is organized with column headers (not row headers)
  # there can be header rows above and/or below the column headers


### generate_input_metadata function ###########################################

generate_input_metadata <- function(file_path) {
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(fs)
  
  # get file extension
  current_file_path <- file_path
  current_file_extension <- fs::path_ext(current_file_path)
  
  # read in raw data file
  log_info(paste0("Reading in '", basename(current_file_path), "'"))
  
  if (current_file_extension == "tsv") {
    
    # read in tsv
    current_data <- read_tsv(current_file_path, show_col_types = F, name_repair = "minimal", col_names = F)
    
  } else if (current_file_extension == "csv") {
    
    # read in csv
    current_data <- read_csv(current_file_path, show_col_types = F, name_repair = "minimal", col_names = F)
    
  }
  
  # initialize empty return df
  input_metadata_report <- data.frame(file_path = as.character(),
                                      file_name = as.character(),
                                      column_or_row_name_position = as.numeric(), # row line of the column headers
                                      header_rows = as.numeric()) # this is header rows after the column header and before the data
  
  # show data
  View(current_data)
  
  # ask user about column header position
  user_prompt_column_header_position <- readline(prompt = "What row number are the column headers on? ")
  
  # ask user about header rows after the header
  user_prompt_data_start <- readline(prompt = "What row number does the data matrix start on? ")
  
  # calculate header rows from user prompt information
  header_rows <- as.numeric(user_prompt_data_start) - as.numeric(user_prompt_column_header_position) - 1
  
  # store the user inputs with the report df
  input_metadata_report <- input_metadata_report %>% 
    add_row(file_path = current_file_path,
            file_name = basename(current_file_path),
            column_or_row_name_position = as.numeric(user_prompt_column_header_position),
            header_rows = as.numeric(header_rows))
  
  log_info("generate_input_metadata complete.")
  
  # return input_metadata_report df
  return(input_metadata_report)
  
  
}



file_path <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/PROJECTS/Get IGSNs for Joan Use Case/ECA2_Sediment/ECA2_NPOC_TN_Moisture.csv"
generate_input_metadata(file_path)
