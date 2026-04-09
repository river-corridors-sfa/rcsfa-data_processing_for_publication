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
user_directory <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Data_Package'

# provide the name of the person running the checks
report_author <- "Brieanne Forbes"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Data_Package'

# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- T

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- T

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Data_Package/WHONDRS_TAP_flmd.csv"

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

user_exclude_files = c("WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAPBLK01_ICR-1_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP001_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP001_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP001_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP001_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP001_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP001_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP002_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP002_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP002_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP002_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP002_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP002_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP003_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP004_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP005_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP006_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP007_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP008_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP009_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP010_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP011_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP011_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP011_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP011_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP011_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP011_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-1_p025.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-1_p025.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-1_p025.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-3_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-3_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP012_ICR-3_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP013_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-1_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-1_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-1_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-3_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-3_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP014_ICR-3_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-3_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-3_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP015_ICR-3_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-1_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-1_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-1_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP016_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP017_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP018_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP019_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP020_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP021_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP022_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP023_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP024_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP025_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP026_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP027_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP028_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP029_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-2_p15.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-2_p15.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-2_p15.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP030_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP031_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP032_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-1_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-1_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-1_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP033_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP034_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP035_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-3_p15.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-3_p15.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP036_ICR-3_p15.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP037_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP038_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP039_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP040_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP041_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP042_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP043_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP044_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP045_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-1_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-1_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-1_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP046_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-1_p5.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-1_p5.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-1_p5.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP047_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-3_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-3_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP048_ICR-3_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-3_p4.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-3_p4.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP049_ICR-3_p4.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-3_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-3_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP050_ICR-3_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP051_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP052_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP053_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP054_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-3_p4.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-3_p4.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP055_ICR-3_p4.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP056_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP057_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP058_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-1_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-1_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-1_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-2_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-2_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-2_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP059_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-1_p4.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-1_p4.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-1_p4.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP060_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-1_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-1_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-1_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-2_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-2_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-2_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-3_p2.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-3_p2.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP061_ICR-3_p2.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP064_ICR-2_p1.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP064_ICR-2_p1.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP064_ICR-2_p1.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP064_ICR-3_p3.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP064_ICR-3_p3.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP064_ICR-3_p3.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-1_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-1_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-1_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP090_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP091_ICR-1_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP091_ICR-1_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP091_ICR-1_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-1_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-1_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-1_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-2_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-2_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-2_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP092_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-1_p08.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-1_p08.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-1_p08.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-2_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-2_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-2_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP093_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-1_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-1_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-1_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-2_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-2_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-2_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP094_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-1_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-1_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-1_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-2_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-2_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-2_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP095_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-1_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-1_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-1_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-2_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-2_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-2_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-3_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-3_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP096_ICR-3_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-1_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-1_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-1_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-2_p03.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-2_p03.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-2_p03.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-3_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-3_p05.corems.csv",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAP097_ICR-3_p05.corems.json",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAPBLK01_ICR-1_p05.corems.cal",
                       "WHONDRS_TAP_Sample_Data/FTICR/Water_CoreMS_Output_Files/TAPBLK01_ICR-1_p05.corems.csv")
  
# include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA_character_. 
user_include_files = NA_character_

# include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE.
user_include_dot_files = F


### Prep Script ################################################################
# Directions: Run this chunk without modification.
require(pacman)
p_load(here, # for setting wd at git repo
tidyverse,
rlog,
devtools, # for sourcing from github
hms, # for handling times
fs, # for tree diagram
clipr, # for copying to clipboard
knitr, # for kable
kableExtra, # for rmd report table styling
DT, # for interactive tables in report
rmarkdown, # for rendering report
plotly, # for interactive graphs
downloadthis, # for downloading tabular data report as .csv
cli) # for fnacy warning mesages 

current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("./..")

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Transformation/functions/load_tabular_data.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")
source_url("https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_Validation/functions/check_sample_numbers.R")

### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.

# confirm directory has files in it
# if (length(list.files(user_directory, recursive = T)) == 0) {
#   warning("Your directory has 0 files.")
# }

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
# invisible(lapply(names(data_package_data$tabular_data), function(name) {
#   cat("/n--- Data Preview of", name, "---/n")
#   glimpse(data_package_data$tabular_data[[name]])
# }))


# 4. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)


# 5. Generate report
out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document", output_dir = report_out_dir, output_file = out_file)
browseURL(paste0(report_out_dir, "/", out_file))

# 6. Check sample numbers
sample_numbers <- check_sample_numbers(data_package_data = data_package_data,
                                       pattern_to_exclude_from_metadata_check = c('BLK'))

# 7. Check that all numeric columns contain a Reported_Precision

if(any(str_detect(names(data_package_checks$input$tabular_data), "dd\\.csv$"))){
  
  dd_path <- names(data_package_checks$input$tabular_data)[
    str_detect(names(data_package_checks$input$tabular_data), "dd\\.csv$")
  ]
  
  ## Pull in dd to get units
  dd <- data_package_checks$input$tabular_data[[dd_path]]%>%
    select(Column_or_Row_Name, Data_Type, Reported_Precision)
  
  numeric <- dd %>%
    filter(Data_Type == 'numeric') %>%
    filter(Column_or_Row_Name != 'Reported_Precision')
  

  not_numeric <- dd %>%
    filter(Data_Type != 'numeric')
    
  if(any(numeric$Reported_Precision == -9999)){
    
    cli_alert_danger('A numeric column is missing a Reported_Precision')
  } else{
    
    cli_alert_success('All numeric columns have a Reported_Precision')
  }
  
  if(any(not_numeric$Reported_Precision != -9999)){
    
    cli_alert_danger('A non-numeric column contains a Reported_Precision')
  }else{
    
    cli_alert_success('All non-numeric columns do not have a Reported_Precision')
  }
  
  
}

# View tabular data ############################################################

tabular_data <- data_package_checks$tabular_report

# Find the path that contains "dd.csv"
dd_path <- names(data_package_checks$input$tabular_data)[
  str_detect(names(data_package_checks$input$tabular_data), "dd\\.csv$")
]

## Pull in dd to get units
dd <- data_package_checks$input$tabular_data[[dd_path]]%>%
  select(Column_or_Row_Name, Unit)

## look at missing values, negative values, num_empty_cells, duplicate rows, and non numeric data ####

cli_alert_info("Displaying files with missing values (num_missing_rows > 0)")
view(tabular_data %>%
       filter(num_missing_rows>0))

cli_alert_info("Displaying files with negative values (num_negative_rows > 0)")
view(tabular_data %>%
       filter(num_negative_rows>0))

cli_alert_info("Displaying files with empty cells (num_empty_cells > 0)")
view(tabular_data %>%
       filter(num_empty_cells>0))

cli_alert_info("Displaying files with duplicate rows (num_unique_rows != num_rows)")
view(tabular_data %>%
       filter(num_unique_rows!=num_rows))

cli_alert_info("Displaying non-numeric columns (column_type != 'numeric')")
view(tabular_data %>%
       filter(column_type != 'numeric'))

## look at min/max values ####

numeric_long <- tabular_data %>%
  left_join(dd, by = c('column_name' = 'Column_or_Row_Name')) %>%
  filter(column_type != 'POSIXct') %>%
  select(column_name, range_min, range_max, Unit) %>%
  mutate(range_min = as.numeric(range_min),
         range_max = as.numeric(range_max)) %>%
  filter(!is.na(range_min)) %>%
  rename(MIN = range_min,
         MAX = range_max) %>%
  pivot_longer(cols = c(MIN, MAX),
               names_to = "type",
               values_to = "value") %>%
  mutate(facet_label = paste0(column_name, " (", Unit, ") ", type)) %>%
  filter(!str_detect(column_name, "SSS|CM"))

plot <- ggplot(numeric_long, aes(x = value)) +
  geom_boxplot() +
  facet_wrap(~facet_label, scales = "free_x", ncol = 2) +
  theme_bw()  +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.title.x = element_blank(),
    plot.title = element_text(size = 10, color = "grey")
  ) +
  ggtitle(paste("The associated data checks report was created on", Sys.Date(), "by", report_author))

ggsave(
  paste0(report_out_dir, '/tabular_data_plots_',Sys.Date(),'.pdf'),
  plot,
  device = 'pdf',
  width = 10,
  height = 200,
  units = 'in',
  dpi = 300,
  limitsize = FALSE
)

