### SSS_Data_Package_v2_function_RenamePhotoFilenames.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: Originally created by Brieanne Forbes on 2022-08-24, script updated and turned into a function by Bibi Powers-McCormack
# Date Updated: 2023-07-28 by Bibi Powers-McCormack

# Objective: Create an updated function that can take a .jpg filename (as long as the site_ID info is prefixed on the beginning) and the new and old SiteIDs and then rename the filename with the updated site ID
# Note: This function is very specific to this use case and requires the following parameters: 
  # - the photos are in their own sub folder without any other file types
  # - the photo filenames are in this syntax: SSS_[old_SiteID]_YYYYMMDD_#.jpg with the desire to change them to SSS_[new_SiteID]_YYYYMMDD_#.jpg
  # - the study code must be "SSS"
  # - the photo must have a .jpg extension



### FILE SET UP ##############################

# Load libraries
library(tidyverse)
library(fs)
library(tools)


### FUNCTION: rename_photo_filename ##############################
# Inputs: filepath, old_SiteID, new_SiteID
# Outputs: renamed .jpg files


rename_photo_filenames <- function(filepath, old_SiteID, new_SiteID) {
  
  # get a list of photo filenames that include the old_SiteID
  files <- list.files(filepath, recursive = TRUE, full.names = TRUE, pattern = paste0(old_SiteID))
  
  print(paste0("You selected ", length(files), " files: "))
  print(files)
  continue <- readline(prompt = "Be sure to read the parameters outlined in the function script. If you still want to continue, enter uppercase 'Y': ")
  
    if (continue == "Y") {
    
    # create a loop that runs through each photo file and renames it
    for (file in files) {
      
      # extract the directory of the file
      dir <- path_dir(file)
      
      # extract the file name and removes the .jpg extension
      file_name <- path_file(file) %>%
        str_remove('.jpg')
      
      # store the file extension separately
      ext <- file_ext(file)
      
      # rename the file by adding the new_SiteID to the beginning of the file
      new_name <- str_c("SSS_", new_SiteID, "_", file_name)
      
      # remove the old_SiteID from the new_name
      new_name <- str_remove_all(new_name, paste0("SSS_", old_SiteID, "_"))
      
      # store the new directory, which includes the renamed file
      new_dir <- paste0(dir, '/', new_name, ".", ext)
      
      # rename the file
      file.rename(file, new_dir)
      
      print(paste0("The file ", file_name, " has been renamed to ", new_name))
    
    } 
      print("File renaming is complete.")
      } else {
    print("ERROR: You did not enter 'Y'. Function terminating.")
  }
  
}


