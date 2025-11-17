# ==============================================================================
#
# Check sample IDs across data package to ensure:
#    - there are no duplicates
#    - rep numbers match
#    - each sample in data file has metadata and vice versa
#    - ICR files in the FTICR folder also match 
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 14 Nov 2025
#
# ==============================================================================
require(pacman)
p_load(tidyverse,
       cli)

# ================================= functions ================================

check_sample_numbers <- function(data_package_data){
  
  # ---- TO DO add some validation for inputs ----
  
  # ---- get file paths ----

  sample_file_paths <- data_package_data$inputs$files_df %>%
    filter(str_detect(relative_dir, "Sample_Data$")) %>% # pull data from sample data folder, not recursive (so that it doesnt look into ICR folder)
    filter(!str_detect(file, "Methods_Codes")) %>% # filter out methods code file since it doesnt have sample IDs
    pull(all)
  
  has_icr_files <- data_package_data$inputs$files_df %>%
    filter(str_detect(relative_dir, "/FTICR/")) %>% # pull all files within the ICR folder
    pull(all) %>%
    length() > 1
  
  metadata_file_path <- data_package_data$inputs$files_df %>%
    filter(str_detect(file, "Field_Metadata")) %>% # pull metadata file
    pull(all)
    
  
  # ---- read metadata ---- 
  
  metadata <- data_package_data[["tabular_data"]][[metadata_file_path]] %>%
    select(Parent_ID) %>%
    mutate(metadata_parent_ID = Parent_ID)
  
  # ---- initialize dataframes and output list ---- 
  
  metadata_summary <- tibble(file = as.character(),
                             samples_missing_metadata = as.character())
  
  full_summary <- tibble(file = as.character(),
                         expected_number_of_reps = as.numeric(),
                         all_sample_number_reps_match_expected = as.logical(),
                         all_samples_have_metadata = as.logical())
  
  output_list <- list()

  # ---- loop through files ---- 
  

  for (sample_file in sample_file_paths) {
    
    data <- data_package_data[["tabular_data"]][[sample_file]] %>%
      mutate(Parent_ID_step1 = str_remove(Sample_Name, "_r\\d+$"), # extra Parent_ID piece by piece so that it works with multiple formats
             Parent_ID_step2 = str_remove(Parent_ID_step1, "-\\d+$"),
             Parent_ID = str_remove(Parent_ID_step2, "_[A-Za-z]{2,3}$")
             ) %>%
      select(Sample_Name, Parent_ID)
    
    sample_summary <- data %>%
      add_count(Parent_ID, name = "rep_count_per_parent_id") %>%
      add_count(Sample_Name, name = "sample_count")

    mode_rep_count <- sample_summary  %>%
      group_by(rep_count_per_parent_id) %>%
      summarize(mode = n(), .groups = "drop") %>%
      arrange(desc(mode)) %>%
      head(1) %>%
      pull(rep_count_per_parent_id)
     
    data_summary <- sample_summary %>%
      full_join(metadata, by = 'Parent_ID') %>%
      mutate(expected_number_of_reps = mode_rep_count,
             number_reps_match_expected = rep_count_per_parent_id == mode_rep_count,
             has_metadata = case_when(is.na(metadata_parent_ID) ~ FALSE,
                                      TRUE ~ TRUE),
             duplicate = case_when(sample_count == 1 ~ FALSE,
                                   TRUE ~ TRUE)) 
    
    missing_metadata <- data_summary %>%
      filter(is.na(sample_count)) %>%
      pull(Parent_ID)
      
    metadata_summary <- metadata_summary %>%
      add_row(file = basename(sample_file),
              samples_missing_metadata = case_when(is_empty(missing_metadata) == T ~ 'NONE',
                                                   TRUE ~ paste(missing_metadata, collapse = '; ')))
    
    full_summary <- full_summary %>%
      add_row(file = basename(sample_file),
              expected_number_of_reps = mode_rep_count,
              all_sample_number_reps_match_expected = case_when(any(FALSE %in% data_summary$number_reps_match_expected) == TRUE ~ FALSE,
                                                         TRUE ~ TRUE),
              all_samples_have_metadata = case_when(any(FALSE %in% data_summary$has_metadata) == TRUE ~ FALSE,
                                           TRUE ~ TRUE))
    
    # add reports to  output 
    output_list[['full_summary']] <- full_summary
    output_list[['metadata_summary']] <- metadata_summary
    output_list[['summary_by_file']][[basename(sample_file)]] <- data_summary %>%
      select(Sample_Name, Parent_ID, expected_number_of_reps, number_reps_match_expected, has_metadata, duplicate)
    
  }
  
  if(has_icr_files == T){
    
    # check that all samples are in icr methods files, all samples have metadata and vice versa
    
    icr_methods_file <- data_package_data$tabular_data[[
      names(data_package_data$tabular_data)[grepl("FTICR_Methods\\.csv", names(data_package_data$tabular_data))][1]
    ]] %>%
      filter(`FTICR-MS` != '-9999') %>%
      select(Sample_Name)%>%
      mutate(Methods_Sample_Name = Sample_Name)
    
    xml_files <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, 'xml')) %>% # pull all files within the ICR folder
      pull(file) %>%
      tibble(xml = .) %>%
      mutate(Sample_Name = str_remove(xml, "_p\\d+\\.xml$"),
             XML_Sample_Name = Sample_Name) %>%
      select(-xml)%>%
      full_join(icr_methods_file, by = 'Sample_Name')
    
    processed_file <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, 'CoreMS_Processed_ICR_Data.csv')) %>% # pull all files within the ICR folder
      pull(all) %>%
      data_package_data[["tabular_data"]][[.]] %>%
      select(-Calibrated_Mass) %>%
      colnames() %>%
      tibble(Sample_Name = .) %>%
      mutate(Processed_Sample_Name = Sample_Name)%>%
      full_join(icr_methods_file, by = 'Sample_Name')
    
    outputs_files <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, '.corems.csv')) %>% # pull all files within the ICR folder
      pull(file) %>%
      tibble(output = .) %>%
      mutate(Sample_Name = str_remove(output, "_p\\d+\\.corems.csv$"),
             Outputs_Sample_Name = Sample_Name) %>%
      select(-output)%>%
      full_join(icr_methods_file, by = 'Sample_Name')
    
    icr_check <- icr_methods_file %>%
      full_join(xml_files)%>%
      full_join(processed_file)%>%
      full_join(outputs_files)
    
    # add reports to  output 
    output_list[['full_summary']] <- output_list[['full_summary']] %>%
      add_column(all_samples_in_icr_methods = NA,
                 all_samples_in_icr_folder = NA) %>%  
      add_row(
        file = 'xml files', 
        expected_number_of_reps = NA, 
        all_sample_number_reps_match_expected = NA,  
        all_samples_have_metadata = NA,  
        all_samples_in_icr_methods = !any(is.na(xml_files))
      ) %>%
      add_row(
        file = 'processed icr', 
        expected_number_of_reps = NA, 
        all_sample_number_reps_match_expected = NA, 
        all_samples_have_metadata = NA, 
        all_samples_in_icr_methods = !any(is.na(processed_file))
      ) %>%
      add_row(
        file = 'icr outputs', 
        expected_number_of_reps = NA, 
        all_sample_number_reps_match_expected = NA, 
        all_samples_have_metadata = NA, 
        all_samples_in_icr_methods = !any(is.na(outputs_files))
      ) %>%
      mutate(all_samples_in_icr_folder = case_when(str_detect(file, 'FTICR_Methods') & any(is.na(icr_check$Methods_Sample_Name)) ~ FALSE,
                                                   str_detect(file, 'FTICR_Methods') & !any(is.na(icr_check$Methods_Sample_Name)) ~ TRUE,
                                                   TRUE ~ NA))
    
    output_list[['summary_by_file']][['FTICR Folder']] <- icr_check
    
  }
  
  return(output_list)
  }
