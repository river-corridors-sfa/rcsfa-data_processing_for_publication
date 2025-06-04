### update_flmd_database.R #####################################################
# Date Created: 2024-02-02
# Date Updated: 2025-06-04
# Author: Bibi Powers-McCormack

### FUNCTION ###################################################################

update_flmd_database <- function(flmd_abs_file, date_published, flmd_database_abs_dir) {
  
  # Objective: Add new entries to the file level metadata database.
  
  # Inputs: 
    # flmd_abs_file = the absolute file path of the new flmd to add. Required argument.
    # date_published = the date when the associated data package became publicly available, formatted as YYYY-MM-DD. If you want today's date, then put "Sys.Date()". Required argument.
    # flmd_database_abs_dir = the absolute file path of the flmd database; the csv needs the cols: index, File_Name, File_Description, date_published, flmd_filename, flmd_source. Required argument.
  
  # Output: 
    # file_level_metadata_database.csv with the cols: index, File_Name, File_Description, date_published, flmd_filename, flmd_source
  
  # Assumptions: 
    # By default it pulls data from these flmd cols: File_Name, File_Description
    # If one of those columns does not exist, it will populate that cell with NA
    # If a file name appears more than once, the function will show the user and ask them to confirm they'd like to update the database
    # In the database, title case columns are ones from the FLMD; lower case are database metadata cols.
  
  # Status: complete
  
  ### Prep script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(devtools)
  library(rlog)
  library(lubridate)
  
  ### Read in files ############################################################
  
  log_info("Reading in files.")
  
  # read in database
  flmd_database <- read_csv(flmd_database_abs_dir, col_names = T, show_col_types = F, col_types = "iccDcc") %>% 
    arrange(index)
  
  # read in current flmd
  current_flmd <- read_csv(flmd_abs_file, show_col_types = F)
  
  
  ### Validate inputs ##########################################################
  # This chunk validates the input arguments. 
  # It makes sure the database has cols: File_Name, File_Description, date_published, flmd_filename, flmd_source
  # It grabs the following cols from the flmd: File_Name, File_Description
  # If a col isn't present in the flmd, it fills it in with NA
  # It confirms the date the user provided is in YYYY-MM-DD format and converts it to a date
  
  # confirm flmd_database has correct cols
  database_required_cols <- c("index", "File_Name", "File_Description", "date_published", "flmd_filename", "flmd_source")
  
  if (!all(database_required_cols %in% names(flmd_database))) {
    
    # if files_df is missing required cols, error
    log_error(paste0("flmd database is missing required column: ", setdiff(database_required_cols, names(flmd_database))))
    stop("Function terminating.")
  } # end of checking flmd database required cols
  
  
  # confirm flmd has the correct cols
  flmd_cols <- c("File_Name", "File_Description")
  
  # if some cols are missing, ask the user before filling in the col with NA
  if (!all(flmd_cols %in% names(current_flmd))) {
    
    log_warn("Not all flmd columns are present in your flmd.")
    
    # loop through each correct col and ask user if that col is present in the flmd (under a different name)
    for (i in seq_along(flmd_cols)) {
      
      # get i-th current column
      current_correct_col <- flmd_cols[i]
      
      # check if correct col exists in current flmd
      if (!current_correct_col %in% names(current_flmd)) { # if correct col doesn't exist in current flmd...
        
        # print the current flmd
        print(head(current_flmd))
        cat("\n")
        print(data.frame(flmd_cols = names(current_flmd)))
        
        # ask which column matches the current correct col
        user_input <- readline(paste0("What row number is the column '", current_correct_col, "'? Enter 0 if column is not present. "))
        
        if (user_input > 0 & user_input <= (ncol(current_flmd))) { #if the user entered a number...
          
          # get the name of the column from current flmd that needs to be corrected
          current_df_col_to_rename <- names(current_flmd)[as.numeric(user_input)]
          
          
          # rename the current column to the correct column
          current_flmd <- current_flmd %>% 
            rename_with(~ current_correct_col, .cols = current_df_col_to_rename)
          
        } else if (user_input == 0) { # else if the user said the column isn't present...
          
          # mutate the column on and make all cell values empty
          current_flmd <- current_flmd %>% 
            mutate(!!current_correct_col := NA)
        } else (break)
        
      } else {
        log_info("No changes needed to fix column headers.")
      }
      
    } # end of loop through correct cols
    
    # arrange columns with corrects cols first, followed by all other columns
    current_flmd <- current_flmd %>% 
      select(all_of(flmd_cols), everything())
    
  } # end of checking flmd cols
  
  # confirm date_published is in date format
  parsed_date_published <- ymd(date_published, quiet = TRUE)
  
  if (is.na(parsed_date_published)) {
    stop("`date_published` must be in 'YYYY-MM-DD' format and convertible to a Date.")
  }
  
  # select required cols
  current_flmd <- current_flmd %>%
    select(File_Name,
           File_Description)
  
  log_info("All inputs loaded in.")
  
  # print number of new entries
  log_info(paste0("Found ", nrow(current_flmd), " files in '", flmd_abs_file, "'."))
  
  
  ### Check for possible duplicates ############################################
  
  flmd_filename <- basename(flmd_abs_file)
  
  # searches the flmd database for duplicate file names, asks if the user wants to continue
  possible_duplicates <- flmd_database %>% 
    filter(flmd_filename == flmd_filename) %>% 
    select(File_Name, flmd_filename, flmd_source) %>% 
    group_by(flmd_filename, flmd_source) %>% 
    summarise(headers = toString(File_Name), .groups = "drop") %>% 
    distinct()
  
  if (nrow(possible_duplicates) > 0) {
    
    log_info("This file name is already in the database. Showing possible duplicates: ")
    
    # show user possible duplicates - this shows a df listing the duplicates with their source and a concatenated list of headers
    View(possible_duplicates)
    
    user_input <- readline(prompt = "Do you want to add your flmd to the database? (enter Y/N): ")
    
  } else {
    user_input <- "y"
  }
  
  ### Add to flmd database #######################################################
  
  # if the user wants to add the flmd...
  
  if (tolower(user_input) == "y") {
    
    # identify where the indexing should pick up
    if (nrow(flmd_database) == 0) {
      # if there are no rows in the database, start at 0
      max_index <- 0
      } else {
        # otherwise, identify the largest number in the index
        max_index <- max(flmd_database$index, na.rm = TRUE)
      }
    
    # add additional database columns
    current_flmd_updated <- current_flmd %>% 
      mutate(index = (max_index + 1):(max_index + nrow(current_flmd)),
             date_published = parsed_date_published,
             flmd_filename = flmd_filename,
             flmd_source = flmd_database_abs_dir)
    
    # add current flmd to database
    flmd_database_updated <- flmd_database %>% 
      add_row(current_flmd_updated) %>% 
      arrange(File_Name, .locale = "en") # the .locale argument get it to sort alphabetically irrespective of capital/lowercase letters
    
    ### Export out new database ##################################################
    
    # ask to export
    user_input_export <- readline("Would you like to export the new version of the database? (Y/N) ")
    
    if (tolower(user_input_export) == "n") {
      
      log_info("Export terminated.")
      log_info("update_flmd_database complete")
      return(flmd_database)
      
    } else if (tolower(user_input_export) == "y") {
      
      # export updated database
      write_csv(flmd_database_updated, flmd_database_abs_dir, col_names = TRUE)
      
      log_info("Updated data_dictionary_database.csv.")
      
      # returns flmd database
      log_info("update_flmd_database complete")
      return(flmd_database_updated)
      
    }
    
    
  } else {
    
    log_info(paste0("'", flmd_filename, "' is NOT being added to the database."))
    
    log_info("update_flmd_database complete")
    return(flmd_database)
    
  }
  
  
  
} # end of update_flmd_database() function
