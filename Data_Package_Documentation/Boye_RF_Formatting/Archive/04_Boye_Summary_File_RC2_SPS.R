# ==============================================================================
#
# Make a summary file of means for each analyte file going into a data package
#
# Status: In progress
#
# Notes: 
# 
# ==============================================================================
#
# Author: Brieanne Forbes, brieanne.forbes@pnnl.gov
# 30 Sept 2022
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

analyte_files_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/BoyeFiles_byStudyCode/RC2/2022-11-1'

combined_qaqc_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/BoyeFiles_byStudyCode/RC2/2022-11-1'

summary_out_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/BoyeFiles_byStudyCode/RC2/2022-11-1/RC2_NPOC_TN_DIC_TSS_Ions_Summary_2022-11-02.csv'

# ================================= Wrangle data and summarize =================

analyte_files <- list.files(analyte_files_dir, 'Template', full.names = T)

qaqc_files <- list.files(combined_qaqc_dir, 'CombinedQAQC', full.names = T)
  
# ======================================= DIC ==================================
  
DIC_file <- analyte_files[grepl("DIC", analyte_files)]

if (length(DIC_file) > 0) {
  DIC_boye_headers <- read_csv(DIC_file, n_ma = 11, skip = 2, na = '-9999')%>%
    select(-'Methods_Deviation')
  
  DIC_qaqc <- qaqc_files[grepl("DIC", qaqc_files)] %>%
    read_csv() %>%
    filter(DIC_Outlier == T)
  
  DIC_data <- read_csv(DIC_file, skip = 2, na = '-9999') %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(
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
  
}

# ======================================= Ions ==================================

Ion_file <- analyte_files[grepl("Ions", analyte_files)]

if (length(Ion_file) > 0) {
  Ion_boye_headers <- read_csv(Ion_file, n_ma = 11, skip = 2, na = '-9999')%>%
    select(-'Methods_Deviation')
  
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
  
  Ion_data <- read_csv(Ion_file, skip = 2, na = '-9999') %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(`00000_NH4_mg_per_L_as_NH4` = ifelse(Sample_Name %in% NH4_qaqc$Sample_ID, NA, as.numeric(`00000_NH4_mg_per_L_as_NH4`)),
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
      Sample_Name = str_remove(Sample_Name, '_ION')
    )
  
  Ion_summary <- Ion_data %>%
    group_by(Sample_Name) %>%
    mutate(count_NH4 = sum(!is.na(`00000_NH4_mg_per_L_as_NH4`)),
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
      `Mean_00000_NH4_mg_per_L_as_NH4` = mean(`00000_NH4_mg_per_L_as_NH4`, na.rm = T),
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
    select(
      Field_Name,
      Sample_Name,
      Material,
      `Mean_00000_NH4_mg_per_L_as_NH4`,
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
    distinct()
  
}

# ====================================== NPOC-TN =================================

NPOC_TN_file <- analyte_files[grepl("NPOC_TN", analyte_files)]

if (length(NPOC_TN_file) > 0) {
  NPOC_TN_boye_headers <- read_csv(NPOC_TN_file, n_ma = 11, skip = 2, na = '-9999')%>%
    select(-'Methods_Deviation')
  
  NPOC_TN_NPOC_qaqc <- qaqc_files[grepl("NPOC_TN", qaqc_files)] %>%
    read_csv() %>%
    filter(NPOC_Outlier == T)
  
  NPOC_TN_TN_qaqc <- qaqc_files[grepl("NPOC_TN", qaqc_files)] %>%
    read_csv() %>%
    filter(TN_Outlier == T)
  
  NPOC_TN_data <- read_csv(NPOC_TN_file, skip = 2, na = '-9999') %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(`00681_NPOC_mg_per_L_as_C` = ifelse(Sample_Name %in% NPOC_TN_NPOC_qaqc$Sample_ID, NA, as.numeric(`00681_NPOC_mg_per_L_as_C`)),
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
  
}

# ====================================== NPOC =================================

NPOC_file <- analyte_files[grepl("NPOC", analyte_files)]

if (length(NPOC_file) > 0) {
  NPOC_boye_headers <- read_csv(NPOC_file, n_ma = 11, skip = 2)%>%
    select(-'Methods_Deviation')
  
  NPOC_NPOC_qaqc <- qaqc_files[grepl("NPOC", qaqc_files)] %>%
    read_csv() %>%
    filter(NPOC_Outlier == T)
  
  NPOC_data <- read_csv(NPOC_file, skip = 2, na = '-9999') %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(`00681_NPOC_mg_per_L_as_C` = ifelse(Sample_Name %in% NPOC_NPOC_qaqc$Sample_ID, NA, as.numeric(`00681_NPOC_mg_per_L_as_C`)),
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
  
}

# ====================================== TN =================================

TN_file <- analyte_files[grepl("TN", analyte_files)]

if (length(TN_file) > 0) {
  TN_boye_headers <- read_csv(TN_file, n_ma = 11, skip = 2)%>%
    select(-'Methods_Deviation')
  
  TN_TN_qaqc <- qaqc_files[grepl("TN", qaqc_files)] %>%
    read_csv() %>%
    filter(TN_Outlier == T)
  
  TN_data <- read_csv(TN_file, skip = 2, na = '-9999') %>%
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


# ======================================= TSS ==================================

TSS_file <- analyte_files[grepl("TSS", analyte_files)]

if (length(TSS_file) > 0) {
  TSS_boye_headers <- read_csv(TSS_file, n_ma = 11, skip = 2)%>%
    select(-'Methods_Deviation')

  TSS_data <- read_csv(TSS_file, skip = 2, na = '-9999') %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(
      Sample_Name = str_remove(Sample_Name, '-1'),
      Sample_Name = str_remove(Sample_Name, '-2'),
      Sample_Name = str_remove(Sample_Name, '-3'),
      Sample_Name = str_remove(Sample_Name, '_TSS')
    )
  
  TSS_data <- TSS_data %>%
    mutate(`00530_TSS_mg_per_L` = as.numeric(`00530_TSS_mg_per_L`))
  
  TSS_summary <- TSS_data %>%
    group_by(Sample_Name) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      `Mean_00530_TSS_mg_per_L` = mean(`00530_TSS_mg_per_L`, na.rm = T),
      Mean_Missing_Reps = NA
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, `Mean_00530_TSS_mg_per_L`, Mean_Missing_Reps)
  
}
# ==================================== Combine =================================

combine <- DIC_summary %>%
  full_join(Ion_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
  # full_join(NPOC_TN_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
  full_join(NPOC_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
  full_join(TN_summary, by = c("Field_Name", "Sample_Name", "Material")) %>%
  full_join(TSS_summary, by = c("Field_Name", "Sample_Name", "Material"))%>%
  arrange(Sample_Name) %>%
  unite(Mean_Missing_Reps, Mean_Missing_Reps.x, Mean_Missing_Reps.y,Mean_Missing_Reps.y.y, Mean_Missing_Reps.x.x,remove = T, na.rm = T)%>%
  mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
  filter(!is.na(Sample_Name))

# combine <- NPOC_summary %>%
#   arrange(Sample_Name) %>%
#   mutate(Mean_Missing_Reps = ifelse(str_detect(Mean_Missing_Reps, 'TRUE'), TRUE, FALSE))%>%
#   filter(!is.na(Sample_Name))

combine$Material <- 'Liquid>aqueous'

combine$Field_Name[1] <- '#Start_Data'

combine <- combine %>%
  mutate_if(is.numeric, replace_na, replace = -9999)%>%
  mutate_if(is.character, replace_na, replace = 'N/A')%>%
  relocate(Mean_Missing_Reps, .after = last_col())%>%
  mutate_if(is.numeric, round, 2)

combine[nrow(combine)+1,1] = "#End_Data"

# colnames(combine) <- gsub("X", "", colnames(combine), fixed = TRUE)

combine_headers <- DIC_boye_headers %>%
  left_join(Ion_boye_headers) %>%
  # left_join(NPOC_TN_boye_headers) %>%
  left_join(NPOC_boye_headers) %>%
  left_join(TN_boye_headers) %>%
  left_join(TSS_boye_headers)%>%
  add_column(Mean_Missing_Reps = 'N/A')%>% 
  rename_with(~paste0('Mean_',.), matches('^\\d+'))

# combine_headers <- NPOC_boye_headers %>%
#   add_column(Mean_Missing_Reps = 'N/A')%>%
#   rename_with(~paste0('Mean_',.), matches('^\\d+'))



# =================================== Write File ===============================

columns <- length(combine)-1
  
header_rows <- length(combine_headers$Field_Name) + 1

top <- tibble('one' = as.character(),
              'two' = as.numeric()) %>%
  add_row(one = '#Columns',
          two = columns) %>%
  add_row(one = '#Header_Rows',
          two = header_rows)

write_csv(top, summary_out_dir, col_names = F)

write_csv(combine_headers, summary_out_dir, append = T, col_names = T)

write_csv(combine, summary_out_dir, append = T, na = '')

