### create_dd.R ################################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-07
# Date Updates: 2025-05-14


### FUNCTION: create_dd() ######################################################

create_dd <- function(files_df, 
                      flmd_df = NA, 
                      add_boye_headers = F, 
                      add_flmd_dd_headers = F,
                      include_filenames = F) {
  
  
  ### About the function #######################################################
  # Objective:
    # Create a dd with the following columns: 
      # Column_or_Row_Name, Unit, Definition, Data_Type, Missing_Value_Code
  
  # Inputs: 
    # files_df = df with at least these 5 cols: all, absolute_dir, parent_dir, relative_dir, and file. Required argument. 
    # flmd_df = df with at least these 3 cols: File_Name, Column_or_Row_Name_Position, File_Path. Optional argument; default is NA. 
    # add_boye_headers = T/F where the user should select T if they want placeholder rows for Boye header rows. Optional argument; default is FALSE.
    # add_flmd_dd_headers = T/F where the user should select T if they want placeholder rows for FLMD and DD column headers. Optional argument; default is FALSE. 
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
      # validate inputs
    
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
  
  # does files_df have required cols?
  files_required_cols <- c("absolute_dir", "parent_dir", "relative_dir", "file")
  
  if (!all(files_required_cols %in% names(files_df))) {
    
    # if files_df is missing required cols, error
    log_error(paste0("files_df is missing required column: ", setdiff(files_required_cols, names(files_df))))
    stop("Function terminating.")
  } # end of checking files required cols
  
  # are add_boye_headers, add_flmd_dd_headers, and include_filenames logical?
  if (!is.logical(add_boye_headers) || length(add_boye_headers) != 1) {
    log_error("add_boye_headers must be a single logical value (TRUE or FALSE)")
    stop("Function terminating.")
  }
  
  if (!is.logical(add_flmd_dd_headers) || length(add_flmd_dd_headers) != 1) {
    log_error("add_flmd_dd_headers must be a single logical value (TRUE or FALSE)")
    stop("Function terminating.")
  }
  
  if (!is.logical(include_filenames) || length(include_filenames) != 1) {
    log_error("include_filenames must be a single logical value (TRUE or FALSE)")
    stop("Function terminating.")
  }
  
  # is the flmd present? 
    # this checks if the flmd is present. if it is, then it makes sure that the
    # flmd has the required cols and then checks to see if it can join to the
    # files_df. If the FLMD isn't provided (= NA) then it warns the user that it
    # will attempt to read in headers by assuming headers are on the first row
  
  if (is.data.frame(flmd_df)) {
    
    # if yes...
    
    # does flmd_df have required cols?
    flmd_required_cols <- c("File_Name", "Column_or_Row_Name_Position", "File_Path")
                            
    if (!all(flmd_required_cols %in% names(flmd_df))) {
      
      # if the flmd is missing required cols, error
      log_error(paste0("flmd_df is missing required column: ", setdiff(flmd_required_cols, names(flmd_df))))
      stop("Function terminating.")
    } # end of checking flmd required cols
    
    # are the tabular files in the flmd and files the same? 
    tabular_flmd <- flmd_df %>% 
      mutate(files_flmd_join = paste0(File_Path, "/", File_Name)) %>% 
      filter(str_detect(File_Name, "\\.csv$|\\.tsv$")) %>% # filter for only tabular files
      select(files_flmd_join, Column_or_Row_Name_Position) 
    
    tabular_files <- files_df %>% 
      filter(str_detect(file, "\\.csv$|\\.tsv$")) %>% # filter for only tabular files
      mutate(files_flmd_join = paste0(parent_dir, relative_dir, "/", file))
    
    # are the files listed in the files_df and flmd_df the same?
    are_equal <- setequal(tabular_files$files_flmd_join, tabular_flmd$files_flmd_join)
    
    if (are_equal == F) {
      
      # show the files in files_df but NOT in flmd
      log_warn("Tabular files in the FLMD, but NOT in your directory: ")
      setdiff(tabular_flmd$files_flmd_join, tabular_files$files_flmd_join) %>% 
        tibble(missing_from_directory = .) %>% 
        print()
      
      log_warn("Tabular files in your directory, but NOT in the FLMD: ")
      setdiff(tabular_files$files_flmd_join, tabular_flmd$files_flmd_join) %>% 
        tibble(missing_from_flmd = .) %>% 
        print()
      
      # if the files dirs don't match the flmd, warn user
      log_warn("There is a discrepency between your tabular files and the FLMD. Do you want to proceed?: ")
      
      user_prompt_to_proceed <- readline(prompt = "Y/N?: ")
      
      if (tolower(user_prompt_to_proceed) != "y") {
        
        stop("Function terminating.")
        
      } # end of quitting if user prompt indicates to
      
    } # end of if flmd and files equal
    
    } else { 
      
      # if no, create (fake) flmd and fill with placeholder values where header_rows = 1 and column_or_row_name_position = 1
      log_warn("An FLMD was not provided. The function assumes headers are on the first row.")
      
      tabular_files <- files_df %>% 
        filter(str_detect(file, "\\.csv$|\\.tsv$")) %>% # filter for only tabular files
        mutate(files_flmd_join = paste0(parent_dir, relative_dir, "/", file))
      
      tabular_flmd <- tabular_files %>% 
        mutate(Column_or_Row_Name_Position = 1) %>% 
        select(files_flmd_join, Column_or_Row_Name_Position) 
      
    } # end of checking flmd presence

    
  ### Join files_df with FLMD ##################################################
  
  # join
  tabular_files_with_flmd <- tabular_files %>% 
    left_join(tabular_flmd, by = "files_flmd_join")
  
  # if there are NA values in the FLMD Column_or_Header_Row_Position column, warn the user that the function will assume the headers are on the first line
  if (any(is.na(tabular_files_with_flmd$Column_or_Row_Name_Position))) {
    log_warn("Unless otherwise specified in the FLMD, header rows are assumed to be on the first row.")
    
    tabular_files_with_flmd <- tabular_files_with_flmd %>% 
      mutate(Column_or_Row_Name_Position = case_when(is.na(Column_or_Row_Name_Position) ~ 1, 
                                                     T ~ Column_or_Row_Name_Position))
  }
  
  # initalize empty column for col names
  tabular_files <- tabular_files %>% 
    mutate(Column_or_Row_Name = NA_character_)
  
  ### Extract headers based on Column_or_Row_Name_Position #####################
  
  log_info("Extracting headers from files.")
  
  tabular_files_with_flmd %>% 
    group_by(Column_or_Row_Name_Position) %>%
    summarise(files = str_c(file, collapse = ", "), .groups = "drop") %>% 
    print()
  
  for (i in 1:nrow(tabular_files_with_flmd)) {
    
    # get abs file path
    current_file_absolute <- tabular_files_with_flmd[i, ] %>% 
      mutate(abs = paste0(absolute_dir, files_flmd_join)) %>% 
      pull(abs)
    
    # get current join
    current_files_flmd_join <- tabular_files_with_flmd[i, ] %>% 
      pull(files_flmd_join)
    
    # get column header line number
    current_column_or_row_name_position <- tabular_files_with_flmd[i, ] %>% 
      pull(Column_or_Row_Name_Position)
    
    # read in file
    log_info(paste0("Getting headers from file ", i, " of ", nrow(tabular_files_with_flmd), ": ", basename(current_file_absolute)))
    
    if (str_detect(current_file_absolute, "\\.csv$")) {
      
      # read in current file
      current_tabular_file <- read_csv(current_file_absolute, col_names = F, comment = "#", n_max = current_column_or_row_name_position, show_col_types = F)
      
    } else if (str_detect(current_file_absolute, "\\.tsv$")) {
      
      # read in current file
      current_tabular_file <- read_tsv(current_file_absolute, col_names = F, comment = "#", n_max = current_column_or_row_name_position, show_col_types = F)
      
    }
    
    # get columns
    current_Column_or_Row_Names <- current_tabular_file %>% 
      slice(current_column_or_row_name_position) %>% 
      pivot_longer(everything(), values_to = "Column_or_Row_Name") %>% 
      pull(Column_or_Row_Name)
    
    # add cols to main df
    tabular_files$Column_or_Row_Name[tabular_files$files_flmd_join == current_files_flmd_join] <- list(current_Column_or_Row_Names)
    
  }
  
  ### Create DD ################################################################
  
  dd_skeleton <- tabular_files %>% 
    unnest(Column_or_Row_Name) %>% 
    select(Column_or_Row_Name, 
           associated_files = files_flmd_join) %>% 
    
    # add DD cols
    mutate(Unit = NA_character_,
           Definition = NA_character_,
           Data_Type = NA_character_,
           Missing_Value_Code = '"N/A"; "-9999"; ""; "NA"',
           header_count = 1) %>%
    select(Column_or_Row_Name, Unit, Definition, Data_Type, Missing_Value_Code, header_count, associated_files)
  
  
  ### Add boye headers #########################################################
  # adds boye headers if the user indicated it
  if (add_boye_headers == T) {
    
    # boye header rows
    boye_header_rows <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Missing_Value_Code, ~associated_files, 
                                "Unit", "N/A",	"Unit of measurement that applies to a given column or row in the data package.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "Unit_Basis", "N/A",	"Basis of the units listed in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "MethodID_Analysis", "N/A",	"Method code defining information about analysis of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "MethodID_Inspection", "N/A",	"Method code defining information about inspection of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "MethodID_Storage", "N/A",	"Method code defining information about storage of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "MethodID_Preservation", "N/A",	"Method code defining information about preservation of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "MethodID_Preparation", "N/A",	"Method code defining information about preparation of the samples that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "MethodID_DataProcessing", "N/A",	"Method code defining information about data processing that led to the data presented in the column.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "Analysis_DetectionLimit", "N/A",	"Analytical detection limit.",	"numeric", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "Analysis_Precision", "N/A",	"Precision of the data values.",	"numeric", '"N/A"; "-9999"; ""; "NA"', "boye template", 
                                "Data_Status", "N/A",	"State of data readiness for publication and use.",	"text", '"N/A"; "-9999"; ""; "NA"', "boye template")
    
    # add rows 
    dd_skeleton <- dd_skeleton %>% 
      bind_rows(boye_header_rows)
    
  }
  
  ### Add FLMD and DD headers  #################################################
  # adds FLMD and DD headers if the user indicates it
  if (add_flmd_dd_headers == T) {
    
    # flmd headers
    flmd_placeholder_entires <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Missing_Value_Code, ~associated_files, 
                                        "File_Name", "N/A", "Name of files in the data package.", "text", '"N/A"; "-9999"; ""; "NA"', "flmd template", 
                                        "File_Description", "N/A",  "A brief description of the files in the data package.", "text", '"N/A"; "-9999"; ""; "NA"', "flmd template", 
                                        "Standard", "N/A","ESS-DIVE Reporting Format (https://ess-dive.lbl.gov/data-reporting-formats/) or other standard applied to the data file.", "text", '"N/A"; "-9999"; ""; "NA"', "flmd template", 
                                        "Header_Rows", "N/A", 'The number of rows or the number of columns that occur before the start of tabular data. This count assumes the numbering begins at 1 (rather than 0), excludes columns or rows that begin with "#", and includes the column or row that the header names are on. For example, if the file has columns with variable names but does not have any other metadata header rows, then this value is 1. Most data in this data package is oriented in columns, so this field indicates the number of rows before the start of the data (e.g., If row 1 has the column headers, row 2 has the units, and row 3 has the data values, then this value would be 2 - to indicate the count of the rows prior to the data values).', "numeric", '"N/A"; "-9999"; ""; "NA"', "flmd template", 
                                        "Column_or_Row_Name_Position", "N/A", 'The location of the column or row that contains the header names (i.e., column name or row name). The count used to identify the location assumes the numbering begins at 1 (rather than 0) and excludes columns or rows that begin with "#". Most data in this data package is oriented in columns, so this field indicates the tabular location of the row that holds the column names (e.g., If row 1 has the column headers, row 2 has the units, and row 3 has the data values, then this value would be 1 - to indicate the location of the column header row).', "numeric", '"N/A"; "-9999"; ""; "NA"', "flmd template", 
                                        "File_Path", "N/A", "File path within the data package.", "text", '"N/A"; "-9999"; ""; "NA"', "flmd template")
    
    # dd headers
    dd_placeholder_entires <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Missing_Value_Code, ~associated_files, 
                                      "Column_or_Row_Name", "N/A", "Column or row headers from each tabular file (csv or tsv) in the dataset.", "text", '"N/A"; "-9999"; ""; "NA"', "dd template", 
                                      "Unit",  "N/A", "Unit of measurement that applies to a given column or row in the data package.", "text", '"N/A"; "-9999"; ""; "NA"', "dd template",
                                      "Definition", "N/A", "Description of the information in a given column or row in the dataset.definition", "text", '"N/A"; "-9999"; ""; "NA"', "dd template",
                                      "Data_Type", "N/A", "Type of data (numeric; text; date; time; datetime).", "text", '"N/A"; "-9999"; ""; "NA"', "dd template", 
                                      "Missing_Value_Code", "N/A", 'Cells with missing data are represented with a missing value code rather than an empty cell. This column describes which missing value codes were used. In most cases, the missing value code for numeric data is "-9999" and for character data is "N/A". Some files also use a missing value format specific to when a data value is below the limit of detection or above/below the standard curve. For these cases: a text string is included in the format "[data type]_*|*_Raw_Not_Corrected|*_Final_Corrected" in which the asterisks are the denoted individual data values. See the associated methods deviation (DTL_003) description for more details.', "text", '"N/A"; "-9999"; ""; "NA"', "dd template")
    
    
    # add rows
    dd_skeleton <- dd_skeleton %>% 
      bind_rows(flmd_placeholder_entires) %>% 
      bind_rows(dd_placeholder_entires)
  
  }
  
  
  ### Clean up #################################################################
  
  dd_skeleton <- dd_skeleton %>% 
  # consolidate if placeholders resulted in duplicate row entries
  group_by(Column_or_Row_Name) %>%
    summarize(
      # for columns that should have consistent values within groups, take first non-NA
      Unit = first(na.omit(Unit)),
      Definition = first(na.omit(Definition)),
      Data_Type = first(na.omit(Data_Type)),
      Missing_Value_Code = first(na.omit(Missing_Value_Code)),
      # for associated_files, concatenate with comma separator
      header_count = sum(header_count, na.rm = TRUE), 
      associated_files = paste(associated_files, collapse = ", "),
      .groups = "drop"
    ) %>%
    # if all values were NA for each column then it will return character(0), this converts it back to NA
    mutate(across(c(Unit, Definition, Data_Type, Missing_Value_Code), 
                  ~case_when(length(.) == 0 ~ NA_character_,
                             TRUE ~ .))) %>% 
    
    # alphabetize
    arrange(tolower(Column_or_Row_Name))
  
  
  # if include_filenames == F, then drop cols
  if (include_filenames == F) {
    
    dd_skeleton <- dd_skeleton %>% 
      select(Column_or_Row_Name, Unit, Definition, Data_Type, Missing_Value_Code)
    
  }
  
  
  ### return filled out skeleton ###############################################
  
  log_info("create_dd() complete.")
  return(dd_skeleton)
  
}
  