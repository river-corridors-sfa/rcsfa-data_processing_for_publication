### data_package_update_dd_database.R ##########################################
# Date Created: 2024-04-30
# Date Updated: 2024-05-01
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
source("./Data_Package_Documentation/functions/get_DPs_not_in_dd_database.R")

# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### Check what needs to be updated #############################################
# Directions: Run this chunk without modification. 

# this returns a list of the data packages that you need to add to the dd database
get_DPs_not_in_dd_database()


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
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/2023_04_Roebuck/SPS_Roebuck_Data_Package/SPS_Roebuck_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/BSLE_Data_Package/BSLE_Data_Package/BSLE_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/BSLE_Data_Package_v2/BSLE_Data_Package_v2/BSLE_dd_v2.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/BSLE_Data_Package_v3/v3_BSLE_Data_Package/v3_BSLE_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Chemogeography_2021/Chemogeography_Data_package_2021/Data_Dictionaries/BTRS19_Metadata_for_publishing_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Chemogeography_2021/Chemogeography_Data_package_2021/Data_Dictionaries/BTRS19_Report_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Chemogeography_2021/Chemogeography_Data_package_2021/Data_Dictionaries/FLMD_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Chemogeography_2021/Chemogeography_Data_package_2021/Data_Dictionaries/Processed_BTRS19_CONUS_1-27_newcode_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Chemogeography_2021/Chemogeography_Data_package_2021/Data_Dictionaries/Processed_S19S_Sediments_Water_2-2_newcode_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Chemogeography_2021/Chemogeography_Data_package_2021/Data_Dictionaries/WHONDRS_S19S_Metadata_v2_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/CM_SSS_Data_Package_v1/CM_SSS_Data_Package/CM_SSS_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/CM_SSS_Data_Package_v2/v2_CM_SSS_Data_Package/v2_CM_SSS_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/CM_SSS_Data_Package_v3/v3_CM_SSS_Data_Package/v3_CM_SSS_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Cross-RCSFA_Geospatial_Data_Package/RCSFA_Geospatial_Data_Package_v1/RCSFA_Geospatial_dd_v1.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Cross-RCSFA_Geospatial_Data_Package_v2/v2_RCSFA_Geospatial_Data_Package/v1_RCSFA_Geospatial_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Cross-RCSFA_Geospatial_Data_Package_v3/v3_RCSFA_Geospatial_Data_Package/v2_RCSFA_Geospatial_dd.csv")
ddd <- update_dd_database()
ddd <- update_dd_database()
ddd <- update_dd_database()







