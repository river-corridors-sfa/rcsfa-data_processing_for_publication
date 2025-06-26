### create_flmd.R ##############################################################
# Date Created: 2024-06-14
# Date Updated: 2025-06-26
# Author: Bibi Powers-McCormack

# This script contains the functions for creating FLMDs. 


### FUNCITON: get_files() ######################################################

get_files <- function(directory, # required
                      exclude_files = NA_character_, 
                      include_files = NA_character_,
                      include_dot_files = F) {
  
  # Objective: Given a directory, when get_files() is run, then the function
  # will return a df with 5 columns: all, absolute_dir, parent_dir, relative_dir, and
  # file
  
  # Inputs: 
    # directory = string of the absolute folder file path; do not include "/" at end. Required argument. 
    # exclude_files = vector of files (relative file path + file name) to exclude from within the dir. Optional argument; default is NA. 
    # include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA. 
    # include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE.  
  
  # Outputs: 
    # df with 5 columns: 
      # all = the full absolute path to the file, including the file name
      # absolute_dir = the absolute path above the parent_dir
      # parent_dir = the lowest-level directory shared by all files (the last dir specified in the directory the user specified)
      # relative_dir = the path to the file relative to the directory the user specified
      # file = the name of the file, without any directory path
      
  # Assumptions: 
    # exclude_files and include_files only take relative file paths and require the file name; directories are not allowed.
    # if you use both include and exclude options, only the files listed in include will be kept; the exclude list will be ignored.
  
  # Status: complete. 
    # Code authored by Bibi Powers-McCormack. Reviewed and approved by Brie Forbes on 2025-06-09 via https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/pull/61
  
  # Examples: 
  
  # 1) example that includes all files in a given directory
    # my_files <- get_files(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory")
      # output of my_files <- tibble(all = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory/folderA/file.csv", 
      #                              absolute_dir = "C:/Users/powe419/OneDrive - PNNL/Desktop",
      #                              parent_dir = "/Demo_Directory",
      #                              relative_dir = "/folderA",
      #                              file = "file.csv")

  # 2) example that excludes a single file in an archive folder
    # my_files <- get_files(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory", 
    #                       exclude_files = "archive/archived_file.csv")

  # 3) example that excludes multiple files from an archive folder
    # my_directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory"
    # archived_files <- list.files(path = paste0(my_directory, "/archive"), recursive = T, full.names = T) %>% # use list.files() to gather the (relative) names of all archived files
    #                   str_remove(., paste0(my_directory, "/"))
    # my_files <- get_files(directory = my_directory,
    #                       exclude_files = archived_files)
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse) # cuz duh
  library(rlog) # for logging documentation
  library(fs) # for getting file extension
  
  ### List Files ###############################################################
  
  # get parent directory
  current_parent_directory <- paste0("/", basename(directory))
  
  # get all file paths
  log_info("Getting file paths from directory.")
  file_paths_all <- list.files(directory, recursive = T, full.names = T, all.files = include_dot_files)
  current_file_paths <- file_paths_all
  
  # if a user specifies both include and exclude, then only the include list will be used; exclusions will be ignored
  
  # filter to only keep included files
  if (any(!is.na(include_files))) {
    
    current_file_paths <- file_paths_all[file_paths_all %in% file.path(directory, include_files)]
    
    log_warn(paste0("Including only the ", length(current_file_paths), " file(s) listed in the `include_files` input."))
    
  } else if (any(!is.na(exclude_files))) {
    # if include_files was NA, but exclude files is present, then remove excluded files
    
    current_file_paths <- file_paths_all[!file_paths_all %in% file.path(directory, exclude_files)]
    
    log_warn(paste0("Excluding ", length(file_paths_all) - length(current_file_paths), " file(s)."))
    
  }
  
  log_info(paste0("Excluding ", length(file_paths_all) - length(current_file_paths), " of ", length(file_paths_all), " total file(s) in the directory."))
  
  ### Add Files ################################################################
  
  # add all files to df
  files <- tibble(all = current_file_paths) %>% 
    mutate(absolute_dir = str_remove(directory, paste0("/", basename(directory))), # this is everything in the abs dir before the parent_dir
           parent_dir = current_parent_directory, # this is the last dir in the directory
           relative_dir = str_remove(dirname(all), directory), # any dirs after (relative to) the directory
           file = basename(all)) # the name of the file
  
  ### Return df ################################################################
  log_info("get_files() function complete.")
  return(files)
  
}



### FUNCTION ###################################################################

create_flmd <- function(files_df, # required
                        dp_keyword = "data_package", 
                        add_placeholders = F, 
                        query_header_info = F,
                        view_n_max = 20) {
  
  
  ### About the function #######################################################
  
  # Objective: Given files_df (a df with 4 columns: all, absolute_dir, parent_dir,
  # relative_dir, file), when create_flmd() is run, then the function will
  # return an FLMD with the cols: File_Name, File_Description, Standard,
  # Header_Rows, Column_or_Row_Name_Position, File_Path. It will do its best to
  # populate as many values as it can.
  
  # Inputs: 
    # files_df = df with at least these 5 cols: all, absolute_dir, parent_dir, relative_dir, and file. Required argument. 
    # dp_keyword = string of the data package name; this will be used to name the placeholder flmd, dd, readme files. Optional argument; default is "data_package".
    # add_placeholders = T/F where the user should select T if they want placeholder rows for the flmd, readme, and dd if those files are missing. Optional argument; default is FALSE.
    # query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Header rows that start with "#" can be considered as not having header rows. Optional argument; default is FALSE.  
    # view_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 20 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 20. 
    
  # Outputs: 
    # flmd df with the columns: "File_Name", "File_Description", "Standard", "Header_Rows", "Column_or_Row_Name_Position", "File_Path"
  
  # Assumptions: 
    # Counts skip all rows that begin with a # - doing this because ESS-DIVE told us that's how the fusion DB reads in files
    # If column_or_row_name_position in the correct place (i.e., there are no header rows), the value is 1 - calculations based on https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/flmd_quick_guide.md#column-or-row-name-position
    # If there are no header_rows, the value is 1 - calculations based on https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/flmd_quick_guide.md#header-rows
    # If there are tabular data and user decides to not populate header row info, then those cells populate with NA - leaving blank so the user knows to populate
    # Any non-tabular data gets -9999 for header_rows and column_or_row_name_position to follow missing value code formatting guidelines
    # Tabular data is data where the file extension is .csv or .tsv
    # Tabular data is a single data matrix
    # Tabular data files are organized with column headers (not row headers)
    # Tabular data can have header rows above and/or below the column headers
    # Boye files have a ".csv" file extension
    # If add_placeholders = T, only adds respective placeholders if "readme", "flmd.csv", or "dd.csv" aren't already located in the data package - warning: this will exclude the readme if another readme (e.g., workflow_readme.pdf) is present
    # Adds Standard based on CSV reporting format keywords (https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/RF_FLMD_Standard_Terms.csv)
    # Also adds boye standard to files ending in "Methods_Codes.csv"
    # Also adds goldman standard to files ending in "InstallationMethods.csv"
    # Hard codes in placeholder rows - edit code below if descriptions or other values change
  
  # Status: Complete.
    # Brie informally reviewed on 2024-06-24 (see issue #17)
    # Bibi updated the script on 2025-03-25 and it will need to go through review again. 
    # Bibi refactored and updated the script on 2025-05-16. Reviewed and approved by Brie Forbes on 2025-06-09 via https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/pull/61
  
  # Examples: 
  
  # 1) example that includes all files in a given directory in your flmd, adds an flmd, dd, and readme placeholders, and uses a prompting window to ask the user for header row info
    # my_flmd <- create_flmd(files_df = get_files(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory"), 
    #                        dp_keyword = "example_data_package", add_placeholders = T, query_header_info = T)
  
  # 2) example that does the same as example 1 but formatted differently
    # my_files <- get_files(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory")
    # my_flmd <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", add_placeholders = T, query_header_info = T)
  
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse) # cuz duh
  library(rlog) # for logging documentation
  library(fs) # for getting file extension
  library(crayon) # for colored comments
  
  ### Validate Inputs ##########################################################
  
  # does files_df have required cols?
  files_required_cols <- c("all", "absolute_dir", "parent_dir", "relative_dir", "file")
  
  if (!all(files_required_cols %in% names(files_df))) {
    
    # if files_df is missing required cols, error
    log_error(paste0("files_df is missing required column: ", setdiff(files_required_cols, names(files_df))))
    stop("Function terminating.")
  } # end of checking files required cols
  
  
  # are add_placeholders and query_header_info logical?
  if (!is.logical(add_placeholders) || length(add_placeholders) != 1) {
    log_error("add_placeholders must be a single logical value (TRUE or FALSE)")
    stop("Function terminating.")
  }
  
  if (!is.logical(query_header_info) || length(query_header_info) != 1) {
    log_error("query_header_info must be a single logical value (TRUE or FALSE)")
    stop("Function terminating.")
  }
  
  ### add rows to flmd #########################################################
  
  # get parent directory
  current_parent_directory <- files_df %>% 
    distinct(parent_dir) %>% 
    pull()
  
  log_info(paste0("Adding ", nrow(files_df), " files to the flmd."))
  
  # initialize df with file names and paths
  current_flmd_skeleton <- files_df %>% 
    mutate(File_Name = file,
           File_Path = paste0(parent_dir, relative_dir),
           File_Description = NA_character_, 
           Standard = NA_character_,
           header_format = NA_character_) %>% # temporary column
    select(File_Name, File_Description, Standard, File_Path, header_format, all)
    
  ### add columns as indicated by user argument ################################
  
  #### header rows and column or row position ----
  # check if there are tabular files and query_header_info = T
  count_csv_files <- sum(str_detect(files_df$file, "\\.csv$"))
  count_tsv_files <- sum(str_detect(files_df$file, "\\.tsv$"))
  
  if (count_csv_files > 0 || count_tsv_files > 0) {
    
    log_info(paste0("There are ", count_csv_files, " csv file(s) and ", count_tsv_files, " tsv file(s)."))
    
    # function to ask for header row info
    ask_user_input <- function() {
      
      # ask if there is more than just the data matrix present
      user_input_has_header_rows <- readline(prompt = "Are header rows present (either above or below the column headers)? (Y/N) ")
      
      if (tolower(user_input_has_header_rows) == "y") {
        
        # ask location of column header
        user_input_column_or_row_name_position <- readline(prompt = "What line has the column headers? (Enter 1 if in the correct place) ")
        current_column_or_row_name_position <- as.numeric(user_input_column_or_row_name_position)
        
        # ask location of first data row
        user_input_first_data_row <- as.numeric(readline(prompt = "What line has the first row of data? "))
        
        # calculate header_row
        current_header_row <- user_input_first_data_row - 1
        
        user_inputs <- list(current_column_or_row_name_position = current_column_or_row_name_position, current_header_row = current_header_row)
        
        
      } else {
        
        # if there is only a single data matrix/data doesn't have header rows, then col header is in row 1 and data headers = 1
        user_inputs <- list(current_column_or_row_name_position = 1, current_header_row = 1)
        
      }
      
      return(user_inputs)
    } # end of ask_user_input function
    
    # if user indicated to go through header info, then proceed to ask for header info
    if (query_header_info == T) {
      
      current_flmd_skeleton <- current_flmd_skeleton %>% 
        # add -9999 to non-tabular
        mutate(Header_Rows = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                       T ~ ""),
               Column_or_Row_Name_Position = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                                       T ~ ""))
      
      # filter for tabular data
      tabular_files <- current_flmd_skeleton %>% 
        filter(str_detect(File_Name, "\\.csv$|\\.tsv$"))
      
      # loop through tabular files
      for (i in 1:nrow(tabular_files)) {
        
        # get current file path
        current_file_absolute <- tabular_files$all[i]
        
        # display file name
        log_info(paste0("Tabular file ", i, " of ", nrow(tabular_files), ": "))
        
        tabular_files[i, ] %>%
          mutate(relative_file = paste0(File_Path, "/", File_Name)) %>%
          pull(relative_file) %>%
          magenta() %>%
          cat() %>%
          cat("\n")
        
        # ask what type of header format
        user_reply <- readline(prompt = cat("Which standard best describes the header structure in this file?\n", blue("n"), "= none;", blue("b"), "= Boye;", blue("g"), "= Goldman;", blue("o"), "= other;", blue("u"), "= unknown"))
        
        while (!user_reply %in% c("n", "b", "g", "o", "u")) {
          # if the user reply isn't part of the controlled vocab, ask again
          
          log_warn("Asking for user input again because previous input included an invalid value.")
          user_reply <- readline(prompt = cat("Which standard best describes the header structure in this file?\n", blue("n"), "= none;", blue("b"), "= Boye;", blue("g"), "= Goldman;", blue("o"), "= other;", blue("u"), "= unknown"))
          
        }
        
        # update header row type
        current_flmd_skeleton$header_format[current_flmd_skeleton$all == current_file_absolute] <- user_reply
        
        # update header_rows and column_or_row_name position based on header_format
        current_flmd_skeleton <- current_flmd_skeleton %>% 
          mutate(Header_Rows = case_when(header_format == "n" ~ "1", # no header rows
                                         header_format == "g" ~ "1", # goldman
                                         T ~ Header_Rows)) %>% # user input
          mutate(Column_or_Row_Name_Position = case_when(header_format == "n" ~ "1", # no header rows
                                                         header_format == "b" ~ "1", # boye
                                                         header_format == "g" ~ "1", # goldman
                                                         T ~ Column_or_Row_Name_Position)) # user input
        
        # if boye, use the file to get the Header_Row value
        if (user_reply == "b") {
          
          # extract header row info from boye file
          boye_row_info <- read_csv(current_file_absolute, name_repair = "minimal", col_names = F, show_col_types = F, n_max = 2) %>% 
            slice(2) %>% 
            pull(2)
          
          # add to flmd
          current_flmd_skeleton <- current_flmd_skeleton %>% 
            mutate(Header_Rows = case_when(all == current_file_absolute ~ as.character(boye_row_info),
                                           T ~ Header_Rows))
          
        } # end of user_reply = boye
        
        # if other or unknown, display file
        if (user_reply == "o" || user_reply == "u") {
          
          # read in current file
          if (str_detect(current_file_absolute, "\\.csv$")) {
            
            # read in csv
            current_tabular_file <- read_csv(current_file_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = view_n_max, col_names = F)
            
          } else if (str_detect(current_file_absolute, "\\.tsv$")) {
            
            # read in tsv
            current_tabular_file <- read_tsv(current_file_absolute, name_repair = "minimal", comment = "#", show_col_types = F, n_max = view_n_max, col_names = F)
            
          }
          
          # show file
          current_tabular_file %>%
            print(n = as.numeric(view_n_max))
          
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
          
          # ask the user if a standard should be applied to this file
          user_reply_standard <- readline(prompt = cat("Which standard best describes this file?\n", blue("n"), "= none;", blue("b"), "= Boye;", blue("g"), "= Goldman;", blue("o"), "= other"))
          
          # update standards to be capital - doing this so these rows are captured in standard col (below) but not overwritten (on next loop iteration) when the case_when recalculates header rows
          if(user_reply_standard == "n"){
            user_reply_standard <- "N"
          } else if (user_reply_standard == "b") {
            user_reply_standard <- "B"
          } else if (user_reply_standard == "g") {
            user_reply_standard <- "G"
          }
          
          # add to flmd
          current_flmd_skeleton <- current_flmd_skeleton %>% 
            mutate(header_format = case_when(all == current_file_absolute ~ as.character(user_reply_standard), 
                                             T ~ header_format),
                   Header_Rows = case_when(all == current_file_absolute ~ as.character(current_header_row), 
                                           T ~ Header_Rows),
                   Column_or_Row_Name_Position = case_when(all == current_file_absolute ~ as.character(current_column_or_row_name_position),
                                                           T ~ Column_or_Row_Name_Position))
          
        } # end of user_reply == other or unknown
        
      } # end of loop through tabular files

    } else { # if query_header_info != T
      
      log_warn("
  Header_Rows and Column_or_Row_Name_Position are not being calculated. 
  Tabular files will be populated with NA and all other files will be automatically populated with '-9999'.
  
  Boye and Goldman Standards are not being added. If applicable, they will need to be manually added to the FLMD by the user.")
      
      current_flmd_skeleton <- current_flmd_skeleton %>% 
        mutate(Header_Rows = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                       T ~ NA),
               Column_or_Row_Name_Position = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                                       T ~ NA))
    } # end of query_header_info != T
    
  } # end of if tabular files exist
  
  else {
    
    current_flmd_skeleton <- current_flmd_skeleton %>% 
      mutate(Header_Rows = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                     T ~ NA),
             Column_or_Row_Name_Position = case_when(!str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "-9999", 
                                                     T ~ NA))
    
  } # end of if tabular files do NOT exist
  
  
  
  ### add placeholder readme, flmd, dd rows if indicated #######################
  
  if (add_placeholders == TRUE) {
    log_info("Checking for presence of flmd, dd, and readme files.")
    
    # check for presence of dd and flmd files
    flmd_file_present <- any(str_detect(current_flmd_skeleton$File_Name, "flmd\\.csv$"))
    dd_file_present <- any(str_detect(current_flmd_skeleton$File_Name, "dd\\.csv$"))
    readme_file_present <- any(str_detect(current_flmd_skeleton$File_Name, "readme"))
    
    if (readme_file_present == FALSE) {
      log_info("Adding placeholder row for readme.")
      current_flmd_skeleton <- current_flmd_skeleton %>%
        add_row(
          "File_Name" = paste0("readme_", dp_keyword, ".pdf"),
          "File_Description" = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          "Standard" = NA_character_, # standard updated below
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
          "Standard" = NA_character_, # standard updated below
          "Header_Rows" = "1",
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
          "Standard" = NA_character_, # standard updated below
          "Header_Rows" = "1",
          "Column_or_Row_Name_Position" = "1",
          "File_Path" = current_parent_directory
        )
    }
  }
  
  ### add standard #############################################################
  # update the standard based on CSV reporting format keywords (https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/RF_FLMD_Standard_Terms.csv)
    
  current_flmd_skeleton <- current_flmd_skeleton %>%
    mutate(Standard = case_when(tolower(header_format) == "b" ~ "ESS-DIVE Water-Soil-Sediment Chem v1; ESS-DIVE CSV v1", # boye rf
                                tolower(header_format) == "g" ~ "ESS-DIVE Hydrologic Monitoring v1; ESS-DIVE CSV v1", # goldman rf
                                str_detect(File_Name, "Methods_Codes\\.csv$") ~ "ESS-DIVE Water-Soil-Sediment Chem v1; ESS-DIVE CSV v1", # boye rf
                                str_detect(File_Name, "Installation_Methods\\.csv$") ~ "ESS-DIVE Hydrologic Monitoring v1; ESS-DIVE CSV v1", # goldman rf
                                str_detect(File_Name, "flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # flmd rf
                                str_detect(File_Name, "dd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # flmd rf
                                str_detect(File_Name, "IGSN_Mapping\\.csv$") ~ "ESS-DIVE Sample v1; ESS-DIVE CSV v1", # sample rf 
                                str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "ESS-DIVE CSV v1", # csv rf
                                T ~ "N/A"))
  
  
  ### sort flmd ################################################################
  
  # fix class type
  current_flmd_skeleton <- current_flmd_skeleton %>% 
    mutate(Header_Rows = as.numeric(Header_Rows)) %>% 
    mutate(Column_or_Row_Name_Position = as.numeric(Column_or_Row_Name_Position)) %>% 
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
  
  log_info("create_flmd() complete.")
  return(current_flmd_skeleton)
  
}
