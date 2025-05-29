### data_package_checks.R ######################################################

# Objective: Use this script to run data package checks.

# This script walks you through the steps to read in the data and run it through
# the checks. It relies on `checks.R`, which is the script that houses the
# functions that validate the data and produce tabular outputs. Those tabular
# outputs are then read into the `checks_report.Rmd` file to create the graphics
# and visual report.

# See README_data_package_checks.md for more details on how to run or update the
# checks.

rm(list=ls(all=T))

### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (provide absolute directory; do not include a "/" at the end)
directory <- "C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/Barton_2025_Coastal_Fires_Levo/CoastalFires_Data_Package"

# provide the name of the person running the checks
report_author <- "Brieanne Forbes"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- "C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/Barton_2025_Coastal_Fires_Levo"

# do the tabular files have header rows? (T/F)
user_input_has_header_rows <- T

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



# set working dir
current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("./..")

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Transformation/functions/load_tabular_data_from_flmd.R") # note: will need to update this link after I merge branches
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")

### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.

# confirm directory has files in it
if (length(list.files(directory, recursive = T)) == 0) {
  warning("Your directory has 0 files.")
}

# 1. Load flmd if applicable
if (has_flmd == T) {
  data_package_flmd <- read_csv(flmd_path) %>% 
  # convert to R's NA
  mutate(across(everything(), ~ case_when(. == -9999 ~ NA, 
                                          . == "N/A" ~ NA,
                                          TRUE ~ .)))
} else if (has_flmd == F) {
  data_package_flmd <- NA 
  }


# 2. Load data
data_package_data <- load_tabular_data_from_flmd(directory = directory, flmd_df = data_package_flmd, query_header_info = user_input_has_header_rows,
                                                 exclude_files = )

# preview data - this shows all the tabular data you loaded in so you can quickly check if it loaded in correctly without having to poke around in the nested lists
invisible(lapply(names(data_package_data$tabular_data), function(name) {
  cat("/n--- Data Preview of", name, "---/n")
  glimpse(data_package_data$tabular_data[[name]])
}))


# 3. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)


# 4. Generate report
out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document", output_dir = report_out_dir, output_file = out_file)
browseURL(paste0(report_out_dir, "/", out_file))

