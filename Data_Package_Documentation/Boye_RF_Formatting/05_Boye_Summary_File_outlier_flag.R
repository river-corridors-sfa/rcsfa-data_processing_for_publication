# ==============================================================================
#
# Make a summary file of means for each analyte file going into a data package
#
# ==============================================================================
# Script Updates
#
# Status: In progress this version uses the methods deviation information to
# identify and remove outliers before summarizing known issue: putting NA in
# detection limit and precision row
#
#
# ==============================================================================
#
# Author: Brieanne Forbes, brieanne.forbes@pnnl.gov 30 Sept 2022
#
# Updated 2025-02-03: Bibi Powers-McCormack, bibi.powers-mccormack@pnnl.gov
#
# Status: complete 

# INPUTS: 
  # assumptions for the inputs files: 
    # they have have the following required column names: c("Field_Name", Sample_Name", "Material", "Methods_Deviation")
    # they are boye formatted (when reading in, it will skip 2 and then have 11 header rows)
    # file names include the user indicated `material`
    # files are .csv

# HOW THIS SCRIPT SUMMARIZES: 
  # This script identifies outliers by detecting any text in the
  # `Methods_Deviation` column that says "_OUTLIER". It extracts the text before
  # "_OUTLIER" and pads it with underscores (e.g., TN_ becomes _TN_) and then
  # attempts to match it to an underscore padded column name (e.g., matches _TN_
  # to _00602_TN_mg_per_L_as_N). If a match occurs, it will assign it as an
  # outlier.

  # Any assigned outliers will be dropped before calculating averages.

  # If more than 1 rep exists, the column will be renamed to append "Mean_" to 
  # the front the original column name.

  # If any calculations include a NA value (either because it was an outlier or
  # because of another flag), the column Mean_Missing_Rep will == T

  # Values are rounded to 3 decimal points.

# OUTPUTS: 
  # a single summary file as a .csv to the user indicated `dir`

# NOTES: 
  # If any edits are made to this script, confirm that the tests in 
  # `test-05_Boye_Summary_File_outlier_flag.R` still pass. 

  # If you need to add new outliers (or see which outliers this script works with)
  # see `test-05_Boye_Summary_File_outlier_flag.R`. Follow the commented
  # directions in the test called "flags are correctly assigned".

# ==============================================================================

library(tidyverse)
rm(list=ls(all=T))

# ================================= User inputs ================================

dir <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package_v2/v2_WHONDRS_AV1_Data_Package/Sample_Data"

study_code <- 'v2_WHONDRS_AV1' # this is used to rename the output file

material <- 'Sediment' # the material entered here is how the data files are located and the keyword that's used in the sample name

# ====================== functions used in this script =========================

# function to read in files
read_in_files <- function(analyte_files, material) {
  # INPUTS: 
    # a vector of absolute file names of .csv files in the Boye Format
  # OUTPUT: 
    # a list that contains two sub lists: headers and data
  
  data_files <- list()
  data_headers <- list()
  
  for (i in 1:length(analyte_files)) { # this loops through each analyte file, reads the headers and data, cleans data (splits out sample name and rep counts) and converts to long, and saves to lists
    
    # get file name
    current_file_name <- basename(tools::file_path_sans_ext(analyte_files[i]))
    print(paste0("Reading in file ", i, " of ", length(analyte_files), ": ", current_file_name))
    
    # read in current file
    current_source <- read_csv(analyte_files[i], skip = 2, na = c("-9999", "NA", "", "N/A"), show_col_types = F) %>% 
      filter(!is.na(Sample_Name)) %>% 
      select(-Field_Name) %>% 
      mutate(file_name = current_file_name)
    
    current_file <- current_source %>% 
      
      # remove IGSN column if it exists
      select(-any_of("IGSN")) %>% 
      
      # add user input material
      mutate(user_provided_material = material) %>% 
      
      # split out sample name
      separate(Sample_Name, into = c("parent_analyte", "rep"), sep = "-", remove = FALSE) %>%
      separate(parent_analyte, into = c("parent_id", "analyte"), sep = "_(?=[^_]+$)", remove = TRUE, extra = "merge") %>% 
    
      # convert all to chr (temporarily - will convert back in later step)
      mutate(across(everything(), as.character)) %>% 
        
      # count number of reps
      group_by(parent_id) %>% 
      mutate(number_of_reps = n_distinct(rep)) %>% 
      
      # pivot longer
      group_by(across(c(Sample_Name, parent_id, analyte, rep, Material, Methods_Deviation, file_name, user_provided_material, number_of_reps))) %>% 
      pivot_longer(cols = -group_cols(), # pivoting all cols that aren't grouped
                   names_to = "data_type", 
                   values_to = "data_value") %>% 
        ungroup()
      
      # add to list
      data_files[[current_file_name]] <- current_file
      
      
      # read in headers
      current_headers <- read_csv(analyte_files[i], skip = 2, n_max = 11, show_col_types = F)
      
      # add to list
      data_headers[[current_file_name]] <- current_headers
    
  }
  
  data <- list(headers = data_headers, 
               data = data_files)
  
  # add to list
  data_files[[current_file_name]] <- current_file
  
  # read in headers
  current_headers <- read_csv(analyte_files[i], skip = 2, n_max = 11, show_col_types = F)
  
  # add to list
  data_headers[[current_file_name]] <- current_headers
  return(data)
  
} # end of `read_in_files()` function


combine_data <- function(data) {
  
  # inputs: 
    # data = list of dfs saved as a sublist from the read_in_files function (data$data$dfs)
  # outputs: 
    # combine_data = long df of all data combined together
  
  # extract any values that have letters in them
  data_with_letters <- bind_rows(data$data) %>% 
    mutate(data_value = case_when(str_detect(data_value, "[A-Za-z]") ~ data_value, TRUE ~ NA)) %>% 
    filter(!is.na(data_value)) %>% 
    pull(data_value) %>% 
    unique(.) %>% 
    unlist()
  
  if (length(data_with_letters > 0)) {
    
    # show all character data values
    cat("\n", "The above text values will be converted to NA. Okay to proceed?",
        data_with_letters %>%
          cat(., sep = "\n"))
    
    # ask if okay to convert all of those to NA
    response <- readline(prompt = "(Y/N): ")
    
  } else {
    response <- "Y"
  }
  
  if (tolower(response) == "y") {
    
    combine_df <- bind_rows(data$data) %>% 
      
      # identify fake boye files and then remove them
      mutate(is_fake_boye = str_detect(data_value, "^See_")) %>% 
      filter(is_fake_boye == FALSE | is.na(is_fake_boye)) %>% 
      select(-is_fake_boye) %>% 
      
      # remove text flags
      rowwise() %>% 
      mutate(is_numeric = case_when(str_detect(data_value, "[A-Za-z]") ~ F, T ~ T)) %>%  # flag with F values that have a letter in them
      mutate(data_value = case_when(is_numeric == FALSE ~ NA_character_, T ~ data_value)) %>% # anything flagged with a letter is converted to NA
      mutate(data_value = as.numeric(data_value)) %>% # data_value col converted to numeric
      select(-is_numeric) %>% 
      ungroup()

    return(combine_df) # returns df
    
  } else if (tolower(response) == "n") {
    
    warning("The `data_value` column must be numeric. Fix your data and try again.")
    return(invisible(NULL)) # exits function
    
  } else {
    
    stop("The script is stopping due to an issue. Please check your input data and try again.")
    
  }
  
} # end of `combine_data()` function

# function to assign flags
assign_flags <- function(combine_df) {
  # INPUT: 
    # the the data combined into a single df
  # OUTPUT: 
    # a df with 2 added cols: 
      # `_data_type` that is the data type column name with an underscore appended to it
      # `Outlier` that indicates the text string that needs to match to `_data_type` to determine if it's an outlier
  
  max_deviations <- combine_df %>%
    select(Methods_Deviation) %>% 
    mutate(num_deviations = str_count(Methods_Deviation, ";") + 1) %>% 
    summarise(max = max(num_deviations, na.rm = T)) %>% 
    pull()
  
  combine_prepare_outliers <- combine_df %>% 
    # split outlier methods deviations into separate columns
    separate(Methods_Deviation, into = paste0("Outlier_", 1:max(max_deviations)), sep = ";", fill = "right", remove = F) %>% # splits methods deviation col into multiple cols
    
    # clean up Methods_Deviation column
    mutate(across(starts_with("Outlier"), ~ str_replace_all(., "\\s+", ""))) %>% # remove any white space
    
    # create temporary new column name that includes an extra underscore
    mutate(`_data_type` = paste0("_", data_type)) %>% # add underscore to front of col name so the padding works for columns that don't begin with a number (e.g., NPOC_mg_per_L_as_C becomes _NPOC_mg_per_L_as_C)
    
    # convert outlier cols into look up text
    mutate(across (.cols = starts_with("Outlier_"), # for all column names that start with "Outlier_"
                   .fns = ~ case_when(
                     str_detect(., "OUTLIER") ~ str_extract(., "^[^_]+"), # if "OUTLIER" is present, then extract the look up text (the text that's before "_OUTLIER")
                     TRUE ~ ""), # otherwise if "OUTLIER" isn't present, convert to NA
                   .names = "{.col}" # keep col names the same
                   )) %>% 
    mutate(across(.cols = starts_with("Outlier_"), # if the cell isn't empty, then pad both sides of the look up text with underscores (e.g., TN becomes _TN_)
                  .fns = ~ case_when(
                    !is.na(.) ~ paste0("_", ., "_")),
                  .names = "{.col}"
                  )) %>%
    
    # remove Outlier if it doesn't match with _data_type column
    rowwise() %>% 
    mutate(has_outlier = paste(across(starts_with("Outlier_")), collapse = "|"),  # create single outlier col that combines all Outlier_ cols
           has_outlier = str_replace(has_outlier, "\\|__", ""),
           has_outlier = str_replace(has_outlier, "__\\|", "")) %>% # the NA values are converted into __, so this removes those
    mutate(has_outlier = case_when(any(str_detect(`_data_type`, str_split(has_outlier, "\\|")[[1]])) ~ has_outlier, # if the outlier look up text in has_outlier matches the _data_type col it keeps the lookup text, otherwise it convertst that value to NA
                                   T ~ NA_character_)) %>% 
    ungroup() %>% 
    
    # clean up cols
    select(-c(starts_with("Outlier_")))
  
  # show user how the outlier flags match to the columns
  combine_prepare_outliers %>% 
    select(has_outlier, data_type, `_data_type`) %>% 
    filter(!is.na(has_outlier)) %>% 
    distinct() %>% 
    group_by(has_outlier) %>% 
    summarise(column_look_up_match = toString(data_type)) %>% 
    print()
  
  print("The above outlier flags have been identified and match with these corresponding columns.")
  
  return(combine_prepare_outliers)
  
} # end of `assign_flags()` function

# function to apply flags
apply_flags <- function(combine_prepare_outliers_df) {
  # INPUT: 
    # the output of `assign_flags()`
  # OUTPUT: 
    # a df that drops the c(Methods_Deviation, Outlier, and _data_type) columns after converting outliers to NA
  
  combine_remove_outliers <- combine_prepare_outliers_df %>% 
    
    group_by(Sample_Name) %>% 
    
    # if the lookup text in the Outlier col is present in the _data_type col, it converts the data_value to NA
    mutate(data_value = case_when(str_detect(`_data_type`, has_outlier) ~ NA_real_, T ~ data_value)) %>% 
    
    # clean up df
    select(-`_data_type`, -Methods_Deviation, -has_outlier) %>% # drop Methods Deviation col
    
    # group by Sample_Name and make distinct to remove any duplicates created when we pivoted longer
    distinct() %>% 
    ungroup()
  
  return(combine_remove_outliers)
  
} # end of `apply_flags()` function

# function to calculate summary
calculate_summary <- function(combine_remove_outliers_df) {
  # INPUT: 
    # the output of `apply_flags()`
  # OUTPUT: 
    # a long df that averages each data type for each sample (an average of the reps for each sample)
  
  calculate_summary <- combine_remove_outliers_df %>% 
    group_by(parent_id, file_name, data_type) %>% 
    mutate(average = round(mean(data_value, na.rm = T), digits = 3)) %>%  # calculate mean and round to 3 decimal points
    mutate(average = case_when(average == "NaN" ~ NA_real_, T ~ average)) %>% 
    ungroup() %>% 
    
    # prepare new column headers
    mutate(summary_header_name = case_when(number_of_reps > 1 ~ paste0("Mean_", data_type), T ~ data_type)) %>% # if there are more than 1 reps for each sample, then add "Mean_" to front of header
    mutate(Sample_Name = paste0(parent_id, "_", user_provided_material)) %>% # rename sample name
    
    # deal with missing reps
    group_by(Sample_Name) %>% 
    mutate(Mean_Missing_Reps = any(is.na(data_value) == TRUE)) %>% # marks missing reps = T if any value for that given sample is NA
    ungroup() %>% 
    
    # drop cols and rows we don't need
    select(Sample_Name, Material, average, data_type, file_name, summary_header_name, Mean_Missing_Reps) %>%
    distinct()
  
  return(calculate_summary)
  
} # end of `calculate_summary()` function

# function to drop columns based on column index number
drop_df_columns <- function(df, drop_indices) {
  
  # INPUT:
    # data frame
    # column indices that you want to be dropped (e.g., c(1, 4, 6))
  
  # OUTPUT: 
    # the input df with the columns dropped
  
  # Check if indices are valid
  if (any(drop_indices > ncol(df) | drop_indices < 1)) {
    stop("Some indices are out of range.")
  }
  
  # Get the column names corresponding to the indices
  drop_cols <- colnames(df)[drop_indices]
  
  # Display columns to be dropped
  message("The following columns will be dropped:")
  print(df %>% select(all_of(drop_cols)) %>% str())
  
  # Ask for confirmation
  confirm <- readline(prompt = "Do you want to proceed? (Y/N): ")
  
  if (tolower(confirm) == "y") {
    dropped_df <- df %>% select(-all_of(drop_cols))
    message("`drop_df_columns()` complete")
    return(dropped_df)
  } else {
    message("Operation cancelled. No columns were dropped.")
    return(df)
  }
  

} # end of `drop_df_columns()` function


# ====================== read in data files ====================================
# assumptions: 
  # checks for any files that end in "*Summary.csv" and asks the user to remove them
  # each boye file has 2 top rows that are skipped
  # each boye file has 11 header rows
  # boye files requrie the following headers: Field_Name, Sample_Name, Material, Methods_Deviation (+ any data columns)
  # sample names can look like any of these options: 
    # [Parent_ID]_[analyte code]-[rep] (e.g., SPS_001_TSS-1)
    # [ParentID]_[analyte code]-[rep] (e.g., SPS001_TSS-1)
  # fake boye files have text in their data column that starts with "See_"
  # if an igsn column is present in the boye file, it will drop it

# increases threshold for using scientific notation
options(scipen = 999) # you can check your current scipen value wtih getOption("scipen"); the default is 0 and increasing it reduced the likelihood of scientific notation being used

analyte_files <- list.files(dir, pattern = paste0(material, ".*\\.csv$"), full.names = T) # selects all csv files that contain the word provided in the "material" string
analyte_files <- analyte_files[!grepl('Mass_Volume',analyte_files)] # removing any file that says Mass_Volumne because sometimes those files also have the material type in them, but we don't want them included in the summary
print(basename(analyte_files))

# check if a summary file already exists - if it does, warn the user
if (any(str_detect(analyte_files, "Summary\\.csv"))) {
  warning("Summary file(s) detected. Please remove before proceeding: ", basename(analyte_files[str_detect(analyte_files, "Summary\\.csv")]))
}

# read in files
data <- read_in_files(analyte_files, material = material)


# ====================== combine into single df ================================
# assumptions: 
  # fake boye files, identified by the presence of "See_" in the data value column are filtered out (the entire row removed)
  # all other text values (e.g., text flags) are converted to NA (the row is kept, but the value converted to NA)

# combine all data dfs together + drop fake boyes and text flags
combine <- combine_data(data)

# ====================== remove outliers =======================================
# assumptions: 
  # methods deviations are separated by semi-colons
  # outliers are indicated with "_OUTLIER" in the Methods_Deviation column
  # if the text before "_OUTLIER is matched to any text in the data column header, after the text is padded with underscores on either side, then that data value is converted to NA 
    # (e.g, "NPOC_OUTLIER_001" in the Methods_Deviation will look up "_NPOC_" in the column name and then convert the value in the column "00681_NPOC_mg_per_L_as_C" to NA)
  # the script temporarily adds an underscore to the front of all column headers to account for possible columns that begin with the text lookup (e.g., "NPOC_mg_per_L_as_C" becomes "_NPOC_mg_per_L_as_C" so the "_NPOC_" look up matches)
  # the case sensitivity of the look up text must match the column. This ensures that Mg won't strip any mention of milligrams (mg)

# identify outliers
combine_prepare_outliers <- assign_flags(combine_df = combine)
  

# remove outlier values  
combine_remove_outliers <- apply_flags(combine_prepare_outliers_df = combine_prepare_outliers)


# ====================== calculate summary =====================================
# assumptions
  # average is calculated with mean() with NA values removed and rounded to 3 decimal points
  # if any samples have more than 1 rep, then that data's column header includes "Mean_" prefixed to the column header in the summary output
  # if any sample had a rep dropped, marks the entire row Mean_Missing_Reps == TRUE

# calculate average for every parent_id for each data_type
summary_calculated <- calculate_summary(combine_remove_outliers_df = combine_remove_outliers)

summary <- summary_calculated %>% 
  # pivot wider
  pivot_wider(id_cols = c(Sample_Name, Material, Mean_Missing_Reps), names_from = summary_header_name, values_from = average) %>% 
  relocate(Mean_Missing_Reps, .after = last_col()) %>% 
  
  # sort by sample name
  arrange(Sample_Name)

# ========================= clean up summary ===================================
# assumptions
  # we generally want to remove any `stdev` columns
  # within respiration rate cols, we usually only want the `Respiration_Rate_mg_DO_per_L_per_H`, so we usually omit the following cols from the summary
    # Respiration_R_Squared
    # Respiration_R_Squared_Adj
    # Respiration_p_value
    # Total_Incubation_Time_Min
    # Number_Points_In_Respiration_Regression
    # Number_Points_Removed_Respiration_Regression
    # DO_Concentration_At_Incubation_Time_Zero

# create a df that lists summary cols and whether they are usually dropped
indexed_summary_cols <- colnames(summary) %>% 
  tibble(column_name = .) %>% 
  mutate(index = 1:n(), .before = "column_name") %>% 
  rowwise() %>% 
  mutate(to_remove = any(str_detect(column_name, c("stdev", 
                                                        "Respiration_R_Squared",
                                                        "Respiration_R_Squared_Adj", 
                                                        "Respiration_p_value",
                                                        "Total_Incubation_Time_Min",
                                                        "Number_Points_In_Respiration_Regression",
                                                        "Number_Points_Removed_Respiration_Regression",
                                                        "DO_Concentration_At_Incubation_Time_Zero",
                                                   'FTICR-MS'
                                                        )))) %>% 
  ungroup() %>% 
  mutate(to_remove = case_when(to_remove == TRUE ~ TRUE)) %>% 
  mutate(to_remove = case_when(column_name %in% c("Field_Name", "Sample_Name", "Material", "Mean_Missing_Reps") ~ FALSE, T ~ to_remove)) %>% 
  mutate(index = case_when(to_remove == FALSE ~ NA_integer_, T ~ index))

# if any cols in summary match with cols we commonly remove, ask user if they'd like to remove those cols
if ((indexed_summary_cols %>% 
    filter(to_remove == TRUE) %>% 
    nrow()) > 0) {
  
  # ask user if they would like to remove all of the indicated cols: 
  # possible response combinations are
  # remove default cols + additional cols 
  # remove default cols
  # remove additional cols
  # remove no cols
cat("Columns that are typically removed are indicated as 'TRUE' in the `to_remove` column and 'FALSE' indicates the column cannot be removed. ", 
    View(indexed_summary_cols))
  
  response_1 <- readline(prompt = "Would you like to remove all of the indicated columns from the summary file (Y/N)? ")
  response_2 <- readline(prompt = paste0("Which (additional) column(s) would you like to remove?",  "\n",
                                          "Provide a comma-separated list of index numbers (e.g., '3, 5, 8'). Write '0' if none: "))
  
  
} else {
  
  response_1 <- "N"
  View(indexed_summary_cols)
  cat("\n")
  
  response_2 <- readline(prompt = paste0("Would you like to remove any column(s) from the summary file?", "\n", 
                                          "If so, provide a comma-separated list of index numbers (e.g., '3, 5, 8'); otherwise write '0' if none: "))
  
}


# based on response 1, identify if default cols should be removed
if (tolower(response_1) == "n") {
  
  # if no, change default T to NA
  indexed_summary_cols <- indexed_summary_cols %>% 
    mutate(to_remove = case_when(to_remove == TRUE ~ NA, T ~ to_remove))
  
  
} else if (tolower(response_1) != "y") {
  
  message("ERROR. Y/N not provided.")

  }

# based on response 2, remove additional cols
if(response_2 != "0") {
  
  additional_cols_to_remove <- as.numeric(unlist(strsplit(response_2, ",")))
  
  # update df with additional cols to remove
  indexed_summary_cols <- indexed_summary_cols %>% 
    mutate(to_remove = case_when(index %in% additional_cols_to_remove ~ TRUE, T ~ to_remove))
}

# filter for cols to remove and get index value
cols_to_remove <- indexed_summary_cols %>% 
  filter(to_remove == TRUE)

if(nrow(cols_to_remove) > 0) {
  
  cols_to_remove <- cols_to_remove %>% 
    pull(index)
  
} else {
  
  cols_to_remove <- 0
}


if(sum(cols_to_remove) != 0){
  
  cat("Dropping columns.")
  cat("\n")
  
  # drop the cols
  summary <- drop_df_columns(df = summary, drop_indices = cols_to_remove)
  
} else {

  cat("No columns will be dropped.")
  
}


# ==================================== Format ==================================
# assumptions
  # numeric columns use -9999 as a missing value code
  # character columns use N/A as a missing value code

summary <- summary %>% 
  # add Field Name col
  mutate(Field_Name = NA_character_, .before = Sample_Name,
         Field_Name = replace(Field_Name, row_number() == 1, "#Start_Data")) %>% 
  
  # add -9999 and N/A
  mutate_if(is.numeric, replace_na, replace = -9999)%>%
  mutate_if(is.character, replace_na, replace = 'N/A') %>% 
  
  bind_rows(tibble(Field_Name = "#End_Data"))



# ===================== Prepare header rows ====================================

# create header mapping file
header_mapping_file <- summary_calculated %>% 
  select(file_name, data_type, summary_header_name) %>% 
  distinct()

# note: this script has been commented out. Uncomment this if you need to visualize the new column names
# print(header_mapping_file)
# cat("The above table shows that columns with more than 1 rep will be renamed to include 'Mean_'.")

# loop through the data_headers list and rename cols based on the mapping file
data_headers_renamed <- lapply(names(data$headers), function(df_name) {
  
  # get df
  current_df <- data$headers[[df_name]]
  
  # filter mapping file for current df name
  current_mapping_file <- header_mapping_file %>% 
    filter(file_name == df_name)
  
  # create a named vector for renaming
  current_rename_vector <- setNames(current_mapping_file$data_type, current_mapping_file$summary_header_name)
  
  # rename cols
  current_df <- current_df %>% 
    rename(all_of(current_rename_vector))
  
  return(current_df)
  
})

# combine headers
combine_headers <- reduce(data_headers_renamed, left_join, by = c("Field_Name", "Sample_Name", "Material", "Methods_Deviation")) %>% # this takes the list of header info for each file and joins them binding columns across all files together
  
  # add new Mean_Missing_Reps col
  add_column(Mean_Missing_Reps = "N/A") %>% 
  
  # drop cols that don't exist in summary and reorders to make sure the headers properly line up with the data
  select(colnames(summary))

# verify column order matches
identical(names(combine_headers), names(summary)) # Should return TRUE


# =================================== Write File ===============================
# this exports exports the combine_headers and summary dfs

columns <- length(summary)-1
  
header_rows <- length(combine_headers$Field_Name) + 1

top <- tibble('one' = as.character(),
              'two' = as.numeric()) %>%
  add_row(one = '#Columns',
          two = columns) %>%
  add_row(one = '#Header_Rows',
          two = header_rows)


summary_out_file <- paste0(dir, "/", study_code, "_", material,'_Sample_Data_Summary_', Sys.Date(), '.csv') # this is one is for when you have files in the Share Drive
cat("Exporting... ", summary_out_file)

write_csv(top, summary_out_file, col_names = F)

write_csv(combine_headers, summary_out_file, append = T, col_names = T)

write_csv(summary, summary_out_file, append = T, na = '')

shell.exec(dir)

