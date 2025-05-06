### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Barnes_2024_BSLE_P_Gradient_Manuscript_Data_Package/rcsfa-RC3-BSLE_P/Barnes_2024_BSLE_P_Gradient"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Barnes_2024_BSLE_P_Gradient_Manuscript_Data_Package/rcsfa-RC3-BSLE_P/Barnes_2024_BSLE_P_Gradient"
  

### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs)
library(clipr)
library(tools)

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()
original_wd <- getwd()

# load functions
source("./Data_Transformation/functions/load_tabular_data.R")
source("./Data_Package_Documentation/functions/create_dd_skeleton.R")
source("./Data_Package_Documentation/functions/create_flmd_skeleton.R")
source("./Data_Package_Documentation/functions/query_dd_database.R")
source("./Data_Package_Documentation/functions/query_flmd_database.R")


# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 


# 1. Load data
# for excluding or including files, write the relative path from the directory, without slash in the beginning
data_package_data <- load_tabular_data(directory)


# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
# dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
# flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)

### DP Specific Edits ##########################################################

# join to prelim flmd ----

# read in prelim
prelim_flmd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/Barnes_2024_BSLE_P_Gradient_Manuscript_Data_Package/Archive/prelim_Barnes_2023_BSLE_P_Gradient_flmd.csv", skip = 1) %>% 
  mutate(File_Path = str_replace(File_Path, "rcsfa-RC3-BSLE_P", "Barnes_2024_BSLE_P_Gradient")) # fix parent folder 
  

flmd_skeleton_populated <- flmd_skeleton %>% 
  
# update columns
  select(-Date_Start, -Date_End) %>% 
  
# update rows
  filter(!str_detect(File_Path, "/rcsfa-RC3-BSLE_P/.git"),
         !File_Name %in% c(".gitignore", "README.md", "lock_file", "LICENSE")) %>% # remove git files
  mutate(File_Path = str_replace(File_Path, "rcsfa-RC3-BSLE_P", "Barnes_2024_BSLE_P_Gradient")) %>% # fix parent folder
  mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.(csv|tsv)$") ~ '"N/A"; "-9999"; ""; "NA"',
                                         T ~ "N/A")) %>% # add missing value codes for .csv files
  mutate(Standard = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # add standard for FLMD
                              str_detect(File_Name, "\\.(csv|tsv)$") ~ "ESS-DIVE CSV v1", # add standard for .csv files
                              T ~ "N/A")) %>% 
  mutate(File_Name = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "Barnes_2024_BSLE_P_Gradient_flmd.csv", # rename flmd and dd
                               str_detect(File_Name, "_dd\\.csv$") ~ "Barnes_2024_BSLE_P_Gradient_dd.csv",
                               T ~ File_Name)) %>% 
  mutate(File_Description = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "File-level metadata that lists and describes all of the files contained in the data package.", # add definitions for flmd and dd
                                      str_detect(File_Name, "_dd\\.csv$") ~ 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
                                      T ~ File_Description)) %>% 
  add_row(File_Name = "readme_Barnes_2024_BSLE_P_Gradient.pdf", # add readme row
          File_Description = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          Standard = "N/A",
          Missing_Value_Codes = "N/A", 
          File_Path = NA_character_) %>% 
  mutate(File_Path = case_when(File_Name %in% c("Barnes_2024_BSLE_P_Gradient_flmd.csv", "Barnes_2024_BSLE_P_Gradient_dd.csv", "readme_Barnes_2024_BSLE_P_Gradient.pdf") ~ "/Barnes_2024_BSLE_P_Gradient", # update file paths
                               T ~ File_Path)) %>% 
  select(File_Name, File_Description, Standard, Missing_Value_Codes, File_Path) %>%
  
  # sort rows by readme, flmd, dd, and then by File_Path, File_Name
  mutate(sort_order = case_when(grepl("readme_Barnes", File_Name, ignore.case = F) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(-sort_order)


# join to prelim dd ----

# read in prelim
prelim_dd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/Barnes_2024_BSLE_P_Gradient_Manuscript_Data_Package/Archive/prelim_Barnes_2023_BSLE_P_Gradient_dd.csv", skip = 1) %>% 
  select(Column_or_Row_Name, Unit, Definition, Data_Type)
  
dd_skeleton_populated <- dd_skeleton %>% 
# update columns
  filter(!Column_or_Row_Name %in% c("Date_End", "Date_Start", "Term_Type")) %>% # remove columns dropped when updating flmd and dd columns
  
  # join existing dd cols
  select(Column_or_Row_Name) %>%
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  arrange(Column_or_Row_Name) %>% 
  select(Column_or_Row_Name, Unit, Definition, Data_Type) %>% 

# update rows
  mutate(Data_Type = case_when(Column_or_Row_Name %in% c("Column_or_Row_Name", "Data_Type", "Standard","Missing_Value_Codes", "Parent_ID", "Sample_Name") ~ "text", 
                               T ~ Data_Type),
         Unit = case_when(tolower(Unit) %in% c("energy_electronvolt", "elevtronvolts", "electronvolts") ~ "electronvolt",
                     Unit %in% c("parts_per_million") ~ "parts per million", 
                     T ~ Unit))

### Export #####################################################################
# Directions: 
  # Export out .csvs at your choosing. Only run the lines you want. 
  # After exporting, remember to properly rename the dd and flmd files and to update the flmd to reflect such changes.

# write out data package data
save(data_package_data, file = paste0(out_directory, "/data_package_data.rda"))

# write out skeleton dd
write_csv(dd_skeleton, paste0(out_directory, "/skeleton_dd.csv"), na = "")

# write out populated dd
write_csv(dd_skeleton_populated, paste0(out_directory, "/skeleton_populated_dd.csv"), na = "")

# write out skeleton flmd
write_csv(flmd_skeleton, paste0(out_directory, "/skeleton_flmd.csv"), na = "")

# writ eout populated flmd
write_csv(flmd_skeleton_populated, paste0(out_directory, "/skeleton_populated_flmd.csv"), na = "")

# open the directory the files were saved to
shell.exec(out_directory)


