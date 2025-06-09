# ==============================================================================
#
# Format IGSNs for data package, including combining site and sample if needed
#
# Status: Complete. Add N/A and -9999
#
# ==============================================================================
#
# Author: Brieanne Forbes; brieanne.forbes@pnnl.gov
# 20 July 2022
#
# ==============================================================================

library(tidyverse)
library(lubridate)
library(readxl)

# ================================= User inputs ================================

dp_dir <- 'Z:/00_ESSDIVE/01_Study_DPs/CoastalFires_Data_Package'

out_file <- "CoastalFires_Metadata_IGSN-Mapping.csv"

# ======================= read in site and sample IGSN =========================

outdir <- paste(dp_dir, out_file, sep = '/')  

site <- list.files(dp_dir, pattern = 'Site', full.names = T) %>%
  read_csv(site_file, skip = 1) 

sample <- list.files(dp_dir, pattern = 'Samples', full.names = T) %>% 
  read_csv(sample_file, skip = 1)

# ========================= remove unwanted columns and rename =================

if (nrow(site) > 0 ){

  site <- site %>%
    select(-`Parent IGSN`,-`Release Date`) %>%
    rename(
      Locality = "Sample Name",
      Parent_IGSN = "IGSN",
      Primary_Physiographic_Feature = "Primary physiographic feature",
      Physiographic_Feature_Name = "Name of physiographic feature",
      State_or_Province = "State/Province",
      Field_Program_Cruise = "Field program/Cruise",
      City_or_Township = 'City/Township',
      Other_Names = 'Other name(s)'
    ) %>%
    mutate(across(everything(), as.character))
  

}

if (nrow(sample) > 0) {
  
  sample <- sample %>%
    select(-`Release Date`) %>%
    rename(
      Sample_Name = "Sample Name",
      Parent_IGSN = "Parent IGSN",
      Field_Name_Informal_Classification = "Field name (informal classification)",
      Collection_Method = "Collection method",
      Collection_Method_Description = "Collection method description",
      Primary_Physiographic_Feature ="Primary physiographic feature",
      Physiographic_Feature_Name = "Name of physiographic feature",
      Field_Program_Cruise ="Field program/cruise",
      City_or_Township = 'City/Township',
      Collector_Chief_Scientist ="Collector/Chief Scientist",
      Collection_Date = "Collection date",
      Related_URL ="Related URL",
      Related_URL_Type = "Related URL Type",
      State_or_Province = "State/Province"
    )%>%
    mutate(across(everything(), as.character))

}


# ========================= merge and add metadata =============================



if (nrow(sample) > 0 & nrow(site) > 0) {

combine <- sample %>%
  full_join(site, by = c("Parent_IGSN", "Locality",
                        "Latitude", "Longitude",
                           "Primary_Physiographic_Feature",
                           'Physiographic_Feature_Name',
                           "Country", "Field_Program_Cruise", 'Comment',
                           'State_or_Province')
                         ) %>%
  # select(-Site_Name) %>%
  mutate(Collection_Date = paste0(' ', as.character(mdy(Collection_Date))))

metadata <- tibble('#Samples have International Generic Sample Numbers (IGSNs) registered with System for Earth Sample Registration (SESAR; https://www.geosamples.org/about/services#igsnregistration). This file maps between sample names and IGSNs. It conforms to the ESS-DIVE Sample ID and Metadata Reporting Format (IGSN-ESS) v1.1.0 (Damerow et al. 2020). Some information may be repeated between the field metadata file and this file. Parent_IGSN is the IGSN for each site ID. The original site ID is listed in the Locality column.' = as.character())

write_csv(metadata, outdir)

write_csv(combine, outdir, append = T, col_names = T)

# file.remove(site_file)
#
# file.remove(sample_file)

} else if (nrow(sample) == 0) {

  metadata <- tibble('#Site IDs have International Generic Sample Numbers (IGSNs) registered with System for Earth Sample Registration (SESAR; https://www.geosamples.org/about/services#igsnregistration).  This file maps between site IDs (in the column labeled Sample_Name) and IGSNs. It conforms to the ESS-DIVE Sample ID and Metadata Reporting Format (IGSN-ESS) v1.1.0 (Damerow et al. 2020). Some information is repeated between the field metadata file and this file.' = as.character())

  write_csv(metadata, outdir)

  write_csv(site, outdir, append = T, col_names = T)

  # file.remove(site_file)

} else if (nrow(site) == 0) {

  combine <- sample %>%
    mutate(Collection_Date = paste0(' ', as.character(mdy(Collection_Date))))

  metadata <- tibble('#Samples have International Generic Sample Numbers (IGSNs) registered with System for Earth Sample Registration (SESAR; https://www.geosamples.org/about/services#igsnregistration). This file maps between sample names and IGSNs. It conforms to the ESS-DIVE Sample ID and Metadata Reporting Format (IGSN-ESS) v1.1.0 (Damerow et al. 2020). Some information may be repeated between the field metadata file and this file. The site ID is listed in the Locality column.' = as.character())

  write_csv(metadata, outdir)

  write_csv(combine, outdir, append = T, col_names = T)

  # file.remove(sample_file)
}

