### load_tabular_data_from_flmd.R ###############################################
# Date Created: 2024-04-19
# Date Updated: 2024-06-20
# Author: Bibi Powers-McCormack

# Objective: Read in tabular data using the flmd to get file paths and header row info

# Inputs: 
  # directory (the absolute directory up until the path provided in the flmd)
  # flmd df (the return of the create_flmd_skeleton.R function)
  # exclude files (relative file paths to not include)
  # include files (relative file paths of files to include)

# Outputs: 
  # a list that has
    # directory
    # vector of relative file paths
    # list of each tabular data file

# Assumptions: 
  # data will be pulled based on directory (including any files not listed in flmd)
  # only data with .csv or .tsv file extensions will be read in
  # the tabular data is a single data matrix
  # the data are organized with column headers (not row headers)
  # data files can have header rows above and/or below the column headers
  # it skips all rows that begin with a #

# Status: initial draft complete
  # possible enhancement: optional argument to specify if data are there are no header rows (with or without #), then read in without asking for input


### TEST SPACE #################################################################
directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/ECA_Data_Package/EC_Data_Package"
exclude_files = NA
include_files = NA
flmd_df = test_flmd

test_directory <- "C:/Users/powe419/Downloads/Sandbox_Data"
test_exclude_files = NA
test_include_files = c("good_data.csv", "sad_data/bad_data_comments_2.csv", "sad_data/bad_data_comments_3.csv")
test_flmd_df <- tribble(
  ~File_Name, ~Column_or_Row_Name_Position,  ~File_Path,
  "good_data.csv", 1,  "/Sandbox_Data",
  # "bad_data_comments_2.csv", 1,  "/Sandbox_Data/sad_data",
  "bad_data_comments_3.csv", 1,  "/Sandbox_Data/sad_data",
)
TEST <- load_tabular_data_from_flmd(directory = test_directory, include_files = test_include_files, flmd_df = test_flmd_df)


### load_tabular_data_file function ############################################

load_tabular_data_from_flmd <- function(directory, flmd_df = NA, exclude_files = NA_character_, include_files = NA_character_){
  
  ### Prep script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(fs)
  
  # load user inputs
  current_directory <- directory
  current_flmd_df <- flmd_df
  current_exclude_files <- exclude_files
  current_include_files <- include_files
  
  ### List Files ###############################################################
  
  # get parent directory
  current_parent_directory <- sub(".*/", "/", current_directory)
  
  # get all file paths
  log_info("Getting file paths from directory.")
  file_paths_all <- list.files(current_directory, recursive = T, full.names = T, all.files = T)
  
  # filter for only .csv and .tsv files
  file_paths_all_tabular <- file_paths_all[str_detect(file_paths_all, "\\.tsv$|\\.csv$")]
  current_file_paths <- file_paths_all_tabular
  
  # remove excluded files
  if (any(!is.na(exclude_files))) {
    
    current_file_paths <- file_paths_all_tabular[!file_paths_all_tabular %in% file.path(current_directory, exclude_files)]
    
  }
  
  # filter to only keep included files
  if (any(!is.na(include_files))) {
    
    current_file_paths <- file_paths_all_tabular[file_paths_all_tabular %in% file.path(current_directory, include_files)]
    
  }
  
  # initialize df with file names
  current_df_metadata <- tibble(
    "File_Name" = basename(current_file_paths),
    "File_Path_Absolute" = current_file_paths) %>% 
    mutate("Header_Position" = NA_real_,
           "Data_Start_Row" = NA_real_)
  
  log_info(paste0("Planning to load ", length(current_file_paths), " of the ", length(file_paths_all_tabular), " tabular files."))
  
  
  ### FLMD present? ############################################################
  
  # if the flmd is present... 
  
  if (is.data.frame(flmd_df)) {
    
    log_info("Matching up flmd with files in directory.")
    
    # clean up flmd by fixing file path and selecting only certain cols
    current_flmd_df <- flmd_df %>%
      mutate(File_Path_Absolute = paste0(str_replace(File_Path, current_parent_directory, ""), "/", File_Name)) %>%  # removes parent dir and adds file name
      mutate(File_Path_Absolute = paste0(current_directory, File_Path_Absolute)) %>% # makes it absolute
      select(File_Name, Header_Position = Column_or_Row_Name_Position, File_Path_Absolute) %>% 
      filter(str_detect(File_Name, "\\.tsv$|\\.csv$")) # filter for only .csv and .tsv files
  
    # check for difference between the dir and flmd
    files_not_in_flmd <- setdiff(current_file_paths, current_flmd_df$File_Path_Absolute)
    files_not_in_dir <- setdiff(current_flmd_df$File_Path_Absolute, current_file_paths)
    
    if (length(files_not_in_flmd) > 0) {
      log_warn(paste0("The following file is in the directory but NOT in the flmd: ", basename(files_not_in_flmd)))
    }
    
    if (length(files_not_in_dir > 0 )) {
      log_warn(paste0("The following file is in the flmd but NOT in the directory: ", basename(files_not_in_dir)))
    }
  
    # join flmd to dir df
    current_df_metadata <- left_join(current_df_metadata, current_flmd_df, by = c("File_Name", "File_Path_Absolute")) %>% 
      mutate(Header_Position = coalesce(Header_Position.x, Header_Position.y)) %>% 
      select(File_Name, Header_Position, Data_Start_Row, File_Path_Absolute)
    
  } 
  
  ### Get header_position for any remaining files ##############################
  
  log_info("Asking for remaining header position info.")
  
  # getting files that don't have a header_position
  current_df_metadata_missing_header_position <- current_df_metadata %>% 
    filter(is.na(.$Header_Position))
  
  # if there are files that have missing header info...
  if (nrow(current_df_metadata_missing_header_position) > 0) {
  
    # function to ask for header row info
    ask_user_input_header_position <- function() {
      # ask location of column header
      user_input_column_or_row_name_position <- readline(prompt = "What line has the column headers? (Enter 0 if in the correct place) ")
      current_column_or_row_name_position <- as.numeric(user_input_column_or_row_name_position)
      
      # now increment up the column_or_row_name_position by 1 because reporting format says to use 1 if headers are in the correct positon (not 0)
      current_column_or_row_name_position <- current_column_or_row_name_position + 1
      
      return(current_column_or_row_name_position)
    }
    
    # go through tabular data missing header position
    for (i in 1:nrow(current_df_metadata_missing_header_position)) {
      
      current_df_metadata_file_path_absolute <- current_df_metadata_missing_header_position$File_Path_Absolute[i]
      
      if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
        
        # read in current file
        current_tabular_file <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", comment = "#", show_col_types = F)
        
      } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
        
        # read in current file
        current_tabular_file <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", comment = "#", show_col_types = F)
        
      }
      
      log_info(paste0("Viewing tabular file ", i, " of ", nrow(current_df_metadata_missing_header_position), ": ", basename(current_df_metadata_file_path_absolute)))
      
      # show file
      View(current_tabular_file)
      
      # run function
      current_header_position <- ask_user_input_header_position()
      
      # quick check to confirm the user input - if either values are less than 0, rerun function because the user entered them wrong
      while(current_header_position < 0) {
        
        log_info("Asking for user input again because prevoius input included an invalid (negative) value. ")
        
        current_header_position <- ask_user_input_header_position()
        
      }
      
      # save header position into df metadata
      current_df_metadata <- current_df_metadata %>% 
        mutate(Header_Position = case_when(.$File_Path_Absolute == current_df_metadata_file_path_absolute ~ current_header_position, T ~ Header_Position))
      
    }  
    
  }
  # you should now have Header_Position for all files
  
  ### Ask for start data for each file #########################################
    
  log_info("Asking for the row the data start on for all files.")
  
  # function to ask for start data row info
  ask_user_input_data_start_row <- function() {
    
    # ask for row that the data starts on
    user_input_data_start_row <- readline(prompt = "What line does the data start on? ")
    user_input_data_start_row <- as.numeric(user_input_data_start_row)
    
    return(user_input_data_start_row)
  }
  
  for (j in 1:nrow(current_df_metadata)) {
    
    # get current file path
    current_df_metadata_file_path_absolute <- current_df_metadata$File_Path_Absolute[j]
    
    if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
      
      # read in current file (does NOT include comment = "#" and does NOT read in col headers)
      current_tabular_file <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F)
      
    } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
      
      # read in current file (does NOT include comment = "#" and does NOT read in col headers)
      current_tabular_file <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F)
      
    }
    
    log_info(paste0("Viewing tabular file ", j, " of ", nrow(current_df_metadata), ": ", basename(current_df_metadata_file_path_absolute)))
    
    # show file
    View(current_tabular_file)
    
    # run function that asks for what row the data start on
    current_data_start_row <- ask_user_input_data_start_row()
    
    # quick check to confirm the user input - if either values are less than 0, rerun function because the user entered them wrong
    while(current_data_start_row < 0) {
      
      log_info("Asking for user input again because prevoius input included an invalid (negative) value. ")
      
      current_data_start_row <- ask_user_input_data_start_row()
      
    }
    
    # store start data row into the current_df_metadata
    current_df_metadata <- current_df_metadata %>% 
      mutate(Data_Start_Row = case_when(.$File_Path_Absolute == current_df_metadata_file_path_absolute ~ current_data_start_row, T ~ Data_Start_Row))
    
    
  }
  
  ### Use data inputs to read in data ##########################################
  
  log_info("Reading in all data based on previous inputs and preparing to return final list.")
  
  # initialize empty list to store the data
  all_loaded_data <- list()
  
  # for each row in the df_metadata...
  for (k in 1:nrow(current_df_metadata)) {
    
    # get k row
    current_df_k_row <- current_df_metadata[k, ]
  
    # name the df the absolute file path
    current_df_metadata_file_path_absolute <- current_df_metadata$File_Path_Absolute[k]
  
    # use the df_metadata to get the column headers
    if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
      
      # read in current file
      current_df_headers <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", comment = "#", col_names = F, show_col_types = F) %>% 
        slice(current_df_k_row$Header_Position) %>% 
        unlist() %>% 
        as.character()
      
    } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
      
      # read in current file
      current_df_headers <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", comment = "#", col_names = F, show_col_types = F) %>% 
        slice(current_df_k_row$Header_Position) %>% 
        unlist() %>% 
        as.character()
    }
  
    # use the data start to read in data (don't pull in columns and don't use comment = "#")
    if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
      
      # read in current file (does NOT include comment = "#" and does NOT read in col headers)
      current_df_data <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, skip = current_df_k_row$Data_Start_Row - 1)
      
    } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
      
      # read in current file (does NOT include comment = "#" and does NOT read in col headers)
      current_df_data <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, skip = current_df_k_row$Data_Start_Row - 1)
    }
    
    # rename columns with the col headers that were already pulled
    colnames(current_df_data) <- current_df_headers
    
    # add new data to full list
    all_loaded_data[[current_df_metadata_file_path_absolute]] <- current_df_data
    
  }
  
  # return all data
  output <- list(inputs = list(directory = current_directory,
                               flmd_df = current_flmd_df,
                               exclude_files = current_exclude_files,
                               include_files = current_include_files),
                 tabular_data = all_loaded_data)
  
  log_info("load_tabular_data_from_flmd complete.")
  return(output)
    
}

