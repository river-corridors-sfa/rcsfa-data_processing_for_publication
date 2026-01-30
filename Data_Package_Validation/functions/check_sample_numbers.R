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
# Last updated: 30 January 2026
#
# Status: complete
#
# ==============================================================================
require(pacman)

p_load(tidyverse,
       cli)

# ================================= functions ================================

# CHECK SAMPLE NUMBERS
# 
# Validates sample consistency across your data package files.
# 
# WHAT IT DOES:
#   - Checks that samples in data files have matching metadata entries
#   - Verifies all samples have the same number of replicates
#   - Identifies duplicate sample names
#   - Validates FTICR files match methods file (if applicable)
#   - Checks IGSN mapping against metadata (if present)
# 
# INPUTS:
#   data_package_data - List from load_tabular_data() containing your file info and data
#   
#   pattern_to_exclude_from_metadata_check - (Optional) Pattern(s) to exclude samples 
#                                            from metadata checks (e.g., c("_QC", "_BLK"))
# 
# OUTPUTS:
#   A list with two parts:
#   
#   1. full_summary - Quick overview showing pass/fail for each file
#      Key columns:
#        - expected_number_of_reps: How many reps each sample should have
#        - all_sample_number_reps_match_expected: TRUE if rep counts are consistent
#        - all_samples_have_metadata: TRUE if all samples have metadata
#        - metadata_ParentID_missing_from_data: TRUE if metadata has extra Parent IDs
#        - has_duplicate_sample: TRUE if duplicate sample names found
#        - all_samples_in_icr_methods: TRUE if FTICR samples in methods file
#        - all_samples_in_icr_folder: TRUE if method samples have FTICR files
#   
#   2. summary_by_file - Detailed results for each file showing which samples have issues
# 
# HOW PARENT IDs ARE CREATED:
#   Strips these suffixes from Sample_Name (in order):
#     1. _r# (replicate suffix like _r1, _r2)
#     2. -# or -A# (terminal numbers/codes like -2, -D1)  
#     3. _XX or _XXX (analyte codes like _OCN, _RNA)
#   
#   Example: MySample-1_OCN_r2 → MySample
# 
# WHAT YOU NEED:
#   Required:
#     - Sample data files in Sample_Data folder with Sample_Name column
#   
#   Optional (warnings shown if missing):
#     - Field_Metadata file with Parent_ID column
#     - IGSN-Mapping file with Sample_Name column  
#     - FTICR_Methods.csv with Sample_Name and FTICR-MS columns (for FTICR checks)
# 
# EXAMPLES:
#   # Basic check
#   results <- check_sample_numbers(my_data_package)
#   
#   # Exclude QC and blanks from metadata checks
#   results <- check_sample_numbers(my_data_package, 
#                                    pattern_to_exclude_from_metadata_check = c("_QC", "_BLK"))
#   
#   # View results
#   View(results$full_summary)
#   View(results$summary_by_file$"my_file.csv")

check_sample_numbers <- function(data_package_data,
                                 pattern_to_exclude_from_metadata_check = NULL){
  
  cli_alert("{.emph {col_green('All ICR xml files and output files will be reviewed even in excluded in data_pacakage_data.')}}")
  
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
  
  # Check if metadata file exists (WARNING instead of ABORT)
  metadata_files_exist <- files_df %>%
    filter(str_detect(file, "Field_Metadata")) %>%
    nrow() > 0
  
  has_metadata_file <- FALSE
  metadata_file_path <- NULL
  metadata <- NULL
  
  if (!metadata_files_exist) {
    cli_alert_warning("No Field_Metadata file found. Metadata checks will be skipped.")
  } else {
    # Check if metadata file exists in tabular_data
    metadata_file_path <- files_df %>%
      filter(str_detect(file, "Field_Metadata")) %>%
      pull(all)
    
    if (!metadata_file_path %in% names(data_package_data$tabular_data)) {
      cli_alert_warning("Metadata file '{metadata_file_path}' not found in tabular_data. Metadata checks will be skipped.")
    } else {
      # Check if metadata has required columns
      metadata <- data_package_data$tabular_data[[metadata_file_path]]
      if (!"Parent_ID" %in% names(metadata)) {
        cli_alert_warning("Metadata file must contain 'Parent_ID' column. Metadata checks will be skipped.")
      } else {
        has_metadata_file <- TRUE
        # Prepare metadata for joining
        metadata <- metadata %>%
          select(Parent_ID) %>%
          mutate(metadata_parent_ID = Parent_ID)
      }
    }
  }
  
  # Check if igsn file exists (WARNING instead of ABORT)
  has_igsn_file <- FALSE
  igsn_file_path <- files_df %>%
    filter(str_detect(file, "IGSN-Mapping")) %>%
    pull(all)
  
  if (length(igsn_file_path) == 0) {
    cli_alert_warning("No IGSN mapping file found. IGSN checks will be skipped.")
  } else if (length(igsn_file_path) > 1) {
    cli_alert_warning("Multiple IGSN mapping files found. Only the first will be used: {basename(igsn_file_path[1])}")
    igsn_file_path <- igsn_file_path[1]
    has_igsn_file <- TRUE
  } else {
    has_igsn_file <- TRUE
  }
  
  # If IGSN file exists, check if it's in tabular_data and has required columns
  if (has_igsn_file) {
    if (!igsn_file_path %in% names(data_package_data$tabular_data)) {
      cli_alert_warning("IGSN file '{basename(igsn_file_path)}' not found in tabular_data. IGSN checks will be skipped.")
      has_igsn_file <- FALSE
    } else {
      igsn_df <- data_package_data$tabular_data[[igsn_file_path]]
      if (!"Sample_Name" %in% names(igsn_df)) {
        cli_alert_warning("IGSN file '{basename(igsn_file_path)}' must contain 'Sample_Name' column. IGSN checks will be skipped.")
        has_igsn_file <- FALSE
      }
    }
  }
  
  # Validate that sample data files exist in tabular_data
  sample_file_paths <- files_df %>%
    filter(str_detect(relative_dir, "Sample_Data$")) %>%
    filter(str_detect(file, "csv")) %>%
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
  
  # ---- Get file paths ----
  # Check if FTICR files are present in the package
  has_icr_files <- data_package_data$inputs$files_df %>%
    filter(str_detect(relative_dir, "/FTICR/")) %>% # pull all files within the ICR folder
    pull(all) %>%
    length() > 0
  
  # ---- Initialize dataframes and output list ---- 
  # Initialize summary dataframe to store results for each file
  full_summary <- tibble(
    file = "** EXPECTED VALUES **",
    expected_number_of_reps = NA_real_,
    all_sample_number_reps_match_expected = TRUE,
    all_samples_have_metadata = TRUE,
    metadata_ParentID_missing_from_data = FALSE,
    has_duplicate_sample = FALSE,
    all_samples_in_icr_methods = if(has_icr_files) TRUE else NA,
    all_samples_in_icr_folder = if(has_icr_files) TRUE else NA
  )
  
  # Initialize output list to store all results
  output_list <- list()
  
  # ---- Loop through sample data files ---- 
  
  
  # Process each sample data file
  for (sample_file in sample_file_paths) {
    
    
    # Show processing status
    cli_alert_info("Processing file {match(sample_file, sample_file_paths)} of {length(sample_file_paths)}: {basename(sample_file)}")
    
    # Load and process sample data
    # Extract Parent_ID by removing various suffixes from Sample_Name
    data <- data_package_data[["tabular_data"]][[sample_file]] %>%
      mutate(Parent_ID_step1 = str_remove(Sample_Name, "_r\\d+$"), # remove ICR replicate suffix (_r1, _r2, etc.)
             Parent_ID_step2 = str_remove(Parent_ID_step1, "-([A-Za-z]\\d+|\\d+|[A-Za-z])$"), # remove rep (-1, -D2, etc.)
             Parent_ID = str_remove(Parent_ID_step2, "_[A-Za-z]{2,3}$") # remove analyte code (_OCN, etc.)
      ) %>%
      select(Sample_Name, Parent_ID) 
    
    # Calculate replicate counts and detect duplicates
    sample_summary <- data %>%
      add_count(Parent_ID, name = "rep_count_per_parent_id") %>%
      add_count(Sample_Name, name = "sample_count")
    
    # Determine the expected number of replicates (mode of rep counts)
    mode_rep_count <- sample_summary  %>%
      group_by(rep_count_per_parent_id) %>%
      summarize(mode = n(), .groups = "drop") %>%
      arrange(desc(mode)) %>%
      head(1) %>%
      pull(rep_count_per_parent_id)
    
    # Create exclusion pattern for metadata checking or set to impossible match
    exclude_pattern <- if(!is.null(pattern_to_exclude_from_metadata_check)) {
      paste(pattern_to_exclude_from_metadata_check, collapse = '|')
    } else {
      "^$"  # Pattern that matches nothing
    }
    
    # Perform validation checks for each sample
    if (has_metadata_file) {
      data_summary <- sample_summary %>%
        full_join(metadata, by = 'Parent_ID') %>%
        mutate(expected_number_of_reps = mode_rep_count,
               number_reps_match_expected = rep_count_per_parent_id == mode_rep_count,
               has_metadata = case_when(
                 str_detect(Sample_Name, exclude_pattern) ~ NA, # excluded samples
                 is.na(metadata_parent_ID) ~ FALSE, # no metadata found
                 TRUE ~ TRUE # has metadata
               ),
               duplicate = sample_count > 1,
               metadata_ParentID_missing_from_data = case_when(is.na(Sample_Name) ~ TRUE,
                                                               TRUE ~ FALSE))
    } else {
      # No metadata file available - skip metadata checks
      data_summary <- sample_summary %>%
        mutate(expected_number_of_reps = mode_rep_count,
               number_reps_match_expected = rep_count_per_parent_id == mode_rep_count,
               has_metadata = NA, # Cannot check without metadata
               duplicate = sample_count > 1,
               metadata_ParentID_missing_from_data = NA,
               metadata_parent_ID = NA)
    }
    
    # Add file-level summary to results
    full_summary <- full_summary %>%
      add_row(file = basename(sample_file),
              expected_number_of_reps = mode_rep_count,
              all_sample_number_reps_match_expected = case_when(any(FALSE %in% data_summary$number_reps_match_expected) ~ FALSE,
                                                                TRUE ~ TRUE),
              all_samples_have_metadata = if(has_metadata_file) {
                case_when(any(FALSE %in% data_summary$has_metadata) ~ FALSE,
                          TRUE ~ TRUE)
              } else {
                NA
              },
              metadata_ParentID_missing_from_data = if(has_metadata_file) {
                case_when(any(TRUE %in% data_summary$metadata_ParentID_missing_from_data) ~ TRUE,
                          TRUE ~ FALSE)
              } else {
                NA
              },
              has_duplicate_sample = case_when(any(TRUE %in% data_summary$duplicate) ~ TRUE,
                                               TRUE ~ FALSE))
    
    # Store results in output list
    output_list[['full_summary']] <- full_summary
    output_list[['summary_by_file']][[basename(sample_file)]] <- data_summary %>%
      select(Sample_Name, Parent_ID, expected_number_of_reps, number_reps_match_expected, has_metadata, metadata_ParentID_missing_from_data, duplicate)%>%
      # Add optimal values reference row at the top
      add_row(
        Sample_Name = "** EXPECTED VALUES **",
        Parent_ID = "** EXPECTED VALUES **", 
        expected_number_of_reps = NA,
        number_reps_match_expected = TRUE,
        has_metadata = if(has_metadata_file) TRUE else NA,
        metadata_ParentID_missing_from_data = if(has_metadata_file) FALSE else NA,
        duplicate = FALSE,
        .before = 1  # Adds the row at the top
      )
    
  }
  
  
  # ---- Process IGSN ----
  
  if (has_igsn_file) {
    
    igsn_summary <- data_package_data[["tabular_data"]][[igsn_file_path]] %>%
      select(Sample_Name) %>%
      mutate(Parent_ID = str_remove(Sample_Name, '_(RNA|Sediment|Water)$'),
             igsn_parent_ID = Parent_ID) %>%
      select(-Sample_Name)
    
    if (has_metadata_file) {
      igsn_summary <- igsn_summary %>%
        full_join(metadata, by = 'Parent_ID') %>%
        mutate(has_metadata = case_when(
          is.na(metadata_parent_ID) ~ FALSE, # no metadata found
          TRUE ~ TRUE # has metadata
        ),
        metadata_ParentID_missing_from_data = case_when(
          is.na(igsn_parent_ID) ~ TRUE, # Parent_ID not in IGSN data
          TRUE ~ FALSE # Parent_ID exists in IGSN data
        )) %>%
        select(Parent_ID, has_metadata, metadata_ParentID_missing_from_data)
    } else {
      igsn_summary <- igsn_summary %>%
        mutate(has_metadata = NA,
               metadata_ParentID_missing_from_data = NA) %>%
        select(Parent_ID, has_metadata, metadata_ParentID_missing_from_data)
    }
    
    # Store results in output list
    output_list[['full_summary']] <- output_list[['full_summary']] %>%
      add_row(file = basename(igsn_file_path),
              expected_number_of_reps = NA,
              all_sample_number_reps_match_expected = NA,
              
              all_samples_have_metadata = if(has_metadata_file) {
                case_when(any(igsn_summary$has_metadata == FALSE, na.rm = TRUE) ~ FALSE,
                          TRUE ~ TRUE)
              } else {
                NA
              },
              metadata_ParentID_missing_from_data = if(has_metadata_file) {
                case_when(any(TRUE %in% igsn_summary$metadata_ParentID_missing_from_data) ~ TRUE,
                          TRUE ~ FALSE)
              } else {
                NA
              },
              has_duplicate_sample = NA,
              all_samples_in_icr_methods = NA,
              all_samples_in_icr_folder = NA)
    
    output_list[['summary_by_file']][[basename(igsn_file_path)]] <- igsn_summary %>%
      # Add optimal values reference row at the top
      add_row(
        Parent_ID = "** EXPECTED VALUES **", 
        has_metadata = if(has_metadata_file) TRUE else NA,
        metadata_ParentID_missing_from_data = if(has_metadata_file) FALSE else NA,
        .before = 1  # Adds the row at the top
      )
  }
  
  # ---- Process FTICR files if present ----
  if(has_icr_files == TRUE){
    
    cli_alert_info("Processing FTICR files")
    
    # Check for FTICR methods file
    icr_methods_path <- names(data_package_data$tabular_data)[grepl("FTICR_Methods\\.csv", names(data_package_data$tabular_data))]
    
    has_icr_methods <- length(icr_methods_path) > 0
    
    if (!has_icr_methods) {
      cli_alert_warning("FTICR_Methods.csv file not found. FTICR checks will be incomplete.")
    }
    
    # Initialize FTICR components check flags
    has_xml_files <- FALSE
    has_processed_file <- FALSE
    has_output_files <- FALSE
    
    icr_methods_file <- NULL
    xml_files <- NULL
    processed_file <- NULL
    outputs_files <- NULL
    
    # Load FTICR methods file if available
    if (has_icr_methods) {
      icr_methods_file <- data_package_data$tabular_data[[icr_methods_path[1]]]
      
      if (!"FTICR-MS" %in% names(icr_methods_file)) {
        cli_alert_warning("FTICR_Methods file missing 'FTICR-MS' column. FTICR checks will be incomplete.")
        has_icr_methods <- FALSE
      } else if (!"Sample_Name" %in% names(icr_methods_file)) {
        cli_alert_warning("FTICR_Methods file missing 'Sample_Name' column. FTICR checks will be incomplete.")
        has_icr_methods <- FALSE
      } else {
        icr_methods_file <- icr_methods_file %>%
          filter(`FTICR-MS` != '-9999') %>%
          select(Sample_Name) %>%
          mutate(Methods_Sample_Name = Sample_Name)
      }
    }
    
    # Check XML files in FTICR folder
    xml_file_list <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, 'xml')) %>%
      pull(all)
    
    if (length(xml_file_list) > 0) {
      has_xml_files <- TRUE
      
      xml_dir <- unique(dirname(xml_file_list))
      
      xml_files <- map(xml_dir, ~list.files(.x, pattern = '\\.xml$', full.names = FALSE))%>%
        unlist() %>%
        tibble(xml = .) %>%
        mutate(Sample_Name = str_remove(xml, "_p\\d+\\.xml$"),
               XML_Sample_Name = Sample_Name) %>%
        select(-xml)
      
      if (has_icr_methods) {
        xml_files <- xml_files %>%
          full_join(icr_methods_file, by = 'Sample_Name')
      }
    } else {
      cli_alert_warning("No XML files found in FTICR folder.")
    }
    
    # Check processed ICR data file
    processed_file_path <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, 'CoreMS_Processed_ICR_Data.csv')) %>%
      pull(all)
    
    if (length(processed_file_path) > 0) {
      has_processed_file <- TRUE
      processed_file <- data_package_data[["tabular_data"]][[processed_file_path]] %>%
        select(-Calibrated_Mass) %>%
        colnames() %>%
        tibble(Sample_Name = .) %>%
        mutate(Processed_Sample_Name = Sample_Name)
      
      if (has_icr_methods) {
        processed_file <- processed_file %>%
          full_join(icr_methods_file, by = 'Sample_Name')
      }
    } else {
      cli_alert_warning("CoreMS_Processed_ICR_Data.csv file not found in FTICR folder.")
    }
    
    # Check CoreMS output files
    output_file_list <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, '\\.corems\\.csv')) %>%
      pull(all)
    
    if (length(output_file_list) > 0) {
      has_output_files <- TRUE
      
      output_dir <- unique(dirname(output_file_list))
      
      outputs_files <- map(output_dir, ~list.files(.x, pattern = '\\.csv$', full.names = FALSE))%>%
        unlist() %>% 
        tibble(output = .) %>%
        mutate(Sample_Name = str_remove(output, "_p\\d+\\.corems\\.csv$"),
               Outputs_Sample_Name = Sample_Name) %>%
        select(-output)
      
      if (has_icr_methods) {
        outputs_files <- outputs_files %>%
          full_join(icr_methods_file, by = 'Sample_Name')
      }
    } else {
      cli_alert_warning("No .corems.csv output files found in FTICR folder.")
    }
    
    # Combine all FTICR checks if we have at least the methods file
    if (has_icr_methods) {
      icr_check <- icr_methods_file
      
      if (has_xml_files) {
        icr_check <- icr_check %>%
          full_join(xml_files, by = c('Sample_Name', 'Methods_Sample_Name'))
      }
      
      if (has_processed_file) {
        icr_check <- icr_check %>%
          full_join(processed_file, by = c('Sample_Name', 'Methods_Sample_Name'))
      }
      
      if (has_output_files) {
        icr_check <- icr_check %>%
          full_join(outputs_files, by = c('Sample_Name', 'Methods_Sample_Name'))
      }
      
      # Add FTICR results to output summary
      if (has_xml_files) {
        full_summary <- full_summary %>%  
          add_row(
            file = 'xml files', 
            expected_number_of_reps = NA, 
            all_sample_number_reps_match_expected = NA,  
            all_samples_have_metadata = NA,  
            all_samples_in_icr_methods = !any(is.na(xml_files$Methods_Sample_Name)),
            metadata_ParentID_missing_from_data = NA,
            has_duplicate_sample = NA,
            all_samples_in_icr_folder = NA
          )
      }
      
      if (has_processed_file) {
        full_summary <- full_summary %>%
          add_row(
            file = 'processed icr', 
            expected_number_of_reps = NA, 
            all_sample_number_reps_match_expected = NA, 
            all_samples_have_metadata = NA, 
            all_samples_in_icr_methods = !any(is.na(processed_file$Methods_Sample_Name)),
            metadata_ParentID_missing_from_data = NA,
            has_duplicate_sample = NA,
            all_samples_in_icr_folder = NA
          )
      }
      
      if (has_output_files) {
        full_summary <- full_summary %>%
          add_row(
            file = 'icr outputs', 
            expected_number_of_reps = NA, 
            all_sample_number_reps_match_expected = NA, 
            all_samples_have_metadata = NA, 
            all_samples_in_icr_methods = !any(is.na(outputs_files$Methods_Sample_Name)),
            metadata_ParentID_missing_from_data = NA,
            has_duplicate_sample = NA,
            all_samples_in_icr_folder = NA
          )
      }
      
      # Check if all methods samples are present in folder files
      if (has_icr_methods) {
        # Update the existing rows with all_samples_in_icr_folder evaluation
        if (has_xml_files) {
          row_idx <- which(full_summary$file == 'xml files')
          full_summary$all_samples_in_icr_folder[row_idx] <- !any(is.na(xml_files$XML_Sample_Name))
        }
        
        if (has_processed_file) {
          row_idx <- which(full_summary$file == 'processed icr')
          full_summary$all_samples_in_icr_folder[row_idx] <- !any(is.na(processed_file$Processed_Sample_Name))
        }
        
        if (has_output_files) {
          row_idx <- which(full_summary$file == 'icr outputs')
          full_summary$all_samples_in_icr_folder[row_idx] <- !any(is.na(outputs_files$Outputs_Sample_Name))
        }
      }
      
      # Update output list with the modified full_summary
      output_list[['full_summary']] <- full_summary
      
      # Store FTICR detailed results
      output_list[['summary_by_file']][['FTICR Folder']] <- icr_check
      
    }
  }
  
  # ---- Summary-based CLI alerts ----
  # Provide user feedback based on validation results
  
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
    cli_alert_danger("Some files in the FTICR folder are missing from the FTICR methods file")
  }
  
  # Check for FTICR folder issues
  if (any(output_list[['full_summary']]$all_samples_in_icr_folder == FALSE, na.rm = TRUE)) {
    cli_alert_danger("Some samples in the FTICR methods file are missing from the FTICR folder")
  }
  
  # Check for duplicate samples
  if (any(output_list[['full_summary']]$has_duplicate_sample  == TRUE, na.rm = TRUE)) {
    cli_alert_danger("Some files contain duplicate samples")
  }
  
  # Check for missing metadata entries
  if (any(output_list[['full_summary']]$metadata_ParentID_missing_from_data == TRUE, na.rm = TRUE)) {
    cli_alert_danger("Some Parent IDs in the field metadata were not found in all data files")
  }
  
  return(output_list)
  
}