### rename_column_headers.R #######################################################
# Date Created: 2023-12-18
# Author: Bibi Powers-McCormack

# Objective: Clean up a df by inputting the desired columns and having it loop through each correct column to ask if there's a current column you want renamed

# Inputs: 
  # dataframe of data
  # vector string of desired column names

  # example: rename_column_headers(df, c("header_1", "header_2", "header_3"))

# Outputs:
  # corrected dataframe

### Function ###################################################################
rename_column_headers <- function(dataframe, correct_headers) {
  
  library(tidyverse)
  
  current_correct_headers <- correct_headers
  current_df <- dataframe

    # get the columns that exist in current dd
    current_cols <- colnames(current_df)
    current_cols_df <- data.frame(current_cols)
    
  # go through each correct column and see if it's in the current dd
  for (current_correct_col in current_correct_headers){
    
    # check if correct col exists in current dd
    if (!current_correct_col %in% current_cols) { # if correct col doesn't exist in current dd...
      
      # print the current dd
      print(head(current_df))
      print(current_cols_df)
      
      # ask which column matches the current correct col
      user_input <- readline(paste0("What row number is the column '", current_correct_col, "'? Enter 0 if column is not present. "))
      
      if (user_input > 0 & user_input <= (ncol(current_df))) { #if the user entered a number...
        
        # get the name of the column from current dd that needs to be corrected
        current_df_col_to_rename <- current_cols_df[user_input, ]
        
        # rename the current column to the correct column
        current_df <- current_df %>% 
          rename(!!current_correct_col := current_df_col_to_rename)
        
      } else if (user_input == 0) { # else if the user said the column isn't present...
        
        # mutate the column on and make all cell values empty
        current_df <- current_df %>% 
          mutate(!!current_correct_col := "")
      } else (break)
      
    } else {
      print("No changes needed to fix column headers.")
    }
    
  }
  
  # arrange columns with corrects cols first, followed by all other columns
  current_df <- current_df %>% 
    select(all_of(current_correct_headers, everything()))
  
  return(current_df)
  
}
