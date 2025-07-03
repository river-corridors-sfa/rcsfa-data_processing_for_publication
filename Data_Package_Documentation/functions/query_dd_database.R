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

# 3. iterate through each column name that doesnt have a definition
# > provide database entries for user  
# to choose from 
# 4. For remaining definitions where a direct match was not found, use a fuzzy join to see if there is a potential match
# > provide database entries for user  
# to choose from 
# > allows for skip, manual input, and quit
# > save RDS intermediate files with csv save at end
# - append instead of output a new file every time??
#   
#   
#   > need to set up way to start function back up with intermediate file 
# > is there a way to make a note to myself when noticing things I should go back to? 
#   > add a flag?
#   > option to select database definition but then edit 

# ==============================================================================

require(pacman)

p_load(tidyverse,
       rlog,
       cli)

# ============== Define Inputs/Outputs/Assumptions =============================

# asummption: if the definition is empty but other columns have something, they are incorrect and will be over written

# =================== DELETE AFTER TESTING ===============================

dd_database_abs_path <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/data_dictionary_database.csv"

dd_skeleton <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/Test_Data_Package/Test_Data_Package/Test_dd.csv")
  
# =================== query_dd_database function ===============================

query_dd_database <- function(dd_database_abs_path, dd_skeleton){
  
  log_info("Reading in and validating files.")
  
  # read in database
  dd_database <- read_csv(dd_database_abs_path, col_names = T, show_col_types = F, col_types = "icccccDcc") # the col types argument tells the function what col types (chr, int, date) to use
  
  intermediate_file_name <- paste0(dirname(dd_database_abs_path), '/dd_populate_interim_temp.rds')
  
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
  
  ## =================== Initilize populated dd ============================
  
  log_info("Initilizing populated dd")
  
  dd_populated <- dd_skeleton %>%
    add_column(flag = NA)
  
  
  ## =================== look at existing definitions ==================
  
  log_info("Showing populated rows. Read through the definitions and units. ")
  
  view(dd_skeleton %>% filter(!is.na(Definition)))
  
  user_input1 <- readline(prompt = "Do you want to flag any to come back to later? (enter Y/N) ")
  
  if(tolower(user_input1) == "y"){
    
    dd_skeleton %>% filter(!is.na(Definition)) %>% pull(Column_or_Row_Name)
    
    user_input2 <- readline(prompt = "Provide a comma seperated list of the column names you would like to flag:  ")
    
    dd_populated <- dd_populated %>%
      mutate(flag = case_when(str_detect(user_input2, Column_or_Row_Name) ~ T,
                              TRUE ~ flag))
    
    write_rds(dd_populated, intermediate_file_name)
    
  } 
  
  ## =================== loop through and populate ==================
  
  for (i in 1:nrow(dd_skeleton %>% filter(is.na(Definition)))) {
    
    # START HERE
    # issue: need to seperate existing definition df from populating df. it messes up count 
    
    log_info(paste0("Querying skeleton dd row ", i, " of ", nrow(dd_skeleton %>% filter(is.na(Definition))), "."))
    
    # extract current row
    current_row <- current_dd_skeleton %>% 
      slice(i)
    
    # extract current header
    current_header <- current_row %>% 
      pull(Column_or_Row_Name)
    
    
    
    write_rds(dd_populated, intermediate_file_name)
  }
  
  
  
  log_info("Deleting iterim rds file.")
  file_delete(intermediate_file_name)
  
  log_info("query_dd_database function complete")
  
  cli_alert_warning("Reminder to review the rows that have TRUE in the flag column and then remove the flag column. ")
}



