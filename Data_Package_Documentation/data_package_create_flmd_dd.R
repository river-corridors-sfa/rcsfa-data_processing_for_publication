### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 

### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs)
library(clipr)
library(tools)

rm(list=ls(all=T))
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

### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_EV_Data_Package/WHONDRS_EV_Data_Package" 

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_EV_Data_Package/WHONDRS_EV_Data_Package"
  

### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 

# 1. Load data. 
# TIP: to exclude/include multiple files, go to the directory > select all > copy path. Paste within c(). Click alt + shift + drag cursor over all lines > click "End" on keyboard > add a comma.
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

# left join prelim dd to this dd

prelim_dd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_EV_Data_Package/EC_dd.csv")


dd_skeleton <- dd_skeleton %>%
  select(Column_or_Row_Name) %>%
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  arrange(Column_or_Row_Name)

# left join prelim flmd to this flmd

prelim_flmd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_EV_Data_Package/EC_flmd.csv") %>%

  select(-File_Path)

flmd_skeleton <- flmd_skeleton %>%
  select(File_Name, File_Path) %>%
  left_join(prelim_flmd, by = c("File_Name")) %>%
  select(-File_Path, File_Path)

### join headers to dd #########################################################
# get headers
# headers <- data_package_data$headers %>%
#   mutate(relative_file = basename(file)) %>%
#   group_by(header) %>% 
#   summarise(header_count = n(),
#             file_name = toString(relative_file),
#             file_path = toString(file)) %>% 
#   ungroup() %>% 
#   arrange(header, .locale = "en")
# 
# 
# dd_skeleton_with_header_source <- dd_skeleton_populated %>% 
#   left_join(headers, by = c("Column_or_Row_Name" = "header")) %>% 
#   select(-file_path)



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


