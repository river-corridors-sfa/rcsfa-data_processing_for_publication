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

#### REQUIRED ----

# provide the absolute folder file path (do not include "/" at end)
user_directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Regier_2025_d50_v2/d50_computer_vision"

# provide the name of the person running the checks
report_author <- "Bibi Powers-McCormack"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Regier_2025_d50_v2"

# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- F

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- F

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- ""


#### OPTIONAL ----

# TIPS for including/excluding files: 
  # Example 1: Suppose your data package contains 100 sensor files with
  # standardized "Goldman" headers and 5 regular CSV files. Instead of writing
  # out all 100 file names just to exclude them, you can use the include_files
  # argument to explicitly list the 5 files you do want to process. This is more
  # efficient and makes your code easier to manage.
  
  # Example 2: If you have 75 regular files and 3 files with header rows, you
  # can process them separately by first running the function with
  # query_header_info = TRUE and include_files set to the 3 files to extract
  # their header metadata. Then, run the function again with query_header_info =
  # FALSE and exclude_files set to the same 3 files to process the 75 regular
  # files.

# exclude_files = vector of files (relative file path + file name; no / at beginning of path) to exclude from within the dir. Optional argument; default is NA_character_. (Tip: Select files in file browser. Click "Copy Path". Paste within c() here. To add commas: Shift+Alt > drag to select all lines > end > comma) 
user_exclude_files = NA_character_

# include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA_character_. 
user_include_files = NA_character_

# include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE.
user_include_dot_files = F


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
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Transformation/functions/load_tabular_data.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")

### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.

# confirm directory has files in it
if (length(list.files(user_directory, recursive = T)) == 0) {
  warning("Your directory has 0 files.")
}

# 1. Get all files
dp_files <- get_files(directory = user_directory, 
                      exclude_files = user_exclude_files, 
                      include_files = user_include_files, 
                      include_dot_files = user_include_dot_files)


# 2. Load flmd if applicable
if (has_flmd == T) {
  data_package_flmd <- read_csv(flmd_path) %>% 
  # convert to R's NA
  mutate(across(everything(), ~ case_when(. == -9999 ~ NA, 
                                          . == "N/A" ~ NA,
                                          TRUE ~ .)))
} else if (has_flmd == F) {
  data_package_flmd <- NA 
  }


# 3. Load data
data_package_data <- load_tabular_data(files_df = dp_files, flmd_df = data_package_flmd, query_header_info = user_input_has_header_rows)

# preview data - this shows all the tabular data you loaded in so you can quickly check if it loaded in correctly without having to poke around in the nested lists
invisible(lapply(names(data_package_data$tabular_data), function(name) {
  cat("/n--- Data Preview of", name, "---/n")
  glimpse(data_package_data$tabular_data[[name]])
}))


# 4. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)


# 5. Generate report
out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document", output_dir = report_out_dir, output_file = out_file)
browseURL(paste0(report_out_dir, "/", out_file))

