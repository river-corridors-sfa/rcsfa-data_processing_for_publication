### data_package_checks.R ######################################################

# Objective: 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Kassianov_2023_AML_Plumes_Manuscript_Data_Package"

# provide the name of the person running the checks
report_author <- "Bibi Powers-McCormack"


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs) # for tree diagram
library(clipr) # for copying to clipboard
library(knitr) # for kable
library(kableExtra) # for rmd report table styling
library(DT) # for interactive tables in report
library(rmarkdown) # for rendering report
library(plotly) # for interactive graphs

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
tabular_data_check <- check_tabular_data(data_package_data)


# 4. Generate report
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document")
browseURL("./Data_Package_Validation/functions/checks_report.html")

