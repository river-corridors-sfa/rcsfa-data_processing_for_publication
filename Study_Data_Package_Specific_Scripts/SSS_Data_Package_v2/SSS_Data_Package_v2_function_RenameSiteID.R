### SSS_Data_Package_v2_function_RenameSiteID.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: 2023-07-25 by Bibi Powers-McCormack
# Date Updated: 2023-07-26 by Bibi Powers-McCormack

# Objective: Write a function that can take a parent ID and the new and old Site_IDs and then rename the site IDs in the file



### FILE SET UP ##############################

# Load libraries
library(tidyverse)


### FUNCTION: rename_site_id ##############################
# Inputs: filepath, parent_id, old_SiteID, new_SiteID
# Outputs: .csv file

rename_site_id <- function(filepath, parent_id, old_SiteID, new_SiteID) {
  # gather correct file path to read in
  filename <- list.files(filepath, pattern = paste0(parent_id))
  
  # read in correct file
  data_01 <- read_csv(paste0(filepath, filename), comment = "#", id = "filepath")
  
  # see if there are multiple files, and if so stop the function
  file_count <- data_01 %>% 
    select(filepath) %>% 
    unique()
  
  if(nrow(file_count) > 1) {
    print("ERROR: More than one file read in from the associated Parent ID. Function terminating")
  } else {
  
  # extract contents of first column, first row to get the header row number
  data_header <- read_csv(paste0(filepath, filename), col_names = "header_row") %>% 
    head(1) %>% 
    separate(header_row, into = c("header", "row_number"), sep="_(?=[^_]+$)") %>% 
    mutate(row_number = as.numeric(row_number))
  
  # extract out the row number value from the df
  header_string <- data_header$row_number
  
  # read in header info
  header_info <- read_csv(paste0(filepath, filename), col_names = FALSE) %>% 
    head(header_string-1)
  
  # case when to change site ID
  data_02 <- data_01 %>% 
    rename(Site_ID_original = Site_ID) %>% 
    mutate(Site_ID = case_when((Site_ID_original == old_SiteID ~ new_SiteID), TRUE ~ Site_ID_original), .after = Site_ID_original) %>% 
    
  
  # mutate to change column type and paste0 a space to front of dates
    mutate(DateTime = paste0(" ", DateTime))
  
  # count how many rows were updated
  check_count <- data_02 %>% 
    group_by(Site_ID_original, Site_ID) %>% 
   filter(Site_ID_original != Site_ID) %>% 
    count()
  
  # ask if correct
  print(check_count)
  print(filename)
  
  ask_user <- readline(prompt = "Are the above changes correct? If yes, enter uppercase 'Y': ")
  
  if (ask_user == "Y") {
    
  
  # remove Site_ID_original column
  data_03 <- data_02 %>% 
    select(-Site_ID_original, -filepath)
  
  # confirm new file version
  print(paste0("The file you imported is called ", filename))
  new_version <- readline(prompt = "What would you like the new version to be called? If you want the original file to be overwritten, put zero '0', otherwise enter version v2, v3, etc.: ")
  
  if (new_version == 0) {
    new_version <- ""
  } else {
    new_version <- paste0(new_version, "_")
  }
  
  # write out header file to same as input file path with version appended to it
  write_csv(header_info, paste0(filepath, new_version, filename), col_names = FALSE, na = "")
  
  
  # write out to append data
  write_csv(data_03, paste0(filepath, new_version, filename), col_names = TRUE, append = TRUE)
  
  # print message
  print(paste0("The new file, ", new_version, filename, ", is exporting. Check ", filepath, " for the exported file. Remember to manually remove ", filename, " from the directory if the file was not overwritten."))
  
  } else {
    print("ERROR: You did not enter 'Y'. Function terminating.")
  }
  }
  
}



