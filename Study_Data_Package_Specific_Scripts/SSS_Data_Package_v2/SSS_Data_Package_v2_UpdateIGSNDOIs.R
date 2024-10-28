### SSS_Data_Package_v2_UpdateIGSNDOIs.R ##############################

## File Metadata
# Author: Bibi Powers-McCormack
# Contact Info: bibi.powers-mccormack@pnnl.gov
# Date Created: 2023-08-07 by Bibi Powers-McCormack
# Date Updated: 2023-08-07 by Bibi Powers-McCormack

# Objective: Append the DOI prefix to the sample names in the IGSN Mapping file


# Inputs: v2_SSS_Metadata_IGSN-Mapping.csv
# Outputs: v2_SSS_Metadata_IGSN-Mapping.csv


### FILE SET UP ##############################

# Load libraries
library(tidyverse)

# set working directory
getwd()

# Load functions


# Load data

# load in the IGSN data, skipping the comment in the first row
sss_igsn_df_01 <- read_csv("./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv", skip = 1)


### PREFIX DOI ##############################
sss_igsn_df_02 <- sss_igsn_df_01 %>% 
  mutate(IGSN = paste0("10.58052/", IGSN),
         Parent_IGSN = paste0("10.58052/", Parent_IGSN)) %>% 


### ADD SPACE IN FRONT OF DATE COLUMNS ##############################
  mutate(Collection_Date = paste0(" ", Collection_Date))


### EXPORT IGSN MAPPING FILE ##############################

# read in SSS IGSN headers; doing this because these headers were skipped when initially reading in the file and we need to add this info back on when the file is exported
sss_igsn_headers_df_01 <- read_csv("./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv", col_names = FALSE) %>%
  head(1)

# write out IGSN header file to same as input file path with version appended to it
write_csv(sss_igsn_headers_df_01, "./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv", col_names = FALSE, na = "")


# write out IGSN data to append to header
write_csv(sss_igsn_df_02, paste0("./v2_SSS_Data_Package/v2_SSS_Metadata_IGSN-Mapping.csv"), col_names = TRUE, append = TRUE)
