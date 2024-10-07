# checks_range_report_debug.R ##################################################
# Date Created: 2024-10-07
# Date Updated: 2024-10-07
# Author: Bibi Powers-McCormack

# Objective: 
  # There seems to be an issue with the the loop only sometimes returning the number of negative rows


### Set up #####################################################################
test_directory <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/ECA_Data_Package/EC_Data_Package"

test_flmd <- paste0(test_directory, "/EC_flmd.csv")

test_data <- load_tabular_data_from_flmd(directory = test_directory,
                                         flmd_df = test_flmd)

data_package_data <- test_data

current_df <- data_package_data$tabular_data[[10]] # change this number to manually spot check different dfs

# initialize empty df for tabular data report
data_tabular_report <- tibble(
  file_name = as.character(),
  column_name = as.character(),
  column_type = as.character(),
  num_rows = as.numeric(),
  num_unique_rows = as.numeric(),
  num_missing_rows = as.numeric(),
  top_counts = as.character(),
  range_min = NA_character_,
  range_max = NA_character_,
  num_negative_rows = NA_real_
)

for (i in 1:length(data_package_data$tabular_data)) {
current_df <- data_package_data$tabular_data[[i]]

### CODE TO DEBUG ##############################################################

# loop through each column in the df
for (k in 1:length(current_df)) {
  
  # get current column
  current_column <- current_df[k]
  
  # get current column name
  current_column_name <- colnames(current_column)
  
  log_info(paste0("Column ", k, " of ", length(current_df), ": ", current_column_name))
  
  # convert to NA
  current_column <- current_column %>% 
    mutate(across(everything(), ~ replace(., . %in% input_parameters$missing_value_codes, NA)))
  
  # calculate number of total rows
  current_nrow <- current_column %>% 
    nrow()
  
  # calculate number of missing rows
  current_n_misisng <- current_column %>% 
    filter(is.na(current_column)) %>% 
    nrow()
  
  # calculate number of unique rows
  current_unique_rows <- current_column %>% 
    n_distinct()
  
  # calculate top counts
  current_top_counts <- current_column %>% 
    count(current_column[1], sort = T) %>% 
    drop_na() %>% 
    mutate(top_counts = paste0(!!sym(names(current_column)[1]), " (n=", n, ")")) %>% 
    head(5) %>%
    summarise(top_counts = str_c(top_counts, collapse = "  ---  ")) %>% 
    pull()
  
  # get column type
  current_column_type <- current_column %>% 
    pull(1) %>% 
    class() %>% 
    head(1)
  
  # set defaults
  current_min <- NA_character_
  current_max <- NA_character_
  current_n_negative <- NA_real_
  
  # if chr
  if (current_column_type == "character") {
    
    # check if col is mixed - separate out numeric vs chr rows
    current_mixed <- current_column %>% 
      mutate(
        numeric_col = case_when(grepl("^-?\\d+(\\.\\d+)?$", current_column[[1]]) ~ as.numeric(current_column[[1]]),
                                TRUE ~ NA_real_),
        character_col = case_when(!grepl("^-?\\d+(\\.\\d+)?$", current_column[[1]]) ~ as.character(current_column[[1]]),
                                  TRUE ~ NA_character_))
    
    # if there are numeric values, return TRUE and change column type to be "mixed"
    is_mixed <- current_mixed %>% 
      filter(!is.na(numeric_col)) %>% 
      nrow(.) > 0
    
    if (is_mixed == TRUE) {
      current_column_type <- "mixed"
    }
    
  } # end of if chr
  
  
  # if mixed
  if (current_column_type == "mixed") { 
    
    # calculate min
    current_min <- current_mixed$numeric_col %>% 
      min(na.rm = T)
    
    # calculate max
    current_max <- current_mixed$numeric_col %>% 
      max(na.rm = T)
    
    # if there are negative values, see how many rows
    if (current_min < 0) {
      
      # calculate number of rows with a negative value
      current_n_negative <- current_mixed %>% 
        select(numeric_col) %>% 
        filter(numeric_col < 0) %>% 
        count()
    } else {
      current_n_negative <- 0
    }
    
  } # end of if mixed
  
  # if numeric
  if (current_column_type == "numeric") {
    
    # calculate min
    current_min <- current_column %>% 
      pull(1) %>% 
      min(na.rm = T)
    
    # calculate max
    current_max <- current_column %>% 
      pull(1) %>% 
      max(na.rm = T)
    
    # if there are negative values, see how many rows
    if (current_min < 0) {
      
      # calculate number of rows with a negative value
      current_n_negative <- current_column %>% 
        pull(1) %>% 
        {sum(. < 0, na.rm = T)}
      
    } else {
      current_n_negative <- 0
    }
    
  } # end of if numeric
  
  # if date
  if (current_column_type == "Date") {
    
    current_min <- current_column %>% 
      pull(1) %>% 
      min(na.rm = T)
    
    current_max <- current_column %>% 
      pull(1) %>% 
      max(na.rm = T)
    
  } # end of if date
  
  # if time
  if (current_column_type == "hms") {
    
    current_min <- current_column %>% 
      pull(1) %>% 
      as.POSIXct(format = "%Y-%m-%d %H:%M:%S", tz = "UTC") %>% 
      min(na.rm = T) %>% 
      as_hms()
    
    current_max <- current_column %>% 
      pull(1) %>% 
      as.POSIXct(format = "%Y-%m-%d %H:%M:%S", tz = "UTC") %>% 
      max(na.rm = T) %>% 
      as_hms()
    
  } # end of if time
  
  # if datetime
  if (current_column_type == "POSIXct") {
    
    current_min <- current_column %>% 
      pull(1) %>% 
      min(na.rm = T)
    
    current_max <- current_column %>% 
      pull(1) %>% 
      max(na.rm = T)
    
  } # end of if datetime
  
  if (current_column_type == "logical") {
    
    # if logical, currently do nothing
    
  }
  
  
  # create summary tibble
  current_data_report <- tibble(
    file_name = current_file_name_relative,
    column_name = current_column_name,
    column_type = current_column_type,
    num_rows = current_nrow,
    num_unique_rows = current_unique_rows,
    num_missing_rows = current_n_misisng,
    top_counts = current_top_counts,
    range_min = as.character(current_min),
    range_max = as.character(current_max),
    num_negative_rows = current_n_negative
  )
  
  # add current row to existing summary
  data_tabular_report <- data_tabular_report %>% 
    add_row(current_data_report)
  
} # end of loop through current_df columns


### CHECK OUTPUT ###############################################################
}

View(data_tabular_report)
View(current_df)
