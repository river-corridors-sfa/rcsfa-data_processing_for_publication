### annotate_dd_database.R #####################################################
# Date Created: 2024-05-03
# Date Updated: 2024-05-21
# Author: Bibi Powers-McCormack

# Objective for annotate_dd_database_status(): 
  # return sorted list of results that shows which headers still need ddd annotations
  # filters for unevaluated (archive = NA) headers and sorts based on how many times that column was used in a data package.

# Objective for annotate_dd_database(): 
  # Read in dd database
  # Filter for dd_database_archive is NA
  # Group by header, unit, and definition
  # Assign IDs
  # For each ID
    # Show each row of same header name
    # Ask user if archive should be T, F, or NA (0)
    # If T, prompt with dd_database_note to leave comment with reasoning
    # Add that result to all rows that match that ID


### FUNCTION ###################################################################

annotate_dd_database_status <- function(number_of_results) {
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(knitr) # for kable()
  
  # load data
  source_ddd <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", show_col_types = F)
  
  # filter ddd
  filter_ddd <- source_ddd %>% 
    
    # filter for rows where dd_database_archive is NA
    filter(is.na(dd_database_archive)) %>% 
    
    # select only dd cols
    select(Column_or_Row_Name, Unit, Definition) %>% 
    
    # group by dd cols
    group_by(Column_or_Row_Name, Unit, Definition) %>% 
    
    # sort cols by headers that are referenced most often at the top
    summarise(count = n()) %>% # get count of how many times that header is in the database
    ungroup() %>% 
    distinct() %>% 
    select(count, Column_or_Row_Name) %>% 
    arrange(desc(count)) # sort by count with highest appearances at top
    
  # return table of results
  top_results <- filter_ddd %>% 
    head(number_of_results) %>% 
    kable(.)
  
  log_info(paste0("Showing top ", number_of_results, " results."))
  
  return(top_results)
  
}


### FUNCTION ###################################################################

annotate_dd_database <- function(num_headers_to_assess) {
  
  ### Prep script ################################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  
  # load ddd
  source_ddd <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", show_col_types = F)
  
  # filter ddd
  filter_ddd <- source_ddd %>% 
    
    # filter for rows where dd_database_archive is NA
    filter(is.na(dd_database_archive)) %>% 
    
    # select only dd cols
    select(Column_or_Row_Name, Unit, Definition) %>% 
    
    # group by dd cols
    group_by(Column_or_Row_Name, Unit, Definition) %>% 
    
    # sort cols by headers that are referenced most often at the top
    summarise(count = n()) %>% # get count of how many times that header is in the database
    distinct() %>% 
    arrange(desc(count)) %>% # sort by count with highest appearances at top
    select(-count) %>% 
    
    # filter for top X number (based on function input)
    head(num_headers_to_assess) %>% 
    
    # # add unique ID
    rownames_to_column(., "filter_id") %>% 
    ungroup()
  
  log_info(paste0("Headers: ", filter_ddd %>% select(Column_or_Row_Name) %>% c()))
  
  # initialize populate ddd to be later edited
  annotated_ddd <- source_ddd %>% 
    left_join(filter_ddd, by = c("Column_or_Row_Name", "Unit", "Definition")) # match up and add the filter_id to the ddd
    
  # for each row in the filtered df...
    for (i in 1:nrow(filter_ddd)) {
      
      
      # extract variables
      current_row <- filter_ddd %>%
        slice(i) # get row
      
      current_filter_id <- current_row %>% 
        select(filter_id) %>% 
        pull() # get filter_id
      
      current_header <- current_row %>%
        select(Column_or_Row_Name) %>%
        pull() # get header
      
      current_unit <- current_row %>% 
        select(Unit) %>% 
        pull() # get unit
      
      current_definition <- current_row %>% 
        select(Definition) %>% 
        pull() # get definition
      
      log_info(paste0("Presenting header ", i, " of ", nrow(filter_ddd), ": ", current_header))
      
      # search the ddd for all of the same header
      current_decision <- source_ddd %>% 
        filter(Column_or_Row_Name == current_header) %>% 
        
        # collapse identical rows
        group_by(Column_or_Row_Name, Unit, Definition) %>% 
        summarise(file_count = n(),
                  files = toString(dd_filename)) %>% 
        
        # make current row that's being evaluated in all caps
        mutate(files = case_when(Unit == current_unit & Definition == current_definition ~ toupper(files), 
                                 TRUE ~ files), 
               Column_or_Row_Name = case_when(Unit == current_unit & Definition == current_definition ~ toupper(Column_or_Row_Name), 
                                              TRUE ~ Column_or_Row_Name)) %>% 
        ungroup() %>% 
        arrange((files))
      
      # show options
      log_info("Showing all unique definitions that match the given header.")
      View(current_decision)
      
      # ask user if they want to archive the current row
      user_input <- readline(prompt = "Do you want to archive the header/unit/definition in ALL CAPS? (Y/N) ")
      
      # if yes...
      if (tolower(user_input) == "y") {
        
        user_input_reason <- readline(prompt = "Rationale for archiving: ")
        
        # update ddd
        annotated_ddd <- annotated_ddd %>% 
          
          # when the filter_id matches, then assign "TRUE" to the dd_database_archive column to indicate that those rows should be archived
          mutate(dd_database_archive = case_when(filter_id == current_filter_id ~ T, 
                                                 TRUE ~ dd_database_archive),
                 # when the filter_id matches, then add the rationale to the notes column for cols that are going to be archived
                 dd_database_notes = case_when(filter_id == current_filter_id ~ 
                                                 # if the notes is empty, put rationale. If it's not empty, append rationale to existing note
                                                 ifelse(is.na(dd_database_notes) | dd_database_notes == "", user_input_reason, paste0(dd_database_notes, "; ", user_input_reason)), 
                                               TRUE ~ dd_database_notes)) # if no rationale, then keep old notes
        
      } else if (tolower(user_input == "n")) {
        
        # else if no...
        user_input_reason <- readline(prompt = "Optional Note: ")
        
        # update ddd
        annotated_ddd <- annotated_ddd %>% 
          
          # when the filter_id matches, then assign "FALSE" to the dd_database_archive column to indicate that those rows should be NOT be archived
          mutate(dd_database_archive = case_when(filter_id == current_filter_id ~ F, 
                                                 TRUE ~ dd_database_archive))
        
        # if the optional note is NOT empty...
        if (user_input_reason != "") {
          
          # add note to ddd
          annotated_ddd <- annotated_ddd %>% 
            mutate(dd_database_notes = case_when(filter_id == current_filter_id ~ # when the filter_id matches, then add the optional note to the notes column
                                                 # if the ddd note is empty, put note. If it's not empty, append note to existing note
                                                 ifelse(is.na(dd_database_notes) | dd_database_notes == "", user_input_reason, paste0(dd_database_notes, "; ", user_input_reason)), 
                                               TRUE ~ dd_database_notes)) # if no note, then keep old notes
        } # closes adding note
      } # closes user_input if
    } # closes for loop
  
  # clean up df
  annotated_ddd <- annotated_ddd %>% 
    select(-filter_id)
  
  # ask if ready to export
  user_prompt_export <- readline("Ready to export annotated dd database? (Y/N) ")
  
  if (tolower(user_prompt_export) == "y") {
    
  # export annotated ddd
  write_csv(annotated_ddd, "./Data_Package_Documentation/database/data_dictionary_database.csv", na = "")
    
  } else{
    
    log_warn("Annotated dd database NOT exporting.")
  }
  
  log_info("annotate_dd_database.R complete")
  
}


