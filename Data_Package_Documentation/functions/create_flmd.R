### create_flmd.R ##############################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-04-24
# Date Updated: 2025-04-29

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
                          cols_to_add = c("Definition", "Standard", "Missing_Value_Codes", "Header_Rows", "Column_or_Row_Name_Position")) { # optional
  
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
  
  # update columns #############################################################
  
  # convert col classes
  flmd_base <- flmd_base %>% 
    mutate(across(any_of(c("File_Name", "Definition", "Standard", "Missing_Value_Codes", "File_Path")), as.character)) %>% 
    mutate(across(any_of(c("Header_Rows", "Column_or_Row_Name_Position")), as.numeric))
    
  # sort cols
  flmd <- flmd_base %>% 
    select(File_Name, all_of(cols_to_add), File_Path)
  
  ### prepare return ###########################################################
  log_info("get_flmd_cols() complete.")
  return(flmd)
  
  
  
} # end get_flmd_cols()


### get_flmd_cells() function ##################################################

get_flmd_cells <- function(flmd_base, #required
                           cols_to_populate = c("Definition", "Standard", "Missing_Value_Codes", "Header_Rows", "Column_or_Row_Name_Position")) {
  
  ### About the function #######################################################
  # GWT
  
  # Inputs: 
  
  # Outputs: 
  
  # Assumptions: 
   # we are using standards based on the Nov 2024 list: https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/38fc54dbcc3c01fa6f2b57488884c88e21e67380/RF_FLMD_Standard_Terms.csv
  
  # Status: 
  
  # Examples: 
  
  
  ### Prep script ##############################################################
  library(tidyverse)
  library(rlog)
  
  ### validate inputs ##########################################################
  
  ### update cells #############################################################
  if ("Standard" %in% cols_to_populate) {
    
    log_info("Populating 'Standard' column.")
    
    # adding "ESS-DIVE FLMD v1" to flmd and dd
    # adding "ESS-DIVE CSV v1" to all csv or tsv files
    # filling in the rest with "N/A"
    flmd <- flmd_base %>% 
      mutate(Standard = case_when(str_detect(File_Name, "flmd\\.csv$") | str_detect(File_Name, "dd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1",
                                  str_detect(File_Name, "\\.csv$|\\.tsv$") ~ "ESS-DIVE CSV v1",
                                  T ~ "N/A"))
  }
  
  if ("Missing_Value_Codes" %in% cols_to_populate) {
    
    log_info("Populating 'Missing_Value_Codes' column.")
    
    flmd <- flmd %>% 
      mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.csv$|\\.tsv$") ~ '"-9999"; "N/A"; "": NA"',
                                  T ~ "N/A"))
  }
  
  if ("Header_Rows" %in% cols_to_populate || "Column_or_Row_Name_Position" %in% cols_to_populate) {
    
    log_info("Populating header info columns.")
    
    
    
    
    
    
  }
  
  
  # prepare return #############################################################
  log_info("get_flmd_cells() complete.")
  return(flmd)
  
  
}





