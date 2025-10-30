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
user_directory <- 'Z:/00_ESSDIVE/01_Study_DPs/TGW_Data_Package/TGW_Data_Package'

# provide the name of the person running the checks
report_author <- "Brieanne Forbes"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- "Z:/00_ESSDIVE/01_Study_DPs/TGW_Data_Package"

# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- T

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- T

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- "Z:/00_ESSDIVE/01_Study_DPs/TGW_Data_Package/TGW_Data_Package/TGW_flmd.csv"

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

user_exclude_files = c("TGW_Field_Photos/TGW_021-south.jpg",
                       "TGW_Field_Photos/TGW_022-collection.jpg",
                       "TGW_Field_Photos/TGW_022-data.png",
                       "TGW_Field_Photos/TGW_022-east.jpg",
                       "TGW_Field_Photos/TGW_022-north.jpg",
                       "TGW_Field_Photos/TGW_022-south.jpg",
                       "TGW_Field_Photos/TGW_022-west.jpg",
                       "TGW_Field_Photos/TGW_023-collection.jpg",
                       "TGW_Field_Photos/TGW_023-data.png",
                       "TGW_Field_Photos/TGW_023-east.jpg",
                       "TGW_Field_Photos/TGW_023-north.jpg",
                       "TGW_Field_Photos/TGW_023-south.jpg",
                       "TGW_Field_Photos/TGW_023-west.jpg",
                       "TGW_Field_Photos/TGW_001-east.jpeg",
                       "TGW_Field_Photos/TGW_001-north.jpeg",
                       "TGW_Field_Photos/TGW_001-south.jpeg",
                       "TGW_Field_Photos/TGW_001-substrate.jpeg",
                       "TGW_Field_Photos/TGW_001-west.jpeg",
                       "TGW_Field_Photos/TGW_002-data.jpg",
                       "TGW_Field_Photos/TGW_002-east.jpg",
                       "TGW_Field_Photos/TGW_002-north.jpg",
                       "TGW_Field_Photos/TGW_002-south.jpg",
                       "TGW_Field_Photos/TGW_002-substrate.jpg",
                       "TGW_Field_Photos/TGW_002-west.jpg",
                       "TGW_Field_Photos/TGW_003-data.jpeg",
                       "TGW_Field_Photos/TGW_003-east.jpeg",
                       "TGW_Field_Photos/TGW_003-north.jpeg",
                       "TGW_Field_Photos/TGW_003-south.jpeg",
                       "TGW_Field_Photos/TGW_003-substrate.jpeg",
                       "TGW_Field_Photos/TGW_003-west.jpeg",
                       "TGW_Field_Photos/TGW_006-data.jpeg",
                       "TGW_Field_Photos/TGW_006-east.jpeg",
                       "TGW_Field_Photos/TGW_006-north.jpeg",
                       "TGW_Field_Photos/TGW_006-south.jpeg",
                       "TGW_Field_Photos/TGW_006-substrate.jpeg",
                       "TGW_Field_Photos/TGW_006-west.jpeg",
                       "TGW_Field_Photos/TGW_007-data.jpeg",
                       "TGW_Field_Photos/TGW_007-east.jpeg",
                       "TGW_Field_Photos/TGW_007-north.jpeg",
                       "TGW_Field_Photos/TGW_007-south.jpeg",
                       "TGW_Field_Photos/TGW_007-substrate.jpeg",
                       "TGW_Field_Photos/TGW_007-west.jpeg",
                       "TGW_Field_Photos/TGW_008-data.jpg",
                       "TGW_Field_Photos/TGW_008-east.jpg",
                       "TGW_Field_Photos/TGW_008-north.jpg",
                       "TGW_Field_Photos/TGW_008-south.jpg",
                       "TGW_Field_Photos/TGW_008-substrate.jpg",
                       "TGW_Field_Photos/TGW_008-west.jpg",
                       "TGW_Field_Photos/TGW_009-data.jpg",
                       "TGW_Field_Photos/TGW_009-east.jpg",
                       "TGW_Field_Photos/TGW_009-north.jpg",
                       "TGW_Field_Photos/TGW_009-south.jpg",
                       "TGW_Field_Photos/TGW_009-substrate.jpg",
                       "TGW_Field_Photos/TGW_009-west.jpg",
                       "TGW_Field_Photos/TGW_010-data.jpg",
                       "TGW_Field_Photos/TGW_010-east.jpg",
                       "TGW_Field_Photos/TGW_010-north.jpg",
                       "TGW_Field_Photos/TGW_010-south.jpg",
                       "TGW_Field_Photos/TGW_010-substrate.jpg",
                       "TGW_Field_Photos/TGW_010-west.jpg",
                       "TGW_Field_Photos/TGW_011-data.jpg",
                       "TGW_Field_Photos/TGW_011-east.jpg",
                       "TGW_Field_Photos/TGW_011-north.jpg",
                       "TGW_Field_Photos/TGW_011-south.jpg",
                       "TGW_Field_Photos/TGW_011-substrate.jpg",
                       "TGW_Field_Photos/TGW_011-west.jpg",
                       "TGW_Field_Photos/TGW_013-collection.jpg",
                       "TGW_Field_Photos/TGW_013-data.png",
                       "TGW_Field_Photos/TGW_013-east.jpg",
                       "TGW_Field_Photos/TGW_013-north.jpg",
                       "TGW_Field_Photos/TGW_013-south.jpg",
                       "TGW_Field_Photos/TGW_013-west.jpg",
                       "TGW_Field_Photos/TGW_014-data.png",
                       "TGW_Field_Photos/TGW_014-east.jpg",
                       "TGW_Field_Photos/TGW_014-north.jpg",
                       "TGW_Field_Photos/TGW_014-south.jpg",
                       "TGW_Field_Photos/TGW_014-west.jpg",
                       "TGW_Field_Photos/TGW_015-collection.jpg",
                       "TGW_Field_Photos/TGW_015-data.png",
                       "TGW_Field_Photos/TGW_015-east.jpg",
                       "TGW_Field_Photos/TGW_015-north.jpg",
                       "TGW_Field_Photos/TGW_015-south.jpg",
                       "TGW_Field_Photos/TGW_015-west.jpg",
                       "TGW_Field_Photos/TGW_016-collection.jpg",
                       "TGW_Field_Photos/TGW_016-data.png",
                       "TGW_Field_Photos/TGW_016-east.jpg",
                       "TGW_Field_Photos/TGW_016-north.jpg",
                       "TGW_Field_Photos/TGW_016-south.jpg",
                       "TGW_Field_Photos/TGW_016-west.jpg",
                       "TGW_Field_Photos/TGW_017-collection.jpg",
                       "TGW_Field_Photos/TGW_017-data.png",
                       "TGW_Field_Photos/TGW_017-east.jpg",
                       "TGW_Field_Photos/TGW_017-north.jpg",
                       "TGW_Field_Photos/TGW_017-south.jpg",
                       "TGW_Field_Photos/TGW_017-west.jpg",
                       "TGW_Field_Photos/TGW_018-collection.jpg",
                       "TGW_Field_Photos/TGW_018-data.png",
                       "TGW_Field_Photos/TGW_018-east.jpg",
                       "TGW_Field_Photos/TGW_018-north.jpg",
                       "TGW_Field_Photos/TGW_018-south.jpg",
                       "TGW_Field_Photos/TGW_018-west.jpg",
                       "TGW_Field_Photos/TGW_019-collection.jpg",
                       "TGW_Field_Photos/TGW_019-data.png",
                       "TGW_Field_Photos/TGW_019-east.jpg",
                       "TGW_Field_Photos/TGW_019-north.jpg",
                       "TGW_Field_Photos/TGW_019-south.jpg",
                       "TGW_Field_Photos/TGW_019-west.jpg",
                       "TGW_Field_Photos/TGW_020-collection.jpg",
                       "TGW_Field_Photos/TGW_020-data.png",
                       "TGW_Field_Photos/TGW_020-east.jpg",
                       "TGW_Field_Photos/TGW_020-north.jpg",
                       "TGW_Field_Photos/TGW_020-south.jpg",
                       "TGW_Field_Photos/TGW_020-west.jpg",
                       "TGW_Field_Photos/TGW_021-collection.jpg",
                       "TGW_Field_Photos/TGW_021-data.png",
                       "TGW_Field_Photos/TGW_021-east.jpg",
                       "TGW_Field_Photos/TGW_021-north.jpg",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_023_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_023_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_001_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_001_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_001_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_001_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_001_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_002_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_002_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_002_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_002_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_002_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_002_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_003_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_003_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_003_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_003_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_003_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_003_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_006_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_006_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_006_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_006_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_006_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_006_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_007_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_007_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_007_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_007_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_007_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_007_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_008_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_008_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_008_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_008_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_008_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_008_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_009_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_009_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_009_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_009_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_009_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_009_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_010_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_010_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_010_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_010_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_010_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_010_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_011_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_011_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_011_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_011_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_011_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_011_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_013_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_013_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_013_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_013_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_013_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_013_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_014_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_014_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_014_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_014_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_014_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_014_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_015_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_015_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_015_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_015_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_016_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_016_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_016_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_016_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_016_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_016_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_017_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_017_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_017_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_017_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_017_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_017_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_018_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_018_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_018_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_018_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_018_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_018_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_019_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_019_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_019_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_019_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_019_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_019_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_020_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_020_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_020_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_020_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_020_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_020_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_021_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_021_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_021_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_021_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_021_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_021_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_022_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_022_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_022_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_022_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_022_ICR-3_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_022_ICR-3_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_023_ICR-1_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_023_ICR-1_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_023_ICR-2_r1_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_XML_Files/TGW_023_ICR-2_r2_p03.xml",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_001_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_002_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_003_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_006_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_007_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_008_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_009_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_010_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_011_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_013_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_014_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_015_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_016_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_017_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_018_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_019_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_020_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_021_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-3_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-3_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-3_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_022_ICR-3_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-1_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-1_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-1_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-1_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-1_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-1_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-2_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-2_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-2_r1_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-2_r2_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-2_r2_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-2_r2_p03.corems.json",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-3_r1_p03.corems.cal",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-3_r1_p03.corems.csv",
                       "TGW_Sample_Data/FTICR/Water_CoreMS_Output_Files/TGW_023_ICR-3_r1_p03.corems.json")
  
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

# 6. Check for duplicate sample names
for (file_path in names(data_package_data[["tabular_data"]])) {
  df <- data_package_data[["tabular_data"]][[file_path]]
  file_name <- basename(file_path)
  
  # Check if either Sample_Name or Sample_ID exists
  if ("Sample_Name" %in% colnames(df)) {
    # Check for duplicates in Sample_Name
    if (any(duplicated(df$Sample_Name))) {
      cli_alert_danger(paste("Duplicate Sample_Name values found in file:", file_name))
    } else {
      
      cli_alert_success('No duplicate Sample_Name values found')
    }
  }
  
  if ("Sample_ID" %in% colnames(df)) {
    # Check for duplicates in Sample_ID
    if (any(duplicated(df$Sample_ID))) {
      cli_alert_danger(paste("Duplicate Sample_ID values found in file:", file_name))
    }else {
      
      cli_alert_success('No duplicates Sample_ID values found')
    }
  }
}

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

view(tabular_data %>%
       filter(num_missing_rows>0))

view(tabular_data %>%
       filter(num_negative_rows>0))

view(tabular_data %>%
       filter(num_empty_cells>0))

view(tabular_data %>%
       filter(num_unique_rows!=num_rows))

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

