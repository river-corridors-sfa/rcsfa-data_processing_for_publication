# ==============================================================================
#
# Format ICR data following the Boye et al. (2022) template. 
#
# Status: Incomplete; add console flag if method status is not done
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 10 April 2024
#
# ==============================================================================

library(tidyverse)
library(crayon)
library(readxl)
library(glue)

rm(list=ls(all=T))

# ================================= User inputs ================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/'

dp_outdir <- 'Z:/00_ESSDIVE/01_Study_DPs/CM_SSS_Data_Package_v5/v5_CM_SSS_Data_Package/Sample_Data/'

RC <- 'RC2'

study_code <- 'SSS'

material <- 'Sediment'

hub_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Hub-Typical-Codes-by-Study-Code.xlsx'
  
typical_codes_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Typical_Codes.xlsx'

# =============================== list files ===================================

material_fixed <- case_when(material == 'Sediment' ~ 'Sediment',
                      material == 'Water' ~ 'Liquid>aqueous')


analyte_code <- case_when(material == 'Sediment' ~ 'SED',
                            material == 'Water' ~ 'ICR')

combined_mapping <- list.files(paste0(dir, RC, '/FTICR/03_ProcessedData/', study_code, '_Data_Processed_FTICR'),'Mapping', full.names = T) %>%
  read_csv() %>%
  filter(str_detect(Sample_ID, analyte_code)) %>% # pull samples with correct analyte code for the material
  filter(is.na(Notes) | !str_detect(Notes, 'OMIT')) # remove samples that were rerun

if('FALSE' %in% combined_mapping$Method_Status | NA %in% combined_mapping$Method_Status){
  
  cat(
    red$bold(
      'Wait! Please check that \nMethods_Devation are completed.'
    )
  )
  
  user <-
    (readline(prompt = paste('Is it safe to continue? (Y/N)', sep = " ")
              
    ))
  
  if(user == 'N'){
    
    stop('Please finalize Methods Devations before proceeding.')
    
  }
}
  


icr_boye_file <- combined_mapping %>%
  select(Sample_ID, Method_Deviation)  %>%
  filter(!str_detect(Sample_ID, 'Blk')) %>%
  arrange(Sample_ID)%>%
  mutate(Field_Name = case_when(row_number() == 1 ~ '#Start_Data', 
                                TRUE ~ 'N/A'),
         Methods_Deviation = case_when(is.na(Method_Deviation) ~ 'N/A',
                                       TRUE ~ Method_Deviation)) %>%
  add_column(Material = material_fixed,
             'FTICR-MS' = 'See_FTICR_folder_for_data') %>%
  rename(Sample_Name = Sample_ID) %>%
  select(Field_Name, Sample_Name, Material, 'FTICR-MS', Methods_Deviation) %>%
  add_row(Field_Name = '#End_Data',
          Sample_Name = NA,
          Material = NA,
          'FTICR-MS' = NA,
          Methods_Deviation = NA )


    # ========================= build header rows ==============================
hub <- read_excel(hub_dir)    

boye_file_headers <- tibble(
      'Field_Name' = c('Unit', 'Unit_Basis', 'MethodID_Analysis', 'MethodID_Inspection',
                       'MethodID_Storage', 'MethodID_Preservation', 'MethodID_Preparation', 
                       'MethodID_DataProcessing', 'Analysis_DetectionLimit', 
                       'Analysis_Precision', 'Data_Status'),
      'Sample_Name' = c('N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 
                        '-9999', '-9999', 'N/A'),
      'Material' = c('N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 
                     '-9999', '-9999', 'N/A')
    ) 
    
   analyte <- 'ICR'
      
      filter_hub <- hub %>%
        filter(RC == RC,
               Study_Code == study_code,
               Data_Package_Unit == material)
      
      typical_code_number <-  filter_hub %>%
        select(contains(analyte)) %>%
        pull(1)
      
      typical_codes <- read_excel(typical_codes_dir, sheet = paste0(analyte,"_Typical"))
      
      order <- c('MethodID_Analysis', 'MethodID_Inspection',
                 'MethodID_Storage', 'MethodID_Preservation',
                 'MethodID_Preparation', 'MethodID_DataProcessing')

      column_typical_codes <- typical_codes %>%
        filter(str_detect(Method_ID, typical_code_number)) %>%
        slice(match(order, Method_Type))%>%
        select(Method_ID)%>%
        pull(n = 1)


      unit <- 'N/A'

      unit_basis <- 'N/A'
      
      data_status <- 'raw'


      boye_file_headers <- boye_file_headers %>%
        add_column('FTICR-MS'= c(unit, unit_basis, column_typical_codes, '-9999', '-9999', data_status),
                   'Methods_Deviation' = 'N/A')

      # ========================= build top rows ==============================
    
    columns <- length(icr_boye_file) - 1
    
    header_rows <- length(boye_file_headers$Field_Name) + 1
    
    top <- tibble('one' = as.character(),
                  'two' = as.numeric()) %>%
      add_row(one = '#Columns',
              two = columns) %>%
      add_row(one = '#Header_Rows',
              two = header_rows)
    
    # =================================== Write File ===============================
    
    out_name <- glue('{dp_outdir}{study_code}_{material}_FTICR_Methods_{Sys.Date()}.csv' )

    write_csv(top, out_name, col_names = F)

    write_csv(boye_file_headers, out_name, append = T, col_names = T)

    write_csv(icr_boye_file, out_name, append = T, na = '')

  
    
  