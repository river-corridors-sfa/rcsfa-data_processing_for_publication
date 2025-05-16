# create_flmd_dd.R #############################################################

# Objective: 
  # Create an FLMD with the cols: File_Name, File_Description, Standard, Header_Rows, Column_or_Row_Name_Position, File_Path
  # Create a DD with the cols: Column_or_Row_Name, Unit, Definition, Data_Type, Missing_Value_Code

# Directions: 
  # 1. Fill out user inputs
  # 2. Run the following sections (you do not need to edit the code): Prep Script, Get Files, Create FLMD, Create DD
  # 3. Optionally, add code into the "Data Package Specific Edits" section if needed
  # 4. Run the "Export" section (you do not need to edit the code)


### USER INPUTS ################################################################

#### REQUIRED ----

# directory = string of the absolute folder file path; do not include "/" at end.
my_directory = ""

# dp_keyword = string of the data package name; this will be used to name the placeholder flmd, dd, readme files in the flmd and name the FLMD and DD files. Optional argument; default is "data_package".
my_dp_keyword = ""

# out_dir = string of the absolute folder you want the flmd and dd saved to; do not include "/" at end.
my_out_dir = ""

#### OPTIONAL ----

# exclude_files = vector of files (relative file path + file name) to exclude from within the dir. Optional argument; default is NA_character_. 
user_exclude_files = NA_character_

# include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA_character_. 
user_include_files = NA_character_

# include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE.
user_include_dot_files = F

# add_placeholders = T/F where the user should select T if they want placeholder rows for the flmd, readme, and dd if those files are missing. Optional argument; default is FALSE.
user_add_placeholders = F

# query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Select F if on NERSC. Optional argument; default is FALSE.  
user_query_header_info = F

# file_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 100 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 100. 
user_file_n_max = 100

# add_boye_headers = T/F where the user should select T if they want placeholder rows for Boye header rows. Optional argument; default is FALSE.
user_add_boye_headers = F

# add_flmd_dd_headers = T/F where the user should select T if they want placeholder rows for FLMD and DD column headers. Optional argument; default is FALSE. 
user_add_flmd_dd_headers = F

# include_filenames = T/F to indicate whether you want to include the file name(s) the headers came from. Optional argument; default is F. 
user_include_filenames = F


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(rlog)
library(fs)
library(devtools)

# load functions
source("./Data_Package_Documentation/functions/create_flmd.R")
source("./Data_Package_Documentation/functions/create_dd.R")

# source functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_dd.R")


### Get Files ##################################################################

my_files <- get_files(files_df = my_directory, 
                      exclude_files = user_exclude_files, 
                      include_files = user_include_files, 
                      include_dot_files = F)

### Create FLMD ################################################################

my_flmd <- create_flmd(files_df = my_files,
                       dp_keyword = my_dp_keyword,
                       add_placeholders = user_add_placeholders,
                       query_header_info = user_query_header_info,
                       file_n_max = user_file_n_max)

### Create DD ##################################################################

my_dd <- create_dd(files_df = my_files, 
                   flmd_df = my_flmd, 
                   add_boye_headers = user_add_boye_headers, 
                   add_flmd_dd_headers = user_add_flmd_dd_headers, 
                   include_filenames = user_include_filenames)

### Data Package Specific Edits ################################################





### Export #####################################################################

write_csv(my_flmd, file = paste0(my_out_dir, "/", my_dp_keyword, "_flmd.csv"), na = "")

write_csv(my_dd, file = paste0(my_out_dir, "/", my_dp_keyword, "_dd.csv"), na = "")

