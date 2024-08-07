### data_package_checks.R ######################################################

# Objective: Use this script to run all data package checks.


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Kassianov_2023_AML_Plumes_Manuscript_Data_Package/Kassianov_2023_AML_Plumes"

# provide the name of the person running the checks
report_author <- "Bibi Powers-McCormack"


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(devtools) # for sourcing from github
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
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Transformation/functions/load_tabular_data_from_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Package_Documentation/functions/create_flmd_skeleton_v2.R")

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



# 4. Generate report
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document")
browseURL("./Data_Package_Validation/functions/checks_report.html")

