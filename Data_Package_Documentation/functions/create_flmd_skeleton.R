### create_flmd_skeleton.R #####################################################
# Date Created: 2024-02-02
# Author: Bibi Powers-McCormack

# Objective: create an empty flmd skeleton

# Inputs: 
  # the file_paths_relative vector from load_tabular_data

# Outputs: 
  # a df with an empty flmd skeleton


### FUNCTION ###################################################################

create_flmd_skeleton <- function(relative_file_paths) {
  
  # load libaries
  library(tidyverse)
  library(rlog)
  
  # get df of file paths
  current_file_paths <- relative_file_paths

  # initialize empty df
  current_flmd_skeleton <- tibble(
    "File_Name" = as.character(),
    "File_Description" = as.character(),
    "Standard" = as.character(),
    "Date_Start" = as.character(),
    "Date_End" = as.character(),
    "Missing_Value_Codes" = as.character(),
    "File_Path" = as.character()
  )
  
  ### check and ask to add dd and flmd files ###################################
  log_info("Checking for presence of dd and flmd files.")
  
  # check for presence of dd and flmd files
  dd_file_present <- "dd.csv" %in% current_file_paths
  flmd_file_present <- "flmd.csv" %in% current_file_paths
  
  if (dd_file_present == FALSE ) {
    user_input_add_dd_file <- readline(prompt = "The dd file is not present. Would you like to add a placeholder dd to the flmd? (Y/N) ")
  } else {
    user_input_add_dd_file <- "N"
  }
  
  if (flmd_file_present == FALSE) {
    user_input_add_flmd_file <- readline(prompt = "The flmd file is not present. Would you like to add a placehold flmd to the flmd? (Y/N) ")
  } else {
    user_input_add_flmd_file <- "N"
  }
  
  log_info(paste0("Adding ", length(current_file_paths), " files to the flmd."))
  
  ### loop through files and add to df #########################################
  
  for (i in 1:length(current_file_paths)) {
    
    # gather flmd components
    # get current relative file path
    current_file_path_relative <- current_file_paths[i]
    
    # get file name
    current_file_name <- basename(current_file_path_relative)
    
    # get file path
    current_file_path <- str_replace(string = current_file_path_relative, pattern = paste0("/", current_file_name), replacement = "")
    
    
    # add to skeleton
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = current_file_name,
        "File_Description" = "",
        "Standard" = "",
        "Date_Start" = "",
        "Date_End" = "",
        "Missing_Value_Codes" = "",
        "File_Path" = current_file_path
      )
    
    
  }
  
  
  
  ### adding dd and flmd file placeholders if applicable #######################
  if (tolower(user_input_add_dd_file) == "y") {
    
    # adding dd file to flmd if user indicated Y
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = "[INSERT DD FILENAME]_dd.csv",
        "File_Description" = "",
        "Standard" = "",
        "Date_Start" = "",
        "Date_End" = "",
        "Missing_Value_Codes" = "",
        "File_Path" = ""
      )
  }
  
  if (tolower(user_input_add_flmd_file) == "y") {
    
    # adding flmd file to flmd if user indicated Y
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = "[INSERT FLMD FILENAME]_flmd.csv",
        "File_Description" = "",
        "Standard" = "",
        "Date_Start" = "",
        "Date_End" = "",
        "Missing_Value_Codes" = "",
        "File_Path" = ""
      )
  }
  
  
  
  ### clean up #################################################################
  current_flmd_skeleton <-  current_flmd_skeleton %>% 
    arrange(File_Path, File_Name)
  
  log_info("create_flmd_skeleton complete.")

  return(current_flmd_skeleton)
    
}




