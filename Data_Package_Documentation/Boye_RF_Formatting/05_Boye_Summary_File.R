# ==============================================================================
#
# Make a summary file of means for each analyte file going into a data package
#
# Status: In progress
#
# known issue: putting NA in detection limit and precision row 
# 
# ==============================================================================
#
# Author: Brieanne Forbes, brieanne.forbes@pnnl.gov
# 30 Sept 2022
#
# ==============================================================================

library(tidyverse)
library(janitor)
rm(list=ls(all=T))

# ================================= User inputs ================================

# dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/'
dir <- "Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Study-Data-Package-Folders/CM_SSS_Data_Package_v4"

# RC <- 'RC2'

study_code <- 'CM_SSS'

material <- 'Sediment'

# ====================================== Build dir name ========================

# boye_dir <- paste0(dir, RC, '/Boye_Files/', study_code, '/')

# ================================= Wrangle data and summarize =================

# analyte_files <- list.files(boye_dir, 'Boye', full.names = T)

# analyte_files <- analyte_files[!grepl('ReadyForBoye',analyte_files)]

analyte_files <- list.files(paste0(dir, "/v4_CM_SSS_Data_Package/Sample_Data"), pattern = paste0(material, ".*\\.csv$"), full.names = T) # selects all csv files that contain the word provided in the "material" string
analyte_files <- analyte_files[!grepl('Mass_Volume',analyte_files)]
print(basename(analyte_files))

# qaqc_files <- list.files(boye_dir, 'CombinedQAQC', full.names = T)

qaqc_files <- list.files(dir, pattern = "(Outliers|CombinedQAQC).*\\.csv$", full.names = T) # selects .csv files that contain the word "Outliers" or "CombinedQAQC" in the file name
print(basename(qaqc_files))

# ====================== create combined data frames ===========================

# get full list of all samples by reading in each file and creating unique list of parent ids
combine <- data.frame(Sample_Name = NA_character_, Material = NA_character_)

for (i in 1:length(analyte_files)) {
  
  # read in file and select only sample column
  current_parent_ids <- read_csv(analyte_files[i], skip = 2, na = c("-9999", "NA", "", "N/A")) %>% 
    select(Sample_Name, Material) %>% 
    drop_na() %>% 
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-2[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-3[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-4[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-5[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-6[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '-4'),
      Sample_Name = str_remove(Sample_Name, '-5'),
      Sample_Name = str_remove(Sample_Name, '-6'),
      Sample_Name = str_remove(Sample_Name, '_DIC'),
      Sample_Name = str_remove(Sample_Name, '_ION'),
      Sample_Name = str_remove(Sample_Name, '_OCN'),
      Sample_Name = str_remove(Sample_Name, '_TN'),
      Sample_Name = str_remove(Sample_Name, '_ICR'),
      Sample_Name = str_remove(Sample_Name, '_TSS'),
      Sample_Name = str_remove(Sample_Name, '_SFE'),
      Sample_Name = str_remove(Sample_Name, '_INC'),
      Sample_Name = str_remove(Sample_Name, '_MOI'),
      Sample_Name = str_remove(Sample_Name, "_ATP"),
      Sample_Name = str_remove(Sample_Name, '_GRN'),
      Sample_Name = str_remove(Sample_Name, '_XRD'),
      Sample_Name = str_remove(Sample_Name, '_WIN'),
      Sample_Name = str_remove(Sample_Name, '_SCN')) %>% 
    distinct()
  
  # add samples to df
  combine <- combine %>% 
    rbind(., current_parent_ids)
  
}

# get unique list of samples
combine <- combine %>% 
  distinct() %>% 
  drop_na() %>% 
  mutate(Field_Name = NA_character_, 
         Mean_Missing_Reps = NA) %>% 
  select(Field_Name, Sample_Name, Material, Mean_Missing_Reps)

paste0("Total number of samples: ", count(distinct(combine, Sample_Name)))

# combine <- read_csv(analyte_files[3], skip = 2) %>%
#   filter(!Sample_Name %in% c('N/A', '-9999', 'NA', '')) %>%
#   select("Field_Name", "Sample_Name", "Material") %>%
#   mutate(Field_Name = NA,
#          Sample_Name = str_remove(Sample_Name, '-1[:alpha:]'),
#          Sample_Name = str_remove(Sample_Name, '-2[:alpha:]'),
#          Sample_Name = str_remove(Sample_Name, '-3[:alpha:]'),
#          Sample_Name = str_remove(Sample_Name, '-4[:alpha:]'),
#          Sample_Name = str_remove(Sample_Name, '-5[:alpha:]'),
#          Sample_Name = str_remove(Sample_Name, '-6[:alpha:]'),
#          Sample_Name = str_remove(Sample_Name, '-1'),
#          Sample_Name = str_remove(Sample_Name, '-2'),
#          Sample_Name = str_remove(Sample_Name, '-3'),
#          Sample_Name = str_remove(Sample_Name, '-4'),
#          Sample_Name = str_remove(Sample_Name, '-5'),
#          Sample_Name = str_remove(Sample_Name, '-6'),
#          Sample_Name = str_remove(Sample_Name, '_DIC'),
#          Sample_Name = str_remove(Sample_Name, '_ION'),
#          Sample_Name = str_remove(Sample_Name, '_OCN'),
#          Sample_Name = str_remove(Sample_Name, '_TN'),
#          Sample_Name = str_remove(Sample_Name, '_ICR'),
#          Sample_Name = str_remove(Sample_Name, '_TSS'),
#          Sample_Name = str_remove(Sample_Name, '_SFE'),
#          Sample_Name = str_remove(Sample_Name, '_INC'),
#          Sample_Name = str_remove(Sample_Name, '_MOI'),
#          Sample_Name = str_remove(Sample_Name, "_ATP"),
#          Sample_Name = str_remove(Sample_Name, '_GRN'),
#          Sample_Name = str_remove(Sample_Name, '_WIN'),
#          Sample_Name = str_remove(Sample_Name, '_SCN'))%>%
#   add_column(Mean_Missing_Reps = NA) %>%
#   distinct()

combine_headers <- read_csv(analyte_files[1], n_max = 11, skip = 2) %>%
  select("Field_Name", "Sample_Name", "Material")

# ======================================= DIC ==================================
  
DIC_file <- analyte_files[grepl("DIC", analyte_files)]
DIC_file

if (length(DIC_file) > 0) {
  DIC_boye_headers <- read_csv(DIC_file, n_max = 11, skip = 2, na = '-9999')%>%
    select(-'Methods_Deviation', -IGSN)
  
  DIC_qaqc <- qaqc_files[grepl("DIC", qaqc_files)] %>%
    read_csv() %>%
    filter(DIC_Outlier == T)
  
  DIC_data <- read_csv(DIC_file, skip = 2) %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(Field_Name = 'N/A',
      `00691_DIC_mg_per_L_as_C` = ifelse(Sample_Name %in% DIC_qaqc$Sample_ID,NA,as.numeric(`00691_DIC_mg_per_L_as_C`)),
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '_DIC')
    )
  
  DIC_summary <- DIC_data %>%
    group_by(Sample_Name) %>%
    mutate(count = sum(!is.na(`00691_DIC_mg_per_L_as_C`))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_00691_DIC_mg_per_L_as_C` = mean(`00691_DIC_mg_per_L_as_C`, na.rm = T),
      Mean_Missing_Reps = ifelse(count<3, TRUE, FALSE),
      count = unique(count)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `Mean_00691_DIC_mg_per_L_as_C`, Mean_Missing_Reps)%>%
    distinct()
  
  combine <- combine %>%
    full_join(DIC_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps,Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(DIC_boye_headers)
  
  
}

# ======================================= Ions ==================================

Ion_file <- analyte_files[grepl("Ions", analyte_files)]
Ion_file

if (length(Ion_file) > 0) {
  
  # read in headers
  Ion_boye_headers <- read_csv(Ion_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -starts_with('...'), -IGSN)
  
  # read in qaqc file
  Ion_qaqc <- qaqc_files[grepl("Ions", qaqc_files)] %>%
    read_csv()
  
  NH4_qaqc <- Ion_qaqc %>%
    filter(Ammonium_Outlier == T)
  
  Br_qaqc <- Ion_qaqc %>%
    filter(Bromide_Outlier == T)
  
  Ca_qaqc <- Ion_qaqc %>%
    filter(Calcium_Outlier == T)
  
  Cl_qaqc <- Ion_qaqc %>%
    filter(Chloride_Outlier == T)
  
  F_qaqc <- Ion_qaqc %>%
    filter(Fluoride_Outlier == T)
  
  Li_qaqc <- Ion_qaqc %>%
    filter(Lithium_Outlier == T)
  
  Mg_qaqc <- Ion_qaqc %>%
    filter(Magnesium_Outlier == T)
  
  NO3_qaqc <- Ion_qaqc %>%
    filter(Nitrate_Outlier == T)
  
  NO2_qaqc <- Ion_qaqc %>%
    filter(Nitrite_Outlier == T)
  
  PO4_qaqc <- Ion_qaqc %>%
    filter(Phosphate_Outlier == T)
  
  K_qaqc <- Ion_qaqc %>%
    filter(Potassium_Outlier == T)
  
  Na_qaqc <- Ion_qaqc %>%
    filter(Sodium_Outlier == T)
  
  SO4_qaqc <- Ion_qaqc %>%
    filter(Sulfate_Outlier == T)
  
  # `00691_DIC_mg_per_L_as_C` = ifelse(Sample_Name %in% DIC_qaqc$Sample_ID,NA,as.numeric(`00691_DIC_mg_per_L_as_C`))
  
  Ion_data <- read_csv(Ion_file, skip = 2, na = c(-9999, "N/A", "")) %>%
    select(-IGSN) %>%
    filter(!is.na(Sample_Name)) %>% 
    mutate(Field_Name = NA,
           `NH4_mg_per_L_as_NH4` = ifelse(Sample_Name %in% NH4_qaqc$Sample_ID, NA, as.numeric(`NH4_mg_per_L_as_NH4`)),
           `71870_Br_mg_per_L` = ifelse(Sample_Name %in% Br_qaqc, NA, as.numeric(`71870_Br_mg_per_L`)),
           `00915_Ca_mg_per_L` = ifelse(Sample_Name %in% Ca_qaqc, NA, as.numeric(`00915_Ca_mg_per_L`)),
           `00940_Cl_mg_per_L` = ifelse(Sample_Name %in% Cl_qaqc, NA, as.numeric(`00940_Cl_mg_per_L`)),
           `00950_F_mg_per_L` = ifelse(Sample_Name %in% F_qaqc, NA, as.numeric(`00950_F_mg_per_L`)),
           `01130_Li_mg_per_L` = ifelse(Sample_Name %in% Li_qaqc, NA,  as.numeric(`01130_Li_mg_per_L`)),
           `00925_Mg_mg_per_L` = ifelse(Sample_Name %in% Mg_qaqc, NA, as.numeric(`00925_Mg_mg_per_L`)),
           `71851_NO3_mg_per_L_as_NO3` = ifelse(Sample_Name %in% NO3_qaqc, NA, as.numeric(`71851_NO3_mg_per_L_as_NO3`)),
           `71856_NO2_mg_per_L_as_NO2` = ifelse(Sample_Name %in% NO2_qaqc, NA, as.numeric(`71856_NO2_mg_per_L_as_NO2`)),
           `00653_PO4_mg_per_L_as_PO4` = ifelse(Sample_Name %in% PO4_qaqc, NA, as.numeric(`00653_PO4_mg_per_L_as_PO4`)),
           `00935_K_mg_per_L` = ifelse(Sample_Name %in% K_qaqc, NA, as.numeric(`00935_K_mg_per_L`)),
           `00930_Na_mg_per_L` = ifelse(Sample_Name %in% Na_qaqc, NA, as.numeric(`00930_Na_mg_per_L`)),
           `00945_SO4_mg_per_L_as_SO4` = ifelse(Sample_Name %in% SO4_qaqc, NA, as.numeric(`00945_SO4_mg_per_L_as_SO4`)),
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '_ION'),
      Sample_Name = str_remove(Sample_Name, '_WIN')
    )
  
  Ion_summary <- Ion_data %>%
    group_by(Sample_Name) %>%
    mutate(count_NH4 = sum(!is.na(`NH4_mg_per_L_as_NH4`)),
           count_Br = sum(!is.na(`71870_Br_mg_per_L`)),
           count_Ca = sum(!is.na(`00915_Ca_mg_per_L`)),
           count_Cl = sum(!is.na(`00940_Cl_mg_per_L`)),
           count_F = sum(!is.na(`00950_F_mg_per_L`)),
           count_Li = sum(!is.na(`01130_Li_mg_per_L`)),
           count_Mg = sum(!is.na(`00925_Mg_mg_per_L`)),
           count_NO3 = sum(!is.na(`71851_NO3_mg_per_L_as_NO3`)),
           count_NO2 = sum(!is.na(`71856_NO2_mg_per_L_as_NO2`)),
           count_PO4 = sum(!is.na(`00653_PO4_mg_per_L_as_PO4`)),
           count_K = sum(!is.na(`00935_K_mg_per_L`)),
           count_Na = sum(!is.na(`00930_Na_mg_per_L`)),
           count_SO4 = sum(!is.na(`00945_SO4_mg_per_L_as_SO4`))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_NH4_mg_per_L_as_NH4` = mean(`NH4_mg_per_L_as_NH4`, na.rm = T),
      `Mean_71870_Br_mg_per_L` = mean(`71870_Br_mg_per_L`, na.rm = T),
      `Mean_00915_Ca_mg_per_L` = mean(`00915_Ca_mg_per_L`, na.rm = T),
      `Mean_00940_Cl_mg_per_L` = mean(`00940_Cl_mg_per_L`, na.rm = T),
      `Mean_00950_F_mg_per_L` = mean(`00950_F_mg_per_L`, na.rm = T),
      `Mean_01130_Li_mg_per_L` = mean(`01130_Li_mg_per_L`, na.rm = T),
      `Mean_00925_Mg_mg_per_L` = mean(`00925_Mg_mg_per_L`, na.rm = T),
      `Mean_71851_NO3_mg_per_L_as_NO3` = mean(`71851_NO3_mg_per_L_as_NO3`, na.rm = T),
      `Mean_71856_NO2_mg_per_L_as_NO2` = mean(`71856_NO2_mg_per_L_as_NO2`, na.rm = T),
      `Mean_00653_PO4_mg_per_L_as_PO4` = mean(`00653_PO4_mg_per_L_as_PO4`, na.rm = T),
      `Mean_00935_K_mg_per_L` = mean(`00935_K_mg_per_L`, na.rm = T),
      `Mean_00930_Na_mg_per_L` = mean(`00930_Na_mg_per_L`, na.rm = T),
      `Mean_00945_SO4_mg_per_L_as_SO4` = mean(`00945_SO4_mg_per_L_as_SO4`, na.rm = T),
      Mean_Missing_Reps = ifelse(count_NH4<3, TRUE, FALSE),
      Mean_Missing_Reps = ifelse(count_Br<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_Ca<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_Cl<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_F<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_Li<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_Mg<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_NO3<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_NO2<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_PO4<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_K<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_Na<3, TRUE, Mean_Missing_Reps),
      Mean_Missing_Reps = ifelse(count_SO4<3, TRUE, Mean_Missing_Reps)) %>% 
    filter(!is.na(Sample_Name)) %>%
    # rename_if(is.numeric, ~ paste0("Mean_", .)) %>% # this renames all numeric cols with "Mean_" appended to front; this includes the count cols which it shouldn't do but those columns that are incorrectly renamed are immediately dropped in the select(), so I'm leaving it
    select(
      Field_Name,
      Sample_Name,
      Material,
      `Mean_NH4_mg_per_L_as_NH4`,
      `Mean_71870_Br_mg_per_L`,
      `Mean_00915_Ca_mg_per_L`,
      `Mean_00940_Cl_mg_per_L`,
      `Mean_00950_F_mg_per_L`,
      `Mean_01130_Li_mg_per_L`,
      `Mean_00925_Mg_mg_per_L`,
      `Mean_71851_NO3_mg_per_L_as_NO3`,
      `Mean_71856_NO2_mg_per_L_as_NO2`,
      `Mean_00653_PO4_mg_per_L_as_PO4`,
      `Mean_00935_K_mg_per_L`,
      `Mean_00930_Na_mg_per_L`,
      `Mean_00945_SO4_mg_per_L_as_SO4`,
      Mean_Missing_Reps
    )%>%
    mutate(across(where(is.numeric), ~ ifelse(is.nan(mean(., na.rm = TRUE)), NA_real_, mean(., na.rm = TRUE)))) %>%  # calculates mean of all numeric cols; converts rows where all sample reps were NA from NaN to NA
    distinct()
    
  combine <- combine %>%
    full_join(Ion_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(Ion_boye_headers)
  
  
}

# ====================================== NPOC-TN =================================

NPOC_TN_file <- analyte_files[grepl("NPOC_TN", analyte_files)]
NPOC_TN_file

if (length(NPOC_TN_file) > 0) {
  NPOC_TN_boye_headers <- read_csv(NPOC_TN_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  NPOC_TN_NPOC_qaqc <- qaqc_files[grepl("NPOC_TN", qaqc_files)] %>% 
    read_csv() %>%
    filter(NPOC_Outlier == T)
  
  NPOC_TN_TN_qaqc <- qaqc_files[grepl("NPOC_TN", qaqc_files)] %>%
    read_csv() %>%
    filter(TN_Outlier == T)
  
  NPOC_TN_data <- read_csv(NPOC_TN_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(Field_Name = 'N/A',
           `00681_NPOC_mg_per_L_as_C` = ifelse(Sample_Name %in% NPOC_TN_NPOC_qaqc$Sample_ID, NA, as.numeric(`00681_NPOC_mg_per_L_as_C`)),
           `00602_TN_mg_per_L_as_N` = ifelse(Sample_Name %in% NPOC_TN_TN_qaqc$Sample_ID, NA, as.numeric(`00602_TN_mg_per_L_as_N`)),
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '_OCN')
    )
  
  
  NPOC_TN_summary <- NPOC_TN_data %>%
    group_by(Sample_Name) %>%
    mutate(count_NPOC = sum(!is.na(`00681_NPOC_mg_per_L_as_C`)),
           count_TN = sum(!is.na(`00602_TN_mg_per_L_as_N`))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_00681_NPOC_mg_per_L_as_C` = mean(`00681_NPOC_mg_per_L_as_C`, na.rm = T),
      `Mean_00602_TN_mg_per_L_as_N` = mean(`00602_TN_mg_per_L_as_N`, na.rm = T),
      Mean_Missing_Reps = ifelse(count_NPOC<3, TRUE, FALSE),
      Mean_Missing_Reps = ifelse(count_TN<3, TRUE, Mean_Missing_Reps),
      count_NPOC = unique(count_NPOC),
      count_TN = unique(count_TN)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `Mean_00681_NPOC_mg_per_L_as_C`, `Mean_00602_TN_mg_per_L_as_N`, Mean_Missing_Reps)%>%
    distinct()
  
  combine <- combine %>%
    full_join(NPOC_TN_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(NPOC_TN_boye_headers)
  
}

# ====================================== NPOC =================================

NPOC_file <- analyte_files[grepl("NPOC_Boye", analyte_files)]
NPOC_file

if (length(NPOC_file) > 0) {
  NPOC_boye_headers <- read_csv(NPOC_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  NPOC_NPOC_qaqc <- qaqc_files[grepl("NPOC", qaqc_files)] %>%
    read_csv() %>% 
    clean_names(replace = c('outlier' = 'Outlier'), case = 'none') %>%
    filter(NPOC_Outlier == T)
  
  NPOC_data <- read_csv(NPOC_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(Field_Name = 'N/A',
           `00681_NPOC_mg_per_L_as_C` = ifelse(Sample_Name %in% NPOC_NPOC_qaqc$Sample_ID, NA, as.numeric(`00681_NPOC_mg_per_L_as_C`)),
           Sample_Name = str_remove(Sample_Name, '-1'),
           Sample_Name = str_remove(Sample_Name, '-2'),
           Sample_Name = str_remove(Sample_Name, '-3'),
           Sample_Name = str_remove(Sample_Name, '_OCN'),
           Sample_Name = str_remove(Sample_Name, '_ICR')
    )
  
  
  NPOC_summary <- NPOC_data %>%
    group_by(Sample_Name) %>%
    mutate(count_NPOC = sum(!is.na(`00681_NPOC_mg_per_L_as_C`))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_00681_NPOC_mg_per_L_as_C` = mean(`00681_NPOC_mg_per_L_as_C`, na.rm = T),
      Mean_Missing_Reps = ifelse(count_NPOC<3, TRUE, FALSE),
      count_NPOC = unique(count_NPOC)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `Mean_00681_NPOC_mg_per_L_as_C`, Mean_Missing_Reps)%>%
    distinct()
  
  combine <- combine %>%
    full_join(NPOC_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(NPOC_boye_headers)
  
}

# ===================================== TN =====================================

TN_file <- analyte_files[grepl("TN", analyte_files)]
TN_file <- TN_file[-grepl("NPOC", TN_file)]
TN_file

if (length(TN_file) > 0) {
  TN_boye_headers <- read_csv(TN_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  TN_TN_qaqc <- qaqc_files[grepl("TN", qaqc_files)] %>%
    read_csv() %>%
    filter(TN_Outlier == T)
  
  TN_data <- read_csv(TN_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(`00602_TN_mg_per_L_as_N` = ifelse(Sample_Name %in% TN_TN_qaqc$Sample_ID, NA, as.numeric(`00602_TN_mg_per_L_as_N`)),
           Sample_Name = str_remove(Sample_Name, '-1'),
           Sample_Name = str_remove(Sample_Name, '-2'),
           Sample_Name = str_remove(Sample_Name, '-3'),
           Sample_Name = str_remove(Sample_Name, '_OCN'),
           Sample_Name = str_remove(Sample_Name, '_ICR')
    )
  
  
  TN_summary <- TN_data %>%
    group_by(Sample_Name) %>%
    mutate(count_TN = sum(!is.na(`00602_TN_mg_per_L_as_N`))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_00602_TN_mg_per_L_as_N` = mean(`00602_TN_mg_per_L_as_N`, na.rm = T),
      Mean_Missing_Reps = ifelse(count_TN<3, TRUE, FALSE),
      count_TN = unique(count_TN)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `Mean_00602_TN_mg_per_L_as_N`, Mean_Missing_Reps)%>%
    distinct()
  
}

# ================================== ATP =======================================

ATP_file <- analyte_files[grepl("ATP", analyte_files)]
ATP_file

if (length(ATP_file) > 0) {
  
  # read in headers
  ATP_boye_headers <- read_csv(ATP_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  # read in QAQC file
  ATP_qaqc <- qaqc_files[grepl("ATP", qaqc_files)] %>%
    read_csv() %>% 
    clean_names(replace = c('flag' = 'Flag'), case = 'none') %>% # if applicable, make flag -> Flag
    filter(Flag == "OMIT") %>%  # Flag == "OMIT" will later be marked as NA so it's value isn't included in the mean
    pull(Sample_Name) # return a vector of samples to ignore in summary calculations
  
  # read in data
  ATP_data <- read_csv(ATP_file, skip = 2, na = c("-9999", "N/A", "")) %>%
    select(-IGSN)%>%
    filter(!is.na(Sample_Name)) %>%
    mutate_at(vars(ATP_nanomoles_per_L, ATP_picomoles_per_g), 
              as.numeric) %>% # convert columns to numeric str
    mutate(across(where(is.numeric), ~ if_else(Sample_Name %in% ATP_qaqc, NA_real_, .))) %>%  # for any samples that are in the qaqc list, convert all numeric cols to NA
    mutate(Sample_Name = str_remove(Sample_Name, '-1'), # strip rep and data type info off sample names
           Sample_Name = str_remove(Sample_Name, '-2'),
           Sample_Name = str_remove(Sample_Name, '-3'),
           Sample_Name = str_remove(Sample_Name, '_ATP'),
           Field_Name = NA_character_) # convert #Start_Data and #End_Data to NA
  
  # create summary for ATP
  ATP_summary <- ATP_data %>%
    group_by(Sample_Name) %>%
    mutate(count_ATP1 = sum(!is.na(ATP_nanomoles_per_L)),
           count_ATP2 = sum(!is.na(ATP_picomoles_per_g))) %>% 
    summarise(
      Field_Name = NA,
      Material = unique(Material),
      across(where(is.numeric), ~ ifelse(is.nan(mean(., na.rm = TRUE)), NA, mean(., na.rm = TRUE))), # calculates mean of all numeric cols; converts rows where all sample reps were NA from NaN to NA
      Mean_Missing_Reps = case_when(count_ATP1 < 3 | count_ATP2 < 3 ~ TRUE, TRUE ~ FALSE),   # if either col has fewer than 3 reps, mark missing reps col as TRUE
      count_ATP1 = unique(count_ATP1),
      count_ATP2 = unique(count_ATP2)) %>% 
    ungroup() %>% 
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, ATP_nanomoles_per_L, ATP_picomoles_per_g, Mean_Missing_Reps) %>%
    distinct() %>% 
    rename_with(~ ifelse(sapply(ATP_data, is.numeric), paste0("Mean_", .), .)) # renames numeric cols to prefix "Mean_" to the original col name
  
  # join atp to all
  combine <- combine %>%
    full_join(ATP_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T) %>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE)) %>%
    filter(!is.na(Sample_Name))
  
  # join atp headers to all headers
  combine_headers <- combine_headers %>%
    left_join(ATP_boye_headers)
  
}

# ================================== MOI =======================================

MOI_file <- analyte_files[grepl("Moisture", analyte_files)]
MOI_file

if (length(MOI_file) > 0) {
  
  # read in headers
  MOI_boye_headers <- read_csv(MOI_file, n_max = 11, skip = 2)%>%
    select(Field_Name, Sample_Name, Material, contains('Gravimetric_Moisture'))
  
  # read in QAQC file
  MOI_qaqc <- qaqc_files[grepl("MOI", qaqc_files)] %>%
    read_csv() %>% 
    clean_names(replace = c('flag' = 'Flag'), case = 'none') %>% # if applicable, make flag -> Flag
    filter(Flag == "OMIT") %>%  # Flag == "OMIT" will later be marked as NA so it's value isn't included in the mean
    pull(Sample_Name) # return a vector of samples to ignore in summary calculations
  
  # read in data
  MOI_data <- read_csv(MOI_file, skip = 2, na = c(-9999, "N/A", "")) %>%
    select(-IGSN) %>%
    filter(!is.na(Sample_Name)) %>%
    mutate_at(vars(Wet_Sediment_Mass_MOI_g, Dry_Sediment_Mass_MOI_g, Water_Mass_MOI_g, 
                   `62948_Gravimetric_Moisture_g_per_g`), 
              as.numeric) %>% # convert columns to numeric str
    mutate(across(where(is.numeric), ~ if_else(Sample_Name %in% MOI_qaqc, NA_real_, .))) %>%  # for any samples that are in the qaqc list, convert all numeric cols to NA
    mutate(Sample_Name = str_remove(Sample_Name, '-1'), # strip rep and data type info off sample names
           Sample_Name = str_remove(Sample_Name, '-2'),
           Sample_Name = str_remove(Sample_Name, '-3'),
           Sample_Name = str_remove(Sample_Name, '_MOI'),
           Field_Name = NA_character_) # convert #Start_Data and #End_Data to NA
  
  # create summary for MOI
  MOI_summary <- MOI_data %>%
    group_by(Sample_Name) %>%
    mutate(count_MOI = sum(!is.na(`62948_Gravimetric_Moisture_g_per_g`))) %>% 
    summarise(
      Field_Name = NA,
      Material = unique(Material),
      across(where(is.numeric), mean, .names = "Mean_{.col}"), # calculates mean of all numeric cols; converts rows where all sample reps were NA from NaN to NA, renames them to start with "Mean_"
      Mean_Missing_Reps = case_when(count_MOI < 3 ~ TRUE, TRUE ~ FALSE),   # if col has fewer than 3 reps, mark missing reps col as TRUE
      count_MOI = unique(count_MOI)) %>% 
    ungroup() %>% 
    filter(!is.na(Sample_Name)) %>% 
    select(Field_Name, Sample_Name, Material, `Mean_62948_Gravimetric_Moisture_g_per_g`, Mean_Missing_Reps) %>% 
    distinct() 
  
  # join moi to all
  combine <- combine %>%
    full_join(MOI_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T) %>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE)) %>%
    filter(!is.na(Sample_Name))
  
  # join atp headers to all headers
  combine_headers <- combine_headers %>%
    left_join(MOI_boye_headers)
  
}

# ======================================= TSS ==================================

TSS_file <- analyte_files[grepl("TSS", analyte_files)]
TSS_file

if (length(TSS_file) > 0) {
  TSS_boye_headers <- read_csv(TSS_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)

  TSS_data <- read_csv(TSS_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999')) %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '_TSS')
    )
  
  TSS_data <- TSS_data %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data')%>%
    mutate(Field_Name = 'N/A',
           `00530_TSS_mg_per_L` = as.numeric(`00530_TSS_mg_per_L`))
  
  TSS_summary <- TSS_data %>%
    group_by(Sample_Name) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `00530_TSS_mg_per_L` = `00530_TSS_mg_per_L`,
      Mean_Missing_Reps = NA
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `00530_TSS_mg_per_L`, Mean_Missing_Reps)
  
  combine <- combine %>%
    full_join(TSS_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(TSS_boye_headers)
  
}

# ======================================= XRD ==================================

XRD_file <- analyte_files[grepl("XRD", analyte_files)]
XRD_file

if (length(XRD_file) > 0) {
  
  # read in headers
  XRD_boye_headers <- read_csv(XRD_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  # read in data
  XRD_data <- read_csv(XRD_file, skip = 2, na = c(-9999, "N/A", "")) %>%
    select(-IGSN) %>%
    filter(!is.na(Sample_Name)) %>% # remove any NA samples
    mutate(Sample_Name = str_remove(Sample_Name, '-1'), # strip rep and data type info off sample names
           Sample_Name = str_remove(Sample_Name, '_XRD'),
           Field_Name = NA_character_) %>% # convert #Start_Data and #End_Data to NA
    mutate_at(vars(Quartz_percent, Albite_percent, Microcline_percent, Pyroxene_percent,
                   Calcite_percent, Dolomite_percent, Muscovite_percent, Smectite_percent, 
                   Chlorite_percent, Amphibole_percent, Apatite_percent), 
              as.numeric) # convert percents columns to numeric str
  
  # create summary file for XRD data
  XRD_summary <- XRD_data %>%
    group_by(Sample_Name) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      across(where(is.numeric), mean, na.rm = T), # calculates mean of all percent cols; however since rep = 1, this is pulling the same single value as before
      Mean_Missing_Reps = NA
    )
  
  # join xrd to all
  combine <- combine %>%
    full_join(XRD_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  # join xrd headers to all headers
  combine_headers <- combine_headers %>%
    left_join(XRD_boye_headers)
  
}

# ======================================= CN ===================================

CN_file <- analyte_files[grepl("CN", analyte_files)]
CN_file

if (length(CN_file) > 0) {
  
  # read in headers
  CN_boye_headers <- read_csv(CN_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  # read in data
  CN_data <- read_csv(CN_file, skip = 2, na = c(-9999, "N/A", "")) %>%
    select(-IGSN) %>%
    filter(!is.na(Sample_Name)) %>% # remove any NA samples
    mutate(Sample_Name = str_remove(Sample_Name, '-1'), # strip rep and data type info off sample names
           Sample_Name = str_remove(Sample_Name, '_CN'), 
           Sample_Name = str_remove(Sample_Name, '_ATP'), 
           Sample_Name = str_remove(Sample_Name, '_SCN'),
           Field_Name = NA_character_) %>% # convert #Start_Data and #End_Data to NA
    mutate_at(vars(`01395_C_percent_per_mg`, `01397_N_percent_per_mg`), 
              as.numeric) # convert percents columns to numeric str
  
  # create summary file for XRD data
  CN_summary <- CN_data %>%
    group_by(Sample_Name) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      across(where(is.numeric), mean, na.rm = T), # calculates mean of all percent cols; however since rep = 1, this is pulling the same single value as before
      Mean_Missing_Reps = NA
    )
  
  # join xrd to all
  combine <- combine %>%
    full_join(CN_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  # join xrd headers to all headers
  combine_headers <- combine_headers %>%
    left_join(CN_boye_headers)
  
}

# ======================================= GRN ==================================

GRN_file <- analyte_files[grepl("Grain", analyte_files)]
GRN_file

if (length(GRN_file) > 0) {
  GRN_boye_headers <- read_csv(GRN_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  GRN_data <- read_csv(GRN_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA, '')) %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '_GRN')
    )
  
  GRN_data <- GRN_data %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data')%>%
    mutate(Field_Name = 'N/A',
           `Percent_Fine_Sand` = as.numeric(`Percent_Fine_Sand`),
           `Percent_Med_Sand` = as.numeric(`Percent_Med_Sand`),
           `Percent_Coarse_Sand` = as.numeric(`Percent_Coarse_Sand`),
           `Percent_Tot_Sand` = as.numeric(`Percent_Tot_Sand`),
           `Percent_Clay` = as.numeric(`Percent_Clay`),
           `Percent_Silt` = as.numeric(`Percent_Silt`))
  
  GRN_summary <- GRN_data %>%
    group_by(Sample_Name) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Percent_Fine_Sand` = `Percent_Fine_Sand`,
      `Percent_Med_Sand` = `Percent_Med_Sand`,
      `Percent_Coarse_Sand` = `Percent_Coarse_Sand`,
      `Percent_Tot_Sand` = `Percent_Tot_Sand`,
      `Percent_Clay` = `Percent_Clay`,
      `Percent_Silt` = `Percent_Silt`,
      Mean_Missing_Reps = NA
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `Percent_Fine_Sand`,Percent_Med_Sand,
           Percent_Coarse_Sand,Percent_Tot_Sand, Percent_Clay, Percent_Silt, Mean_Missing_Reps)
  
  combine <- combine %>%
    full_join(GRN_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(GRN_boye_headers)
  
}
# ======================================= SFE ==================================

SFE_file <- analyte_files[grepl("Fe", analyte_files)]
SFE_file

if (length(SFE_file) > 0) {
  SFE_boye_headers <- read_csv(SFE_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  SFE_data <- read_csv(SFE_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999')) %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-2[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-3[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-4[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-5[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '-6[:alpha:]'),
      Sample_Name = str_remove(Sample_Name, '_SFE')
    )
  
  SFE_data <- SFE_data %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data')%>%
    mutate(Field_Name = 'N/A',
           `Fe_mg_per_kg` = as.numeric(`Fe_mg_per_kg`),
           `Fe_mg_per_L` = as.numeric(`Fe_mg_per_L`)) %>% 
    filter(!str_detect(Methods_Deviation, "SFE_001"))
  
  SFE_summary <- SFE_data %>%
    group_by(Sample_Name) %>%
    mutate(na_SFE = is.na(`Fe_mg_per_kg`)) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_Fe_mg_per_kg` = mean(`Fe_mg_per_kg`, na.rm = T),
      `Mean_Fe_mg_per_L` = mean(`Fe_mg_per_L`, na.rm = T),
      Mean_Missing_Reps = ifelse(TRUE %in% na_SFE, TRUE, FALSE),
      na_SFE = unique(na_SFE)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, Mean_Fe_mg_per_kg, 'Mean_Fe_mg_per_L', Mean_Missing_Reps) %>%
    distinct()
  
  combine <- combine %>%
    full_join(SFE_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(SFE_boye_headers)
  
}
# ==================================== norm resp ===============================

nresp_file <- analyte_files[grepl("Normalized", analyte_files)]
nresp_file

if (length(nresp_file) > 0) {
  nresp_boye_headers <- read_csv(nresp_file, n_max = 11, skip = 2)%>%
    select(-'Methods_Deviation', -IGSN)
  
  nresp_data <- read_csv(nresp_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA)) %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '-4'),
      Sample_Name = str_remove(Sample_Name, '-5'),
      Sample_Name = str_remove(Sample_Name, '-6'),
      Sample_Name = str_remove(Sample_Name, '_INC')
    )
  
  nresp_data <- nresp_data %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data')%>%
    mutate(Field_Name = 'N/A',
           Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment = as.numeric(Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment))
  
  nresp_summary <- nresp_data %>%
    group_by(Sample_Name) %>%
    mutate(count_nresp = sum(!is.na(Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      Mean_Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment = mean(Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment, na.rm = T),
      Mean_Missing_Reps = ifelse(count_nresp<3, TRUE, FALSE),
      count_nresp = unique(count_nresp)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, Mean_Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment, Mean_Missing_Reps)%>%
    distinct()
  
  combine <- combine %>%
    full_join(nresp_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(nresp_boye_headers)
  
}
# ==================================== resp ===============================

resp_file <- analyte_files[grepl("Respiration", analyte_files)]
resp_file <- resp_file[-grepl("Normalized", resp_file)]
resp_file

if (length(resp_file) > 0) {
  resp_boye_headers <- read_csv(resp_file, n_max = 11, skip = 2)%>%
    select("Field_Name","Sample_Name","Material","Respiration_Rate_mg_DO_per_L_per_H")
  
  resp_data <- read_csv(resp_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA)) %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '-4'),
      Sample_Name = str_remove(Sample_Name, '-5'),
      Sample_Name = str_remove(Sample_Name, '-6'),
      Sample_Name = str_remove(Sample_Name, '_INC')
    )
  
  resp_data <- resp_data %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data')%>%
    mutate(Field_Name = 'N/A',
           Respiration_Rate_mg_DO_per_L_per_H = as.numeric(Respiration_Rate_mg_DO_per_L_per_H))
  
  resp_summary <- resp_data %>%
    group_by(Sample_Name) %>%
    mutate(count_resp = sum(!is.na(Respiration_Rate_mg_DO_per_L_per_H))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      Mean_Respiration_Rate_mg_DO_per_L_per_H = mean(Respiration_Rate_mg_DO_per_L_per_H, na.rm = T),
      Mean_Missing_Reps = ifelse(count_resp<3, TRUE, FALSE),
      count_resp = unique(count_resp)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, Mean_Respiration_Rate_mg_DO_per_L_per_H, Mean_Missing_Reps) %>%
    distinct()
  
  
  combine <- combine %>%
    full_join(resp_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(resp_boye_headers)
  
}

# ==================================== SSA ===============================

SSA_file <- analyte_files[grepl("Specific_Surface_Area", analyte_files)]
SSA_file

if (length(SSA_file) > 0) {
  SSA_boye_headers <- read_csv(SSA_file, n_max = 11, skip = 2)%>%
    select("Field_Name","Sample_Name","Material","Specific_Surface_Area_m2_per_g")
  
  SSA_data <- read_csv(SSA_file, skip = 2, na = '-9999') %>%
    select(-IGSN) %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA)) %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '-4'),
      Sample_Name = str_remove(Sample_Name, '-5'),
      Sample_Name = str_remove(Sample_Name, '_MOI')
    )
  
  SSA_data <- SSA_data %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data')%>%
    mutate(Field_Name = 'N/A',
           Specific_Surface_Area_m2_per_g = as.numeric(Specific_Surface_Area_m2_per_g))
  
  SSA_summary <- SSA_data %>%
    group_by(Sample_Name) %>%
    mutate(count_SSA = sum(!is.na(Specific_Surface_Area_m2_per_g))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      Mean_Specific_Surface_Area_m2_per_g = mean(Specific_Surface_Area_m2_per_g, na.rm = T),
      Mean_Missing_Reps = ifelse(count_SSA<3, TRUE, FALSE),
      count_SSA = unique(count_SSA)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, Mean_Specific_Surface_Area_m2_per_g, Mean_Missing_Reps) %>%
    distinct()
  
  
  combine <- combine %>%
    full_join(SSA_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
    arrange(Sample_Name) %>%
    unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y, remove = T, na.rm = T)%>%
    mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
    filter(!is.na(Sample_Name))
  
  combine_headers <- combine_headers %>%
    left_join(SSA_boye_headers)
  
}


# ==================================== Format =================================

if(material == 'Water'){
  
  combine$Material <- 'Liquid>aqueous'
  
  combine <- combine %>%
    mutate(Sample_Name = str_c(Sample_Name, "_Water"))
  
} else{
  
  combine$Material <- material
  
  combine <- combine %>%
    mutate(Sample_Name = str_c(Sample_Name, "_", material))

}

combine$Field_Name[1] <- '#Start_Data'

combine <- combine %>%
  mutate_if(is.numeric, replace_na, replace = -9999)%>%
  mutate_if(is.character, replace_na, replace = 'N/A')%>%
  relocate(Mean_Missing_Reps, .after = last_col()) %>% 
  mutate_if(is.numeric, round, 3)

combine[nrow(combine)+1,1] = "#End_Data"


combine_headers <- combine_headers %>%
  add_column(Mean_Missing_Reps = 'N/A')

colnames(combine_headers) <- colnames(combine)

# =================================== Write File ===============================

columns <- length(combine)-1
  
header_rows <- length(combine_headers$Field_Name) + 1

top <- tibble('one' = as.character(),
              'two' = as.numeric()) %>%
  add_row(one = '#Columns',
          two = columns) %>%
  add_row(one = '#Header_Rows',
          two = header_rows)

# summary_out_file <- paste0(boye_dir, study_code, '_Summary_', Sys.Date(), '.csv') # this one is for when you files in the Share Point RC folders
summary_out_file <- paste0(dir, "/", study_code, "_", material,'_Sample_Data_Summary_', Sys.Date(), '.csv') # this is one is for when you have files in the Share Drive

write_csv(top, summary_out_file, col_names = F)

write_csv(combine_headers, summary_out_file, append = T, col_names = T)

write_csv(combine, summary_out_file, append = T, na = '')

shell.exec(dir)
