### create_flmd.R ##############################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-04-24
# Date Updated: 2025-04-24

# Objective

# Assumptions


### get_flmd_rows() function ###################################################

get_flmd_rows <- function(directory, # required
                          dp_keyword, # required
                          include_files = NA, # optional 
                          exclude_files = NA, # optional 
                          include_dot_files = F, # optional
                          placeholder_rows_to_add = c("readme", "flmd", "dd")) { # optional
  
  ### About the function #######################################################
  # GWT
  
  # Inputs: 
  
  # Outputs: 
  
  # Assumptions: 
    # The script first filters by include_files, then removes exclude_files, then adds placeholders.
    # Files listed in exclude_files will be removed, even if they're also included in include_files.
    # File Paths begin with "/"
  
  # Status: 
  
  # Examples: 
  
  
  ### Prep script ##############################################################
  library(tidyverse)
  library(rlog)
  
  ### validate inputs ##########################################################
  
  
  ### list files ###############################################################
  # get parent directory
  current_parent_directory <- sub(".*/", "/", directory)
  
  # get all file paths
  log_info("Getting file paths from directory.")
  file_paths_all <- list.files(directory, recursive = T, full.names = T, all.files = include_dot_files)
  current_file_paths <- file_paths_all
  
  # filter to only keep included files
  if (any(!is.na(include_files))) {
    current_file_paths <- file_paths_all[file_paths_all %in% file.path(directory, include_files)]
  }
  
  # remove excluded files
  if (any(!is.na(exclude_files))) {
    current_file_paths <- file_paths_all[!file_paths_all %in% file.path(directory, exclude_files)]
  }
  
  log_info(paste0("Adding ", length(current_file_paths), " of the ", length(file_paths_all), " files to the flmd."))
  
  
  ### add rows to flmd #########################################################
  
  # initialize df with file names and paths
  flmd_base <- tibble(absolute_path = current_file_paths) %>% 
    mutate(File_Name = basename(absolute_path),
           File_Path = paste0(current_parent_directory, "/", fs::path_rel(absolute_path, start = directory)),
           File_Path = str_remove(File_Path, paste0("/", File_Name))) %>% 
    select(File_Name, File_Path)
  
  ### sort flmd ################################################################
  
  # sort rows by readme, flmd, dd, and then by File_Path and File_Name
  flmd_base <- flmd_base %>% 
    mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = T) ~ 1,
                                  grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                  grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                  T ~ 4)) %>% 
    arrange(sort_order, File_Path, File_Name) %>% 
    select(-sort_order)
  
  ### prepare return ###########################################################
  log_info("get_flmd_rows() complete.")
  return(flmd_base)
 
                          
} # end get_flmd_rows()
  


### get_flmd_cols() function ###################################################

get_flmd_cols <- function(flmd_base, # required
                          cols_to_add = c("Definition", "Standard", "Missing_Value_Codes", "Header_Rows", "Column_or_Row_Position")) { # optional
  
  ### About the function #######################################################
  # GWT
  
  # Inputs: 
  
  # Outputs: 
  
  # Assumptions: 
  
  # Status: 
  
  # Examples: 
  
  
  ### Prep script ##############################################################
  library(tidyverse)
  library(rlog)
  
  ### validate inputs ##########################################################
  
  
  
  ### add columns to flmd ######################################################
  for (col in cols_to_add) {
    flmd_base[[col]] <- NA
  }
    
  ### sort cols ################################################################
  flmd <- flmd_base %>% 
    select(File_Name, all_of(cols_to_add), File_Path)
    
  
  ### prepare return ###########################################################
  return(flmd_base)
  
  
} # end fet_flmd_cols()






