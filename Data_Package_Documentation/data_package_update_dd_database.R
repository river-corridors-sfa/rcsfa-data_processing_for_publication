### data_package_update_dd_database.R ##########################################
# Date Created: 2024-04-30
# Date Updated: 2024-04-30
# Author: Bibi Powers-McCormack

# Objective: This script will generate a static list of all the times the ddd was updated. 

# Assumptions: 
  # DO NOT RERUN this script. If you rerun this script in its entirety, it might create duplicate entries in the database.
  # Only run the lines when you add them. 


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(tidyverse)
library(rlog)

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()


# load functions
source("./Data_Package_Documentation/functions/update_dd_database.R")

# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### RECORD KEEPING #############################################################
# Directions: Add new data package(s) to the growing list and only run the ones you add. 

# MANUSCRIPT DATA PACKAGES ----
update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Bao_2023_Residence_Time_Distribution_Manuscript_Data_Package/Bao_2024_Residence_Time_Distribution_Data_Package/Bao_2024_Residence_Time_Distribution_dd.csv")



# STUDY DATA PACKAGES ----


