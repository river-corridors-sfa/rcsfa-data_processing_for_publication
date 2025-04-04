### igsn_for_landing_page.R ####################################################
# Date Created: 2023-10-19
# Date Updated: 2023-10-24
# Author: Bibi Powers-McCormack
# Objective: Pull IGSNs for Methods section of ESS-DIVE metadata landing page

### Prep script ################################################################
# load libraries
library(tidyverse)
library(clipr)

# load IGSN mapping file
igsn_mapping_filepath <- file.choose()
igsn_mapping <- read_csv(igsn_mapping_filepath, comment = "#")


### Pull site IGSNs ############################################################

# extract site strings from mapping file
igsn_site <- igsn_mapping %>% 
  select(Locality, Parent_IGSN) %>% 
  distinct() %>%  # pulls unique list of sites
  arrange(Locality) %>% # sort alphabetically
  mutate(`IGSN PID` = paste0("IGSN:", Parent_IGSN),
         `IGSN URL` = paste0("https://doi.org/", Parent_IGSN),
          text = paste(Locality, `IGSN PID`, `IGSN URL`, sep = " ")) %>% # create text string
  select(text)

# create header text information
igsn_site_header_text <- data.frame(text = 
  "This section provides a list of all parent site locations, from which the physical samples were collected. More information is provided in the location landing pages (links below) and the dataset file that ends in 'IGSN-Mapping.csv'.") %>% 
  rbind("Sample Name IGSN PID IGSN URL")

# combine text
igsn_site_full_text <- igsn_site_header_text %>% 
  rbind(igsn_site) %>% 
  rename(` ` = text)

# copy to clipboard
write_clip(igsn_site_full_text)

# confirm content copied
read_clip()


### Pull sample IGSNs ##########################################################

# extract sample strings from mapping file
igsn_sample <- igsn_mapping %>% 
  mutate(`IGSN PID` = paste0("IGSN:", IGSN),
         `IGSN URL` = paste0("https://doi.org/", IGSN),
         text = paste(Sample_Name, `IGSN PID`, `IGSN URL`, sep = " ")) %>% # create text string
  select(text)

# create header text information
igsn_sample_header_text <- data.frame(text = 
  "This section provides a list of source material physical samples used in this dataset. More information describing the samples is provided in the sample landing pages (links below) and the dataset file that ends in 'IGSN-Mapping.csv'.") %>% 
  rbind("Sample Name IGSN PID IGSN URL")

# combine text
igsn_sample_full_text <- igsn_sample_header_text %>% 
  rbind(igsn_sample) %>% 
  rename(` ` = text)

# copy to clipboard
write_clip(igsn_sample_full_text)

# confirm content copied
read_clip()




