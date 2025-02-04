### data_package_checks.R ######################################################

# Objective: Use this script to run all data package checks.

# This script walks you through the steps to download the data and run it
# through the checks. It relies on `checks.R`, which is the script that
# validates the data and produces tabular outputs. Those tabular outputs are
# then read into the `checks_report.Rmd` file and creates the graphics and
# visual report.


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_ESSDIVE/03_Manuscript_DPs/00_ARCHIVE-WHEN-PUBLISHED/Kassianov_2023_AML_Plumes_Manuscript_Data_Package/Kassianov_2023_AML_Plumes"

# provide the name of the person running the checks
report_author <- "Bibi Powers-McCormack"


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
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

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
setwd(here())
getwd()

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Transformation/functions/load_tabular_data_from_flmd.R") # note: will need to update this link after I merge branches
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Package_Documentation/functions/create_flmd_skeleton_v2.R") # note: will need to update this link after I merge branches
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/data_checks_v2/Data_Package_Validation/functions/checks.R") # note: will need to update this link after I merge branches

### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.

# 1. Load flmd
data_package_flmd <- create_flmd_skeleton(directory = directory) %>% 
  # convert to R's NA
  mutate(across(everything(), ~ case_when(. == -9999 ~ NA, 
                                          . == "N/A" ~ NA,
                                          TRUE ~ .)))

# 2. Load data
data_package_data <- load_tabular_data_from_flmd(directory = directory, flmd_df = data_package_flmd)


# 3. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)


# 4. Generate report
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document")
browseURL("./Data_Package_Validation/functions/checks_report.html")

