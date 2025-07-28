### data_package_checks_github_action.R ########################################

# Objective: Use this script to run data package checks.

# This script walks you through the steps to read in the data and run it through
# the checks. It relies on `checks.R`, which is the script that houses the
# functions that validate the data and produce tabular outputs. Those tabular
# outputs are then read into the `checks_report.Rmd` file to create the graphics
# and visual report.

# See README_data_package_checks.md for more details on how to run or update the
# checks.

# This is a simplified version of data_package_checks.R used specifically within
# a github action. 

rm(list=ls(all=T))

### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

#### REQUIRED ----

# provide the absolute folder file path (do not include "/" at end)
user_directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/ECA_DOM_Thermodynamics"

# provide the name of the person running the checks
report_author <- "Bibi Powers-McCormack"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- "C:/Users/powe419/Downloads"


# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- F

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- F

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- ""


### Prep Script ################################################################
# Directions: Run this chunk without modification.

library(here) # for setting wd at git repo
library(tidyverse)
library(rlog)
library(devtools) # for sourcing from github
library(hms) # for handling times
library(fs) # for tree diagram
library(clipr) # for copying to clipboard
library(knitr) # for kable
library(kableExtra) # for rmd report table styling
library(DT) # for interactive tables in report
library(rmarkdown) # for rendering report
library(plotly) # for interactive graphs
library(downloadthis) # for downloading tabular data report as .csv

current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("./..")

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Transformation/functions/load_tabular_data.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")

### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.


# 1. Get all files
dp_files <- get_files(directory = user_directory)


# 2. Load data
data_package_data <- load_tabular_data(files_df = dp_files)

# 4. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)


# 5. Generate report
out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document", output_dir = report_out_dir, output_file = out_file)

