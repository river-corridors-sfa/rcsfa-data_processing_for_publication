# ==============================================================================
#
# Make a summary file of means for SSS Cotton strips
#
# 
# ==============================================================================
#
# Author: Brieanne Forbes, brieanne.forbes@pnnl.gov
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

dir <- 'C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/'

RC <- 'RC2'

study_code <- 'SSS'

# ====================================== Build dir name ========================

boye_dir <- paste0(dir, RC, '/Boye_Files/', study_code, '/')

# ================================= Wrangle data and summarize =================

COT_file <- list.files(boye_dir, 'CottonStrip', full.names = T)


# ======================================= DIC ==================================


  COT_boye_headers <- read_csv(COT_file, n_max = 11, skip = 2, na = '-9999')%>%
    select(-'Methods_Deviation')
  

  COT_data <- read_csv(COT_file, skip = 2, na = '-9999') %>%
    filter(!Sample_Name %in% c('N/A', '-9999', NA),
           Field_Name != '#End_Data') %>%
    mutate(Field_Name = 'N/A',
           Sample_Name = str_remove(Sample_Name, '-1'),
           Sample_Name = str_remove(Sample_Name, '-2'),
           Sample_Name = str_remove(Sample_Name, '-3'),
           Sample_Name = str_remove(Sample_Name, '-4'),
           Sample_Name = str_remove(Sample_Name, '_COT'),
           Tensile_Strength = as.numeric(Tensile_Strength),
           Decay_Rate = as.numeric(Decay_Rate)
    )
  
  COT_summary <- COT_data %>%
    group_by(Sample_Name) %>%
    mutate(count = sum(!is.na(Tensile_Strength))) %>%
    summarize(
      Field_Name = NA,
      Material = unique(Material),
      Mean_Tensile_Strength = mean(Tensile_Strength, na.rm = T),
      Mean_Decay_Rate = mean(Decay_Rate, na.rm = T),
      Mean_Missing_Reps = ifelse(count<4, TRUE, FALSE),
      count = unique(count)
    ) %>%
    filter(!is.na(Sample_Name)) %>%
    select(Field_Name, Sample_Name, Material, Mean_Tensile_Strength, Mean_Decay_Rate, Mean_Missing_Reps)%>%
    distinct() %>%
    mutate(Mean_Tensile_Strength = round(Mean_Tensile_Strength, 2),
           Mean_Decay_Rate = round(Mean_Decay_Rate, 4))
  


# ======================================= Ions ==================================


# ==================================== Combine =================================

  COT_summary$Field_Name[1] <- '#Start_Data'

  COT_summary <- COT_summary %>%
  mutate_if(is.numeric, replace_na, replace = -9999)%>%
  mutate_if(is.character, replace_na, replace = 'N/A')%>%
  relocate(Mean_Missing_Reps, .after = last_col())

  COT_summary[nrow(COT_summary)+1,1] = "#End_Data"

  COT_boye_headers <- COT_boye_headers %>%
  add_column(Mean_Missing_Reps = 'N/A')%>% 
    select(-Total_Incubation_Days, -Appearance_Notes) %>%
    rename(Mean_Tensile_Strength = Tensile_Strength,
           Mean_Decay_Rate = Decay_Rate)


# =================================== Write File ===============================

columns <- length(COT_summary)-1

header_rows <- length(COT_boye_headers$Field_Name) + 1

top <- tibble('one' = as.character(),
              'two' = as.numeric()) %>%
  add_row(one = '#Columns',
          two = columns) %>%
  add_row(one = '#Header_Rows',
          two = header_rows)

summary_out_file <- paste0(boye_dir, study_code, '_Summary_', Sys.Date(), '.csv')

write_csv(top, summary_out_file, col_names = F)

write_csv(COT_boye_headers, summary_out_file, append = T, col_names = T)

write_csv(COT_summary, summary_out_file, append = T, na = '')

