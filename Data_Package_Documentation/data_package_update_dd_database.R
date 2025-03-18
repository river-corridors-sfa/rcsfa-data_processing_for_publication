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
source("./Data_Package_Documentation/functions/annotate_dd_database.R")

# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### Check what needs to be updated #############################################
# Directions: Run this chunk without modification. 

# this returns a list of the data packages that you need to add to the dd database
get_DPs_not_in_dd_database()


### RECORD KEEPING: Add new DPs to ddd #########################################
# Directions: Add new data package(s) to the growing list and only run the ones you add. 

# ~ manuscript data packages ----
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
ddd <- update_dd_database("Z:/00_ESSDIVE/03_Manuscript_DPs/00_ARCHIVE-WHEN-PUBLISHED/Shi_2024_Ecosystem_Responses_To_Wildfires_Manuscript_Data_Package/Shi_Ecosystem_Responses_To_Wildfires_dd.csv")
ddd <- update_dd_database()


# ~ study data packages ----
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
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/D50_2021_Spatial_Study_Manuscript_Data_Package/D50_2021_Spatial_Study_Manuscript_Data_Package/d50_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Fulton_OS_Sensors_Data_Package/Fulton_OS_Sensors_Data_Package/OS_Sensor_Comparison_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Kaufman_Multireactor_Data_Package/Kaufman_Multireactor_Data_Package/Multireactor_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/1. Metadata_4Jun2021_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/2. Stegen_EC_Raw_DO_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/3. cDNA_bNTI_weighted_rare_27227_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/4. cDNA_OTU_rarefied_27227_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/5. gDNA_bNTI_weighted_rare_15106_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/6. gDNA_OTU_rarefied_15106_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/7. EC_Stegen_Report_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/8. Reactorspecificdata_forStatistics_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/9. cDNA_OTU_rarefied_27227_betadisp_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/10. gDNA_OTU_rarefied_15106_betadisp_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/11. CPI.vs.betdisp_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Mesocosm_DataPackage_2021/DataPackage/7_Data_Dictionaries/FLMD_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Optode_methods_2021/Optode_methods_Data_package_2021/dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC2_TemporalStudy_2021-2022_SampleData/RC2_TemporalStudy_2021-2022_SampleData/RC2_Sample_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC2_TemporalStudy_2021-2022_SampleData_v2/v2_RC2_TemporalStudy_2021-2022_SampleData/v2_RC2_Sample_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC2_TemporalStudy_2021-2022_SensorData/RC2_TemporalStudy_2021-2022_SensorData/RC2_Sensor_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC3_EWEB_Nov2020_DataPackage_May_2022_AR/RC3_EWEB_Nov2020_DataPackage_May_2022/1_Metadata/Metadata_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC3_EWEB_Nov2020_DataPackage_May_2022_AR/RC3_EWEB_Nov2020_DataPackage_May_2022/2_EnvData/EnvData_terms_dd_combo.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC3_EWEB_Nov2020_DataPackage_May_2022_AR/RC3_EWEB_Nov2020_DataPackage_May_2022/3_SensorData/SensorData_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/RC3_EWEB_Nov2020_DataPackage_May_2022_AR/RC3_EWEB_Nov2020_DataPackage_May_2022/4_FTICR_SupportingData/SupportingTable_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Roley_CR_Metabolism_Data_Package/Roley_CR_Metabolism_Data_Package/DO_temp_sensor_data_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Roley_CR_Metabolism_Data_Package/Roley_CR_Metabolism_Data_Package/Kdistrib_Ar_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Roley_CR_Metabolism_Data_Package/Roley_CR_Metabolism_Data_Package/metabolism_data_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Roley_CR_Metabolism_Data_Package/Roley_CR_Metabolism_Data_Package/Roley_CR_Metabolism_Data_Package_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SampleData/SFA_SpatialStudy_2021_SampleData/SPS_Sample_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SampleData_v2/v2_SFA_SpatialStudy_2021_SampleData/SPS_Sample_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SensorData/SFA_SpatialStudy_2021_SensorData/SPS_Sensor_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SensorData_v2/SFA_SpatialStudy_2021_SensorData_v2/SPS_Sensor_dd_v2.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Son_et_al_2022_Denitrification_Data_Package/Son_et_al_2022_Denitrification_Data_Package/denitrification_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Son_et_al_2022_Respiration_Data_Package/Son_et_al_2022_Respiration_Data_Package/respiration_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SSF_Data_Package/SSF_Data_Package/SSF_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SSS_Data_Package/SSS_Data_Package/SSS_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SSS_Data_Package_v2/v2_SSS_Data_Package/v2_SSS_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/SSS_Ecosystem_Respiration_Data_Package/SSS_Ecosystem_Respiration_Data_Package/SSS_ER_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Transformations_2021/Transformations_Data_package_2021/dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Transformations_2021/Transformations_Data_package_2021_v2/dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/Wenas_Data_Package/Wenas_Data_Package/YRBT_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_DBP_Data_Package/WHONDRS_DBP_Data_Package/DBP_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_Sediment_v4/WHONDRS_S19S_Sediment_v4/dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_Sediment_v5/WHONDRS_S19S_Sediment_v5/dd_v5.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_Sediment_v6/WHONDRS_S19S_Sediment_v6/dd_v4.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_Sediment_v7/WHONDRS_S19S_Sediment_v7/dd_v5.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_Sediment_v8/v8_WHONDRS_S19S_Sediment/v6_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_SW_v4/WHONDRS_S19S_SW_v4/dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_SW_v5/WHONDRS_S19S_SW_v5/dd_v2.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_S19S_SW_v6/v6_WHONDRS_S19S_SW/v3_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_STL_Data_Package/WHONDRS_STL_Data_Package/WHONDRS_STL_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_WROL2019_Data_Package/WHONDRS_WROL2019_Data_Package/WHONDRS_WROL_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_WROL2019_Data_Package_v2/WHONDRS_WROL2019_Data_Package_v2/WHONDRS_WROL_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_WROL2019_Data_Package_v3/v3_WHONDRS_WROL2019_Data_Package/v2_WHONDRS_WROL_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_YDE21_Data_Package/WHONDRS_YDE21_data_package/WHONDRS_YDE21_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_YDE21_Data_Package_v2/WHONDRS_YDE21_Data_Package_v2/WHONDRS_YDE21_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/WHONDRS_YDE22_Data_Package/WHONDRS_YDE22_Data_Package/WHONDRS_YDE22_dd.csv")
ddd <- update_dd_database("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/00_ARCHIVE-WHEN-PUBLISHED/YOLO_ESSDive/dd.csv")
ddd <- update_dd_database()



### Annotate dd database #######################################################
# Directions: Run this function to annotate (mark as archive and add notes) the dd database

# checks status of annotations for X columns
annotate_dd_database_status(number_of_results = 20) 

# annotates dd database by iterating through each header and asking user for annotation
annotate_dd_database(num_headers_to_assess = 10) # returns the top X header/unit/definitions used most often

