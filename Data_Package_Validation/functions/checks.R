### checks.R ###################################################################
# Date Created: 2024-06-20
# Date Updated: 2025-04-11
# Author: Bibi Powers-McCormack

# This script evaluates and then summarizes data quality checks that are
# performed on a data set. It generates a detailed output for all quality checks
# as well as a condensed summary. The goal is to provide clear insights into
# data quality issues, making it easier to identify and subsequently address
# them.

# The script contains 3 parts. Part 1 is a modular user-defined list that lets
# the user adjust common parameters. Part 2 contains the core functions
# responsible for performing data quality checks. Each function examines an
# aspect of the input data package and returns a standardized data checks df
# with the following fields: `requirement`, `pass_check`, `assessment`,
# `source`, `value`, and `file`. Part 3 runs is the final function that combines
# Part 1 and 2 to run checks at a data package level. While this entire script
# is sourced into `data_package_checks.R`, it's this only this final function
# that's actually used (with all of the Part 2 functions embedded within) in
# other scripts.

# Inputs: 
  # the main function `check_data_package()` in Part 3 requires the output from
  # the `load_tabular_data_from_flmd.R` script. See the function for input
  # details.

# Outputs: 
  # All of the functions in Part 2 have this output: 
    # requirement = indicates the type of requirement with c("required", "strongly recommended", "recommended", "optional") as options.
    # pass_check = is a logical T/F indication of whether the assessment passed or failed. 
    # assessment = describes the specific assessment that the data were evaluated against; each check function has it's own unique assessment name.
    # input = indicates the exact value (such as a file name or column header) that the assessment was evaluating.
    # value = indicates the specific content of the input that was being assessed or triggered a failure (e.g., if special chrs are being evaluated and input = "example$input", then the value will be "$").
    # source = indicates what the assessment is checking; options are c("all_file_names", "file_name", "directory_name","column_header").
    # file = provides the file that's being assessed.

  # The output of Part 3 is a list that includes the function's inputs and 3 output tables: 
    # input = a list that's the input to this function but the output to `load_tabular_data_from_flmd.R`. inputs are what was originally provided as an input to the load_tabular_data_from_flmd() function; outputs are outputs from `load_tabular_data_from_flmd()`.
      # output$input$inputs$directory = the user provided directory
      # output$input$inputs$flmd_df = the (optional) user provided flmd
      # output$input$inputs$exclude_files = a vector of files to exclude
      # output$input$inputs$include_files = a vector of files to filter for/include
      # output$input$outputs$header_row_info = a df that includes the columns c("File_Name", File_Path_Absolute", "Header_Position", "Data_Start_Row") to aid in reading in files
      # output$input$outputs$filtered_file_paths = a vector of absolute file paths to read in (fitlered if exclude or include files were provided)
      # output$input$outputs$tabular_data = a list of all the dfs read in
    # parameters = a list of the modular parameters that this check was based off of
      # output$parameters$required_file_strings = a list of file strings that are required to be in the data package
      # output$parameters$special_chrs = a vector of characters that are not allowed (regex)
      # output$parameters$no_proprietary_extensions = a vector of file extensions that are not allowed
      # output$parameters$missing_value_codes = a vector of values that indicate missing data
    # data_checks_summary = a df that summarizes the results of the data checks
    # data_checks = a df that includes a detailed output of all the data checks
    # tabular_report = a df that provides a summary of each column including data types, row-level statistics, and potential quality issues

# Status: complete
  # Reviewed by Brie Forbes on 2025-04-10


### Checks Inputs ##############################################################
# this chunk provides all the modular, although generally consistent parameters for the checks

input_parameters <- list(

  # required file strings
  required_file_strings = list(flmd = ".*flmd\\.csv$", # file that ends with flmd.csv
                                dd = ".*dd\\.csv$", # file that ends with dd.csv
                                readme = "(?i).*readme.*\\.pdf$"), # .pdf file that includes case insensitive text "readme"
  
  # no special chrs
  special_chrs = "[^a-zA-Z0-9_\\.\\-]", # anything that is NOT alphanumeric character (uppercase and lowercase), underscore, dot, or hyphen is a special chr
  
  # non proprietary file extensions (a list of the extensions that will be flagged - do not include ".")
  non_proprietary_extensions = c("docx", "doc", "xlsx", "pptx", "ppt", # microsoft extensions
                                 "m", "fig", "mat", "mlx", "p", "mdl" # matlab extensions
                                ),
  
  # missing value codes
  missing_value_codes = c("-9999", "N/A", "", "NA")
) # end of input_parameters list



### Checks Functions ###########################################################
# this chunk contains all of the checks functions

initialize_checks_df <- function() {
  # initialize empty df checks outputs
  current_data_checks <- tibble(
    requirement = factor(), 
    pass_check = logical(), 
    assessment = factor(), 
    input = character(),
    value = character(), 
    source = character(), 
    file = character()
  )
  
  return(current_data_checks)
}

check_for_required_file_strings <- function(input = all_file_names, 
                                            required_file_strings = input_parameters$required_file_strings,
                                            data_checks_table = initialize_checks_df()){
  
  # checks to see if each required file string exists in all_files vector
  # inputs: 
    # input = a vector of strings to check
    # required_file_strings = a list of regex strings to check for
    # data_checks_table = the table you want to add to
  # output: standard check df
  # assumptions: 
    # uses the strings provided in required_file_strings to check against all_file_names
    # returns TRUE when only a single file fits the regex provided in the input list;
    # returns FALSE otherwise (e.g., if no files match or if more than one file matches)
  
  # for each required string...
  for (i in seq_along(required_file_strings)) {
    
    # get current file string
    current_required_file_string <- required_file_strings[[i]]
    
    # check file name against regex string
    matches <- grepl(current_required_file_string, input, ignore.case = TRUE)
    
    if (any(matches)) {
      current_check <- TRUE
      
      file_name <- input[matches]
    } else {
      current_check <- FALSE
      
      file_name <- NA_character_
    }
    
    # update output
    data_checks_table <- data_checks_table %>% 
      add_row(
        requirement = "required", 
        pass_check = current_check, 
        assessment = "includes required files", 
        input = file_name,
        value = current_required_file_string, 
        source = "all_file_names", 
        file = file_name
    )
    
  }
  
  return(data_checks_table)
  
} # end of check_for_required_file_strings

check_for_no_special_chrs <- function(input,
                                      invalid_chrs = input_parameters$special_chrs,
                                      data_checks_table = initialize_checks_df(),
                                      source = c("file_name", "directory_name", "column_header"),
                                      file) {
  
  # checks to see if there are characters beyond what's included in the valid_chrs string
  # inputs: 
    # input = a single vectored value to check
    # invalid_chrs = a regex expression of chrs that aren't allowed
    # data_checks_table = the table you want to add to
    # source = a categorical variable choosing between "file_name", "directory_name", or "column_header"
    # file = the name of the file that's being evaluated
  # outputs: standard checks df
  # assumptions: 
    # if source is a directory, also allows "/"
    # if source is a file_name or column_header, check fails if the input is ""
  
  # confirm source input
  if (!source %in% c("file_name", "directory_name", "column_header")) {
    
    stop("`source` does not match controlled vocabulary options: file_name, directory_name, column_header")
    
  }
  
  # if source is a directory, then include "/" into allowed chrs
  if (source == "directory_name") {
    
    # take apart regex to add "/" into it
    invalid_chrs <- paste0("[", substr(invalid_chrs, 2, nchar(invalid_chrs) - 1), "\\/]")
    
  }
  
  
  # split out source by character
  split_chrs <- unlist(strsplit(input, ""))
  
  # check for special characters
  has_special_chrs <-
    sum(str_detect(split_chrs, invalid_chrs)) > 0 # the ^ turns the allowed chrs into a negated chr which matches any chr not listed within allowed_chrs
  
  # if the source is a file_name or column_name, an empty input will also fail
  if ((source %in% c("file_name", "column_header")) &&
      input == "" | is.na(input)) {
    has_special_chrs <- TRUE
    
    special_characters <- paste0(source, " is empty")
  } else  if (has_special_chrs == FALSE) {
    special_characters <- "none"
    
  } else {
    # get the special character values - this becomes a chr vector with each special chr listed out (e.g., special_characters <- c("%", "#", "&"))
    special_characters <-
      grep(invalid_chrs, split_chrs, value = TRUE)
    
    # replace space with "space"
    special_characters[special_characters == " "] <- "space"
  }
    
  
  # this adds a new row for however many special_characters there are (e.g., if an input has 2 special chrs, it will add 2 rows to data_checks_table)
  data_checks_table <- data_checks_table %>% 
    add_row(
      requirement = "strongly recommended", 
      pass_check = !has_special_chrs, 
      assessment = "no special characters", 
      input = input,
      value = special_characters, 
      source = source, 
      file = file
    )
  
  return(data_checks_table)
  
} # end of check_for_no_special_chrs

check_for_no_proprietary_files <- function(input,
                                           invalid_extensions = input_parameters$non_proprietary_extensions,
                                           data_checks_table = initialize_checks_df(),
                                           source = "file_name",
                                           file) {
  # checks to see if there are any proprietary file extensions
  # inputs: 
    # input = a single vectored value to check
    # invalid_extensions = a vector of extensions that aren't allowed
    # data_checks_table = the table you want to add to
    # source = a categorical variable, currently only set up to work with "file_name"
    # file = the name of the file that's being evaluated
  # outputs: 
    # standard checks df
  # assumptions: 
    # this check will only be run on files
  
  # check if input contains one of the invalid file extensions
  has_proprietary_file_ext <- str_detect(input, paste0("\\.", invalid_extensions, "$", collapse = "|")) # the $ ensures the ext is at the end of the file name, the | combines the extensions into a single pattern that matches any of the extensions
  
  if (has_proprietary_file_ext == FALSE) {
    file_extension <- "none"
  } else {
    file_extension <- paste0(".", tools::file_ext(input))
  }
  
  # update output
  data_checks_table <- data_checks_table %>% 
    add_row(
      requirement = "strongly recommended", 
      pass_check = !has_proprietary_file_ext, 
      assessment = "no proprietary files", 
      input = input,
      value = file_extension, 
      source = source, 
      file = file
    )
  
  return(data_checks_table)

} # end of check_for_no_proprietary_files

check_for_unique_names <- function(input, 
                                   all_names,
                                   data_checks_table = initialize_checks_df(),
                                   source = c("file_name", "column_header"),
                                   file) {
  # checks to see if the input occurs more than once in the "all_names" object
  # inputs: 
    # input = a single vectored value to check
    # all_names = a character string of the values for the input to be checked against
    # data_checks_table = the table you want to add to
    # source = a categorical variable choosing between "file_name" or "column_header"
    # file = the name of the file that's being evaluated
  # outputs: 
    # standard checks df
  # assumptions: 
    # this check will only be run on file_names or column_headers because you can't have duplicate directories
    # if the input isn't included in all_files the pass_check will result in NA
    # this output may have duplicates in it; these are removed with distinct() in the check_data_package() function
  
  # confirm source input
  if (!source %in% c("file_name", "column_header")) {
    
    stop("`source` does not match controlled vocabulary options: file_name, column_header")
    
  }
  
  # count how many times the input exists in the string
  name_count <- sum(all_names == fixed(input))
  
  name <- paste0(input, " x", name_count)
  
  if (input != "EMPTY_COLUMN_HEADER") { # if the input is "EMPTY_COLUMN_HEADER, then this check isn't applicable and it will return the original input data_checks_table
    
    if (name_count > 1) {
      # if input is listed more than once, duplicates exist
      has_duplicate_name <- TRUE
      
    } else {
      # otherwise, duplicates do NOT exist
      has_duplicate_name <- FALSE
      
    }
  
  # update output
  data_checks_table <- data_checks_table %>% 
    add_row(
      requirement = "strongly recommended", 
      pass_check = !has_duplicate_name, 
      assessment = "no duplicate names", 
      input = input,
      value = name, 
      source = source, 
      file = file
    )
  }
  
  return(data_checks_table)
  
} # end of check_for_unique_names


check_for_empty_column_headers <- function(input, 
                                           data_checks_table = initialize_checks_df(),
                                           source = "column_header", 
                                           file) {
  
  
  # checks to see if the input matches "EMPTY_COLUMN_HEADER"
  # inputs: 
    # input = a single vectored value to check
    # data_checks_table = the table you want to add to
    # source = a categorical variable, currently only set up to work with "column_header"
    # file = the name of the file that's being evaluated
  # outputs: 
   # standard checks df
  # assumptions: 
    # this check will only be run on column_headers
    # this function was made specifically to work within check_data_package() - load_tabular_data_from_flmd() keeps the original column names. However, the check_data_package() function in the "get inputs" section renames all empty column headers to "EMPTY_COLUMN_HEADER" to create a searchable identifier so this function can check it
  
  # confirm source input
  if (!source %in% c("column_header")) {
    
    stop("`source` does not match controlled vocabulary options: column_header")
    
  }
  
  # check if string matches
  if (input == "EMPTY_COLUMN_HEADER") {
    
    has_empty_column_header <-  TRUE
    
  } else{
    
    # otherwise, column isn't empty
    has_empty_column_header <- FALSE
    
  }
  
  # update output
  data_checks_table <- data_checks_table %>% 
    add_row(
      requirement = "strongly recommended", 
      pass_check = !has_empty_column_header, 
      assessment = "no empty column headers", 
      input = input,
      value = input, 
      source = source, 
      file = file
    )
  
  return(data_checks_table)
  
} # end of check_for_empty_column_headers



initialize_report_df <- function(){
  
  data_tabular_report <- tibble(
    file_name = as.character(),
    column_name = as.character(),
    column_type = as.character(),
    num_rows = as.numeric(),
    num_unique_rows = as.numeric(),
    num_missing_rows = as.numeric(),
    top_counts = as.character(),
    range_min = NA_character_,
    range_max = NA_character_,
    num_negative_rows = NA_real_)
  
  return(data_tabular_report)
  
}

create_range_report <- function(input_df, 
                                input_df_name, 
                                report_table = initialize_report_df(),
                                missing_value_codes){
  
  # input_df = data frame you want to generate the report from
  # input_df_name = the file name of the df
  # report_table = a df that includes the following cols: 
    # file_name (chr)
    # column_name (chr)
    # column_type (chr)
    # num_rows (num)
    # num_unique_rows (num)
    # num_missing_rows (num)
    # top_counts (chr)
    # range_min (chr)
    # range_max (chr)
    # num_negative_rows (num)
  # missing_value_codes = a vector of all values that you want to convert to NA
  
  # assumptions
    # currently not set up to handle factors (because those are very R specific and we're assuming data are read in from csv/tsv files)
  
  data_tabular_report <- report_table
  
  # loop through each column in the df
  for (k in seq_along(input_df)) {
    
    # get current column
    current_column <- input_df[k]
    
    # get current column name
    current_column_name <- colnames(current_column)
    
    log_info(paste0("Creating range report for column ", k, " of ", length(input_df), ": ", current_column_name))
    
    # convert to NA
    current_column <- current_column %>% 
      mutate(across(everything(), ~ replace(., . %in% missing_value_codes, NA)))
    
    # calculate number of total rows
    current_nrow <- current_column %>% 
      nrow()
    
    # calculate number of missing rows
    current_n_misisng <- current_column %>% 
      filter(is.na(current_column)) %>% 
      nrow()
    
    # calculate number of unique rows
    current_unique_rows <- current_column %>% 
      n_distinct()
    
    # calculate top counts
    current_top_counts <- current_column %>% 
      count(current_column[1], sort = T) %>% 
      drop_na() %>% 
      mutate(top_counts = paste0(!!sym(names(current_column)[1]), " (n=", n, ")")) %>% 
      head(5) %>%
      summarise(top_counts = str_c(top_counts, collapse = "  ---  ")) %>% 
      pull()
    
    # get column type
    current_column_type <- current_column %>% 
      pull(1) %>% # extracts the first col as a vector
      class() %>% # gets the class of the vector - e.g., "numeric", "character", c("POSIXct", "POSIXt")
      head(1) # because class() might return multiple classes, this grabs just the first one - e.g., class(as.POSIXct("2022-01-01")) returns c("POSIXct", "POSIXt")
    
    # set defaults
    current_min <- NA_character_
    current_max <- NA_character_
    current_n_negative <- NA_real_
    
    # if chr
    if (current_column_type == "character") {
      
      # check if col is mixed - separate out numeric vs chr rows
      current_mixed <- current_column %>% 
        
        mutate(is_numeric = case_when(str_detect(current_column[[1]], "[A-Za-z]") ~ F, T ~ T)) %>%  # flag with F values that have a letter in them
        mutate(character_col = case_when(is_numeric == FALSE ~ as.character(current_column[[1]]), T ~ NA_character_)) %>% # anything flagged with a letter is kept as is
        mutate(numeric_col = case_when(is_numeric == TRUE ~ current_column[[1]], T ~ NA_character_)) %>% # bring over numeric values
        mutate(numeric_col = as.numeric(numeric_col)) %>%  # convert numeric col to numeric
        select(-is_numeric)
        
      is_mixed <- current_mixed %>% 
        filter(!is.na(numeric_col)) %>% 
        nrow(.) > 0
      
      if (is_mixed == TRUE) {
        current_column_type <- "mixed"
      }
      
    } # end of if chr
    
    
    # if mixed
    if (current_column_type == "mixed") { 
      
      # calculate min
      current_min <- current_mixed$numeric_col %>% 
        min(na.rm = T)
      
      # calculate max
      current_max <- current_mixed$numeric_col %>% 
        max(na.rm = T)
      
      # if there are negative values, see how many rows
      if (current_min < 0) {
        
        # calculate number of rows with a negative value
        current_n_negative <- current_mixed %>% 
          select(numeric_col) %>% 
          filter(numeric_col < 0) %>% 
          count() %>% 
          pull()
      } else {
        current_n_negative <- 0
      }
      
    } # end of if mixed
    
    # if numeric
    if (current_column_type == "numeric") {
      
      # calculate min
      current_min <- current_column %>% 
        pull(1) %>% 
        min(na.rm = T)
      
      # calculate max
      current_max <- current_column %>% 
        pull(1) %>% 
        max(na.rm = T)
      
      # if there are negative values, see how many rows
      if (current_min < 0) {
        
        # calculate number of rows with a negative value
        current_n_negative <- current_column %>% 
          pull(1) %>% 
          {sum(. < 0, na.rm = T)}
        
      } else {
        current_n_negative <- 0
      }
      
    } # end of if numeric
    
    # if date
    if (current_column_type == "Date") {
      
      current_min <- current_column %>% 
        pull(1) %>% 
        min(na.rm = T)
      
      current_max <- current_column %>% 
        pull(1) %>% 
        max(na.rm = T)
      
    } # end of if date
    
    # if time
    if (current_column_type == "hms") {
      
      current_min <- current_column %>% 
        pull(1) %>% 
        as.POSIXct(format = "%Y-%m-%d %H:%M:%S", tz = "UTC") %>% 
        min(na.rm = T) %>% 
        as_hms()
      
      current_max <- current_column %>% 
        pull(1) %>% 
        as.POSIXct(format = "%Y-%m-%d %H:%M:%S", tz = "UTC") %>% 
        max(na.rm = T) %>% 
        as_hms()
      
    } # end of if time
    
    # if datetime
    if (current_column_type == "POSIXct") {
      
      current_min <- current_column %>% 
        pull(1) %>% 
        min(na.rm = T)
      
      current_max <- current_column %>% 
        pull(1) %>% 
        max(na.rm = T)
      
    } # end of if datetime
    
    if (current_column_type == "logical") {
      
      # if logical, currently do nothing
      
    }
    
    
    # create summary tibble
    current_data_report <- tibble(
      file_name = input_df_name,
      column_name = current_column_name,
      column_type = current_column_type,
      num_rows = current_nrow,
      num_unique_rows = current_unique_rows,
      num_missing_rows = current_n_misisng,
      top_counts = current_top_counts,
      range_min = as.character(current_min),
      range_max = as.character(current_max),
      num_negative_rows = current_n_negative
    )
    
    # add current row to existing summary
    data_tabular_report <- data_tabular_report %>% 
      add_row(current_data_report)
    
  } # end of loop through current_df columns
  
  return(data_tabular_report)
  
} # end `create_range_report` function

### Function to run checks ####################################################
# this chunk combines all of the above checks to evaluate an entire DP

check_data_package <- function(data_package_data, input_parameters = input_parameters) {

  # This function runs all the checks functions for a given data package. 
  
  # It requires the following checks functions:
    # check_for_no_proprietary_files()
    # check_for_no_special_chrs()
    # check_for_required_file_strings()
    # check_for_unique_names()
    # check_for_empty_column_headers()
    # create_range_report()
  
  # It requires the following util functions: 
    # initialize_checks_df()
    # initialize_report_df()
  
  # inputs
    # input_parameters list
      # list(required_file_strings = list(flmd = "", 
      #                                   dd = "",
      #                                   readme = ""), 
      #     special_chrs = "",
      #     no_proprietary_extensions = c(""),
      #     missing_value_codes = c(""))
  
    # data_package_data list
      # list(inputs = list(directory = "",                 -> the inputs provided in the load_tabular_data_from_flmd() function
      #                    flmd_df = df(),
      #                   exclude_files = c(""),
      #                   include_files = c("")),
      #      outputs = list(header_row_info = df(),        -> the outputs from the load_tabular_data_from_flmd() function
      #                     filtered_file_paths = c(""),
      #      tabular_data = list())                        -> all of the data loaded in as dfs
    
  # outputs
    # data_package_checks list
      # list(input = data_package_data,         -> this is the data package provided as input
      #      parameters = input_parameters,     -> this is the list of parameters provided as input that the checks rely on
      #      data_checks_summary = tibble(),    -> this is the summarized results
      #      data_checks = tibble(),            -> this is the complete raw list of all the checks
      #      tabular_report = tibble())         -> this is the tabular range reports
    
  ### Prepare the data to be checked ##########################################
  # initialize empty df for summary list of all checks
  data_checks_summary <- initialize_checks_df()

  # initialize empty df for full list of all checks
  data_checks_output <- initialize_checks_df()

  # initialize empty df for tabular data report
  data_tabular_report <- initialize_report_df()

  # get all file paths and file names
  all_files_absolute <- data_package_data$outputs$filtered_file_paths

  all_file_names <- basename(all_files_absolute)

  # check for making sure specific files are included (e.g., flmd, dd, readme)
  data_checks_output <- check_for_required_file_strings(input = all_file_names, 
                                                        required_file_strings = input_parameters$required_file_strings,
                                                        data_checks_table = data_checks_output)



  ### Loop through and run checks on each file ###################################
  # this chunk loops through every file and conducts file and column header level checks
    

  for (i in 1:length(all_files_absolute)) {
    
    #### get inputs ##############################################################
    # get current absolute file path
    current_file_name_absoulte <- data_package_data$outputs$filtered_file_paths[i]
    
    # get current relative file path
    current_file_name_relative <- current_file_name_absoulte %>% 
      str_remove(pattern = data_package_data$inputs$directory) # get relative file path by stripping absolute file path off
    
    # get file name
    current_file_name <- basename(current_file_name_absoulte)
    
    # get relative folder name
    current_folder_path_relative <- dirname(current_file_name_absoulte) %>% 
      str_remove(pattern = data_package_data$inputs$directory) # get relative file path by stripping absolute file path off

    # if tabular data, get col headers and df
    if (str_detect(current_file_name, "\\.csv$|\\.tsv$")){
      
      current_is_tabular <- TRUE

      # get dataframe
      current_df <- data_package_data$tabular_data[[current_file_name_absoulte]]
      
      # update empty col names so the checks and range reports can run
      if (any(is.na(colnames(current_df)))) {
        
        # find indices of unnamed cols
        empty_col_indices <- which(is.na(colnames(current_df)))
        
        # Rename the unnamed columns - this renames any empty cols "EMPTY_COLUMN_HEADER". Originally I wasn't sure if it would allow duplicates, so I wrote the commented out code that uses an index to name it. Leaving it here in case it's needed in the future
        # colnames(current_df)[empty_col_indices] <- paste0("unnamed_col_", seq_along(empty_col_indices))
        colnames(current_df)[empty_col_indices] <- "EMPTY_COLUMN_HEADER"
        
      }
      
      # get col headers
      current_headers <- colnames(current_df)
      
    } else {
      current_is_tabular <- FALSE
    }
    
    log_info(paste0("Running data checks on file ", i, " of ", length(data_package_data$outputs$filtered_file_paths), ": ", current_file_name))
    
    ### Run checks on folders ####################################################
    # this chunk then checks all folder paths
    
    # check for special characters in folder names
    data_checks_output <- check_for_no_special_chrs(input = current_folder_path_relative,
                                                    invalid_chrs = input_parameters$special_chrs,
                                                    data_checks_table = data_checks_output,
                                                    source = "directory_name",
                                                    file = current_folder_path_relative)
    
    ### run checks on files ######################################################
    
    # check for special characters in file names
    data_checks_output <- check_for_no_special_chrs(input = current_file_name,
                                                  invalid_chrs = input_parameters$special_chrs,
                                                  data_checks_table = data_checks_output,
                                                  source = "file_name",
                                                  file = current_file_name)
    
    # check for non-proprietary file extensions
    data_checks_output <- check_for_no_proprietary_files(input = current_file_name,
                                                          invalid_extensions = input_parameters$non_proprietary_extensions,
                                                          data_checks_table = data_checks_output,
                                                          source = "file_name",
                                                          file = current_file_name)
    
    
    ### run checks on tabular data ###############################################
    
    if (current_is_tabular == TRUE) {
      
      
      for (j in 1:length(current_headers)) {
        
        # get current header
        current_header <- current_headers[j]
        
        log_info(paste0("Running data checks on column header: ", current_header))
        
        # check for special characters in column headers
        data_checks_output <- check_for_no_special_chrs(input = current_header,
                                                        invalid_chrs = input_parameters$special_chrs,
                                                        data_checks_table = data_checks_output,
                                                        source = "column_header",
                                                        file = current_file_name)
        
        # check for unique headers - this check will flag is a header is included more than once
        data_checks_output <- check_for_unique_names(input = current_header, 
                                                    all_names = current_headers, 
                                                    data_checks_table = data_checks_output, 
                                                    source = "column_header", 
                                                    file = current_file_name)
        
        # check for empty column headers
        data_checks_output <- check_for_empty_column_headers(input = current_header,
                                                             data_checks_table = data_checks_output,
                                                             source = "column_header",
                                                             file = current_file_name)
        
      }
      
      
    ### run range reports ########################################################
      
    data_tabular_report <- create_range_report(input_df = current_df,
                                              input_df_name = current_file_name_relative, 
                                              report_table = data_tabular_report, 
                                              missing_value_codes = input_parameters$missing_value_codes)
      
    } # end of loop through all tabular files
    
  } # end of loop through all files

  ### Summarize Checks ###########################################################
  # this chunk generates a summary file of all the checks

  # clean up checks table
  data_checks_output <- data_checks_output %>% 
    distinct()

  # create summary
  data_checks_summary <- data_checks_output %>% 
    mutate(file = case_when(assessment == "includes required files" ~ value, # add value into file for this check so it's able to count files correctly
                            T ~ file)) %>% 
    group_by(requirement, pass_check, assessment, source) %>% 
    summarise(values = str_c(unique(value), collapse = ", "),
              file_count = length(unique(file)),
              files = str_c(unique(file), collapse = ", ")) %>% 
    ungroup() %>% 
    mutate(requirement = factor(requirement, levels = c("required", "strongly recommended", "recommended", "optional"), ordered = TRUE),
          source = factor(source, levels = c("all_file_names", "directory_name", "file_name", "column_header"), ordered = TRUE)) %>%
    arrange(requirement, pass_check, source, .locale = "en")


  ### Return Output ##############################################################
  # this chunk cleans up the script and prepares the list to return

  output <- list(input = data_package_data, # this is the data package provided as input
                parameters = input_parameters, # this is the list of parameters the functions used
                data_checks_summary = data_checks_summary,  # this is the summarized results, ready for graphing
                data_checks = data_checks_output, # this is the complete raw list of all checks
                tabular_report = data_tabular_report) # this is the tabular range reports

  log_info("check_data_package() complete.")
  return(output)



}

