### update_landing_page_charcuterie.R ###############################################

# A selection of functions used to update ESS-DIVE landing pages


### Prep Script ################################################################

# load libraries

# load functions



### Updating Authors ###########################################################

# USER INPUTS
your_essdive_metadata_file <- ""
your_api_token = ""
your_essdive_id = ""
upload_site = "sandbox"


# RUN functions (no modifications needed)
# get authors from ESS-DIVE spreadsheet
author_names <- get_authors_from_essdive_metadata(essdive_metadata_file = your_essdive_metadata_file)


# get author info from spreadsheet
author_info <- get_author_spreadsheet_info(author_df = author_names, 
                                           author_info_file = "Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx")


# update landing page
update_landing_page_authors(api_token = your_api_token,
                            author_df = author_info,
                            essdive_id = your_essdive_id,
                            upload_site = your_upload_site)


### Updating Coordinates #######################################################

# USER INPUTS

# RUN function (no modifications needed)
