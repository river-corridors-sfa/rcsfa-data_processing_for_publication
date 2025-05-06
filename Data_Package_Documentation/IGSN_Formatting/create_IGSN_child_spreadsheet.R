### create_IGSN_child_spreadsheet.R ############################################
# Contact Information: 
  # Brieanne Forbes; brieanne.forbes@pnnl.gov
  # Bibi Powers-McCormack; bibi.powers-mccormack@pnnl.gov
# Date Created: 2022-05-25 by Brieanne Forbes
# Date Updated: 2025-04-02 by Bibi Powers-McCormack

# 2023-11-13 Changes
  # Added code to check if parent IGSN DOI was included and if it wasn't to add the DOI prefix.
  # Fixed the script to work when multiple materials are included. Previous version assumed material was "water" and then duplicated for "filter". Script now runs script based on materials provided by user. 

# 2025-04-02 Changes
  # Fixed the script to work with the new header changes that SESAR implemented. The header was previously "User Code", but is now "SESAR Code".

# Objective: Create the (.xls) spreadsheet needed to register child (sample) IGSNs from field metadata
  # Inputs: field_metadata, registered parent_IGSN .xls, user inputs
  # Outputs: ToBeRegistered.csv file
      # Note: the user will need to open this csv file and save it as an .xls prior to uploading for registration

# Directions

  # Edit the 5 "User Inputs" sections as it's applicable for the current file
  # Run "Generate IGSN File" section to create the a single file; you shouldn't need to edit any code in this section
    # (this creates a partly empty general file and then generates subsets for each material before joining all subsets together)
  # Run "Export IGSN file" section to export a .csv; you shouldn't need to edit any code in this section
  # Manually open .csv file and save as .xls
  # Use this file to register samples on IGSN website


### Load Libraries #############################################################
library(tidyverse) # cuz duh
library(readxl) # for reading in .xls files


### User Inputs 1: General #####################################################

# edit or run the applicable lines in this section

# select *_Field_Metadata.csv file (either use file.choose to select file or change filepath manually)
metadata_filepath <- file.choose()
# metadata_filepath <- "Z:\\00_Cross-SFA_ESSDIVE-Data-Package-Upload\\01_Study-Data-Package-Folders\\CM_SSS_Data_Package_v3\\v3_CM_SSS_Data_Package\\v3_CM_SSS_Field_Metadata.csv"

# indicate out directory file path and file name
outdir <- 'Z:/IGSN/MEL_IGSN_Samples_ToBeRegistered.csv' 
# the user will need to open this csv file and save it as an .xls prior to uploading for registration 

# select user code (options include: "IEWDR", "IEPRS")
user_code <- 'IEWDR' # this is for WHONDRS
# user_code <- 'IEPRS'  # this is not for WHONDRS

# indicate if parent IGSNs exist
# parent_igsn_present <- T
parent_igsn_present <- F

# if parent_igsn_presnt == T, select the registered sites (parent IGSN) .xls file (either use file.choose to select file or change filepath manually); skip if not applicable
parent_filepath <- file.choose()
# parent_filepath <- ""

# indicate which materials were collected (options include: "water", "sediment", "filter")
# materials_list <- c("water", "sediment", "filter", "soil") # soil assumes no other material and is not appended to parent ID
materials_list <- c("soil")


### Load data ##################################################################
# load metadata
metadata <- read_csv(metadata_filepath)

# load parent IGSN
if (parent_igsn_present == T) {
  parent <- read_xls(parent_filepath, skip = 1)
}


### User Inputs 2: field metadata extraction ###################################

# Fill in variables. 
# Either write in a character description manually or...
  # reference the metadata sheet by filling in the corresponding column header "metadata$[column header]". 
# If you are unsure how to, contact the Data Management Team


# print col names to use as a reference for filling out the variables below
print(colnames(metadata))

# `Sample Name`
a <- metadata$Parent_ID

# (name of sampling campaign) 'Comment'
i <- 'WHONDRS MONet Collaboration'

# 'Latitude (WGS 84)'
j <- metadata$Latitude

# 'Longitude (WGS 84)'
k <- metadata$Longitude

# 'Primary physiographic feature'
# l <- 'stream'
l <- ''

# 'Name of physiographic feature'
# m <- metadata$Locality
m <- ''

# (site ID) 'Locality'
n <- as.character(metadata$Site_Name)

# 'Locality description'
# o <- 'In stream site'
o <- ''

# 'Country'
p <- 'United States'

# 'State/Province'
q <- metadata$State
# q <- "Washington"

# 'City/Township'
r <- metadata$City
# r <- ""

# 'Field program/cruise'
s <- 'US Department of Energy River Corridor Science Focus Area, Worldwide Hydrobiogeochemical Observation Network for Dynamic River Systems (WHONDRS)'
# s <- 'US Department of Energy River Corridor Science Focus Area'

# 'Collector/Chief Scientist'
t <- 'James Stegen'

# 'Collection date'
u <- as.character(metadata$Sample_Date)

# 'Related URL'
v <- 'https://whondrs.pnnl.gov'
# v <- 'https://www.pnnl.gov/projects/river-corridor'

# Related URL Type
w <- 'regular URL'


### User Inputs 3: material - water ############################################

# Fill in inputs for water (*_Water)
# `Material`
e_water <- 'Liquid>aqueous'

# `Field name (informal classification)`
f_water <- 'Surface water'

# `Collection method`
g_water <- 'grab'

# `Collection method description`
h_water <- 'Surface water was either (1) pulled into syringe from 50% water column depth and expelled through 0.22 micron filter into sample vials or (2) was not filtered and collected into a bottle.'
h_water <- metadata$Collection_Method_Description


### User Inputs 4: material - sediment #########################################

# Fill in inputs for sediment (*_Sediment)
# `Material`
e_sediment <- 'Sediment'

# `Field name (informal classification)`
f_sediment <- 'Riverbed sediment'

# `Collection method`
g_sediment <- 'grab'

# `Collection method description`
h_sediment <- 'Sediment was scooped with a metal spoon (cleaned with hydrogen peroxide) into a bottle and two 50 milliliter vials containing "RNAlater" to preserve for future microbial analysis.'


### User Inputs 5: material - filter #############################################

# Fill in inputs for filter (*_RNA)
# `Material`
e_filter <- 'Other'

# `Field name (informal classification)`
f_filter <- 'Filter'

# `Collection method`
g_filter <- 'grab'

# `Collection method description`
h_filter <- '0.22 micron filter used for collecting filtered surface water samples and preserved with "RNAlater" for future microbial analysis'

### User Inputs 5: material - soil #############################################

# Fill in inputs for soil
# `Material`
e_soil <- 'Soil'

# `Field name (informal classification)`
f_soil <- 'Soil core'

# `Collection method`
g_soil <- ''

# `Collection method description`
h_soil <- ''


### Generate IGSN file #########################################################

# > Run the following code. There should be no more inputs. ----

# add variables that do not require user input
# `IGSN` 
b <- '' # leave blank

# `Parent IGSN`
c <- '' # fill in with parent

# `Release Date`
d <- '' # leave blank

# `Material`
e <- '' # leave blank for now, will get filled in later in the script

# `Field name (informal classification)`
f <- '' # leave blank for now, will get filled in later in the script

# `Collection method`
g <- '' # leave blank for now, will get filled in later in the script

# `Collection method description`
h <- '' # leave blank for now, will get filled in later in the script


# create df and add general metadata info
output_general <- tibble(a) %>% 
  add_column(b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w)


# add parent IGSNs, if applicable
if (parent_igsn_present == TRUE) {
  
  # extract Site ID and parent IGSN from parent df
  parent_igsn_join <- parent %>% 
    select(`Sample Name`, IGSN) %>% 
    rename("n" = `Sample Name`,
           "c" = "IGSN")
  
  # join by Site ID and move column
  output_general <- output_general %>%
    select(-`c`) %>% 
    left_join(parent_igsn_join, by = ("n" = "n")) %>% 
    relocate(c, .before = d)
  
  # append DOI ("10.58052/") if not already present on parent IGSN
  output_general <- output_general %>% 
    mutate(c = case_when((!is.na(c) & !startsWith(c, "10.58052/")) ~ paste0("10.58052/", c), TRUE ~ c))
}


# create empty output
output <- tibble(matrix(ncol = ncol(output_general), nrow = 0))
colnames(output) <- colnames(output_general)

# generate water
if ("water" %in% materials_list) {
  output_water <- output_general %>% 
    mutate(a = paste0(a, "_Water"), # rename sample name
           e = e_water, # add material
           f = f_water, # add field name
           g = g_water, # add collection method
           h = h_water) # add collection method description
  
  # add to output
  output <- output %>% 
    rbind(output_water)
}

# generate sediment
if ("sediment" %in% materials_list) {
  output_sediment <- output_general %>% 
    mutate(a = paste0(a, "_Sediment"), # rename sample name
           e = e_sediment, # add material
           f = f_sediment, # add field name
           g = g_sediment, # add collection method
           h = h_sediment) # add collection method description
  
  # add to output
  output <- output %>% 
    rbind(output_sediment)
}

# generate filter
if ("filter" %in% materials_list) {
  output_filter <- output_general %>% 
    mutate(a = paste0(a, "_RNA"), # rename sample name
           e = e_filter, # add material
           f = f_filter, # add field name
           g = g_filter, # add collection method
           h = h_filter) # add collection method description
  
  # add to output
  output <- output %>% 
    rbind(output_filter)
}

# generate filter
if ("soil" %in% materials_list) {
  output_filter <- output_general %>% 
    mutate(e = e_soil, # add material
           f = f_soil, # add field name
           g = g_soil, # add collection method
           h = h_soil) # add collection method description
  
  # add to output
  output <- output %>% 
    rbind(output_filter)
}


### Clean final IGSN file ######################################################

# rename cols
output <- output %>% 
  rename(
    "Sample Name" = "a",
    "IGSN" = "b",
    "Parent IGSN" = "c",
    "Release Date" = "d",
    "Material" = "e",
    "Field name (informal classification)" = "f",
    "Collection method" = "g",
    "Collection method description" = "h",
    "Comment" = "i",
    "Latitude" = "j",
    "Longitude" = "k",
    "Primary physiographic feature" = "l",
    "Name of physiographic feature" = "m",
    "Locality" = "n" ,
    "Locality description" = "o",
    "Country" = "p",
    "State/Province" = "q",
    "City/Township" = "r",
    "Field program/cruise" = "s",
    "Collector/Chief Scientist" = "t",
    "Collection date" = "u",
    "Related URL" = "v",
    "Related URL Type" = "w"
  )


# add correct user code to top
if (user_code == 'IEWDR') {
  
  header <- tibble('Object Type:'= as.character(),
                   'Individual Sample'= as.character(),
                   'SESAR Code:'= as.character(), 
                   'IEWDR' = as.character())
}

if (user_code == "IEPRS") {
  header <- tibble('Object Type:'= as.character(),
                   'Individual Sample'= as.character(),
                   'SESAR Code:'= as.character(), 
                   'IEPRS' = as.character())
}



# Export IGSN file #############################################################

write_csv(header, outdir)

write_csv(output, outdir, append = TRUE, col_names = TRUE)

shell.exec(outdir)

