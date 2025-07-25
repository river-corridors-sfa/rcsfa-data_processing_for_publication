### load_tabular_data.R ########################################################
# Date Created: 2024-04-19
# Date Updated: 2025-06-20
# Author: Bibi Powers-McCormack

### load_tabular_data_file function ############################################

load_tabular_data <- function(files_df, 
                              query_header_info = F,
                              flmd_df = NA, 
                              file_n_max = 100){
  
  ### About the function #######################################################
  # Objective: Read in tabular data using the flmd to get file paths and header row info
  
  # Inputs: 
    # files_df = df with at least these 5 cols: all, absolute_dir, parent_dir, relative_dir, and file. Required argument. 
    # query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Select F if on NERSC. Optional argument; default is FALSE.  
    # flmd_df = df with at least these 3 cols: File_Name, Column_or_Row_Name_Position, File_Path. Include this if you have it and query_header_info = T. Optional argument; default is NA. 
    # file_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 100 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 100. 
    
  # Outputs: 
    # a hierarchical list(inputs, outputs, tabular_data): 
    # inputs = a list that includes the input to this function
      # input$directory = the directory extracted from files_df
      # input$files_df = the output from the `get_files()` function 
      # input$flmd_df = the output from the `get_flmd()` function 
    # outputs = a list
      # outputs$header_row_info = a df that lists out each file, the row the column headers are on, and the row the data start - this is what's used to read in the data
      # outputs$filtered_file_paths = a vector of absolute file paths from files_df
    # tabular_data = a list of all the tabular data read in as data frames
  
  # Assumptions: 
    # data will be pulled based on files_df (not the files listed in flmd_df)
    # only data with .csv or .tsv file extensions will be read in
    # the tabular data is a single data matrix
    # the data are organized with column headers (not row headers)
    # data files can have header rows above and/or below the column headers
    # if the user selects `query_header_info = F`, then data will be read in skipping any rows that begin with "#" and then assuming column headers are on the first row and data begin on the second row. 
    # rows containing "#End_Data" will be skipped.
  
  # Status: complete. 
    # Code authored by Bibi Powers-McCormack. Reviewed and approved by Brie Forbes on 2025-06-09 via https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/pull/61
      # v2 refactored this function to more efficiently work with the FLMD and DD.
    # Code updated by Bibi Powers-McCormack. Reviewed and approved by Brie Forbes on 2025-06-19 via https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/pull/68
      # v2.1 added a feature that allows the user to read in data without having
      # to indicate the row data start on for every file. When the user argument
      # query_header_info = F, then load_tabular_data() reads in all files where
      # it treats the column headers as being on the first row and the data
      # starting on the second row. read_csv ignores rows that begin with "#"
      # and it doesn't ask the user for the row the data start on.
  
  ### Load dependencies ########################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(fs)
  
  ### Validate Inputs ##########################################################
  
  # get parent directory
  parent_directory <- files_df %>% 
    distinct(parent_dir) %>% 
    pull()
  
  # get current abs directory
  abs_directory <- files_df %>% 
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
  
  
  ### Prep script ##############################################################
  
  # initialize empty list to store the data
  all_loaded_data <- list()
  
  # filter for only tabular files
  tabular_metadata <- files_df %>% 
    filter(str_detect(file, "\\.tsv$|\\.csv$")) 
  
  log_info(paste0("Planning to load ", nrow(tabular_metadata), " tabular files."))
  
  
  ### query_header_info = F ####################################################
  
  # If the user indicates that there are no header rows, then read in the data
  # with read_csv() like normal. Ignores any rows that begin with "#", and then
  # assumes that column headers are on the first row and the data begin on the
  # second row.
  
  if (query_header_info == F) {
    
    # for each row in the tabular_metadata...
    for (f in 1:nrow(tabular_metadata)) {
      
      # name the df the absolute file path
      current_df_metadata_file_path_absolute <- tabular_metadata$all[f]
      
      log_info(paste0("Loading in file ", f, " of ", nrow(tabular_metadata), ": ", basename(current_df_metadata_file_path_absolute)))
      
      if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
        
        # read in current file (includes comment = "#" and assumes col headers on first row)
        current_df_data <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = T, show_col_types = F, comment = "#")
        
      } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
        
        # read in current file (includes comment = "#" and assumes col headers on first row)
        current_df_data <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = T, show_col_types = F, comment = "#")
      }
      
      # add new data to full list
      all_loaded_data[[current_df_metadata_file_path_absolute]] <- current_df_data
      
    } # end of loop that reads in each tabular file
    
  } # end of query_header_info == F
  
  
  ### query_header_info = T ####################################################
  
  # This portion of the script handles quirks in the Boye reporting format where
  # rows starting with "#" are dropped, which can cause the first row of real
  # data to be missed. It uses the FLMD (if available) to find the column header
  # row and asks the user for the data start row. Part 1 builds a mapping of
  # file names to their header and data row positions. Part 2 reads in the
  # header and data rows separately for each file and stores the result in a
  # list.
  
  # Once the Boye reporting format is updated, this can likely be simplified by
  # using the FLMD fields directly to load data, and not have to ask the user
  # for the row the data start on.
  
  #### Part 1: construct the metadata table ----
  # Each file (a row in the df) needs the row the column headers are on and the
  # row the data start.
  
  else if (query_header_info == T) {
    
    # get tabular files
    tabular_metadata <- tabular_metadata %>% 
      mutate("Header_Position" = NA_real_,
             "Data_Start_Row" = NA_real_)
    
    
    #### get row location of col headers ----
    # first attempt to get as much info from the FLMD (if the user provided it)
    if (is.data.frame(flmd_df)) {
      
      # if flmd is present...
      
      # does flmd_df have required cols?
      flmd_required_cols <- c("File_Name", "Column_or_Row_Name_Position", "File_Path")
      
      if (!all(flmd_required_cols %in% names(flmd_df))) {
        
        # if the flmd is missing required cols, error
        log_error(paste0("flmd_df is missing required column: ", setdiff(flmd_required_cols, names(flmd_df))))
        stop("Function terminating.")
      } # end of checking flmd required cols
      
      log_info("Matching up flmd with files in directory.")
      
      # clean up flmd by fixing file path and selecting only certain cols and only tabular files
      flmd_info <- flmd_df %>%
        mutate(File_Path_Absolute = paste0(abs_directory, File_Path, "/", File_Name)) %>%
        mutate(Header_Rows = as.numeric(Header_Rows),
               Column_or_Row_Name_Position = as.numeric(Column_or_Row_Name_Position)) %>%
        filter(str_detect(File_Name, "\\.tsv$|\\.csv$")) %>%
        select(File_Name, Header_Position = Column_or_Row_Name_Position, File_Path_Absolute)
      
      # check for difference between the dir and flmd
      files_not_in_flmd <- setdiff(tabular_metadata$all, flmd_info$File_Path_Absolute)
      files_not_in_dir <- setdiff(flmd_info$File_Path_Absolute, tabular_metadata$all)
      
      if (length(files_not_in_flmd) > 0) {
        log_warn(paste0("The following file is in the directory but NOT in the flmd: ", basename(files_not_in_flmd)))
      }
      
      if (length(files_not_in_dir > 0 )) {
        log_warn(paste0("The following file is in the flmd but NOT in the directory: ", basename(files_not_in_dir)))
      }
      
      # join flmd to dir df
      tabular_metadata <- tabular_metadata %>%
        left_join(flmd_info, join_by(all == File_Path_Absolute)) %>%
        mutate(Header_Position = coalesce(Header_Position.x, Header_Position.y)) %>%
        select(-c("Header_Position.x", "Header_Position.y", "File_Name"))
      
    } # end of if flmd_df exists
    
    
    # then/otherwise prompt the user to gather the rest of the info
    log_info("Asking for remaining header position info.")
    
    # getting files that don't have a header_position
    current_df_metadata_missing_header_position <- tabular_metadata %>%
      filter(is.na(.$Header_Position))
    
    # if there are files that have missing header info...
    if (nrow(current_df_metadata_missing_header_position) > 0) {
      
      # function to ask for header row info
      ask_user_input_header_position <- function() {
        # ask location of column header
        user_input_column_or_row_name_position <- readline(prompt = "What line has the column headers? (Enter 0 if in the correct place) ")
        current_column_or_row_name_position <- as.numeric(user_input_column_or_row_name_position)
        
        # now increment up the column_or_row_name_position by 1 because reporting format says to use 1 if headers are in the correct position (not 0)
        current_column_or_row_name_position <- current_column_or_row_name_position + 1
        
        return(current_column_or_row_name_position)
      }
      
      # go through tabular data missing header position
      for (i in 1:nrow(current_df_metadata_missing_header_position)) {
        
        current_df_metadata_file_path_absolute <- current_df_metadata_missing_header_position$all[i]
        
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
        tabular_metadata <- tabular_metadata %>%
          mutate(Header_Position = case_when(.$all == current_df_metadata_file_path_absolute ~ current_header_position,
                                             T ~ Header_Position))
      }
      
    } # end of getting rest of header info
    # you should now have Header_Position for all files
    
  
  #### ask for start data for each file ----
  log_info("Asking for the row the data start on for all files. Note: If a file has no header rows, then the value should be 2.")
  
  # function to ask for start data row info
  ask_user_input_data_start_row <- function() {
    
    # ask for row that the data starts on
    user_input_data_start_row <- readline(prompt = "What line does the data start on? ")
    user_input_data_start_row <- as.numeric(user_input_data_start_row)
    
    return(user_input_data_start_row)
  }
  
  for (j in 1:nrow(tabular_metadata)) {
    
    # get current file path
    current_df_metadata_file_path_absolute <- tabular_metadata$all[j]
    
    if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
      
      # read in current file (does NOT include comment = "#" and does NOT read in col headers)
      current_df_metadata <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, n_max = file_n_max)
      
       
    } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
      
      # read in current file (does NOT include comment = "#" and does NOT read in col headers)
      current_df_metadata <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, n_max = file_n_max)
      
    }
    
    log_info(paste0("Viewing tabular file ", j, " of ", nrow(tabular_metadata), ": ", basename(current_df_metadata_file_path_absolute)))
    
    # show file
    View(current_df_metadata)
    
    # run function that asks for what row the data start on
    current_data_start_row <- ask_user_input_data_start_row()
    
    # quick check to confirm the user input - if either values are less than 0, rerun function because the user entered them wrong
    while(current_data_start_row < 0) {
      
      log_info("Asking for user input again because previous input included an invalid (negative) value. ")
      
      current_data_start_row <- ask_user_input_data_start_row()
      
    }
    
    # store start data row into the current_df_metadata
    tabular_metadata <- tabular_metadata %>%
      mutate(Data_Start_Row = case_when(.$all == current_df_metadata_file_path_absolute ~ current_data_start_row,
                                        T ~ Data_Start_Row))
    
  } # end of asking for data start row info
  

### Part 2: Use data inputs to read in data ##################################

    log_info("Reading in all data based on previous inputs and preparing to return final list.")
    
    # for each row in the tabular_metadata...
    for (k in 1:nrow(tabular_metadata)) {
      
      # get k row
      current_df_k_row <- tabular_metadata[k, ]
      
      # name the df the absolute file path
      current_df_metadata_file_path_absolute <- tabular_metadata$all[k]
      
      log_info(paste0("Loading in file ", k, " of ", nrow(tabular_metadata), ": ", basename(current_df_metadata_file_path_absolute)))
      
      # use the tabular_metadata to get the column headers
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
      
      # use the data start to read in data
      if (query_header_info == T) {
        # don't pull in columns and don't use comment = "#"
        if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
          
          # read in current file (does NOT include comment = "#" and does NOT read in col headers)
          current_df_data <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, skip = current_df_k_row$Data_Start_Row - 1)%>%
            filter(!str_detect(X1, '#End_Data'))
          
        } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
          
          # read in current file (does NOT include comment = "#" and does NOT read in col headers)
          current_df_data <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = F, show_col_types = F, skip = current_df_k_row$Data_Start_Row - 1)
        }
        
        
      } else if (query_header_info == F) {
        # don't pull in columns and use comment = "#"
        if (str_detect(current_df_metadata_file_path_absolute, "\\.csv$")) {
          
          # read in current file (does NOT include comment = "#" and does NOT read in col headers)
          current_df_data <- read_csv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = T, show_col_types = F, comment = "#") %>%
          {
            if ("Field_Name" %in% names(.)) {
              # If "Field_Name" exists, filter it for rows NOT containing "#End_Data"
              . <- filter(., Field_Name != "#End_Data")
            } else {
              # If "Field_Name" does not exist, return the dataset as-is
              .
            }
          }
        } else if (str_detect(current_df_metadata_file_path_absolute, "\\.tsv$")) {
          
          # read in current file (does NOT include comment = "#" and does NOT read in col headers)
          current_df_data <- read_tsv(current_df_metadata_file_path_absolute, name_repair = "minimal", col_names = T, show_col_types = F, comment = "#")
        }
        
        
      }
      
      
      # rename columns with the col headers that were already pulled
      colnames(current_df_data) <- current_df_headers
      
      # add new data to full list
      all_loaded_data[[current_df_metadata_file_path_absolute]] <- current_df_data
      
    } # end of loop that reads in each tabular file
  
  
  } # end of query_header_info == T
  

  ### Prep return ##############################################################
  
  # return all data
  output <- list(inputs = list(directory = paste0(abs_directory, parent_directory),
                               files_df = files_df,
                               flmd_df = flmd_df),
                 outputs = list(header_row_info = tabular_metadata,
                                filtered_file_paths = files_df$all),
                 tabular_data = all_loaded_data)
  
  log_info("load_tabular_data() function complete.")
  return(output)

} # end load_tabular_data() function


