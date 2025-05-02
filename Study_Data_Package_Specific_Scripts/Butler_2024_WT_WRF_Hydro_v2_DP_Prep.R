### Butler_2024_WT_WRF_Hydro_v2_DP_Prep.R ######################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-01
# Date Updated: 2025-05-01

# Objective: 
  # This script is designed to prepare Zach's v2 data package

# Assumptions: 


### get dir tree ###############################################################
# requires fs package
library(fs)

# user input is a directory
directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/PROJECTS/Data Package RC-1 Manuscript Zach Butler WRF-Hydro v2/Butler_2024_WT_WRF_Hydro_Manuscript_Data_Package"

# user input for out dir
out_directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/PROJECTS/Data Package RC-1 Manuscript Zach Butler WRF-Hydro v2"

# visualize tree in console
dir_tree(directory, recurse = T)

# save tree as a markdown file
tree_output <- capture.output(dir_tree(directory))
writeLines(tree_output, paste0(out_directory, "/", Sys.Date(), "_directory_tree.md"))


### compare v1 and v2 files ####################################################

library(tidyverse)
v1_dir <- "Q:/Published_Manuscript_DP_Archive/Butler_2024_WT_WRF_Hydro/Butler_2024_WT_WRF_Hydro_Manuscript_Data_Package"

v2_dir <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/PROJECTS/Data Package RC-1 Manuscript Zach Butler WRF-Hydro v2/Butler_2024_WT_WRF_Hydro_Manuscript_Data_Package"

v1_files <- list.files(v1_dir, recursive = T)

v2_files <- list.files(v2_dir, recursive = T)

# see if names are unique - if they are, compare by file name; otherwise compare with file paths
tibble(v2 = basename(v2_files)) %>% count(v2) %>% filter(n > 1) %>% count() # file names repeat, so will have to compare using file paths

# Returns files that are in `v1` but **not** in `v2` (removed files)
setdiff(v1_files, v2_files)

# Returns files that are in `v2` but **not** in `v1` (added files)
setdiff(v2_files, v1_files)

# do i need to update the dd? - are there any new added tabular files? 
setdiff(v2_files, v1_files) %>% 
  tibble(added_files = .) %>% 
  filter(str_ends(added_files, regex("\\.csv", ignore_case = TRUE))) %>% 
  mutate(has_old = str_detect(added_files, regex("old", ignore_case = TRUE))) %>% 
  filter(has_old == F) %>% 
  view() # yes

# do i need to update the dd - did the column headers change? 

# function to read only headers
get_headers <- function(file) {
  headers <- read_csv(file, n_max = 0, show_col_types = TRUE, name_repair = "minimal") %>%
    names()
  tibble(file_name = basename(file), file_path = file, headers = list(headers))
}

# list all .csv files
v1_csv_files <- list.files(v1_dir, pattern = "\\.csv$", full.names = TRUE, recursive = T)
v2_csv_files <- list.files(v2_dir, pattern = "\\.csv$", full.names = TRUE, recursive = T)


# apply to all files
v1_headers <- map_dfr(v1_csv_files, get_headers) %>% 
  unnest(headers)

v2_headers <- map_dfr(v2_csv_files, get_headers) %>% 
  unnest(headers)

# removed headers
setdiff(unique(v1_headers$headers), unique(v2_headers$headers)) # looks like the quality_flag columns aren't renamed in the version Zach sent me, so I will have to manually update those files again

# added headers
setdiff(unique(v2_headers$headers), unique(v1_headers$headers)) # yes there are new ones

# location of the newly added headers
v2_headers %>% 
  filter(headers %in% setdiff(unique(v2_headers$headers), unique(v1_headers$headers))) %>% 
  view() # will need to clean up those output files that have the blanks in them


### create flmd ################################################################

library(tidyverse)
library(devtools)

source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/database_v2/Data_Package_Documentation/functions/create_flmd_skeleton_v2.R")


v2_dir <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/PROJECTS/Data Package RC-1 Manuscript Zach Butler WRF-Hydro v2/v2_Butler_2024_WT_WRF_Hydro_Manuscript_Data_Package"

flmd_skeleton <- create_flmd_skeleton(directory = v2_dir,
                                      add_placeholders = T, 
                                      query_header_info = F)


### create dd ##################################################################

library(tidyverse)




  
