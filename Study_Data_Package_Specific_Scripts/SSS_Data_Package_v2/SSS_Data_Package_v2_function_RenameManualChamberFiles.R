### SSS_Data_Package_v2_RenameManualChamberFiles.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: Originally created by Brieanne Forbes on 2022-08-24, script updated and turned into a function by Bibi Powers-McCormack
# Date Updated: 2023-08-17 by Bibi Powers-McCormack

# Objective: The filenames in the miniDOTManualChamber folder have a typo and do not have "MC" in the filenames.	"DO" should be capitalized and the manual chamber files should not have the same filename as the miniDOT folder contents



### FILE SET UP ##############################

# Load libraries
library(tidyverse)
library(fs)
library(tools)

# set working directory
getwd()

# Load functions

# Load data
  # see below


### RENAME MINI DOT FILES ##############################
# Inputs: 
# Outputs: 

# check which files need to be renamed

filepath <- "./v2_SSS_Data_Package/miniDOTManualChamber/Data"

list.files(filepath)

# gather files, separated by version (since some of the files were already updated to v2, I'll have to change those ones separately)
all_files <- list.files(filepath, recursive = TRUE, full.names = TRUE)
v2_files <- list.files(filepath, recursive = TRUE, full.names = TRUE, pattern = "v2")
v1_files <- base::setdiff(all_files, v2_files)



# rename v2 files

# create a loop that runs through each file and renames it
for (file in v2_files) {
  
  # extract the directory of the file
  dir <- path_dir(file)
  
  # extract the file name and removes the .csv extension
  file_name <- path_file(file) %>%
    str_remove('.csv')
  
  # store the file extension separately
  ext <- file_ext(file)
  
  # extract the parent ID from the filename
  parentID <- str_remove_all(file_name, "_Water_Do_Temp") %>% 
  str_remove_all(., "v2_")
  
  # rename the file 
  new_name <- str_c("v2_", parentID, "_MC_Water_DO_Temp")
  
  # store the new directory, which includes the renamed file
  new_dir <- paste0(dir, '/', new_name, ".", ext)
  
  # rename the file
  file.rename(file, new_dir)
  
  print(paste0("The file ", file_name, " has been renamed to ", new_name))
  
}




# rename v1 files

# create a loop that runs through each file and renames it
for (file in v1_files) {
  
  # extract the directory of the file
  dir <- path_dir(file)
  
  # extract the file name and removes the .csv extension
  file_name <- path_file(file) %>%
    str_remove('.csv')
  
  # store the file extension separately
  ext <- file_ext(file)
  
  # extract the parent ID from the filename
  parentID <- str_remove_all(file_name, "_Water_Do_Temp")
  
  # rename the file 
  new_name <- str_c(parentID, "_MC_Water_DO_Temp")
  
  # store the new directory, which includes the renamed file
  new_dir <- paste0(dir, '/', new_name, ".", ext)
  
  # rename the file
  file.rename(file, new_dir)
  
  print(paste0("The file ", file_name, " has been renamed to ", new_name))
  
}





