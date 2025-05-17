### load_tabular_data.R ########################################################
# Date Created: 2024-04-19
# Date Updated: 2025-06-16
# Author: Bibi Powers-McCormack


### load_tabular_data_file function ############################################

load_tabular_data <- function(files_df, 
                              flmd_df = NA, 
                              query_header_info = F,
                              file_n_max = 100){
  
  ### About the function #######################################################
  # Objective: Read in tabular data using the flmd to get file paths and header row info
  
  # Inputs: 
    # files_df = df with at least these 5 cols: all, absolute_dir, parent_dir, relative_dir, and file. Required argument. 
    # flmd_df = df with at least these 3 cols: File_Name, Column_or_Row_Name_Position, File_Path. Optional argument; default is NA. 
    # query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Select F if on NERSC. Optional argument; default is FALSE.  
    # file_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 100 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 100. 
    
  # Outputs: 
    # a list that has
    # directory
    # vector of absolute file paths, filtered down based on exclude/include inputs
    # list of each tabular data file
  
  # Assumptions: 
    # data will be pulled based on files_df (not the files listed in flmd_df)
    # only data with .csv or .tsv file extensions will be read in
    # the tabular data is a single data matrix
    # the data are organized with column headers (not row headers)
    # data files can have header rows above and/or below the column headers
  
  # Status: in progress
  
  ### Prep script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(fs)
  
  ### Validate Inputs ##########################################################
  
  # get parent directory
  current_parent_directory <- files_df %>% 
    distinct(parent_dir) %>% 
    pull()
  
  # get current directory
  current_directory <- files_df %>% 
    distinct(absolute_dir) %>% 
    pull()
  
  # does files_df have required cols?
  files_required_cols <- c("all", "absolute_dir", "parent_dir", "relative_dir", "file")
  
  if (!all(files_required_cols %in% names(files_df))) {
    
    # if files_df is missing required cols, error
    log_error(paste0("files_df is missing required column: ", setdiff(files_required_cols, names(files_df))))
    stop("Function terminating.")
  } # end of checking files required cols
  
  # is query_header_info logical?
  if (!is.logical(query_header_info) || length(query_header_info) != 1) {
    log_error("query_header_info must be a single logical value (TRUE or FALSE)")
    stop("Function terminating.")
  }
  
  
  ### Prepare tabular files ####################################################
  
  # get tabular files
  file_paths_tabular <- files_df %>% 
    filter(str_detect(file, "\\.tsv$|\\.csv$")) %>% 
    pull(all)
  
  # initialize df with file names
  tabular_metadata <- tibble(
    "File_Name" = basename(file_paths_tabular),
    "File_Path_Absolute" = file_paths_tabular) %>% 
    mutate("Header_Position" = NA_real_,
           "Data_Start_Row" = NA_real_)
  
  log_info(paste0("Planning to load ", length(file_paths_tabular), " tabular files."))
  
  if (query_header_info == F) {
    
    # if the user indicated that all tabular files don't have header info, then set data start = 2 and header position = 1
    tabular_metadata <- tabular_metadata %>% 
      mutate(Header_Position = 1, 
             Data_Start_Row = 2)
    
    # initialize empty list to store the data
    all_loaded_data <- list()
    
    # loop through metadata df
    for (k in 1:nrow(tabular_metadata)) {
      
      # get k row
      current_df_k_row <- tabular_metadata[k, ]
      
      # name the df the absolute file path
      current_df_metadata_file_path_absolute <- tabular_metadata$File_Path_Absolute[k]
      
      log_info(paste0("Reading in tabular file ", k, " of ", nrow(current_tabular_only_metadata), ": ", basename(current_df_metadata_file_path_absolute)))
      
      # use the data start to read in data (don't pull in columns and don't use comment = "#")
      if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
        
        # read in current file 
        current_df_data <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = T, show_col_types = T)
        
      } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
        
        # read in current file
        current_df_data <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = T, show_col_types = T)
      }
      
      # add new data to full list
      all_loaded_data[[current_df_metadata_file_path_absolute]] <- current_df_data
      
    } # end of looping through metadata df
    
  } else { # otherwise use the flmd to begin to pull in header info and then prompt the user to gather the rest of the info
    
    ### FLMD present? ############################################################
    
    # if the flmd is present... 
    
    if (is.data.frame(flmd_df)) {
      
      # if yes...
      
      # does flmd_df have required cols?
      flmd_required_cols <- c("File_Name", "Column_or_Row_Name_Position", "File_Path")
      
      if (!all(flmd_required_cols %in% names(flmd_df))) {
        
        # if the flmd is missing required cols, error
        log_error(paste0("flmd_df is missing required column: ", setdiff(flmd_required_cols, names(flmd_df))))
        stop("Function terminating.")
      } # end of checking flmd required cols
      
      log_info("Matching up flmd with files in directory.")
      
      # clean up flmd by fixing file path and selecting only certain cols
      current_flmd_df <- flmd_df %>%
        mutate(File_Path_Absolute = paste0(current_directory, File_Path, "/", File_Name)) %>%
        mutate(Header_Rows = as.numeric(Header_Rows),
               Column_or_Row_Name_Position = as.numeric(Column_or_Row_Name_Position)) %>% 
        select(File_Name, Header_Position = Column_or_Row_Name_Position, File_Path_Absolute)
      
      # check for difference between the dir and flmd
      files_not_in_flmd <- setdiff(files_df$all, current_flmd_df$File_Path_Absolute)
      files_not_in_dir <- setdiff(current_flmd_df$File_Path_Absolute, files_df$all)
      
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
      
    } # end of if flmd_df exists
    
    ### Get header_position for any remaining files ##############################
    
    log_info("Asking for remaining header position info.")
    
    # getting files that don't have a header_position
    current_df_metadata_missing_header_position <- current_df_metadata %>% 
      filter(str_detect(File_Name, "\\.tsv$|\\.csv$")) %>% # filter for only .csv and .tsv files
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
          current_tabular_file <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = file_n_max)
          
        } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
          
          # read in current file
          current_tabular_file <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = file_n_max)
          
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
      
    } # end of getting rest of header info
    # you should now have Header_Position for all files
    
    ### Ask for start data for each file #########################################
    
    log_info("Asking for the row the data start on for all files. Note: If a file has no header rows, then the value should be 2.")
    
    # function to ask for start data row info
    ask_user_input_data_start_row <- function() {
      
      # ask for row that the data starts on
      user_input_data_start_row <- readline(prompt = "What line does the data start on? ")
      user_input_data_start_row <- as.numeric(user_input_data_start_row)
      
      return(user_input_data_start_row)
    }
    
    # get only tabular data
    current_tabular_only_metadata <- current_df_metadata %>% 
      filter(str_detect(File_Name, "\\.tsv$|\\.csv$")) # filter for only .csv and .tsv files
    
    for (j in 1:nrow(current_tabular_only_metadata)) {
      
      # get current file path
      current_df_metadata_file_path_absolute <- current_tabular_only_metadata$File_Path_Absolute[j]
      
      if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
        
        # read in current file (does NOT include comment = "#" and does NOT read in col headers)
        current_tabular_file <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, n_max = file_n_max)
        
      } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
        
        # read in current file (does NOT include comment = "#" and does NOT read in col headers)
        current_tabular_file <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, n_max = file_n_max)
        
      }
      
      log_info(paste0("Viewing tabular file ", j, " of ", nrow(current_tabular_only_metadata), ": ", basename(current_df_metadata_file_path_absolute)))
      
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
      
      
    } # end of asking for data start row info
    
    ### Use data inputs to read in data ##########################################
    
    log_info("Reading in all data based on previous inputs and preparing to return final list.")
    
    # initialize empty list to store the data
    all_loaded_data <- list()
    
    # update tabular_only_metadata
    current_tabular_only_metadata <- current_df_metadata %>% 
      filter(str_detect(File_Name, "\\.tsv$|\\.csv$")) # filter for only .csv and .tsv files
    
    # for each row in the df_metadata...
    for (k in 1:nrow(current_tabular_only_metadata)) {
      
      # get k row
      current_df_k_row <- current_tabular_only_metadata[k, ]
      
      # name the df the absolute file path
      current_df_metadata_file_path_absolute <- current_tabular_only_metadata$File_Path_Absolute[k]
      
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
    
  } # end of query_header_info != T
  
  
  
  # return all data
  output <- list(inputs = list(directory = current_directory,
                               files_df = files_df,
                               flmd_df = flmd_df),
                 outputs = list(header_row_info = current_df_metadata,
                                filtered_file_paths = files_df$all),
                 tabular_data = all_loaded_data)
  
  log_info("load_tabular_data_from_flmd complete.")
  return(output)
  
}
  
  
  
