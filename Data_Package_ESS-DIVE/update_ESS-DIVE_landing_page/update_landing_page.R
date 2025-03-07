### update_landing_page.R ###############################################

# A selection of functions used to update ESS-DIVE landing pages


### Prep Script ################################################################

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
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/create-update-landing-page-authors/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_coordinates.R")


### Updating Authors ###########################################################

# USER INPUTS
your_essdive_metadata_file <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_ESSDIVE_Metadata.docx" # absolute file path of ESS-DIVE metadata .docx
your_api_token = "" # recommend adding this in the console
your_essdive_id = "ess-dive-5408b37073797ff-20250307T030039977" # id that begins with "ess-dive-" found on the landing page you want to update
your_upload_site = "sandbox" # options: c("sandbox", "main")


# RUN functions (no modifications needed)
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



### Updating Coordinates #######################################################

# USER INPUTS

# RUN function (no modifications needed)
