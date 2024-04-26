### update_dd_database.R #######################################################
# Date Created: 2024-02-05
# Date Updated: 2024-04-26
# Author: Bibi Powers-McCormack

# Objective: Add new entries to the data dictionary database.

# Input: 
  # file name of new dd to add

# Output: 
  # data_dictionary_database.csv
  # data_dictionary_database_version_log.csv

# Assumptions: 
  # v2 update: uploads a single dd at a time.


### FUNCTION ###################################################################

file_path = "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Roebuck_2023_S19S_XRF_ICR_Manuscript_Data_Package/XRF_FTICR_Manuscript_Data_Package/XRF_ICR_Manuscript_dd.csv"

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
  
  log_info("Reading in dd and dd files.")
  
  # read in dd database
  ddd <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", show_col_types = F)
  
  # read in version log
  ddd_version_log <- read_csv("./Data_Package_Documentation/database/data_dictionary_database_version_log.csv", show_col_types = F)
  
  # read in current file
  current_dd <- read_csv(current_file_path, show_col_types = F)
  
  # run it through rename_column_headers function
  current_dd <- rename_column_headers(current_dd, c("Column_or_Row_Name", "Unit", "Definition")) %>%
    select(Column_or_Row_Name,
           Unit,
           Definition)
  
  log_info("All inputs loaded in.")
  
  # print number of new entries
  log_info(paste0("Found ", nrow(current_dd), " headers in '", current_file_name, "'."))
  
  
  ### Add current_dd to ddd ####################################################
  
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
  
  
  # if the user wants to add the dd...
  
  if (user_input == tolower(user_input) == "y") {
    
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
    
    # add current dd to version log
    current_version_log <- data.frame(
      date = Sys.Date(),
      dd_source = current_file_path,
      number_headers_added = nrow(current_dd_updated))
      
      # update version log
      ddd_version_log_updated <- ddd_version_log %>% 
        add_row(current_version_log)
    
    
  } else {
    
    user_input <- "N"
    
    log_info(paste0("'", current_file_name, "' is NOT being added to the database."))
  
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  # If the entry is not an identical duplicate, it adds the entry to the ddd
  
  for (i in 1:nrow(current_dd)) {
    # loops through each header in the current_dd df
    current_row <- current_dd[i, ]
    current_header <- current_dd[, "Column_or_Row_Name"]
    
    current_file <- current_row[, "dd_filename"]
    
    # checks to see if an identical duplicate exists in the database
    check_for_identical_duplicate <- ddd %>% 
      filter(.$dd_filename == current_file$dd_filename, 
             .$Column_or_Row_Name == current_row$Column_or_Row_Name, 
             .$Definition == current_row$Definition,
             .$Unit == current_row$Unit,
             .$Data_Type == current_row$Data_Type,
             .$Term_Type == current_row$Term_Type)
    
      if (nrow(check_for_identical_duplicate) > 0) {
        
        # if there is a duplicate, remove from new_to_add df
        new_dd_to_add <- new_dd_to_add %>%
          filter(.$Column_or_Row_Name != current_header$Column_or_Row_Name)
        
        log_info(paste0("Removed because an identical copy already exists in ddd: '", current_file$dd_filename, "' --- ", current_header$Column_or_Row_Name))
      }
  }
  
  # add new_to_add to ddd
  ddd <- ddd %>% 
    rbind(., new_dd_to_add)
  
  log_info(paste0("Added ", nrow(new_dd_to_add), " new headers to the dd database."))
  
  
  ### Clean up ddd #############################################################
  
  ddd <- ddd %>% 
    select(-status) %>% 
    arrange(Column_or_Row_Name) %>% 
    filter(!is.na(Column_or_Row_Name)) %>% 
    filter(Column_or_Row_Name != "")
  
  ### Export out new version of dd database ####################################
  
  # update version number
  version <- read_csv(paste0("./Data_Package_Documentation/database/data_dictionary_database.csv"), n_max = 1, col_names = FALSE, show_col_types = F)
  
  update_version <- version$X2 + 1
  
  version_header <- tibble("# version", update_version)
  
  log_info(paste0("Incrementing up dd database version number from v", update_version - 1, " to v", update_version))
  
  # ask to export
  
  user_input <- readline("Would you like to export the new version of the database? (Y/N) ")
  
  if (tolower(user_input) == "n") {
    
    log_info("Export terminated.")
    
  } else if (tolower(user_input) == "y") {
    
    # update database version log
    
    # collect values
    date <- Sys.Date()
    database <- "dd"
    dd_files <- new_dd_to_add %>% 
      select(dd_filename) %>% 
      distinct() %>% 
      pull() %>% 
      paste(., collapse = ", ")
    note <- paste0("Added ", nrow(new_dd_to_add), " headers from the following dd files: ", dd_files)
    
    # create row to append to log
    update_version_log <- data.frame(
      Date = date,
      Version = update_version,
      Database = database,
      Note = note
    )
    
    # update log
    write_csv(update_version_log, "./Data_Package_Documentation/database/database_version_log.csv", col_names = F, append = T)
    
    
    # export database
    write_csv(version_header, "./Data_Package_Documentation/database/data_dictionary_database.csv", col_names = FALSE)

    write_csv(ddd, "./Data_Package_Documentation/database/data_dictionary_database.csv", col_names = TRUE, append = TRUE, na = "")
    
    log_info(paste0("Updated version log and exported out data_dictionary_database.csv."))
    log_info(paste0("v", update_version, ": ", note))
      
  }
  
  return(ddd)
  
  log_info("update_dd_database complete")
  
}

  
