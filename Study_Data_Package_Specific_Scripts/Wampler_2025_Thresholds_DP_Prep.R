### Wampler_2025_Thresholds_DP_Prep.R #######################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-07
# Date Updated: 2025-03-10

# Objective: Prepare the Thresholds manuscript data package

# Assumptions: 
# Each code chunk was run independently from the rest. 

# Citation: 
# Wampler K A ; Bladon K D ; Forbes B ; Kang H ; Powers-McCormack B ;
# Regier P ; Scheibe T D ; Myers-Pigg A (2025): Data and scripts associated with
# “Thresholds of Area Burned and Burn Severity for Downstream Riverine Systems
# to ‘Feel the Burn’”. River Corridor and Watershed Biogeochemistry SFA,
# ESS-DIVE repository. Dataset. doi:10.15485/2529445 accessed via
# https://data.ess-dive.lbl.gov/datasets/doi:10.15485/2529445


### Add authors to landing page ################################################
# this chunk pulls author info from ess-dive metadata .docx and author spreadsheet and then updates the landing page

# load libraries
library(tidyverse)
library(rlog)
library(officer) # for reading in docx files
library(readxl) # for reading in excel files
library(janitor) # for cleaning up col headers
library(glue)
library(devtools) # for sourcing in script
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/create-update-landing-page-authors/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_authors.R")

# USER INPUTS
your_essdive_metadata_file <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/thresholds_ESSDIVE_Metadata.docx" # absolute file path of ESS-DIVE metadata .docx
your_api_token = "" # recommend adding this in the console
your_essdive_id = "ess-dive-09d64795a658e7e-20250307T191416645" # id that begins with "ess-dive-" found on the landing page you want to update
your_upload_site = "main" # options: c("sandbox", "main")


# get authors from ESS-DIVE metadata file
author_names <- get_authors_from_essdive_metadata(essdive_metadata_file = your_essdive_metadata_file)


# get author info from spreadsheet
author_info <- get_author_spreadsheet_info(author_df = author_names, 
                                           author_info_file = "Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx")


# update landing page - warning this will overwrite all existing authors with the new ones you provide
update_landing_page_authors(api_token = your_api_token,
                            author_df = author_info,
                            essdive_id = your_essdive_id,
                            upload_site = your_upload_site)


### Create coordinate spreadsheet ##############################################
# this chunk creates a csv with 3 columns (Description, Latitude, Longitude) that will used to update the landing page

# load libraries
library(tidyverse)

# copy and paste info manually from the ess-dive metadata .docx file
coords <- tribble(~Description, ~Latitude, ~Longitude,
                  "USGS gauge data (12488500) used for parameterizing the humid, forested test basin", 46.97761606, -121.168696,
                  "USGS gauge data (11204100) used for parameterizing the semi-arid, mixed land use test basin", 36.02411648, -118.8134258,
                  "Elevation, soil, land cover, and climate data used for parameterizing the humid, forested test basin", 46.9935, -121.5225, # note this is a bounding box: 46.9935, 46.81174, -121.5225, -121.1685
                  "Elevation, soil, land cover, and climate data used for parameterizing the semi-arid, mixed land use test basin", 35.95394, -118.814, # note this is a bounding box: 35.95394, 36.11071, -118.814, -118.5751
                  "Water quality data used for parameterizing the humid, forested test basin", 46.01679, -121.7604, # note this is a bounding box: 46.01679, 47.35512, -121.7604, -121.0040
                  "Water quality data used for parameterizing the semi-arid, mixed land use test basin", 35.90773, -119.3979 # note this is a bounding box: 35.90773, 36.74077, -119.3979, -118.2726
                  )

write_csv(coords, "Z:/00_ESSDIVE/03_Manuscript_DPs/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/thresholds_geospatial_coords.csv")


### Update landing page with coordinates #######################################

# load libraries
library(devtools)
library(tidyverse)
library(rlog)
library(glue)
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# set wd to the rc-sfa data processing repo
setwd("C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-data_proceesing_for_publication")

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_coordinates.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")

#### Fill out arguments ----
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "abcdefjhijklmnopqrstuvwxyz - added in the console"

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-f403f5ad350f22c-20250307T184624508105"

# this is the .csv absolute file path of the coordinates
your_coordinates_file_path <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/thresholds_geospatial_coords.csv"

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "main" 


#### Run function ----

update_landing_page_coordinates(api_token = your_api_token,
                                essdive_id = your_essdive_id,
                                coordinates_file_path = your_coordinates_file_path,
                                upload_site = your_upload_site)


### Create flmd and dd v0.1 ####################################################
# this chunk creates the flmd and dds based on the initial files Katie filled out
# FLMD cols: File_Name, File_Description, Standard, Missing_Value_Codes, File_Path
# DD cols: Column_or_Row_Name, Unit, Definition, Data_Type

# input directory (do not include "/" at end of path)
input_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package"

# output directory
out_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/archive/"

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
data_package_data <- load_tabular_data(directory = input_dir) # say YES to reading tabular files and YES to column headers on first row

#### flmd ----

# read in existing flmd
existing_flmd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/archive/thresholds_flmd.csv") %>% 
  select(File_Name, File_Description)

# create skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative) # say YES to adding placeholder dd and flmds
print(flmd_skeleton)

# update columns
flmd_skeleton <- flmd_skeleton %>% 
  select(-Date_End, -Date_Start)
print(flmd_skeleton)

# update rows
flmd <- flmd_skeleton %>%
  mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.(csv|tsv)$") ~ '"N/A"; "-9999"; ""; "NA"',
                                         T ~ "N/A")) %>% # add missing value codes for .csv files
  mutate(Standard = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # add standard for FLMD
                              str_detect(File_Name, "\\.(csv|tsv)$") ~ "ESS-DIVE CSV v1", # add standard for .csv files
                              T ~ "N/A")) %>% 
  mutate(File_Name = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "Myers-Pigg_2025_Thresholds_flmd.csv", # rename flmd and dd
                               str_detect(File_Name, "_dd\\.csv$") ~ "Myers-Pigg_2025_Thresholds_dd.csv",
                               T ~ File_Name)) %>% 
  mutate(File_Description = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "File-level metadata that lists and describes all of the files contained in the data package.", # add definitions for flmd and dd
                                      str_detect(File_Name, "_dd\\.csv$") ~ 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
                                      str_detect(File_Name, "readme") ~ 'Data package level readme. Contains data package summary; acknowledgements; and contact information.',
                                      T ~ File_Description)) %>% 
  add_row(File_Name = "readme_Myers-Pigg_2025_Thresholds.pdf", # add readme row
          File_Description = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          Standard = "N/A",
          Missing_Value_Codes = "N/A", 
          File_Path = NA_character_) %>% 
  mutate(File_Path = case_when(File_Name %in% c("Myers-Pigg_2025_Thresholds_flmd.csv", "Myers-Pigg_2025_Thresholds_dd.csv", "readme_Myers-Pigg_2025_Thresholds.pdf") ~ "/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package", # update file paths
                               T ~ File_Path)) %>% 
  
  # join existing flmd definitions
  left_join(existing_flmd, by = "File_Name") %>% 
  mutate(File_Description = coalesce(File_Description.y, File_Description.x)) %>% 
  select(File_Name, File_Description, Standard, Missing_Value_Codes, File_Path) %>%
  
  # sort rows by readme, flmd, dd, and then by File_Path, File_Name
  mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = F) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(-sort_order)

print(flmd)

#### dd ----

# read in existing flmd
existing_dd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/archive/thresholds_dd.csv") %>% 
  select(-Data_Type)

# identify column header issues
data_package_data$headers %>% 
  distinct() %>% 
  filter(str_detect(header, fixed("..."))) %>% 
  view() # shows duplicates within the same file

data_package_data$headers %>% 
  count(header) %>% 
  view() # shows duplicates across files

# template
dd_template <- tribble(~Column_or_Row_Name, ~Unit, ~Definition, ~Data_Type,
                       "File_Name",	"N/A",	"Name of files in the data package.", "text",
                       "File_Description",	"N/A",	"A brief description of the files in the data package.",	"text",
                       "Standard",	"N/A",	"ESS-DIVE Reporting Format or other standard applied to the data file.",	"text",
                       "Missing_Value_Codes",	"N/A",	'Cells with missing data are represented with a missing value code rather than an empty cell. This column describes which missing value codes were used. The recommendation for numeric data is "-9999" and for character data is "N/A".',	"text",
                       "File_Path",	"N/A",	"File path within the data package.",	"text",
                       "Column_or_Row_Name",	"N/A",	"Column or row headers from each csv file in the dataset.",	"text",
                       "Unit",	"N/A",	"Unit of measurement that applies to a given column or row in the data package.",	"text",
                       "Definition",	"N/A",	"Description of the information in a given column or row in the dataset.",	"text",
                       "Data_Type",	"N/A",	"Type of data (numeric; text; date; time; datetime).",	"text")

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
  left_join(existing_dd, by = "Column_or_Row_Name") %>% 
  mutate(Unit = coalesce(Unit.y, Unit.x),
         Definition = coalesce(Definition.y, Definition.x)) %>% 
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
  mutate(Data_Type = case_when(Column_or_Row_Name == "p_val" ~ "character", # there is one p_val that's chr, so changing all to text
                               T ~ Data_Type)) %>% 
  mutate(Data_Type = case_when(Data_Type == "character" ~ "text", 
                               T ~ Data_Type)) %>% 
  select(Column_or_Row_Name, Data_Type) %>% 
  distinct()

# join data type to dd
dd <- dd %>% 
  select(-Data_Type) %>% 
  left_join(df_classes, by = "Column_or_Row_Name") %>% 
  full_join(dd_template, by = "Column_or_Row_Name") %>% # add flmd and dd rows info
  mutate(Unit = coalesce(Unit.y, Unit.x),
         Definition = coalesce(Definition.y, Definition.x),
         Data_Type = coalesce(Data_Type.y, Data_Type.x)) %>% 
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
  left_join(headers, by = join_by("Column_or_Row_Name" == "header"))

print(dd_with_header_counts)

#### export ----

# view files before exporting
View(flmd)
View(dd_with_header_counts)

# write out flmd
write_csv(flmd, paste0(out_dir, "/Myers-Pigg_2025_Thresholds_flmd_v0.1.csv"), na = "")

# write out dd
write_csv(dd_with_header_counts, paste0(out_dir, "/Myers-Pigg_2025_Thresholds_dd_v0.1.csv"), na = "")

# open folder
shell.exec(out_dir) # on windows
system(paste0("open '", out_dir, "'")) # on mac


### Create flmd and dd #########################################################
# this chunk updates the flmd and dd after deciding to rename the data package folder names
# FLMD cols: File_Name, File_Description, Standard, Missing_Value_Codes, File_Path
# DD cols: Column_or_Row_Name, Unit, Definition, Data_Type

# input directory (do not include "/" at end of path)
input_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/Wampler_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/Wampler_2025_Thresholds_Manuscript_Data_Package"

# output directory
out_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/Wampler_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/Wampler_2025_Thresholds_Manuscript_Data_Package"

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
data_package_data <- load_tabular_data(directory = input_dir) # say YES to reading tabular files and YES to column headers on first row

#### flmd ----

# read in existing flmd
existing_flmd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Wampler_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/archive/Myers-Pigg_2025_Thresholds_flmd_v0.1.csv") %>% 
  select(File_Name, File_Description)

# create skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative) # say YES to adding placeholder dd and flmds
print(flmd_skeleton)

# update columns
flmd_skeleton <- flmd_skeleton %>% 
  select(-Date_End, -Date_Start)
print(flmd_skeleton)

# update rows
flmd <- flmd_skeleton %>%
  mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.(csv|tsv)$") ~ '"N/A"; "-9999"; ""; "NA"',
                                         T ~ "N/A")) %>% # add missing value codes for .csv files
  mutate(Standard = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # add standard for FLMD
                              str_detect(File_Name, "\\.(csv|tsv)$") ~ "ESS-DIVE CSV v1", # add standard for .csv files
                              T ~ "N/A")) %>% 
  mutate(File_Name = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "Wampler_2025_Thresholds_flmd.csv", # rename flmd and dd
                               str_detect(File_Name, "_dd\\.csv$") ~ "Wampler_2025_Thresholds_dd.csv",
                               T ~ File_Name)) %>% 
  mutate(File_Description = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "File-level metadata that lists and describes all of the files contained in the data package.", # add definitions for flmd and dd
                                      str_detect(File_Name, "_dd\\.csv$") ~ 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
                                      str_detect(File_Name, "readme") ~ 'Data package level readme. Contains data package summary; acknowledgements; and contact information.',
                                      T ~ File_Description)) %>% 
  add_row(File_Name = "readme_Wampler_2025_Thresholds.pdf", # add readme row
          File_Description = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          Standard = "N/A",
          Missing_Value_Codes = "N/A", 
          File_Path = NA_character_) %>% 
  mutate(File_Path = case_when(File_Name %in% c("Wampler_2025_Thresholds_flmd.csv", "Wampler_2025_Thresholds_dd.csv", "readme_Wampler_2025_Thresholds.pdf") ~ "/Wampler_2025_Thresholds_Manuscript_Data_Package", # update file paths
                               T ~ File_Path)) %>% 
  
  # join existing flmd definitions
  left_join(existing_flmd, by = "File_Name") %>% 
  mutate(File_Description = coalesce(File_Description.y, File_Description.x)) %>% 
  select(File_Name, File_Description, Standard, Missing_Value_Codes, File_Path) %>%
  
  # sort rows by readme, flmd, dd, and then by File_Path, File_Name
  mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = F) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(-sort_order)

print(flmd)

#### dd ----

# read in existing flmd
existing_dd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/Wampler_2025_Thresholds_Manuscript_Data_Package/rc_sfa-rc-3-wenas-modeling/archive/Myers-Pigg_2025_Thresholds_dd_v0.1.csv") %>% 
  select(-Data_Type)

# identify column header issues
data_package_data$headers %>% 
  distinct() %>% 
  filter(str_detect(header, fixed("..."))) %>% 
  view() # shows duplicates within the same file

data_package_data$headers %>% 
  count(header) %>% 
  view() # shows duplicates across files

# template
dd_template <- tribble(~Column_or_Row_Name, ~Unit, ~Definition, ~Data_Type,
                       "File_Name",	"N/A",	"Name of files in the data package.", "text",
                       "File_Description",	"N/A",	"A brief description of the files in the data package.",	"text",
                       "Standard",	"N/A",	"ESS-DIVE Reporting Format or other standard applied to the data file.",	"text",
                       "Missing_Value_Codes",	"N/A",	'Cells with missing data are represented with a missing value code rather than an empty cell. This column describes which missing value codes were used. The recommendation for numeric data is "-9999" and for character data is "N/A".',	"text",
                       "File_Path",	"N/A",	"File path within the data package.",	"text",
                       "Column_or_Row_Name",	"N/A",	"Column or row headers from each csv file in the dataset.",	"text",
                       "Unit",	"N/A",	"Unit of measurement that applies to a given column or row in the data package.",	"text",
                       "Definition",	"N/A",	"Description of the information in a given column or row in the dataset.",	"text",
                       "Data_Type",	"N/A",	"Type of data (numeric; text; date; time; datetime).",	"text")

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
  left_join(existing_dd, by = "Column_or_Row_Name") %>% 
  mutate(Unit = coalesce(Unit.y, Unit.x),
         Definition = coalesce(Definition.y, Definition.x)) %>% 
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
  mutate(Data_Type = case_when(Column_or_Row_Name == "p_val" ~ "character", # there is one p_val that's chr, so changing all to text
                               T ~ Data_Type)) %>% 
  mutate(Data_Type = case_when(Data_Type == "character" ~ "text", 
                               T ~ Data_Type)) %>% 
  select(Column_or_Row_Name, Data_Type) %>% 
  distinct()

# join data type to dd
dd <- dd %>% 
  select(-Data_Type) %>% 
  left_join(df_classes, by = "Column_or_Row_Name") %>% 
  full_join(dd_template, by = "Column_or_Row_Name") %>% # add flmd and dd rows info
  mutate(Unit = coalesce(Unit.y, Unit.x),
         Definition = coalesce(Definition.y, Definition.x),
         Data_Type = coalesce(Data_Type.y, Data_Type.x)) %>% 
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
  left_join(headers, by = join_by("Column_or_Row_Name" == "header"))

print(dd_with_header_counts)

#### export ----

# view files before exporting
View(flmd)
View(dd_with_header_counts)

# write out flmd
write_csv(flmd, paste0(out_dir, "/Wampler_2025_Thresholds_flmd.csv"), na = "")

# write out dd
write_csv(dd_with_header_counts, paste0(out_dir, "/Wampler_2025_Thresholds_dd.csv"), na = "")

# open folder
shell.exec(out_dir) # on windows
system(paste0("open '", out_dir, "'")) # on mac
