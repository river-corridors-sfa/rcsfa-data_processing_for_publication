### recreate_SESAR_template.R ##################################################
# Date Created: 2024-11-07
# Date Updated: 2024-11-07
# Author: Bibi Powers-McCormack

# Background: 
  # ESS-DIVE would like us to provide the SESAR template that we used to register
  # samples to the SESAR database. However, we have since updated the SESAR
  # database, meaning that the template that we originally used is now out of
  # date.
  
  # To rectify this, we can create a new file by downloading the data from SESAR.
  # We can use the IGSNs from the data package to query SESAR and download the
  # information. Unfortunately, the downloaded file doesn't match the original
  # templated file, so we will also have to do some manipulation to that file to
  # fix columns.

# Objective: Recreate a SESAR upload template from samples already registered in the SESAR database
  # Because we can't provide the original SESAR upload template that we used to
  # register samples, this script recreates the template and includes it in an 
  # `ESS_DIVE_Infrastructure_ONLY` folder in the data package.

# Assumptions: 
  # Requires input IGSN file to have 2 columns: `IGSN` that has the sample IGSNs and `Parent_IGSN` that has the site IGSNs.
  # The input file IGSNs should not have the full DOI URL. They can look like "10.58052/IEPRS007S" or "IEPRS007S".

# Directions: 
  # Go through this script line by line for directions on how to navigate
  # downloading info from the SESAR database and creating the psuedo template
  # files

# Status: 
  # complete. 
  # possible future enhancements: splitting the samples in groupings of 100 and copying each for the user


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(devtools)
library(rlog)
library(clipr)
library(readxl)

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")

# user inputs - update these each time you run the script
data_package_igsns <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/SFA_SpatialStudy_2021_SampleData_v3/v3_SFA_SpatialStudy_2021_SampleData/SPS_Sample_IGSN-Mapping.csv", skip = 1) # read in the file from your data package that has IGSN and Parent_IGSN cols
ess_dive_infrastructure_only_dir <- "Z:/00_ESSDIVE/01_Study_DPs/SFA_SpatialStudy_2021_SampleData_v3/ESS_DIVE_Infrastructure_ONLY"

# create and open your temp directory - this folder and files in it will automatically delete when your R session ends
temp_dir <- tempdir()
shell.exec(temp_dir)


### Download from SESAR ########################################################
# first pull the IGSNs from the data package
# manipulate them into a version that can be copied into the search query in SESAR
# search for files
# download them to a temporary directory

# get site IGSN col
site_igsns <- data_package_igsns %>% 
  mutate(Parent_IGSN = str_replace_all(Parent_IGSN, "\\s+", "")) %>% 
  select(Parent_IGSN) %>%
  distinct() %>% 
  {print(paste0("There are ", nrow(.), " sites.")); .} %>% 
  pull(.) %>% 
  str_c(collapse = ", ")

# copy IGSNs to clipboard
write_clip(site_igsns)

# go to website
browseURL("https://www.geosamples.org/search-options/catalog-search")

# in the "search by multiple IGSNs" box, paste in your site IGSNs
# scroll down and click the blue "search" button

# copy this temp directory to your clipboard
dir.create(paste0(temp_dir, "/sites"))
write_clip(paste0(temp_dir, "/sites"))

# go back to website and click the grey "Download" button
# when the dialog box to save the file comes up, paste the temp_dir URL into the folder path
# no need to rename the file, click save


# now we're gonna do the same thing but for samples

# get sample IGSN col
sample_igsns <- data_package_igsns %>% 
  mutate(IGSN = str_replace_all(IGSN,  "\\s+", "")) %>% 
  select(IGSN) %>% 
  distinct() %>% 
  {print(paste0("There are ", nrow(.), " samples.")); .} %>% 
  pull() %>% 
  str_c(collapse = ", ")

# copy IGSNs to clipboard
write_clip(sample_igsns)

# go to website
browseURL("https://www.geosamples.org/search-options/catalog-search")

# in the "search by multiple IGSNs" box, paste in your sample IGSNs
# scroll down and click the blue "search" button

# copy this temp directory to your clipboard
dir.create(paste0(temp_dir, "/samples"))
write_clip(paste0(temp_dir, "/samples"))

# go back to website and click the grey "Download" button
# when the dialog box to save the file comes up, paste the temp_dir URL into the folder path
# no need to rename the file, click save
# if it doesn't let you download all of them at the same time, you can download in batches of 100 and save each file to that same `/samples` sub directory


### Identify format of desired output ##########################################

# list out the headers of the final file. I got these final column headers from downloading a batch template from mySESAR. 
output_site_header <- tibble('Object Type:'= as.character(),
                            'Site'= as.character(),
                            'User Code:'= as.character(), 
                            'IEWDR' = as.character()) # 'IEWDR' is for WHONDRS

output_site_columns <- c("Sample Name", "IGSN", "Parent IGSN", 
                         "Release Date", "Geological unit", "Comment", 
                         "Purpose", "Latitude", "Longitude", 
                         "Vertical datum", "Elevation start", "Elevation unit", "Navigation type", 
                         "Primary physiographic feature", "Name of physiographic feature", 
                         "Location description", "Locality", "Locality description", "Country", "State/Province", "County", "City/Township", 
                         "Field program/cruise", "Collector/Chief Scientist", "Collector/Chief Scientist Address") 

output_sample_header <- tibble('Object Type:'= as.character(),
                            'Individual Sample'= as.character(),
                            'User Code:'= as.character(), 
                            'IEWDR' = as.character()) # 'IEWDR' is for WHONDRS

output_sample_columns <- c("Sample Name", "IGSN", "Parent IGSN", "Release Date", 
                           "Material", "Field name (informal classification)", "Classification", 
                           "Collection method", "Purpose", "Latitude", "Longitude", 
                           "Elevation start", "Elevation unit", "Navigation type", 
                           "Primary physiographic feature", "Name of physiographic feature", 
                           "Field program/cruise", "Collector/Chief Scientist", "Collection date", 
                           "Collection date precision", "Current archive", "Current archive contact")


### Create SITES SESAR template ################################################

# read in site file(s)
site_files <- list.files(paste0(temp_dir, "/sites"), pattern = ".xlsx$", full.names = T) # gets all xlsx files from the temp dir
basename(site_files)

# initialize empty df
sites_template <- tibble()

for (i in 1:length(site_files)) {
  
  log_info(paste0("Reading in ", i, " of ", length(site_files), ": ", basename(site_files[i])))
  
  current_file <- read_excel(site_files[i])
  
  sites_template <- sites_template %>% 
    rbind(., current_file)
  
}

# rename columns
sites_template <- rename_column_headers(sites_template, output_site_columns)

# remove cols where all values are NA
output_sites_template <- sites_template %>% 
  select_if(~ !all(is.na(.))) %>% # only selects columns that have content in them
  
  # make additional edits based on ESS-DIVE's preferences
  # fix coordinates: round to 5 decimal places to provide accuracy within 1 meter
  mutate(Latitude = round(Latitude, 5),
         Longitude = round(Longitude, 5)) %>% 
  
  # fix column order
  select(`Sample Name`, IGSN, `Release Date`, Latitude, Longitude, `Primary physiographic feature`, `Name of physiographic feature`, Country, everything())



### Create SAMPLES SESAR template ##############################################

# read in site file(s)
sample_files <- list.files(paste0(temp_dir, "/samples"), pattern = ".xlsx$", full.names = T) # gets all xlsx files from the temp dir
basename(sample_files)

# initialize empty df
samples_template <- tibble()

# loop through each file and add it to source_sample
for (i in 1:length(sample_files)) {
  
  log_info(paste0("Reading in ", i, " of ", length(sample_files), ": ", basename(sample_files[i])))
  
  current_file <- read_excel(sample_files[i])
  
  samples_template <- samples_template %>% 
    rbind(., current_file)
}

# rename columns
samples_template <- rename_column_headers(samples_template, output_sample_columns)

# remove cols where all values are NA
output_samples_template <- samples_template %>% 
  select_if(~ !all(is.na(.))) %>% # only selects columns that have content in them

  # make additional edits based on ESS-DIVE's preferences
  # fix date: convert date time to date
  mutate(`Collection date` = as.Date(`Collection date`)) %>% 
  
  # fix coordinates: round to 5 decimal places to provide accuracy within 1 meter
  mutate(Latitude = round(Latitude, 5),
         Longitude = round(Longitude, 5)) %>% 
  
  # edit Parent IGSN col by removing the full DOI link
  mutate(`Parent IGSN` = str_remove_all(`Parent IGSN`, "https://doi.org/")) %>% 
  
  # select and reorder columns (reorder based on this list: https://github.com/ess-dive-community/essdive-sample-id-metadata/blob/main/guide.md)
  select(`Sample Name`, IGSN, `Parent IGSN`,
         Material, `Sample Type`, 
         `Collector/Chief Scientist`, `Collection date`, `Collection method`, `Collection method description`, `Field program/cruise`,
         Latitude, Longitude, `Primary physiographic feature`, Country,
         `Release Date`, `Current Registrant Name`, `Original Registrant Name`, URL)


### Create readme for ESS_DIVE_Infrastructure_ONLY folder ######################

readme <- c(
  paste0(format(Sys.Date(), "%d %B %Y")),
  
  "River Corridor Science Focus Area",
  "Pacific Northwest National Lab",
  "",
  "The files in this folder are for the purpose of ESS-DIVE infrastructure ONLY and can be ignored by data users. These files and associated column headers are not described anywhere in the data package. For a description of these files, go to https://ess-dive.gitbook.io/sample-id-and-metadata/.",
  "",
  'If you have looked at the data in this folder and are interested in the contents, you can find the same information within the main data package folder in a machine-readable file ending in "IGSN-Mapping.csv."'
)

readme


### Write out files ############################################################

# write out readme
write_lines(readme, paste0(ess_dive_infrastructure_only_dir, "/readme_ESS-DIVE_Insfrastructure_ONLY.md"))

# write out sites
write_csv(output_site_header, paste0(ess_dive_infrastructure_only_dir, "/igsn_metadata_sites_for_samples.csv"))

write_csv(output_sites_template, paste0(ess_dive_infrastructure_only_dir, "/igsn_metadata_sites_for_samples.csv"), append = TRUE, col_names = TRUE, na = "")

# write out samples
write_csv(output_sample_header, paste0(ess_dive_infrastructure_only_dir, "/igsn_metadata_samples.csv"))

write_csv(output_samples_template, paste0(ess_dive_infrastructure_only_dir, "/igsn_metadata_samples.csv"), append = TRUE, col_names = TRUE, na = "")

