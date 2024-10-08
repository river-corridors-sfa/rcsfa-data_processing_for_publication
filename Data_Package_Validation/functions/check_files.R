### check_files.R ########################################################
# Date Created: 2024-02-08
# Author: Bibi Powers-McCormack

# Objective: Give a directory and have it check all file paths, file names, and file extensions for the following...
  # no spaces
  # no special characters
    # allowed chrs: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen
  # no invalid extensions
    # invalid extensions: 
        # microsoft extensions: .docx, .xlsx, .pptx, .ppt
        # matlab extensions: .m, .fig, .mat, .mlx, .p, .mdl

# Input: 
  # relative file paths generated from load_tabular_data()

# Output: 
  # list that includes
    # directory given
    # report of checks
    # list of data checks
    # list of failed checks


### FUNCTION ###################################################################

check_files <- function(directory) {
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(clipr)
  
  # load user inputs
  current_directory <- directory
  
  
  ### Create empty output ######################################################
  
  # initialize an empty list to store the returned output
  data_checks <- list(
    directory = current_directory,
    report = data.frame(),
    data_checks = list(
      folders = data.frame(),
      files = data.frame()),
    failed_checks = data.frame()
  )
  
  # initialize empty report
  report <- data.frame(
    pass_check = as.character(),
    type = as.character(),
    assessment = as.character(),
    summary = as.character()
  )
  
  # initialize an empty df to store the failed checks
  failed_checks <- data.frame(
    pass_check = as.logical(),
    type = as.character(),
    item = as.character(),
    assessment = as.character(),
    source = as.character(),
    notes = as.character()
  )
  
  # Run Checks #################################################################
  # This checks all file paths, file names, and file extensions for spaces, special characters, and invalid extensions
    # allowed chrs: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen
  # invalid extensions: 
    # microsoft extensions: .docx, .xlsx, .pptx, .ppt
    # matlab extensions: .m, .fig, .mat, .mlx, .p, .mdl
  
  
  ### Folder Checks ----
  current_folders <- list.dirs(path = current_directory, full.names = F, recursive = T)
  
  log_info(paste0("Checking ", length(current_folders), " folder(s) for errors."))
  
  # initialize empty df for folder checks
  folder_checks <- data.frame(
    pass_check = as.logical(),
    type = as.character(),
    item = as.character(),
    assessment = as.character(),
    source = as.character(),
    notes = as.character()
  )
  
  # this iterates through each folder, grabs the folder name and folder path. 
  # it checks the folder for spaces and special chrs. 
  # then adds it to the folder_checks df. 
  # then it assesses the folder_checks df to be able to create a summary report
  for (i in 1:length(current_folders)) {
    
    # get current folder path
    current_folder_path <- current_folders[i]
    
    # get current folder
    current_item <- basename(current_folder_path)
    
    # get associated parent folders
    current_source <- dirname(current_folder_path)
    
    # check for spaces
    has_spaces <- grepl(" ", current_item)
    
    # remove spaces
    current_item_no_spaces <- gsub(" ", "", current_item)
    
    # split out by character
    split_chrs <- unlist(strsplit(current_item_no_spaces, ""))
    
    # check for special characters
    has_special_chrs <- length(grep("[^a-zA-Z0-9_/\\.-]", split_chrs)) > 0 # chrs allowed: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen.
    
    # get the special character values
    if (has_special_chrs == FALSE) {
      special_characters <- "none"
    } else {
      special_characters <- paste0("\"", paste(grep("[^a-zA-Z0-9_/\\.-]", split_chrs, value = TRUE), collapse = ""), "\"")
    }
    
    # add row to checks
    folder_checks <- folder_checks %>% 
      add_row(pass_check = !has_spaces,
              type = "folder",
              item = current_item,
              assessment = "no_spaces",
              source = current_source,
              notes = NA_character_) %>% 
      add_row(pass_check = !has_special_chrs,
              type = "folder",
              item = current_item,
              assessment = "no_special_chrs",
              source = current_source,
              notes = paste("special characters:", special_characters, sep = " "))
  }
  
  # assess folder checks
  
  # initialize empty report
  folder_report <- data.frame(
    pass_check = as.character(),
    type = as.character(),
    assessment = as.character(),
    summary = as.character()
  )
  
  #  update for spaces
  folder_no_spaces_check <- folder_checks %>%
    filter(assessment == "no_spaces" & pass_check == FALSE)
  
  if (nrow(folder_no_spaces_check) > 0) {
    
    # update report with FAILED
    folder_report <- folder_report %>% 
      add_row(pass_check = "FAILED",
              type = "folder",
              assessment = "no_spaces",
              summary = paste0("Found spaces in ", nrow(folder_no_spaces_check), " folders: ", toString(folder_no_spaces_check$item)))
    
    # add failed checks to master failed_checks df
    failed_checks <- failed_checks %>% 
      add_row(folder_no_spaces_check)
      
    
  } else if (nrow(folder_no_spaces_check) == 0) {
    
    # update report with PASSED
    folder_report <- folder_report %>% 
      add_row(pass_check = "PASSED",
              type = "folder",
              assessment = "no_spaces",
              summary = paste0("There are no spaces in ", length(current_folders), " folders."))
  }
  
  # update for special chrs
  folder_no_special_chrs_check <- folder_checks %>%
    filter(assessment == "no_special_chrs" & pass_check == FALSE)
  
  if (nrow(folder_no_special_chrs_check) > 0) {
    
    # update report with FAILED
    folder_report <- folder_report %>% 
      add_row(pass_check = "FAILED",
              type = "folder",
              assessment = "no_special_chrs",
              summary = paste0("Found special characters in ", nrow(folder_no_special_chrs_check), " folders: ", toString(folder_no_special_chrs_check$item)))
    
    # add failed checks to master failed_checks df
    failed_checks <- failed_checks %>% 
      add_row(folder_no_special_chrs_check)
    
  } else if (nrow(folder_no_special_chrs_check) == 0) {
    
    # update report with PASSED
    folder_report <- folder_report %>% 
      add_row(pass_check = "PASSED",
              type = "folder",
              assessment = "no_special_chrs",
              summary = paste0("There are no special characters in ", length(current_folders), " folders."))
    
  }
  
  # add folder_checks to output list
  data_checks$data_checks$folders <- folder_checks
  
  log_info("Folder check complete.")
  
  
  ### File Checks ----
  # file checks complete 3 steps for each check (spaces, special chrs, and extensions)
    # 1. completes the checks for all 3 checks
    # then assesses each check...
    # 2. filters for failed checks and adds to failed_checks df
    # 3. filters for failed checks and summarizes them in report
  
  current_files <- list.files(path = current_directory, full.names = F, recursive = T)
  
  log_info(paste0("Checking ", length(current_files), " file(s) for errors."))
  
  # initialize empty df for file checks
  file_checks <- data.frame(
    pass_check = as.logical(),
    type = as.character(),
    item = as.character(),
    assessment = as.character(),
    source = as.character(),
    notes = as.character()
  )
  
  for (i in 1:length(current_files)) {
    
    # get current folder path
    current_folder_path <- current_files[i]
    
    # get current file
    current_item <- basename(current_folder_path)
    
    # get associated folder
    current_source <- dirname(current_folder_path)
    
    # check for spaces
    has_spaces <- grepl(" ", current_item)
    
    # remove spaces
    current_item_no_spaces <- gsub(" ", "", current_item)
    
    # split out by character
    split_chrs <- unlist(strsplit(current_item_no_spaces, ""))
    
    # check for special characters
    has_special_chrs <- length(grep("[^a-zA-Z0-9_/\\.-]", split_chrs)) > 0 # chrs allowed: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen.
    
    # get the special character values
    if (has_special_chrs == FALSE) {
      special_characters <- "none"
    } else {
      special_characters <- paste0("\"", paste(grep("[^a-zA-Z0-9_/\\.-]", split_chrs, value = TRUE), collapse = ""), "\"")
    }
    
    # get the extension
    current_extension <- tools::file_ext(current_item)
    
    # get list of invalid extensions
    bad_extensions <- c("docx", "doc", "xlsx", "pptx", "ppt", # microsoft extensions
                        ".m", ".fig", ".mat", ".mlx", ".p", ".mdl" # matlab extensions
    )
    # check for not approved extensions
    non_proprietary <- !current_extension %in% bad_extensions
    
    # add row to checks
    file_checks <- file_checks %>% 
      # add row for spaces
      add_row(pass_check = !has_spaces,
              type = "file",
              item = current_item,
              assessment = "no_spaces",
              source = current_source,
              notes = NA_character_) %>% 
      # add row for special chrs
      add_row(pass_check = !has_special_chrs,
              type = "file",
              item = current_item,
              assessment = "no_special_chrs",
              source = current_source,
              notes = paste("special characters:", special_characters, sep = " ")) %>% 
      # add row for extensions
      add_row(pass_check = non_proprietary,
              type = "file",
              item = current_item,
              assessment = "non_proprietary",
              source = current_source,
              notes = paste0("extension: ", current_extension))

  }
  
  # assess file checks
  
  # initialize empty report
  file_report <- data.frame(
    pass_check = as.character(),
    type = as.character(),
    assessment = as.character(),
    summary = as.character()
  )
 
  #  update for spaces
  file_no_spaces_check <- file_checks %>%
    filter(assessment == "no_spaces" & pass_check == FALSE)
  
  if (nrow(file_no_spaces_check) > 0) {
    
    # update report with FAILED
    file_report <- file_report %>% 
      add_row(pass_check = "FAILED",
              type = "file",
              assessment = "no_spaces",
              summary = paste0("Found spaces in ", nrow(file_no_spaces_check), " files: ", toString(file_no_spaces_check$item)))
    
    # add failed checks to master failed_checks df
    failed_checks <- failed_checks %>% 
      add_row(file_no_spaces_check)
    
    
  } else if (nrow(file_no_spaces_check) == 0) {
    
    # update report with PASSED
    file_report <- file_report %>% 
      add_row(pass_check = "PASSED",
              type = "file",
              assessment = "no_spaces",
              summary = paste0("There are no spaces in ", length(current_files), " files."))
  }
  
  # update for special chrs
  file_no_special_chrs_check <- file_checks %>%
    filter(assessment == "no_special_chrs" & pass_check == FALSE)
  
  if (nrow(file_no_special_chrs_check) > 0) {
    
    # update report with FAILED
    file_report <- file_report %>% 
      add_row(pass_check = "FAILED",
              type = "file",
              assessment = "no_special_chrs",
              summary = paste0("Found special characters in ", nrow(file_no_special_chrs_check), " files: ", toString(file_no_special_chrs_check$item)))
    
    # add failed checks to master failed_checks df
    failed_checks <- failed_checks %>% 
      add_row(file_no_special_chrs_check)
    
  } else if (nrow(file_no_special_chrs_check) == 0) {
    
    # update report with PASSED
    file_report <- file_report %>% 
      add_row(pass_check = "PASSED",
              type = "file",
              assessment = "no_special_chrs",
              summary = paste0("There are no special characters in ", length(current_files), " files."))
  }
  
  # update for extensions
  file_non_proprietary_check <- file_checks %>% 
    filter(assessment == "non_proprietary" & pass_check == FALSE)
  
  if (nrow(file_non_proprietary_check) > 0) {
    
    # update report with FAILED
    file_report <- file_report %>% 
      add_row(pass_check = "FAILED",
              type = "file",
              assessment = "non_proprietary",
              summary = paste0("Found non-proprietary extensions in ", nrow(file_non_proprietary_check), " files: ", toString(file_non_proprietary_check$item)))
    
    # add failed checks to master failed_checks df
    failed_checks <- failed_checks %>% 
      add_row(file_non_proprietary_check)
    
  } else if (nrow(file_non_proprietary_check) == 0) {
    
    # update report with PASSED
    file_report <- file_report %>% 
      add_row(pass_check = "PASSED",
              type = "file",
              assessment = "non_proprietary",
              summary = paste0("There are no non-proprietary extensions in ", length(current_files), " files."))
  }
  
  # add file_checks to output list
  data_checks$data_checks$files <- file_checks
  
  log_info("File check complete.")

  
  ### Clean up output ##########################################################
  
  # add report to output list
  data_checks$report <- bind_rows(list(folder_report, file_report)) %>% 
    as.data.frame()
  
  # add failed_checks to output list
  data_checks$failed_checks <- failed_checks
  
  report_summary <- data_checks$report %>% 
    select(pass_check, type, assessment)
  
  print(report_summary)
  
  log_info("Copying report to clipboard.")
  
  write_clip(data_checks$report)
  
  log_info("check_files complete")
  return(data_checks)
  
}

