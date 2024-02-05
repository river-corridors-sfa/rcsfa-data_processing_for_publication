### query_flmd_database.R ######################################################
# Date Created: 2024-02-02
# Author: Bibi Powers-McCormack

# Objective: Use the flmd database to fill in definitions in a provided flmd skeleton

# Inputs: 
  # flmd skeleton
  # flmd database
  # rename_column_headers function

# Outputs: 
  # populated skeleton


### FUNCTION ###################################################################

query_flmd_database <- function(flmd_skeleton) {
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog) # for logging
  library(tools) # for removing file extension
  
  # load user inputs 
  current_flmd_skeleton <- flmd_skeleton %>% 
    mutate(across(everything(), ~ ifelse(. == "", NA, .))) # replaces "" with NA
  
  # load dd database
  flmdd <- read_csv("./Data_Package_Documentation/database/file_level_metadata_database.csv", comment = "#", show_col_types = F)
  
  # load helper functions
  source("./Data_Transformation/functions/rename_column_headers.R")
  
  
  ### Check for correct column headers #########################################
  # Directions: Run this chunk without modification. Respond to inline prompts as they appear.
  # This confirms the provided skeleton has the correct column headers. 
  
  current_flmd_skeleton <- rename_column_headers(current_flmd_skeleton, c("File_Name", "File_Description", "Standard", "Date_Start", "Date_End", "Missing_Value_Codes", "File_Path"))
 
  ### Query database #############################################################
  # Directions: Run this chunk without modification. Respond to inline prompts as they appear.
  # Breaks apart each File_Name into keywords split by underscores and hyphens. 
  # Then for each keyword, it searches through the flmdd for any File_Names that match that search.
  # Pulls all of those into a df to show to the user.
  # Asks the user to select the definition they want.
  # Pulls that definition into the skeleton flmd.
  
  # create empty df to slowly populate
  populate_flmd_skeleton <- data.frame()
  
  
  for (i in 1:nrow(current_flmd_skeleton)) {
    
    log_info(paste0("Querying skeleton flmd row ", i, " of ", nrow(current_flmd_skeleton), "."))
    
    # extract current row
    current_row <- current_flmd_skeleton %>% 
      slice(i)
    
    # extract current file
    current_file_name <- current_row %>% 
      select(File_Name) %>% 
      pull()
    
    # for each row, split out based on underscores and dashes
    current_keywords <- current_file_name %>% 
      file_path_sans_ext(.) %>%  # remove file extension
      str_split_1(., "[_-]") %>% # split based on underscores and dashes
      str_replace_all(., "[.*]", "") %>% # remove all periods and wildcard asterisks
      tibble(keywords = .) %>% 
      mutate(keywords = tolower(keywords)) # convert to lower case
    
    # create skeleton for current query
    current_query <- data.frame()
    
      # loop through each keyword - for each keyword, search file names in database that include that keyword
      for (j in 1:nrow(current_keywords)) {
      
        # extract current keyword
        current_keyword <- current_keywords[j, 1] %>% 
          pull() %>% 
          tolower()
        
        # look for the keyword in the flmdd
        current_keyword_search <- flmdd %>% 
          mutate(keyword = tolower(.$File_Name), .before = File_Name) %>% # make temporarily database lowercase
          mutate(keyword = file_path_sans_ext(.$File_Name)) %>%  # temporarily remove file extension
          filter(str_detect(keyword, current_keyword)) # search based on file name without extension
        
        # add any results to the query for this File_Name
        current_query <- current_query %>% 
          rbind(current_keyword_search)
        
      }
    
    # clean up query by sorting by most matched keywords 
    cat(paste0("Searched the keywords ", current_keywords, " to identify a description for '", current_file_name, "'"))
    
    current_query <- current_query %>%
      select(File_Description, File_Name, flmd_filename, flmd_database_archive) %>% 
      count(File_Description, File_Name, flmd_filename, flmd_database_archive, name = "num_of_keywords_matched", sort = TRUE) %>% 
      select(num_of_keywords_matched, everything())
    
    # if the search returned results, ask user if they want to take a description; otherwise skips and fills in with whatever was in the skeleton
    if (nrow(current_query) > 0) {
    
      view(current_query)
      
      user_input <- readline(paste0("Which 'File_Description' do you want in your flmd to describe ", current_file_name, "? Enter the row number. Enter 0 if none match. "))
      
      # use row number to copy over correct definition
      current_query <- current_query %>% 
        slice(as.numeric(user_input)) %>% 
        select(File_Description) %>% 
        pull()
    
    } else {
      
      log_info(paste0("Skipping ", current_file_name,". No keywords located."))
      
      user_input <- 0
    }
    
    
    
    # take user input and fill in skeleton flmd accordingly
    if (user_input > 0) {
      
      # update current row with user selected definition
      current_row <- current_row %>% 
        mutate(File_Description = current_query)
      
    }
      
    # add current row to populated flmd. If user didn't select a new definition it will fill in with whatever was already present in the skeleton (usually blanks)
    log_info(paste0("Updating populated skeleton with ", current_file_name, "."))
    populate_flmd_skeleton <- populate_flmd_skeleton %>% 
      rbind(., current_row)
    
  }
  
  
  log_info("Querying complete.")
  
  ### Compare descriptions pulled from flmdd to original skeleton input ########
  # This chunk compares the file descriptions from the skeleton flmd with those pulled from the database.
  # It asks the user to select which description to use.
  # 1 = pull original description.
  # 2 = pull database description.
  # 3 = write your own description. both descrptions are copied to the clipboard for you to use to edit.
  # assumptions: 
    # if both values are NA, return NA in the final output
    # if one value is NA, automatically pull the single description


  log_info("Comparing descriptions pulled from the flmd database to orignal skeleton input.")  
  
  # initialize empty df for edited response
  edit_flmd_skeleton <- data.frame()
  
  for (i in 1:nrow(populate_flmd_skeleton)) {
    
    # get current row
    current_row <- populate_flmd_skeleton %>% 
      slice(i)
    
    # get current file name
    current_file_name <- current_row %>% 
      select(File_Name) %>% 
      pull()
    
    # get flmdd description
    current_flmdd_description <- current_row %>% 
      select(File_Description) %>% 
      pull()
    
    # get skeleton description
    current_skeleton_description <- current_flmd_skeleton %>% 
      filter(File_Name == current_file_name) %>% 
      select(File_Description) %>% 
      pull()
    
    log_info(paste0("Comparing row ", i, " of ", nrow(populate_flmd_skeleton), ": '", current_file_name, "'"))
    
    # make adjustments if there are NA values
    
    # if both values are NA, treat them as equal. This will eventually return NA in the final output
    if(is.na(current_flmdd_description) & is.na(current_skeleton_description)) {
      current_flmdd_description <- "N/A"
      current_skeleton_description <- "N/A"
    } else if (is.na(current_skeleton_description)) { # else if only one description is NA, carry over other description. This will pull over the non NA description
      current_skeleton_description <- current_flmdd_description
    } else if(is.na(current_flmdd_description)) {
      current_flmdd_description <- current_skeleton_description
    }
    
    # if the descriptions are not equal...
    if (current_flmdd_description != current_skeleton_description) {
      
      # ... ask user which description to take
      
      # copy descriptions to clipboard
      current_clipboard <- paste0(current_flmdd_description, " /// ", current_skeleton_description)
      write_clip(current_clipboard)
      
      # show options
      cat(" 0. Leave description empty to fill in manually later.", "\n",
          "1. Database Description: ", "\n", "     ", current_flmdd_description, "\n", 
          "2. Skeleton Description: ", "\n", "     ", current_skeleton_description, "\n", "\n",
          "The above Description have been copied to your clipboard for your editing convenience.")
      
      user_input <- readline("What description would you like to keep? Enter 0, 1, or 2. Or write in your own: ")
      
      # update current description based on user input
      if (user_input == 0) {
        current_description = NA
      } else if (user_input == 1) {
        current_description <- current_flmdd_description
      } else if (user_input == 2) {
        current_description <- current_skeleton_description
      } else {
        current_description <- user_input
      }
      
      # edit current row to append
      current_row <- current_row %>% 
        mutate(File_Description = current_description) %>% 
        mutate(File_Description = case_when(File_Description == "N/A" ~ NA_character_, TRUE ~ File_Description))
    
    }
    
    # add current row to the edited df
    edit_flmd_skeleton <- edit_flmd_skeleton %>% 
      rbind(., current_row)
    
  }
  
  
  ### Clean up #################################################################
  
  log_info("query_flmd_database complete")
  
  return(edit_flmd_skeleton)
  
}



