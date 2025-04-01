### Regier_2024_WRB_YRB_Scaling_DP_Prep.R ######################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-06
# Date Updated: 2025-03-26

# Objective: Prepare Peter's Scaling manuscript data package

# Assumptions: 
  # Each code chunk was run independently from the rest. 


### Confirm author list ########################################################
# this chunk checks to see if the authors listed in the ess-dive metadata are in our master author list

# Inputs: 
  # author spreadsheet
  # copy and pasted author names from ess-dive metadata file

# Outputs
  # df with all authors and information copied to clipboard


# load libraries
library(tidyverse)
library(readxl)
library(janitor)

# import author names - copied from ess-dive metadata doc
manuscript_authors <- tribble(~full_name,
                              "Peter Regier",
                              "Kyongho Son",
                              "Xingyuan Chen",
                              "Yilin Fang",
                              "Peishi Jiang",
                              "Micah Taylor",
                              "Wil Wollheim",
                              "Beck Powers-McCormack",
                              "Brieanne Forbes",
                              "Amy E. Goldman",
                              "James C. Stegen") %>%
  separate(col = full_name, into = c("first_name", "middle_name", "last_name"), sep = " ", fill = "right") %>% 
  mutate(last_name = case_when(is.na(last_name) ~ middle_name, T ~ last_name),
         middle_name = case_when(last_name == middle_name ~ NA_character_, T ~ middle_name))

# import author spreadsheet
author_spreadsheet <- read_excel("Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx", trim_ws = T) %>% 
  clean_names()

# merge authors
manuscript_author_info <- manuscript_authors %>% 
  left_join(author_spreadsheet, by = c("first_name", "middle_name", "last_name")) %>% 
  rename(email = e_mail,
         affiliation = institution) %>% 
  unite("first_name", first_name, middle_name, sep = " ", na.rm = T) %>% 
  select(first_name, last_name, email, orcid, affiliation)

manuscript_author_info


### Add authors to landing page ################################################

# first run the "Confirm author list" chunk

# load libraries
library(tidyverse)
library(rlog)
library(glue)
library(devtools) # for sourcing in script
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_authors.R")

### Fill out arguments 
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "" # i added this in the console

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-1ce1ff991d54325-20250306T184121991"

# this is the author data frame you already made
your_author_df <- manuscript_author_info

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "main" 


### Run function 

update_landing_page_authors(api_token = your_api_token,
                            essdive_id = your_essdive_id,
                            author_df = your_author_df,
                            upload_site = your_upload_site)


### Check for new/removed files ################################################
# this chunk compares the old flmd with the all the files currently in the repo

library(tidyverse)

# read in previous flmd
prelim_flmd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/Archive/Regier_2024_WRB_YRB_Scaling_flmd_v0.2.csv")

# get relative files from v1 flmd
v1_files <- prelim_flmd %>% 
  mutate(v1_files = paste0(File_Path, "/", File_Name)) %>% 
  select(v1_files)

# list current files
v2_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/rc_wrb_yrb_scaling/"
setwd(v2_dir)
v2_files <- tibble(v2_files = list.files(v2_dir, recursive = T)) %>% 
  mutate(v2_files = paste0("/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/", v2_files))

# compare
# files in v1 but not in v2 (removed files)
setdiff(v1_files$v1_files, v2_files$v2_files) 
removed <- anti_join(v1_files, v2_files, join_by("v1_files" == "v2_files"))

# files in v2 but not in v1 (added files)
setdiff(v2_files$v2_files, v1_files$v1_files)
added <- anti_join(v2_files, v1_files, join_by("v2_files" == "v1_files"))


prelim_flmd %>% 
  filter(str_detect(File_Description, regex("removed", ignore_case = T))) %>% 
  pull(File_Name)
  

### Prepare flmd and dd ########################################################
# this chunk creates the flmd and dds based on Peter's GitHub repo
# FLMD cols: File_Name, File_Description, Standard, Missing_Value_Codes, File_Path
# DD cols: Column_or_Row_Name, Unit, Definition, Data_Type

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/rc_wrb_yrb_scaling"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package"

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
prelim_flmd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/Archive/Regier_2024_WRB_YRB_Scaling_flmd_v0.2.csv") %>% 
  select(File_Name, File_Description, File_Path)

# create skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative) # say YES to adding placeholder dd and flmds

# update columns
flmd_skeleton <- flmd_skeleton %>% 
  select(-Date_Start, -Date_End)

# update rows
flmd <- flmd_skeleton %>%
  filter(!str_detect(File_Path, "/rc_wrb_yrb_scaling/.git"),
         !File_Name %in% c(".gitignore", "README.md", "lock_file", "LICENSE")) %>% # remove git files
  mutate(File_Path = str_replace(File_Path, "rc_wrb_yrb_scaling", "Regier_2024_WRB_YRB_Scaling")) %>% # fix parent folder
  select(File_Name, File_Path) %>%
  left_join(prelim_flmd, by = c("File_Name", "File_Path")) %>% # join to prelim
  mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.(csv|tsv)$") ~ '"N/A"; "-9999"; ""; "NA"',
                                         T ~ "N/A")) %>% # add missing value codes for .csv files
  mutate(Standard = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # add standard for FLMD
                              str_detect(File_Name, "\\.(csv|tsv)$") ~ "ESS-DIVE CSV v1", # add standard for .csv files
                              T ~ "N/A")) %>% 
  mutate(File_Name = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "Regier_2024_WRB_YRB_Scaling_flmd.csv", # rename flmd and dd
                               str_detect(File_Name, "_dd\\.csv$") ~ "Regier_2024_WRB_YRB_Scaling_dd.csv",
                               T ~ File_Name)) %>% 
  mutate(File_Description = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "File-level metadata that lists and describes all of the files contained in the data package.", # add definitions for flmd and dd
                                      str_detect(File_Name, "_dd\\.csv$") ~ 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
                                      str_detect(File_Name, "readme") ~ 'Data package level readme. Contains data package summary; acknowledgements; and contact information.',
                                      T ~ File_Description)) %>% 
  add_row(File_Name = "readme_Regier_2024_WRB_YRB_Scaling.pdf", # add readme row
          File_Description = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          Standard = "N/A",
          Missing_Value_Codes = "N/A", 
          File_Path = NA_character_) %>% 
  mutate(File_Path = case_when(File_Name %in% c("Regier_2024_WRB_YRB_Scaling_flmd.csv", "Regier_2024_WRB_YRB_Scaling_dd.csv", "readme_Regier_2024_WRB_YRB_Scaling.pdf") ~ "/Regier_2024_WRB_YRB_Scaling_Data_Package", # update file paths
                               T ~ File_Path)) %>% 
  select(File_Name, File_Description, Standard, Missing_Value_Codes, File_Path) %>%
  
  # sort rows by readme, flmd, dd, and then by File_Path, File_Name
  mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = F) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(-sort_order)

#### dd ----

# read in v1 dd
prelim_dd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/Archive/Regier_2024_WRB_YRB_Scaling_dd_v0.2.csv")

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
  select(Column_or_Row_Name) %>%
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  add_row(dd_template) %>% 
  arrange(Column_or_Row_Name) %>% 
  select(Column_or_Row_Name, Unit, Definition, Data_Type)

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


#### export ----

# view files before exporting
View(flmd)
View(dd)

# write out flmd
write_csv(flmd, paste0(out_directory, "/Regier_2024_WRB_YRB_Scaling/Regier_2024_WRB_YRB_Scaling_flmd.csv"), na = "")

# write out dd
write_csv(dd, paste0(out_directory, "/Regier_2024_WRB_YRB_Scaling/Regier_2024_WRB_YRB_Scaling_dd.csv"), na = "")

# open folder
shell.exec(out_directory) # on windows
system(paste0("open '", out_directory, "'")) # on mac

