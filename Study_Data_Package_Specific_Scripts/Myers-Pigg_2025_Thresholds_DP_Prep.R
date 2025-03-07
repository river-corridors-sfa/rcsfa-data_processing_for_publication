### Myers-Pigg_2025_Thresholds_DP_Prep.R #######################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-07
# Date Updated: 2025-03-07

# Objective: Prepare the Thresholds manuscript data package

# Assumptions: 
# Each code chunk was run independently from the rest. 

# (un-finalized) Citation: Wampler K A ; Kang H ; Bladon K D ; Myers-Pigg A ; Regier P ;
# Scheibe T D (2025): Data and scripts associated with “Thresholds of Area
# Burned and Burn Severity for Downstream Riverine Systems to ‘Feel the Burn’”.
# River Corridor and Watershed Biogeochemistry SFA, ESS-DIVE repository.
# Dataset. ess-dive-f403f5ad350f22c-20250307T184624508105 accessed via
# https://data.ess-dive.lbl.gov/datasets/ess-dive-f403f5ad350f22c-20250307T184624508105
# on 2025-03-07

### Add authors to landing page ################################################
# this chunk pulls author info from ess-dive metadata .docx and author spreadsheet and then updates the landing page

# load libraries
library(tidyverse)
library(rlog)
library(officer) # for reading in docx files
library(readxl) # for reading in excel files
library(janitor) # for cleaning up col headers
library(glue)
library(devtools) # for sourcing in script
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/create-update-landing-page-authors/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_authors.R")

# USER INPUTS
your_essdive_metadata_file <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/thresholds_ESSDIVE_Metadata.docx" # absolute file path of ESS-DIVE metadata .docx
your_api_token = "" # recommend adding this in the console
your_essdive_id = "ess-dive-19356ecaa806fac-20250307T184038618139" # id that begins with "ess-dive-" found on the landing page you want to update
your_upload_site = "main" # options: c("sandbox", "main")


# get authors from ESS-DIVE metadata file
author_names <- get_authors_from_essdive_metadata(essdive_metadata_file = your_essdive_metadata_file)


# get author info from spreadsheet
author_info <- get_author_spreadsheet_info(author_df = author_names, 
                                           author_info_file = "Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx")


# update landing page - warning this will overwrite all existing authors with the new ones you provide
update_landing_page_authors(api_token = your_api_token,
                            author_df = author_info,
                            essdive_id = your_essdive_id,
                            upload_site = your_upload_site)


### Create coordinate spreadsheet ##############################################
# this chunk creates a csv with 3 columns (Description, Latitude, Longitude) that will used to update the landing page

# load libraries
library(tidyverse)

# copy and paste info manually from the ess-dive metadata .docx file
coords <- tribble(~Description, ~Latitude, ~Longitude,
                  "USGS gauge data (12488500) used for parameterizing the humid, forested test basin", 46.97761606, -121.168696,
                  "USGS gauge data (11204100) used for parameterizing the semi-arid, mixed land use test basin", 36.02411648, -118.8134258,
                  "Elevation, soil, land cover, and climate data used for parameterizing the humid, forested test basin", 46.9935, -121.5225, # note this is a bounding box: 46.9935, 46.81174, -121.5225, -121.1685
                  "Elevation, soil, land cover, and climate data used for parameterizing the semi-arid, mixed land use test basin", 35.95394, -118.814, # note this is a bounding box: 35.95394, 36.11071, -118.814, -118.5751
                  "Water quality data used for parameterizing the humid, forested test basin", 46.01679, -121.7604, # note this is a bounding box: 46.01679, 47.35512, -121.7604, -121.0040
                  "Water quality data used for parameterizing the semi-arid, mixed land use test basin", 35.90773, -119.3979 # note this is a bounding box: 35.90773, 36.74077, -119.3979, -118.2726
                  )

write_csv(coords, "Z:/00_ESSDIVE/03_Manuscript_DPs/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/thresholds_geospatial_coords.csv")


### Update landing page with coordinates #######################################

# load libraries
library(devtools)
library(tidyverse)
library(rlog)
library(glue)
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# set wd to the rc-sfa data processing repo
setwd("C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-data_proceesing_for_publication")

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_coordinates.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")

#### Fill out arguments ----
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "abcdefjhijklmnopqrstuvwxyz - added in the console"

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-f403f5ad350f22c-20250307T184624508105"

# this is the .csv absolute file path of the coordinates
your_coordinates_file_path <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Myers-Pigg_2025_Thresholds_Manuscript_Data_Package/thresholds_geospatial_coords.csv"

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "main" 


#### Run function ----

update_landing_page_coordinates(api_token = your_api_token,
                                essdive_id = your_essdive_id,
                                coordinates_file_path = your_coordinates_file_path,
                                upload_site = your_upload_site)
