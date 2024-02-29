### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-RC4-WROL-YRB_DOM_Diversity" # commit 6b527ea3acb1c4e0f9bf82d5557215bfc44152a9

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/INBOX"
  

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
data_package_data_1 <- load_tabular_data(directory, include_files = c("data/ancillary_chemistry/RC2_NPOC_TN_DIC_TSS_Ions_Summary_2021-2022.csv",
                                                                      "data/waterTemp/RC2_Ultrameter_WaterChem_Summary.csv")) # loads in files where col headers are NOT on line 0

data_package_data_2 <- load_tabular_data(directory, exclude_files = c("data/ancillary_chemistry/RC2_NPOC_TN_DIC_TSS_Ions_Summary_2021-2022.csv",
                                                                      "data/waterTemp/RC2_Ultrameter_WaterChem_Summary.csv")) # loads in files where col headers ARE on line 0

data_package_data <- list(
  directory = data_package_data_1$directory,
  file_paths = c(data_package_data_1$file_paths, data_package_data_2$file_paths),
  file_paths_relative = c(data_package_data_1$file_paths_relative, data_package_data_2$file_paths_relative),
  data = c(data_package_data_1$data, data_package_data_2$data),
  headers = rbind(data_package_data_1$headers, data_package_data_2$headers)
)


# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)


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



