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
dir <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package/Sample_Data"

study_code <- 'SPS' # this is used to rename the output file

material <- 'Water' # the material entered here is how the data files are located and the keyword that's used in the sample name

# rep_type <- "variable" # indicate the number of reps; options include c("variable, static")
#   # if variable, the rep number must be included at the end of the sample name in the format [samplename]-[rep] (e.g., Sample1-2)
#   # variable = the number of reps for each sample varies; e.g., some have 1 rep, others have 3
#   # static = all samples the same number of reps
# 
# rep_number <- 1 # if all samples have the same number of reps (i.e., rep_type == "static"), then indicate the number of reps
#   # this is the number each sample average will be divided by

# ====================== read in data files ====================================
# assumptions: 
  # sample names look like this: [Parent_ID]_[analyte code]-[rep] (e.g., SPS_0001_TSS-1)
  # fake boye files have text in their data column that starts with "See_"

analyte_files <- list.files(dir, pattern = paste0(material, ".*\\.csv$"), full.names = T) # selects all csv files that contain the word provided in the "material" string
analyte_files <- analyte_files[!grepl('Mass_Volume',analyte_files)]
print(basename(analyte_files))

data_files <- list()
data_headers <- list()

for (i in 1:length(analyte_files)) {
  
  # get file name
  current_file_name <- basename(tools::file_path_sans_ext(analyte_files[i]))
  print(paste0("Reading in file ", i, " of ", length(analyte_files), ": ", current_file_name))
  
  # read in current file
  current_file <- read_csv(analyte_files[i], skip = 2, na = c("-9999", "NA", "", "N/A"), show_col_types = F) %>% 
    filter(!is.na(Sample_Name)) %>% 
    select(-Field_Name) %>% 
    mutate(file_name = current_file_name) %>% 
    
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

combine_remove_outliers <- combine %>% 
  mutate(has_outlier = case_when(str_detect(Methods_Deviation, "OUTLIER") ~ TRUE),
         extract_lookup_text = case_when(has_outlier == TRUE ~ # if it's an outlier, extract the text before "_OUTLIER"
                                         str_extract(Methods_Deviation, "^[^_]+")),
         data_value = case_when(str_detect(data_type, extract_lookup_text) ~ NA_real_, T ~ data_value)) # if that extracted text matches anything in the data_type col, then convert value to NA


# ====================== calculate summary =====================================

# calculate average for every parent_id for each data_type
calculate_summary <- combine_remove_outliers %>% 
  select(-extract_lookup_text) %>% 
  group_by(parent_id, file_name) %>% 
  mutate(average = round(mean(data_value, na.rm = T), digits = 3)) %>%  # calcualte mean and round to 3 decimal points
  mutate(average = case_when(average == "NaN" ~ NA_real_, T ~ average)) %>% 
  ungroup() %>% 

  # prepare new column headers
  mutate(summary_header_name = case_when(number_of_reps > 1 ~ paste0("mean_", data_type), T ~ data_type)) %>% # if there are more than 1 reps for each sample, then add "mean_" to front of header
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
  relocate(Mean_Missing_Reps, .after = last_col())


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

columns <- length(summary)-1
  
header_rows <- length(combine_headers$Field_Name) + 1

top <- tibble('one' = as.character(),
              'two' = as.numeric()) %>%
  add_row(one = '#Columns',
          two = columns) %>%
  add_row(one = '#Header_Rows',
          two = header_rows)


summary_out_file <- paste0(dir, "/", study_code, "_", material,'_Sample_Data_Summary_', Sys.Date(), '.csv') # this is one is for when you have files in the Share Drive

write_csv(top, summary_out_file, col_names = F)

write_csv(combine_headers, summary_out_file, append = T, col_names = T)

write_csv(summary, summary_out_file, append = T, na = '')

shell.exec(dir)
