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
  
  ### Compare 
  
  
  ### Clean up #################################################################
  
  return(populate_flmd_skeleton)
  
}



