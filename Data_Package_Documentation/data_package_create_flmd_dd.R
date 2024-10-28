### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_ESSDIVE/01_Study_DPs/SSS_Data_Package_v3/v3_SSS_Data_Package" 

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "Z:/00_ESSDIVE/01_Study_DPs/SSS_Data_Package_v3/v3_SSS_Data_Package"
  

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
data_package_data <- load_tabular_data(directory, exclude_files = c("Sensor_Data/BarotrollAtm/Data/v2_SSS002_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS003_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS005_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS007_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS008_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS009_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS010_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS011_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS012_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS013_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS014_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS015_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS017_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS018_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS019_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS020_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS021_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS022_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS023_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS024_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS025_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS026_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS027_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS028_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS029_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS030_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS031_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS032_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS033_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS034_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS035_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS036_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS037_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS038_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS039_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS040_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS041_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS042_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS043_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS044_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS045_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS046_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS047_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v2_SSS048_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v3_SSS004_Air_Press_Temp.csv",
                                                                    "Sensor_Data/BarotrollAtm/Data/v3_SSS006_Air_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS002_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS003_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS005_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS007_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS008_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS009_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS010_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS011_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS012_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS013_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS014_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS015_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS017_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS018_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS019_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS020_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS021_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS022_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS023_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS024_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS025_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS026_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS027_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS028_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS029_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS030_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS031_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS032_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS033_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS034_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS035_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS036_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS037_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS038_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS039_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS040_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS041_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS042_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS043_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS044_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS045_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS046_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS047_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v2_SSS048_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v3_SSS004_Water_Press_Temp.csv",
                                                                    "Sensor_Data/DepthHOBO/Data/v3_SSS006_Water_Press_Temp.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS002_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS003_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS005_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS007_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS008_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS009_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS010_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS011_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS012_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS013_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS014_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS015_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS017_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS018_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS019_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS020_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS021_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS022_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS023_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS024_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS025_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS026_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS027_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS031_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS032_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS033_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS034_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS035_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS036_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS037_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS038_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS039_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS040_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS041_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS042_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS043_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS044_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS045_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS046_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS047_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v2_SSS048_Water_Temp_SpC_Turb_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v3_SSS004_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/MantaRiver/Data/v3_SSS006_Water_Temp_SpC_Turb_pH_ChlA.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS002_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS003_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS005_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS007_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS008_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS009_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS010_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS011_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS012_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS013_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS014_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS015_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS017_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS018_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS019_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS020_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS021_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS022_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS023_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS024_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS025_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS026_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS027_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS028_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS029_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS030_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS031_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS032_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS033_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS034_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS035_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS036_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS037_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS038_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS039_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS040_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS041_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS042_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS043_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS044_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS045_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS046_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS047_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v2_SSS048_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v3_SSS004_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOT/Data/v3_SSS006_Water_DO_Temp.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS002_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS003_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS005_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS007_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS008_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS009_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS010_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS011_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS012_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS013_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS014_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS015_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS017_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS018_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS019_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS020_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS021_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS022_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS023_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS024_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS025_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS026_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS027_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS028_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS029_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS030_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS031_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS032_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS033_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS034_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS035_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS036_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS037_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS038_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS039_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS040_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS041_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS042_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS043_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS044_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS045_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS046_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS047_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v2_SSS048_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v3_SSS004_MC_Water_DO.csv",
                                                                    "Sensor_Data/miniDOTManualChamber/Data/v3_SSS006_MC_Water_DO.csv",
                                                                    "Sensor_Data/Sonar/SSS025_Water_Depth_Kayak1.csv",
                                                                    "Sensor_Data/Sonar/SSS025_Water_Depth_Kayak2.csv",
                                                                    "Sensor_Data/Sonar/SSS026_Water_Depth_Kayak1.csv",
                                                                    "Sensor_Data/Sonar/SSS026_Water_Depth_Kayak2.csv")) # doesnt load in all sensor data, just one for each data type

# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
# flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)

### DP Specific Edits ##########################################################

# left join prelim dd to this dd

prelim_dd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/SSS_Data_Package_v3/v2_SSS_dd.csv")

dd_skeleton <- dd_skeleton %>%
  select(Column_or_Row_Name) %>%
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  arrange(Column_or_Row_Name)

# left join prelim flmd to this flmd

prelim_flmd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/SSS_Data_Package_v3/v2_SSS_flmd.csv") %>%
  select(-File_Path)

flmd_skeleton <- flmd_skeleton %>%
  select(File_Name, File_Path) %>%
  left_join(prelim_flmd, by = c("File_Name")) %>%
  select(-File_Path, File_Path)

# add status column to list the cols that need to be filled in
find_na_columns <- function(row) {
  na_cols <- names(row)[is.na(row)]
  if (length(na_cols) == 0) {
    return("None")
  } else {
    return(paste(na_cols, collapse = ", "))
  }
}

# Using mutate and across to apply find_na_columns
flmd_skeleton_with_status <- flmd_skeleton %>%
  rowwise() %>%
  mutate(status = find_na_columns(cur_data())) %>%
  select(status, everything())



### join headers to dd #########################################################
# get headers
headers <- data_package_data$headers %>%
  mutate(relative_file = basename(file)) %>%
  group_by(header) %>% 
  summarise(header_count = n(),
            file_name = toString(relative_file),
            file_path = toString(file)) %>% 
  ungroup() %>% 
  arrange(header, .locale = "en")


dd_skeleton_with_header_source <- dd_skeleton_populated %>% 
  left_join(headers, by = c("Column_or_Row_Name" = "header")) %>% 
  select(-file_path)




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


### DP Specific Edits ##########################################################

# left join v4 CM dd to this dd

v4_CM_dd <- read_csv("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package/v4_CM_SSS_dd.csv")

dd_skeleton <- dd_skeleton %>% 
  select(Column_or_Row_Name) %>% 
  left_join(v4_CM_dd, by = c("Column_or_Row_Name"))

