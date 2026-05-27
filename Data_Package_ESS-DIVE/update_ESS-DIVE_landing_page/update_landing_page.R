### update_landing_page.R ###############################################

# A selection of functions used to update ESS-DIVE landing pages


### Prep Script ################################################################
rm(list=ls(all=T))

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
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/functions/update_landing_page_authors.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/functions/update_landing_page_coordinates.R")


### Updating Authors ###########################################################
# For detailed information on the function that uses the API to update the
# landing page, refer to the `README_update_ESS-DIVE_landing_page_authors.md`
# file. This script also includes two internal "helper" functions developed for
# the RC-SFA DM Team. These functions extract author lists from the ESS-DIVE
# metadata and merge them with the data stored in the author spreadsheet.


# USER INPUTS

your_essdive_metadata_file <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/TAP_ESSDIVE_Metadata_Template.docx"# absolute file path of ESS-DIVE metadata .docx
your_author_spreadsheet <- "Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx"
your_api_token = "" # this is your personal token that you can get after signing into ess-dive; recommend adding this in the console
your_essdive_id = "ess-dive-ab321e2a84266f5-20260526T171609176" # id that begins with "ess-dive-" found on the landing page you want to update
your_upload_site = "main" # options: c("sandbox", "main")

# RUN functions (no modifications needed)
# get authors from ESS-DIVE metadata file
author_names <- get_authors_from_essdive_metadata(essdive_metadata_file = your_essdive_metadata_file)


# get author info from spreadsheet
author_info <- get_author_spreadsheet_info(author_df = author_names, 
                                           author_info_file = your_author_spreadsheet)

additional_authors <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/TAP Authors.csv") %>%
  mutate('First Name' = case_when(!is.na(`Middle Initial`) ~ str_c(`First Name`,' ', `Middle Initial`),
                                  TRUE ~ `First Name`)) %>%
  rename(first_name = 'First Name',
         last_name = 'Last Name',
         orcid =  "ORCID" ,
         email =  "E-mail" ,
         affiliation = "Institution") %>%
  select(-`Middle Initial`)

author_info <- author_info %>%
  bind_rows(additional_authors) %>%
  arrange(last_name) %>%
  mutate(
    sort_order = case_when(
      last_name == "Goldman" ~ 1,
      last_name == "Stegen" ~ 999,
      TRUE ~ row_number() + 1
    )
  ) %>%
  arrange(sort_order) %>%
  select(-sort_order)


# update landing page - warning this will overwrite all existing authors with the new ones you provide
update_landing_page_authors(api_token = your_api_token,
                            author_df = author_info,
                            essdive_id = your_essdive_id,
                            upload_site = your_upload_site)



### Updating Coordinates #######################################################
# For detailed information on the function that uses the API to update the
# landing page, refer to the `README_update_ESS-DIVE_landing_page_coordinates.md`
# file. 


# USER INPUTS
your_coordinates_file_path <- "Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/WHONDRS_TAP_geospatial.csv" # this is the .csv absolute file path of the coordinates (required cols: Description, Latitude, Longitude)
your_api_token = "" # this is your personal token that you can get after signing into ess-dive; recommend adding this in the console
your_essdive_id = "ess-dive-1b1d2a84b50278d-20260526T173935678417" # id that begins with "ess-dive-" found on the landing page you want to update
your_upload_site = "main" # options: c("sandbox", "main")


# RUN function (no modifications needed)
# update landing page - warning this will overwrite all existing coordinates with the new ones you provide
update_landing_page_coordinates(api_token = your_api_token,
                                essdive_id = your_essdive_id,
                                coordinates_file_path = your_coordinates_file_path,
                                upload_site = your_upload_site)
