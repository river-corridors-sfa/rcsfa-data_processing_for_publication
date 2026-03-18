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
user_directory <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_Minikits/WHONDRS_Minikits_Data_Package'

# provide the name of the person running the checks
report_author <- "Brieanne Forbes"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_Minikits'

# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- T

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- T

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_Minikits/WHONDRS_Minikits_Data_Package/WHONDRS_Minikits_flmd.csv"

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

user_exclude_files = c("WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000001-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000001-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/Minikits_SPE_Milli_Q_blank_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/Minikits_SPE_MeOH_blank_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000251-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000251-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000251-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000250-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000250-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000250-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000192-4_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000192-3_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000192-2_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000189-4_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000189-3_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000189-2_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000188-4_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000188-3_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000188-2_p075.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000175-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000175-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000175-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000174-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000174-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000174-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000173-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000173-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000173-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000166-4_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000166-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000166-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000157-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000157-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000157-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000156-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000156-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000156-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000155-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000155-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000155-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000148-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000148-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000148-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000145-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000145-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000145-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000144-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000144-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000144-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000143-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000143-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000143-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000142-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000142-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000142-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000141-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000141-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000141-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000140-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000140-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000140-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000134-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000134-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000134-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000132-4_p15.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000132-3_p15.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000132-2_p15.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000130-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000130-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000130-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000129-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000129-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000128-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000128-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000128-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000127-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000127-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000127-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000126-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000126-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000126-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000125-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000125-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000125-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000112-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000112-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000112-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000110-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000110-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000110-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000098-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000098-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000098-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000087-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000087-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000087-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000086-4_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000086-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000086-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000085-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000085-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000085-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000084-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000084-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000084-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000073-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000073-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000073-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000066-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000066-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000066-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000065-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000065-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000065-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000063-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000063-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000063-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000062-4_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000062-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000062-2_p3.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000061-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000061-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000061-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000060-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000060-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000060-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000059-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000059-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000059-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000056-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000056-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000056-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000055-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000055-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000055-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000054-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000054-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000054-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000052-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000052-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000052-1_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000045-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000045-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000045-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000044-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000044-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000044-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000036-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000036-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000036-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000035-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000035-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000035-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000032-3_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000032-2_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000032-1_p08.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000030-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000030-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000030-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000026-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000026-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000026-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000023-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000023-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000023-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000022-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000022-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000022-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000014-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000014-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000014-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000013-3_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000013-2_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000013-1_p1.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000012-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000012-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000012-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000011-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000011-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000011-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000010-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000010-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000010-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000009-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000009-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000009-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000008-4_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000008-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000008-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000007-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000007-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000006-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000006-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000006-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000005-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000005-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000005-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000004-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000004-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000004-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000003-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000003-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000003-1_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000002-3_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000002-2_p05.corems.csv",
                       "WHONDRS_Minikits_Sample_Data/FTICR/Water_CoreMS_Output_Files/S000002-1_p05.corems.csv")
  
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
                                       pattern_to_exclude_from_metadata_check = c('blank'))

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

