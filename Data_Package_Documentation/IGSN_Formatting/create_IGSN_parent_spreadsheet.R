# ==============================================================================
#
# Create the spreadsheet needed to register parent (site) IGSNs from field metadata
#
# Status: Complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 25 May 2022
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================
metadata_filepath <- file.choose()
metadata <- read_csv(metadata_filepath)
metadata <- read_csv('Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/WHONDRS_CM_Data_Package/WHONDRS_CM_Data_Package/WHONDRS_CM_Field_Metadata.csv')

user_code <- 'IEWDR' # this if for WHONDRS
# user_code <- 'IEPRS' # this is NOT for WHONDRS

outdir <- 'Z:/IGSN/AV1_IGSN_Site_ToBeRegistered.csv'


# ======================== input column names ============================

colnames(metadata)

# Sample Name: Some site identifier 
a <- metadata$Site_ID

# IGSN: leave blank 
b <- ''
 
# Parent IGSN: leave blank  
c <- ''

# Release Date: leave blank 
d <- ''
 
# Other name(s)
# use second line if not needed; used for the "extra names" for RC2 temporal sites
# e <- as.character(metadata$Site_Name)
e <- ''

# Latitude 
f <- as.character(metadata$Sample_Latitude)

# Longitude 
g <- as.character(metadata$Sample_Longitude)

# Primary physiographic feature: Stream 
h <- 'stream'
 
# Name of physiographic feature: Insert stream name 
i <- as.character(metadata$Stream_Name)
# i <- 'St. Lawrence River'
 
# Field program/Cruise
# j <- 'US Department of Energy River Corridor Science Focus Area'
j <- 'US Department of Energy River Corridor Science Focus Area, Worldwide Hydrobiogeochemical Observation Network for Dynamic River Systems (WHONDRS)'
 
# Country  
k <- 'United States'
# k <- as.character(metadata$Country)

# State/Province
# Use second line if not needed
l <- metadata$State
# l <- '

# (optional) City/Township 
# Use second line if not needed
m <- as.character(metadata$City)
# m <- ''

#name of study
n <- 'WHONDRS Allison Veach collaboration'

# =========================== create dataframe and add the data =================

output <- tibble(a) %>%
  add_column(b, c, d, e, f, g, h, i,
             j, k, l, m, n)

# =========================== rename with IGSN column headers ===================
# writeLines(paste(hs, sep = "\n"), file.path(outdir,file))

output <- output %>%
  rename('Sample Name' = a,
         'IGSN' = b,
         'Parent IGSN' = c,
         'Release Date' = d,
         'Other name(s)' = e ,
         'Latitude' = f ,
         'Longitude' = g,
         'Primary physiographic feature' = h,
         'Name of physiographic feature' = i,
         'Field program/Cruise' = j,
         'Country' = k,
         'State/Province' = l,
         'City/Township' = m,
         'Comment' = n
  ) %>%
  distinct(`Sample Name`, .keep_all = TRUE) # gets rid of duplicated sites

if (user_code == 'IEWDR') {

header <- tibble('Object Type:'= as.character(),
                 'Site'= as.character(),
                 'User Code:'= as.character(), 
                 'IEWDR' = as.character())
} else {
  
  header <- tibble('Object Type:'= as.character(),
                   'Site'= as.character(),
                   'User Code:'= as.character(), 
                   'IEPRS' = as.character())
}


write_csv(header, outdir)

write_csv(output, outdir, append = T, col_names = T)

shell.exec(outdir)
