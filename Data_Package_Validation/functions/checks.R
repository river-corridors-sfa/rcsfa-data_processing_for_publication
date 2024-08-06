### checks.R ###################################################################
# Date Created: 2024-06-20
# Date Updated: 2024-06-20
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
  
test_flmd <- create_flmd_skeleton(directory = test_directory)

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
  "recommended", "FAILED", "no_proprietary_ext", ".docx", "file_name", 1, "file5.docx"
)


### Checks Inputs ##############################################################
# this chunk provides all the modular, although generally consistent parameters for the checks

input_parameters <- list(

  # required file strings
  required_file_strings = list(flmd = ".*flmd\\.csv$", # file that ends with flmd.csv
                                dd = ".*dd\\.csv$", # file that ends with dd.csv
                                readme = "^readme.*\\.pdf$"), # .pdf file that begins with readme
  
  # no special chrs
  allowed_chrs = "[a-zA-Z0-9_\\.\\-]", # alphanumeric character (uppercase and lowercase), underscore, dot, or hyphen.
  
  # non proprietary file extensions (a list of the extensions that will be flagged)
  non_proprietary_extensions = c()
  
)


### Checks Functions ###########################################################
# this chunk contains all of the checks functions

initialize_checks_df <- function() {
  # initialize empty df checks outputs
  current_data_checks <- tibble(
    requirement = factor(), 
    pass_check = logical(), 
    assessment = factor(), 
    value = character(), 
    source = character(), 
    file = character()
  )
  
  return(current_data_checks)
}

check_for_required_file_strings <- function(source_to_check = all_file_names, 
                                            required_file_strings = input_parameters$required_file_strings){
  
  # checks to see if each required file string exists in all_files vector
  # inputs: 
    #  source_to_check = a vector of strings to check
    # required_file_strings = a list of regex strings to check for
  # output: standard check df
  # assumptions: 
    # uses the strings provided in required_file_strings to check against all_file_names
    # returns TRUE when only a single file fits the regex provided in the input list;
    # returns FALSE otherwise (e.g., if no files match or if more than one file matches)
  
  # initialize empty df
  current_data_checks <- initialize_checks_df()
  
  # for each required string...
  for (i in seq_along(required_file_strings)) {
    
    # get current file string
    current_required_file_string <- required_file_strings[[i]]
    
    # check file name against regex string
    matches <- grepl(current_required_file_string, source_to_check, ignore.case = TRUE)
    
    if (any(matches)) {
      current_check <- TRUE
      
      file_name <- source_to_check[matches]
    } else {
      current_check <- FALSE
      
      file_name <- NA_character_
    }
    
    # update output
    current_data_checks <- current_data_checks %>% 
      add_row(
        requirement = "required", 
        pass_check = current_check, 
        assessment = "includes required files", 
        value = current_required_file_string, 
        source = "all_file_names", 
        file = file_name
    )
    
  }
  
  return(current_data_checks)
  
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
current_data_checks <- tibble(
  requirement = factor(), 
  pass_check = logical(), 
  assessment = factor(), 
  value = character(), 
  source = character(), 
  file = character()
)


### Check all files ############################################################
# this chunk first checks the entire DP for any checks



### Loop through and check each file ###########################################
# this chunk loops through every file and conducts the checks

all_files_absolute = data_package_data$outputs$filtered_file_paths

all_file_names = basename(all_files_absolute)
  

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
  
  #### prepare checks for current file #########################################
  
  # initialize empty df
  current_data_checks <- tibble(
    requirement = factor(), 
    pass_check = logical(), 
    assessment = factor(), 
    value = character(), 
    source = character(), 
    file = character()
  )
  
  #### run checks on files #####################################################
  
  # check for special characters
  current_data_checks <- check_for_no_special_chrs(requirement = TRUE, 
                                                   source = "file_name",
                                                   file = current_file_name)
  
  current_data_checks <- check_for_no_proprietary_files()
  
  #### run checks on folders ###################################################
  current_data_checks <- check_for_no_special_chrs()
  
  #### run checks on tabular data ##############################################
  current_data_checks <- check_for_no_special_chrs()
  current_data_checks <- check_for_unique_headers()
  
  #### run range reports #######################################################
  
  # character cols
  
  # numeric cols
  
  # logical cols
  
  # date cols
  
  # time cols
  
}

### Summarize Checks ###########################################################
# this chunk generates a summary file of all the checks


### Return Output ##############################################################
# this chunk cleans up the script and prepares the list to return

output <- list(input = data_package_data, # this is the data package provided as input
               parameters = list(), # this is the list of parameters the functions used
               data_checks_summary,  # this is the summarized results, ready for graphing
               data_checks) # this is the complete raw list of all checks

return(output)
