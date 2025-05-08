### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2021-2022_SensorData_v2/v2_RC2_TemporalStudy_2021-2022_SensorData"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2021-2022_SensorData_v2/v2_RC2_TemporalStudy_2021-2022_SensorData"
  

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
                                       exclude_files = c("BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-05-06.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-05-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-05-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-06-17.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-06-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-07-08.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-07-15.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-07-22.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-07-29.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-08-12.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-08-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-09-16.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-09-23.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-09-30.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-10-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-10-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-10-21.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-10-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-11-04.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-11-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-12-02.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2021-12-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-01-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-01-27.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-02-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-03-01.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-03-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-03-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T02_Mabton_2022-04-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-04-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-05-06.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-05-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-05-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-06-03.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-06-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-06-17.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-06-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-07-08.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-07-15.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-07-22.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-07-29.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-08-12.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-08-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-09-16.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-09-23.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-09-30.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-10-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-10-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-10-21.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-10-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-11-04.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-11-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-12-02.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2021-12-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2022-01-27.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2022-02-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2022-03-01.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2022-03-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2022-03-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T03_Union_Gap_2022-04-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-04-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-04-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-05-06.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-05-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-05-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-06-03.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-06-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-06-17.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-06-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-07-08.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-07-15.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-07-22.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-07-29.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-08-12.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-08-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-09-23.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-09-30.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-10-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-10-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-10-21.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-10-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-11-04.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-11-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2021-12-02.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2022-03-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T05P_Little_Naches_2022-03-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-04-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-04-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-05-06.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-05-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-05-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-06-03.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-06-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-06-17.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-06-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-07-08.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-07-15.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-07-22.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-07-29.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-08-12.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-08-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-09-16.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-09-23.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-09-30.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-10-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-10-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-10-21.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-10-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-11-04.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-11-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2021-12-02.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2022-03-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T06_American_River_2022-04-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-05-06.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-05-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-05-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-06-03.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-06-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-06-17.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-06-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-07-08.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-07-15.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-07-22.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-07-29.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-08-12.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-08-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-09-16.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-09-23.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-09-30.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-10-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-10-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-10-21.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-10-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-11-04.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-11-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-12-02.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2021-12-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-01-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-01-27.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-02-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-03-01.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-03-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-03-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T07_Kiona_2022-04-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T41_Naches_Craig_Road_1_2021-04-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-04-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-05-06.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-05-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-05-20.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-06-03.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-06-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-06-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-07-08.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-07-15.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-07-22.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-07-29.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-08-12.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-08-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-09-16.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-09-23.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-09-30.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-10-07.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-10-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-10-21.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-10-28.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-11-04.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-11-18.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-12-02.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2021-12-13.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2022-02-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2022-03-01.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2022-03-10.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2022-03-24.csv",
                                                         "BarotrollAtmData/Data/BarotrollAtm_T42_Naches_Craig_Road_2_2022-04-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-04-28.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-05-06.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-05-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-05-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-05-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-06-03.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-06-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-07-15.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-07-22.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-07-29.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-08-12.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-08-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-09-16.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-09-23.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-09-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-10-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-10-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-10-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-11-04.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-11-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2021-12-02.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2022-01-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2022-01-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2022-02-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2022-03-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T02_Mabton_2022-04-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-04-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-04-28.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-05-06.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-05-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-05-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-05-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-06-03.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-06-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-06-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-07-15.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-07-22.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-07-29.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-08-12.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-08-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-09-16.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-09-23.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-09-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-10-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-10-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-10-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-11-04.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-11-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2021-12-02.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2022-01-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2022-02-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2022-03-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T03_Union_Gap_2022-04-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-04-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-04-28.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-05-06.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-05-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-05-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-05-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-06-03.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-06-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-06-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-07-15.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-07-22.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-07-29.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-08-12.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-08-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-09-23.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-09-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-10-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-10-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-10-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-11-04.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-11-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2021-12-02.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2022-03-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T05P_Little_Naches_2022-04-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-04-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-04-28.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-05-06.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-05-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-05-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-05-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-06-03.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-06-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-06-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-07-15.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-07-22.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-07-29.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-08-12.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-08-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-09-16.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-09-23.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-09-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-10-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-10-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-10-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-11-04.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-11-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2021-12-02.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2022-03-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T06_American_River_2022-04-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-04-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-04-28.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-05-06.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-05-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-05-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-05-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-06-03.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-06-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-06-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-07-15.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-07-22.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-07-29.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-08-12.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-08-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-09-16.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-09-23.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-09-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-10-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-10-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-10-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-11-04.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-11-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-12-02.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2021-12-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2022-01-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2022-01-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2022-02-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2022-03-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T07_Kiona_2022-04-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T41_Naches_Craig_Road_1_2021-04-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T41_Naches_Craig_Road_1_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-04-28.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-05-06.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-05-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-05-20.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-05-27.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-06-03.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-06-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-06-17.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-06-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-07-15.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-07-22.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-07-29.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-08-12.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-08-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-09-16.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-09-23.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-09-30.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-10-07.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-10-13.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-10-21.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-11-04.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-11-18.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2021-12-02.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2022-02-10.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2022-03-24.csv",
                                                         "MantaRiverData/Data/MantaRiver_T42_Naches_Craig_Road_2_2022-04-07.csv"))


# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
# dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
# flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)

### DP Specific Edits ##########################################################
# left join prelim dd to this dd

prelim_dd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2021-2022_SensorData_v2/RC2_Sensor_dd.csv") %>%
  rename(Column_or_Row_Name = Name,
         Term_Type = Type) %>%
  select(-Column_Long_Name)

dd_skeleton <- dd_skeleton %>%
  select(Column_or_Row_Name) %>%
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  arrange(Column_or_Row_Name) 



# left join prelim flmd to this flmd

prelim_flmd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2021-2022_SensorData_v2/RC2_Sensor_flmd.csv")%>%
  select(-File_Path)

flmd_skeleton <- flmd_skeleton %>%
  select(File_Name, File_Path) %>%
  mutate(File_Name = str_remove(File_Name, 'v2_')) %>%
  left_join(prelim_flmd, by = c("File_Name")) %>%
  select(-File_Path, File_Path)



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


