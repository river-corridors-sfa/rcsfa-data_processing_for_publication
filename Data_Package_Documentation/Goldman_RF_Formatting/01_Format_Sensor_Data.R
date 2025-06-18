# ==============================================================================
#
# Format sensor data following the Goldman et al. (2021) reporting format 
#
# Status: complete
#
# known issue: 
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 10 Oct 2023
#
# ==============================================================================

library(tidyverse)
library(crayon)
library(readxl)
library(glue)
library(rlog)

rm(list=ls(all=T))

# =========================== User inputs ======================================

data_dir <- "Z:/RC2/03_Temporal_Study/02_MantaRiver/03_ProcessedData"

# must match header row sensor column (do not include "_summary")
sensor <- 'manta'

# indicate if this is a summary file, if so the script will find headers with "_summary" appended
summary <- 'N' 

study_code <- 'RC2'

out_dir <- 'Z:/RC2/03_Temporal_Study/02_MantaRiver/05_PublishReadyData/'

out_name_format <- '{out_dir}/{study_code}_{Site_ID}_{Date}_Water_Temp_SpC_ChlA.csv'
# out_name_format <- '{out_dir}/v2_{study_code}_Water_Press_Temp_Summary.csv'

# indicator of different method IDs that can be found in the file name. Could be 
# a list of site IDs or left blank if only one method ID. 
# group1 <- c('S01', 'S02', 'S08', 'S10', 'S11', 'S47R', 'T05P', 'S54', 'S03', 'S29', 'S58', 'T41')
# group1_ID <- 'Minidot_Hobo_01'
# 
# group2 <- c('S04', 'S10', 'S15', 'S03', 'S29')
# group2_ID <- 'Minidot_Hobo_02'

# group1 <- c('S18R', 'S29', 'S34R', 'S39', 'S42', 'S48R', 'S56N', 'T05P', 'W10')
# group1_ID <- 'TreeRope_01'
# 
# group2 <- c('C21', 'S01', 'S02', 'S03', 'S04', 'S08', 'S10', 'S11', 'S15', 'S17R', 'S22RR', 'S23', 'S24', 'S30R', 'S31', 'S32', 'S36', 'S37', 'S38', 'S41R', 'S43', 'S45', 'S47R', 'S49R', 'S50P', 'S51', 'S52', 'S53', 'S54', 'S55N', 'S57', 'S58', 'S63', 'T02', 'T03', 'T07', 'T42', 'U20', 'W20')
# group2_ID <- 'BaroExtrap_01'
# ========================== data base dirs ====================================

# headers_dir <- '~/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Sensor_Header_Rows.xlsx'
# 
# inst_methods_dir <- '~/OneDrive - PNNL/Data Generation and Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Installation_Methods.xlsx'

headers_dir <- "C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Sensor_Header_Rows.xlsx"

inst_methods_dir <- "C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Installation_Methods.xlsx"

# ===================== list files in dir and loop =============================

if(summary == 'Y' & str_detect(data_dir, '.csv') == T){
  
  data_files <- data_dir

} else if (summary == 'Y') {
  
  data_files <- list.files(data_dir, 'Summary', full.names = T)
  
} else {

data_files <- list.files(data_dir, '.csv', full.names = T)
data_files <- data_files[ !grepl('Archive|Summary|SSF_miniDOT_HOBO_with_Depth|Regression',data_files)]
}

for (data_file in data_files) {

# ========================== read files in =====================================

  # read in file
  data <- read_csv(data_file, show_col_types = F)
  
  if(study_code == 'RC2' & "pH" %in% colnames(data)){
    
    data <- data %>%
      select(-pH)
    
  }
  
  # remove depth column if it's in a manta or exo sensor
  if (sensor %in% c("manta", "exo") & "Depth" %in% colnames(data)) {
    data <- data %>% 
      select(-Depth)
  }
  
  data_headers <- colnames(data)

  headers <- read_xlsx(headers_dir, sheet = study_code) %>%
    mutate(InstallationMethod_ID = trimws(InstallationMethod_ID))  %>%
    filter(Column_Header %in% data_headers) # added this to filter out any headers (like pH) that might be in some files but not all
  
  inst_methods <- read_xlsx(inst_methods_dir)

# ========================== make headers ======================================

  inst_methods_filter <- inst_methods %>%
    filter(InstallationMethod_ID %in% headers$InstallationMethod_ID,
           str_detect(Sensor, sensor))
  
  if(summary == 'Y'){
    
    headers_filter <- headers %>%
      filter(Sensor == paste0(sensor, "_summary"))
    
    } else {
      
    headers_filter <- headers %>%
      filter(Sensor == sensor)
  
  }
  
  n_method_id <- headers_filter %>%
    select(InstallationMethod_ID) %>%
    distinct() %>%
    nrow() %>%
    as.numeric()
  
  if(n_method_id == 2){
    
    if(TRUE %in% str_detect(data_file, group1)){
      
      headers_filter <- headers_filter %>%
        filter(InstallationMethod_ID == group1_ID)
      
    } else if(TRUE %in% str_detect(data_file, group2)){
      
      headers_filter <- headers_filter %>%
        filter(InstallationMethod_ID == group2_ID)
      
    } 
    
    
  } else if(n_method_id > 2) {
    
    cat(
      red$bold(
        'Too many method IDs/n'
      )
    )
    
    break
    
  }
  
  if(TRUE %in% str_detect(colnames(data), '3')){

      
  } else{    
    headers_filter <- headers_filter %>%
      filter(!str_detect(Column_Header, '3'))
    }
  
  headers <- headers_filter %>%
    pull(Column_Header)
  
  
  headers_filter <- headers_filter %>%
    mutate(Instrument_Summary = str_replace(Instrument_Summary, "//.{1,}$", ""),
      header = paste0('# ', Column_Header,"; ", Unit, "; ", InstallationMethod_ID, "; ",Instrument_Summary, ".")) %>%
    select(header)
  

  data_headers <- tibble(header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary') %>%
    add_row(headers_filter)

  n_rows <- nrow(data_headers) + 2

  data_headers <- data_headers %>%
   add_row(header = paste0('# HeaderRows_', n_rows),
           .before = 1)

# =========================== format data ======================================

  data <- data %>%
   mutate_if(is.numeric, replace_na, replace = -9999) 
  
  
  # list of columns to check
  columns_to_check <- c("DateTime", "Date", "DateTime_Start", "DateTime_End")
  
  # check if any of the columns exist in the df
  if (any(columns_to_check %in% colnames(data))) {
    
    # if any of the columns exist, add space before date/time for reporting format needs
    data <- data %>%
      mutate(across(any_of(columns_to_check), ~ paste0(" ", as.character(.))))
  }
  
  data_colnames <- data %>%
    colnames()
  
  if ('Parent_ID' %in% colnames(data)){
    data_colnames <- data_colnames[ !grepl('Parent_ID',data_colnames)]
    
  } 
  
  if ('Site_ID' %in% colnames(data)){
    data_colnames <- data_colnames[ !grepl('Site_ID',data_colnames)]
    
  }
  
  if ('Outlier' %in% colnames(data)){
    data_colnames <- data_colnames[ !grepl('Outlier',data_colnames)]
  }  
  
  if('InstallationMethod_ID' %in% colnames(data)){
    
    data_colnames <- data_colnames[ !grepl('InstallationMethod_ID',data_colnames)]
    
  }
  
  if('Notes' %in% colnames(data)){
    
    data_colnames <- data_colnames[ !grepl('Notes',data_colnames)]
    
  }
  
  check <- headers == data_colnames
  
  if('FALSE' %in% check | is_empty(check)){
    
    cat(
      red$bold(
        'COLUMN HEADERS IN DATA AND SENSOR HEADER ROWS DO NOT MATCH/n'
      )
    )
    
  } else{

# ============================ write file ======================================
  
  # Parent_ID <- data %>%
  #   select(Parent_ID) %>%
  #   distinct()%>%
  #   pull()

    Site_ID <- data %>%
      select(Site_ID) %>%
      distinct()%>%
      pull()
    
    Date <-  unique(date(data$DateTime))
    


  if(study_code == 'SSF'){
  location <- unlist(str_split(data_file, '-'))[2] %>%
    str_remove(., '.csv')
}
  
  out_name <- glue(out_name_format)
  
  
  if(sensor == 'manta' & summary == 'N' & !'pH' %in% colnames(data)){
    
    out_name <- str_remove(out_name, '_pH')
    
  }
  
  if(sensor == 'manta' & summary == 'N' & !'Chlorophyll_A' %in% colnames(data)){
    
    out_name <- str_remove(out_name, '_ChlA')
    
  }
  

  # write out headers
  write_csv(data_headers, out_name, col_names = F)
  
  # pause for 2 seconds in case it's trying to append before the headers are written out
  Sys.sleep(2)

  # write out data
  write_csv(data, out_name, col_names = T, append = T)
  
  }

}

