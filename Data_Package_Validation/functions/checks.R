### checks.R ###################################################################
# Date Created: 2024-06-20
# Date Updated: 2024-06-20
# Author: Bibi Powers-McCormack

# Objective: 
  # functions to run checks on a given data package

# Inputs: 
  # all scripts require the output from the load_tabular_data_from_flmd.R script

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

# no special chrs
allowed_chrs = "[a-zA-Z0-9_\\.\\-]" # alphanumeric character (uppercase and lowercase), underscore, dot, or hyphen.


### Checks Functions ###########################################################
# this chunk contains all of the checks functions




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


### Loop through and check each file ###########################################
# this chunk loops through every file and conducts the checks

for (i in 1:length(data_package_data$filtered_file_paths)) {
  
  #### get inputs ##############################################################
  
  # get current absolute file
  current_file_absoulte <- data_package_data$filtered_file_paths[i]
  
  # get file name
  current_file_name <- basename(current_file_absoulte)
  
  # get relative folder name
  current_folder_path_relative <- dirname(current_file_absoulte) %>% 
    str_remove(pattern = data_package_data$inputs$directory) # get relative file path by stripping absolute file path off
  
  current_is_tabular <- FALSE

  # if tabular data, get col headers and df
  if (str_detect(current_file_name, "\\.csv$|\\.tsv$")){
    
    current_is_tabular <- TRUE

    # get dataframe
    current_df <- data_package_data$tabular_data[[current_file_absoulte]]
    
    # get col headers
    current_headers <- colnames(current_df)
  }
  
  log_info(paste0("Running data checks on file ", i, " of ", length(data_package_data$filtered_file_paths), ": ", current_file_name))
  
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
