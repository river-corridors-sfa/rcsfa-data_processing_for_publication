### rename_and_copy_folders.R ##################################################
# Date Created: 2024-10-29
# Date Updated: 2024-10-29
# Author: Bibi Powers-McCormack

rename_and_copy_folders <- function(lookup_df) {
  # this function takes a lookup df as input and then renames and copies folders to a new location
  
  # Input:
    # the lookup df requires 2 cols: 
      # source_folder = the absolute folder path of the original location
      # destination_folder = the absolute folder path of the renamed folder and its new location
  
  # Output: 
    # folders and their sub-folders renamed and copied to the new location
  
  # Assumptions: 
  
  
  # Example: 
  
  
  ### Prep script ##############################################################
  
  library(tidyverse)
  library(fs)
  library(rlog)
  
  ### Check input ##############################################################
  
  # confirm required col headers are present
  if (all(c("source", "destination") %in% colnames(lookup_df))) {
    
    lookup_df <- lookup_df %>% 
      select(source, destination)
    
  } else {
    
    log_error("Function stopping.")
    stop("ERROR. Your lookup df does not include the correct column names. The input requires c(`source`, `destination`).")
    
  }
  
  
  ### Copy and rename folders ##################################################
  lookup_df %>% 
    rowwise() %>% 
    mutate(success = dir_copy(source, destination, overwrite = TRUE))
  
  log_info(paste0("Opening parent directory: ", path_common(lookup_df$destination)))
  shell.exec(path_common(lookup_df$destination))
  
  log_info("`rename_and_copy_folders()` complete")
  
  return()
  
}
