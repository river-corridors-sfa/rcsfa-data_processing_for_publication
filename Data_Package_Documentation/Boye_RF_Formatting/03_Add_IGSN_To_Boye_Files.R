# ==============================================================================
#
# Add IGSNs into data files
#
# Status: Complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 9 Nov 2023
#
# ==============================================================================

library(tidyverse)
library(crayon)
library(rstudioapi) 

rm(list=ls(all=T))

# ================================= User inputs ================================

dp_dir <- selectDirectory()


#number of digits in the parent ID
parent_id_number <- 7

file <- file.choose()

# ================================== read files ================================

top <- read_csv(file, n_max = 2, col_names = F) %>%
  select(1:2)

header <- read_csv(file, skip = 2, n_max = 11) %>%
  mutate(IGSN = Sample_Name, .after = 'Sample_Name')

if(str_detect(dp_dir, 'BSLE')){ # bsle sample names are different
  
data <- read_csv(file, skip = 2) %>%
  filter(!Sample_Name %in% c('N/A', '-9999')) %>%
  mutate(Parent_ID = str_extract(Sample_Name, '.+(?=-)'))

} else if(str_detect(dp_dir, 'EWEB')){ # EWEB is different
  
  data <- read_csv(file, skip = 2) %>%
    filter(!Sample_Name %in% c('N/A', '-9999')) %>%
    # mutate(Parent_ID = Sample_Name)%>% # BPCA
    # mutate(Parent_ID = str_extract(Sample_Name, '.+(?=-)'))%>% # EEMs
    mutate(Parent_ID = str_extract(Sample_Name, '.+(?=-)')) # ICR
  
} else{
  
  data <- read_csv(file, skip = 2) %>%
    filter(!Sample_Name %in% c('N/A', '-9999')) %>%
    mutate(Parent_ID = str_extract(Sample_Name, paste0('.{', parent_id_number, '}')))
  
}

material <- data %>%
  select(Material) %>%
  filter(!is.na(Material)) %>%
  distinct() %>%
  pull()


if(str_detect(dp_dir, 'EC|EV')){ # IGSN in field metadata for ECA so having to pull in a different way
  
  igsn <- read_csv(list.files(dp_dir, 'Metadata', full.names = T)) %>%
    select(Parent_ID, IGSN) 
  
} else if(str_detect(dp_dir, 'BSLE')){ # have to pull BSLE in a different way
  
  igsn <- read_csv(list.files(dp_dir, 'IGSN', full.names = T), skip = 1) %>%
    select(Sample_Name, IGSN, Material) %>%
    # filter(Material == material) %>%
    mutate(Parent_ID = Sample_Name) %>%
    select(-Sample_Name, -Material)
  
} else if(str_detect(dp_dir, 'EWEB')){ # have to pull EWEB in a different way
  
  igsn <- read_csv(list.files(dp_dir, 'metadata', full.names = T)) %>%
    select(Sample_Name, IGSN) %>%
    mutate(Parent_ID = Sample_Name) %>%
    select(-Sample_Name)
  
} else{
  igsn <- read_csv(list.files(dp_dir, 'IGSN', full.names = T), skip = 1) %>%
    select(Sample_Name, IGSN, Material) %>%
    filter(Material == material) %>%
    mutate(Parent_ID = str_extract(Sample_Name, paste0('.{', parent_id_number, '}'))) %>%
    select(-Sample_Name, -Material)
  
  }

# ====================== add IGSN ==============================================

combine <- data %>%
  left_join(igsn, by = 'Parent_ID') %>%
  relocate(IGSN, .after = 'Sample_Name') %>%
  select(-Parent_ID)

if(str_detect(dp_dir, 'BSLE')){ # need to pull igsns for combined leachates
  
  igsn_pooled <-  read_csv(list.files(dp_dir, 'IGSN', full.names = T), skip = 1) %>%
    select(Sample_Name, IGSN, Material) %>%
    filter(Material == 'Liquid>aqueous')%>%
    select( -Material) %>%
    mutate(Parent_ID = sub("([A-Z]+_\\d+).*", "\\1", Sample_Name),
           Parent_ID = paste0(Parent_ID, 'ABC')) %>% # Extract Base as BSLE_001
    group_by(Parent_ID) %>%
    summarise(IGSN = paste(IGSN, collapse = "; ")) %>%
    ungroup()
  
  combine <- combine %>%
    mutate(Parent_ID = str_extract(Sample_Name, '.+(?=-)')) %>%
    left_join(igsn_pooled, by = "Parent_ID", suffix = c("", "_new")) %>%
    mutate(IGSN = coalesce(IGSN, IGSN_new)) %>%
    select(-IGSN_new, -Parent_ID)
  
}

igsn_missing <- combine %>%
  filter(!is.na(Sample_Name), is.na(IGSN))

if(nrow(igsn_missing) > 0){
  
  cat(
    red$bold(
      'Wait! Some samples are missing IGSNs'
    )
  )
  
  view(igsn_missing)
  
  user <- (readline(prompt = "Is it okay that these samples are missing IGSNs? (Y/N) "))
  
  if(user == 'Y'){
    
    combine <- combine %>%
      mutate(IGSN = case_when(is.na(IGSN)~'N/A', 
                              TRUE ~ IGSN),
             IGSN = case_when(Field_Name == '#End_Data'~ NA, 
                              TRUE ~ IGSN))
  }
} else {
  user <- "Y"
}

 
# ======================== write out ===========================================   

# if there are either no missing igsns or if missing igsns have been approved to be okay, then export
if (user == "Y") {

  # update top count of columns
  top[1, 2] <- length(combine) - 1
      
  write_csv(top, file, col_names = F)
  
  # pausing between exports because headers aren't writing out fast enough before next line attempts to append data
  Sys.sleep(2)
  
  write_csv(header, file, col_names = T, append = T)
  
  Sys.sleep(2)
  
  write_csv(combine, file, append = T, na = '')
    
  # opens folder
  # shell.exec(dirname(file))
  
}


