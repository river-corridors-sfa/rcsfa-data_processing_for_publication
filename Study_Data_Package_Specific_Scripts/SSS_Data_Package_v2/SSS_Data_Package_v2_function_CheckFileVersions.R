### SSS_Data_Package_v2_function_CheckFileVersions.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: 2023-07-25 by Bibi Powers-McCormack
# Date Updated: 2023-07-26 by Bibi Powers-McCormack

# Objective: Write a function that can take a parent ID and the new and old Site_IDs and then rename the site IDs in the file



### FILE SET UP ##############################

# Load libraries
library(tidyverse)


### FUNCTION: check_file_versions ##############################
# Inputs: filepath, parent_id
# Outputs: prints df, but does not save anything

check_file_versions <- function(filepath, parent_id) {
  # gather correct file path to read in
  filename <- list.files(filepath, pattern = paste0(parent_id))
  
  # read in correct file
  data_01 <- read_csv(paste0(filepath, filename), comment = "#", id = "filepath")
  
  # see if there are multiple files, and if so stop the function
  file_count <- data_01 %>% 
    select(filepath) %>% 
    unique() %>% 
    print
}


