# ==============================================================================
#
# compare new temporal ions with old
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 28 March 2025
#
# ==============================================================================

library(tidyverse)

# =============================== User inputs ==================================

new <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Ions/03_ProcessedData/REPROCESSED_QAQCed_and_Dilution_Corrected_RC2_RC2.csv' %>%
  read_csv(na = c('NA', 'N/A', '-9999', ''))

old <- 'Z:/00_ESSDIVE/01_Study_DPs/RC2_TemporalStudy_2021-2022_SampleData_v3/v3_RC2_TemporalStudy_2021-2022_SampleData/RC2_Ions_2021-2022.csv' %>%
  read_csv(skip = 2, na = c('NA', 'N/A', '-9999', '')) %>%
  filter(!is.na(Sample_Name))

# =============================== merge and compare ==================================

merge <- new %>%
  full_join(old, by = c('Sample_ID' = 'Sample_Name')) %>%
  mutate(across(everything(), as.character)) %>%
  mutate(
    NH4 = case_when(
      is.na(Ammonium_mg_per_L) & is.na(`00000_NH4_mg_per_L_as_NH4`) ~ TRUE,
      Ammonium_mg_per_L == `00000_NH4_mg_per_L_as_NH4` ~ TRUE,
      TRUE ~ FALSE
    ),
    Br = case_when(
      is.na(Bromide_mg_per_L) & is.na(`71870_Br_mg_per_L`) ~ TRUE,
      Bromide_mg_per_L == `71870_Br_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    Ca = case_when(
      is.na(Calcium_mg_per_L) & is.na(`00915_Ca_mg_per_L`) ~ TRUE,
      Calcium_mg_per_L == `00915_Ca_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    Cl = case_when(
      is.na(Chloride_mg_per_L) & is.na(`00940_Cl_mg_per_L`) ~ TRUE,
      Chloride_mg_per_L == `00940_Cl_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    F = case_when(
      is.na(Fluoride_mg_per_L) & is.na(`00950_F_mg_per_L`) ~ TRUE,
      Fluoride_mg_per_L == `00950_F_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    Li = case_when(
      is.na(Lithium_mg_per_L) & is.na(`01130_Li_mg_per_L`) ~ TRUE,
      Lithium_mg_per_L == `01130_Li_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    Mg = case_when(
      is.na(Magnesium_mg_per_L) & is.na(`00925_Mg_mg_per_L`) ~ TRUE,
      Magnesium_mg_per_L == `00925_Mg_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    NO3 = case_when(
      is.na(Nitrate_mg_per_L) & is.na(`71851_NO3_mg_per_L_as_NO3`) ~ TRUE,
      Nitrate_mg_per_L == `71851_NO3_mg_per_L_as_NO3` ~ TRUE,
      TRUE ~ FALSE
    ),
    NO2 = case_when(
      is.na(Nitrite_mg_per_L) & is.na(`71856_NO2_mg_per_L_as_NO2`) ~ TRUE,
      Nitrite_mg_per_L == `71856_NO2_mg_per_L_as_NO2` ~ TRUE,
      TRUE ~ FALSE
    ),
    PO4 = case_when(
      is.na(Phosphate_mg_per_L) & is.na(`00653_PO4_mg_per_L_as_PO4`) ~ TRUE,
      Phosphate_mg_per_L == `00653_PO4_mg_per_L_as_PO4` ~ TRUE,
      TRUE ~ FALSE
    ),
    K = case_when(
      is.na(Potassium_mg_per_L) & is.na(`00935_K_mg_per_L`) ~ TRUE,
      Potassium_mg_per_L == `00935_K_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    Na = case_when(
      is.na(Sodium_mg_per_L) & is.na(`00930_Na_mg_per_L`) ~ TRUE,
      Sodium_mg_per_L == `00930_Na_mg_per_L` ~ TRUE,
      TRUE ~ FALSE
    ),
    SO4 = case_when(
      is.na(Sulfate_mg_per_L) & is.na(`00945_SO4_mg_per_L_as_SO4`) ~ TRUE,
      Sulfate_mg_per_L == `00945_SO4_mg_per_L_as_SO4` ~ TRUE,
      TRUE ~ FALSE
    )
  ) %>%
  select(Sample_ID,
         Ammonium_mg_per_L, `00000_NH4_mg_per_L_as_NH4`, NH4, 
         Bromide_mg_per_L, `71870_Br_mg_per_L`, Br,
         Calcium_mg_per_L, `00915_Ca_mg_per_L`, Ca,
         Chloride_mg_per_L, `00940_Cl_mg_per_L`, Cl,
         Fluoride_mg_per_L, `00950_F_mg_per_L`, F,
         Lithium_mg_per_L, `01130_Li_mg_per_L`, Li,
         Magnesium_mg_per_L, `00925_Mg_mg_per_L`, Mg,
         Nitrate_mg_per_L, `71851_NO3_mg_per_L_as_NO3`, NO3,
         Nitrite_mg_per_L, `71856_NO2_mg_per_L_as_NO2`, NO2,
         Phosphate_mg_per_L, `00653_PO4_mg_per_L_as_PO4`, PO4,
         Potassium_mg_per_L, `00935_K_mg_per_L`, K,
         Sodium_mg_per_L, `00930_Na_mg_per_L`, Na,
         Sulfate_mg_per_L, `00945_SO4_mg_per_L_as_SO4`, SO4, 
         everything())     

write_csv(merge, 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Ions/03_ProcessedData/REPROCESSED_ComparedToPublished.csv')
