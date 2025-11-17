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
  
  # ---- Input validation ----
  
  # Check if data_package_data is provided
  if (missing(data_package_data) || is.null(data_package_data)) {
    cli_abort("data_package_data is required and cannot be NULL")
  }
  
  # Check if data_package_data is a list
  if (!is.list(data_package_data)) {
    cli_abort("data_package_data must be a list")
  }
  
  # Check for required top-level components
  required_components <- c("inputs", "tabular_data")
  missing_components <- setdiff(required_components, names(data_package_data))
  if (length(missing_components) > 0) {
    cli_abort("Missing required components in data_package_data: {paste(missing_components, collapse = ', ')}")
  }
  
  # Check inputs structure
  if (!is.list(data_package_data$inputs)) {
    cli_abort("data_package_data$inputs must be a list")
  }
  
  if (!"files_df" %in% names(data_package_data$inputs)) {
    cli_abort("data_package_data$inputs must contain 'files_df'")
  }
  
  # Check files_df structure
  files_df <- data_package_data$inputs$files_df
  if (!is.data.frame(files_df)) {
    cli_abort("data_package_data$inputs$files_df must be a data frame")
  }
  
  required_columns <- c("relative_dir", "file", "all")
  missing_columns <- setdiff(required_columns, names(files_df))
  if (length(missing_columns) > 0) {
    cli_abort("files_df is missing required columns: {paste(missing_columns, collapse = ', ')}")
  }
  
  # Check if files_df has any rows
  if (nrow(files_df) == 0) {
    cli_abort("files_df cannot be empty")
  }
  
  # Check tabular_data structure
  if (!is.list(data_package_data$tabular_data)) {
    cli_abort("data_package_data$tabular_data must be a list")
  }
  
  # Check if there are sample data files
  sample_files_exist <- files_df %>%
    filter(str_detect(relative_dir, "Sample_Data$")) %>%
    filter(!str_detect(file, "Methods_Codes")) %>%
    nrow() > 0
  
  if (!sample_files_exist) {
    cli_abort("No sample data files found in Sample_Data folder")
  }
  
  # Check if metadata file exists
  metadata_files_exist <- files_df %>%
    filter(str_detect(file, "Field_Metadata")) %>%
    nrow() > 0
  
  if (!metadata_files_exist) {
    cli_abort("No Field_Metadata file found")
  }
  
  # Check if metadata file exists in tabular_data
  metadata_file_path <- files_df %>%
    filter(str_detect(file, "Field_Metadata")) %>%
    pull(all)
  
  if (!metadata_file_path %in% names(data_package_data$tabular_data)) {
    cli_abort("Metadata file '{metadata_file_path}' not found in tabular_data")
  }
  
  # Check if metadata has required columns
  metadata <- data_package_data$tabular_data[[metadata_file_path]]
  if (!"Parent_ID" %in% names(metadata)) {
    cli_abort("Metadata file must contain 'Parent_ID' column")
  }
  
  # Validate that sample data files exist in tabular_data
  sample_file_paths <- files_df %>%
    filter(str_detect(relative_dir, "Sample_Data$")) %>%
    filter(!str_detect(file, "Methods_Codes")) %>%
    pull(all)
  
  missing_sample_files <- setdiff(sample_file_paths, names(data_package_data$tabular_data))
  if (length(missing_sample_files) > 0) {
    cli_abort("Sample data files not found in tabular_data: {paste(basename(missing_sample_files), collapse = ', ')}")
  }
  
  # Check if sample data files have required columns
  for (sample_file in sample_file_paths) {
    sample_data <- data_package_data$tabular_data[[sample_file]]
    if (!"Sample_Name" %in% names(sample_data)) {
      cli_abort("Sample data file '{basename(sample_file)}' must contain 'Sample_Name' column")
    }
  }
  
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
                         all_samples_have_metadata = as.logical(),
                         has_duplicate_sample = as.logical())
  
  output_list <- list()

  # ---- loop through files ---- 
  
  if (length(sample_file_paths) > 3) {
    pb <- cli_progress_bar("Processing files", total = length(sample_file_paths))
  }
  

  for (sample_file in sample_file_paths) {

      
      if (exists("pb")) {
        cli_progress_update(pb)
      }
      

    cli_alert_info("Processing file {match(sample_file, sample_file_paths)} of {length(sample_file_paths)}: {basename(sample_file)}")
    
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
                                           TRUE ~ TRUE),
              has_duplicate_sample = case_when(any(TRUE %in% data_summary$duplicate) == TRUE ~ TRUE,
                                               TRUE ~ FALSE))
    
    # add reports to  output 
    output_list[['full_summary']] <- full_summary
    output_list[['metadata_summary']] <- metadata_summary
    output_list[['summary_by_file']][[basename(sample_file)]] <- data_summary %>%
      select(Sample_Name, Parent_ID, expected_number_of_reps, number_reps_match_expected, has_metadata, duplicate)
    
    if (exists("pb")) {
      cli_progress_done(pb)
    }
    
  }
  
  if(has_icr_files == T){
    
    cli_alert_info("Processing FTICR files")
    
    
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
  
  # ---- Summary-based CLI alerts ----
  
  # Check for replication issues
  if (any(output_list[['full_summary']]$all_sample_number_reps_match_expected == FALSE, na.rm = TRUE)) {
    cli_alert_danger("Some files have inconsistent replicate counts")
  }
  
  # Check for metadata completeness issues
  if (any(output_list[['full_summary']]$all_samples_have_metadata == FALSE, na.rm = TRUE)) {
    cli_alert_danger("Some files have samples that were not found in the field metadata")
  }
  
  # Check for FTICR methods issues
  if (any(output_list[['full_summary']]$all_samples_in_icr_methods == FALSE, na.rm = TRUE)) {
    cli_alert_danger("Some FTICR files in the FTICR folder are missing from the FTICR methods file")
  }
  
  # Check for FTICR folder issues
  if (any(output_list[['full_summary']]$all_samples_in_icr_folder == FALSE, na.rm = TRUE)) {
    cli_alert_danger("Some samples in the FTICR methods file are missing from the FTICR folder")
  }
  
  # Check for duplicate samples
  if (any(output_list[['full_summary']]$has_duplicate_samples == TRUE, na.rm = TRUE)) {
    cli_alert_danger("Some files contain duplicate samples")
  }
  
  # Check for missing metadata entries
  if (any(output_list[['metadata_summary']]$samples_missing_metadata != 'NONE', na.rm = TRUE)) {
    cli_alert_danger("Some samples were not found in the field metadata")
  }
  
  return(output_list)
  }
