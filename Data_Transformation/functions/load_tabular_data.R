### load_tabular_data.R ########################################################
# Date Created: 2024-01-31
# Author: Bibi Powers-McCormack

# Objective: 
  # A function where you provide a directory and in return, get...
    # a list of the files within
    # a list of the relative files within
    # the tabular data as a list
    # the headers of the tabular data

# Inputs: 
  # directory

# Outputs: 
  # a single list with the following
    # string of all file names
    # string of all file names (relative)
    # list of tabular data
    # df that has 2 columns: header, file


### FUNCTION ###################################################################

load_tabular_data <- function(directory) {
  
  ### Prep Script ##############################################################
  
  # load libaries
  library(tidyverse)
  library(rlog)
  library(fs) # for getting file extension
  
  # load user inputs
  current_directory <- directory

  
  ### List Files ###############################################################
  
  # get parent directory
  current_parent_directory <- sub(".*/", "/", current_directory)
  
  # get all file paths
  file_paths_all <- list.files(current_directory, recursive = T, full.names = T)
  
  # get all csv file paths
  file_paths_csv <- list.files(directory, pattern = "\\.csv$", full.names = T, recursive = T)
  
  # get all tsv file paths
  file_paths_tsv <- list.files(current_directory, pattern = "\\.tsv$", full.names = T, recursive = T)
  
  # combine tabular files
  file_paths_tabular <- c(file_paths_csv, file_paths_tsv)
    
  # get relative file paths
  # ensure the base directory ends with "/"
  current_directory <- ifelse(substr(current_directory, nchar(current_directory), nchar(current_directory)) == "/", 
                                     current_directory, paste0(current_directory, "/"))
  
  # extract relative file paths with the parent directory included
  file_paths_relative <- substr(file_paths_all, nchar(current_directory) + 1, nchar(file_paths_all)) %>% 
    paste0(current_parent_directory, "/", .)
  
  
  log_info(paste0("There are ", length(file_paths_all), " files, including ", length(file_paths_csv), " csv files and ", length(file_paths_tsv), " tsv files."))
  
  
  ### Read in tabular files ####################################################
  
  # initialize empty list for storing all tabular data
  current_tabular_data <- list()
  
  # initialize empty df for storing all headers
  current_headers_df <- data.frame(header = as.character(), file = as.character())
  
  # read through each tabular file and ask for location of header columns
  for (i in 1:length(file_paths_tabular)) {
    
    # get current file path
    current_file_path <- file_paths_tabular[i]
    
    # get relative file path
    current_file_path_relative <- substr(current_file_path, nchar(current_directory) + 1, nchar(current_file_path)) %>% 
      paste0(current_parent_directory, .)
    
    # get file extension
    current_file_extension <- fs::path_ext(current_file_path)
    
    # read in file
    
    log_info(paste0("Reading in file ", i, " of ", length(file_paths_tabular), ": ", basename(current_file_path)))
    
    if (current_file_extension == "tsv") {
      
      # read in tsv
      current_data <- read_tsv(current_file_path, show_col_types = F)
      
    } else if (current_file_extension == "csv") {
      
      # read in csv
      current_data <- read_csv(current_file_path, show_col_types = F)
      
    }
    

    view(current_data)
    
    user_input <- readline(prompt = "What line has the column headers? (Enter 0 if in the correct place) ")
    
    
    # if default headers are incorrect, remove data and read it back in correctly
    if (user_input > 0) {
      
      rm(current_data)
      
      if (current_file_extension == "tsv") {
        
        current_data <- read_tsv(current_file_path, show_col_types = F, skip - as.numeric(user_input))
        
      } else if (current_file_extension == "csv") {
        
        current_data <- read_csv(current_file_path, show_col_types = F, skip - as.numeric(user_input))
      
      }
      
    }
    
    # get column headers
    current_headers <- colnames(current_data)
    
    log_info(paste0("Adding ", length(current_headers), " headers from ", basename(current_file_path)))
    
    for (j in 1:length(current_headers)) {
      # get current header
      current_header <- current_headers[j]
      
      # add header to growing df
      current_headers_df <- current_headers_df %>% 
        add_row(
          "header" = current_header,
          "file" = current_file_path_relative
        )
      
      
    }
    
    # add data to list
    current_tabular_data[[current_file_path_relative]] <- current_data
    
  }
  
  log_info("load_tabular_data complete.")
  
  ### prep return ##############################################################
  return = list(file_paths = file_paths_all,
                file_paths_relative = c(file_paths_relative),
                data = current_tabular_data,
                headers = current_headers_df)
  
  return(return)
    
}

