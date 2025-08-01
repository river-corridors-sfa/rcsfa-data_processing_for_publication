### create_dd.R ################################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-07
# Date Updates: 2025-06-09


### FUNCTION: create_dd() ######################################################

create_dd <- function(files_df, 
                      flmd_df = NA, 
                      add_boye_headers = F, 
                      add_flmd_dd_headers = F,
                      include_filenames = F) {
  
  
  ### About the function #######################################################
  # Objective:
    # Create a dd with the following columns: 
      # Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, Missing_Value_Code, Reported_Precision
  
  # Inputs: 
    # files_df = df with at least these 5 cols: all, absolute_dir, parent_dir, relative_dir, and file. Required argument. 
    # flmd_df = df with at least these 3 cols: File_Name, Column_or_Row_Name_Position, File_Path. Optional argument; default is NA. 
    # add_boye_headers = T/F where the user should select T if they want placeholder rows for Boye header rows. Optional argument; default is FALSE.
    # add_flmd_dd_headers = T/F where the user should select T if they want placeholder rows for FLMD and DD column headers. Optional argument; default is FALSE. 
    # include_filenames = T/F to indicate whether you want to include the file name(s) the headers came from. Optional argument; default is F. 
  
  # Outputs: 
    # dd df with the columns: "Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type", Missing_Value_Code", Reported_Precision
      # additional optional cols (if include_filenames = T): "header_count", "associated_files"
  
  # Assumptions: 
    # Counts skip all rows that begin with a # - doing this because ESS-DIVE told us that's how the fusion DB reads in files
    # Reads in column header rows based on ESS-DIVE calculations - https://github.com/ess-dive-workspace/essdive-file-level-metadata/blob/main/flmd_quick_guide.md#column-or-row-name-position
    # Tabular data is data where the file extension is .csv or .tsv
    # Tabular data files are organized with column headers (not row headers)
    # Boye files have a ".csv" file extension
    # Hard codes in placeholder headers - edit code below if descriptions or other values change
    # Duplicate header names are automatically consolidated (in a previous version, it would ask the user to confirm before removing duplicates). Use `include_filenames = T` if you want to see the duplicates. 
    
  # Status: complete. 
    # Code authored by Bibi Powers-McCormack. Reviewed and approved by Brie Forbes on 2025-06-09 via https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/pull/61
    
  # Examples: 
  
  # 1) example that includes all headers from the files listed in my_files in your dd and also lists the files each header is associated with
    # my_files <- get_files(directory = "C:/Users/powe419/OneDrive - PNNL/Desktop/Demo_Directory")
    # my_flmd <- create_flmd(files_df = my_files, dp_keyword = "example_data_package", add_placeholders = T, query_header_info = T)
    # my_dd <- create_dd(files_df = my_files, flmd_df = my_flmd, add_boye_headers = F, add_flmd_dd_headers = F, include_filenames = T)
    
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse) # cuz duh
  library(rlog) # for logging documentation
  library(fs) # for getting file extension
  library(cli) # for warnings
  
  ### Validate Inputs ##########################################################
  
  # does files_df have required cols?
  files_required_cols <- c("all", "absolute_dir", "parent_dir", "relative_dir", "file")
  
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
    flmd_required_cols <- c("File_Name", "Column_or_Row_Name_Position", "Header_Rows", "File_Path")
                            
    if (!all(flmd_required_cols %in% names(flmd_df))) {
      
      # if the flmd is missing required cols, error
      log_error(paste0("flmd_df is missing required column: ", setdiff(flmd_required_cols, names(flmd_df))))
      stop("Function terminating.")
    } # end of checking flmd required cols
    
    # are the tabular files in the flmd and files the same? 
    tabular_flmd <- flmd_df %>% 
      mutate(files_flmd_join = paste0(File_Path, "/", File_Name)) %>% 
      filter(str_detect(File_Name, "\\.csv$|\\.tsv$")) %>% # filter for only tabular files
      select(files_flmd_join, Column_or_Row_Name_Position, Header_Rows) 
    
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
      log_warn("An FLMD was not provided. The function assumes headers are on the first row and data starts on the second row.")
      
      tabular_files <- files_df %>% 
        filter(str_detect(file, "\\.csv$|\\.tsv$")) %>% # filter for only tabular files
        mutate(files_flmd_join = paste0(parent_dir, relative_dir, "/", file))
      
      tabular_flmd <- tabular_files %>% 
        mutate(Column_or_Row_Name_Position = 1,
               Header_Rows = 1) %>% 
        select(files_flmd_join, Column_or_Row_Name_Position, Header_Rows) 
      
    } # end of checking flmd presence

    
  ### Join files_df with FLMD ##################################################
  
  # join
  tabular_files_with_flmd <- tabular_files %>% 
    left_join(tabular_flmd, by = "files_flmd_join")
  
  # if there are NA values in the FLMD Column_or_Header_Row_Position column, warn the user that the function will assume the headers are on the first line and data starts on the second row
  if (any(is.na(tabular_files_with_flmd$Column_or_Row_Name_Position))) {
    log_warn("Unless otherwise specified in the FLMD, header rows are assumed to be on the first row and data starts on second row.")
    
    tabular_files_with_flmd <- tabular_files_with_flmd %>% 
      mutate(Column_or_Row_Name_Position = case_when(is.na(Column_or_Row_Name_Position) ~ 1, 
                                                     T ~ Column_or_Row_Name_Position),
             Header_Rows = case_when(is.na(Header_Rows) ~ 1, 
                                     T ~ Header_Rows))
  }
  
  # initalize empty column for col names
  tabular_files <- tabular_files %>% 
    mutate(Column_or_Row_Name = NA_character_)
  
  #initilize data frame to get precision 
  precision_df <- tibble(Column_or_Row_Name = as.character(), 
                         precision = as.numeric(),
                         associated_files = as.character())
  
  ### Extract headers based on Column_or_Row_Name_Position #####################
  
  log_info("Extracting headers from files.")
  
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
    
    # get header row count
    current_header_rows <- tabular_files_with_flmd[i, ] %>% 
      pull(Header_Rows)
    
    # read in file
    log_info(paste0("Getting headers from file ", i, " of ", nrow(tabular_files_with_flmd), ": ", basename(current_file_absolute)))
    
    if (str_detect(current_file_absolute, "\\.csv$")) {
      
      # read in current file
        current_tabular_file <- read_csv(current_file_absolute, col_names = F, comment = "#", n_max = current_column_or_row_name_position, show_col_types = F, col_types = cols(.default = "c"))
        
      # read in full file to get precision. NOTE: this will skip first row of data since it has a hash
        current_tabular_data <- read_csv(current_file_absolute, comment = "#",  skip = current_column_or_row_name_position - 1, na = c("NA", -9999), show_col_types = F) %>%
          slice(-(1:(current_header_rows - current_column_or_row_name_position))) %>%
          mutate(across(where(~ any(grepl("Standard\\||LOD\\||Not_Corrected\\|", .x))), ~ suppressWarnings(as.numeric(.x)))) %>% # ensure sample data with text flags are read in as numeric
        type_convert(col_types = cols(.default = col_guess())) # reassess column types after reading in properly
      
    } else if (str_detect(current_file_absolute, "\\.tsv$")) {
      
      # read in current file
      current_tabular_file <- read_tsv(current_file_absolute, col_names = F, comment = "#", n_max = current_column_or_row_name_position, show_col_types = F, col_types = cols(.default = "c"))
      
      # read in full file to get precision. NOTE: this will skip first row of datasince it has a hash
      current_tabular_data <- read_tsv(current_file_absolute, comment = "#",  skip = current_column_or_row_name_position - 1, show_col_types = F) %>%
        slice(-(1:(current_header_rows - current_column_or_row_name_position))) %>%
        mutate(across(where(~ any(grepl("Standard\\||LOD\\||Not_Corrected\\|", .x))), ~ suppressWarnings(as.numeric(.x))))%>% # ensure sample data with text flags are read in as numeric
        type_convert(col_types = cols(.default = col_guess())) # reassess column types after reading in properly
      
    }
    
    if(any("Method_Description" %in% colnames(current_tabular_data))){
      # fixing issue where mutate above makes this column numeric
      
      current_tabular_data <- current_tabular_data %>%
        mutate(Method_Description = as.character(Method_Description))
      
    }
    
    if(any("Definition" %in% colnames(current_tabular_data))){
      # fixing issue where mutate above makes this column numeric
      
      current_tabular_data <- current_tabular_data %>%
        mutate(Definition = as.character(Definition))
      
    }
    
    # get columns
    current_Column_or_Row_Names <- current_tabular_file %>% 
      slice(current_column_or_row_name_position) %>% 
      pivot_longer(everything(), values_to = "Column_or_Row_Name") %>% 
      pull(Column_or_Row_Name)
    
    # add column headers to the main data frame
      # Each row in `tabular_files` represents a file, and this assigns the corresponding vector of column names (e.g., c("Sample_Name", "IGSN", "Parent_IGSN", ...)) to the `Column_or_Row_Name` column for that file
    tabular_files$Column_or_Row_Name[tabular_files$files_flmd_join == current_files_flmd_join] <- list(current_Column_or_Row_Names) # leaving this in base because tidy's case_when expects vectors, not a list. 
    
    ### Extract precision #####################
    

    # loop through columns to extract precision 
    for (column in current_Column_or_Row_Names) {
      
      current_column <- current_tabular_data %>%
        select(column) %>%
        rename(name = 1)
      
      # if column is numeric, extract precision. 
      if(identical(class(pull(current_column)), "numeric")){
        
        column_precision <- current_column %>%
          filter(!is.na(name)) %>%
          mutate(
            num_decimals = nchar(sub("^[^\\.]*\\.?", "", as.character(format(name, scientific = FALSE, trim = FALSE)))), 
            precision = 10^(-num_decimals) # Convert to precision
          )%>%
          summarise( min_precision = min(precision, na.rm = T),
                     max_precision = max(precision, na.rm = T))
        
        # if min and max precision dont match, ask the user if okay to proceed
        if(column_precision$max_precision != column_precision$min_precision){
          
          user_prompt_to_proceed_precision <- readline(prompt = cli_alert(paste0('Precision varies for ', column, '. Okay to proceed with maximum precision (',column_precision$max_precision ,'); Y/N?')))
          
          if(tolower(user_prompt_to_proceed_precision) == 'n'){ # if the user says not okay to proceed, stop the function
            
            stop('create_dd() function ended. Fix precision of data file and re-run dd function to proceed.')
            
            
          } else if(to_lower(user_prompt_to_proceed_precision) == 'y'){ # if user says its okay to proceed, report max as precision
            
            precision <- column_precision$max_precision
            
          }
          
          
          
        } else{ # if min and max precision do match, report the max as the precision 
          
          precision <- column_precision$max_precision
          
        }
        
      } else{ # if column is not numeric, precision is -9999
        
        precision <- -9999
        
      }
      
      
      precision_df <- precision_df %>%
        add_row(Column_or_Row_Name = column,
                precision = precision,
                associated_files =current_files_flmd_join)
      
      
    }
    
    
  }
  
  ### Create DD ################################################################
  
  # create the DD skeleton by unnesting the `Column_or_Row_Name` column so each column name gets its own row: tabular_files (1 row = 1 file); dd_skeleton (1 row = 1 column_or_row_name)
  dd_skeleton <- tabular_files %>% 
    unnest(Column_or_Row_Name) %>% 
    select(Column_or_Row_Name, 
           associated_files = files_flmd_join) %>% 
    
    # add DD cols
    mutate(Unit = NA_character_,
           Definition = NA_character_,
           Data_Type = NA_character_,
           Term_Type = NA_character_,
           Missing_Value_Code = '"N/A"; "-9999"; ""; "NA"',
           header_count = 1) %>%
    select(Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, Missing_Value_Code, header_count, associated_files) %>%
    
    # join with precision df
    
    left_join(precision_df %>%
                mutate(Reported_Precision = trimws(format(precision, scientific = FALSE, drop0trailing = TRUE)))%>%
                select(-precision), 
              by = c('Column_or_Row_Name', 'associated_files'))
  
  
  ### Add boye headers #########################################################
  # adds boye headers if the user indicated it
  if (add_boye_headers == T) {
    
    # boye header rows
    boye_header_rows <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Term_Type, ~Missing_Value_Code, ~associated_files, ~Reported_Precision,
                                "Unit", "N/A",	"Unit of measurement that applies to a given column or row in the data package.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template", '-9999',
                                "Unit_Basis", "N/A",	"Basis of the units listed in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "MethodID_Analysis", "N/A",	"Method code defining information about analysis of the samples that led to the data presented in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "MethodID_Inspection", "N/A",	"Method code defining information about inspection of the samples that led to the data presented in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "MethodID_Storage", "N/A",	"Method code defining information about storage of the samples that led to the data presented in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "MethodID_Preservation", "N/A",	"Method code defining information about preservation of the samples that led to the data presented in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "MethodID_Preparation", "N/A",	"Method code defining information about preparation of the samples that led to the data presented in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "MethodID_DataProcessing", "N/A",	"Method code defining information about data processing that led to the data presented in the column.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '-9999',
                                "Analysis_DetectionLimit", "N/A",	"Analytical detection limit.",	"numeric", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '0.01',
                                "Analysis_Precision", "N/A",	"Precision of the data values.",	"numeric", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template",  '0.01',
                                "Data_Status", "N/A",	"State of data readiness for publication and use.",	"text", "row_header", '"N/A"; "-9999"; ""; "NA"', "boye template" ,'-9999')
    
    # add rows 
    dd_skeleton <- dd_skeleton %>% 
      bind_rows(boye_header_rows)
    
  }
  
  ### Add FLMD and DD headers  #################################################
  # adds FLMD and DD headers if the user indicates it
  if (add_flmd_dd_headers == T) {
    
    # flmd headers
    flmd_placeholder_entires <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Term_Type, ~Missing_Value_Code, ~associated_files,  ~Reported_Precision,
                                        "File_Name", "N/A", "Name of files in the data package.", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "flmd template", '-9999',
                                        "File_Description", "N/A",  "A brief description of the files in the data package.", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "flmd template", '-9999',
                                        "Standard", "N/A","ESS-DIVE Reporting Format (https://ess-dive.lbl.gov/data-reporting-formats/) or other standard applied to the data file.", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "flmd template", '-9999',
                                        "Header_Rows", "N/A", 'The number of rows or the number of columns that occur before the start of tabular data. This count assumes the numbering begins at 1 (rather than 0), excludes columns or rows that begin with "#", and includes the column or row that the header names are on. For example, if the file has columns with variable names but does not have any other metadata header rows, then this value is 1. Most data in this data package is oriented in columns, so this field indicates the number of rows before the start of the data (e.g., If row 1 has the column headers, row 2 has the units, and row 3 has the data values, then this value would be 2 - to indicate the count of the rows prior to the data values).', "numeric", "column_header", '"N/A"; "-9999"; ""; "NA"', "flmd template",'1', 
                                        "Column_or_Row_Name_Position", "N/A", 'The location of the column or row that contains the header names (i.e., column name or row name). The count used to identify the location assumes the numbering begins at 1 (rather than 0) and excludes columns or rows that begin with "#". Most data in this data package is oriented in columns, so this field indicates the tabular location of the row that holds the column names (e.g., If row 1 has the column headers, row 2 has the units, and row 3 has the data values, then this value would be 1 - to indicate the location of the column header row).', "numeric", "column_header", '"N/A"; "-9999"; ""; "NA"', "flmd template", '1',
                                        "File_Path", "N/A", "File path within the data package.", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "flmd template",'-9999')
    
    # dd headers

    dd_placeholder_entires <- tribble(~Column_or_Row_Name, ~Unit, ~ Definition, ~Data_Type, ~Term_Type, ~Missing_Value_Code, ~associated_files,  ~Reported_Precision,
                                      "Column_or_Row_Name", "N/A", "Column or row headers from each tabular file (csv or tsv) in the dataset.", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template", '-9999',
                                      "Unit",  "N/A", "Unit of measurement that applies to a given column or row in the data package.", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template",'-9999',
                                      "Definition", "N/A", "Description of the information in a given column or row in the dataset.definition", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template",'-9999',
                                      "Data_Type", "N/A", "Type of data (numeric; text; date; time; datetime).", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template", '-9999',
                                      "Term_Type", "N/A", "Indicates how the term is used in the data package (e.g., a column_header, row_header, data_flag, or other variable).", "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template", '-9999',
                                      "Missing_Value_Code", "N/A", 'Cells with missing data are represented with a missing value code rather than an empty cell. This column describes which missing value codes were used. In most cases, the missing value code for numeric data is "-9999" and for character data is "N/A". Some files also use a missing value format specific to when a data value is below the limit of detection or above/below the standard curve. For these cases: a text string is included in the format "[data type]_*|*_Raw_Not_Corrected|*_Final_Corrected" in which the asterisks are the denoted individual data values. See the associated methods deviation (DTL_003) description for more details.', "text", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template", '-9999',
                                      "Reported_Precision", "N/A", 'Precision of the reported data values. For example, if the values are rounded to 1 decimal place, the precision would be 0.1. Similarly, if a value like 5.24 is reported (rounded to 2 decimal places), its precision would be 0.01.', "numeric", "column_header", '"N/A"; "-9999"; ""; "NA"', "dd template", '-9999')

    
    # add rows
    dd_skeleton <- dd_skeleton %>% 
      bind_rows(flmd_placeholder_entires) %>% 
      bind_rows(dd_placeholder_entires)
  
  }
  
  
  ### Clean up #################################################################
  
  # see if there are duplicate column headers with different precision 
 check_precision <-  dd_skeleton %>%
    select(Column_or_Row_Name, Reported_Precision) %>%
    group_by(Column_or_Row_Name) %>%
    filter(n_distinct(Reported_Precision) > 1)
  
  if(nrow(check_precision)>0){
    
    for (dup_column in unique(check_precision$Column_or_Row_Name)) {
      
      values <- paste(check_precision %>%
                        filter(Column_or_Row_Name == dup_column) %>% 
                        pull(Reported_Precision),
                      collapse = ", ")
      
      cli_alert_danger(paste0('Precision varies for "', dup_column, '" across files: ',values))
      

    }
    
    stop('create_dd() function ended. Fix precision of data file and re-run dd function to proceed.')
  }
  
  
  dd_skeleton <- dd_skeleton %>% 
  # consolidate if placeholders resulted in duplicate row entries
  group_by(Column_or_Row_Name) %>%
    summarize(
      # for columns that should have consistent values within groups, take first non-NA
      Unit = first(na.omit(Unit)),
      Definition = first(na.omit(Definition)),
      Data_Type = first(na.omit(Data_Type)),
      Term_Type = paste(na.omit(Term_Type), collapse = "; "),
      Missing_Value_Code = first(na.omit(Missing_Value_Code)),
      Reported_Precision = first(Reported_Precision),
      header_count = sum(header_count, na.rm = TRUE), # sum all files with given header
      associated_files = paste(associated_files, collapse = ", "), # for associated_files, concatenate with comma separator
      .groups = "drop"
    ) %>%
    # if all values were NA for each column then it will return character(0), this converts it back to NA
    mutate(Term_Type = case_when(Term_Type == "" ~ NA_character_, T ~ Term_Type)) %>% 
    mutate(across(c(Unit, Definition, Data_Type, Term_Type, Missing_Value_Code), 
                  ~case_when(length(.) == 0 ~ NA_character_,
                             TRUE ~ .))) %>% 
    # make Reported_Precision for Reported_Precisoin = -9999
    mutate(Reported_Precision = ifelse(Column_or_Row_Name == "Reported_Precision", -9999, Reported_Precision)) %>%
    # alphabetize
    arrange(tolower(Column_or_Row_Name))
  
  
  # if include_filenames == F, then drop cols
  if (include_filenames == F) {
    
    dd_skeleton <- dd_skeleton %>% 
      select(-associated_files, -header_count)
    
  }
  
  
  
  ### return filled out skeleton ###############################################
  
  log_info("create_dd() complete.")
  return(dd_skeleton)
  
}
  
