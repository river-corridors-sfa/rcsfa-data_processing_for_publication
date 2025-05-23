### recreate_SESAR_template.R ##################################################
# Date Created: 2024-11-07
# Date Updated: 2025-01-07
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
  # The input file IGSNs should not have the full DOI URL. It is okay if they look like "10.58052/IEPRS007S" or "IEPRS007S".
  # If there are more than 100 samples or sites, you will have to repeat the downloading process (but this script will walk you through that).
  # Uses the user code 'IEWDR' for WHONDRS  and 'IEPRS' for everything else.
  # This script has functions that work only on Windows machines. 

# Directions: 
  # Go through this script line by line for directions on how to navigate
  # downloading info from the SESAR database and creating the pseudo template.

# Status: 
  # complete. 
  # script has not yet been tested when there are more than 100 sites or samples


### Prep Script ################################################################

# load libraries
library(tidyverse)
library(devtools)
library(rlog)
library(clipr)
library(readxl)
library(testthat)

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")

# user inputs - update these each time you run the script
data_package_igsns <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SampleData_v3/v3_SFA_SpatialStudy_2021_SampleData/SPS_Sample_IGSN-Mapping.csv", skip = 1) # read in the file from your data package that has IGSN and Parent_IGSN cols
ess_dive_infrastructure_only_dir <- "Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/SFA_SpatialStudy_2021_SampleData_v3/ESS_DIVE_Infrastructure_ONLY"
is_whondrs <- F # indicate T/F if this data package is WHONDRS

# create and open your temp directory - this folder and files in it will automatically delete when your R session ends
temp_dir <- tempdir()
shell.exec(temp_dir) # this only works on windows; use system(paste0("open '", temp_dir, "'")) for macs - you will have to change this in several places within this script

# function to download from SESAR
download_from_SESAR <- function(dir, type = c("sites", "samples"), max) {
  
  # go to website
  browseURL("https://www.geosamples.org/search-options/catalog-search")
  
  cat("Your IGSNs have been copied to your clipboard.")
  cat("\n")
  cat("In the 'search by multiple IGSNs' box, paste in your site IGSNs. ")
  cat("\n")
  cat("Scroll down and click the blue 'search' button.")
  
  readline(prompt = "Ready for the next step? After you clicked 'search', enter 'Y' into the console: ")
  
  # copies temp directory to your clipboard
  write_clip(paste0(temp_dir, "/", type))
  
  cat('Click the grey "Download" button.')
  cat("\n")
  cat("When the dialog box to save the file comes up, paste the temp_dir URL (it's been saved to your clipboard) into the folder path. No need to rename the file, click save.")
  cat("\n")
  
  # check the number of files in the sites dir
  while(list.files(paste0(temp_dir, "/", type)) %>% length() != i) {
    
    cat(paste0("If you did not get this dialog box, your file was likely saved to your default download directory. If this happens, manually move the file from your Downloads to the temp directory - '", temp_dir, "'. Save it to the '", type, "' sub directory."))
    cat("\n")
    shell.exec(file.path(paste0(Sys.getenv("USERPROFILE"), "/Downloads")))
    readline(prompt = "Enter 'Y' to continue. ")
    
  }
  
  cat("There are", i, "files saved to your", type, "temp dir:", list.files(paste0(temp_dir, "/", type)))
  cat("\n")
  
  
  if (i == max) {
    
    cat("You have finished downloading. Return to R and run the next line. ")
    
  } else {
    
    readline(prompt = "Ready for the next step? You have more to download. This loop will start over and copy the next 100 to your clipboard. 
             Enter 'Y' into the console when ready to continue: ")
    
  }
  
}


### Download from SESAR ########################################################
# first pull the IGSNs from the data package
# manipulate them into a version that can be copied into the search query in SESAR
# search for files
# download them to a temporary directory

# get sample IGSN col
sample_igsns <- data_package_igsns %>% 
  mutate(IGSN = str_replace_all(IGSN,  "\\s+", "")) %>% 
  select(IGSN) %>% 
  distinct() %>% 
  mutate(step = (row_number() - 1) %/% 100 + 1) # this assigns a value for every 100

log_info(paste0("There are ", count(sample_igsns), " samples."))

# create temp site dir
dir.create(paste0(temp_dir, "/samples"))

# if there are more than 100 samples, then need to break it up for downloading from SESAR
# this loop grabs 100 samples at a time and walks you through how to download them from SESAR
for (i in 1:max(sample_igsns$step)){
  
  current_step <- sample_igsns %>% 
    filter(step == i) %>% 
    select(-step) %>% 
    {print(paste0("There are ", nrow(.), " samples.")); .} %>% 
    pull(.) %>% 
    str_c(collapse = ", ")
  
  current_max = max(sample_igsns$step)
  
  # copy IGSNs to clipboard
  write_clip(current_step)
  
  # download samples
  download_from_SESAR(dir = temp_dir, type = "samples", max = current_max)
}


### Identify format of desired output ##########################################

# set user code
if (is_whondrs == TRUE) {
  user_code_value <- "IEWDR"
} else {
  user_code_value <- "IEPRS"
}

# list out the headers of the final file. 

output_sample_header <- tibble('Object Type:'= as.character(),
                            'Individual Sample'= as.character(),
                            'User Code:'= as.character(), 
                            !!sym(user_code_value) := as.character()) # !! unquotes the user code value, sym() converts it to a symbol to remove the quotes, and := allows for dynamic column naming

# list out required columns. I got these column headers from https://github.com/ess-dive-community/essdive-sample-id-metadata/blob/main/guide.md
output_sample_columns <- c("Sample Name",  
                           "Material", 
                           "Collector/Chief Scientist", "Collection date", "Collection method", "Field program/cruise",
                           "Latitude", "Longitude", 
                           "Country", # this was added per suggestion from ess-dive
                           "Primary physiographic feature",
                           "Release Date")


### Create SAMPLES SESAR template ##############################################

# read in site file(s)
sample_files <- list.files(paste0(temp_dir, "/samples"), pattern = ".xlsx$", full.names = T) # gets all xlsx files from the temp dir
basename(sample_files)

samples_template <- sample_files %>% 
  map(~ read_excel(.x)) %>% 
  bind_rows()

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
  
  # fix col names: if Related URL 1 and Related URL Type 1 exist, rename those col names dropping the 1
  rename_with(~ c("Related URL", "Related URL Type"), any_of(c("Related URL 1", "Related URL Type 1"))) %>% 
  
  # select and reorder columns (reorder based on this list: https://github.com/ess-dive-community/essdive-sample-id-metadata/blob/main/guide.md)
  select(any_of(c("Sample Name", "IGSN", "Parent IGSN",
         "Material", "Field name (informal classification)", "Sample Type", 
         "Collector/Chief Scientist", "Collection date", "Collection method", "Collection method description", "Field program/cruise",
         "Latitude", "Longitude", "Primary physiographic feature", "Locality", "Country",
         "Release Date", "Current Registrant Name", "Original Registrant Name", "URL", "Related URL", "Related URL Type")), everything())


### Check for ESS-DIVE required columns ########################################
# checks that the required columns (according to https://ess-dive.gitbook.io/sample-id-and-metadata/guide) are present


test_that("Header rows are correct", {

  # check samples
  # first 3 cols are Object Type:, Individual Sample, User Code:
  # 4th col is either IEWDR or IEPRS
  expect_equal(colnames(output_sample_header)[1:3], c("Object Type:", "Individual Sample", "User Code:"))
  expect_true(colnames(output_sample_header[4]) %in% c("IEWDR", "IEPRS")) # 'IEWDR' is for WHONDRS  'IEPRS' is not for WHONDRS

})


test_that("Required SAMPLES columns are present", {


  expect_true(all(output_sample_columns %in% colnames(output_samples_template)))

  cat("Required cols NOT in your template: ")
  cat("\n")
  print(setdiff(output_sample_columns, colnames(output_samples_template)))
  cat("\n")
  cat("Non-required cols in your template: ")
  cat("\n")
  print(setdiff(colnames(output_samples_template), output_sample_columns))
  cat("\n")
  cat("\n")

})



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
write_lines(readme, paste0(ess_dive_infrastructure_only_dir, "/readme_ESS-DIVE_Insfrastructure_ONLY.txt"))

# write out samples
write_csv(output_sample_header, paste0(ess_dive_infrastructure_only_dir, "/igsn_metadata_samples.csv"))

write_csv(output_samples_template, paste0(ess_dive_infrastructure_only_dir, "/igsn_metadata_samples.csv"), append = TRUE, col_names = TRUE, na = "")

shell.exec(ess_dive_infrastructure_only_dir)
