### data_package_checks.R ######################################################

# Objective: 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Cavaiani_2024_Metaanalysis_Manuscript_Data_Package/rc_sfa-rc-3-wenas-meta" # ran checks on commit 314300dae4064c55bcc0cef976901f1ca757661c
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-RC4-WROL-YRB_DOM_Diversity" # ran checks on commit 6b527ea3acb1c4e0f9bf82d5557215bfc44152a9


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

# combines 1 and 2

# 2. Check files
files_check <- check_files(directory)


# 3. Check tabular data
tabular_data_check <- check_tabular_data(data_package_data)

