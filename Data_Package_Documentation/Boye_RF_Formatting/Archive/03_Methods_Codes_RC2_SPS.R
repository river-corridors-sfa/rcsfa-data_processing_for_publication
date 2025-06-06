# ==============================================================================
#
# Get methods codes from boye files 
#
# Status: In Progress
#
# Notes: might want to combine this with previous script
#
# ==============================================================================
#
# Author: James Stegen, Vanessa Garayburu-Caruso, and Brieanne Forbes (WHONDRS)
# 24 October 2022
#
# ==============================================================================

library(tidyverse)
library(readxl)

rm(list=ls(all=T))

# ================================= User inputs ================================

boye_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/BoyeFiles_byStudyCode/RC2/2022-11-1/'

study_code <- 'RC2'

typical_codes <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Typical_Codes.xlsx'
  
deviation_codes <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Deviation_Codes.xlsx'

# ======================== get files and make methods file =====================

boye_files <- list.files(boye_dir, 'Template', full.names = T)

deviations_combine <- tibble(Methods_Deviations = as.character())

typical_combine <- tibble(Typical = as.character())

for (boye_file in boye_files) {
  
  
  data <- read_csv(boye_file, skip = 2, na = c('N/A', 'NA'))
  
  data_columns <- data %>%
    select(-Field_Name, -Sample_Name, -Material, -Methods_Deviation) %>%
    colnames()
  
  for (column in data_columns) {
    
    typical <- data %>%
      select(one_of(column))%>%
      slice(c(3:8, 11))%>%
      pull()
    
    typical_combine <-  typical_combine %>%
      add_row(Typical = typical)
    
    deviations <- data %>%
      select(Methods_Deviation)%>%
      filter(Methods_Deviation != '',
             Methods_Deviation != 'NA',
             Methods_Deviation != 'N/A',
             !is.na(Methods_Deviation))%>%
      mutate(Methods_Deviation = str_replace(Methods_Deviation,',', ';'))%>%
      pull() %>%
      paste(collapse = '; ')
    
    unique_deviations <- unlist(str_split(deviations, ';'))%>%
      unique()
    
    deviations_combine <- deviations_combine %>%
      add_row(Methods_Deviations = unique_deviations)
      
    
  }
  
}

# ================================ get unique codes ============================

deviations_combine$Methods_Deviations <- gsub(' ', '', deviations_combine$Methods_Deviations)
# deviations <- gsub(' ', '', deviations)
# deviations <- gsub(';;', ';', deviations)

deviations_combine <- deviations_combine %>%
  filter(Methods_Deviations != 'NA',
         Methods_Deviations != '') %>%
  unique()

typical_combine <-typical_combine %>%
  filter(Typical != 'NA',
         Typical != '')%>%
  unique()


# =========================== combine methods sheets ===========================

typical_sheets <- excel_sheets(typical_codes) 

typical_sheets <- typical_sheets[ !grepl('readme',typical_sheets)]

all_typical <- map_df(typical_sheets, ~read_excel(typical_codes, sheet = .x))


deviation_sheets <- excel_sheets(deviation_codes) 

deviation_sheets <- deviation_sheets[ !grepl('readme',deviation_sheets)]

all_deviation <- map_df(deviation_sheets, ~read_excel(deviation_codes, sheet = .x))

# ================== filter codes to data set and combine ======================

typical_filter <- all_typical %>%
  filter(Method_ID %in% typical_combine$Typical) %>%
  select(contains('Method_'))

deviation_filter <- all_deviation %>%
  filter(Method_ID %in% deviations_combine$Methods_Deviations)%>%
  select(contains('Method_'))

methods <- typical_filter %>%
  add_row(deviation_filter)%>%
  arrange(Method_Name)

# ================================== write file ================================

write_excel_csv(methods, paste0(boye_dir, study_code, '_Methods_Codes.csv' ))


