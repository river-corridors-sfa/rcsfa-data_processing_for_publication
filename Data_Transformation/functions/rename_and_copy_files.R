### rename_and_copy_files.R ####################################################
# Date Created: 2024-11-25
# Date Updated: 2024-11-25
# Author: Bibi Powers-McCormack

rename_and_copy_files <- function(lookup_df) {
  # This function takes a lookup df as input and renames and copies files to a new location
  
  # Input:
  # - The lookup df requires 2 columns:
  #   - `source`: Absolute file paths of the original files
  #   - `destination`: Absolute file paths including the renamed file and its new location
  
  # Output:
  # - Files renamed and copied to the new locations as specified in `destination`
  
  # Assumptions:
  # - The destination directories don't need to be created in advance
  #   (the function will create them if they don't exist)
  # - The function won't overwrite existing files in the destination
  
  # Example:
  # example_lookup <- tibble(
  #   source = c("C:/Users/username/Downloads/fileA.txt", "C:/Users/username/Downloads/fileB.csv"),
  #   destination = c("C:/Users/username/Documents/new_fileA.txt", "C:/Users/username/Documents/new_fileB.csv")
  # )
  # rename_and_copy_files(example_lookup)
  
  
  ### Prep script ##############################################################
  
  # Load required libraries
  library(tidyverse)
  library(fs)
  
  # Validate input
  if (!all(c("source", "destination") %in% colnames(lookup_df))) {
    stop("The lookup dataframe must have 'source' and 'destination' columns.")
  }
  
  # Iterate over each row to copy files
  results <- lookup_df %>%
    rowwise() %>%
    mutate(
      status = tryCatch({
        # Ensure the destination directory exists
        dir_create(path_dir(destination))
        
        # Copy file if it does not already exist at destination
        if (!file_exists(destination)) {
          file_copy(source, destination)
          "success"
        } else {
          "already exists"
        }
      }, error = function(e) {
        paste("error:", e$message)
      })
    ) %>%
    ungroup()
  
  # Report summary and return results
  message(paste(sum(results$status == "success"), "files copied successfully."))
  message(paste(sum(results$status == "already exists"), "files already existed and were not overwritten."))
  if (any(grepl("error:", results$status))) {
    message("Some errors occurred during the operation.")
  }
  
  return(results)
}

