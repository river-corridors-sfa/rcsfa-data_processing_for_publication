### data_package_create_flmd_dd.R ##############################################
# Date Created: 2024-02-01
# Author: Bibi Powers-McCormack

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Muller_2023_Lambda_Pipeline_Manuscript_Data_Package/manuscript_files"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Muller_2023_Lambda_Pipeline_Manuscript_Data_Package/manuscript_files"
out_directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/INBOX"
  

### Prep Script ################################################################
# Directions: 
  # 1. Set working directory to the `rcsfa-data-processing` repo.
  # 2. Then run this chunk without modification.

# confirm that the working directory is set to this GitHub repo (rcsfa-data-processing-for-publication), otherwise setwd() in the console
getwd()

# load libraries
library(tidyverse)
library(rlog)
library(fs)
library(clipr)

# load functions
source("./Data_Transformation/functions/load_tabular_data.R")
source("./Data_Package_Documentation/functions/create_dd_skeleton.R")
source("./Data_Package_Documentation/functions/create_flmd_skeleton.R")
source("./Data_Package_Documentation/functions/query_dd_database.R")

# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 

# 1. Load data
data_package_data <- load_tabular_data(directory)


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
  # Remember to properly name the dd and flmd files and to update the flmd to reflect such changes.


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



