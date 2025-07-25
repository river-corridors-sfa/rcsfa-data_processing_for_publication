# ==============================================================================
#
# Functions for querying the dd database to populate dd skeleton
#
# Status: in progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 3 July 2025
#
# ==============================================================================


#   > need to set up way to start function back up with intermediate file 


# ==============================================================================

require(pacman)

p_load(tidyverse,
       rlog,
       cli,
       stringdist)

# ============== Define Inputs/Outputs/Assumptions =============================

# assumption: if the definition is empty but other columns have something, they are incorrect and will be over written
#             if definition matches, the other columns (unit, term type, data type) also match

# =================== DELETE AFTER TESTING ===============================

dd_database_abs_path <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/data_dictionary_database.csv"

dd_skeleton <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/Test_Data_Package/Test_Data_Package/Test_dd.csv")

populated_dd <- query_dd_database(dd_database_abs_path, dd_skeleton)
  
# =================== query_dd_database function ===============================
query_dd_database <- function(dd_database_abs_path, dd_skeleton){
  log_info("Reading in and validating files.")
  # read in database
  dd_database <- read_csv(dd_database_abs_path, col_names = T, show_col_types = F, col_types = "icccccDcc") # the col types argument tells the function what col types (chr, int, date) to use
  backup_file_name <- paste0(dirname(dd_database_abs_path), '/dd_populate_temporary_backup.rds')
  
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
  
  # Process matches (both fuzzy and exact)
  process_matches <- function(matches, current_header, match_type) {
    if (nrow(matches) == 0) {
      log_info(paste0("No ", match_type, " match found for '", current_header, "'"))
      return(NULL)
    }
    
    log_info(paste0("The header '", current_header, "' ", 
                    if(match_type == "fuzzy") "is not in the data dictionary database. Trying a fuzzy match." 
                    else "was found in the data dictionary database."))
    print(matches)
    
    user_choice <- get_validated_numeric_input(
      "Do any of these column definitions apply? If so, indicate the row. If none match, write '0': ",
      nrow(matches)
    )
    
    if (user_choice == 0) {
      log_info(paste0("Did not find a suitable definition in the database for header '", current_header, "'"))
      return(NULL)
    }
    
    log_info("Adding selected definition to the dd")
    return(matches %>% 
             slice(user_choice) %>% 
             select(Unit, Definition, Data_Type, Term_Type))
  }
  
  ## =================== Validate inputs ===================
  # This chunk validates the input arguments.
  # It makes sure the database has cols: index, Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, date_published, dd_filename, dd_source
  # It makes sure the dd has cols: Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, date_published, dd_filename, dd_source
  # confirm dd_database has correct cols
  database_required_cols <- c("index", "Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type", "date_published", "dd_filename", "dd_source")
  if (!all(database_required_cols %in% names(dd_database))) {
    # if files_df is missing required cols, error
    log_error(paste0("dd database is missing required column: ", setdiff(database_required_cols, names(dd_database))))
    stop("query_dd_database() function terminating")
  } # end of checking dd database required cols
  # confirm dd has the correct cols
  dd_cols <- c("Column_or_Row_Name", "Unit", "Definition", "Data_Type", "Term_Type")
  if (!all(dd_cols %in% names(dd_skeleton))) {
    # if files_df is missing required cols, error
    log_error(paste0("dd is missing required column: ", setdiff(dd_cols, names(dd_skeleton))))
    stop("query_dd_database() function terminating")
  } # end of checking dd  required cols
  
  ## =================== condense database ============================
  log_info("Condensing database")
  dd_database_condensed <- dd_database %>%
    group_by(Column_or_Row_Name,Unit, Definition, Data_Type, Term_Type) %>%
    summarise(latest_date_published = max(date_published, na.rm = TRUE),
              dd_filename = paste(unique(dd_filename), collapse = ", "), .groups = "drop")
  
  ## =================== Initialize populated dd ============================
  # add flag column
  dd_skeleton <- dd_skeleton %>%
    add_column(flag = FALSE)
  
  ## ================= Initialize fuzzy match function ==========================
  find_fuzzy_matches <- function(current_header, dd_database_condensed, max_distance = 2, min_similarity = 0.69, method = "jw") {
    dd_database_fuzzy <- dd_database_condensed %>%
      mutate(
        string_distance = stringdist(Column_or_Row_Name, current_header, method = method),
        similarity_score = if (method == "jw") 1 - string_distance else 1 - (string_distance / max(nchar(Column_or_Row_Name), nchar(current_header)))
      ) %>%
      filter(similarity_score >= min_similarity) %>%
      arrange(desc(similarity_score), Column_or_Row_Name, desc(latest_date_published)) %>%
      head(10)
    return(dd_database_fuzzy)
  }
  
  ## =================== look at existing definitions ==================
  log_info("Showing populated rows. Read through the definitions and units. ")
  view(dd_skeleton %>% filter(!is.na(Definition)))
  
  flag_existing <- get_validated_yn_input("Do you want to flag any rows to come back to later? (enter Y/N) ")
  
  if(flag_existing){
    print(dd_skeleton %>% filter(!is.na(Definition)) %>% pull(Column_or_Row_Name))
    user_input2 <- readline(prompt = "Provide a comma seperated list of the column names you would like to flag:  ")
    dd_skeleton <- dd_skeleton %>%
      mutate(flag = case_when(str_detect(user_input2, Column_or_Row_Name) ~ T,
                              TRUE ~ FALSE))
    write_rds(dd_skeleton, backup_file_name)
    
    log_info("Back up created.")
  }
  
  ## =================== loop through and populate ==================
  for (i in 1:nrow(dd_skeleton)) {
    log_info(paste0("Querying skeleton dd row ", i, " of ", nrow(dd_skeleton), "."))
    # extract current row
    current_row <- dd_skeleton %>%
      slice(i)
    
    if(!is.na(current_row$Definition)){ # if definition is populated, do nothing
      populated_row <- current_row
    } else{ # if definition is NA, query the database
      # extract current header
      current_header <- current_row %>%
        pull(Column_or_Row_Name)
      
      database_filter_current_header <- dd_database_condensed %>%
        filter(Column_or_Row_Name %in% current_header) %>%
        arrange(desc(latest_date_published))
      
      # Try exact match first
      selected_definition <- process_matches(database_filter_current_header, current_header, "exact")
      
      # If no exact match, try fuzzy match
      if (is.null(selected_definition)) {
        database_filter_current_header_fuzzy <- find_fuzzy_matches(current_header, dd_database_condensed)
        selected_definition <- process_matches(database_filter_current_header_fuzzy, current_header, "fuzzy")
      }
      
      # Create populated row based on whether definition was found
      if (is.null(selected_definition)) {
        populated_row <- current_row
      } else {
        # Handle Missing_Value_Code more explicitly
        missing_code <- if(length(unique(dd_skeleton$Missing_Value_Code)) == 1) {
          unique(dd_skeleton$Missing_Value_Code)
        } else {
          NA
        }
        
        populated_row <- selected_definition %>%
          add_column(Column_or_Row_Name = current_header, .before = 'Unit') %>%
          add_column(Missing_Value_Code = missing_code)
      }
      
      # Ask about flagging
      flag_row <- get_validated_yn_input("Do you want to flag this row to come back to later? (enter Y/N) ")
      
      populated_row <- populated_row %>%
        mutate(flag = flag_row)
      
    } # end of if definition is NA
    
    if(i == 1){ # create dd_populated if first row, otherwise append to existing dd_populated
      dd_populated <- populated_row
    } else{
      dd_populated <- dd_populated %>%
        add_row(populated_row)
    }
    write_rds(dd_populated, backup_file_name)
    log_info("Back up created.")
  } # end of loop for each column
  
  log_info("Deleting backup rds file.")
  file_delete(backup_file_name)
  log_info("query_dd_database function complete")
  cli_alert_warning("Reminder to review the rows that have TRUE in the flag column and then remove the flag column. ")
  
  # Return the populated data dictionary
  return(dd_populated)
} # end of function
