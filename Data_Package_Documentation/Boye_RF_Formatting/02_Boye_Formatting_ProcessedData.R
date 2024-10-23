# ==============================================================================
#
# Format processed data following the Boye et al. (2022) template. 
#
# Status: need to add analytes to line 127 as needed
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 3 April 2023
#
# ==============================================================================

library(tidyverse)
library(crayon)
library(readxl)
library(glue)

rm(list=ls(all=T))

# ================================= User inputs ================================

boye_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC4/CN/03_ProcessedData/'

RC <- 'RC4'

study_code <- 'AV1'

material <- 'Sediment'

outdir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC4/Boye_Files/AV1/'

hub_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Hub-Typical-Codes-by-Study-Code.xlsx'

typical_codes_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Typical_Codes.xlsx'

colnames_lookup_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Template_for_code/Boye_Template_Input.csv'

LOD_file_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Raw_Instrument_Data/Special_LODs.xlsx'

# =============================== red LOD file =================================

LOD_data <- read_xlsx(LOD_file_dir, skip = 1) %>%
  filter(Study_Code == study_code)

# =============================== list files ===================================

files <- list.files(boye_dir, 'ReadyForBoye', full.names = T)

hub <- read_excel(hub_dir)

colnames_lookup <- read_csv(colnames_lookup_dir, skip = 1)


for (file in files) {
  
  data <- read_csv(file)
  
  data_type <- unlist(str_split(basename(file), '_'))[2]
  
  if(data_type == 'SFE'){
    
    data_type <- 'Fe'
    
  } else if (str_detect(file, 'NPOC_TN') == TRUE){
    
    data_type <- 'NPOC_TN'
  } else if  (str_detect(file, 'ICP_PNMR') == TRUE){
    
    data_type <- 'ICP_PNMR'
  }  else if  (str_detect(file, 'ICP_Solid') == TRUE){
    
    data_type <- 'ICP_Solid'
  } 
    
  data_columns <- data %>%
    select(-Sample_Name,-Methods_Deviation) %>%
    colnames()
  
  #remove material and flag from data columns, works if the column isnt in the data frame
  data_columns <- data_columns[ !grepl('Material',data_columns)]
  data_columns <- data_columns[ !grepl('flag',data_columns)]
  
  # ========================= get typical codes ==============================
  
  filter_hub <- hub %>%
    filter(RC == RC,
           Study_Code == study_code,
           Data_Package_Unit == material)
  
  # ========================= build header rows ==============================
  boye_file_headers <- tibble(
    'Field_Name' = c(
      'Unit',
      'Unit_Basis',
      'MethodID_Analysis',
      'MethodID_Inspection',
      'MethodID_Storage',
      'MethodID_Preservation',
      'MethodID_Preparation',
      'MethodID_DataProcessing',
      'Analysis_DetectionLimit',
      'Analysis_Precision',
      'Data_Status'
    ),
    'Sample_Name' = c(
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      '-9999',
      '-9999',
      'N/A'
    ),
    'Material' = c(
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      'N/A',
      '-9999',
      '-9999',
      'N/A'
    )
  )

  
  for (column in data_columns) {
    
    analyte <-
      if (str_detect(column, 'NPOC')) {
        'NPOC'
      } else if (str_detect(column, 'TN')) {
        'TN'
      } else if (str_detect(column, 'TSS')) {
        'TSS'
      } else if (str_detect(column, 'SpC')) {
        'SpC'
      } else if (str_detect(column, 'Temp')) {
        'Temp'
      } else if (str_detect(column, 'pH')) {
        'pH'
      } else if (str_detect(data_type, 'MOI')) {
        'MOI'
      } else{
        data_type
      }
    
    # ======================== fix column headers ==============================
    
    colnames_lookup_filter <- colnames_lookup %>%
      dplyr::filter(col.in == column)
    
    new_name <- colnames_lookup_filter$col.out
    
    data <- data %>%
      dplyr::rename(!!new_name := all_of(column))
    
    # if (is.null(analyte)){
    #   
    #   boye_file_headers <- boye_file_headers %>%
    #     add_column(
    #       !!column := c(
    #         'N/A',
    #         'N/A',
    #         'N/A',
    #         'N/A',
    #         'N/A',
    #         'N/A',
    #         'N/A',
    #         'N/A',
    #         '-9999',
    #         '-9999',
    #         'N/A'
    #       )
    #     )
    #   
    # }else{

    typical_code_number <-  filter_hub %>%
      select(contains(analyte)) %>%
      pull(1)
    
    typical_codes <-
      read_excel(typical_codes_dir, sheet = paste0(analyte, "_Typical"))
    
     order <- c(
      'MethodID_Analysis',
      'MethodID_Inspection',
      'MethodID_Storage',
      'MethodID_Preservation',
      'MethodID_Preparation',
      'MethodID_DataProcessing'
    )
    
    column_typical_codes <- typical_codes %>%
      filter(str_detect(Method_ID, typical_code_number)) %>%
      slice(match(order, Method_Type)) %>%
      select(Method_ID) %>%
      pull()
    
    unit <- colnames_lookup_filter %>%
      filter(col.in == column) %>%
      select(Unit) %>%
      pull(n = 1)
    
    unit_basis <- colnames_lookup_filter %>%
      filter(col.in == column) %>%
      select(Unit_Basis) %>%
      pull(n = 1)
    
    data_status <- colnames_lookup_filter %>%
      filter(col.in == column) %>%
      select(Data_Status) %>%
      pull(n = 1)
    
    
    boye_file_headers <- boye_file_headers %>%
      add_column(
        !!column := c(
          unit,
          unit_basis,
          column_typical_codes,
          '-9999',
          '-9999',
          data_status
        )
      )
    
    if("Methods_Deviation" %in% colnames(boye_file_headers)){
      
      boye_file_headers <- boye_file_headers %>%
        relocate(Methods_Deviation, .after = last_col())
      
      
    } else {
      
      boye_file_headers <- boye_file_headers %>%
        add_column('Methods_Deviation' = 'N/A')
  
    }
    
    boye_file_headers <- boye_file_headers %>%
      dplyr::rename(!!new_name := all_of(column))
  
  #=============================== get LOD ==================================
  
  LOD <- LOD_data %>% 
    filter(Column_Header == new_name) %>%
      distinct()
  
  LOD_min <- LOD %>%
    select(LOD_min) %>%
    pull()
  
  LOD_max <- LOD %>%
    select(LOD_max) %>%
    pull()
  
  
  if(LOD_min == LOD_max){
    
    LOD_final = LOD_max
    
  } else{
    
    LOD_final = paste0(LOD_min,"-",LOD_max)
  }
  
    
  
  boye_file_headers <- boye_file_headers %>%
    assign_in(list(new_name, 9), LOD_final)

    
    rm(analyte) 
    rm(column_typical_codes)
    rm(unit)
    rm(unit_basis)
    rm(data_status)

    
  }
    
    # ========================== finish formatting =============================
    
  if(!"Material" %in% colnames(data)){
    
    if (material == 'Water'){
      
      data <- data %>%
        add_column(Material = 'Liquid>aqueous', .after = 'Sample_Name')
      
    } else {
      
      data <- data %>%
        add_column(Material = material, .after = 'Sample_Name')
      
    }
    
  }
    

    data <- data %>%
      add_column(Field_Name = 'N/A', .before = 'Sample_Name')%>%
      dplyr::mutate(across(everything(), as.character))%>%
      dplyr::mutate(across(contains('X'), replace_na, replace = '-9999'))%>%
      dplyr::mutate(across(!contains('X'), replace_na, replace = 'N/A'))%>%
      arrange(Sample_Name)
    
    data$Field_Name[1] <- '#Start_Data'
    
    colnames(data) <- gsub('X', '', colnames(data))
    
    colnames(boye_file_headers) <- gsub('X', '', colnames(boye_file_headers))
    
    data[nrow(data)+1,1] = "#End_Data"
    
    
    columns <- length(data)-1
    
    header_rows <- length(boye_file_headers$Field_Name) + 1
    
    top <- tibble('one' = as.character(),
                  'two' = as.numeric()) %>%
      add_row(one = '#Columns',
              two = columns) %>%
      add_row(one = '#Header_Rows',
              two = header_rows)
    
    # =================================== Write File ===============================
    
    out_name <- glue('{outdir}{study_code}_{data_type}_Boye_{Sys.Date()}.csv' )
    
    write_csv(top, out_name, col_names = F)
    
    write_csv(boye_file_headers, out_name, append = T, col_names = T)
    
    write_csv(data, out_name, append = T, na = '')
    
  }

