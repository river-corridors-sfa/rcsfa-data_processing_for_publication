### create_flmd_skeleton.R ################################################
# Date Created: 2024-06-14
# Date Updated: 2024-07-11
# Author: Bibi Powers-McCormack

# Objective: Create an flmd with all the columns filled out, except for the File_Description

# Inputs: 
  # directory = string of the absolute folder file path. Required argument. 
  # exclude_files = vector of files to exclude from within the dir. Optional argument; default is NA. 
  # include_files = vector of files to include from within the dir. Optional argument; default is NA. 
  # file_n_max = number of rows to load in. Optional argument; default is 100. The only time you'd want to change this is if there are more than 100 rows before the data matrix starts; if that is the case, then increase this number. 

# Outputs: 
  # flmd df that lists out all the provided files
    # columns include: "File_Name", "File_Description", "Standard", "Header_Rows", "Column_or_Row_Name_Position"

# Assumptions: 
  # Counts skip all rows that begin with a #
  # If column_or_row_name_position in the correct place, the value is 1
  # If there are no header_rows, the value is 0
  # If there are tabular data and user decides to not populate header row info, then those cells populate with NA
  # Any non-tabular data gets -9999 for header_rows and column_or_row_name_position
  # Tabular data is only data where the file extension is .csv or .tsv
  # Tabular data is a single data matrix
  # Tabular data files are organized with column headers (not row headers)
  # Tabular data can be header rows above and/or below the column headers
  # exclude_files and include_files only take relative file paths and require the file name; directories are not allowed

# Status: Complete. Awaiting testing after confirmation about formatting from ESS-DIVE
  # Brie informally reviewed on 2024-06-24 (see issue #17)

# Examples

  # # 1) example where you want to include all files in a given directory in your flmd
  # flmd_df <- create_flmd_skeleton(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory")
  # 
  # # 2) example where you don't want to include a file in an archive folder
  # flmd_df <- create_flmd_skeleton(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory",
  #                                 exclude_files = "archive/archived_file.csv")
  # 
  # # 3) example where you don't want to include all files in an archive folder
  # archived_files <- list.files(path = paste0(directory, "/archive"), recursive = T, full.names = T) %>% # use list.files() to gather the (relative) names of all archived files
  #                   str_remove(., paste0(directory, "/")) 
  # 
  # flmd_df <- create_flmd_skeleton(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory",
  #                                 exclude_files = archived_files)
  # 
  # # 4) example where you have 2 files with header rows and 98 without
  # # you can split the data and import it separately; this allows the user to not have to enter row header info on the 98 files that are regularly structured
  # files_with_headers <- c("folder/of/data/with/header/rows/file_1.csv", # first create a vector of all relative file paths that have header rows
  #                         "folder/of/data/with/header/rows/file_2.csv")
  # 
  # flmd_df_with_headers <- create_flmd_skeleton(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory",
  #                                             include_files = files_with_headers) # this loads in only the 2 files with headers. Select "A" when asked for `user_input_add_header_info`
  # 
  # flmd_df_without_headers <- create_flmd_skeleton(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory",
  #                                                 exclude_files = files_with_headers) # this loads all the remaining files. Select "F" when asked for `user_input_add_header_info`
  # 
  # flmd_df <- bind_rows(flmd_df_with_headers, # now combine the two dfs to create your complete flmd.
  #                      flmd_df_without_headers) 
  # 
  # # After exporting, manually replace all NAs with column_or_row_name_position = 1 and header_rows = 0 for the remaining 98 files without header rows
  # # You may also need to reorder the files



### FUNCTION ###################################################################

create_flmd_skeleton <- function(directory, exclude_files = NA_character_, include_files = NA_character_, file_n_max = 100) {
  
  
  ### Prep Script ##############################################################
  
  log_info("This function takes 4 arguments: 
            - directory (required)
            - exclude_files (optional; default = NA)
            - include_files (optional; default = NA)
            - file_n_max (optional; default = 100)
  Open the function script to see argument definitions, function assumptions, and examples.")
  
  # load libraries
  pacman::p_load(tidyverse, # cuz duh
                 rlog, # for logging documentation
                 fs) # for getting file extension
  
  
  ### List Files ###############################################################
  
  # get parent directory
  current_parent_directory <- sub(".*/", "/", directory)
  
  # get all file paths
  log_info("Getting file paths from directory.")
  file_paths_all <- list.files(directory, recursive = T, full.names = T, all.files = T)
  current_file_paths <- file_paths_all
  
  # remove excluded files
  if (any(!is.na(exclude_files))) {
    
    current_file_paths <- file_paths_all[!file_paths_all %in% file.path(directory, exclude_files)]
    
  }
  
  # filter to only keep included files
  if (any(!is.na(include_files))) {
    
    current_file_paths <- file_paths_all[file_paths_all %in% file.path(directory, include_files)]
    
  }
  
  # initialize empty df
  current_flmd_skeleton <- tibble(
    "File_Name" = as.character(),
    "File_Description" = as.character(),
    "Standard" = as.character(),
    "Header_Rows" = as.numeric(),
    "Column_or_Row_Name_Position" = as.numeric(),
    "File_Path" = as.character()
  )
  
  log_info(paste0("Adding ", length(current_file_paths), " of the ", length(file_paths_all), " files to the flmd."))
  
  
  ### check and ask to add flmd, dd, readme files ##############################
  log_info("Checking for presence of flmd, dd, and readme files.")
  
  # check for presence of dd and flmd files
  flmd_file_present <- any(str_detect(current_file_paths, "flmd.csv"))
  dd_file_present <- any(str_detect(current_file_paths, "dd.csv"))
  pdf_file_present <- any(str_detect(current_file_paths, "readme"))
  
  if (flmd_file_present == FALSE) {
    user_input_add_flmd_file <- readline(prompt = "The flmd file is not present. Would you like to add a placehold flmd to the flmd? (Y/N) ")
  } else {
    user_input_add_flmd_file <- "N"
  }
  
  if (dd_file_present == FALSE ) {
    user_input_add_dd_file <- readline(prompt = "The dd file is not present. Would you like to add a placeholder dd to the flmd? (Y/N) ")
  } else {
    user_input_add_dd_file <- "N"
  }
  
  if (pdf_file_present == FALSE) {
    user_input_add_readme_file <- readline(prompt = "The readme file is not present. Would you like to add a placehold readme to the flmd? (Y/N) ")
  } else {
    user_input_add_readme_file <- "N"
  }
  
  
  ### check and ask to include header position info ############################
  count_csv_files <- sum(str_detect(current_file_paths, "\\.csv$"))
  count_tsv_files <- sum(str_detect(current_file_paths, "\\.tsv$"))
  
  if (count_csv_files > 0 | count_tsv_files > 0) {
    
    log_info(paste0("There are ", count_csv_files, " csv file(s) and ", count_tsv_files, " tsv file(s)."))
    
    cat("What flmd columns do you want to fill out? If unsure, enter 'A':",
        "   - Enter 'A' if you want to fill in ALL columns",
        "   - Enter 'F' if you only wish to fill in the 'File_Name' column",
        sep = "\n")
    
    user_input_add_header_info <- readline(prompt = "Enter A/F ")
    
  }
  
  
  ### loop through files and add to df #########################################
  
  # create progress bar
  pb <- txtProgressBar(min = 0, max = length(current_file_paths), style = 3)
  
  for (i in 1:length(current_file_paths)) {
    
    # gather flmd components
    # get current file
    current_file_absolute <- current_file_paths[i]
    
    # get file name
    current_file_name <- basename(current_file_absolute)
    
    # get file path
    current_file_path <- str_replace(string = current_file_absolute, pattern = directory, replacement = "") %>% # absolute file path - directory: this removes the absolute file path to get the relative path for the given file
      paste0(current_parent_directory, .) %>% # parent directory + .: this adds the parent directory to the front of the file path
      str_replace(string = ., pattern = paste0("/", current_file_name), replacement = "") # . - "/" - current file name: this removes the file name from the relative directory so the end product is the file path with the parent directory and without the file name
    
    # if the file is tabular (is .csv or .tsv)
    if (str_detect(current_file_name, "\\.csv$|\\.tsv$")) {
      
      # update the standard with the CSV reporting format
      current_standard <- "ESS-DIVE Reporting Format for Comma-separated Values (CSV) File Structure (Velliquette et al. 2021)"
      
      # update the header rows with NA
      current_column_or_row_name_position <- NA_real_
      current_header_row <- NA_real_
      
      # if user said yes to adding header info...
      if (tolower(user_input_add_header_info) == "a") {
        
        if (str_detect(current_file_name, "\\.csv$")) {
          
          # read in current file
          current_tabular_file <- read_csv(current_file_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = file_n_max)
          
        } else if (str_detect(current_file_name, "\\.tsv$")) {
          
          # read in current file
          current_tabular_file <- read_tsv(current_file_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = file_n_max)
          
        }
        
        log_info(paste0("Viewing tabular file ", i, " of ", length(current_file_paths), ": ", current_file_name))
        
        # show file
        View(current_tabular_file)
        
        # function to ask for header row info
        ask_user_input <- function() {
          
          # ask if there is more than just the data matrix present
          user_input_has_header_rows <- readline(prompt = "Are header rows present (either above or below the column headers)? (Y/N) ")
          
          if (tolower(user_input_has_header_rows) == "y") {
            
            # ask location of column header
            user_input_column_or_row_name_position <- readline(prompt = "What line has the column headers? (Enter 0 if in the correct place) ")
            current_column_or_row_name_position <- as.numeric(user_input_column_or_row_name_position)
            
            # ask location of first data row
            user_input_first_data_row <- as.numeric(readline(prompt = "What line has the first row of data? "))
            
            # calculate header_row
            current_header_row <- user_input_first_data_row - current_column_or_row_name_position - 1
            
            # now increment up the column_or_row_name_position by 1 because reporting format says to use 1 if headers are in the correct position (not 0)
            current_column_or_row_name_position <- current_column_or_row_name_position + 1
            
            user_inputs <- list(current_column_or_row_name_position = current_column_or_row_name_position, current_header_row = current_header_row)
            
            
          } else {
            
            # if there is only a single data matrix/data doesn't have header rows, then col header is in row 1 and data headers = 0
            user_inputs <- list(current_column_or_row_name_position = 1, current_header_row = 0)
            
          }
          
          return(user_inputs)
        }
        
        # run function
        user_inputs <- ask_user_input()
        
        # quick check to confirm the user input - if either values are less than 0, rerun function because the user entered them wrong
        while(user_inputs$current_column_or_row_name_position < 0 | user_inputs$current_header_row <0) {
          
          log_info("Asking for user input again because previous input included an invalid (negative) value. ")
          
          user_inputs <- ask_user_input()
          
        }
        
        # pull results out of list
        current_column_or_row_name_position <- user_inputs$current_column_or_row_name_position
        current_header_row <- user_inputs$current_header_row
        
      }
      
    } else {
      
      # fill in empty standard
      current_standard <- "N/A"
      
      # fill in header rows assuming data is not tabular
      current_header_row <- -9999
      
      # fill in column or row name position assuming data is not tabular
      current_column_or_row_name_position <- -9999
      
    }
    
    # add to skeleton
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = current_file_name,
        "File_Description" = NA_character_,
        "Standard" = current_standard,
        "Header_Rows" = current_header_row,
        "Column_or_Row_Name_Position" = current_column_or_row_name_position,
        "File_Path" = current_file_path
      )
    
    # update progress bar
    setTxtProgressBar(pb, i)
    
  }
  
  # close progress bar
  close(pb)
  
  ### if user indicated, add readme, flmd, dd placeholders #####################
  
  # adding readme file to flmd is user indicated Y
  if (tolower(user_input_add_readme_file) == "y"){
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = "readme_[INSERT README FILE NAME].pdf",
        "File_Description" = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
        "Standard" = "N/A",
        "Header_Rows" = -9999,
        "Column_or_Row_Name_Position" = -9999,
        "File_Path" = current_parent_directory
        )
  }
  
  # adding flmd file to flmd if user indicated Y
  if (tolower(user_input_add_flmd_file) == "y") {
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = "[INSERT FLMD FILE NAME]_flmd.csv",
        "File_Description" = "File-level metadata that lists and describes all of the files contained in the data package.",
        "Standard" = "ESS-DIVE Reporting Format for Comma-separated Values (CSV) File Structure (Velliquette et al. 2021); ESS-DIVE Reporting Format for File-level Metadata (Velliquette et al. 2021)",
        "Header_Rows" = 0,
        "Column_or_Row_Name_Position" = 1,
        "File_Path" = current_parent_directory
      )
  }
  
  # adding dd file to flmd if user indicated Y
  if (tolower(user_input_add_dd_file) == "y") {
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      add_row(
        "File_Name" = "[INSERT DD FILE NAME]_dd.csv",
        "File_Description" = 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
        "Standard" = "ESS-DIVE Reporting Format for Comma-separated Values (CSV) File Structure (Velliquette et al. 2021).",
        "Header_Rows" = 0,
        "Column_or_Row_Name_Position" = 1,
        "File_Path" = current_parent_directory
      )
  }
  
  ### sort flmd ################################################################
  
  # sort rows by readme, flmd, dd, and then by File_Path and File_Name
  current_flmd_skeleton <- current_flmd_skeleton %>% 
    mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = T) ~ 1,
                                  grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                  grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                  T ~ 4)) %>% 
    arrange(sort_order, File_Path, File_Name) %>% 
    select(-sort_order)
  
  
  ### return filled out skeleton ###############################################
  
  log_info("create_flmd_skeleton complete.")
  return(current_flmd_skeleton)
  
}
