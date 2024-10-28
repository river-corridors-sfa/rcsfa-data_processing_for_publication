# ==============================================================================
#
# Format NMR data to match published 13C NMR data formatting
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 31 August 2023
#
# ==============================================================================

library(tidyverse)
library(fs)
library(tools)

rm(list=ls(all=T))

# the commented lines below were to include the first version on NMR. Below that 
# formats the second version to go into BSLE v4

# # ================================= User inputs ================================
# 
# dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v3/Review/NMR_Samples'
# 
# outdir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v3/BSLE_Data_Package_v3/BSLE_Data_v3/'
# 
# # ================================= list files ================================
# 
# files <- list.files(dir, 'solid', full.names = T, recursive = T)
# 
# solid_files <- files[!grepl('spiking',files)]
# 
# spiked_files <- files[grepl('spiking',files)]
# 
# combine <- tibble(Chemical_Shift_parts_per_million = as.numeric())
# 
# combine_spiked <- tibble(Chemical_Shift_parts_per_million = as.numeric())
# 
# # =================== loop through regular samples ============================
# 
# for (solid in solid_files) {
# 
#   data <- read_tsv(solid, col_names = F) %>%
#     select(-X3) %>%
#     rename(Chemical_Shift_parts_per_million = X1)
# 
#   sample_name <- solid %>%
#     path_file() %>%
#     file_path_sans_ext() %>%
#     str_replace('_solid', '-solid')
# 
#   data <- data %>%
#     rename(!!sample_name := X2)
# 
#   combine <- combine %>%
#     full_join(data)
# 
#   rm(data)
# 
# }
# 
# 
# # =================== loop through spiked samples ============================
# 
# for (spiked in spiked_files) {
# 
#   data <- read_csv(spiked) %>%
#     rename(Chemical_Shift_parts_per_million = 1) %>%
#     select(-2)
# 
#   colnames <- colnames(data) %>%
#   str_replace_all('(?<=#).?', "") %>%
#   str_replace_all('#', "") %>%
#   str_replace_all('_solid', '-solid') %>%
#   str_replace_all('_aGP', '_alphaGP') %>%
#   str_replace_all('_alpha_', '_alphaGP_') %>%
#   str_replace_all('_beta_', '_betaGP_') %>%
#   str_replace_all('_bGP', '_betaGP') %>%
#   str_replace_all('_secondrun', '')
# 
#   colnames(data) <- colnames
# 
#   combine_spiked <- combine_spiked %>%
#     full_join(data)
# 
# }
# 
# combine_spiked <- combine_spiked %>%
#   select(-'BSLE_0073-solid') %>%
#   rename('BSLE_0002-solid_alphaGP_betaGP' = 'BSLE_0002-solid_alphaGP_beta',
#          'BSLE_0011-solid_alphaGP_RNA_g6P_betaGP' = 'BSLE_0011-solid_alphaGP_RNA_g6P_beta',
#          'BSLE_0051-solid_alphaGP_betaGP' = 'BSLE_0051-solid_alphaGP_beta',
#          'BSLE_0013-solid_RNA_alphaGP_betaGP' = 'BSLE_0013-solid_RNA_alphaGP_beta')
# 
# # ========================== combine samples ===================================
# 
# 
# format_combine <- combine %>%
#   full_join(combine_spiked) %>%
#   arrange(Chemical_Shift_parts_per_million) %>%
#   mutate(across(everything(), ~replace_na(.x, 0)))
# 
# outname <- paste0(outdir, 'BSLE_P-NMR.csv')
# 
# write_csv(format_combine, outname)
# ================================= User inputs ================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v4/Review/NMR_Samples'

v3_nmr <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v4/v4_BSLE_Data_Package/v4_BSLE_Data/BSLE_31P-NMR.csv'

outdir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC3/05_Editable_ESS-DIVE_Format/BSLE_Data_Package_v4/v4_BSLE_Data_Package/v4_BSLE_Data/'

# ================================= list files ================================

files <- list.files(dir,full.names = T, recursive = T)

solid_files <- files[!grepl('spiking|spiked',files)]

spiked_files <- files[grepl('spiking|spiked',files)]

combine <- tibble(Chemical_Shift_parts_per_million = as.numeric())

combine_spiked <- tibble(Chemical_Shift_parts_per_million = as.numeric())

# =================== loop through regular samples ============================

for (solid in solid_files) {
  
  data <- read_tsv(solid, col_names = F) %>%
    select(-X3) %>%
    rename(Chemical_Shift_parts_per_million = X1)
  
  sample_name <- solid %>%
    path_file() %>%
    file_path_sans_ext() %>%
    str_replace('_solid', '-solid') %>%
    str_replace('_filt', '-filt')
  
  data <- data %>%
    rename(!!sample_name := X2)
  
  combine <- combine %>%
    full_join(data)
  
  rm(data)
  
}


# =================== loop through spiked samples ============================

for (spiked in spiked_files) {
  
  data <- read_csv(spiked) %>%
    rename(Chemical_Shift_parts_per_million = 1) %>%
    select(-2)
  
  if(str_detect(colnames(data)[2], 'BSLE_0051')){
    
    data <- data %>%
      select(-contains('#5'))
    
  }
  
  colnames <- colnames(data) %>%
    str_replace_all('(?<=#).?', "") %>%
    str_replace_all('#', "") %>%
    str_replace_all('_solid', '-solid')  %>%
    str_replace('_filt', '-filt') %>%
    str_replace('_07_leachate', '-filt0.7')%>%
    str_replace('_2xDil', '')%>%
    str_replace('_16h', '')%>%
    str_replace('_16hr', '')%>%
    str_replace('_fid', '')%>%
    str_replace('fid', '')%>%
    str_replace('_redo2', '') %>%
    str_replace('_complete16h', '') %>%
    str_replace('_2xdilute', '') %>%
    str_replace('_2400nt', '') %>%
    str_replace_all('_aGP', '_alphaGP') %>%
    str_replace_all('_a-gp', '_alphaGP') %>%
    str_replace_all('_aGP', '_alphaGP') %>%
    str_replace_all('_alpha_', '_alphaGP_') %>%
    str_replace_all('_beta_', '_betaGP_') %>%
    str_replace_all('_bGP', '_betaGP') %>%
    str_replace_all('-bGP', '_betaGP') %>%
    str_replace_all('_b-gp', '_betaGP') %>%
    str_replace_all('_b-GP', '_betaGP') %>%
    str_replace_all('_secondrun', '')%>%
    str_replace_all('RNA.', 'RNA')%>%
    str_replace_all('RNAbeta', 'RNA_beta')%>%
    str_replace_all('G1P', 'g1p')%>%
    str_replace_all('G6P', 'g6p')%>%
    str_replace_all('RNAg6P', 'RNA_g6p')%>%
    str_replace_all('RNAPhytate', 'RNA_phytate')%>%
    str_replace_all('RNAphytate', 'RNA_phytate')%>%
    str_replace_all('RNAbeta', 'RNA_beta')%>%
    str_replace_all('RNAphos', 'RNA_phos')
  
  colnames(data) <- colnames
  
  combine_spiked <- combine_spiked %>%
    full_join(data)
  
}

combine_spiked <- combine_spiked %>%
  select(-contains('7600nt_24hr_comp')) %>%
  select(-contains('full_relax')) %>%
  rename('BSLE_0017-filt0.7_alphaGP_RNA_betaGP' = 'BSLE_0017-filt0.7_alphaGP_RNA_beta',
         'BSLE_0009-filt0.7_g1P_g6P_betaGP' = 'BSLE_0009-filt0.7_g1P_g6P_beta')

# ========================== combine samples ===================================

format_combine <- combine %>%
  full_join(combine_spiked) %>%
  arrange(Chemical_Shift_parts_per_million) %>%
  mutate(across(everything(), ~replace_na(.x, 0)))

# =============== combine with previously published ============================

v3 <- read_csv(v3_nmr)

full_combine <- v3 %>%
  full_join(format_combine) %>%
  arrange(Chemical_Shift_parts_per_million) %>%
  mutate(across(everything(), ~replace_na(.x, 0)))


outname <- paste0(outdir, 'v2_BSLE_P-NMR.csv')

write_csv(full_combine, outname)















