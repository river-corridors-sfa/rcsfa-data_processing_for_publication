### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/Barton_2025_Coastal_Fires_Levo/CoastalFires_Data_Package"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/Barton_2025_Coastal_Fires_Levo/CoastalFires_Data_Package"
  

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
# # left join prelim dd to this dd
# 
# prelim_dd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/SSF_Data_Package_v2/SSF_dd.csv") 
# 
# dd_skeleton <- dd_skeleton %>%
#   select(Column_or_Row_Name) %>%
#   left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
#   arrange(Column_or_Row_Name) 
# 
# view(prelim_dd%>%
#   select(Column_or_Row_Name) %>%
#   anti_join(dd_skeleton, by = c("Column_or_Row_Name")))
# 
# # left join prelim flmd to this flmd
# 
# prelim_flmd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/SSF_Data_Package_v2/SSF_flmd.csv")%>%
#   select(-File_Path)
# 
# flmd_skeleton <- flmd_skeleton %>%
#   select(File_Name, File_Path) %>%
#   mutate(temp = str_remove(File_Name, 'v2_')) %>%
#   left_join(prelim_flmd, by = c(temp = "File_Name")) %>%
#   select(-File_Path, File_Path)


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


