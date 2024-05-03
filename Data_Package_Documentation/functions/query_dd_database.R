### query_dd_database.R ########################################################
# Date Created: 2024-02-02
# Author: Bibi Powers-McCormack

# Objective: Use the dd database to fill in definitions in a provided dd skeleton

# Inputs: 
  # dd skeleton
  # dd database
  # rename_column_headers function

# Outputs: 
  # populated skeleton


### FUNCTION ###################################################################

query_dd_database <- function(dd_skeleton) {
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(clipr)
  
  # load user inputs 
  current_dd_skeleton <- dd_skeleton %>% 
    mutate(across(everything(), ~ ifelse(. == "", NA, .))) # replaces "" with NA
  
  # load dd database
  ddd <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", show_col_types = F)
  
  # convert archive col from logical to factor for sorting purposes later
  archive_levels <- c("Use", "Unevaluated", "Do not use")
  
  ddd <- ddd %>% 
    mutate(dd_database_archive = case_when(dd_database_archive == TRUE ~ "Do not use",
                                           dd_database_archive == FALSE ~ "Use", 
                                           is.na(dd_database_archive) ~ "Unevaluated")) %>% 
    mutate(dd_database_archive = factor(dd_database_archive, levels = archive_levels))
  
  # load helper functions
  source("./Data_Transformation/functions/rename_column_headers.R")
  
  ### Check for correct column headers #########################################
  # Directions: Run this chunk without modification. Respond to inline prompts as they appear.
  # This confirms the provided skeleton has the correct column headers. 
  
  current_dd_skeleton <- rename_column_headers(current_dd_skeleton, c("Column_or_Row_Name", "Unit", "Definition"))
  
  ### Query for shared definitions #############################################
  # Directions: Run this chunk without modification. Respond to inline prompts as they appear.
  # This chunk searches through the dd database for each header listed in the dd skeleton.
  # If a match wasn't found in the database, it will return the row from the skeleton.
  # The output is a populated skeleton. 
  
  # create empty df to slowly populate
  populate_skeleton_dd <- data.frame()
  
  
  for (i in 1:nrow(current_dd_skeleton)) {
    
    log_info(paste0("Querying skeleton dd row ", i, " of ", nrow(current_dd_skeleton), "."))
    
    # extract current row
    current_row <- current_dd_skeleton %>% 
      slice(i)
    
    # extract current header
    current_header <- current_row %>% 
      select(Column_or_Row_Name) %>% 
      pull()
    
    # look for current header in ddd
    ddd_filter <- ddd %>% 
      filter(.$Column_or_Row_Name %in% current_header)
    
    # if header is not in database, do nothing
    if (nrow(ddd_filter) == 0) {
      
      log_info(paste0("The header '", current_header, "' is not in the data dictionary database."))
      
      user_input <- as.numeric(0)
      
    } else if (nrow(ddd_filter) > 0) {
      
      # if the header is in the database, show definitions and ask user which one they want to use by imputing the row number
      ddd_filter <- ddd_filter %>% 
        filter(dd_database_archive != "Do not use") %>% 
        group_by(Column_or_Row_Name, Unit, Definition, dd_database_archive, dd_database_notes) %>% 
        summarise(dd_filenames_count = n(), # collapse identical definitions
                  dd_filenames = toString(dd_filename)) %>% 
        arrange(
          # sort archive col by FALSE, NA, TRUE
          dd_database_archive,
          # sort by count in descending order
          desc(dd_filenames_count)
        ) %>% 
        # arrange(desc(dd_filenames_count)) %>% 
        ungroup()
      
      view(ddd_filter)
      
      user_input <- readline("What entry do you want in your dd? Enter the row number. Enter 0 if none match. ")
      
      # use row number to copy over correct definition
      ddd_filter <- ddd_filter %>% 
        slice(as.numeric(user_input)) %>% 
        select(c(Column_or_Row_Name, Unit, Definition))
      
    } 
    
    # take user input and fill in skeleton dd accordingly
    if (user_input == 0) {
      
      # fill in with whatever was already present in the skeleton (usually blanks)
      populate_skeleton_dd <- populate_skeleton_dd %>% 
        rbind(., current_row)
      
    } else {
      
      # fill in with the selected definition from the database
      populate_skeleton_dd <- populate_skeleton_dd %>% 
        rbind(., ddd_filter)
      
    }
    
    
  }
  
  # sort by Column_or_Row
  populate_skeleton_dd <- populate_skeleton_dd %>% 
    arrange(Column_or_Row_Name, .locale = "en") # this sorts irrespective of caps
  
  log_info("Querying complete.")
  
  
  ### Compare definitions pulled from ddd to original skeleton input #############
  # Directions: Run this chunk without modification. Respond to inline prompts as they appear.
  # This chunk compares the definitions from the skeleton dd with those pulled from the database.
  # It asks the user to select which definition to use.
  # 1 = pull original definition.
  # 2 = pull database definition.
  # 3 = write your own definition. both definitions are copied to clipboard for you to use to edit.
  
  log_info("Comparing definitions pulled from dd database to original skeleton input.")
  
  # initialize empty df for the edited responses
  edit_skeleton_dd <- data.frame()
  
  for (i in 1:nrow(populate_skeleton_dd)){
    
    # get current row
    current_row <- populate_skeleton_dd %>% 
      slice(i)
    
    # get current header
    current_header <- current_row %>% 
      select(Column_or_Row_Name) %>% 
      pull()
    
    # get ddd definition
    current_ddd_definition <- current_row %>% 
      select(Definition) %>% 
      pull()
    
    # get skeleton definition
    current_skeleton_definition <- current_dd_skeleton %>% 
      filter(Column_or_Row_Name == current_header) %>% 
      select(Definition) %>% 
      pull()
    
    log_info(paste0("Comparing row ", i, " of ", nrow(populate_skeleton_dd), ": '", current_header, "'"))
    
    # make adjustments if there are NA values 
    
    # if both values are NA, treat them as equal. This will eventually return NA in the final output
    if (is.na(current_ddd_definition) & is.na(current_skeleton_definition)) {
      current_ddd_definition <- "N/A"
      current_skeleton_definition <- "N/A"
    } else if (is.na(current_skeleton_definition)) { # else if only one definition is NA, carry over other definition. This will pull over the non NA definition in the final output
      current_skeleton_definition <- current_ddd_definition
    } else if(is.na(current_ddd_definition)) {
      current_ddd_definition <- current_skeleton_definition
    }
    
    # if definitions are not equal...
    if (current_ddd_definition != current_skeleton_definition) {
      
      # ... ask which definition to take
      
      # copy definitions to clipboard
      current_clipboard <- paste0(current_ddd_definition, " /// ", current_skeleton_definition)
      write_clip(current_clipboard)
      
      # show options  
      cat(" 0. Leave definition empty to fill in manually later.", "\n",
          "1. Database Definition: ", "\n", "     ", current_ddd_definition, "\n", 
          "2. Skeleton Definition: ", "\n", "     ", current_skeleton_definition, "\n", "\n",
          "The above definitions have been copied to your clipboard for your editing convenience.")
      
      user_input <- readline("What definition would you like to keep? Enter 0, 1, or 2. Or write in your own: ")
      
      # update current definition based on user input
      if (user_input == 0) {
        current_definition = NA
      } else if (user_input == 1) {
        current_definition <- current_ddd_definition
      } else if (user_input == 2) {
        current_definition <- current_skeleton_definition
      } else {
        current_definition <- user_input
      }
      
      # edit current row to append
      current_row <- current_row %>% 
        mutate(Definition = current_definition) %>% 
        mutate(Definition = case_when(Definition == "N/A" ~ NA_character_, TRUE ~ Definition))
      
    } 
    
    # add current row to the edited df
    edit_skeleton_dd <- edit_skeleton_dd %>% 
      rbind(., current_row)
    
  }
  
  log_info("query_dd_database complete.")
  
  return(edit_skeleton_dd)
  
}
