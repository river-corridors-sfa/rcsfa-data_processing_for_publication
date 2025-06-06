### data_package_update_database.R #############################################

# Objective: Run this script to add new DD and FLMD entries to their respective databases.


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.
# Review the comments within each function for additional details on the input arguments and how the functions work. 

# provide the date when the associated data package became publicly available, formatted as "YYYY-MM-DD". Use "Sys.Date()" if it was published today.
my_publish_date <- Sys.Date()

# provide the absolute file path of the new DD to add
my_dd <- ""

# provide the absolute file path of the new FLMD to add
my_flmd <- ""

# absolute file path of the DD database
dd_database_dir <- ""

# absolute file path of the FLMD database
flmd_database_dir <- ""


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


### Bulk populate already existing DPs into databases ##########################

# The first objective is to get the publish date for each data package (we can
# do this by matching up airtable (where we record the publish date) and the
# list of FLMD and DDs in the Share Drive).

# To do this, Brie pulled a list of all files that match "*dd.csv" and
# "*flmd.csv" within "Z:\00_ESSDIVE\01_Study_DPs\00_ARCHIVE-WHEN-PUBLISHED" with
# https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Transformation/query_dd_flmd_archive.R
# and filtered out additional data packages that we don't want to include in the
# database (like manuscript DPs or any files in an Archive sub directory).

# Bibi downloaded the Air Table "Data and Manuscript Publishing Hub/Published
# Brief"
# (https://airtable.com/appz3RK7NO8J0JSS8/tblgBk7IgkZWSHZnk/viw490CheMt2eUys0?blocks=hide)
# as "AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv" so we
# can get the publish date.

# Bibi then manually matched up the short name in airtable with the share drive
# file path. The "Exclude" files are manuscript data packages that we're not
# including in the databases. Then those two files were brought into this script
# to join together.


# read in files
archived_list <- read_csv("./Data_Package_Documentation/database/All_dd_flmd_as_of_2025-06-05.csv")

airtable <- read_csv("./Data_Package_Documentation/database/AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv") %>% 
  mutate(Publish_Date = mdy(Publish_Date)) %>% 
  rename(airtable_title = `Dataset Summary Title`)

# join file path with publish date
filtered_archived_list <- archived_list %>% 
  left_join(airtable, by = join_by(airtable_title)) %>% 
  filter(is.na(exclude)) %>% # remove manuscript DPs from list
  select(airtable_title, archived_dd_flmd, sans_dir, Link, Publish_Date)

# separate flmd and dds
dd_list <- filtered_archived_list %>% 
  filter(str_detect(archived_dd_flmd, "dd\\.csv$")) %>% 
  arrange(Publish_Date)

flmd_list <- filtered_archived_list %>% 
  filter(str_detect(archived_dd_flmd, "flmd\\.csv$")) %>% 
  arrange(Publish_Date)

nrow(filtered_archived_list) == nrow(dd_list) + nrow(flmd_list)

# loop to add flmds to database

for (i in 1:nrow(flmd_list)) {
  
  
  my_flmd <- flmd_list$archived_dd_flmd[i]
    
  my_publish_date <- flmd_list$Publish_Date[i]
    
  flmd_database_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-data_proceesing_for_publication/Data_Package_Documentation/database/file_level_metadata_database.csv"

  log_warn(paste0("File ", i, " of ", nrow(flmd_list)))
  
  flmd_database <- update_flmd_database(flmd_abs_file = my_flmd,
                                        date_published = my_publish_date, 
                                        flmd_database_abs_dir = flmd_database_dir)
}


# loop to add dds to database

for (i in 1:nrow(dd_list)) {
  
  my_dd <- dd_list$archived_dd_flmd[i]
  
  my_publish_date <- dd_list$Publish_Date[i]
  
  dd_database_dir <- "C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-data_proceesing_for_publication/Data_Package_Documentation/database/data_dictionary_database.csv"
  
  log_warn(paste0("File ", i, " of ", nrow(dd_list)))
  
  dd_database <- update_dd_database(dd_abs_file = my_dd, 
                                    date_published = my_publish_date, 
                                    dd_database_abs_dir = dd_database_dir)
}
  