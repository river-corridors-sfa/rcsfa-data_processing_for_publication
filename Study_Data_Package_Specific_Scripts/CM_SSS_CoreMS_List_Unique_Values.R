library(tidyverse)
library(fs)

# Define the specific columns you want to analyze
target_columns <- c("13C", "15N", "17O", "18O", "33S", "34S")

# Get list of CSV files in your directory
csv_files <- c(dir_ls(path = "C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/PRELIMINARY_Core-MS_Processed_ICR_Legacy_Data/CM_SSS_CoreMS", glob = "*.corems.csv"))

# Function to process each file
process_file <- function(file_path) {
  # Read the CSV file
  data <- read_csv(file_path, show_col_types = FALSE,
                   col_types = cols(
                     `13C` = col_double(),
                     `15N` = col_double(),
                     `17O` = col_double(),
                     `18O` = col_double(),
                     `33S` = col_double(),
                     `34S` = col_double(),
                     .default = col_guess()
                   ))
  
  # Get filename without path and extension
  filename <- path_ext_remove(path_file(file_path))
  
  # Find which target columns exist in this file
  existing_columns <- intersect(names(data), target_columns)
  
  # If no target columns exist, return empty tibble
  if (length(existing_columns) == 0) {
    return(tibble(filename = character(), column_name = character(), unique_values = character()))
  }
  
  # Process each existing target column
  results <- map_dfr(existing_columns, function(col) {
    unique_vals <- data %>%
      select(all_of(col)) %>%
      distinct() %>%
      pull() %>%
      as.character() %>%
      paste(collapse = ", ")  # Collapse all unique values into one string
    
    tibble(
      filename = filename,
      column_name = col,
      unique_values = unique_vals  # Note: changed to plural
    )
  })
  
  return(results)
}

# Process all CSV files and combine results
final_result <- map_dfr(csv_files, process_file)

# View the result
print(final_result)