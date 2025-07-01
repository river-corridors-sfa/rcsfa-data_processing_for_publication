# create_flmd_dd.R #############################################################

# Objective: 
  # Create an FLMD with the cols: File_Name, File_Description, Standard, Header_Rows, Column_or_Row_Name_Position, File_Path
  # Create a DD with the cols: Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, Missing_Value_Code

# Directions: 
  # 1. Fill out user inputs; then run the chunk. 
  # 2. Run the following chunks (you do not need to edit the code): Prep Script, Get Files, Create FLMD, Create DD
  # 3. Optionally, add code into the "Data Package Specific Edits" section if needed
  # 4. Run the "Export" chunk (you do not need to edit the code)

# If you need to edit the functions `get_files()`, `create_flmd()`, or
# `create_dd()`, refer to test-create_flmd() and test-create_dd() to ensure that
# your updates work as expected and haven't broken any existing functionality.


### USER INPUTS ################################################################

#### REQUIRED ----

# directory = string of the absolute folder file path; do not include "/" at end.
my_directory = "C:/Brieanne/GitHub/YRB_Water_Column_Respiration"

# dp_keyword = string of the data package name; this will be used to name the placeholder flmd, dd, readme files in the flmd and name the FLMD and DD files. Optional argument; default is "data_package".
my_dp_keyword = "Laan_2025_Water_Column_Respiration"

# out_dir = string of the absolute folder you want the flmd and dd saved to; do not include "/" at end.
my_out_dir = "Z:/00_ESSDIVE/03_Manuscript_DPs/v2_Laan_2025_Water_Column_Manuscript_Data_Package/Laan_2025_Water_Column_Respiration_Data_Package"

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
  # files. Finally, bind the outputs from both runs to combine them into a
  # single FLMD.

# exclude_files = vector of files (relative file path + file name; no / at beginning of path) to exclude from within the dir. Optional argument; default is NA_character_. (Tip: Select files in file browser. Click "Copy Path". Paste within c() here. To add commas: Shift+Alt > drag to select all lines > end > comma) 
user_exclude_files = c('Data/Published_Data/v3_SFA_SpatialStudy_2021_SampleData/SPS_Sample_Field_Metadata.csv',
                       "Data/Map_Layers/ERwc_Coords_LULC.csv")

# include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA_character_. 
user_include_files = NA_character_

# include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE.
user_include_dot_files = F

# add_placeholders = T/F where the user should select T if they want placeholder rows for the flmd, readme, and dd if those files are missing. Optional argument; default is FALSE.
user_add_placeholders = T

# query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Header rows that start with "#" can be considered as not having header rows. Optional argument; default is FALSE.  
user_query_header_info = F

# file_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 20 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 20. 
user_view_n_max = 20

# add_boye_headers = T/F where the user should select T if they want placeholder rows in the dd for Boye header row names. Optional argument; default is FALSE.
user_add_boye_headers = F

# add_flmd_dd_headers = T/F where the user should select T if they want placeholder rows for FLMD and DD column headers. Optional argument; default is FALSE. 
user_add_flmd_dd_headers = T

# include_filenames = T/F to indicate whether you want to include the file name(s) the headers came from. Optional argument; default is F. 
user_include_filenames = F


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(rlog)
library(fs)
library(devtools)
library(crayon)

# source functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_dd.R")


### Get Files ##################################################################

my_files <- get_files(directory = my_directory, 
                      exclude_files = user_exclude_files, 
                      include_files = user_include_files, 
                      include_dot_files = user_include_dot_files)

### Create FLMD ################################################################

my_flmd<- create_flmd(files_df = my_files,
                       dp_keyword = my_dp_keyword,
                       add_placeholders = user_add_placeholders,
                       query_header_info = user_query_header_info,
                       view_n_max = user_view_n_max)

### Create DD ##################################################################

my_dd <- create_dd(files_df = my_files, 
                    flmd_df = my_flmd, 
                    add_boye_headers = user_add_boye_headers, 
                    add_flmd_dd_headers = user_add_flmd_dd_headers, 
                    include_filenames = user_include_filenames)

### Data Package Specific Edits ################################################


prelim_dd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/v2_Laan_2025_Water_Column_Manuscript_Data_Package/Laan_2025_Water_Column_Respiration_dd_prelim.csv") %>%
  select(Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type) 


dd_populated <- my_dd %>%
  rows_patch(prelim_dd, by = c("Column_or_Row_Name"), unmatched = 'ignore') %>% 
  mutate(Term_Type = case_when(is.na(Term_Type) ~ "column_header", 
                               T ~ Term_Type))

prelim_flmd <- read_csv("Z:/00_ESSDIVE/03_Manuscript_DPs/v2_Laan_2025_Water_Column_Manuscript_Data_Package/Laan_2025_Water_Column_Respiration_flmd_prelim.csv") %>%
  select(File_Name, File_Description)


flmd_populated <- my_flmd %>%
  rows_patch(prelim_flmd, by = c("File_Name"), unmatched = 'ignore')


### Export #####################################################################

# write_csv(my_flmd, file = paste0(my_out_dir, "/", my_dp_keyword, "_flmd.csv"), na = "")
# 
# write_csv(my_dd, file = paste0(my_out_dir, "/", my_dp_keyword, "_dd.csv"), na = "")

write_csv(flmd_populated, file = paste0(my_out_dir, "/", my_dp_keyword, "_flmd.csv"), na = "")

write_csv(dd_populated, file = paste0(my_out_dir, "/", my_dp_keyword, "_dd.csv"), na = "")

