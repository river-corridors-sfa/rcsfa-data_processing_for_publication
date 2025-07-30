### data_package_update_database.R #############################################

# Objective: Run this script to add new DD and FLMD entries to their respective databases.


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.
# Review the comments within each function for additional details on the input arguments and how the functions work. 

# provide the date when the associated data package became publicly available, formatted as "YYYY-MM-DD". Use "Sys.Date()" if it was published today.
my_publish_date <- Sys.Date()
# my_publish_date <- '2025-07-21'
  
# provide the absolute file path of the new DD to add
my_dd <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/RC2_TemporalStudy_2022-2024_SensorData/RC2_TemporalStudy_2022_2024_SensorData/RC2_2022_2024_dd.csv"

# provide the absolute file path of the new FLMD to add
my_flmd <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/RC2_TemporalStudy_2022-2024_SensorData/RC2_TemporalStudy_2022_2024_SensorData/RC2_2022_2024_flmd.csv"

# absolute file path of the DD database
dd_database_dir <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/data_dictionary_database.csv"

# absolute file path of the FLMD database
flmd_database_dir <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/file_level_metadata_database.csv"


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(tidyverse)
library(rlog)
library(devtools)
library(lubridate)

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()

# load functions
source("./Data_Package_Documentation/functions/update_dd_database.R")
source("./Data_Package_Documentation/functions/update_flmd_database.R")


### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 

# 1. Update DD database
dd_database <- update_dd_database(dd_abs_file = my_dd, 
                                  date_published = my_publish_date, 
                                  dd_database_abs_dir = dd_database_dir)


# 2. Update FLMD database
flmd_database <- update_flmd_database(flmd_abs_file = my_flmd,
                                      date_published = my_publish_date, 
                                      flmd_database_abs_dir = flmd_database_dir)

# 3. Optionally view databases
View(dd_database)
View(flmd_database)
