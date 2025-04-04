### Cavaiani_2024_Metaanalysis_v2_DP_Prep.R ####################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-19
# Date Updated: 2025-03-24

# Objective: 
  # Prepare data package files for Jake's v2 data package



### Check for new/removed files ################################################
# this chunk compares the old flmd with the all the files in v2

library(tidyverse)

# read in v1 flmd
prelim_flmd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis/rc_sfa-rc-3-wenas-meta/Cavaiani_2024_Metaanalysis_flmd.csv")

# get relative files from v1 flmd
v1_files <- prelim_flmd %>% 
  mutate(v1_files = paste0(File_Path, "/", File_Name)) %>% 
  select(v1_files)

# list v2 files
v2_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis/rc_sfa-rc-3-wenas-meta"
setwd(v2_dir)
v2_files <- tibble(v2_files = list.files(v2_dir, recursive = T)) %>% 
  mutate(v2_files = paste0("/Cavaiani_2024_Metaanalysis/", v2_files))

# compare
# files in v1 but not in v2 (removed files)
setdiff(v1_files$v1_files, v2_files$v2_files)
removed <- anti_join(v1_files, v2_files, join_by("v1_files" == "v2_files"))

# files in v2 but not in v1 (added files)
setdiff(v2_files$v2_files, v1_files$v1_files)
added <- anti_join(v2_files, v1_files, join_by("v2_files" == "v1_files"))


### Prepare v2 flmd and dd #####################################################
# this chunk creates the flmd and dds based on Jake's GitHub repo
# FLMD cols: File_Name, File_Description, Standard, Missing_Value_Codes, File_Path
# DD cols: Column_or_Row_Name, Unit, Definition, Data_Type

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis/rc_sfa-rc-3-wenas-meta"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis/rc_sfa-rc-3-wenas-meta"

#### prep script ----

# load libraries
library(devtools)
library(tidyverse)
library(clipr)

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/load_tabular_data.R") # function to load in data
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_flmd_skeleton.R") # function to create flmd
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_dd_skeleton.R") # function to create dd

# load data in
data_package_data <- load_tabular_data(directory = directory) # say YES to reading tabular files and YES to column headers on first row

#### flmd ---- 

# read in v1 flmd
flmd_v1 <- prelim_flmd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis/rc_sfa-rc-3-wenas-meta/Cavaiani_2024_Metaanalysis_flmd.csv")

# create skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative) # say YES to adding placeholder dd and flmds

# update columns
flmd_skeleton <- flmd_skeleton %>% 
  select(-Date_Start, -Date_End)

# update rows
flmd <- flmd_skeleton %>%
  filter(!str_detect(File_Path, "/rc_sfa-rc-3-wenas-meta/.git"),
         !File_Name %in% c(".gitignore", "README.md", "lock_file")) %>% # remove git files
  select(File_Name, File_Path) %>%
  mutate(File_Path = str_replace(File_Path, "rc_sfa-rc-3-wenas-meta", "Cavaiani_2024_Metaanalysis")) %>% # fix parent folder - # rename parent folder to from "/rc_sfa-rc-3-wenas-meta" to "/Cavaiani_2024_Metaanalysis"
  left_join(flmd_v1, by = c("File_Name", "File_Path")) %>% # join to existing flmd definitions
  mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.(csv|tsv)$") ~ '"N/A"; "-9999"; ""; "NA"',
                                         T ~ "N/A")) %>% # add missing value codes for .csv files
  mutate(Standard = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # add standard for FLMD
                              str_detect(File_Name, "\\.(csv|tsv)$") ~ "ESS-DIVE CSV v1", # add standard for .csv files
                              T ~ "N/A")) %>% 
  # sort rows by readme, flmd, dd, and then by File_Path, File_Name
  mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = F) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(-sort_order) %>% 
  select(File_Name, File_Description, Standard, Missing_Value_Codes, File_Path)


### Prepare v2 dd ##############################################################

# read in v1 dd
dd_v1 <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis/rc_sfa-rc-3-wenas-meta/Cavaiani_2024_Metaanalysis_dd.csv")

# create skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers) # say NO to adding dd and flmd headers; these will be added in subsequent steps below. Say YES to removing duplicates
print(dd_skeleton)

# update columns
dd_skeleton <- dd_skeleton %>% 
  select(-Term_Type)

# update rows
dd <- dd_skeleton %>%
  filter(!Column_or_Row_Name %in% c("Date_End", "Date_Start", "Term_Type")) %>% # remove columns dropped when updating flmd and dd columns
  
  # join existing dd cols
  select(Column_or_Row_Name) %>%
  left_join(dd_v1, by = c("Column_or_Row_Name")) %>%
  arrange(Column_or_Row_Name) %>% 
  select(Column_or_Row_Name, Unit, Definition, Data_Type)


# get the Data Type

# initialize empty df
df_classes <- tibble(Column_or_Row_Name = as.character(), 
                     Data_Type = as.character(),
                     df_name = as.character())

# loop through data to extract column type
for (i in seq_along(data_package_data$data)) {
  
  # get name of df
  current_df_name <- names(data_package_data$data[i])
  
  # get df
  current_df <- data_package_data$data[[i]]
  
  print(paste0("Dataframe: ", current_df_name))
  
  # loop through cols in df
  for (j in seq_along(current_df)) {
    
    # get name of current col
    current_col_name <- names(current_df)[j]
    
    # get class of current col
    current_class <- class(current_df[[j]])
    
    cat("Column:", current_col_name, "Class:", current_class, "\n")
    
    # add to df
    df_classes <- df_classes %>% 
      add_row(Column_or_Row_Name = current_col_name,
              Data_Type = current_class,
              df_name = current_df_name)
    
  }
  
}

# sorting out issue where some columns have more than 1 data type

# show all column headers that have more than one data type associated with it
df_classes %>% # this is a summarized view
  group_by(Column_or_Row_Name, Data_Type) %>% 
  summarise(file_count = n(),
            df_names = toString(df_name)) %>% 
  group_by(Column_or_Row_Name) %>% 
  mutate(column_name_count = n()) %>% 
  arrange(Column_or_Row_Name) %>% 
  select(Column_or_Row_Name, column_name_count, everything()) %>%
  filter(column_name_count > 1) %>% 
  ungroup() %>% 
  view()

df_classes %>% # this is the full view
  group_by(Column_or_Row_Name) %>% 
  mutate(unique_data_type_count = n_distinct(Data_Type)) %>% 
  ungroup() %>% 
  filter(unique_data_type_count > 1) %>% 
  view()

df_issues <- df_classes %>% # get all dfs that were included in the query above
  group_by(Column_or_Row_Name) %>% 
  mutate(unique_data_type_count = n_distinct(Data_Type)) %>% 
  ungroup() %>% 
  filter(unique_data_type_count > 1) %>% 
  distinct(df_name) %>% 
  pull(df_name)

df_issues <- purrr::keep(data_package_data$data, names(data_package_data$data) %in% df_issues) # gets all dfs with issues

df_issues

# update classes based on previous exploration
df_classes <- df_classes %>%
  group_by(Column_or_Row_Name) %>%
  mutate(file_count = n_distinct(Data_Type)) %>%
  mutate(Data_Type = case_when(Column_or_Row_Name == "DOC" ~ "text; numeric", # this is mixed depending on the column
                               Column_or_Row_Name == "Fire_year" ~ "text", # becomes text because some years a range is listed
                               Column_or_Row_Name == "NO3" ~ "text; numeric", # this is mixed depending on the column
                               Column_or_Row_Name == "STDEV_DOC" ~ "numeric", # uses N/A as missing value which made some say it was text but all reported values are numeric
                               Column_or_Row_Name == "STER_DOC" ~ "numeric", # uses N/A as missing value which made some say it was text but all reported values are numeric
                               Column_or_Row_Name == "STER_NO3" ~ "numeric", # uses N/A as missing value which made some say it was text but all reported values are numeric
                               Column_or_Row_Name == "Time_Since_Fire" ~ "text; numeric", # sometimes ranges are listed
                               Column_or_Row_Name == "Vegetation_year_pull" ~ "text; date", # sometimes ranges are listed
                               Column_or_Row_Name == "burn_percentage" ~ "numeric", # uses N/A as missing value which made some say it was text but all reported values are numeric
                               Column_or_Row_Name == "year" ~ "text; date",  # sometimes ranges are listed
                               T ~ Data_Type)) %>%
  mutate(Data_Type = case_when(Data_Type == "character" ~ "text",
                               T ~ Data_Type)) %>%
  select(Column_or_Row_Name, Data_Type) %>%
  distinct()

# join data type to dd
dd <- dd %>%
  select(-Data_Type) %>%
  left_join(df_classes, by = "Column_or_Row_Name") %>%
  select(Column_or_Row_Name, Unit, Definition, Data_Type) %>%
  distinct() %>%
  arrange(Column_or_Row_Name)

dd

# get file header counts
headers <- data_package_data$headers %>%
  mutate(file = basename(file)) %>% 
  group_by(header) %>% 
  summarise(header_count = n(),
            files = toString(file)) %>% 
  ungroup() %>% 
  arrange(header, .locale = "en")

# join those counts to the dd
dd_with_header_counts <- dd %>% 
  left_join(headers, by = join_by("Column_or_Row_Name" == "header")) %>% 
  arrange(Column_or_Row_Name)

print(dd_with_header_counts)

# export
write_csv(flmd, file = paste0(out_directory, "/v2_Cavaiani_2024_Metaanalysis_flmd.csv"), na = "")
write_csv(dd_with_header_counts, file = paste0(out_directory, "/v2_Cavaiani_2024_Metaanalysis_dd.csv"), na = "")




