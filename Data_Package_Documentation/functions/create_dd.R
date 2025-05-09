### create_dd.R ################################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-07
# Date Updates: 2025-05-07

### FUNCITON: get_files() ######################################################

get_files <- function(directory, # required
                      exclude_files = NA_character_, 
                      include_files = NA_character_,
                      include_dot_files = F) {
  
  # Given a directory, when get_files() is run, then the function will return a
  # df with 4 columns: absolute_dir, parent_dir, relative_dir, and file
  
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
  
  log_info(paste0("Adding ", length(current_file_paths), " of ", length(file_paths_all), " files."))
  
  ### Add Files ################################################################
  
  # add all files to df
  files <- tibble(all = current_file_paths) %>% 
    mutate(absolute_dir = str_remove(all, str_c(current_parent_directory, ".*$")),
           parent_dir = current_parent_directory,
           relative_dir = str_remove(dirname(all), absolute_dir) %>% 
             str_remove(paste0("^", parent_dir)),
           file = basename(all)) %>% 
    select(-all)
  
  ### Return df ################################################################
  log_info("get_files() complete.")
  return(files)
  
}


### FUNCTION: create_dd() ######################################################

create_dd <- function(files_df, # required df with 4 cols: absolute_dir, parent_dir, relative_dir, and file
                      flmd = NA, 
                      add_boye_headers = F, 
                      include_filenames = F) {
  
  
  ### About the function #######################################################
  # Objective:
    # Create a dd with the following columns: 
      # Column_or_Row_Name, Unit, Definition, Data_Type, Missing_Value_Code
  
  # Inputs: 
    # files_df = df with 4 cols: absolute_dir, parent_dir, relative_dir, and file
    # add_boye_headers = T/F where the user should select T if they want placeholder rows for Boye header rows. Optional argument; default is FALSE.
    # include_filenames = T/F to indicate whether you want to include the file name(s) the headers came from. Optional argument; default is F. 
  
  # Outputs: 
    # dd df with the columns: "Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Missing_Value_Code"
      # additional optional cols (if include_filenames = T): header_count, associated_files
  
  # Assumptions: 
    # Counts skip all rows that begin with a #
    # If column_or_row_name_position in the correct place (i.e., there are no header rows), the value is 1
    # If there are no header_rows, the value is 1
    # Tabular data is data where the file extension is .csv or .tsv
    # Tabular data files are organized with column headers (not row headers)
    # Tabular data can have header rows above and/or below the column headers
    # exclude_files and include_files only take relative file paths and require the file name; directories are not allowed
    # Boye files have a ".csv" file extension
    
  # Status: In progress.  
  
  # TASKS
    # write tests for current script
    # write MVP
    # refactor
    
    # update examples
    # update header documentation
    # update log_info text about inputs
    # add notes about how header row calculations are done
    
  # Examples
  
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse) # cuz duh
  library(rlog) # for logging documentation
  library(fs) # for getting file extension
  
  ### Validate Inputs ##########################################################
  
  
  
  
  ### 
  
  current_dd_skeleton <- tibble(Column_or_Row_Name = as.character(),
                                Unit = as.character(), 
                                Definition = as.character(), 
                                Data_Type = as.character(), 
                                Missing_Value_Code = as.character())
  
  # adds boye headers if the user indicated it
  if (add_boye_headers == T) {
    
    # boye header rows
    boye_header_rows <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Missing_Value_Code,
            "Unit", "N/A",	"Unit of measurement that applies to a given column or row in the data package.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "Unit_Basis", "N/A",	"Basis of the units listed in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "MethodID_Analysis", "N/A",	"Method code defining information about analysis of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "MethodID_Inspection", "N/A",	"Method code defining information about inspection of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "MethodID_Storage", "N/A",	"Method code defining information about storage of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "MethodID_Preservation", "N/A",	"Method code defining information about preservation of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "MethodID_Preparation", "N/A",	"Method code defining information about preparation of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "MethodID_DataProcessing", "N/A",	"Method code defining information about data processing that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"',
            "Analysis_DetectionLimit", "N/A",	"Analytical detection limit.",	"numeric", '"N/A"; "-9999"; ""; "NA"',
            "Analysis_Precision", "N/A",	"Precision of the data values.",	"numeric", '"N/A"; "-9999"; ""; "NA"',
            "Data_Status", "N/A",	"State of data readiness for publication and use.",	"text", '"N/A"; "-9999"; ""; "NA"',)
    
    current_dd_skeleton <- current_dd_skeleton %>% 
      add_row(boye_header_rows)
    
    }
  
  
  ### return filled out skeleton ###############################################
  
  log_info("create_dd() complete.")
  return(current_dd_skeleton)
  
  
  
  
}
  