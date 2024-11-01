# ==============================================================================
#
# Make a summary file of means for each analyte file going into a data package
# 
# ==============================================================================
# Script Updates
#
# Status: In progress
# this version uses the methods deviation information to identify and remove outliers before summarizing
# known issue: putting NA in detection limit and precision row 
#
# 
# ==============================================================================
#
# Author: Brieanne Forbes, brieanne.forbes@pnnl.gov
# 30 Sept 2022
#
# Updated 2024-10-30: Bibi Powers-McCormack, bibi.powers-mccormack@pnnl.gov
#
# ==============================================================================

library(tidyverse)
library(janitor)
rm(list=ls(all=T))

# ================================= User inputs ================================

# dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/'
dir <- "Z:/00_ESSDIVE/01_Study_DPs/SFA_SpatialStudy_2021_SampleData_v3/v3_SFA_SpatialStudy_2021_SampleData"

study_code <- 'SPS' # this is used to rename the output file

material <- 'Water' # the material entered here is how the data files are located and the keyword that's used in the sample name

# ====================== read in data files ====================================
# assumptions: 
  # each boye file has 2 top rows that are skipped
  # each boye file has 11 header rows
  # boye files requrie the following headers: Sample_Name, Material, Methods_Deviation (+ any data columns)
  # sample names can look like any of these options: 
    # [Parent_ID]_[analyte code]-[rep] (e.g., SPS_001_TSS-1)
    # [ParentID]_[analyte code]-[rep] (e.g., SPS001_TSS-1)
  # fake boye files have text in their data column that starts with "See_"
  # if an igsn column is present in the boye file, it will drop it

analyte_files <- list.files(dir, pattern = paste0(material, ".*\\.csv$"), full.names = T) # selects all csv files that contain the word provided in the "material" string
analyte_files <- analyte_files[!grepl('Mass_Volume',analyte_files)]
print(basename(analyte_files))

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


# ====================== combine into single df ================================
combine <- bind_rows(data_files) %>% 
  
  # identify fake boye files and then remove them
  mutate(is_fake_boye = str_detect(data_value, "^See_")) %>% 
  filter(is_fake_boye == FALSE) %>% 
  select(-is_fake_boye) %>% 
  
  # remove text flags
  mutate(data_value = as.numeric(data_value))


# ====================== remove outliers =======================================
# assumptions
  # methods deviations are separated by semi-colons
  # outliers are indicated with "_OUTLIER" in the Methods_Deviation column
  # if the text before "_OUTLIER" is matched to any text in the data column header, then that data value is converted to NA 
    # (e.g, "NPOC_OUTLIER_001" in the Methods_Deviation will convert the value in the column "00681_NPOC_mg_per_L_as_C" to NA)

# calc max number of deviations per sample based on number of semicolons
max_deviations <- combine %>%
  select(Methods_Deviation) %>% 
  mutate(num_deviations = str_count(Methods_Deviation, ";") + 1) %>% 
  summarise(max = max(num_deviations, na.rm = T)) %>% 
  pull()

combine_remove_outliers <- combine %>% 
  mutate(has_outlier = case_when(str_detect(Methods_Deviation, "OUTLIER") ~ TRUE)) %>% # add true if the words "OUTLIER" are present in methods deviation col
  separate(Methods_Deviation, into = paste0("Methods_Deviation_", 1:max(max_deviations)), sep = ";", fill = "right") %>% # splits methods deviation col into multiple cols
  mutate(across(starts_with("Methods_Deviation"), ~ case_when(str_detect(., "OUTLIER") ~ ., TRUE ~ NA_character_))) %>% # removes any deviations that aren't outliers
  mutate(across(starts_with("Methods_Deviation"), ~ case_when(str_detect(., "OUTLIER") ~ str_extract(., "^[^_]+"), TRUE ~ NA_character_))) %>% # extract look up text (the text that's before "_OUTLIER")
  mutate(across(starts_with("Methods_Deviation"), ~ str_replace_all(., "\\s+", ""))) %>% # remove any white space
  rowwise() %>% 
  mutate(data_value = case_when(any(across(starts_with("Methods_Deviation"), ~ str_detect(data_type, .))) ~ NA_real_,
                                T ~ data_value)) %>%  # if the lookup text in any methods deviation column is present in the data_type col, it converts the data value to NA
  ungroup()


# ====================== calculate summary =====================================
# assumptions
  # average is calculated with mean() with NA values removed and rounded to 3 decimal points
  # if any samples have more than 1 rep, then that data's column header includes "Mean_" prefixed to the column header in the summary output
  # if any sample had a rep dropped, marks the entire row Mean_Missing_Reps == TRUE

# calculate average for every parent_id for each data_type
calculate_summary <- combine_remove_outliers %>% 
  group_by(parent_id, file_name, data_type) %>% 
  mutate(average = round(mean(data_value, na.rm = T), digits = 3)) %>%  # calcualte mean and round to 3 decimal points
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

summary <- calculate_summary %>% 
  # pivot wider
  pivot_wider(id_cols = c(Sample_Name, Material, Mean_Missing_Reps), names_from = summary_header_name, values_from = average) %>% 
  relocate(Mean_Missing_Reps, .after = last_col()) %>% 
  
  # sort by sample name
  arrange(Sample_Name)


# ==================================== Format ==================================

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
header_mapping_file <- calculate_summary %>% 
  select(file_name, data_type, summary_header_name) %>% 
  distinct()

# loop through the data_headers list and rename cols based on the mapping file
data_headers_renamed <- lapply(names(data_headers), function(df_name) {
  
  # get df
  current_df <- data_headers[[df_name]]
  
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
combine_headers <- reduce(data_headers_renamed, left_join, by = c("Field_Name", "Sample_Name", "Material", "Methods_Deviation")) %>% 
  
  # add new Mean_Missing_Reps col
  add_column(Mean_Missing_Reps = "N/A") %>% 
  
  # drop cols that don't exist in summary and reorder
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
summary_out_file

write_csv(top, summary_out_file, col_names = F)

write_csv(combine_headers, summary_out_file, append = T, col_names = T)

write_csv(summary, summary_out_file, append = T, na = '')

shell.exec(dir)
