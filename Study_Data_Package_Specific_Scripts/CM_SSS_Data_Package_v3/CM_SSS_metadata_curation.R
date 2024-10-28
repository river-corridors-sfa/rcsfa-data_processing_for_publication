### CM_SSS_metadata_curation.R #################################################
# Date Created: 2023-10-12
# Author: Bibi Powers-McCormack
# Objective: Pull newly sampled metadata from google drive and append it to v2 Field Metadata. Export new v3 copy of Field Metadata.

# Notes
  # The output of this script was copy edited for commas and clarity. Then it was read into *_check_coords.R to check and update the coordinates.
  # This script shouldn't need to be run again. It now serves as documentation for what changes were made. 
  # Any edits to the metadata should use the output of this file as an input. 


### Prepare Script #############################################################
library(tidyverse)
library(gsheet) # used to load in google sheets
library(daff) # used to compare df columns
library(clipr) # used to copy final text string to clipboard

# clear global environment 
rm(list = ls())



### Load Data ##################################################################

# >> load in metadata ----
gd_metadata <-gsheet2tbl("https://docs.google.com/spreadsheets/d/14g_vLiGnF9vp9T9jlsbxFKLYB5TX6kF8N73WOvsBkiE/edit#gid=1075453003") %>% 
  .[1:114, ]


# >> load in v2 metadata ----
v2_metadata_file_path <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v3_CM_SSS_Data_Package\\v2_CM_SSS_Field_Metadata.csv"
v2_metadata_file_path <- file.choose()
v2_metadata <- read_csv(v2_metadata_file_path)

### EXPLORE GD METADATA ###########################################################

# >> Compare columns ----
  # extract only colnames
cols_v2_metadata <- data.frame(col_names = colnames(v2_metadata))
cols_gd_metadata <- data.frame(col_names = colnames(gd_metadata))

  # visualize differences
diff <- daff::diff_data(v2_metadata, gd_metadata)
diff <- daff::diff_data(cols_v2_metadata, cols_gd_metadata)
print(diff)
render_diff(diff)

 # quickly get a list of which ones are missing
missing_in_gd <- setdiff(colnames(v2_metadata), colnames(gd_metadata)) %>% print()
missing_in_v2 <- setdiff(colnames(gd_metadata), colnames(v2_metadata)) %>% print()


# >> Check if all kits (CM_001 to CM_117) are present ----
kit_check <- data.frame(kits = paste0("CM_", sprintf("%03d", 1:117))) %>%  # create values to expect (CM_001 to CM_117)
  left_join(gd_metadata, by = c("kits" = "Sample_Kit_ID")) %>% 
  filter(is.na(MiniDot_ID)) %>% 
  select(kits) %>% 
  print()

  # result: Kits without metadata: CM_019, CM_031, CM_036


# >> Extract Acknowledgements
acknowledgements <- gd_metadata %>% 
  select(Acknowledgements) %>% 
  filter(!is.na(Acknowledgements)) %>% 
  filter(!Acknowledgements %in% c("N/A", "No", "no", "not yet buy maybe in the future as my position expands")) %>% 
  distinct(.) %>% 
  arrange(Acknowledgements)

write_clip(acknowledgements)

read_clip()

### FIX GD METADATA ###############################################################

# >> Rename column names ----
gd_metadata_df_01 <- gd_metadata %>% 
  rename(Parent_ID = Sample_Kit_ID,
         miniDOT_Date = MiniDot_Date,
         miniDOT_Latitude = MiniDot_Latitude,
         miniDOT_Longitude = MiniDot_Longitude,
         miniDOT_Start_Time = MiniDot_Start_Time,
         miniDOT_End_Time = MiniDot_End_Time,
         miniDOT_SN = MiniDot_ID,
         Sediment = MiniDot_Sediment,
         Canopy_Coverage = Canopy_Cover,
         miniDOT_Notes = MiniDot_Notes)

# missing_in_gd cleaned
setdiff(colnames(v2_metadata), colnames(gd_metadata_df_01)) %>% print()
# missing_in_v2
setdiff(colnames(gd_metadata_df_01), colnames(v2_metadata)) %>% print()


# >> Remove columns ----
gd_metadata_df_02 <- gd_metadata_df_01 %>% 
  select(-c(Email, Water_Temperature, Field_Photos, Hydrograph_Other, CoAuthorship, Additional_Authors, Feedback, Acknowledgements, PNNL_Notes, `Run through script`, `Sent to Parallel Works`)) %>% 
  arrange(Parent_ID)


# >> Reorder columns ----
# get order from v2
col_order <- as.character(colnames(v2_metadata))

# reorder gd
gd_metadata_df_03 <- gd_metadata_df_02 %>% 
  select(col_order) %>% 
  arrange(Parent_ID)

# >> Update class str ----
gd_metadata_df_04 <- gd_metadata_df_03 %>% 
  mutate(miniDOT_SN = as.numeric(miniDOT_SN),
         Sample_Date = as.Date(Sample_Date, format = "%m/%d/%Y"),
         miniDOT_Date = as.Date(miniDOT_Date, format = "%m/%d/%Y"))
  
# >> Backfill N/A and -9999 ----
gd_metadata_df_05 <- gd_metadata_df_04 %>% 
  mutate_if(is.numeric, ~ifelse(is.na(.), -9999, .)) %>% 
  mutate_if(is.character, ~ifelse(is.na(.), "N/A", .))
  

# >> Filter only data after 2023-04-24 ----
gd_metadata_df_06 <- gd_metadata_df_05 %>% 
  filter(Sample_Date > "2023-04-24")


### CREATE COMBINED METADATA ###################################################

# >> Join v2 on to new gd data ----
metadata_df_01 <- v2_metadata %>% 
  add_row(gd_metadata_df_06)

### RUN INITIAL CHECKS #########################################################
source(file.choose()) # select `data_checks_functions.R`

check_class_str(metadata_df_01) # looks good
check_serach_for_NA(metadata_df_01) %>% View() # looks good
check_search_for_string(metadata_df_01, ",") %>% View() # 42 rows have commas
check_subset_class_view(metadata_df_01, "num") %>% View() # check coords
check_subset_class_view(metadata_df_01, "log") %>% View() # looks good
check_subset_class_view(metadata_df_01, "other") %>% View() # 2 date columns to convert to chr
check_subset_class_view(metadata_df_01, "chr") %>% View()
check_subset_class_counts(metadata_df_01, "chr") %>% View() # convert commas, change , to ; in General_Vegetation and River_Gradient


### EXPORT METADATA ############################################################
# final metadata df
metadata <- metadata_df_01

# clean up global environment - remove all objects except for "metadata" df
all_objects <- ls()
objects_to_remove <- setdiff(all_objects, "metadata")
rm(list = objects_to_remove)
rm(all_objects)
rm(objects_to_remove)

write_csv(metadata, "v3_CM_SSS_Field_Metadata.csv")



### LIST OF ITEMS TO MANUALLY CLEAN UP IN EXCEL ################################
  # remove commas [DONE]
  # convert data columns to character [DONE]
  # check coords [DONE]


### RUN FINAL CHECKS ###########################################################
metadata <- read_csv(file.choose())
source(file.choose()) # select `data_checks_functions.R`

check_class_str(metadata) # looks good
check_serach_for_NA(metadata) %>% View() # looks good
check_search_for_string(metadata, ",") %>% View() # looks good
check_subset_class_view(metadata, "num") %>% View() # looks good
check_subset_class_view(metadata, "log") %>% View() # looks good
check_subset_class_view(metadata, "other") %>% View() # 2 date columns to confirm in export
check_subset_class_view(metadata, "chr") %>% View() # looks good
check_subset_class_counts(metadata, "chr") %>% View() # looks good














