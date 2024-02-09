### data_package_update_database.R #############################################

# Objective: 
  # Run this script to add new dd and flmd entries to their respective databases.


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/CM_SSS_Data_Package_v3/v3_CM_SSS_Data_Package"

# load libraries
library(tidyverse)
library(rlog)


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()


# load functions
source("./Data_Package_Documentation/functions/update_dd_database.R")
source("./Data_Package_Documentation/functions/update_flmd_database.R")


# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")



### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 

# 1. Update data dictionary database
dd_database <- update_dd_database(directory)


# 2. Update file-level metadata database