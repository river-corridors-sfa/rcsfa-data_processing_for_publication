### data_package_update_dd_database.R ##########################################
# Date Created: 2024-04-30
# Date Updated: 2024-04-30
# Author: Bibi Powers-McCormack

# Objective: This script will generate a static list of all the times the ddd was updated. 

# Assumptions: 
  # DO NOT RERUN this script. If you rerun this script in its entirety, it might create duplicate entries in the database.
  # Only run the lines when you add them. 


### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(tidyverse)
library(rlog)

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()


# load functions
source("./Data_Package_Documentation/functions/update_dd_database.R")

# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### RECORD KEEPING #############################################################
# Directions: Add new data package(s) to the growing list and only run the ones you add. 

# MANUSCRIPT DATA PACKAGES ----
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Bao_2023_Residence_Time_Distribution_Manuscript_Data_Package/Bao_2024_Residence_Time_Distribution_Data_Package/Bao_2024_Residence_Time_Distribution_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Cavaiani_2024_Metaanalysis_Manuscript_Data_Package/Cavaiani_2024_Metaanalysis_Manuscript_Data_Package/Cavaiani_2024_Metaanalysis_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Danczak_2023_48Hour_Manuscript_Data_Package/Danczak_2023_48Hour_Manuscript_Data_Package/48Hour_dd.csv")
ddd <- update_dd_database(upload_file_path = "C:/Users/powe419/OneDrive - PNNL/Desktop/Fulton_2024_Water_Column_Respiration_Data_Package_dd.csv",
                          archive_file_path = "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Fulton_2023_Water_Column_Manuscript_Data_Package/Fulton_2024_Water_Column_Respiration_Data_Package/Fulton_2024_Water_Column_Respiration_Data_Package_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Gary_2024_sl-archive-whondrs_Manuscript_Data_Package/sl_archive_whondrs_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Kassianov_2023_AML_Plumes_Manuscript_Data_Package/Kassianov_2023_AML_Plumes/Kassianov_2024_AML_Plumes_dd.csv")
ddd <- update_dd_database(upload_file_path = "C:/Users/powe419/OneDrive - PNNL/Desktop/Muller_2024_Lambda_PFLOTRAN_Manuscript_Data_Package_dd.csv",
                          archive_file_path = "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Muller_2024_Lambda_Pipeline_Manuscript_Data_Package/Muller_2024_Lambda_PFLOTRAN_Manuscript_Data_Package/Muller_2024_Lambda_PFLOTRAN_Manuscript_Data_Package_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Roebuck_2023_S19S_XRF_ICR_Manuscript_Data_Package/XRF_FTICR_Manuscript_Data_Package/XRF_ICR_Manuscript_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Zahura_2023_Postfire_Recovery_Manuscript_Data_Package/Postfire_recovery_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/03_Manuscript-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Zheng_2023_Bioenergetic_Modeling_Manuscript_Data_Package/Zheng_2023_Bioenergetic_Modeling_Manuscript_Data_Package/Zheng_bioenergetic_modeling_dd.csv")



# STUDY DATA PACKAGES ----
ddd <- update_dd_database()


