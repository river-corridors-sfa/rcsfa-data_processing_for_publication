### get_DPs_not_in_dd_database.R ###############################################
# Date Created: 2024-05-01
# Date Updaed: 2024-05-01
# Author: Bibi Powers-McCormack

# Objective: 
  # Compare the list of data packages in the manuscript or study DP secret folders with the DPs in the DD database
  # Return a list of the data packages that have not been uploaded


### FUNCTION ###################################################################
get_DPs_not_in_dd_database <- function() {

  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  
  # read in secret folder file directories
  manuscript_dp_folder <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED"
  study_dp_folder <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED"
  
  # read in DD database
  dd_database <- read_csv("./Data_Package_Documentation/database/data_dictionary_database.csv", show_col_types = F)
  
  
  ### Get list of DPs from database ############################################
  
  database_dps <- dd_database %>% 
    
    # select only file paths
    select(dd_source) %>% 
    distinct() %>% 
    
    # separate based on DP type
    mutate(type = ifelse(str_detect(dd_source, "Study-Data-Package"), "study", NA)) %>% 
    mutate(type = ifelse(str_detect(dd_source, "Manuscript-Data-Package"), "manuscript", type)) %>% 
    
    # remove parent folders 
    mutate(data_package = ifelse(str_detect(dd_source, "Study-Data-Package"), str_remove(dd_source, study_dp_folder), NA)) %>% 
    mutate(data_package = ifelse(str_detect(dd_source, "Manuscript-Data-Package"), str_remove(dd_source, manuscript_dp_folder), data_package)) %>% 
    
    # extract DP (extracting between the first 2 slashes)
    mutate(data_package = str_extract(data_package, "(?<=/)[^/]*/")) %>% 
    
    # clean up
    mutate(data_package = str_remove(data_package, "/$"))
    
    
  ### Get list of manuscript DPs ###############################################
  
  # get list of data package directories in the manuscript folder
  manuscript_dp_list <- list.dirs(manuscript_dp_folder, recursive = F, full.names = F)
  
  # get list of manuscript data packages in the database
  manuscript_dp_dd_list <- database_dps %>% 
    filter(type == "manuscript") %>% 
    select(data_package) %>% 
    pull()
  
  dp_to_add_manuscript <- setdiff(manuscript_dp_list, manuscript_dp_dd_list)
  
  
  ### Get list of study DPs ####################################################
  
  # get list of data package directories in the study folder
  study_dp_list <- list.dirs(study_dp_folder, recursive = F, full.names = F)
  
  # get list of manuscript data packages in the database
  study_dp_dd_list <- database_dps %>% 
    filter(type == "study") %>% 
    select(data_package) %>% 
    pull()
  
  dp_to_add_study <- setdiff(study_dp_list, study_dp_dd_list)
  
  
  ### Return DPs not in database ###############################################
  
  complete_list <- list(manuscript = dp_to_add_manuscript,
                        study = dp_to_add_study)
  
  return(complete_list)

}

