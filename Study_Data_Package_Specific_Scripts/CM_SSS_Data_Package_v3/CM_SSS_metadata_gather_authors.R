# Gather CM SSS authors
# 2023-10-16
# Bibi Powers-McCormack

# Objective: Create a complete list of all the WHONDRS consortium authors that contributed to the CM SSS data collection. 
  # Inputs: authors came from the v2 author list and authors since 2023-04-24 came from the google drive metadata
  # Outputs: the text string of all authors was copied into the `v3_WHONDRS_Consortium_Authors.txt` and a .csv export `v3_WHONDRS_Consortium_Authors.csv` was also generated

# Notes
  # This script shouldn't need to be run again. It involves exporting out and manually fixing a .csv (line 46) and then reading that .csv back in.
  # Use the .csv output of this script as the starting point/input for future circumstances.


### Prepare Script #############################################################
library(tidyverse)
library(gsheet) # used to load in google sheets
library(clipr) # used to copy final text string to clipboard

# clear global environment 
rm(list = ls())



### Load Data ##################################################################

# >> load in metadata ----
gd_metadata <-gsheet2tbl("https://docs.google.com/spreadsheets/d/14g_vLiGnF9vp9T9jlsbxFKLYB5TX6kF8N73WOvsBkiE/edit#gid=1075453003") %>% 
  .[1:114, ]

# >> load in v2 authors ----
v2_authors_filepath <-  "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v2_authors.csv"
v2_authors_filepath <- file.choose()
v2_authors <- read_csv(v2_authors_filepath) %>% 
  select(-v2_authors_txt)


### Clean author metadata ######################################################

# pull out additional authors to deal with later
authors_additional <- gd_metadata %>% 
  select(Additional_Authors) %>% 
  filter(!is.na(Additional_Authors)) %>% 
  filter(!Additional_Authors %in% c("N/A", "n/a", "No", "not for now.", "no", "No one else was involved")) %>% 
  unique()

# write out additional authors to clean up manually
write_csv(authors_additional, "authors_additional.csv")

# read back in cleaned author list
authors_additional_clean_filepath <- file.choose()
authors_additional_clean_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\authors_additional.csv"
authors_additional_clean <- read_csv(authors_additional_clean_filepath) %>% 
  select(-Additional_Authors)
  


# extract author information from gd_metadata
authors <- gd_metadata %>% 
  select(Sample_Date,
         Contact_First_Name, Contact_Last_Name, Organization,
         CoAuthorship) %>% 
  # filter for those who want authorship
  filter(CoAuthorship == "Yes") %>% 
  select(-CoAuthorship) %>% 
  mutate(Sample_Date = as.Date(Sample_Date, format = "%m/%d/%Y"))




### Create v3 author list ###################################################### 

# extract v3 authors
v3_authors <- authors %>% 
  # pull anything more recent than 2023-04-24
  filter(Sample_Date > as.Date("2023-04-24")) %>% 
  select(-Sample_Date) %>% 
  unique() %>% 
  rename(First = Contact_First_Name,
         Last = Contact_Last_Name)

# create full author list
all_authors_df_01 <- data.frame(
  First = as.character(),
  Last = as.character(),
  Organization = as.character()
) %>% 
  add_row(v2_authors) %>% 
  add_row(v3_authors) %>% 
  add_row(authors_additional_clean) %>% 
  unique() %>% 
  arrange(Last) %>% 
  mutate(author_id = row_number())

# check for duplicates
all_authors_df_01 %>% 
  filter(duplicated(paste(First, Last)) | duplicated(paste(First, Last), fromLast = TRUE)) %>% 
  print()
  
  

# remove duplicates
author_duplicates_to_remove <- c("17", "30", "36", "38", "46", "52", "68", "72", "75", "83", "102", "106", "109", "110", "123", "139", "141", "154")

all_authors_df_02 <- all_authors_df_01 %>% 
  # remove duplicates
  filter(!author_id %in% author_duplicates_to_remove)


# format each author row
all_authors_df_03 <- all_authors_df_02 %>% 
  select(-author_id) %>% # remove extra cols
  arrange(Last) %>% # sort alpha by last name
  mutate_at(vars(First, Last, Organization), ~str_trim(.)) %>% # clean trailing white space
  mutate(author_text_string = case_when(is.na(Organization) ~ paste0(First, " ", Last), 
                                        TRUE ~ paste0(First, " ", Last, " (", Organization, ")"))) # add text string col
  
  
# format as single text string
author_text_string <- paste(all_authors_df_03$author_text_string, collapse = "; ") %>% 
  print()


### Export #####################################################################

# copy text string to clipboard to manually paste into `WHONDRS_Consortium_Authors.txt`
write_clip(author_text_string)

read_clip()

# write out author df
write_csv(all_authors_df_03, "v3_WHONDRS_Consortium_Authors.csv", na = "")
