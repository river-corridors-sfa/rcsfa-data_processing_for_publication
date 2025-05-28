### update_dd_database.R #######################################################
# Date Created: 2024-02-05
# Date Updated: 2024-05-28
# Author: Bibi Powers-McCormack

### FUNCTION ###################################################################

update_dd_database <- function(dd_abs_file, date_published, dd_database_abs_dir) {
  
  # Objective: Add new entries to the data dictionary database.
  
  # Inputs: 
    # dd_abs_file = the absolute file path of the new dd to add. Required argument.
    # date_published = the date the data package the dd was associated with was published. Format is a character string in the YYYY-MM-DD format. If you want today's date, then put "as.character(Sys.Date())". Required argument.
    # dd_database_abs_dir = the absolute file path of the dd database; the csv needs the cols: Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, date_published, dd_filename, dd_source. Required argument.

  # Output: 
    # data_dictionary_database.csv with the cols: Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, date_published, dd_filename, dd_source
    
  # Assumptions: 
    # By default it pulls data from these dd cols: Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type
    # If one of those columns does not exist, it will populate that cell with NA
  
  # Status: 
    # v2 update: uploads a single dd at a time.
    # v2.1 update
  
  
  ### Prep script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(devtools)
  library(rlog)
  
  
  ### Read in files ############################################################
  
  log_info("Reading in files.")
  
  # read in database
  dd_database <- read_csv(dd_database_abs_dir, col_names = T, na = c("N/A", "-9999", "", "NA"), show_col_types = F)
  
  # read in current dd
  current_dd <- read_csv(dd_abs_file, show_col_types = F)
  
  
  ### Validate inputs ##########################################################
  
  # confirm dd_database has correct cols
  database_required_cols <- c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type", "date_published", "dd_filename", "dd_source")
  
  if (!all(database_required_cols %in% names(dd_database))) {
    
    # if files_df is missing required cols, error
    log_error(paste0("dd database is missing required column: ", setdiff(database_required_cols, names(dd_database))))
    stop("Function terminating.")
  } # end of checking dd database required cols
  
  
  # confirm dd has the correct cols
  dd_cols <- c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type")
  
  # if some cols are missing, ask the user before filling in the col with NA
  if (!all(dd_cols %in% names(current_dd))) {
    
    log_warn("Not all dd columns are present in your dd.")
    
    # loop through each correct col and ask user if that col is present in the dd (under a different name)
    for (i in seq_along(dd_cols)) {
      
      # get i-th current column
      current_correct_col <- dd_cols[i]
      
      # check if correct col exists in current dd
      if (!current_correct_col %in% names(current_dd)) { # if correct col doesn't exist in current dd...
        
        # print the current dd
        print(head(current_dd))
        cat("\n")
        print(data.frame(dd_cols = names(current_dd)))
        
        # ask which column matches the current correct col
        user_input <- readline(paste0("What row number is the column '", current_correct_col, "'? Enter 0 if column is not present. "))
        
        if (user_input > 0 & user_input <= (ncol(current_dd))) { #if the user entered a number...
          
          # get the name of the column from current dd that needs to be corrected
          current_df_col_to_rename <- names(current_dd)[as.numeric(user_input)]
            
          
          # rename the current column to the correct column
          current_dd <- current_dd %>% 
            rename_with(~ current_correct_col, .cols = current_df_col_to_rename)
          
        } else if (user_input == 0) { # else if the user said the column isn't present...
          
          # mutate the column on and make all cell values empty
          current_dd <- current_dd %>% 
            mutate(!!current_correct_col := NA)
        } else (break)
        
      } else {
        log_info("No changes needed to fix column headers.")
      }
      
    } # end of loop through correct cols
    
    # arrange columns with corrects cols first, followed by all other columns
    current_dd <- current_dd %>% 
      select(all_of(dd_cols), everything())
    
  } # end of checking dd cols
  
  # select required cols
  current_dd <- current_dd %>%
    select(Column_or_Row_Name,
           Unit,
           Definition,
           Data_Type, 
           Term_Type)
  
  log_info("All inputs loaded in.")
  
  # print number of new entries
  log_info(paste0("Found ", nrow(current_dd), " headers in '", dd_abs_file, "'."))


  ### Check for possible duplicates ############################################
  
  dd_filename <- basename(dd_abs_file)
  
  # searches the ddd for duplicate file names, asks if the user wants to continue
  possible_duplicates <- dd_database %>% 
    filter(dd_filename == dd_filename) %>% 
    select(Column_or_Row_Name, dd_filename, dd_source) %>% 
    group_by(dd_filename, dd_source) %>% 
    summarise(headers = toString(Column_or_Row_Name), .groups = "drop") %>% 
    distinct()
  
  if (nrow(possible_duplicates) > 0) {
    
    log_info("This file name is already in the database. Showing possible duplicates: ")
    
    # show user possible duplicates - this shows a df listing the duplicates with their source and a concatenated list of headers
    View(possible_duplicates)
    
    user_input <- readline(prompt = "Do you want to add your dd to the database? (enter Y/N): ")
    
  } else {
    user_input <- "y"
  }
  
  ### Add to dd database #######################################################
  
  # if the user wants to add the dd...
  
  if (tolower(user_input) == "y") {
    
    log_info("Adding your dd to the database.")
    
    # add additional database columns
    current_dd_updated <- current_dd %>% 
      mutate(date_published = date_published,
             dd_filename = dd_filename,
             dd_source = dd_database_abs_dir)
    
    # add current dd to database
    dd_database_updated <- dd_database %>% 
      add_row(current_dd_updated) %>% 
      arrange(Column_or_Row_Name, .locale = "en") # the .locale argument get it to sort alphabetically irrespective of capital/lowercase letters
  
  ### Export out new database ##################################################
  
    # ask to export
    user_input_export <- readline("Would you like to export the new version of the database? (Y/N) ")
    
    if (tolower(user_input_export) == "n") {
      
      log_info("Export terminated.")
      
      return(dd_database)
      
    } else if (tolower(user_input_export) == "y") {
    
      # export updated database
      write_csv(dd_database_updated, dd_database_abs_dir, col_names = TRUE)
      
      log_info("Updated data_dictionary_database.csv.")
      
      # returns dd database
      return(dd_database_updated)
      
    }
    
    
  } else {
    
    user_input <- "N"
    
    log_info(paste0("'", dd_filename, "' is NOT being added to the database."))
    
    return(dd_database)
    
  }
  
  log_info("update_dd_database complete")
  
  
}
