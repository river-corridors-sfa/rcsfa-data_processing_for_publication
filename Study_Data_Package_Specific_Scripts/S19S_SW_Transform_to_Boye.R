# ==============================================================================
#
# Turn S19S data into boye
#
# Status: in progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 10 July 2026
#
# ==============================================================================

library(tidyverse) 

rm(list=ls(all=T))

# =================================== user input ===============================

dp_folder <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_S19S_SW_v8/v8_WHONDRS_S19S_SW'

# =================================== list files ============================

all_files <- list.files(dp_folder, recursive = T, full.names = T)

all_files <- all_files[!grepl('BoyeTransformed',all_files)]

npoc_data <- all_files[grepl('SW_NPOC',all_files)]

npoc_icr_methods <-  all_files[grepl('SW_FTICR_NPOC',all_files)]

iso_data <- all_files[grepl('SW_Isotopes.csv',all_files)]

iso_methods <- all_files[grepl('Tracker_Isotopes.csv',all_files)]

dic_data <- all_files[grepl('DIC.csv',all_files)]

fcs_data <- all_files[grepl('FlowCytometry.csv',all_files)]

anion_TN_data <- all_files[grepl('SpC_Anions_TN.csv',all_files)]

anion_TN_methods <- all_files[grepl('Tracker_Anions_TN.csv',all_files)]

# =================================== boye function ============================
add_header_rows <- function(input_file) {
  # Get column count (original columns only)
  n_cols <- ncol(input_file)
  # Create header rows as a proper input_file frame - 14 rows total to match the format [2]
  # Create column names for the header structure
  col_names <- paste0("V", 1:(n_cols + 1))
  
  # Define special values for sample/material columns
  sample_values <- c("N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "-9999", "-9999", "N/A")
  
  # Function to get values for each column based on column name
  get_column_values <- function(col_name) {
    if (grepl("Sample_Name|Sample_ID|Material", col_name, ignore.case = TRUE)) {
      return(sample_values)
    } else if (grepl("Methods_Deviation", col_name, ignore.case = TRUE)) {
      return(rep("N/A", 11))
    } else {
      return(rep("[FILL IN]", 11))
    }
  }
  
  # Build each header row as a named vector, then combine
  header_input_file <- list(
    # Row 1: #Columns
    c("#Columns", as.character(n_cols), rep("", n_cols - 1)),
    # Row 2: #Header_Rows  
    c("#Header_Rows", "12", rep("", n_cols - 1)),
    # Row 3: Field_Name
    c("Field_Name", names(input_file))
  )
  
  # Add rows 4-14 with conditional values
  row_names <- c("Unit", "Unit_Basis", "MethodID_Analysis", "MethodID_Inspection", 
                 "MethodID_Storage", "MethodID_Preservation", "MethodID_Preparation", 
                 "MethodID_DataProcessing", "Analysis_DetectionLimit", "Analysis_Precision", 
                 "Data_Status")
  
  for (i in seq_along(row_names)) {
    row_values <- c(row_names[i], map_chr(names(input_file), ~get_column_values(.x)[i]))
    header_input_file <- append(header_input_file, list(row_values))
  }
  
  # Convert to input_file frame
  header_rows <- map_dfr(header_input_file, ~{
    names(.x) <- col_names
    as_tibble(t(.x))
  })
  
  # Convert input_file to character and keep original structure
  input_file_rows <- input_file %>%
    mutate(across(everything(), as.character))
  
  # Add the first column for input_file rows - first row gets "#Start_input_file", rest get "N/A"
  first_col_values <- c("#Start_Data", rep("N/A", nrow(input_file_rows) - 1))
  input_file_with_first_col <- tibble(V1 = first_col_values) %>%
    bind_cols(input_file_rows)
  
  # Ensure consistent column names
  names(input_file_with_first_col) <- col_names
  
  # Combine header and input_file
  result <- bind_rows(header_rows, input_file_with_first_col)
  
  # Add end marker
  end_row <- rep("", n_cols + 1)
  end_row[1] <- "#End_Data"
  names(end_row) <- col_names
  result <- bind_rows(result, as_tibble(t(end_row)))
  
  return(result)
}


# =================================== npoc/icr ============================

npoc_methods_combine <- read_csv(npoc_data)  %>% select(-1) 

# dont need to join because there are no deviations 
# %>%
#   full_join(read_csv(npoc_icr_methods) %>% slice(-1) %>% select(-1))%>% 
#   arrange(Sample_ID) 

npoc_icr_boye <- npoc_methods_combine %>%
  mutate(
    Methods_Deviation = case_when(
      str_detect(`00681_NPOC_mg_per_L_as_C`, "[A-Za-z]") ~ "Geochem_QA_002",
      TRUE ~ "N/A"
    )
  )%>%
  add_column('FTICR-MS' = 'See_FTICR_folder_for_data', .before = 'Methods_Deviation')%>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Liquid>aqueous', .after = 'Sample_Name') %>%
  add_header_rows() %>%
  mutate(V4 = case_when(
    V1 == "Unit" ~ "milligrams per liter",
    V1 == "Unit_Basis" ~ "as dissolvable Carbon",
    V1 == "MethodID_Analysis" ~ "NPOC_T_AN_023",
    V1 == "MethodID_Inspection" ~ "NPOC_T_IN_023",
    V1 == "MethodID_Storage" ~ "NPOC_T_ST_023",
    V1 == "MethodID_Preservation" ~ "NPOC_T_PRES_023",
    V1 == "MethodID_Preparation" ~ "NPOC_T_PREP_023",
    V1 == "MethodID_DataProcessing" ~ "NPOC_T_DP_023",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V4
  ),
  V5 = case_when(
    V1 == "Unit" ~ "N/A",
    V1 == "Unit_Basis" ~ "N/A",
    V1 == "MethodID_Analysis" ~ "ICR_T_AN_021",
    V1 == "MethodID_Inspection" ~ "ICR_T_IN_021",
    V1 == "MethodID_Storage" ~ "ICR_T_ST_021",
    V1 == "MethodID_Preservation" ~ "ICR_T_PRES_021",
    V1 == "MethodID_Preparation" ~ "ICR_T_PREP_021",
    V1 == "MethodID_DataProcessing" ~ "ICR_T_DP_021",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V5
  ))

write_csv(npoc_icr_boye, str_replace(npoc_data, '.csv', '_FTICR_BoyeTransformed.csv'), na = '-9999', col_names = F)
# =================================== iso ============================

iso_methods_combine <- read_csv(iso_data)  %>% select(-1) 

# dont need to join because there are no deviations 
# %>%
#   full_join(read_csv(iso_methods) %>% slice(-1) %>% select(-1))%>% 
#   arrange(Sample_ID) 

iso_boye <- iso_methods_combine %>%
  add_column(Methods_Deviation = 'N/A') %>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Liquid>aqueous', .after = 'Sample_Name') %>%
  mutate(Date_Run = paste0(' ', as.character(Date_Run))) %>%
  add_header_rows() %>%
  mutate(across(V4:V9, ~ case_when(
    V1 == "Unit" ~ "[FILL IN UNIT]",
    V1 == "Unit_Basis" ~ "[FILL IN UNIT]",
    V1 == "MethodID_Analysis" ~ "ISO_T_AN_003",
    V1 == "MethodID_Inspection" ~ "ISO_T_IN_003",
    V1 == "MethodID_Storage" ~ "ISO_T_ST_003",
    V1 == "MethodID_Preservation" ~ "ISO_T_PRES_003",
    V1 == "MethodID_Preparation" ~ "ISO_T_PREP_003",
    V1 == "MethodID_DataProcessing" ~ "ISO_T_DP_003",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ .x
  ))
  )

write_csv(iso_boye, str_replace(iso_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== dic ============================

dic_boye <- read_csv(dic_data)  %>% select(-1) %>%
  add_column(Methods_Deviation = 'N/A') %>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Liquid>aqueous', .after = 'Sample_Name') %>%
  add_header_rows() %>%
  mutate(V4 = case_when(
    V1 == "Unit" ~ "milligrams per liter",
    V1 == "Unit_Basis" ~ "as Carbon",
    V1 == "MethodID_Analysis" ~ "DIC_T_AN_000",
    V1 == "MethodID_Inspection" ~ "DIC_T_IN_000",
    V1 == "MethodID_Storage" ~ "DIC_T_ST_000",
    V1 == "MethodID_Preservation" ~ "DIC_T_PRES_000",
    V1 == "MethodID_Preparation" ~ "DIC_T_PREP_000",
    V1 == "MethodID_DataProcessing" ~ "DIC_T_DP_000",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V4
  )
  )

write_csv(dic_boye, str_replace(dic_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== fcs ============================

fcs_boye <- read_csv(fcs_data)  %>% select(-1)  %>%
  add_column(Methods_Deviation = 'N/A') %>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Liquid>aqueous', .after = 'Sample_Name') %>%
  add_header_rows() %>%
  mutate(across(V4:V6, ~ case_when(
    V1 == "Unit" ~ "cells per liter",
    V1 == "Unit_Basis" ~ "[FILL IN UNIT]",
    V1 == "MethodID_Analysis" ~ "FCS_T_AN_001",
    V1 == "MethodID_Inspection" ~ "FCS_T_IN_001",
    V1 == "MethodID_Storage" ~ "FCS_T_ST_001",
    V1 == "MethodID_Preservation" ~ "FCS_T_PRES_001",
    V1 == "MethodID_Preparation" ~ "FCS_T_PREP_001",
    V1 == "MethodID_DataProcessing" ~ "FCS_T_DP_001",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ .x
  ))
  )

write_csv(fcs_boye, str_replace(fcs_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== anion/tn ============================

anion_tn_methods_combine <- read_csv(anion_TN_data)  %>% select(-1) 

# dont need to join because there are no deviations 
# %>%
#   full_join(read_csv(anion_tn_methods) %>% slice(-1) %>% select(-1))%>% 
#   arrange(Sample_ID) 

anion_tn_boye <- anion_tn_methods_combine %>%
  mutate(
    Methods_Deviation = case_when(
      if_any(2:8, ~ str_detect(.x, "[A-Za-z]")) ~ "Geochem_QA_002",
      TRUE ~ "N/A"
    )
  ) %>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Liquid>aqueous', .after = 'Sample_Name') %>%
  add_header_rows() %>%
  mutate(across(V5:V9, ~ case_when(
    V1 == "Unit" ~ "milligrams per liter",
    V1 == "Unit_Basis" ~ "[FILL IN UNIT]",
    V1 == "MethodID_Analysis" ~ "ION_T_AN_009",
    V1 == "MethodID_Inspection" ~ "ION_T_IN_009",
    V1 == "MethodID_Storage" ~ "ION_T_ST_009",
    V1 == "MethodID_Preservation" ~ "ION_T_PRES_009",
    V1 == "MethodID_Preparation" ~ "ION_T_PREP_009",
    V1 == "MethodID_DataProcessing" ~ "ION_T_DP_009",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ .x
  ))
  ) %>%
  mutate(V4 = case_when(
    V1 == "Unit" ~ "microsiemens per centimeter",
    V1 == "Unit_Basis" ~ "as microsiemens per centimeter",
    V1 == "MethodID_Analysis" ~ "SpC_T_AN_000",
    V1 == "MethodID_Inspection" ~ "SpC_T_IN_000",
    V1 == "MethodID_Storage" ~ "SpC_T_ST_000",
    V1 == "MethodID_Preservation" ~ "SpC_T_PRES_000",
    V1 == "MethodID_Preparation" ~ "SpC_T_PREP_000",
    V1 == "MethodID_DataProcessing" ~ "SpC_T_DP_000",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V4
  ),
  V10 = case_when(
    V1 == "Unit" ~ "milligrams per liter",
    V1 == "Unit_Basis" ~ "as dissolvable Nitrogen",
    V1 == "MethodID_Analysis" ~ "TN_T_AN_019",
    V1 == "MethodID_Inspection" ~ "TN_T_IN_019",
    V1 == "MethodID_Storage" ~ "TN_T_ST_019",
    V1 == "MethodID_Preservation" ~ "TN_T_PRES_019",
    V1 == "MethodID_Preparation" ~ "TN_T_PREP_019",
    V1 == "MethodID_DataProcessing" ~ "TN_T_DP_019",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V10
  ))

write_csv(anion_tn_boye, str_replace(anion_TN_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

