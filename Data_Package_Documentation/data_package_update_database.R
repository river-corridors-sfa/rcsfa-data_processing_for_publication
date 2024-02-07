### data_package_update_database.R #############################################

# Objective: 
  # Run this script to add new dd and flmd entries to their respective databases.


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/CM_SSS_Data_Package_v3/v3_CM_SSS_Data_Package"


### Prep Script ################################################################
# Directions: 
# 1. Set working directory to the `rcsfa-data-processing` repo.
# 2. Then run this chunk without modification.

# confirm that the working directory is set to this GitHub repo (rcsfa-data-processing-for-publication), otherwise setwd() in the console
getwd()

# load libraries
library(tidyverse)
library(rlog)

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