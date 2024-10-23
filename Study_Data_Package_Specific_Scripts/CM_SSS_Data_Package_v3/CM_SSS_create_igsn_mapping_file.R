### CM_SSS_create_igsn_mapping_file.R #################################################
# Date Created: 2023-11-17
# Author: Bibi Powers-McCormack
# Objective: Create the v3_CM_SSS_Metadata_IGSN-Mapping.csv mapping file. 
  # This file is usually generated from Brie's format_igsn.R script, but since the online database is more up to date than the files we currently have, there is a need for a specific script


### Prep #######################################################################

# load libraries
library(tidyverse)
library(lubridate)

# load data

# read in v3 field metadata
v3_field_metadata_filepath <- file.choose()
v3_field_metadata_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v3_CM_SSS_Data_Package\\v3_CM_SSS_Field_Metadata.csv"
v3_field_metadata <- read_csv(v3_field_metadata_filepath)

# read in igsn site identifiers
igsn_sites_filepath <- file.choose()
igsn_sites_filepath <- "C:\\Users\\powe419\\OneDrive - PNNL\\Desktop\\BP PNNL\\PROJECTS\\Assist Brie with ECA and SSF and CM\\CM_IGSNs\\Data\\L2\\igsn_sites.csv"
igsn_sites <- read_csv(igsn_sites_filepath)

# read in old mapping file (this is used to extract the "Other_Names" column because for some reason that column wasn't included when I downloaded from IGSN)
old_mapping_filepath <- file.choose()
old_mapping_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v3_CM_SSS_Data_Package\\v3_CM_SSS_Metadata_IGSN-Mapping.csv"

old_mapping <- read_csv(old_mapping_filepath, skip = 1) %>% 
  select(Sample_Name, Other_Names)

old_mapping_header <- read_csv(old_mapping_filepath, n_max = 1, col_names = F) %>% 
  select(1)

# create a vector of excel files to read
excel_files <-  list.files(path = "./Data/L0/", pattern=".xlsx", recursive = T, full.names = T)

# convert excel files to csv
if (length(excel_files) != 0) {
  # read each file and write it to csv
  lapply(excel_files, function(f) {
    df = read_excel(f, sheet=1)
    write_csv(df, gsub("xlsx", "csv", f), na = "")
  })
  
  delete_okay <- readline(prompt = "Confirm the excel files converted. Ready to delete (if yes, enter Y)?")
  
  # delete excel files
  if (delete_okay == "Y") {
    lapply(excel_files, file.remove)
  }
}


# read in igsn samples

# get list of files
list_of_files <- list.files(path = "./Data/L0/", recursive = T, full.names = T)

# read in each file as a df
for (i in list_of_files) {
  
  # get df name
  current_filename <- basename(i) %>% 
    str_remove("20231117_") %>% 
    str_remove(".csv")
  
  # read in file and rename file with current df name
  assign(current_filename, read_csv(i))
}

# combine samples
igsn_samples <- IGSN_samples_CM %>% 
  rbind(IGSN_samples_SSS)

# clean up global environment
rm(IGSN_samples_CM)
rm(IGSN_samples_SSS)


### Clean up individual files ##################################################
igsn_samples_df_01 <- igsn_samples %>% 
  select(`Sample Name`, IGSN, Material, `Field Name`, `collection Method`, `Collection Method Descr`, Comment, `Latitude Start`, `Longitude Start`, `Physiographic Feature`, `Name of Physiographic Feature`, Locality,
         `Locality Description`, Country, City, `Field Program/Cruise`, `Collector/Chief Scientist`, `collection Start Date`)

igsn_sites_df_01 <- v3_field_metadata %>% 
  select(Parent_ID, Site_ID, State) %>% 
  left_join(igsn_sites, by = c("Site_ID" = "Sample Name")) %>% 
  rename(Locality = "Site_ID", 
         `Parent IGSN` = IGSN)


### Join all dfs together ######################################################

mapping_file_df_01 <-  igsn_samples_df_01 %>% 
  left_join(igsn_sites_df_01, by = c("Locality" = "Locality"), relationship = "many-to-many")
  


### Tidy mapping file ##########################################################

# rename columns
mapping_file_df_02 <- mapping_file_df_01 %>% 
  rename("Sample_Name" = "Sample Name",
         "Parent_IGSN" = "Parent IGSN",
         "Field_Name_Informal_Classification" = "Field Name",
         "Collection_Method" = "collection Method",
         "Collection_Method_Description" = "Collection Method Descr",
         "Latitude" = "Latitude Start",
         "Longitude" = "Longitude Start",
         "Primary_Physiographic_Feature" = "Physiographic Feature",
         "Physiographic_Feature_Name" = "Name of Physiographic Feature",
         "Locality_Description" = "Locality Description",
         "City_or_Township" = "City",
         "Field_Program_Cruise" = "Field Program/Cruise",
         "Collector_Chief_Scientist" = "Collector/Chief Scientist",
         "Collection_Date" = "collection Start Date",
         "State_or_Province" = "State") %>% 
  # add missing columns
  mutate(Related_URL = "https://whondrs.pnnl.gov",
         Related_URL_Type = "regular URL") %>% 
  # join on Other_Names from previous mapping version
  left_join(old_mapping, by = c("Sample_Name" = "Sample_Name")) %>% 
  # reorder
  select(Sample_Name, 
         IGSN, 
         Parent_IGSN, 
         Material, 
         Field_Name_Informal_Classification, 
         Collection_Method, 
         Collection_Method_Description, 
         Comment, 
         Latitude, 
         Longitude, 
         Primary_Physiographic_Feature, 
         Physiographic_Feature_Name, 
         Locality, 
         Other_Names, 
         Locality_Description, 
         Country, 
         State_or_Province, 
         City_or_Township, 
         Field_Program_Cruise, 
         Collector_Chief_Scientist, 
         Collection_Date, 
         Related_URL, 
         Related_URL_Type) %>%   
  # fix date column
  mutate(Collection_Date = paste0(' ', as_date(Collection_Date))) %>% 
  # add N/A to NA columns
  mutate(City_or_Township = case_when(is.na(City_or_Township) ~ "N/A", TRUE ~ City_or_Township)) %>% 
  
  # sort by Parent ID
  separate(Sample_Name, into = c("Parent_ID", "Sample_Material"), sep = "_(?=[^_]*$)", remove = FALSE) %>%  # split sample name into parent id + material columns
  arrange(desc(Sample_Material)) %>% 
  
  # remove rows that shouldn't be there; there should be 471 rows
  filter(Sample_Material != "COT") %>% 
  distinct() %>% 
  
  select(-Parent_ID, -Sample_Material)


### Export #####################################################################

write_csv(old_mapping_header, "./Data/20231117_v3_CM_SSS_Metadata_IGSN-Mapping.csv", col_names = F)
write_csv(mapping_file_df_02, "./Data/20231117_v3_CM_SSS_Metadata_IGSN-Mapping.csv", col_names = T, append = T)














