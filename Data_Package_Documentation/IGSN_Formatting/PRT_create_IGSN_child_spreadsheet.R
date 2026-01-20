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
rm(list=ls(all=T))

### User Inputs 1: General #####################################################

# edit or run the applicable lines in this section

# select *_Field_Metadata.csv file (either use file.choose to select file or change filepath manually)
metadata_filepath <- file.choose()

# indicate out directory file path and file name
outdir <- 'Z:/IGSN/PRT_IGSN_Samples_ToBeRegistered.csv' 
# the user will need to open this csv file and save it as an .xls prior to uploading for registration 

# select user code (options include: "IEWDR", "IEPRS")
user_code <- 'IEPRS'  # this is not for WHONDRS

# indicate if parent IGSNs exist
# parent_igsn_present <- T
parent_igsn_present <- T

# if parent_igsn_presnt == T, select the registered sites (parent IGSN) .xls file (either use file.choose to select file or change filepath manually); skip if not applicable
parent_filepath <- file.choose()
# parent_filepath <- ""

### Load data ##################################################################
# load metadata
metadata <- read_csv(metadata_filepath, na = c('', '-9999', 'N/A')) %>%
  filter(!is.na(Parent_ID))

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
i <- 'Post Retreat Fire Temporal Study  (PRT)'

# 'Latitude (WGS 84)'
j <- metadata$Latitude

# 'Longitude (WGS 84)'
k <- metadata$Longitude

# 'Primary physiographic feature'
l <- ''

# 'Name of physiographic feature'
# m <- metadata$Stream_Name
m <- ''

# (site ID) 'Locality'
n <- ''
n <- metadata$Site_ID

# 'Locality description'
# o <- 'In stream site'
o <- ''

# 'Country'
p <- 'United States'
# p <- metadata$Country

# 'State/Province'
# q <- metadata$State
q <- "Washington"

# 'City/Township'
# r <- metadata$City
r <- ""

# 'Field program/cruise'
# s <- 'US Department of Energy: Investigating Hydrologic Connectivity as a Driver ofWetland Biogeochemical Response to Flood Disturbances'
s <- 'US Department of Energy River Corridor Science Focus Area'

# 'Collector/Chief Scientist'
t <- 'Allison Myers-Pigg'

# 'Collection date' in mm/dd/yyyy format
u <- metadata$Date

# 'Related URL'
# v <- 'https://whondrs.pnnl.gov'
v <- 'https://www.pnnl.gov/projects/river-corridor'
v <- ''

# Related URL Type
w <- 'regular URL'
w <- ''


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
  add_column(b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w) %>%
  add_column(type = metadata$Metadata_Type)


# add parent IGSNs, if applicable
if (parent_igsn_present == TRUE) {
  
  # extract Site ID and parent IGSN from parent df
  parent_igsn_join <- parent %>% 
    select(`Sample Name`, IGSN, "Primary physiographic feature", "Name of physiographic feature") %>% 
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
output_final <- output_general %>%
  select(-l, -m) %>%
  rename(l = "Primary physiographic feature",
         m = "Name of physiographic feature") %>%
  mutate(o = case_when(l == 'stream' ~ 'In stream site',
                       l == 'Groundwater spring' ~ 'Groundwater spring',
                       l == 'Groundwater well' ~ 'Groundwater water from well water faucet at Oak Creek Wildlife Area Unit',
                       l == 'Open field' ~ 'Open field at Oak Creek Wildlife Area Unit'),
         e = case_when(str_detect(type, 'water')~'Liquid>aqueous',
                       str_detect(type, 'Precipitation')~'Liquid>aqueous',
                       str_detect(type, 'Vegetation')~'Organic Material'
                       ),
         f = case_when(str_detect(type, 'Surface water')~'Surface water',
                       str_detect(type, 'Ground water')~'Ground water',
                       str_detect(type, 'Precipitation')~'Precipitation',
                       str_detect(type, 'Vegetation')~'Vegetation'
         ),
         g = 'grab',
         h = case_when(str_detect(type, 'Surface water')~'Surface water was pulled into syringe from 50% water column depth and expelled through 0.22 micron filter into sample vials.',
                       type == 'Ground water - push points'~'Ground water was pulled into syringe from tubing connected to pushpoint and expelled through 0.22 micron filter into sample vials.',
                       type == 'Ground water - well'~'Ground water was pulled into syringe from well waterfaucet and expelled through 0.22 micron filter into sample vials.',
                       type == 'Ground water - spring'~'Ground water was pulled into syringe from flowing water and expelled through 0.22 micron filter into sample vials.',
                       str_detect(type, 'Precipitation')~'Precipitation was pulled into syringe from bottle on precipitation collector and expelled through 0.22 micron filter into sample vials.',
                       str_detect(type, 'Vegetation')~'Burned and unburned vegetation were clipped and then laid out to dry.'
         )) %>%
  select(a, b, c, d, e, f, g, h, i, j,k,l,m,n,o,p,q, r, s, t,u ,v, w)
  


### Clean final IGSN file ######################################################

# rename cols
output_final <- output_final %>% 
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
} else if (user_code == 'IEPRS'){
  
  header <- tibble('Object Type:'= as.character(),
                   'Individual Sample'= as.character(),
                   'SESAR Code:'= as.character(), 
                   'IEPRS' = as.character())
} else if (user_code == 'IETGW'){
  
  header <- tibble('Object Type:'= as.character(),
                   'Individual Sample'= as.character(),
                   'SESAR Code:'= as.character(), 
                   'IETGW' = as.character())
}

# Export IGSN file #############################################################

write_csv(header, outdir)

write_csv(output_final, outdir, append = TRUE, col_names = TRUE)

shell.exec(outdir) # save as .xls to IGSN folder in Share Drive

