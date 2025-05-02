### create_flmd.R ##############################################################
# Date Created: 2024-06-14
# Date Updated: 2025-04-29
# Author: Bibi Powers-McCormack


### FUNCTION ###################################################################

create_flmd <- function(directory, 
                        dp_keyword, 
                        add_placeholders = T, 
                        exclude_files = NA_character_, 
                        include_files = NA_character_, 
                        include_dot_files = F, 
                        query_header_info = T,
                        file_n_max = 100) {
  
  
  ### About the function #######################################################
  # Objective:
    # Create an flmd with the following columns: 
      # File_Name, File_Description, Standard, Header_Rows, Column_or_Row_Name_Position, File_Path
  
  # Inputs: 
    # directory = string of the absolute folder file path. Required argument. 
    # add_placeholders = T/F where the user should select T if they want placeholder rows for the flmd, readme, and dd if those files are missing. Optional argument; default is TRUE.
    # exclude_files = vector of files (relative file path + file name) to exclude from within the dir. Optional argument; default is NA. 
    # include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA. 
    # include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE. 
    # query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Select F is on NERSC. Optional argument; default is TRUE.  
    # file_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 100 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 100. 
    
  # Outputs: 
    # flmd df with the columns: "File_Name", "File_Description", "Standard", "Header_Rows", "Column_or_Row_Name_Position", "File_Path"
  
  # Assumptions: 
    # Counts skip all rows that begin with a #
    # If column_or_row_name_position in the correct place, the value is 1
    # If there are no header_rows, the value is 0
    # If there are tabular data and user decides to not populate header row info, then those cells populate with ""
    # Any non-tabular data gets -9999 for header_rows and column_or_row_name_position
    # Tabular data is data where the file extension is .csv or .tsv
    # Tabular data is a single data matrix
    # Tabular data files are organized with column headers (not row headers)
    # Tabular data can have header rows above and/or below the column headers
    # exclude_files and include_files only take relative file paths and require the file name; directories are not allowed
    # Boye files have a ".csv" file extension
    # If add_placeholders = T, only adds respective placeholders if "readme", "flmd.csv", or "dd.csv" aren't already located in the data package
  
  # Status: In progress. Refactoring and testing, also awaiting confirmation about formatting from ESS-DIVE
    # Brie informally reviewed on 2024-06-24 (see issue #17)
    # Bibi updated the script on 2025-03-25 and it will need to go through review again. 
  
    # TASKS
      # redefine inputs (remove add_columns)
      # redefine outputs (remove Missing_Value_Codes)
      # create example data
      # write tests for current script
      # refactor
      # add ability to add header info based on boye and goldman files
  
      # update examples
      # update header documentation
      # update log_info text about inputs
      # add notes about how header row calculations are done
  
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
  
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse) # cuz duh
  library(rlog) # for logging documentation
  library(fs) # for getting file extension
  
  log_info("This function takes 8 arguments: 
            - directory (required)
            - dp_keyword (required)
            - add_placeholders (required; default = T)
            - exclude_files (optional; default = NA)
            - include_files (optional; default = NA)
            - file_n_max (optional; default = 100)
            - include_dot_files (optional; default = F)
            - query_header_info (optoinal; default = T)
           
           It returns a FLMD with the following column headers: 
           -  File_Name, File_Description, Standard, Header_Rows, Column_or_Row_Name_Position, File_Path
  Open the function to see argument definitions, function assumptions, and examples.")
  
  ### Validate Inputs ##########################################################
  
  
  
  ### List Files ###############################################################
  
  # get parent directory
  current_parent_directory <- sub(".*/", "/", directory)
  
  # get all file paths
  log_info("Getting file paths from directory.")
  file_paths_all <- list.files(directory, recursive = T, full.names = T, all.files = include_dot_files)
  current_file_paths <- file_paths_all
  
  # remove excluded files
  if (any(!is.na(exclude_files))) {
    
    current_file_paths <- file_paths_all[!file_paths_all %in% file.path(directory, exclude_files)]
    
  }
  
  # filter to only keep included files
  if (any(!is.na(include_files))) {
    
    current_file_paths <- file_paths_all[file_paths_all %in% file.path(directory, include_files)]
    
  }
  
  
  log_info(paste0("Adding ", length(current_file_paths), " of the ", length(file_paths_all), " files to the flmd."))
  
  
  ### add rows to flmd #########################################################
  
  # initialize df with file names and paths
  current_flmd_skeleton <- tibble(absolute_path = current_file_paths) %>% 
    mutate(File_Name = basename(absolute_path),
           File_Path = paste0(current_parent_directory, "/", fs::path_rel(absolute_path, start = directory)),
           File_Path = str_remove(File_Path, paste0("/", File_Name)),
           File_Description = NA_character_)
  
  
  ### add columns as indicated by user argument ################################
  
  #### header rows and column or row position ----
  # check if there are tabular files and query_header_info = T
  count_csv_files <- sum(str_detect(current_file_paths, "\\.csv$"))
  count_tsv_files <- sum(str_detect(current_file_paths, "\\.tsv$"))
  
  if (count_csv_files > 0 || count_tsv_files > 0) {
    
    log_info(paste0("There are ", count_csv_files, " csv file(s) and ", count_tsv_files, " tsv file(s)."))
    
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
    
    # if user indicated to go through header info, then proceed to ask for header info
    if (query_header_info == T) {
      
      current_flmd_skeleton <- current_flmd_skeleton %>% 
        # add -9999 to non-tabular
        mutate(Header_Rows = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                       T ~ ""),
               Column_or_Row_Name_Position = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                                       T ~ "")) %>% 
        
        # add new (temporary) column
        mutate(header_format = NA_real_)
      
      # filter for tabular data
      tabular_files <- current_flmd_skeleton %>% 
        filter(str_detect(File_Name, "\\.csv$|\\.tsv$")) %>% 
        pull(absolute_path)
      
      # loop through tabular files
      for (i in 1:length(tabular_files)) {
        
        # get current file path
        current_file_absolute <- tabular_files[i]
        
        if (str_detect(current_file_absolute, "\\.csv$")) {
          
          # read in current file
          current_tabular_file <- read_csv(current_file_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = file_n_max)
          
        } else if (str_detect(current_file_absolute, "\\.tsv$")) {
          
          # read in current file
          current_tabular_file <- read_tsv(current_file_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = file_n_max)
          
        }
        
        log_info(paste0("Viewing tabular file ", i, " of ", length(tabular_files), ": ", basename(current_file_absolute)))
        
        # show file
        View(current_tabular_file)
        
        # ask what type of header format
        user_reply <- as.numeric(readline(prompt = cat("What type of header info is present? 0 = none; 1 = Boye; 2 = Goldman; 3 = other")))
        
        if (user_reply == 3) {
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
      
          # add to flmd
          current_flmd_skeleton$Header_Rows[current_flmd_skeleton$absolute_path == current_file_absolute] <- current_header_row
          current_flmd_skeleton$Column_or_Row_Name_Position[current_flmd_skeleton$absolute_path == current_file_absolute] <- current_column_or_row_name_position
          
        } # end of user_reply == 3
        
        if (user_reply == 1) {
          
          # extract header row info from boye file
          boye_row_info <- read_csv(current_file_absolute, name_repair = "minimal", comment = "#", col_names = F, show_col_types = F, n_max = 2) %>% 
            slice(2) %>% 
            pull(2)
          
          # add to flmd
          current_flmd_skeleton$Header_Rows[current_flmd_skeleton$absolute_path == current_file_absolute] <- boye_row_info
          
          
        }
        
        # update header row type
        current_flmd_skeleton$header_format[current_flmd_skeleton$absolute_path == current_file_absolute] <- user_reply
        
      }
      
      current_flmd_skeleton %>% 
        mutate(Header_Rows = case_when(header_format == 0 ~ "1", # no header rows
                                       header_format == 2 ~ "1", # goldman
                                       T ~ Header_Rows)) %>% 
        mutate(Column_or_Row_Name_Position = case_when(header_format == 0 ~ "1", # no header rows
                                                       header_format == 1 ~ "1", # boye
                                                       header_format == 2 ~ "1", # goldman
                                                       T ~ Column_or_Row_Name_Position))
      # update boye files
      
      
      # update goldman files
      
      
      # update files without header info
      
      
    } else {
      
      log_info("Header_Rows and Column_or_Row_Name_Position are not being calculated. 
  Tabular files will be left empty and all other files will be automatically populated with '-9999'.")
      
      current_flmd_skeleton <- current_flmd_skeleton %>% 
        mutate(Header_Rows = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                       T ~ ""),
               Column_or_Row_Name_Position = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                                       T ~ ""))
    }
    
  }
  
  
  #### add standard ----
    
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      mutate(Standard = case_when(str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "ESS-DIVE CSV v1", # update the standard with the CSV reporting format (https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/RF_FLMD_Standard_Terms.csv)
                                  T ~ "N/A"))
  
  #### add placeholder readme, flmd, dd rows if indicated ######################
  
  if (add_placeholders == TRUE) {
    log_info("Checking for presence of flmd, dd, and readme files.")
    
    # check for presence of dd and flmd files
    flmd_file_present <- any(str_detect(current_file_paths, "flmd.csv"))
    dd_file_present <- any(str_detect(current_file_paths, "dd.csv"))
    readme_file_present <- any(str_detect(current_file_paths, "readme"))
    
    if (readme_file_present == FALSE) {
      log_info("Adding placeholder row for readme.")
      current_flmd_skeleton <- current_flmd_skeleton %>%
        add_row(
          "File_Name" = paste0("readme_", dp_keyword, ".pdf"),
          "File_Description" = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          "Standard" = "N/A",
          "Header_Rows" = "-9999",
          "Column_or_Row_Name_Position" = "-9999",
          "File_Path" = current_parent_directory
        )
    }
    
    if (flmd_file_present == FALSE) {
      log_info("Adding placeholder row for FLMD.")
      current_flmd_skeleton <- current_flmd_skeleton %>%
        add_row(
          "File_Name" = paste0(dp_keyword, "_flmd.csv"),
          "File_Description" = "File-level metadata that lists and describes all of the files contained in the data package.",
          "Standard" = "ESS-DIVE FLMD v1; ESS-DIVE CSV v1",
          "Header_Rows" = "0",
          "Column_or_Row_Name_Position" = "1",
          "File_Path" = current_parent_directory
        )
    }
    
    if (dd_file_present == FALSE) {
      log_info("Adding placeholder row for DD.")
      current_flmd_skeleton <- current_flmd_skeleton %>%
        add_row(
          "File_Name" = paste0(dp_keyword, "_dd.csv"),
          "File_Description" = 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
          "Standard" = "ESS-DIVE FLMD v1; ESS-DIVE CSV v1",
          "Header_Rows" = "0",
          "Column_or_Row_Name_Position" = "1",
          "File_Path" = current_parent_directory
        )
    }
  }
  
  
  
  ### sort flmd ################################################################
  
  # select the columns indicated by user
  current_flmd_skeleton <- current_flmd_skeleton %>% 
    select(File_Name, File_Description, Standard, Header_Rows, Column_or_Row_Name_Position, File_Path)
  
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
