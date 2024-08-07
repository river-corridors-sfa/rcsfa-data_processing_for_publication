### checks.R ###################################################################
# Date Created: 2024-06-20
# Date Updated: 2024-08-07
# Author: Bibi Powers-McCormack

# Objective: 
  # functions to run checks on a given data package

# Inputs: 
  # all functions require the output from the load_tabular_data_from_flmd.R script

# Outputs: 

# Assumptions: 

# Status: in progress


### TEST SPACE #################################################################
test_directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/ECA_Data_Package/EC_Data_Package"
  
test_flmd <- 

test_data <- load_tabular_data_from_flmd(directory = test_directory,
                                         flmd_df = test_flmd)
# column headers

test_dd <- map(test_data, colnames) %>% 
  enframe(name = "file_path", value = "header") %>% 
  unnest(header) %>% 
  mutate(file = basename(file_path)) %>% 
  group_by(header) %>% 
  summarise(header_count = n(),
            files = toString(file)) %>% 
  ungroup() %>% 
  arrange(header, .locale = "en")

View(test_dd)  


tribble(
  ~requirement, ~pass_check, ~assessment, ~value, ~source, ~file_count, ~files,
  "required", "PASSED", "no_special_chr", NA, "file_name", 3, "file1.csv, file2.csv, file3.csv",
  "required", "FAILED", "no_special_chr", "$", "file_name", 1, "file4.csv",
  "recommended", "FAILED", "no_proprietary_ext", ".docx", "file_name", 1, "file5.docx  "
) %>% 
  skimr::skim()


### Checks Inputs ##############################################################
# this chunk provides all the modular, although generally consistent parameters for the checks

input_parameters <- list(

  # required file strings
  required_file_strings = list(flmd = ".*flmd\\.csv$", # file that ends with flmd.csv
                                dd = ".*dd\\.csv$", # file that ends with dd.csv
                                readme = "^readme.*\\.pdf$"), # .pdf file that begins with readme
  
  # no special chrs
  special_chrs = "[^a-zA-Z0-9_\\.\\-]", # anything that is NOT alphanumeric character (uppercase and lowercase), underscore, dot, or hyphen is a special chr
  
  # non proprietary file extensions (a list of the extensions that will be flagged)
  non_proprietary_extensions = c()
  
)



### Checks Functions ###########################################################
# this chunk contains all of the checks functions

initialize_tabular_report <- function() {
  # initialize empty df for tabular report
  current_tabular_report <- tibble(
    file_name = character(),
    file_name_absolute = character(),
    row = numeric(),
    column_header = character(),
    column_structure = factor(levels = c("character", "factor", "numeric", "logical", "Date", "POSIXct")),
    value = character()
  )
  
  return(current_tabular_report)
  
}

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
  
}

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
    # if a directory, also allows "/"
  
  # if source is a directory, then include "/" into allowed chrs
  if (source == "directory_name") {
    
    # take apart regex to add "/" into it
    invalid_chrs <- paste0("[", substr(invalid_chrs, 2, nchar(invalid_chrs) - 1), "\\/]")
    
  }
  
  # split out source by character
  split_chrs <- unlist(strsplit(input, ""))
  
  # check for special characters
  has_special_chrs <- length(grep(invalid_chrs, split_chrs)) > 0 # the ^ turns the allowed chrs into a negated chr which matches any chr not listed within allowed_chrs
  
  if (has_special_chrs == FALSE) {
    special_characters <- "none"
  } else {
    
    # get the special character values
    special_characters <- grep(invalid_chrs, split_chrs, value = TRUE)
    
    # replace space with "space"
    special_characters[special_characters == " "] <- "space"
  }
  
  # update output
  
  # update "file" parameter based on source input
  if (source == "file_name"){
    file <- input
  } else if (source == "directory_name") {
    file <- NA_character_
  } 
  
  data_checks_table <- data_checks_table %>% 
    add_row(
      requirement = "recommended*", 
      pass_check = !has_special_chrs, 
      assessment = "no special characters", 
      input = input,
      value = special_characters, 
      source = source, 
      file = file
    )
  
  return(data_checks_table)
  
}


### Run Checks #################################################################
# this chunk prepares the data to be checked

# initialize empty df for summary list of all checks
data_checks_summary <- tibble(
  requirement = factor(), 
  pass_check = logical(), 
  assessment = factor(), 
  value = character(), 
  source = character(), 
  file_count = numeric(),
  files = character()
)

# initialize empty df for full list of all checks
data_checks_output <- initialize_checks_df()

# get all file paths and file names
all_files_absolute = data_package_data$outputs$filtered_file_paths

all_file_names = basename(all_files_absolute)

### Run checks on all files ####################################################
# this chunk first checks the entire DP for any checks

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
                                                  file = NA_character_)
  
  ### run checks on files ######################################################
  
  # check for special characters in file names
  data_checks_output <- check_for_no_special_chrs(input = current_file_name,
                                                 invalid_chrs = input_parameters$special_chrs,
                                                 data_checks_table = data_checks_output,
                                                 source = "file_name",
                                                 file = current_file_name)
  
  # current_data_checks <- check_for_no_proprietary_files()
  
  
  ### run checks on tabular data ###############################################
  
  if (current_is_tabular == TRUE) {
    
    for (j in 1:length(current_headers)) {
      
      # get current header
      current_header <- current_headers[j]
      
      log_info(paste0("Running data checks on column header: ", current_header))
      
      # check for special characters in column headers
      data_checks_output <- check_for_no_special_chrs(input =  current_header,
                                                      invalid_chrs = input_parameters$special_chrs,
                                                      data_checks_table = data_checks_output,
                                                      source = "column_header",
                                                      file = current_file_name)
      
    }
    
  # current_data_checks <- check_for_unique_headers()
    
    
  }
  
  ### run range reports ########################################################
  
  # character cols
  
  # numeric cols
  
  # logical cols
  
  # date cols
  
  # time cols
  
}

### Summarize Checks ###########################################################
# this chunk generates a summary file of all the checks

# clean up checks table
data_checks_output <- data_checks_output %>% 
  distinct()

# create summary
data_checks_summary <- data_checks_output %>% 
  group_by(requirement, pass_check, assessment, source) %>% 
  summarise(values = str_c(unique(value), collapse = ", "),
            file_count = length(unique(file)),
            files = str_c(unique(file), collapse = ", ")) %>% 
  ungroup() %>% 
  mutate(requirement = factor(requirement, levels = c("required", "recommended*", "recommended", "optional"), ordered = TRUE),
         source = factor(source, levels = c("all_file_names", "directory_name", "file_name", "column_header"), ordered = TRUE)) %>% 
  mutate(file_count = case_when(source == "directory_name" ~ NA_integer_, T ~ file_count)) %>% 
  arrange(requirement, pass_check, source, .locale = "en")


### Return Output ##############################################################
# this chunk cleans up the script and prepares the list to return

output <- list(input = data_package_data, # this is the data package provided as input
               parameters = list(), # this is the list of parameters the functions used
               data_checks_summary,  # this is the summarized results, ready for graphing
               data_checks = data_checks_output) # this is the complete raw list of all checks

return(output)
