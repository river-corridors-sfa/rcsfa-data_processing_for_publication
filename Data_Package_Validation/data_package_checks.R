### data_package_checks.R ######################################################

# Objective: 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Regier_2024_WRB_YRB_Scaling_Manuscript_Data_Package/rc_wrb_yrb_scaling" # commit 65ca2a817ca088383d8fe4faee0d69aa2b32bd3c


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs) # for tree diagram
library(clipr) # for copying to clipboard
library(knitr) # for kable

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

# combines 1 and 2

# 2. Check files
files_check <- check_files(directory)


# 3. Check tabular data
tabular_data_check <- check_tabular_data(data_package_data)

