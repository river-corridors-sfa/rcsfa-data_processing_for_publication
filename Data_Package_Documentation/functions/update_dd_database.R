### update_dd_database.R #######################################################
# Date Created: 2024-02-05
# Author: Bibi Powers-McCormack

# Objective: Add new entries to the data dictionary database.

# Input: 
  # directory of new dds to add

# Output: 
  # data_dictionary_database.csv

# Assumptions: 
  # assumes all data dictionaries (and no other files) end in this pattern: "*_dd.csv" and that all file names are unique.


### FUNCTION ###################################################################

update_dd_database <- function(directory) {
  
  current_directory <- directory
  
  # ensure the base directory ends with "/"
  current_directory <- ifelse(substr(current_directory, nchar(current_directory), nchar(current_directory)) == "/", 
                              current_directory, paste0(current_directory, "/"))
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  
  # load helper functions
  source("./Data_Transformation/functions/rename_column_headers.R")
  
  
  ### Read in files ############################################################
  
  # read in dd database
  ddd <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", comment = "#", show_col_types = F) %>% 
    mutate(status = "currently in dd")
  
  # get list of dds to add
  dd_filenames <- list.files((current_directory), pattern = "_dd.csv", recursive = T)
  
  log_info("All inputs loaded in.")
  
  # initialize empty df
  new_dd_to_add <- data.frame()
  
  log_info("Reading in files.")
  
  for (i in 1:length(dd_filenames)) {
    
    # get current file name
    current_file_name <- dd_filenames[i]
    
    log_info(paste0("Reading in file ", i , " of ", length(dd_filenames), ": ", current_file_name))
    
    # read in current file
    current_dd <- read_csv(paste0(current_directory, current_file_name), show_col_types = F)
    
    log_info("Checking and fixing column header discrepancies.")
    
    # run it through rename_column_headers function
    current_dd <- rename_column_headers(current_dd, c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type")) %>%
      select(Column_or_Row_Name,
             Unit,
             Definition,
             Data_Type,
             Term_Type)
    
    # add file name to df
    current_dd <- current_dd %>% 
      mutate(dd_filename = basename(current_file_name))
    
    # add to skeleton df
    new_dd_to_add <- new_dd_to_add %>% 
      rbind(current_dd)
  }
  
  # add archive col to new_to_add
  new_dd_to_add <- new_dd_to_add %>% 
    mutate(dd_database_archive = NA_character_) %>% 
    mutate(status = "new to add to ddd")
  
  # print number of new entries per new dd file to add
  count(new_dd_to_add, dd_filename, name = "count_of_new_headers_to_add")
  
  log_info(paste0("Planning to add ", count(new_dd_to_add), " headers from ", length(dd_filenames), " data dictionary files."))
  
  
  ### Add new_to_add to ddd ####################################################
  # If the entry is not an identical duplicate, it adds the entry to the ddd
  
  for (i in 1:nrow(new_dd_to_add)) {
    # loops through each header in the new to add df
    current_row <- new_dd_to_add[i, ]
    current_header <- current_row[, "Column_or_Row_Name"]
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

  
