### check_tabular_data_structure.R #############################################


# Assuming your list of data frames is named 'list_of_dfs'
list_of_dfs <- data_package_data$data  # Replace with your actual list of data frames

# Initialize an empty data frame to store the summary
summary_df <- data.frame(
  file_name = character(),
  file_path = character(),
  character = logical(),
  numeric = logical(),
  date = logical(),
  datetime = logical(),
  logical = logical(),
  stringsAsFactors = FALSE
)

# Iterate through each data frame in the list
for (i in seq_along(list_of_dfs)) {
  current_df <- list_of_dfs[[i]]
  
  # Extract structure types
  structure_types <- sapply(current_df, class)
  
  # Create a row for the summary data frame
  summary_row <- data.frame(
    file_name = basename(names(list_of_dfs)[i]),
    file_path = names(list_of_dfs)[i],
    character = any(structure_types == "character"),
    numeric = any(structure_types %in% c("numeric", "integer")),
    date = any(structure_types %in% c("Date", "POSIXct")),
    datetime = any(structure_types == "POSIXct"),
    logical = any(structure_types == "logical")
  )
  
  # Append the summary row to the summary data frame
  summary_df <- summary_df %>% 
    rbind(., summary_row)
}

# Print the summary data frame with column names
print(summary_df)
