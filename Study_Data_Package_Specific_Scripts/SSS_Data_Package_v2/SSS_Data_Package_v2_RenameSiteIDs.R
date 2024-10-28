### SSS_Data_Package_v2_RenameSiteIDs.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: 2023-07-21 by Bibi Powers-McCormack
# Date Updated: 2023-08-03 by Bibi Powers-McCormack

# Objective: Update site_id names in the sensor data and photo filenames. Data were assumed to be collected at a specific site were actually collected far enough away to warrant having their own sub site IDs. This script updates the site IDs in (only) the sensor data and photo filenames. The remaining .csv files that had this site ID issue were manually updated.
  # - rename S55 to S55N
  # - rename S56 to S56N
  # - rename T41 to T42

# Inputs: the original sensor files and photo filenames
# Outputs: v2 sensor, sensor summary files, photo filenames


### FILE SET UP ##############################

# Load libraries
library(tidyverse)

# set working directory
getwd()

# Load functions
source("./SSS_Data_Package_v2_function_CheckFileVersions.R")
source("./SSS_Data_Package_v2_function_RenameSiteID.R")
source("./SSS_Data_Package_v2_function_RenameSummarySiteID.R")
source("./SSS_Data_Package_v2_function_RenamePhotoFilenames.R")





### CHANGE SITE ID NAMES IN SENSOR DATA ##############################

# S55 is renamed to S55N in all of the sensor files. The first line renames the sensor files and the second line renames the site in the summary file. 
rename_site_id(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Data/", parent_id = "SSS004", old_SiteID = "S55", new_SiteID = "S55N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Plots_and_Summary_Statistics/", old_SiteID = "S55", new_SiteID = "S55N")

rename_site_id(filepath = "./v2_SSS_Data_Package/DepthHOBO/Data/", parent_id = "SSS004", old_SiteID = "S55", new_SiteID = "S55N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/DepthHOBO/Plots_and_Summary_Statistics/", old_SiteID = "S55", new_SiteID = "S55N")

rename_site_id(filepath = "./v2_SSS_Data_Package/MantaRiver/Data/", parent_id = "SSS004", old_SiteID = "S55", new_SiteID = "S55N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/MantaRiver/Plots_and_Summary_Statistics/", old_SiteID = "S55", new_SiteID = "S55N")

rename_site_id(filepath = "./v2_SSS_Data_Package/miniDOT/Data/", parent_id = "SSS004", old_SiteID = "S55", new_SiteID = "S55N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/miniDOT/Plots_and_Summary_Statistics/", old_SiteID = "S55", new_SiteID = "S55N")

rename_site_id(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Data/", parent_id = "SSS004", old_SiteID = "S55", new_SiteID = "S55N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Plots_and_Summary_Statistics/", old_SiteID = "S55", new_SiteID = "S55N")

# check to make sure I've manually deleted all of the original versions; there should only be one copy of each parent_id
check_file_versions(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Data/", parent_id = "SSS004")
check_file_versions(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Plots_and_Summary_Statistics/", parent_id = "Summary")
check_file_versions(filepath = "./v2_SSS_Data_Package/DepthHOBO/Data/", parent_id = "SSS004")
check_file_versions(filepath = "./v2_SSS_Data_Package/DepthHOBO/Plots_and_Summary_Statistics/", parent_id = "Summary")
check_file_versions(filepath = "./v2_SSS_Data_Package/MantaRiver/Data/", parent_id = "SSS004")
check_file_versions(filepath = "./v2_SSS_Data_Package/MantaRiver/Plots_and_Summary_Statistics/", parent_id = "Summary")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOT/Data/", parent_id = "SSS004")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOT/Plots_and_Summary_Statistics/", parent_id = "Summary")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Data/", parent_id = "SSS004")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Plots_and_Summary_Statistics/", parent_id = "Summary")


# S56 is renamed to S56N in all of the sensor files. The first line renames the sensor files and the second line renames the site in the summary file.
rename_site_id(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Data/", parent_id = "SSS006", old_SiteID = "S56", new_SiteID = "S56N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Plots_and_Summary_Statistics/", old_SiteID = "S56", new_SiteID = "S56N")

rename_site_id(filepath = "./v2_SSS_Data_Package/DepthHOBO/Data/", parent_id = "SSS006", old_SiteID = "S56", new_SiteID = "S56N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/DepthHOBO/Plots_and_Summary_Statistics/", old_SiteID = "S56", new_SiteID = "S56N")

rename_site_id(filepath = "./v2_SSS_Data_Package/MantaRiver/Data/", parent_id = "SSS006", old_SiteID = "S56", new_SiteID = "S56N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/MantaRiver/Plots_and_Summary_Statistics/", old_SiteID = "S56", new_SiteID = "S56N")

rename_site_id(filepath = "./v2_SSS_Data_Package/miniDOT/Data/", parent_id = "SSS006", old_SiteID = "S56", new_SiteID = "S56N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/miniDOT/Plots_and_Summary_Statistics/", old_SiteID = "S56", new_SiteID = "S56N")

rename_site_id(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Data/", parent_id = "SSS006", old_SiteID = "S56", new_SiteID = "S56N")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Plots_and_Summary_Statistics/", old_SiteID = "S56", new_SiteID = "S56N")


# check to make sure I've manually deleted all of the original versions of the S56 sensor data; there should only be one copy of each parent_id
# there's no need to check the summary sensor files since I wrote over the v2 versions that were generated from updating the S55 sites
check_file_versions(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Data/", parent_id = "SSS006")
check_file_versions(filepath = "./v2_SSS_Data_Package/DepthHOBO/Data/", parent_id = "SSS006")
check_file_versions(filepath = "./v2_SSS_Data_Package/MantaRiver/Data/", parent_id = "SSS006")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOT/Data/", parent_id = "SSS006")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Data/", parent_id = "SSS006")


# T41 is renamed to T42 in all of the sensor files. The first line renames the sensor files and the second line renames the site in the summary file.
rename_site_id(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Data/", parent_id = "SSS016", old_SiteID = "T41", new_SiteID = "T42")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Plots_and_Summary_Statistics/", old_SiteID = "T41", new_SiteID = "T42")

rename_site_id(filepath = "./v2_SSS_Data_Package/DepthHOBO/Data/", parent_id = "SSS016", old_SiteID = "T41", new_SiteID = "T42")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/DepthHOBO/Plots_and_Summary_Statistics/", old_SiteID = "T41", new_SiteID = "T42")

rename_site_id(filepath = "./v2_SSS_Data_Package/MantaRiver/Data/", parent_id = "SSS016", old_SiteID = "T41", new_SiteID = "T42")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/MantaRiver/Plots_and_Summary_Statistics/", old_SiteID = "T41", new_SiteID = "T42")

rename_site_id(filepath = "./v2_SSS_Data_Package/miniDOT/Data/", parent_id = "SSS016", old_SiteID = "T41", new_SiteID = "T42")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/miniDOT/Plots_and_Summary_Statistics/", old_SiteID = "T41", new_SiteID = "T42")

rename_site_id(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Data/", parent_id = "SSS016", old_SiteID = "T41", new_SiteID = "T42")
rename_summary_site_id(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Plots_and_Summary_Statistics/", old_SiteID = "T41", new_SiteID = "T42")


# check to make sure I've manually deleted all of the original versions of the T41 sensor data; there should only be one copy of each parent_id
# there's no need to check the summary sensor files since I wrote over the v2 versions that were generated from updating the S55 and S56 sites
check_file_versions(filepath = "./v2_SSS_Data_Package/BarotrollAtm/Data/", parent_id = "SSS016")
check_file_versions(filepath = "./v2_SSS_Data_Package/DepthHOBO/Data/", parent_id = "SSS016")
check_file_versions(filepath = "./v2_SSS_Data_Package/MantaRiver/Data/", parent_id = "SSS016")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOT/Data/", parent_id = "SSS016")
check_file_versions(filepath = "./v2_SSS_Data_Package/miniDOTManualChamber/Data/", parent_id = "SSS016")



### CHANGE SITE ID NAMES IN PHOTO FILENAMES ##############################

# change site_IDs from S55 to S55N
rename_photo_filenames(filepath = "./v2_SSS_Data_Package/SedimentQuadratPhotos_Part2/", old_SiteID = "S55", new_SiteID = "S55N")

# change site_IDs from S56 to S56N
rename_photo_filenames(filepath = "./v2_SSS_Data_Package/SedimentQuadratPhotos_Part2/", old_SiteID = "S56", new_SiteID = "S56N")

# change site_IDs from T41 to T42
rename_photo_filenames(filepath = "./v2_SSS_Data_Package/SedimentQuadratPhotos_Part2/", old_SiteID = "T41", new_SiteID = "T42")


