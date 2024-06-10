### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package"

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/INBOX/data_package_skeletons"
  

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
data_package_data <- load_tabular_data(directory, exclude_files = c("Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_002_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_003_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_004_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_005_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_006_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_007_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_008_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_009_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_010_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_011_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_012_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_013_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_014_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_015_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_016_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_017_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_018_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_020_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_021_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_022_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_023_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_024_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_025_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_026_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_027_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_028_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_029_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_030_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_032_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_033_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_034_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_035_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_037_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_038_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_039_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_040_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_041_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_042_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_043_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_044_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_046_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_047_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_048_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_049_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_050_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_051_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_052_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_053_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_054_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_055_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_056_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_057_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_058_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_059_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_060_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_061_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_062_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_063_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_064_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_065_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_066_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_068_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_069_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_070_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_071_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_072_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_073_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_074_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_075_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_076_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_077_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_078_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_079_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_080_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_081_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_082_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_083_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_084_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_085_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_086_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_087_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_088_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_089_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_090_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_091_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_092_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_093_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_094_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_095_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_096_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_097_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_098_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_099_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_100_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_101_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_102_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_103_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_104_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_105_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_106_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_107_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_108_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_109_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_110_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_111_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_112_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_113_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_114_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_115_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_116_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_CM_117_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS001_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS002_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS003_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS004_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS005_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS006_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS007_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS008_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS009_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS010_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS011_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS012_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS013_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS014_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS015_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS016_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS017_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS018_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS019_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS020_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS021_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS022_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS023_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS024_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS025_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS026_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS027_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS028_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS029_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS030_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS031_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS032_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS033_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS034_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS035_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS036_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS037_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS038_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS039_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS040_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS041_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS042_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS043_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS044_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS045_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS046_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS047_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v2_SSS048_DO_Temp.csv",
                                                                    "Sensor_Data/CM_SSS_miniDOT_Data_and_Plots/v3_CM_045_DO_Temp.csv"))


# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)


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

# join old dd to new dd

old_dd <- read_csv("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package/v4_CM_SSS_dd.csv") %>% 
  select(Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type)

dd_skeleton <- dd_skeleton %>% 
  select(Column_or_Row_Name)

dd_skeleton_2 <- dd_skeleton %>% 
  left_join(old_dd, by = intersect(names(dd_skeleton), names(old_dd))) %>% 
  filter(!Column_or_Row_Name %in% c("...6", "...7")) %>% 
  mutate(Unit = str_replace_all(Unit, "_", " "))



# join old flmd to new flmd

old_flmd <- read_csv("Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package/v4_CM_SSS_flmd.csv") %>% 
  select(File_Name, File_Description, Standard, Date_Start, Date_End, Missing_Value_Codes)

flmd_skeleton <- flmd_skeleton %>% 
  select(File_Name, File_Path)

flmd_skeleton_2 <- flmd_skeleton %>% 
  left_join(old_flmd, by = intersect(names(flmd_skeleton), names(old_flmd))) %>% 
  select(File_Name, File_Description, Standard, Date_Start, Date_End, Missing_Value_Codes, File_Path)

# write out joined files
write_csv(dd_skeleton_2, "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package/CM_SSS_dd_20240610.csv", na = "")

write_csv(flmd_skeleton_2, "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4/v4_CM_SSS_Data_Package/CM_SSS_flmd_20240610.csv", na = "")
