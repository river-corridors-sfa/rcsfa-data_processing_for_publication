### data_package_checks.R ######################################################

# Objective: 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Muller_2023_Lambda_Pipeline_Manuscript_Data_Package/manuscript_files"


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs) # for tree diagram
library(clipr) # for copying to clipboard

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()

# load functions
source("./Data_Transformation/functions/load_tabular_data.R")
source("./Data_Package_Validation/functions/check_files.R")
source("./Data_Package_Validation/functions/check_tabular_data.R")


### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.

# 1. Load data
data_package_data <- load_tabular_data(directory)


# 2. Check files
files_check <- check_files(directory)


# 3. Check tabular data
tabular_data_check <- check_tabular_data()
