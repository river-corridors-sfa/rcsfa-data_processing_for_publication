### Regier_2024_WRB_YRB_Scaling_DP_Prep.R ######################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-06
# Date Updated: 2025-03-06

# Objective: Prepare Peter's Scaling manuscript data package

# Assumptions: 
  # Each code chunk was run independently from the rest. 


### Confirm author list ########################################################
# this chunk checks to see if the authors listed in the ess-dive metadata are in our master author list

# Inputs: 
  # author spreadsheet
  # copy and pasted author names from ess-dive metadata file

# Outputs
  # df with all authors and information copied to clipboard


# load libraries
library(tidyverse)
library(readxl)
library(janitor)

# import author names - copied from ess-dive metadata doc
manuscript_authors <- tribble(~full_name,
                              "Peter Regier",
                              "Kyongho Son",
                              "Xingyuan Chen",
                              "Yilin Fang",
                              "Peishi Jiang",
                              "Micah Taylor",
                              "Wil Wollheim",
                              "Beck Powers-McCormack",
                              "Brieanne Forbes",
                              "Amy E. Goldman",
                              "James C. Stegen") %>%
  separate(col = full_name, into = c("first_name", "middle_name", "last_name"), sep = " ", fill = "right") %>% 
  mutate(last_name = case_when(is.na(last_name) ~ middle_name, T ~ last_name),
         middle_name = case_when(last_name == middle_name ~ NA_character_, T ~ middle_name))

# import author spreadsheet
author_spreadsheet <- read_excel("Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx", trim_ws = T) %>% 
  clean_names()

# merge authors
manuscript_author_info <- manuscript_authors %>% 
  left_join(author_spreadsheet, by = c("first_name", "middle_name", "last_name")) %>% 
  rename(email = e_mail,
         affiliation = institution) %>% 
  unite("first_name", first_name, middle_name, sep = " ", na.rm = T) %>% 
  select(first_name, last_name, email, orcid, affiliation)

manuscript_author_info


### Add authors to landing page ################################################

# first run the "Confirm author list" chunk

# load libraries
library(tidyverse)
library(rlog)
library(glue)
library(devtools) # for sourcing in script
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_authors.R")

### Fill out arguments 
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "" # i added this in the console

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-1ce1ff991d54325-20250306T184121991"

# this is the author data frame you already made
your_author_df <- manuscript_author_info

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "main" 


### Run function 

update_landing_page_authors(api_token = your_api_token,
                            essdive_id = your_essdive_id,
                            author_df = your_author_df,
                            upload_site = your_upload_site)
