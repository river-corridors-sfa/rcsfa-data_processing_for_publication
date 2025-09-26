# ==============================================================================
#
# Format data following the Boye et al. (2022) template. 
#
# Status: Complete
#
#
# known issue: does not properly name NPOC_TN and only pulls one typical code number 
# even if file has multiple data types
#
# ==============================================================================
#
# Author: James Stegen, Vanessa Garayburu-Caruso, and Brieanne Forbes (WHONDRS)
# 12 October 2022
#
# ==============================================================================

library(tidyverse)
library(crayon)
library(readxl)
library(glue)

rm(list=ls(all=T))

# ================================= User inputs ================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Documents - RC-SFA/Study_TAP/NPOC_TN'

study_code <- 'TAP'
  
material <- 'Water'

hub_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Hub-Typical-Codes-by-Study-Code.xlsx'
  
typical_codes_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Method_Typical_Codes.xlsx'

colnames_lookup_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Workflows-MethodsCodes/RC-SFA_ColumnHeader_Lookup.csv'

# uncomment if data was run at EMSL
# LOD_file_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Raw_Instrument_Data/NPOC-TN Shimadzu EMSL/Limit_of_detection_calculations/TOC_EMSL_LOD.xlsx'

#uncomment if data was run at MCRL
# LOD_file_dir <-'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Raw_Instrument_Data/NPOC-TN Shimadzu MCRL/Limit_of_detection_calculations/TOC_MCRL_LOD.xlsx'

#uncomment if data was run at BSF
LOD_file_dir <-'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Raw_Instrument_Data/NPOC-TN Shimadzu BSF/Limit_of_detection_calculations/TOC_BSF_LOD.xlsx'
 
 #uncomment if ions were run at EMSL and update file name
ion_LOD_file <-  'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Raw_Instrument_Data/IC-6000 EMSL/Limit_of_detection_calculations/20230915_LOD_RC2_SSS_1-144.csv'

# tss_LOD_file <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Raw_Instrument_Data/TSS BSF/Limit_of_detection_calculations/TSS_BSF_LOD.xlsx'


# =============================== list files ===================================

files <- list.files(dir, 'Check_for_Duplicates', full.names = T, recursive = T)

hub <- read_excel(hub_dir)

colnames_lookup <- read_csv(colnames_lookup_dir, skip = 1) %>%
  filter(Material == material)


for (file in files) {
  
  data <- read_csv(file)
  
  if('Randomized_ID' %in% colnames(data)){
    
    data <- data %>%
      select(-Randomized_ID)
    
  }
  
  if('Dilution_Factor' %in% colnames(data)){
    
    data <- data %>%
      select(-Dilution_Factor)
    
  }
  
  if('TRUE' %in% data$duplicate){
    
    cat(
      red$bold(
        'Wait! You have duplicates in your data.\n',
        'You will need to remove your duplicates \n',
        'before you are able to proceed\n'
      )
    )
    
  } else{
    
    data <- data %>%
      select(-Date_of_Run, -Method_Notes, -duplicate, -Randomized_ID)
    
    data_type <- unlist(str_split(file, '/'))[7]
    
    if(data_type == 'NPOC' & str_detect(file, 'NPOC_TN')){
      
      data_type <- 'NPOC_TN'
    }
    
    data_columns <- data %>%
      select(-Sample_ID, -Methods_Deviation)%>%
      colnames()


    # ========================= build header rows ==============================
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
    
    for (column in data_columns) {
      
     if(data_type == 'Ions'){
       
       analyte <- 'Ions'
       
     } else {
      
       analyte <- unlist(str_split(column, '_'))[1]
       
     }
      
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


      unit <- colnames_lookup %>%
        filter(col.in == column) %>%
        select(Unit)%>%
        pull(n=1)

      unit_basis <- colnames_lookup %>%
        filter(col.in == column) %>%
        select(Unit_Basis)%>%
        pull(n=1)
      
      data_status <- colnames_lookup %>%
        filter(col.in == column) %>%
        select(Data_Status)%>%
        pull(n=1)


      boye_file_headers <- boye_file_headers %>%
        add_column(
          !!column := c(unit, unit_basis, column_typical_codes, '-9999', '-9999', data_status))
    }

    boye_file_headers <- boye_file_headers %>%
      add_column('Methods_Deviation' = 'N/A')
    
    #=============================== get LOD ==================================
    
    if (data_type == "TSS"){
      
      LOD <- read_xlsx(tss_LOD_file)
      
      LOD_dates_file_info <-file.info(list.files(path = boye_dir,pattern = "TSS_LOD", full.names = T)) %>%
        rownames_to_column('File_Name') %>%
        tibble()
      
      # get most recent LOD file
      LOD_dates_file <- LOD_dates_file_info %>%
        arrange(mtime) %>%
        tail(1)%>%
        select('File_Name')%>%
        pull(1)
      
      LOD_dates <- read_csv(LOD_dates_file)
      
      LOD_min <- LOD %>%
        filter(Date_start_YYYYMMDD <= LOD_dates$Date_start[1] & Date_end_YYYYMMDD >= LOD_dates$Date_start[1]) %>%
        select(LOD_TSS_mg_per_L)%>%
        pull(1)%>%
        round(2)
      
      LOD_max <- LOD %>%
        filter(Date_start_YYYYMMDD <= LOD_dates$Date_end[1] & Date_end_YYYYMMDD >= LOD_dates$Date_end[1]) %>%
        select(LOD_TSS_mg_per_L)%>%
        pull(1)%>%
        round(2)
      
      if(LOD_min == LOD_max){
        
        LOD_final = LOD_max
        
      } else{
        
        LOD_final = paste0(LOD_min[1],"-",LOD_max[1])
      }
      
      boye_file_headers <- boye_file_headers %>%
        assign_in(list(column, 9), LOD_final)
    } else {

      if(data_type == 'Ions' & str_detect(ion_LOD_file, 'MCRL')){

        LOD <- read_csv(ion_LOD_file)
        
        LOD_dates_file_info <-file.info(list.files(path = paste0(dir,'/05_PublishReadyData/Interim_Boye_Files'),pattern = "LOD", full.names = T)) %>%
          rownames_to_column('File_Name') %>%
          tibble()
        
        # get most recent LOD file
        LOD_dates_file <- LOD_dates_file_info %>%
          arrange(mtime) %>%
          tail(1)%>%
          select('File_Name')%>%
          pull(1)
        
        LOD_dates <- read_csv(LOD_dates_file)

        
        for (ion_column in data_columns) {
          
          analyte <- unlist(str_split(ion_column, '_'))[1]
        
          LOD_min <- LOD %>%
            filter(Analyte == analyte,
                   Date_start_YYYYMMDD <= LOD_dates$Date_start[1] & Date_end_YYYYMMDD >= LOD_dates$Date_start[1]) %>%
            select(LOD_ppm)%>%
            pull(1)%>%
            round(2)
          
          LOD_max <- LOD %>%
            filter(Analyte == analyte,
                   Date_start_YYYYMMDD <= LOD_dates$Date_end[1] & Date_end_YYYYMMDD >= LOD_dates$Date_end[1]) %>%
            select(LOD_ppm)%>%
            pull(1)%>%
            round(2)
          
          if(is_empty(LOD_max)){
            
            LOD_final = -9999
            
            cat(
              red$bold(
                'NO LOD\n'
              )
            )
            
          } else if(LOD_min == LOD_max){
            
            LOD_final = LOD_max
            
          } else{
          
          LOD_final = paste0(LOD_min[1],"-",LOD_max[1])
          }
          
          boye_file_headers <- boye_file_headers %>%
            assign_in(list(ion_column, 9), LOD_final)
        }


      }else if(data_type == 'Ions' & str_detect(ion_LOD_file, 'EMSL')){
        
        LOD <- read_csv(ion_LOD_file)
        
        LOD_dates_file_info <-file.info(list.files(path = paste0(dir,'/05_PublishReadyData/Interim_Boye_Files'),pattern = "LOD", full.names = T)) %>%
          rownames_to_column('File_Name') %>%
          tibble()
        
        # get most recent LOD file
        LOD_dates_file <- LOD_dates_file_info %>%
          arrange(mtime) %>%
          tail(1)%>%
          select('File_Name')%>%
          pull(1)
        
        LOD_dates <- read_csv(LOD_dates_file)
        
        
        for (ion_column in data_columns) {
          
          analyte <- unlist(str_split(ion_column, '_'))[1]
          
          LOD_min <- LOD %>%
            filter(Ion_name == analyte) %>%
            select(LOD_ppm)%>%
            pull(1)%>%
            round(2)
          
          LOD_max <- LOD %>%
            filter(Ion_name == analyte) %>%
            select(LOD_ppm)%>%
            pull(1)%>%
            round(2)
          
          if(is_empty(LOD_max)){
            
            LOD_final = -9999
            
            cat(
              red$bold(
                'NO LOD\n'
              )
            )
            
          } else if(LOD_min == LOD_max){
            
            LOD_final = LOD_max
            
          } else{
            
            LOD_final = paste0(LOD_min[1],"-",LOD_max[1])
          }
          
          boye_file_headers <- boye_file_headers %>%
            assign_in(list(ion_column, 9), LOD_final)
        }
        
        
      } else {

        LOD <- read_excel(LOD_file_dir)
        
        LOD_dates_file_info <-file.info(list.files(path = paste0(dir,'/05_PublishReadyData/Interim_Boye_Files'),pattern = "LOD", full.names = T)) %>%
          rownames_to_column('File_Name') %>%
          tibble()
        
        # get most recent LOD file
        LOD_dates_file <- LOD_dates_file_info %>%
          arrange(mtime) %>%
          tail(1)%>%
          select('File_Name')%>%
          pull(1)
        
        LOD_dates <- read_csv(LOD_dates_file)
        
        for (data_column in data_columns) {
          
          analyte <- unlist(str_split(data_column, '_'))[1]
          
          LOD_min <- LOD %>%
            select(contains(analyte) & contains('LOD'), Date_start_YYYYMMDD, Date_end_YYYYMMDD) %>%
            filter(Date_start_YYYYMMDD <= LOD_dates$Date_start[1] & Date_end_YYYYMMDD >= LOD_dates$Date_start[1]) %>%
            pull(1)%>%
            round(2)
          
          LOD_max <- LOD %>%
            select(contains(analyte) & contains('LOD'), Date_start_YYYYMMDD, Date_end_YYYYMMDD) %>%
            filter(Date_start_YYYYMMDD <= LOD_dates$Date_end[1] & Date_end_YYYYMMDD >= LOD_dates$Date_end[1]) %>%
            pull(1)%>%
            round(2)
          
          if(is_empty(LOD_max)){
            
            LOD_final = -9999
            
            cat(
              red$bold(
                'NO LOD\n'
              )
            )
            
          } else if(LOD_min == LOD_max){
            
            LOD_final = LOD_max
            
          } else{
            
            LOD_final = paste0(LOD_min[1],"-",LOD_max[1])
          }
        
          
          boye_file_headers <- boye_file_headers %>%
            assign_in(list(data_column, 9), LOD_final)
          
        }
        
      }
        
      }
      
      # ======================== fix column headers ==============================
      
      for (colname in data_columns) {
        
        colnames_lookup_filter <- colnames_lookup %>%
          dplyr::filter(col.in == colname)
        
        new_name <- colnames_lookup_filter$col.out
        
        data <- data %>%
          dplyr::rename(!!new_name := all_of(colname))
        
        boye_file_headers <- boye_file_headers %>%
          dplyr::rename(!!new_name := all_of(colname))
        
        
      }
      
    
    # ========================== finish formatting =============================

    if (material == 'Water'){
      
      data <- data %>%
        add_column(Material = 'Liquid>aqueous', .after = 'Sample_ID')%>%
        add_column(Field_Name = 'N/A', .before = 'Sample_ID')
      
    } else {
      
      data <- data %>%
        add_column(Material = material, .after = 'Sample_ID')%>%
        add_column(Field_Name = 'N/A', .before = 'Sample_ID')
      
    }

    
    data <- data %>%
      dplyr::mutate(across(everything(), as.character))%>%
      dplyr::mutate(across(contains('X'), replace_na, replace = '-9999'))%>%
      dplyr::mutate(across(!contains('X'), replace_na, replace = 'N/A'))%>%
      arrange(Sample_ID)
    
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
    
    out_name <- glue('{dir}/05_PublishReadyData/{study_code}_{material}_{data_type}_Boye_{Sys.Date()}.csv' )

    write_csv(top, out_name, col_names = F)

    write_csv(boye_file_headers, out_name, append = T, col_names = T)

    write_csv(data, out_name, append = T, na = '')

  
    
  }
}
