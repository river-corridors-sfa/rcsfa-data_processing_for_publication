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
# Updated 2024-12-26: Bibi Powers-McCormack, bibi.powers-mccormack@pnnl.gov
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

# ==============================================================================

library(tidyverse)
rm(list=ls(all=T))

# ================================= User inputs ================================

# dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/'
dir <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SampleData_v3/v3_SFA_SpatialStudy_2021_SampleData"

study_code <- 'SPS' # this is used to rename the output file

material <- 'Water' # the material entered here is how the data files are located and the keyword that's used in the sample name


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
  print(df %>% select(all_of(drop_cols)))
  
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

analyte_files <- list.files(dir, pattern = paste0(material, ".*\\.csv$"), full.names = T) # selects all csv files that contain the word provided in the "material" string
analyte_files <- analyte_files[!grepl('Mass_Volume',analyte_files)]
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

combine <- bind_rows(data$data) %>% 
  
  # identify fake boye files and then remove them
  mutate(is_fake_boye = str_detect(data_value, "^See_")) %>% 
  filter(is_fake_boye == FALSE) %>% 
  select(-is_fake_boye) %>% 
  
  # remove text flags
  rowwise() %>% 
  mutate(is_numeric = case_when(str_detect(data_value, "[A-Za-z]") ~ F, T ~ T)) %>%  # flag with F values that have a letter in them
  mutate(data_value = case_when(is_numeric == FALSE ~ NA_character_, T ~ data_value)) %>% # anything flagged with a letter is converted to NA
  mutate(data_value = as.numeric(data_value)) %>% # data_value col converted to numeric
  select(-is_numeric) %>% 
  ungroup()


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

# tell the user common columns we usually omit
cat("We often remove the following columns from data package summary files: ")
summary %>% 
  select(contains("stdev"),
         contains("Respiration_R_Squared"), 
         contains("Respiration_R_Squared_Adj"),
         contains("Respiration_p_value"),
         contains("Total_Incubation_Time_Min"),
         contains("Number_Points_In_Respiration_Regression"),
         contains("Number_Points_Removed_Respiration_Regression"),
         contains("DO_Concentration_At_Incubation_Time_Zero")) %>% 
  colnames()

# provide list of columns to the user
cat("Listing all columns in the summary file: ")
cat(paste0(seq_along(colnames(summary)), ". ", colnames(summary)), sep = "\n")

# ask user if they would like to drop any cols 
  # return "N" if want to keep all cols
  # return comma separated list listing cols to drop
response <- readline(prompt = "Enter the numbers of columns to drop (comma-separated). If you would like to keep all cols, enter 'N': ")

if (tolower(response) == "n") {
  
  cat("No columns will be dropped.")
  
  } else {
    
  drop_indices <- as.numeric(unlist(strsplit(response, ",")))
  
  # drop the cols
  summary <- drop_df_columns(df = summary, drop_indices = drop_indices)
  
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
