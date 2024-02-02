### create_dd_skeleton.R #####################################################
# Date Created: 2024-02-01
# Author: Bibi Powers-McCormack

# Objective: create an empty dd skeleton

# Inputs: 
  # the headers df from load_tabular_data

# Outputs: 
  # a df with an empty dd skeleton


### FUNCTION ###################################################################

create_dd_skeleton <- function(headers_df) {
  
  # load libraries
  library(tidyverse)
  library(rlog)
  
  # get df of headers
  current_headers <- headers_df
  
  # initialize empty df
  current_dd_skeleton <- tibble(
    "Column_or_Row_Name"= as.character(), 
    "Unit" = as.character(),
    "Definition" = as.character(),
    "Data_Type" = as.character(),
    "Term_Type" = as.character()
  )
  
  ### check and ask to add dd and flmd columns #################################
  log_info("Checking for presence of dd and flmd headers.")
  
  dd_headers <- c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type")
  flmd_headers <- c("File_Name", "File_Description", "Standard", "Date_Start", "Date_End", "Missing_Value_Codes", "File_Path")
  
  # check for presence of dd and flmd headers
  all_dd_headers_present <- all(dd_headers %in% current_headers$header)
  all_flmd_headers_present <- all(flmd_headers %in% current_headers$header)
  
  if (all_dd_headers_present == FALSE ) {
    user_input_add_dd_headers <- readline(prompt = "Not all dd headers are present. Would you like to add them to the dd? (Y/N) ")
  } else {
    user_input_add_dd_headers <- "N"
  }
  
  if (all_flmd_headers_present == FALSE) {
    user_input_add_flmd_headers <- readline(prompt = "Not all flmd headers are present. Would you like to add them to the dd? (Y/N) ")
  } else {
    user_input_add_flmd_headers <- "N"
  }
  
  ### clean up duplicates ######################################################
  duplicate_headers <- headers_df %>% 
    mutate(file = basename(file)) %>% 
    group_by(header) %>% 
    summarise(count = n(), #collapse identical duplicates,
              files = toString(file)) %>% 
    arrange(desc(count)) %>% 
    ungroup()
  
  # show duplicates
  view(duplicate_headers)
  
  log_info(paste0("Of the ", nrow(headers_df), " headers, there are ", duplicate_headers %>% filter(count == 1) %>% count(), " unique headers and ", duplicate_headers %>% filter(count > 1) %>% count(), " duplicate headers used across multiple files."))
  
  # ask user if duplicates can be removed
  user_input <- readline("Can the duplicates be removed? (Y/N) ")
  
  # consolidate duplicates
  if (tolower(user_input) == "y") {
    
    # pull only headers and remove duplicates
    current_headers <- current_headers %>% 
      select(header) %>% 
      distinct()
    
  } else if (tolower(user_input) == "n") {
    
    # pull only headers keeping all duplicates
    current_headers <- current_headers %>% 
      select(header)
    
  }
  
  log_info(paste0("Adding ", nrow(current_headers), " headers to the dd."))
  
  ### loop through header df and add to df #####################################
  for (i in 1:nrow(current_headers)) {
    
    current_header <- current_headers %>% 
      slice(i) %>% 
      unlist()
    
    # note: because all headers are coming from load_tabular_data, which currently only reads in column headers, Term_Type is hard coded to be "column_header"
    current_dd_skeleton <- current_dd_skeleton %>% 
      add_row(
        "Column_or_Row_Name" = as.character(current_header),
        "Unit" = "",
        "Definition" = "",
        "Data_Type" = "", 
        "Term_Type" = "column_header"
      )
    
  }
  

  ### adding dd and flmd headers if applicable #################################
  if (tolower(user_input_add_dd_headers) == "y"){
    
    log_info("Adding the 5 dd headers to the dd.")
    
    # adding dd headers to dd if user indicated Y
    for (header in dd_headers) {
      current_dd_skeleton <- current_dd_skeleton %>% 
        add_row(
          "Column_or_Row_Name" = as.character(header),
          "Unit" = "",
          "Definition" = "",
          "Data_Type" = "", 
          "Term_Type" = "column_header"
        )
    }
  }
  
  if (tolower(user_input_add_flmd_headers == "y")) {
    
    log_info("Adding the 7 flmd headers to the dd.")
    
    # adding flmd headers to dd if user indicated Y
    for (header in flmd_headers) {
      current_dd_skeleton <- current_dd_skeleton %>% 
        add_row(
          "Column_or_Row_Name" = as.character(header),
          "Unit" = "",
          "Definition" = "",
          "Data_Type" = "", 
          "Term_Type" = "column_header"
        )
    }
  }
  
  ### clean up #################################################################
  current_dd_skeleton <- current_dd_skeleton %>% 
    arrange(Column_or_Row_Name)
  
  log_info(paste0("The dd skeleton has ", nrow(current_dd_skeleton), " headers."))
  
  log_info("create_dd_skeleton complete.")
  return(current_dd_skeleton)  
    
}
