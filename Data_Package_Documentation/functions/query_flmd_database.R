# ==============================================================================
#
# Functions for querying the flmd database to populate flmd skeleton
#
# Status: in progress
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 31 July 2025
#
# ==============================================================================

require(pacman)

p_load(tidyverse,
       rlog,
       cli,
       stringdist,
       fs)

# ============== Define Inputs/Outputs/Assumptions =============================
# Purpose:
#       The purpose of this function is to query the flmd database to populate an
#       empty flmd (file level metadata). It will attempt to find matches using the 
#       File_Name field through fuzzy matching, as exact matches are unlikely due to
#       prefixes/suffixes in file names. This is an interactive function that requires 
#       user input for selecting descriptions.
#
# Inputs:
#     - flmd_database_abs_path: (character) Absolute file path to the flmd database CSV file
#     - flmd_skeleton: (data.frame) Empty file level metadata produced by file discovery function
#                      Must contain columns: File_Name, File_Description, Standard, Header_Rows, 
#                      Column_or_Row_Name_Position, File_Path
#
# Outputs:
#     - (data.frame) File level metadata with File_Description populated from the database 
#       if there was a match. Also includes a flag column where the user can indicate 
#       if they want to come back to it to review. In the flag column, TRUE indicates 
#       that the user flagged this row.
#
# Dependencies:
#     - Required packages: tidyverse, rlog, cli, stringdist, fs
#     - Database file must be readable CSV with columns: index, File_Name, File_Description, 
#       date_published, flmd_filename, flmd_source
#
# Interactive Elements:
#     - User will be prompted to select from matching file descriptions
#     - User can flag rows for later review
#     - User can choose to resume from backup if available
#     - Function displays progress and matching options during execution
#
# File Operations:
#     - Creates temporary backup file: '[database_directory]/flmd_populate_temporary_backup.rds'
#     - Backup is automatically deleted upon successful completion
#     - If function is interrupted, backup allows resuming from last position
#
# Error Handling:
#     - Validates required columns in both database and skeleton files
#     - Stops execution with descriptive error messages if validation fails
#     - Input validation for all user prompts
#
# Performance Notes:
#     - Processing time depends on skeleton size and number of matches found
#     - Fuzzy matching parameters: similarity threshold = 0.4 (lower due to prefixes), method = "jw"
#     - Maximum of 10 fuzzy matches displayed per query
#
# Assumptions:
#     - File names in the database may not exactly match skeleton file names due to prefixes
#     - Only File_Description will be populated from database - other columns remain unchanged
#     - Database file uses column types: "iccDcc" (integer, character, character, Date, character, character)
#     - Files with similar base names (e.g., "CM_Field_Metadata.csv" vs "Field_Metadata.csv") should match
#
# Examples:
#     # Basic usage
#     flmd_database_path <- "path/to/flmd_database.csv"
#     skeleton <- discover_files(data_directory)
#     populated_flmd <- query_flmd_database(flmd_database_path, skeleton)
#
#     # Save results
#     write_csv(populated_flmd, "populated_file_metadata.csv")
#
# Warnings:
#     - This function requires active user interaction and cannot run unattended
#     - File name matching relies on fuzzy algorithms - review matches carefully
#     - Always review flagged rows before finalizing the file metadata
#     - Remove the 'flag' column before publishing the final metadata

# =================== DELETE AFTER TESTING ===============================

flmd_database_abs_path <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/file_level_metadata_database.csv"

flmd_skeleton <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/Test_Data_Package/Test_Data_Package/Test_flmd.csv")

populated_flmd <- query_flmd_database(flmd_database_abs_path, flmd_skeleton)

# =================== query_flmd_database function ===============================
query_flmd_database <- function(flmd_database_abs_path, flmd_skeleton){
  
  ## =================== Helper Functions ===================
  # Validate numeric input from user
  get_validated_numeric_input <- function(prompt, max_value) {
    repeat {
      input <- readline(prompt = prompt)
      num_input <- suppressWarnings(as.numeric(input))
      if (!is.na(num_input) && num_input >= 0 && num_input <= max_value) {
        return(num_input)
      }
      cat("Please enter a valid number between 0 and", max_value, "\n")
    }
  }
  
  # Validate Y/N input from user
  get_validated_yn_input <- function(prompt) {
    repeat {
      input <- readline(prompt = prompt)
      if (tolower(input) %in% c("y", "n", "yes", "no")) {
        return(tolower(input) %in% c("y", "yes"))
      }
      cat("Please enter Y/N or Yes/No\n")
    }
  }
  
  # Process matches - only fuzzy matching for file names
  process_matches <- function(matches, current_filename) {
    if (nrow(matches) == 0) {
      cli_rule(left = "No fuzzy match found ", right = current_filename)
      return(NULL)
    }
    
    cli_rule(left = "Found potential matches", right = current_filename)
    print(matches %>% select(File_Name, File_Description, similarity_score))
    
    user_choice <- get_validated_numeric_input(
      "Do any of these file descriptions apply? If so, indicate the row. If none match, write '0': ",
      nrow(matches)
    )
    
    if (user_choice == 0) {
      log_info(paste0("Did not find a suitable description in the database for file '", current_filename, "'"))
      return(NULL)
    }
    
    log_info("Adding selected description to the flmd")
    return(matches %>%
             slice(user_choice) %>%
             select(File_Description))
  }
  
  log_info("Reading in and validating files.")
  # read in database - adjusted column types for flmd structure
  flmd_database <- read_csv(flmd_database_abs_path, col_names = T, show_col_types = F, col_types = "iccDcc")
  backup_file_name <- paste0(dirname(flmd_database_abs_path), '/flmd_populate_temporary_backup.rds')
  
  # Initialize use_backup variable
  use_backup <- FALSE
  
  # Check if backup file exists and ask user if they want to use it
  if (file.exists(backup_file_name)) {
    use_backup <- get_validated_yn_input("A backup file was found. Do you want to continue from where you left off? (Y/N): ")
    if (use_backup) {
      log_info("Loading from backup file.")
      flmd_skeleton <- read_rds(backup_file_name)
      log_info(paste0("Backup loaded. Progress: ", sum(!is.na(flmd_skeleton$File_Description)), " of ", nrow(flmd_skeleton), " files completed."))
    } else {
      log_info("Starting fresh - backup file will be overwritten.")
    }
  }
  
  ## =================== Validate inputs ===================
  # confirm flmd_database has correct cols
  database_required_cols <- c("index", "File_Name", "File_Description", "date_published", "flmd_filename", "flmd_source")
  if (!all(database_required_cols %in% names(flmd_database))) {
    log_error(paste0("flmd database is missing required column: ", setdiff(database_required_cols, names(flmd_database))))
    stop("query_flmd_database() function terminating")
  }
  
  # confirm flmd_skeleton has the correct cols
  flmd_cols <- c("File_Name", "File_Description", "Standard", "Header_Rows", "Column_or_Row_Name_Position", "File_Path")
  if (!all(flmd_cols %in% names(flmd_skeleton))) {
    log_error(paste0("flmd skeleton is missing required column: ", setdiff(flmd_cols, names(flmd_skeleton))))
    stop("query_flmd_database() function terminating")
  }
  
  ## =================== condense database ============================
  log_info("Condensing database")
  
  # Function to extract meaningful descriptive terms from filename
  extract_descriptive_terms <- function(filename) {
    # Remove file extension first
    base_name <- str_remove(filename, "\\.[^.]*$")
    
    # Split by underscores to get components
    components <- str_split(base_name, "_")[[1]]
    
    # Remove common prefixes and version indicators
    prefixes_to_remove <- c("v[0-9]+", "CM", "SSS", "WHONDRS", "AV1", "BSLE", "SPS", 
                            "RC2", "SSF", "STL", "WROL", "YDE21", "YDE22", "DBP", 
                            "EWEB", "EC", "S19S", "2022-2024", "2021-2022")
    
    # Remove date patterns (YYYY-MM-DD format)
    date_pattern <- "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
    
    # Remove numeric patterns and common prefixes
    descriptive_components <- components[!str_detect(components, paste0("^(", paste(prefixes_to_remove, collapse="|"), ")$")) &
                                           !str_detect(components, date_pattern) &
                                           !str_detect(components, "^[0-9]+$") &  # Remove pure numbers
                                           !str_detect(components, "^[A-Z]{1,3}$")]  # Remove short uppercase codes
    
    # Create descriptive key by combining remaining meaningful components
    if(length(descriptive_components) > 0) {
      # Sort components to normalize order (e.g., "Field_Metadata" = "Metadata_Field")
      descriptive_key <- paste(sort(descriptive_components), collapse = "_") %>%
        str_to_lower()
    } else {
      # Fallback to original filename if no meaningful components found
      descriptive_key <- str_to_lower(base_name)
    }
    
    return(descriptive_key)
  }

  flmd_database_condensed <- flmd_database %>%
    mutate(
      # Create descriptive key for grouping
      descriptive_key = map_chr(File_Name, extract_descriptive_terms),
      # Keep original for reference
      original_filename = File_Name
    ) %>%
    # Group by descriptive key and description to consolidate similar files
    group_by(descriptive_key, File_Description) %>%
    summarise(
      # Keep the most recent example filename
      example_filename = original_filename[which.max(date_published)],
      latest_date_published = max(date_published, na.rm = TRUE),
      flmd_filename = paste(unique(flmd_filename), collapse = ", "),
      # Keep track of all original filenames that were consolidated
      all_original_names = paste(unique(original_filename), collapse = "; "),
      # Count how many files were consolidated
      file_count = n(),
      .groups = "drop"
    ) %>%
    # Add back a File_Name column for compatibility
    mutate(File_Name = example_filename) %>%
    select(-example_filename)
  
  # Log consolidation results
  log_info(paste0("Database consolidated from ", nrow(flmd_database), " to ", 
                  nrow(flmd_database_condensed), " unique file patterns"))
  ## =================== Initialize populated flmd ============================
  # add flag column if it doesn't exist (in case we're starting fresh)
  if (!"flag" %in% names(flmd_skeleton)) {
    flmd_skeleton <- flmd_skeleton %>%
      add_column(flag = FALSE)
  }
  
  ## ================= Initialize fuzzy match function ==========================
  find_fuzzy_matches <- function(current_filename, flmd_database_condensed, min_similarity = 0.5, method = "jw") {
    
    # Extract descriptive terms from current filename
    current_descriptive_key <- extract_descriptive_terms(current_filename)
    
    log_info(paste0("Searching for descriptive pattern: '", current_descriptive_key, "' (from '", current_filename, "')"))
    
    flmd_database_fuzzy <- flmd_database_condensed %>%
      mutate(
        # Calculate similarity using the descriptive keys
        similarity_score = 1 - stringdist(descriptive_key, current_descriptive_key, method = method)
      ) %>%
      filter(similarity_score >= min_similarity) %>%
      arrange(desc(similarity_score), desc(latest_date_published)) %>%
      head(10) %>%
      # Show both the example filename and how many files it represents
      mutate(display_name = paste0(File_Name, " (represents ", file_count, " similar files)"))
    
    return(flmd_database_fuzzy)
  }
  ## =================== look at existing descriptions ==================
  # Only show this section if we're not resuming from backup or if user wants to review
  if (!file.exists(backup_file_name) || !use_backup) {
    log_info("Showing files with existing descriptions. Review the descriptions.")
    populated_files <- flmd_skeleton %>% filter(!is.na(File_Description))
    if (nrow(populated_files) > 0) {
      print(populated_files)
      flag_existing <- get_validated_yn_input("Do you want to flag any files to come back to later? (enter Y/N) ")
      if(flag_existing){
        print(populated_files %>% pull(File_Name))
        user_input2 <- readline(prompt = "Provide a comma separated list of the file names you would like to flag: ")
        flmd_skeleton <- flmd_skeleton %>%
          mutate(flag = case_when(str_detect(user_input2, File_Name) ~ TRUE,
                                  TRUE ~ FALSE))
        write_rds(flmd_skeleton, backup_file_name)
        log_info("Backup created.")
      }
    } else {
      log_info("No files have existing descriptions.")
    }
  }
  
  ## =================== loop through and populate ==================
  # Find the starting point (first row with NA File_Description, or 1 if starting fresh)
  start_row <- ifelse(use_backup,
                      min(which(is.na(flmd_skeleton$File_Description)), nrow(flmd_skeleton) + 1),
                      1)
  
  if (start_row > nrow(flmd_skeleton)) {
    log_info("All files already have descriptions!")
    cli_alert_warning("Reminder to review the files that have TRUE in the flag column and then remove the flag column.")
    return(flmd_skeleton)
  }
  
  flmd_populated <- flmd_skeleton  # Initialize with current state
  
  for (i in start_row:nrow(flmd_skeleton)) {
    log_info(paste0("Processing file ", i, " of ", nrow(flmd_skeleton), "."))
    
    # extract current row
    current_row <- flmd_skeleton %>%
      slice(i)
    
    if(!is.na(current_row$File_Description)){ # if description is populated, do nothing
      populated_row <- current_row
    } else{ # if description is NA, query the database
      # extract current filename
      current_filename <- current_row %>%
        pull(File_Name)
      
      log_info(paste0("Searching for matches for file: ", current_filename))
      
      # Use fuzzy matching (exact matches unlikely due to prefixes)
      flmd_database_fuzzy <- find_fuzzy_matches(current_filename, flmd_database_condensed)
      selected_description <- process_matches(flmd_database_fuzzy, current_filename)
      
      # Create populated row based on whether description was found
      if (is.null(selected_description)) {
        populated_row <- current_row
      } else {
        # Only update the File_Description, keep all other columns from original
        populated_row <- current_row %>%
          mutate(File_Description = selected_description$File_Description)
      }
      
      # Ask about flagging
      flag_file <- get_validated_yn_input("Do you want to flag this file to come back to later? (enter Y/N) ")
      populated_row <- populated_row %>%
        mutate(flag = flag_file)
    }
    
    # Update the row in flmd_populated
    flmd_populated[i, ] <- populated_row
    write_rds(flmd_populated, backup_file_name)
    log_info("Backup created.")
  }
  
  log_info("Deleting backup rds file.")
  file_delete(backup_file_name)
  log_info("query_flmd_database function complete")
  cli_alert_warning("Reminder to review the files that have TRUE in the flag column and then remove the flag column.")
  
  # Return the populated file metadata
  return(flmd_populated)
} # end of function
