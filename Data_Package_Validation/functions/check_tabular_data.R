### check_tabular_data.R #######################################################
# Date Created: 2024-02-13
# Author: Bibi Powers-McCormack

# Objective: Give the return from load_tabular_data() and have it check for the following...
  # check headers for 
    # no spaces
    # no special characters
      # allowed chrs: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen
  # check cells for 
    # NA missing values
    # commas

# Input: 
  # list generated from load_tabular_data()

# Output: 
  # list that includes
    # load_tabular_data() input
    # df summary of headers
    # df report of checks
    # df of data checks
    # df of failed checks

# Assumptions: 
  # allowed chrs: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen


### FUNCTION ###################################################################
check_tabular_data <- function(data_package_data) {
  
  ### Prep script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(clipr)
  library(knitr)
  
  # load user inputs
  current_data_package_data <- data_package_data
  current_data <- data_package_data$data
  current_headers <- data_package_data$headers
  
  # load helper functions
  source("./Data_Package_Validation/functions/check_for_no_spaces.R")
  source("./Data_Package_Validation/functions/check_for_no_special_chrs.R")
  source("./Data_Package_Validation/functions/check_for_invalid_chr_in_string.R")
  
  ### Create empty output ######################################################
  
  # initialize an empty list to store the returned output
  data_checks <- list(
    data_package_data_from_load_tabular_data = current_data_package_data, # the input provided by the user
    headers = data.frame(), # count and summary of the headers
    data_checks = data.frame(
        pass_check = as.logical(), # whether or not the check passed. TRUE = passed; FALSE = failed
        type = as.character(), # the level of hierarchy the check assessed (folder, file, header, column)
        item = as.character(), # the name of whatever got checked
        assessment = as.character(), # the name of the check performed (no_spaces, no_special_chrs, no_NAs, no_commas)
        source = as.character(), # the parent information about the item (folder path, file name)
        notes = as.character()), # additional notes from the assessment
    report = data.frame(),
      # pass_check = whether or not the check passed or failed
      # type = the level of hierarchy the check assessed (folder, file, header, column)
      # assessment = the name of the check performed (no_spaces, no_special_chrs, no_NAs, no_commas)
      # summary = count of items that passed/failed the check
      # files = a string of the applicable files that passed/failed the check
    report_failed = data.frame() # filtered report for pass_check == FAILED
  )
  
  # Summarize headers ##########################################################
  
  log_info("Summarizing headers.")
  
  data_checks$headers <- current_headers %>% 
    mutate(file = basename(file)) %>% 
    group_by(header) %>% 
    summarise(header_count = n(), # collapse identical definitions
              files = toString(file)) %>% 
    ungroup() %>% 
    arrange(header)
  
  # Run checks #################################################################
  
  log_info(paste0("Checking ", max(seq_along(current_data)), " tabular data files."))
  
  # loop through each df in the list
  for (i in seq_along(current_data)) {
    
    # get df
    current_df <- current_data[[i]]
    
    # get df name and store it as "source"
    source <- names(current_data)[i]
    
    # loop through each column in the df
    log_info(paste0("Checking ", ncol(current_df), " headers from file ", i, " of ", max(seq_along(current_data)), ":'", basename(source), "'."))
    
    for (j in 1:ncol(current_df)) {
      
      # get current column
      current_column <- current_df %>% 
        select(all_of(j))
      
      # get current header and store it as "item"
      item <- colnames(current_column)
      
      # check headers ----
      
        # check for spaces (T = pass check and does NOT have spaces)
          # this checks for any periods in the header
          # assumption: when R uses read_csv(), it replaces spaces with periods
        has_spaces <- check_for_invalid_chr_in_string(string = item, search_invalid_chr = "\\.", assessment = "no_spaces", notes = "If check fails, header might have spaces") %>% 
          mutate(type = "header",
                 source = source) %>% 
          select(pass_check, type, item, assessment, source, notes)
      
        # check for special chrs (T = passes check and does NOT have special chrs)
        has_special_chrs <- check_for_no_special_chrs(item) %>% 
          mutate(type = "header",
                 source = source,
                 notes = NA_character_) %>% 
          select(pass_check, type, item, assessment, source, notes)
      
        # check for questionable (empty or duplicate) header names (T = passes check and does NOT have questionable headers)
        has_questionable_headers <- check_for_invalid_chr_in_string(item, "\\...", "no_questionable_headers", "If check fails, header is either missing or not unique") %>% 
          mutate(type = "header",
                 source = source) %>% 
          select(pass_check, type, item, assessment, source, notes)
      
      
      # check column ----
        
        # filter for NA values
        check_NAs_filter <- current_column[!complete.cases(current_column), ] %>% 
          count() %>% 
          pull(n)
        
        # check for NA (T = has NA values)
        check_NAs <- check_NAs_filter > 0
        
        has_NAs <- data.frame(
          pass_check = !check_NAs, # T = passes check and does NOT have NA values
          type = "column",
          item = item,
          assessment = "no_NAs",
          source = source,
          notes = paste0("'", item, "' has ", check_NAs_filter, " rows with NA values."))
        
        # check for commas
        check_commas_filter <- current_column %>% 
          filter(str_detect(as.character(.[[1]]), ",")) %>% 
          count() %>% 
          pull(n)
        
        # check for commas (T = has commas)
        check_commas <- check_commas_filter > 0
        
        has_commas <- data.frame(
          pass_check = !check_commas, # T = passes check and does NOT have NA values
          type = "column",
          item = item,
          assessment = "no_commas",
          source = source,
          notes = paste0("'", item, "' has ", check_commas_filter, " rows that contain commas."))
        

        # add to data checks
        data_checks$data_checks <- data_checks$data_checks %>% 
            add_row(has_spaces) %>% 
            add_row(has_special_chrs) %>% 
            add_row(has_questionable_headers) %>% 
            add_row(has_NAs) %>% 
            add_row(has_commas)
      
    }
    
  }
    
    # Assess checks ############################################################
  
    log_info(paste0("Finished checking ", length(current_data), " files."))
  
      
    # add a filtered view to generate report
    data_checks$report <- data_checks$data_checks %>% 
      group_by(pass_check, type, source, assessment) %>% 
      summarise(count = n(),
                items = paste(item, collapse = ", ")) %>% 
      mutate(pass_check = case_when(pass_check == TRUE ~ "PASSED",
                                    pass_check == FALSE ~ "FAILED"),
             summary = paste0(count, " ", type, "(s) ", tolower(pass_check), " the check for ", assessment, " in '", basename(source), "': ", items)) %>% 
      select(-c(count, items)) %>% 
      ungroup()
    
    # add a filtered view to generate report failed
    data_checks$report_failed <- data_checks$report %>% 
      filter(pass_check == "FAILED")
    
    # add a filtered view to generate summary
    data_checks$summary <- data_checks$report %>% 
      mutate(base_file = basename(source)) %>% 
      arrange(base_file) %>% 
      select(-source) %>% 
      distinct() %>% 
      group_by(pass_check, type, assessment) %>% 
      summarise(count = n(),
                files = paste(base_file, collapse = ", ")) %>% 
      mutate(summary = paste0(count, " file(s) ", tolower(pass_check), " the check for ", assessment, "."),
             files = paste0("Files that ", tolower(pass_check), ": ", files)) %>% 
      select(-c(count)) %>% 
      ungroup() %>% 
      select(pass_check, type, assessment, summary, files)
  
    log_info("Data check complete.")
    
    # Clean up output ##########################################################
    
    report_summary <- data_checks$summary %>% 
      select(pass_check, type, assessment, summary) %>% 
      arrange(assessment) %>% 
      kable() %>% 
      print()
    
    log_info("Copying report to clipboard.")
    
    write_clip(data_checks$summary)
    
    log_info("check_data complete")
    
    return(data_checks)
    
    
  }
