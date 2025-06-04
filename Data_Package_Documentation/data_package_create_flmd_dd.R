### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
# It will create empty data dictionary and file-level metadata skeletons.S

  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package_v2/v2_WHONDRS_AV1_Data_Package"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package_v2/v2_WHONDRS_AV1_Data_Package"
  

### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs)
library(clipr)
library(tools)

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()
original_wd <- getwd()

# load functions
source("./Data_Transformation/functions/load_tabular_data.R")
source("./Data_Package_Documentation/functions/create_dd_skeleton.R")
source("./Data_Package_Documentation/functions/create_flmd_skeleton.R")
source("./Data_Package_Documentation/functions/query_dd_database.R")
source("./Data_Package_Documentation/functions/query_flmd_database.R")


# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 


# 1. Load data
# for excluding or including files, write the relative path from the directory, without slash in the beginning
data_package_data <- load_tabular_data(directory,
                                       exclude_files = c("Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_SED_Blk-1_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_031_SED-3_p16.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_031_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_031_SED-1_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_030_SED-3_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_030_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_030_SED-1_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_029_SED-3_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_029_SED-2_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_029_SED-1_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_028_SED-3_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_028_SED-2_p17.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_028_SED-1_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_027_SED-3_p065.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_027_SED-2_p07.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_027_SED-1_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_026_SED-3_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_026_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_026_SED-1_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_025_SED-3_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_025_SED-2_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_025_SED-1_p06.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_024_SED-3_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_024_SED-2_p115.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_024_SED-1_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_023_SED-3_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_023_SED-2_p17.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_023_SED-1_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_022_SED-3_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_022_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_022_SED-1_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_021_SED-3_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_021_SED-2_p115.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_021_SED-1_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_020_SED-3_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_020_SED-2_p16.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_020_SED-1_p14.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_019_SED-3_p14.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_019_SED-2_p14.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_019_SED-1_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_017_SED-3_p18.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_017_SED-2_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_017_SED-1_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_016_SED-3_p125.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_016_SED-2_p16.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_016_SED-1_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_015_SED-3_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_015_SED-2_p08.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_015_SED-1_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_014_SED-3_p17.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_014_SED-1_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_013_SED-3_p08.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_013_SED-2_p85.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_013_SED-1_p06.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_012_SED-3_p16.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_012_SED-2_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_012_SED-1_p175.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_011_SED-3_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_011_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_011_SED-1_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_010_SED-3_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_010_SED-2_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_010_SED-1_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_009_SED-3_p105.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_009_SED-2_p15.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_009_SED-1_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_008_SED-3_p08.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_008_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_008_SED-1_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_007_SED-3_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_007_SED-2_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_007_SED-1_p14.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_006_SED-3_p18.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_006_SED-2_p1.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_006_SED-1_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_005_SED-3_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_005_SED-2_p11.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_005_SED-1_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_002_SED-3_p16.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_002_SED-2_p12.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_002_SED-1_p09.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_001_SED-3_p16.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_001_SED-2_p13.corems.csv",
                                                         "Sample_Data/FTICR/Sediment_CoreMS_Output_Files/AV1_001_SED-1_p12.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_031_ICR-3_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_031_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_031_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_030_ICR-3_p045.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_030_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_030_ICR-1_p075.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_029_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_029_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_029_ICR-1_p065.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_028_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_028_ICR-2_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_028_ICR-1_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_027_ICR-3_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_027_ICR-2_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_027_ICR-1_p04.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_025_ICR-3_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_025_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_025_ICR-1_p09.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_024_ICR-3_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_024_ICR-2_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_024_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_023_ICR-3_p09.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_023_ICR-2_p04.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_022_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_022_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_022_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_021_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_021_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_021_ICR-1_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_020_ICR-3_p065.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_020_ICR-2_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_020_ICR-1_p065.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_019_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_019_ICR-2_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_019_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_017_ICR-3_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_017_ICR-2_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_017_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_016_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_016_ICR-2_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_016_ICR-1_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_015_ICR-3_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_015_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_015_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_013_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_013_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_013_ICR-1_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_012_ICR-3_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_012_ICR-2_p09.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_012_ICR-1_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_011_ICR-3_p09.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_011_ICR-2_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_011_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_010_ICR-3_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_010_ICR-2_p09.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_010_ICR-1_p055.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_007_ICR-3_p07.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_007_ICR-2_p045.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_007_ICR-1_p055.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_006_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_006_ICR-2_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_006_ICR-1_p08.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_005_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_005_ICR-2_p05.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_005_ICR-1_p065.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_001_ICR-3_p06.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_001_ICR-2_p065.corems.csv",
                                                         "Sample_Data/FTICR/Water_CoreMS_Output_Files/AV1_001_ICR-1_p06.corems.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_005_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_006_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_007_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_010_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_011_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_012_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_013_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_015_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_016_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_017_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_019_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_020_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_021_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_022_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_023_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_024_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_025_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_027_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_028_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_029_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_030_Water_DO_Temp.csv",
                                                         "Sensor_Data/AV1_miniDOT_Data_and_Plots/WHONDRS_AV1_031_Water_DO_Temp.csv"))


# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
# dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
# flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)

### DP Specific Edits ##########################################################
# # left join prelim dd to this dd
# 
prelim_dd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package_v2/Archive/WHONDRS_AV1_dd.csv")

dd_skeleton <- dd_skeleton %>%
  select(Column_or_Row_Name) %>%
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  add_row(prelim_dd%>%
            anti_join(dd_skeleton, by = c("Column_or_Row_Name"))) %>%
  arrange(Column_or_Row_Name)
# 
# view(prelim_dd%>%
#   select(Column_or_Row_Name) %>%
#   anti_join(dd_skeleton, by = c("Column_or_Row_Name")))

# # left join prelim flmd to this flmd

# prelim_flmd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/SSF_Data_Package_v2/SSF_flmd.csv")%>%
#   select(-File_Path)
# 
# flmd_skeleton <- flmd_skeleton %>%
#   select(File_Name, File_Path) %>%
#   mutate(temp = str_remove(File_Name, 'v2_')) %>%
#   left_join(prelim_flmd, by = c(temp = "File_Name")) %>%
#   select(-File_Path, File_Path)


### Export #####################################################################
# Directions: 
  # Export out .csvs at your choosing. Only run the lines you want. 
  # After exporting, remember to properly rename the dd and flmd files and to update the flmd to reflect such changes.

# write out data package data
save(data_package_data, file = paste0(out_directory, "/data_package_data.rda"))

# write out skeleton dd
write_csv(dd_skeleton, paste0(out_directory, "/skeleton_dd.csv"), na = "")

# write out populated dd
write_csv(dd_skeleton_populated, paste0(out_directory, "/skeleton_populated_dd.csv"), na = "")

# write out skeleton flmd
write_csv(flmd_skeleton, paste0(out_directory, "/skeleton_flmd.csv"), na = "")

# writ eout populated flmd
write_csv(flmd_skeleton_populated, paste0(out_directory, "/skeleton_populated_flmd.csv"), na = "")

# open the directory the files were saved to
shell.exec(out_directory)


