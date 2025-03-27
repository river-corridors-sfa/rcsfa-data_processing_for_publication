# ==============================================================================
#
# Combine QAQCed data and mapping files. 
#
# Output contains sample ID, data, method deviations, method notes, and a column
# indicating if the sample ID is duplicated. The user will need to remove any 
# duplicated sample IDs before proceeding to next script. 
#
# Status: Complplete
#
# Notes: make qaqc after npoc prettier,  
# TSS Does not have qaqc (remove qaqc file so it doesn't write the last one),
# move ICR mapping into the RC folder and get methods codes, figure out METHODS DEVIATION COLUMN 
#
# ==============================================================================
#
# Author: James Stegen, Vanessa Garayburu-Caruso, and Brieanne Forbes (WHONDRS)
# 5 October 2022
#
# ==============================================================================

library(tidyverse)
library(readxl)
library(crayon)
library(fs)
library(lubridate)
library(openxlsx)


rm(list=ls(all=T))

# ================================= User inputs ================================

pnnl_user <-  'forb086'

dir <- paste0('C:/Users/', pnnl_user, '/OneDrive - PNNL/Data Generation and Files/')

RC <-  'RC4' # Options are RC2, RC3, or RC4

study_code <-  'CM' 

analysis <-  'NPOC_TN' # Options are Ions, TN, NPOC, DIC, TSS and NPOC_TN #for ions, need to change to ION to pull out samples correctly later, but folder is "Ions", similar for NPOC_TN, analysis needs to change to "OCN" to bc that's what is in sample names

analyte_code <- 'SED' # Options are ION, OCN, DIC, TSS

qaqc <- 'N' # Y or N to QAQC the merged data, necessary when reps have been run on different runs

git_hub_dir <-  "C:/GitHub/QAQC_scripts/Functions_for_statistics/"

#coefficient of variation threshold
cv <- 30
# ================================= Build dir ================================

if(RC == 'RC3'){
  
  mapping_file_dir <- paste0(dir, RC, '/00_Raw_data_by_analysis/', analysis, '/')
  qaqc_file_dir <- paste0(dir, RC, '/', '01_Processed_data_by_analysis/', analysis, '/')
  data_file_dir <- paste0(dir, RC, '/', '01_Processed_data_by_analysis/', analysis, '/')
  
} else {

mapping_file_dir <- paste0(dir, RC, '/', analysis, '/', '01_RawData/')
qaqc_file_dir <- paste0(dir, RC, '/', analysis, '/', '03_ProcessedData')

if (analysis == 'Ions'){
  
  data_file_dir <- paste0(dir, RC, '/', analysis, '/', '03_ProcessedData/')
  
} else {
  
  data_file_dir <- paste0(dir, RC, '/', analysis, '/', '02_FormattedData/')
  
}

}





# out_dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Boye_Files/'

# ================================ create outdir ===============================

study_out_dir <- paste0(dir,RC, '/Boye_Files/', study_code, '/')


dir_create(study_out_dir)

# ============================= combine mapping files ==========================

mapping_files <- list.files(mapping_file_dir, pattern = 'Mapping', recursive = T, full.names = T)

mapping_files <- mapping_files[ !grepl('Archive',mapping_files)] #for RC2 NPOC_TN, also need to remove .txt and SPE

mapping_files <- mapping_files[ !grepl('txt',mapping_files)] # skipping txt files

combine_mapping <- tibble('Study_Code' = as.character(), 
                   'Sample_ID' = as.character(), 
                   'Randomized_ID' = as.character(), 
                   'Dilution_Factor' = as.numeric(), 
                   'Date_of_Run'= ymd(), 
                   'Instrument_MakeModel' = as.character(), 
                   'Method_Deviation' = as.character(), 
                   'Method_Notes' = as.character(),
                   'Date' = as.character())  
  
for (mapping_file in mapping_files) {
  
  file_name <-  path_file(mapping_file)
  
  date <- str_extract(file_name, '([A-Za-z0-9]+)')
  
  if(str_detect(file_name, '.csv')){
    
    mapping_data <-  read_csv(mapping_file, skip = 1) %>%
      mutate(Date = date) %>%
      select(!contains('...'))
    
  } else {
    
    mapping_data <-  read.xlsx(mapping_file, startRow = 2, na.strings = c('N/A', -9999), detectDates = FALSE) %>%
      mutate(Date = date) %>%
      select(!contains('...')) %>% 
      mutate(Method_Deviation = if("Method_Deviation" %in% names(.)) as.character(Method_Deviation) else NA_character_, 
      Method_Notes = if("Method_Notes" %in% names(.)) as.character(Method_Notes) else NA_character_, 
      Instrument_MakeModel = if("Instrument_MakeModel" %in% names(.)) as.character(Instrument_MakeModel) else NA_character_, 
      Date_of_Run = if("Date_of_Run" %in% names(.)) as.Date(Date_of_Run, origin = "1899-12-30") else NA)
    
  }
  
  if('Method_Status' %in% colnames(mapping_data)){
    
    mapping_data <- mapping_data %>%
      select(-Method_Status)
    
  }
  
  
  combine_mapping <- combine_mapping %>%
    bind_rows(mapping_data)
  
}
  
# ========================= filter mapping by study code =======================

mapping_filtered <- combine_mapping %>%
  filter(str_detect(Sample_ID, study_code))%>%
  filter(str_detect(Sample_ID, analyte_code)) # analyte code should remove need for if statement below, but keeping for now

# if(analysis == 'DIC'){
#   
#   mapping_filtered <- mapping_filtered %>%
#     filter(str_detect(Sample_ID, 'DIC'))
#   
# }

# ============================== combine QAQC data =============================
  if(analysis != 'TSS'){
  
    
    if(analysis == 'Ions'){
      
      qaqc_files <- list.files(qaqc_file_dir, pattern = 'QAQCed',recursive = T, full.names = T)
      
    } else {
      
      qaqc_files <- list.files(qaqc_file_dir, pattern = 'Compiled_QAQC',recursive = T, full.names = T)
      
    }

  qaqc_files <- qaqc_files[ !grepl('Archive',qaqc_files)]
  
  
  combine_qaqc <- read_csv(qaqc_files[1])%>%
    add_column(Date = 'date0') %>%
    mutate(across(everything(), as.character)) %>%
    filter(is.na(Sample_ID)) 
  
  for (qaqc_file in qaqc_files){
    
    file_name <-  path_file(qaqc_file)
    date <- str_extract(file_name, '([A-Za-z0-9]+)')
    
    qaqc_data <-  read_csv(qaqc_file) %>%
      mutate(Date = date,
             across(everything(), as.character))
    
    combine_qaqc <- combine_qaqc %>%
      bind_rows(qaqc_data)
    
    
  } } else{
    
    combine_qaqc <- list.files(qaqc_file_dir, study_code, full.names = T, recursive = T) %>%
      read_csv() %>%
      mutate(Date = date,
             across(everything(), as.character))
    
  } ## seems like this last else statement wouldn't really be doing anything because everything should be captured in first else statement?
  
  # ===================== filter data by study code and output =================
  
  data_filtered <- combine_qaqc %>%
    filter(str_detect(Sample_ID, study_code)) %>%
    filter(str_detect(Sample_ID, analyte_code)) # filtering by analyte code should remove need for if statement below
  # filter(str_detect(Sample_ID, 'SED'))
  
  
# if(analysis == 'DIC'){
#   
#   data_filtered <- data_filtered %>%
#     filter(str_detect(Sample_ID, 'DIC'))
#   
# } 
  
  #file needed for summary stats code
  write_csv(data_filtered,paste0(study_out_dir,'/', study_code, '_', analysis, '_CombinedQAQC_', Sys.Date(), '_by_', pnnl_user, '.csv'))

    
  
  # ========================== merge data and mapping files ====================
     
   merged <- data_filtered %>%
        full_join(mapping_filtered, by = c('Sample_ID', 'Date', 'Randomized_ID')) %>%
        unite(Deviation,
              c(Method_Deviation, Flags),
              sep = '; ',
              na.rm = T)
  
  # ============================= get LOD date range =============================
  
  date_range = tibble(Date_start = min(merged$Date),
                      Date_end = max(merged$Date))
  
  # Export LOD dates
  write_csv(date_range,paste0(study_out_dir,'/', study_code, '_', analysis, '_LOD_Dates_', Sys.Date(), '_by_', pnnl_user, '.csv'))
  
  # ========================= select necessary columns ===========================
  
  merged_clean <- merged %>%
    select(Date, Randomized_ID, Sample_ID, contains('per_'), Deviation, Method_Notes) %>%
    dplyr::rename(Date_of_Run = Date,
           Methods_Deviation = Deviation)
  
  # ===================================== reruns =================================
  
  # reruns have to be removed manually from the output, a message will appear in the
  # console to tell the user if they have duplicates in the data frame. Duplicates are
  # found in the output when samples have been rerun and therefore have two data values.
  
  merged_clean <-  merged_clean %>%
    mutate(duplicate = duplicated(Sample_ID))
  
  if ('TRUE' %in% merged_clean$duplicate) {
    cat(
      red$bold(
        'Wait! You have duplicates in your data.\n',
        'Please check cleaned dataset carefully\n'
      )
    )
    
  } else{
    cat(green$bold('No duplicates, you are good to go!\n'))
    
  }
  
  # Export data
  # wondering if starting at line 268, this is redundant since the data has already been read in/exported as CombinedQAQC document above?
  
  if (qaqc == 'N') {
    
    #rename to match name of final merged file from qaqc
    final_merged <- merged_clean
  
  } else if (qaqc == 'Y') {
  
# ----------------------- for files that  need to be qaqc'd --------------------
    
    merged_clean <- merged_clean %>%
      mutate(Methods_Deviation = str_remove_all(Methods_Deviation, 'NPOC_CV_030'),
             Methods_Deviation = str_remove_all(Methods_Deviation, 'NPOC_CV_30'),
             Methods_Deviation = if_else(Methods_Deviation == 'NPOC_CV_030',NA, Methods_Deviation),
             Methods_Deviation = if_else(Methods_Deviation == 'NPOC_CV_30',NA, Methods_Deviation)) %>%
      mutate(Methods_Deviation = str_remove_all(Methods_Deviation, 'TN_CV_030'),
             Methods_Deviation = str_remove_all(Methods_Deviation, 'TN_CV_30'),
             Methods_Deviation = if_else(Methods_Deviation == 'TN_CV_030',NA, Methods_Deviation),
             Methods_Deviation = if_else(Methods_Deviation == 'TN_CV_30',NA, Methods_Deviation))

  # ================================ combine data ==============================
  
 
      data_files <- list.files(data_file_dir, pattern = 'Matched', recursive = T, full.names = T)

  
  data_files <- data_files[ !grepl('Archive', data_files)]
  
  combine_data <- read_csv(data_files[1])%>%
    mutate(across(everything(), as.character)) %>%
    filter(is.na(Sample_ID)) %>%
    add_column(Date = 'N/A', .before = 1)
  
  colnames(combine_data) <- str_remove(colnames(combine_data), '_and_blanks')
  
  for (data_file in data_files){
    
    file_name <-  path_file(data_file)
    date <- str_extract(file_name, '([A-Za-z0-9]+)')
    
    data <-  read_csv(data_file) %>%
      mutate(across(everything(), as.character))%>%
      select(-contains('Blank_corrected'))
    
    matched_date <- str_extract(file_name, '([A-Za-z0-9]+)')
    
    data <- data %>%
      add_column(Date = matched_date, .before = 1)
    
    colnames(data) <- str_remove(colnames(data), '_and_blanks')
    
    combine_data <- combine_data %>%
      add_row(data)
  }
  
  # ========================== filter data by study code =======================
  
  mapping_filtered2 <- mapping_filtered %>%
    mutate(Date_of_Run = as.character(Date_of_Run),
           Dilution_Factor = as.character(Dilution_Factor))
  
  qaqc_merge <- combine_data %>%
    filter(str_detect(Sample_ID, study_code))%>%
    filter(str_detect(Sample_ID, analyte_code))%>%
    # select(-length(combine_data))%>%
    mutate(across(contains('per_'), as.numeric)) %>%
    full_join(mapping_filtered2, by = c('Date', 'Randomized_ID', 'Sample_ID', 'Dilution_Factor'))
  
  write_csv(qaqc_merge, paste0(study_out_dir,'/', study_code, '_', analysis, '_Data_Check-for-duplicates_', Sys.Date(), '_by_', pnnl_user, '.csv'))
  
  cat(
    red$bold(
      'REMOVE DUPLICATES BEFORE PROCEEDING\n'
    )
  )
  
  readline(prompt = 'Have the duplicates been removed? Write Y if ready to proceed. \nOtherwise dont write anything until ready to proceed.')
  
  df <- read_csv(list.files(study_out_dir, paste0(analysis, '_Data_Check-for-duplicates'), full.names = T)) %>%
    select(colnames(combine_data))
  
  
  # =============================== NPOC QAQC ==================================
  
  if (analysis == "NPOC"){
    source(paste0(git_hub_dir,"Stats_fun_v4_only_npoc.R"))

    df_stats <-  suppressWarnings(Stats_fun_v4_only_npoc(df)) %>%
      add_column(flags = NA)
 
    # Adding flags based on the CV
    for (i in 1:nrow(df_stats)){
      if (df_stats$NPOC_CV[i] >= cv && is.na(df_stats$NPOC_CV[i])==F){
        df_stats$flags[i] <-  paste0("NPOC_CV_",cv,"_Flag")
      }
    }

    # Identify samples that are outliers based on the samples that are flagged for CV
    df_stats$NPOC_outlier <-  NA
    df_stats_outlier <-  subset(df_stats,is.na(df_stats$flags)== FALSE)
    unique_samples <-  unique(df_stats_outlier$Sample_name)

    for (i in 1:length(unique_samples)) {
      a_temp = (df_stats$flags[which(df_stats$Sample_name == unique_samples[i])])

      if (length(grep("NPOC",a_temp))> 0){
        conc_temp = as.numeric(df_stats$NPOC_mg_C_per_L[which(df_stats$Sample_name == unique_samples[i])])

        dist_temp = as.matrix(abs(dist(conc_temp)))
        dist_comp = numeric()
        for(conc_now in 1:ncol(dist_temp) ) {
          dist_comp = rbind(dist_comp,c(conc_now,sum(dist_temp[,conc_now])))
        }

        dist_comp[,2] = as.numeric(dist_comp[,2])
        temp_outlier = conc_temp[which.max(dist_comp[,2])]
        loc = which(df_stats$NPOC_mg_C_per_L == temp_outlier)
        df_stats$NPOC_outlier[loc] = "TRUE"
      }
    }
    
    df_stats = df_stats %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(NPOC_outlier), flags, if_else(!is.na(flags) & NPOC_outlier ==  TRUE, paste0(flags, "; NPOC_OUTLIER_000"), flags)))
    
  }else if (analysis == "TN"){

    # =============================== TN QAQC ==================================

    source(paste0(git_hub_dir,"Stats_fun_v3_only_tn.R"))
    df_stats <-  suppressWarnings(Stats_fun_v3_only_tn(df))%>%
      add_column(flags = NA, TN_mg_N_per_L = NA, Dilution_factor = NA)

    # Populating the columns just added in the stats matrix
    for (j in 1:nrow(df_stats)){
      df_stats$TN_mg_N_per_L[j] <-  signif(df$TN_mg_N_per_L[which(df$Sample_ID  == df_stats$Sample_ID[j])],3)
      df_stats$Dilution_factor[j] <- df$Dilution_Factor[which(df$Sample_ID  == df_stats$Sample_ID[j])]
    }

    df_stats$flags = NA

    # Adding flags based on the CV
    for (i in 1:nrow(df_stats)){
      if (df_stats$TN_CV[i] >= cv && is.na(df_stats$TN_CV[i])==F){
        df_stats$flags[i] = paste0("TN_CV_",cv,"_Flag")
      }
    }
    # Identify samples that are outliers based on the samples that are flagged for CV
    df_stats$TN.outlier = NA
    df_stats.outlier = subset(df_stats,is.na(df_stats$flags)== FALSE)
    unique.samples = unique(df_stats.outlier$Sample_name)

    for (i in 1:length(unique.samples)) {
      a.temp = (df_stats$flags[which(df_stats$Sample_name == unique.samples[i])])

      if (length(grep("TN",a.temp))> 0){
        conc.temp = as.numeric(df_stats$TN_mg_N_per_L[which(df_stats$Sample_name == unique.samples[i])])

        dist.temp = as.matrix(abs(dist(conc.temp)))
        dist.comp = numeric()
        for(conc.now in 1:ncol(dist.temp) ) {
          dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
        }

        dist.comp[,2] = as.numeric(dist.comp[,2])
        temp.outlier = conc.temp[which.max(dist.comp[,2])]
        loc = which(df_stats$TN_mg_N_per_L == temp.outlier)
        df_stats$TN.outlier[loc] = "TRUE"

      }
    }
    
    df_stats = df_stats %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(TN.outlier), flags, if_else(!is.na(flags) & TN.outlier ==  TRUE, paste0(flags, "; TN_OUTLIER_000"), flags)))

  }else if (analysis == "DIC"){
    
    # =============================== DIC QAQC =================================
    
    source(paste0(git_hub_dir,"Stats_fun_v5_only_dic.R"))
    df_stats = suppressWarnings(Stats_fun_v5_only_dic(df)) %>%
      add_column(flags = NA, DIC_mg_C_per_L = NA, Dilution_factor = NA)

    # Populating the columns just added in the stats matrix
    for (j in 1:nrow(df_stats)){
      df_stats$DIC_mg_C_per_L[j] = signif(df$DIC_mg_C_per_L[which(df$Sample_ID  == df_stats$Sample_ID[j])],3)

      df_stats$Dilution_factor[j] = df$Dilution_Factor[which(df$Sample_ID  == df_stats$Sample_ID[j])]
    }

    df_stats$flags = NA

    # Adding flags based on the CV
    for (i in 1:nrow(df_stats)){
      if (df_stats$DIC_CV[i] >= cv && is.na(df_stats$DIC_CV[i])==F){
        df_stats$flags[i] = paste0("DIC_CV_",cv,"_Flag")
      }
    }

    # Identify samples that are outliers based on the samples that are flagged for CV
    df_stats$DIC.outlier = NA
    df_stats.outlier = subset(df_stats,is.na(df_stats$flags)== FALSE)
    unique.samples = unique(df_stats.outlier$Sample_name)

    for (i in 1:length(unique.samples)) {
      a.temp = (df_stats$flags[which(df_stats$Sample_name == unique.samples[i])])

      if (length(grep("DIC",a.temp))> 0){
        conc.temp = as.numeric(df_stats$DIC_mg_C_per_L[which(df_stats$Sample_name == unique.samples[i])])

        dist.temp = as.matrix(abs(dist(conc.temp)))
        dist.comp = numeric()
        for(conc.now in 1:ncol(dist.temp) ) {
          dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
        }

        dist.comp[,2] = as.numeric(dist.comp[,2])
        temp.outlier = conc.temp[which.max(dist.comp[,2])]
        loc = which(df_stats$DIC_mg_C_per_L == temp.outlier)
        df_stats$DIC.outlier[loc] = "TRUE"
      }
    }
    
    df_stats = df_stats %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(DIC.outlier), flags, if_else(!is.na(flags) & DIC.outlier ==  TRUE, paste0(flags, "; DIC_OUTLIER_000"), flags)))


  }else if (analysis == "Ions"){
    
    # =============================== Ion QAQC ==================================
    
    source(paste0(git_hub_dir,"Stats_fun_v2.R"))
    df_stats = suppressWarnings(Stats_fun_v2(df))
    df_stats$flags = NA
    
    df_stats = df_stats %>% 
      mutate(across(contains("_CV"), as.numeric))
    
    ## a lot of missing replicates for ions, so need to remove those before calculating

    for (i in 1:nrow(df_stats)){
      if (is.na(df_stats$Ammonium_CV[i])== FALSE && df_stats$Ammonium_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Ammonium_CV_",cv,"_Flag")}
      if (is.na(df_stats$Bromide_CV[i])== FALSE && df_stats$Bromide_CV[i] >= cv){
          df_stats$flags[i] = paste0(df_stats$flags[i],"; Bromide_CV_",cv,"_Flag")}
      if (is.na(df_stats$Calcium_CV[i])== FALSE && df_stats$Calcium_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Calcium_CV_",cv,"_Flag")}
      if (is.na(df_stats$Chloride_CV[i])== FALSE && df_stats$Chloride_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Chloride_CV_",cv,"_Flag")}
      if (is.na(df_stats$Fluoride_CV[i])== FALSE && df_stats$Fluoride_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Fluoride_CV_",cv,"_Flag")}
      if (is.na(df_stats$Lithium_CV[i])== FALSE && df_stats$Lithium_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Lithium_CV_",cv,"_Flag")}
      if (is.na(df_stats$Magnesium_CV[i])== FALSE && df_stats$Magnesium_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Magnesium_CV_",cv,"_Flag")}
      if (is.na(df_stats$Nitrate_CV[i])== FALSE && df_stats$Nitrate_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Nitrate_CV_",cv,"_Flag")}
      if (is.na(df_stats$Nitrite_CV[i])== FALSE && df_stats$Nitrite_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Nitrite_CV_",cv,"_Flag")}
      if (is.na(df_stats$Phosphate_CV[i])== FALSE && df_stats$Phosphate_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Phosphate_CV_",cv,"_Flag")}
      if (is.na(df_stats$Potassium_CV[i])== FALSE && df_stats$Potassium_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Potassium_CV_",cv,"_Flag")}
      if (is.na(df_stats$Sodium_CV[i])== FALSE && df_stats$Sodium_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Sodium_CV_",cv,"_Flag")}
      if (is.na(df_stats$Sulfate_CV[i])== FALSE && df_stats$Sulfate_CV[i] >= cv){
        df_stats$flags[i] = paste0(df_stats$flags[i],"; Sulfate_CV_",cv,"_Flag")}
    }
    
       # fixing NA in the flag
    df_stats$flags = gsub("NA; ", "", df_stats$flags)
    df_stats$flags = gsub("NA;", "", df_stats$flags)
    # Identify samples that are outliers based on the samples that are flagged
    df_stats$Ammonium.outlier = NA
    df_stats$Bromide.outlier = NA
    df_stats$Calcium.outlier = NA
    df_stats$Chloride.outlier = NA
    df_stats$Fluoride.outlier = NA
    df_stats$Lithium.outlier = NA
    df_stats$Magnesium.outlier = NA
    df_stats$Nitrate.outlier = NA
    df_stats$Nitrite.outlier = NA
    df_stats$Phosphate.outlier = NA
    df_stats$Potassium.outlier = NA
    df_stats$Sodium.outlier = NA
    df_stats$Sulfate.outlier = NA

    df_stats.outlier = subset(df_stats,is.na(df_stats$flags)== FALSE)
    unique.samples = unique(df_stats.outlier$Sample_name)

    ions = names(df)[2:(ncol(df)-1)]

    for (i in 1:length(unique.samples)) {
      a.temp = (df_stats$flags[which(df_stats$Sample_name == unique.samples[i])])

      for (j in 1:length(ions)){
        if (length(grep(ions[j],a.temp))> 0){
          conc.temp = as.numeric(df_stats[which(df_stats$Sample_name == unique.samples[i]),paste0(ions[j],"_mg_per_L")])

          dist.temp = as.matrix(abs(dist(conc.temp)))
          dist.comp = numeric()
          for(conc.now in 1:ncol(dist.temp) ) {
            dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
          }

          dist.comp[,2] = as.numeric(dist.comp[,2])
          temp.outlier = conc.temp[which.max(dist.comp[,2])]
          loc = which(df_stats[,paste0(ions[j],"_mg_per_L")] == temp.outlier)
          df_stats[loc,paste0(ions[j],".outlier")] = "TRUE"
        }

      }
      
      
      df_stats = df_stats %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Ammonium.outlier), flags, if_else(!is.na(flags) & Ammonium.outlier ==  TRUE, paste0(flags, "; NH4_OUTLIER_000"), flags))) %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(Bromide.outlier), flags, if_else(!is.na(flags) & Bromide.outlier ==  TRUE, paste0(flags, "; Br_OUTLIER_000"), flags))) %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(Calcium.outlier), flags, if_else(!is.na(flags) & Calcium.outlier ==  TRUE, paste0(flags, "; Ca_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Chloride.outlier), flags, if_else(!is.na(flags) & Chloride.outlier ==  TRUE, paste0(flags, "; Cl_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Fluoride.outlier), flags, if_else(!is.na(flags) & Fluoride.outlier ==  TRUE, paste0(flags, "; F_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Lithium.outlier), flags, if_else(!is.na(flags) & Lithium.outlier ==  TRUE, paste0(flags, "; Li_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Magnesium.outlier), flags, if_else(!is.na(flags) & Magnesium.outlier ==  TRUE, paste0(flags, "; Mg_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Nitrate.outlier), flags, if_else(!is.na(flags) & Nitrate.outlier ==  TRUE, paste0(flags, "; NO3_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Nitrite.outlier), flags, if_else(!is.na(flags) & Nitrite.outlier ==  TRUE, paste0(flags, "; NO2_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Phosphate.outlier), flags, if_else(!is.na(flags) & Phosphate.outlier ==  TRUE, paste0(flags, "; PO4_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Potassium.outlier), flags, if_else(!is.na(flags) & Potassium.outlier ==  TRUE, paste0(flags, "; K_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Sodium.outlier), flags, if_else(!is.na(flags) & Sodium.outlier ==  TRUE, paste0(flags, "; Na_OUTLIER_000"), flags))) %>% 
        mutate(flags = if_else(!is.na(flags) & is.na(Sulfate.outlier), flags, if_else(!is.na(flags) & Sulfate.outlier ==  TRUE, paste0(flags, "; SO4_OUTLIER_000"), flags)))
      
    }
    
    
  }else if (analysis == "NPOC_TN"){
    
    # ============================= NPOC-TN QAQC ===============================
    
    source(paste0(git_hub_dir,"Stats_fun_v2.R"))
    
    df_stats <-  suppressWarnings(Stats_fun_v2(df)) %>%
      add_column(flags = NA, NPOC_mg_C_per_L = NA,TN_mg_N_per_L = NA, Dilution_factor = NA)

    # Populating the columns just added in the stats matrix
    for (j in 1:nrow(df_stats)){
      df_stats$NPOC_mg_C_per_L[j] = signif(df$NPOC_mg_C_per_L[which(df$Sample_ID  == df_stats$Sample_ID[j])],3)
      df_stats$TN_mg_N_per_L[j] = signif(df$TN_mg_N_per_L[which(df$Sample_ID  == df_stats$Sample_ID[j])],3)
      df_stats$Dilution_factor[j] = df$Dilution_Factor[which(df$Sample_ID  == df_stats$Sample_ID[j])]
    }

    df_stats$flags = NA

    # Adding flags based on the CV
    for (i in 1:nrow(df_stats)){
      if (df_stats$NPOC_CV[i] >= cv && df_stats$TN_CV[i] <= cv && is.na(df_stats$NPOC_CV[i])==F && is.na(df_stats$TN_CV[i])==F){
        df_stats$flags[i] = paste0("NPOC_CV_",cv,"_Flag")
      }else if (df_stats$TN_CV[i] >= cv && df_stats$NPOC_CV[i] <= cv && is.na(df_stats$NPOC_CV[i])==F && is.na(df_stats$TN_CV[i])==F){
        df_stats$flags[i] = paste0("TN_CV_",cv,"_Flag")
      }else if (df_stats$NPOC_CV[i] >= cv && df_stats$TN_CV >= cv && is.na(df_stats$NPOC_CV[i])==F && is.na(df_stats$TN_CV[i])==F){
        df_stats$flags[i] = paste0("NPOC_CV_",cv,"_Flag,","TN_CV_",cv,"_Flag")
      }
    }

    # Identify samples that are outliers based on the samples that are flagged for CV
    df_stats$NPOC.outlier = NA
    df_stats$TN.outlier = NA
    df_stats.outlier = subset(df_stats,is.na(df_stats$flags)== FALSE)
    unique.samples = unique(df_stats.outlier$Sample_name)

    for (i in 1:length(unique.samples)) {
      a.temp = (df_stats$flags[which(df_stats$Sample_name == unique.samples[i])])

      if (length(grep("NPOC",a.temp))> 0 && length(grep("TN",a.temp))> 0){
        conc.temp = as.numeric(df_stats$NPOC_mg_C_per_L[which(df_stats$Sample_name == unique.samples[i])])

        dist.temp = as.matrix(abs(dist(conc.temp)))
        dist.comp = numeric()
        for(conc.now in 1:ncol(dist.temp) ) {
          dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
        }

        dist.comp[,2] = as.numeric(dist.comp[,2])
        temp.outlier = conc.temp[which.max(dist.comp[,2])]
        loc = which(df_stats$NPOC_mg_C_per_L == temp.outlier)
        df_stats$NPOC.outlier[loc] = "TRUE"

        # Repeating the same process for just TN

        conc.temp = as.numeric(df_stats$TN_mg_N_per_L[which(df_stats$Sample_name == unique.samples[i])])

        dist.temp = as.matrix(abs(dist(conc.temp)))
        dist.comp = numeric()
        for(conc.now in 1:ncol(dist.temp) ) {
          dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
        }

        dist.comp[,2] = as.numeric(dist.comp[,2])
        temp.outlier = conc.temp[which.max(dist.comp[,2])]
        loc = which(df_stats$TN_mg_N_per_L == temp.outlier)
        df_stats$TN.outlier[loc] = "TRUE"

      }else  if (length(grep("NPOC",a.temp))> 0){
        conc.temp = as.numeric(df_stats$NPOC_mg_C_per_L[which(df_stats$Sample_name == unique.samples[i])])

        dist.temp = as.matrix(abs(dist(conc.temp)))
        dist.comp = numeric()
        for(conc.now in 1:ncol(dist.temp) ) {
          dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
        }

        dist.comp[,2] = as.numeric(dist.comp[,2])
        temp.outlier = conc.temp[which.max(dist.comp[,2])]
        loc = which(df_stats$NPOC_mg_C_per_L == temp.outlier)
        df_stats$NPOC.outlier[loc] = "TRUE"
      } else if (length(grep("TN",a.temp))> 0){
        conc.temp = as.numeric(df_stats$TN_mg_N_per_L[which(df_stats$Sample_name == unique.samples[i])])

        dist.temp = as.matrix(abs(dist(conc.temp)))
        dist.comp = numeric()
        for(conc.now in 1:ncol(dist.temp) ) {
          dist.comp = rbind(dist.comp,c(conc.now,sum(dist.temp[,conc.now])))
        }

        dist.comp[,2] = as.numeric(dist.comp[,2])
        temp.outlier = conc.temp[which.max(dist.comp[,2])]
        loc = which(df_stats$TN_mg_N_per_L == temp.outlier)
        df_stats$TN.outlier[loc] = "TRUE"
      }
    }
    
    df_stats = df_stats %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(NPOC.outlier), flags, if_else(!is.na(flags) & NPOC.outlier ==  TRUE, paste0(flags, "; NPOC_OUTLIER_000"), flags))) %>% 
      mutate(flags = if_else(!is.na(flags) & is.na(TN.outlier), flags, if_else(!is.na(flags) & TN.outlier ==  TRUE, paste0(flags, "; TN_OUTLIER_000"), flags)))
    
  }


    # ==================== merge deviations and flags ==========================

  flags <- df_stats %>%
      select('Sample_ID', 'flags')
  
  outliers <- df_stats %>%
    select('Sample_ID', contains('outlier'), 'flags') 
    
    final_merged <- merged_clean %>%
      full_join(flags, by=c('Sample_ID', 'Randomized_ID')) %>%
      mutate(flags = as.character(flags),
             Methods_Deviation = as.character(Methods_Deviation))%>%
      mutate(Methods_Deviation = if_else(Methods_Deviation == "", NA, Methods_Deviation)) %>% 
      unite(Methods_Deviation,
           c(Methods_Deviation, flags),
          sep = '; ',
            na.rm = T)%>% 
    mutate(Methods_Deviation = ifelse(Methods_Deviation == '', NA, Methods_Deviation))
    
    data_filtered_fixed <- data_filtered %>%
      select(-contains('outlier'), -Flags)%>%
      full_join(outliers)
    
    write_csv(data_filtered_fixed,paste0(study_out_dir,'/', study_code, '_', analysis, '_CombinedQAQC_', Sys.Date(), '_by_', pnnl_user, '.csv'))
    
    
  }
  
  # ================================ fix flags =================================
    #qaqc script makes long flags, this part of the script will abbreviate them
  
  final <- final_merged %>%
    mutate(Methods_Deviation = str_replace_all(
      Methods_Deviation,
      c('Bromide' = 'Br',
        'Chloride'= 'Cl',
        'Ammonium' = 'NH4',
        'Calcium' = 'Ca',
        'Fluoride' = 'F',
        'Floride' = 'F',
        'Lithium' = 'Li',
        'Magnesium' = 'Mg',
        'Nitrate' = 'NO3',
        'Nitrite' = 'NO2',
        'Phosphate' = 'PO4',
        'Sodium' = 'Na',
        "Sulfate" = "SO4",
        'Potassium' = 'K',
        'CV_30_Flag' = 'CV_030',
        'CV_3_Flag' = 'CV_030',
        'Blank_corrected' = 'BLC_000',
        'Blank_Higher_than_LOD' = 'BLC_000',
        '[:alpha:]*[:digit:]*_Below_[:digit:]*\\.?[:digit:]*_ppm' = 'DTL_000',
        '[:alpha:]*_Below_[:digit:]*\\.?[:digit:]?_ppm' = 'DTL_000',
        '[:alpha:]*[:digit:]*_Below_LOD_[:digit:]*\\.?[:digit:]*_ppm' = 'DTL_000',
        '[:alpha:]*_Below_LOD_[:digit:]*\\.?[:digit:]?_ppm' = 'DTL_000',
        '[:alpha:]*_Blank_Higher_than_LOD' = 'DTL_000',
        '[:alpha:]*[:digit:]*_Above_[:digit:]*\\.?[:digit:]*_ppm' = 'DTL_000',
        '[:alpha:]*_Above_[:digit:]*\\.?[:digit:]?_ppm' = 'DTL_000',
        '[:alpha:]*[:digit:]*_Above_LOD_[:digit:]*\\.?[:digit:]*_ppm' = 'DTL_000',
        '[:alpha:]*_Above_LOD_[:digit:]*\\.?[:digit:]?_ppm' = 'DTL_000')
      ))%>%
    arrange(Sample_ID) %>%
    rowwise()%>%
    mutate(Methods_Deviation = paste(unique(unlist(strsplit(Methods_Deviation, split="; "))), collapse = '; ')) 

  
  write_csv(final,  paste0(study_out_dir, '/', study_code, '_', analysis, '_Check_for_Duplicates_',Sys.Date(),'_by_', pnnl_user,'.csv'))
  