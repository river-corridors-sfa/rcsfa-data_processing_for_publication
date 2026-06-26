### download_ESS-DIVE_landing_page_data_API_function.R #########################

# Download csv files from a public ESS-DIVE landing page using the ESS-DIVE API

# Function, example, and readme were created using Chat GPT-5.5 in Codex

### Prep Script ################################################################
rm(list = ls(all = TRUE))

# load libraries
require(pacman)
p_load(tidyverse, httr2, devtools) 

# load function
source_url('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_ESS-DIVE/download_from_ESS-DIVE_landing_page/ESS-DIVE_Download_R_API/ESS-DIVE_download_API_function.R')


### Download Data ##############################################################
# For detailed information on the function that uses the API to download csv
# files from an ESS-DIVE landing page, refer to the`README.md` file.


# USER INPUTS

your_package_link <- "https://data.ess-dive.lbl.gov/view/doi%3A10.15485%2F3374642" # ESS-DIVE landing page link for a public data package


# RUN function (no modifications needed)

data_package_csvs <- download_essdive_csvs(package_link = your_package_link)


# View csv files loaded into the list
names(data_package_csvs)


# Example: access individual csv files from the returned list
field_metadata <- data_package_csvs$WHONDRS_TAP_Field_Metadata
npoc_tn <- data_package_csvs$WHONDRS_TAP_Water_NPOC_TN

