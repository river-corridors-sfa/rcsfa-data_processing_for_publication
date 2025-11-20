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
# 17 November 2025
#
# Status: complete
#
# ==============================================================================
require(pacman)

p_load(tidyverse,
       cli)

# ================================= functions ================================

#' Check sample numbers across a data package
#'
#' This function validates sample identifiers and replicate counts across all sample
#' data files in a data package, ensuring consistency between:
#' \itemize{
#'   \item Sample data files (in the `Sample_Data` directory)
#'   \item The Field Metadata file (containing `Parent_ID`)
#'   \item FTICR files (if a `FTICR` folder exists)
#'   \item An IGSN mapping file (file name must contain `IGSN-Mapping`)
#' }
#'
#' The function performs integrity checks, summarizes results per file, and emits
#' CLI alerts for potential issues (e.g., missing metadata, inconsistent replicates,
#' duplicates, FTICR mismatches, and metadata Parent IDs not represented in data or IGSN).
#'
#' @param data_package_data A list produced by `load_tabular_data()` containing:
#' \describe{
#'   \item{inputs}{A list that includes `files_df` (data frame with columns
#'     `relative_dir`, `file`, and `all` for fully qualified relative paths).}
#'   \item{tabular_data}{A named list of data frames keyed by the `all` paths from `files_df`.}
#' }
#' @param pattern_to_exclude_from_metadata_check A character vector of regex
#' patterns. Any `Sample_Name` matching one or more of these patterns will be
#' excluded from metadata presence checks (they will receive `NA` in `has_metadata`).
#' Default = `NULL` (no exclusions). These exclusion patterns are applied only to
#' sample data files, not to the IGSN mapping file.
#'
#' @return A list with two elements:
#' \describe{
#'   \item{full_summary}{A tibble with one row per processed file (sample files,
#'     IGSN mapping file, optional FTICR checks). Columns include:
#'       \itemize{
#'         \item `file` - basename or label for the file / check group
#'         \item `expected_number_of_reps` - modal replicate count (NA for non-sample/IGSN/FTICR rows)
#'         \item `all_sample_number_reps_match_expected` - TRUE if all Parent_ID groups have the modal replicate count
#'         \item `all_samples_have_metadata` - TRUE if all non-excluded samples have matching metadata
#'         \item `metadata_ParentID_missing_from_data` - TRUE if any metadata Parent_ID not found in the particular file (or mapping)
#'         \item `has_duplicate_sample` - TRUE if duplicate `Sample_Name` values are detected
#'         \item `all_samples_in_icr_methods` - FTICR-related check (NA for non-FTICR rows)
#'         \item `all_samples_in_icr_folder` - FTICR-related check (NA for non-FTICR rows)
#'       }}
#'   \item{summary_by_file}{A named list of per-file tibbles. Each tibble for a sample
#'     data file includes (with an initial "** EXPECTED VALUES **" reference row):
#'       \itemize{
#'         \item `Sample_Name`
#'         \item `Parent_ID` (derived from `Sample_Name`)
#'         \item `expected_number_of_reps`
#'         \item `number_reps_match_expected` (logical)
#'         \item `has_metadata` (logical/NA for excluded samples)
#'         \item `metadata_ParentID_missing_from_data` (logical)
#'         \item `duplicate` (logical)
#'       }
#'     The required IGSN mapping tibble includes:
#'       \itemize{
#'         \item `Parent_ID` (derived from IGSN `Sample_Name`)
#'         \item `igsn_parent_ID` (original derived ID before join; retained for transparency)
#'         \item `metadata_parent_ID` (from Field Metadata)
#'         \item `has_metadata` (logical)
#'         \item `metadata_ParentID_missing_from_data` (TRUE for metadata IDs absent in IGSN mapping)
#'       }
#'     If FTICR data are present, a combined "FTICR Folder" tibble shows merged checks
#'     across Methods, XML, processed, and output files.
#' }
#'
#' @details
#' Core validations:
#' \itemize{
#'   \item \strong{Replicate consistency} - Determines the mode (most frequent) replicate count per Parent_ID and verifies uniformity.
#'   \item \strong{Metadata coverage} - Confirms every non-excluded sample has a matching Parent_ID in the Field Metadata.
#'   \item \strong{Duplicate detection} - Flags repeated `Sample_Name` entries within each sample data file.
#'   \item \strong{FTICR validation} - Ensures samples listed in the FTICR methods file are represented across XML, processed, and output files, and vice versa (if FTICR folder present).
#'   \item \strong{IGSN mapping validation (required)} - Aligns IGSN-derived Parent_ID values with metadata Parent_IDs and identifies metadata Parent_IDs missing from the mapping.
#' }
#'
#' \strong{Parent_ID extraction from Sample_Data files}:
#' \enumerate{
#'   \item Remove replicate suffix: `_r<digit>` (e.g., `_r1`).
#'   \item Remove terminal numeric suffix: `-<digit>` (e.g., `-2`).
#'   \item Remove terminal analyte/code suffix: `_[A-Za-z]{2,3}` (e.g., `_OCN`).
#' }
#'
#' @section IGSN Mapping (Required):
#' A file whose name contains `IGSN-Mapping` MUST be present. Its `Sample_Name`
#' values are transformed into `Parent_ID` by stripping *terminal* sample-type
#' suffixes: `_RNA`, `_Sediment`, `_Water` (pattern: `_(RNA|Sediment|Water)$`).
#' After transformation:
#' \itemize{
#'   \item `has_metadata` = TRUE if the derived Parent_ID exists in Field Metadata.
#'   \item `metadata_ParentID_missing_from_data` = TRUE for metadata Parent_IDs with no corresponding IGSN-derived Parent_ID.
#' }
#' If the IGSN file is missing or lacks the `Sample_Name` column, the function aborts.
#'
#' @section Input Validation:
#' The function aborts when:
#' \itemize{
#'   \item Required top-level list elements (`inputs`, `tabular_data`) are missing.
#'   \item `files_df` is missing required columns or is empty.
#'   \item No sample data files are found under `Sample_Data`.
#'   \item Field Metadata file is missing or lacks `Parent_ID`.
#'   \item Any sample data file lacks `Sample_Name`.
#'   \item IGSN mapping file is missing OR not found in `tabular_data` OR lacks `Sample_Name`.
#' }
#'
#' @section CLI Output:
#' Uses the `cli` package for:
#' \itemize{
#'   \item Progress updates when multiple files are processed.
#'   \item Informational messages per file.
#'   \item Danger alerts summarizing any validation class that failed (replicates, metadata coverage, duplicates, FTICR, IGSN).
#' }
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' results <- check_sample_numbers(my_data_package)
#'
#' # Exclude QC and blank samples from metadata presence checks
#' results <- check_sample_numbers(
#'   my_data_package,
#'   pattern_to_exclude_from_metadata_check = c("_QC", "_BLK")
#' )
#'
#' # Inspect file-level summary
#' View(results$full_summary)
#'
#' # Drill into a specific sample data file
#' View(results$summary_by_file$"my_sample_file.csv")
#'
#' # Inspect required IGSN mapping summary
#' View(results$summary_by_file$"IGSN-Mapping.csv")
#'
#' # If FTICR folder present
#' View(results$summary_by_file$"FTICR Folder")
#' }
#'
#' @author Brieanne Forbes
#' @export

check_sample_numbers <- function(data_package_data,
                                 pattern_to_exclude_from_metadata_check = NULL){
  
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
  
  # Check if igsn file exists in tabular_data
  igsn_file_path <- files_df %>%
    filter(str_detect(file, "IGSN-Mapping")) %>%
    pull(all)
  
  has_igsn_file <- length(igsn_file_path) == 1
  
  if (has_igsn_file && !igsn_file_path %in% names(data_package_data$tabular_data)) {
    cli_abort("IGSN file '{igsn_file_path}' not found in tabular_data")
  }
  
  # Check if metadata has required columns
  metadata <- data_package_data$tabular_data[[metadata_file_path]]
  if (!"Parent_ID" %in% names(metadata)) {
    cli_abort("Metadata file must contain 'Parent_ID' column")
  }
  
  # Check if igsn has required columns
    igsn_df <- data_package_data$tabular_data[[igsn_file_path]]
    if (!"Sample_Name" %in% names(igsn_df)) {
      cli_abort("IGSN file '{basename(igsn_file_path)}' must contain 'Sample_Name' column")
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
  
  # ---- Get file paths ----
  # Identify sample data files (excluding methods codes files)
  sample_file_paths <- data_package_data$inputs$files_df %>%
    filter(str_detect(relative_dir, "Sample_Data$")) %>% # pull data from sample data folder, not recursive (so that it doesnt look into ICR folder)
    filter(!str_detect(file, "Methods_Codes")) %>% # filter out methods code file since it doesnt have sample IDs
    pull(all)
  
  # Check if FTICR files are present in the package
  has_icr_files <- data_package_data$inputs$files_df %>%
    filter(str_detect(relative_dir, "/FTICR/")) %>% # pull all files within the ICR folder
    pull(all) %>%
    length() > 1
  
  # Get path to field metadata file
  metadata_file_path <- data_package_data$inputs$files_df %>%
    filter(str_detect(file, "Field_Metadata")) %>% # pull metadata file
    pull(all)
  
  # Get path to IGSN metadata file
  igsn_file_path <- data_package_data$inputs$files_df %>%
    filter(str_detect(file, "IGSN-Mapping")) %>% # pull IGSN file
    pull(all)
  
  # ---- Read metadata ---- 
  # Load metadata and prepare for joining with sample data
  metadata <- data_package_data[["tabular_data"]][[metadata_file_path]] %>%
    select(Parent_ID) %>%
    mutate(metadata_parent_ID = Parent_ID)
  
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
  # Show progress bar only for multiple files to avoid clutter
  if (length(sample_file_paths) > 3) {
    pb <- cli_progress_bar("Processing files", total = length(sample_file_paths))
  }
  
  # Process each sample data file
  for (sample_file in sample_file_paths) {
    
    # Update progress bar if it exists  
    if (exists("pb")) {
      cli_progress_update(pb)
    }
    
    # Show processing status
    cli_alert_info("Processing file {match(sample_file, sample_file_paths)} of {length(sample_file_paths)}: {basename(sample_file)}")
    
    # Load and process sample data
    # Extract Parent_ID by removing various suffixes from Sample_Name
    data <- data_package_data[["tabular_data"]][[sample_file]] %>%
      mutate(Parent_ID_step1 = str_remove(Sample_Name, "_r\\d+$"), # remove ICR replicate suffix (_r1, _r2, etc.)
             Parent_ID_step2 = str_remove(Parent_ID_step1, "-\\d+$"), # remove numeric suffix (-1, -2, etc.)
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
    data_summary <- sample_summary %>%
      full_join(metadata, by = 'Parent_ID') %>%
      mutate(expected_number_of_reps = mode_rep_count,
             number_reps_match_expected = rep_count_per_parent_id == mode_rep_count,
             has_metadata = case_when(
               str_detect(Sample_Name, exclude_pattern) ~ NA, # excluded samples
               is.na(metadata_parent_ID) ~ FALSE, # no metadata found
               TRUE ~ TRUE # has metadata
             ),
             duplicate = case_when(sample_count == 1 ~ FALSE,
                                   TRUE ~ TRUE),
             metadata_ParentID_missing_from_data = case_when(is.na(Sample_Name) ~ TRUE,
                                                             TRUE ~ FALSE))
    
    # Add file-level summary to results
    full_summary <- full_summary %>%
      add_row(file = basename(sample_file),
              expected_number_of_reps = mode_rep_count,
              all_sample_number_reps_match_expected = case_when(any(FALSE %in% data_summary$number_reps_match_expected) == TRUE ~ FALSE,
                                                                TRUE ~ TRUE),
              all_samples_have_metadata = case_when(any(FALSE %in% data_summary$has_metadata) == TRUE ~ FALSE,
                                                    TRUE ~ TRUE),
              metadata_ParentID_missing_from_data = case_when(any(TRUE %in% data_summary$metadata_ParentID_missing_from_data) ~ TRUE,
                                                              TRUE ~ FALSE),
              has_duplicate_sample = case_when(any(TRUE %in% data_summary$duplicate) == TRUE ~ TRUE,
                                               TRUE ~ FALSE))
    
    # Store results in output list
    output_list[['full_summary']] <- full_summary
    output_list[['summary_by_file']][[basename(sample_file)]] <- data_summary %>%
      select(Sample_Name, Parent_ID, expected_number_of_reps, number_reps_match_expected, has_metadata,metadata_ParentID_missing_from_data, duplicate)%>%
      # Add optimal values reference row at the top
      add_row(
        Sample_Name = "** EXPECTED VALUES **",
        Parent_ID = "** EXPECTED VALUES **", 
        expected_number_of_reps = NA,
        number_reps_match_expected = TRUE,
        has_metadata = TRUE,
        duplicate = FALSE,
        .before = 1  # Adds the row at the top
      )
    
  }
  
  # Complete progress bar if it exists
  if (exists("pb")) {
    cli_progress_done(pb)
  }
  
  # ---- Process IGSN ----
  
  igsn_summary <- data_package_data[["tabular_data"]][[igsn_file_path]] %>%
    select(Sample_Name) %>%
    mutate(Parent_ID = str_remove(Sample_Name, '_RNA|_Sediment|_Water'),
            igsn_parent_ID = Parent_ID) %>%
    select(-Sample_Name) %>%
    full_join(metadata) %>%
    mutate(has_metadata = case_when(
             is.na(metadata_parent_ID) ~ FALSE, # no metadata found
             TRUE ~ TRUE # has metadata
           ),
           metadata_ParentID_missing_from_data = case_when(
             is.na(igsn_parent_ID) ~ TRUE, # no metadata found
             TRUE ~ FALSE # has metadata
           ))%>%
    select(-igsn_parent_ID, -metadata_parent_ID)
  
  # Store results in output list
  output_list[['full_summary']] <- output_list[['full_summary']] %>%
    add_row(file = basename(igsn_file_path),
            expected_number_of_reps = NA,
            all_sample_number_reps_match_expected = NA,
            
            all_samples_have_metadata = case_when(any(FALSE %in% igsn_summary$has_metadata) == TRUE ~ FALSE,
                                                  TRUE ~ TRUE),
            metadata_ParentID_missing_from_data = case_when(any(TRUE %in% igsn_summary$metadata_ParentID_missing_from_data) ~ TRUE,
                                                            TRUE ~ FALSE),
            has_duplicate_sample = NA,
            all_samples_in_icr_methods = NA,
            all_samples_in_icr_folder = NA)
  
  output_list[['summary_by_file']][[basename(igsn_file_path)]] <- igsn_summary %>%
    # Add optimal values reference row at the top
    add_row(
      Parent_ID = "** EXPECTED VALUES **", 
      has_metadata = TRUE,
      metadata_ParentID_missing_from_data = FALSE,
      .before = 1  # Adds the row at the top
    )
  
  # ---- Process FTICR files if present ----
  if(has_icr_files == T){
    
    cli_alert_info("Processing FTICR files")
    
    # Load FTICR methods file and get samples that have FTICR data
    icr_methods_file <- data_package_data$tabular_data[[
      names(data_package_data$tabular_data)[grepl("FTICR_Methods\\.csv", names(data_package_data$tabular_data))][1]
    ]] %>%
      filter(`FTICR-MS` != '-9999') %>%
      select(Sample_Name)%>%
      mutate(Methods_Sample_Name = Sample_Name)
    
    # Check XML files in FTICR folder
    xml_files <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, 'xml')) %>% # pull all XML files within the ICR folder
      pull(file) %>%
      tibble(xml = .) %>%
      mutate(Sample_Name = str_remove(xml, "_p\\d+\\.xml$"), # extract sample name from XML filename
             XML_Sample_Name = Sample_Name) %>%
      select(-xml)%>%
      full_join(icr_methods_file, by = 'Sample_Name')
    
    # Check processed ICR data file
    processed_file <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, 'CoreMS_Processed_ICR_Data.csv')) %>%
      pull(all) %>%
      data_package_data[["tabular_data"]][[.]] %>%
      select(-Calibrated_Mass) %>%
      colnames() %>%
      tibble(Sample_Name = .) %>%
      mutate(Processed_Sample_Name = Sample_Name)%>%
      full_join(icr_methods_file, by = 'Sample_Name')
    
    # Check CoreMS output files
    outputs_files <- data_package_data$inputs$files_df %>%
      filter(str_detect(relative_dir, "/FTICR"),
             str_detect(file, '.corems.csv')) %>%
      pull(file) %>%
      tibble(output = .) %>%
      mutate(Sample_Name = str_remove(output, "_p\\d+\\.corems.csv$"), # extract sample name from output filename
             Outputs_Sample_Name = Sample_Name) %>%
      select(-output)%>%
      full_join(icr_methods_file, by = 'Sample_Name')
    
    # Combine all FTICR checks
    icr_check <- icr_methods_file %>%
      full_join(xml_files, by = c('Sample_Name', 'Methods_Sample_Name'))%>%
      full_join(processed_file, by = c('Sample_Name', 'Methods_Sample_Name'))%>%
      full_join(outputs_files, by = c('Sample_Name', 'Methods_Sample_Name'))
    
    # Add FTICR results to output summary
    output_list[['full_summary']] <- output_list[['full_summary']]  %>%  
      add_row(
        file = 'xml files', 
        expected_number_of_reps = NA, 
        all_sample_number_reps_match_expected = NA,  
        all_samples_have_metadata = NA,  
        all_samples_in_icr_methods = !any(is.na(xml_files$Methods_Sample_Name))
      ) %>%
      add_row(
        file = 'processed icr', 
        expected_number_of_reps = NA, 
        all_sample_number_reps_match_expected = NA, 
        all_samples_have_metadata = NA, 
        all_samples_in_icr_methods = !any(is.na(processed_file$Methods_Sample_Name))
      ) %>%
      add_row(
        file = 'icr outputs', 
        expected_number_of_reps = NA, 
        all_sample_number_reps_match_expected = NA, 
        all_samples_have_metadata = NA, 
        all_samples_in_icr_methods = !any(is.na(outputs_files$Methods_Sample_Name))
      ) %>%
      mutate(all_samples_in_icr_folder = case_when(str_detect(file, 'FTICR_Methods') & any(is.na(icr_check$Methods_Sample_Name)) ~ FALSE,
                                                   str_detect(file, 'FTICR_Methods') & !any(is.na(icr_check$Methods_Sample_Name)) ~ TRUE,
                                                   TRUE ~ NA))
    
    # Store FTICR detailed results
    output_list[['summary_by_file']][['FTICR Folder']] <- icr_check
    
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
