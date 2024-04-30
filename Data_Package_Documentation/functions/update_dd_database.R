### update_dd_database.R #######################################################
# Date Created: 2024-02-05
# Date Updated: 2024-04-30
# Author: Bibi Powers-McCormack

# Objective: Add new entries to the data dictionary database.

# Input: 
  # file name of new dd to add
  # data dictionary
  # data dictionary version log

# Output: 
  # data_dictionary_database.csv
  # data_dictionary_database_version_log.csv

# Assumptions: 
  # v2 update: uploads a single dd at a time.


### FUNCTION ###################################################################

update_dd_database <- function(file_path) {
  
  current_file_path <- file_path
  current_file_name <- basename(current_file_path)
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  
  # load helper functions
  source("./Data_Transformation/functions/rename_column_headers.R")
  
  
  ### Read in files ############################################################
  # Inputs: data_dictionary_database.csv, data_dictionary_database_version_log.csv, current file
  
  log_info("Reading in dd and dd files.")
  
  # read in dd database
  ddd <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", show_col_types = F)
  
  # read in version log
  ddd_version_log <- read_csv("./Data_Package_Documentation/database/data_dictionary_database_version_log.csv", show_col_types = F)
  
  # read in current file
  current_dd <- read_csv(current_file_path, show_col_types = F)
  
  # run it through rename_column_headers function to identify the 3 cols: Column_or_Row_Name, Unit, Definition
  current_dd <- rename_column_headers(current_dd, c("Column_or_Row_Name", "Unit", "Definition")) %>%
    select(Column_or_Row_Name,
           Unit,
           Definition)
  
  log_info("All inputs loaded in.")
  
  # print number of new entries
  log_info(paste0("Found ", nrow(current_dd), " headers in '", current_file_name, "'."))
  
  
  ### Check for possible duplicates ############################################
  
  # searches the ddd for duplicate file names, asks if the user wants to continue
  possible_duplicates <- ddd %>% 
    filter(dd_filename == current_file_name) %>% 
    select(Column_or_Row_Name, dd_filename, dd_source) %>% 
    group_by(dd_filename, dd_source) %>% 
    summarise(headers = toString(Column_or_Row_Name)) %>% 
    ungroup() %>% 
    distinct()
  
  if (nrow(possible_duplicates) > 0) {
    
    log_info("This file name is already in the database. Showing possible duplicates: ")
    
    # show user possible duplicates - this shows a df listing the duplicates with their source and a concatenated list of headers
    View(possible_duplicates)
    
    user_input <- readline(prompt = "Do you want to add your dd to the database? (enter Y/N): ")
    
  }
  
  
  ### Add current_dd to ddd ####################################################
  
  # if the user wants to add the dd...
  
  if (tolower(user_input) == "y") {
    
    # add additional database columns
    current_dd_updated <- current_dd %>% 
      mutate(dd_filename = current_file_name,
             dd_source = current_file_path,
             dd_database_notes = NA_character_,
             dd_database_archive = NA_real_)
    
    # add current dd to database
    ddd_updated <- ddd %>% 
      add_row(current_dd_updated) %>% 
      arrange(Column_or_Row_Name, .locale = "en") # the .locale argument get it to sort alphabetically irrespective of capital/lowercase letters
    
    # create new row for version log
    current_version_log <- data.frame(
      date = Sys.Date(),
      dd_source = current_file_path,
      number_headers_added = nrow(current_dd_updated))
      
    ### Export out new version of dd database ####################################
    
    # ask to export
    user_input_export <- readline("Would you like to export the new version of the database? (Y/N) ")
    
    if (tolower(user_input_export) == "n") {
      
      log_info("Export terminated.")
      
    } else if (tolower(user_input_export) == "y") {
      
      
      # export updated version log
      write_csv(current_version_log, "./Data_Package_Documentation/database/data_dictionary_database_version_log.csv", col_names = F, append = T)
      
      # export updated database
      write_csv(ddd_updated, "./Data_Package_Documentation/database/data_dictionary_database.csv", col_names = TRUE, na = "")
      
      log_info(paste0("Updated version log and exported out data_dictionary_database.csv."))
      
    }
    
    
  } else {
    
    user_input <- "N"
    
    log_info(paste0("'", current_file_name, "' is NOT being added to the database."))
  
  }
  
  # returns dd database
  return(ddd_updated)
  
  log_info("update_dd_database complete")
  
}
  
