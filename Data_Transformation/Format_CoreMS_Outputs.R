# ==============================================================================
#
# Format output files from CoreMS to comply with ESS-DIVE CSV reporting format (Velliquette et al. 2021)
#
# ==============================================================================
#
# Author: Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 6 March 2025
#
# ==============================================================================

require(pacman)
p_load(tidyverse) #install and/or library necessary packages

# remove anything in the environment
rm(list=ls(all=T))

# ================================= User inputs ================================

#insert the path of the data package folder
dir <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_AV1_Data_Package/WHONDRS_AV1_Data_Package'

# ============ set WD to the path of the data package ==========================

setwd(dir)

# ================================= get files ================================

corems_files <- list.files(path = './Sample_Data/FTICR', pattern = 'CoreMS.*\\.csv$', recursive = T, full.names = T, ignore.case = T)

data_files <- corems_files[grepl('CoreMS_Processed_ICR_Data', corems_files)]

mol_files <- corems_files[grepl('CoreMS_Processed_ICR_Mol', corems_files)]

cal_files <- corems_files[grepl('CoreMS_Processed_ICR_Calibration', corems_files)]

output_files <- corems_files[grepl('.corems', corems_files)]

# ================================== data files ===============================

for (i in data_files) {
  
  data <- read_csv(i)%>%
    rename_with(~ str_remove(.x, "\\.corems")) %>% # remove ".corems" from sample names
    rename_with(~ str_remove(.x, "_[^_]*$")) %>% # remove IAT from sample names
    rename(Calibrated_Mass = `Calibrated m/z`)
  
  write_csv(data, i) # rewrite files with same name
  
}

# ================================  mol files ==================================

for (j in mol_files) {
  
  mol <- read_csv(j) %>%
    select(-`Molecular Formula`) %>% #remove column as it is the same as MolForm column 
    rename(Calibrated_Mass = `Calibrated m/z`,
           Is_Isotopologue = `Is Isotopologue`,
           Heteroatom_Class = `Heteroatom Class`,
           Calculated_Mass = `Calculated m/z`,
           Error_ppm = `m/z Error (ppm)`) %>%
    mutate_all(function(x) if(is.numeric(x)) ifelse(is.na(x), -9999, x) else ifelse(is.na(x), 'N/A', x)) #replace na values with -9999 or N/A
  
  write_csv(mol, j) # rewrite files with same name
  
}

# ================================= cal files ==================================

for (k in cal_files) {
  
  cal <- read_csv(k) %>%
    rename(Sample_Name = Sample,
           Calibration_Points = "Cal. Points",
           Calibration_Threshold = "Cal. Thresh.",
           Calibration_RMSE =  'Cal. RMS Error (ppm)',
           Calibration_Order = "Cal. Order" )%>% 
    mutate(Sample_Name = str_remove(Sample_Name, "_[^_]*$")) # remove IAT from sample names
  
  write_csv(cal, k) # rewrite files with same name
  
}

# ===============================  output files ================================

for (m in output_files) {
  
  output <- read_csv(m)%>%
    rename_with(~ str_replace_all(.x, " ", "_")) %>% # replace all spaces in column names with underscores
    rename( Mass = `m/z`,
            Calibrated_Mass = `Calibrated_m/z`,
            Calculated_Mass = `Calculated_m/z`,
            S_N = `S/N`,
            Error_ppm = `m/z_Error_(ppm)`,
            Error_Score = `m/z_Error_Score`,
            O_C = `O/C`,
            H_C = `H/C`)%>%
    mutate_all(function(x) if(is.numeric(x)) ifelse(is.na(x), -9999, x) else ifelse(is.na(x), 'N/A', x)) #replace na values with -9999 or N/A
  
  
  write_csv(output, m) # rewrite files with same name
  
}
