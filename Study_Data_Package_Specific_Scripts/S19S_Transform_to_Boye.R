# ==============================================================================
#
# Turn S19S data into boye
#
# Status: In progress
#
# ==============================================================================
#
# Author: Brieanne Forbes 
# 20 April 2026
#
# ==============================================================================

library(tidyverse) 

rm(list=ls(all=T))

# =================================== user input ===============================

dp_folder <- 'Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_S19S_Sediment_v10/v10_WHONDRS_S19S_Sediment'

# =================================== list files ============================

all_files <- list.files(dp_folder, recursive = T, full.names = T)

inc_data <- all_files[grepl('Incubations_Respiration_Rates.csv',all_files)]

inc_methods <-  all_files[grepl('LabTracker_Incubations.csv',all_files)]

npoc_data <- all_files[grepl('Sediment_NPOC',all_files)]

npoc_icr_methods <-  all_files[grepl('LabTracker_FTICR_NPOC',all_files)]

norm_inc_data <- all_files[grepl('Normalized_Respiration_Rates.csv',all_files)]

cn_data <- all_files[grepl('CN.csv',all_files)]

grn_data <- all_files[grepl('GrainSize.csv',all_files)]

dwa_data <- all_files[grepl('Water_Mass_Volume.csv',all_files)]

fcs_data <- all_files[grepl('FlowCytometry.csv',all_files)]

iso_data <- all_files[grepl('Isotopes.csv',all_files)]

xrf_files <- all_files[grepl('WHONDRS_S19S_Sediment_XRF_Data',all_files)]

xrf_data <- all_files[grepl('XRF_ElementalAbundance.csv',all_files)]

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


# =================================== inc ============================

inc_methods_combine <- read_csv(inc_data) %>%
  # remove columns that were not publisehd with icon modex 
  select(-c(rate_mg_per_L_per_min,slope_of_the_regression )) %>%
  full_join(read_csv(inc_methods) %>% slice(-1) %>% select(-1))%>% 
  # remove methods column that isnt applicable to keep 
  select(-SED_INC_DESC) %>%
    arrange(Sample_ID)

inc_boye <- inc_methods_combine %>%
  mutate(INC_Method = case_when(INC_Method=='SED_INC_001' ~ NA,
                                         TRUE ~ INC_Method),
         Vial_Break_Method = case_when(Vial_Break_Method == 'VB_000' ~ NA,
                                                         TRUE ~ Vial_Break_Method)) %>%
  unite(Methods_Deviation, 
        INC_Method, Vial_Break_Method,
        sep = "; ", 
        na.rm = TRUE,  
        remove = TRUE) %>% 
  mutate(Methods_Deviation = ifelse(Methods_Deviation == "", "N/A", Methods_Deviation))%>%
  # rename cols to match icon modex
  rename(Respiration_Rate_mg_DO_per_L_per_H = rate_mg_per_L_per_h,
         Respiration_R_Squared = R_squared,
         Respiration_R_Squared_Adj = R_squared_adj,
         Respiration_p_value = p_value,
         Total_Incubation_Time_Min = total_incubation_time_min
  )  %>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  add_header_rows() %>%
  mutate(V4 = case_when(
    V1 == "Unit" ~ "milligrams per liter water per hour",
    V1 == "Unit_Basis" ~ "as rate of Oxygen consumed", 
    V1 == "MethodID_Analysis" ~ "INC_T_AN_000",
    V1 == "MethodID_Inspection" ~ "INC_T_IN_000",
    V1 == "MethodID_Storage" ~ "INC_T_ST_000",
    V1 == "MethodID_Preservation" ~ "INC_T_PRES_000",
    V1 == "MethodID_Preparation" ~ "INC_T_PREP_000",
    V1 == "MethodID_DataProcessing" ~ "INC_T_DP_000",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V4
  )) %>%
  mutate(across(V5:V11, ~ case_when(
    V1 %in% c("Unit", "Unit_Basis", "MethodID_Analysis", "MethodID_Inspection", 
              "MethodID_Storage", "MethodID_Preservation", "MethodID_Preparation", 
              "MethodID_DataProcessing", "Data_Status") ~ "N/A",
    V1 %in% c("Analysis_DetectionLimit", "Analysis_Precision") ~ "-9999",
    TRUE ~ .x
  )))
  

write_csv(inc_boye, str_replace(inc_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

inc_deviations <- inc_boye %>%
  slice(-(1:2))%>%
  janitor::row_to_names(row_number = 1)%>%
  slice(-(1:11)) %>%
  select(Sample_Name, Methods_Deviation) %>%
  filter(!Sample_Name=='')



# =================================== npoc/icr ============================

npoc_methods_combine <- read_csv(npoc_data)  %>% select(-1) %>%
  full_join(read_csv(npoc_icr_methods) %>% slice(-1) %>% select(-1))%>% 
  arrange(Sample_ID) 

npoc_icr_boye <- npoc_methods_combine %>%
  # remove columns that are unnecessary to provide and arent provided in other data packages 
  select(-c(Thaw_Date, Randomized_Method, NPOC_Dilution_Factor, C_Sample_Vol_mL, -C_DIW_Vol_mL, 
            SPE_NPOC_sample_concentration_mg.per.L.as.C,	SPE_sample_volume_mL,	Final_Concen_After_SPE_ppm,
            Methanol_elution_mL,FTICR_Ion_Accumulation_Time)) %>%
  # remove columns that all info will be in typical code
  select(-c(Sed_Extract_Method,	Frozen_Method, Thawed_Method, Precipitate_Description, 
            Filter_Method, Subsampling_Method, Acidification_Method, NPOC_Dilution_Method,
            Geochem_Method_QA_QC, ICR_Dilution_Method,	Acidification_After_Dilution_Method,
            SPE_Method, NPOC_Software_Method, NPOC_Dilution_Description, C_DIW_Vol_mL))%>%
  mutate(Vial_Break_Method = case_when(Vial_Break_Method=='VB_000' ~ NA,
                                TRUE ~ Vial_Break_Method),
         FTICR_Format_Method = case_when(FTICR_Format_Method == 'ICRFORM_001' ~ NA,
                                       TRUE ~ FTICR_Format_Method)) %>%
  unite(Methods_Deviation, 
        Vial_Break_Method, FTICR_Format_Method,
        sep = "; ", 
        na.rm = TRUE,  
        remove = TRUE)  %>% 
  mutate(
    Methods_Deviation = case_when(
      !is.na(str_extract(Extractable_NPOC_mg_per_L, "[A-Za-z]")) ~
        paste0(ifelse(Methods_Deviation == "" | is.na(Methods_Deviation) | Methods_Deviation == "N/A", 
                      "", paste0(Methods_Deviation, "; ")), "Geochem_QA_001"),
      TRUE ~ Methods_Deviation
    ),
    Methods_Deviation = ifelse(Methods_Deviation == "", "N/A", Methods_Deviation)
  )%>%
  add_column('FTICR-MS' = 'See_FTICR_folder_for_data', .before = 'Methods_Deviation')%>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  add_header_rows() %>%
  mutate(V4 = case_when(
    V1 == "Unit" ~ "milligrams per liter",
    V1 == "Unit_Basis" ~ "as extractable dissolvable Carbon",
    V1 == "MethodID_Analysis" ~ "NPOC_T_AN_022",
    V1 == "MethodID_Inspection" ~ "NPOC_T_IN_022",
    V1 == "MethodID_Storage" ~ "NPOC_T_ST_022",
    V1 == "MethodID_Preservation" ~ "NPOC_T_PRES_022",
    V1 == "MethodID_Preparation" ~ "NPOC_T_PREP_022",
    V1 == "MethodID_DataProcessing" ~ "NPOC_T_DP_022",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V4
  ),
  V5 = case_when(
    V1 == "Unit" ~ "milligrams per liter",
    V1 == "Unit_Basis" ~ "as extractable dissolvable Carbon",
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



# =================================== norm inc ============================

norm_inc_boye <- read_csv(norm_inc_data) %>%
  # rename to match ICON-ModEx
  rename(Normalized_Respiration_Rate_mg_DO_per_H_per_L_wet_sediment = Normalized_Respiration_Rate_mg_DO_per_H_per_L_sediment)%>%
  rename(Sample_Name = Sample_ID) %>%
  # join methods deviatoins from INC
  full_join(inc_deviations)%>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name)%>%
  add_header_rows()%>%
  mutate(V4 = case_when(
    V1 == "Unit" ~ "milligrams per liter water per hour",
    V1 == "Unit_Basis" ~ "as rate of Oxygen consumed", 
    V1 == "MethodID_Analysis" ~ "INC_T_AN_001",
    V1 == "MethodID_Inspection" ~ "INC_T_IN_001",
    V1 == "MethodID_Storage" ~ "INC_T_ST_001",
    V1 == "MethodID_Preservation" ~ "INC_T_PRES_001",
    V1 == "MethodID_Preparation" ~ "INC_T_PREP_001",
    V1 == "MethodID_DataProcessing" ~ "INC_T_DP_001",
    V1 == "Analysis_DetectionLimit" ~ "-9999",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ V4
  ))

write_csv(norm_inc_boye, str_replace(norm_inc_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== cn ==================================

cn_boye <- read_csv(cn_data) %>%
  select(-Study_Code) %>%
  rename('01395_C_percent' = '01395_C_percent_per_mg',
         '01397_N_percent' = '01397_N_percent_per_mg')%>%
  rename(Sample_Name = Sample_ID) %>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name)%>%
  mutate(Methods_Deviation = case_when(Sample_Name %in% c("S19S_0062_BULK-D", "S19S_0012_BULK-M", "S19S_0012_BULK-U", 
                                                            "S19S_0049_BULK-U", "S19S_0056_BULK-M", "S19S_0069_BULK-M", 
                                                            "S19S_0071_BULK-D", "S19S_0085_BULK-U") ~ "CN_RERUN_001",
                                       TRUE ~ "N/A" )) %>%
  add_header_rows() %>%
  #add in header values
  mutate(
    V4 = case_when(
      V1 == "MethodID_Inspection" ~ "CN_T_IN_003",
      V1 == "MethodID_Storage" ~ "CN_T_ST_003", 
      V1 == "MethodID_Preservation" ~ "CN_T_PRES_003",
      V1 == "MethodID_Preparation" ~ "CN_T_PREP_003",
      V1 == "MethodID_Analysis" ~ "CN_T_AN_003",
      V1 == "MethodID_DataProcessing" ~ "CN_T_DP_003",
      V1 == "Unit" ~ "percent",
      V1 == "Unit_Basis" ~ "as percent Carbon dry weight",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == 'Data_Status' ~ 'ready_to_use',
      TRUE ~ V4  
    ),
    V5 = case_when(
      V1 == "MethodID_Inspection" ~ "CN_T_IN_003",
      V1 == "MethodID_Storage" ~ "CN_T_ST_003", 
      V1 == "MethodID_Preservation" ~ "CN_T_PRES_003",
      V1 == "MethodID_Preparation" ~ "CN_T_PREP_003",
      V1 == "MethodID_Analysis" ~ "CN_T_AN_003",
      V1 == "MethodID_DataProcessing" ~ "CN_T_DP_003",
      V1 == "Unit" ~ "percent",
      V1 == "Unit_Basis" ~ "as percent Carbon dry weight",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == 'Data_Status' ~ 'ready_to_use',
      TRUE ~ V5 
    )
  )


write_csv(cn_boye, str_replace(cn_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== grn =================================

grn_boye <- read_csv(grn_data) %>%
  select(-Study_Code) %>%
  mutate( Sample_ID = Sample_ID %>%
            str_replace("_U$", "-U") %>%
            str_replace("_M$", "-M") %>%
            str_replace("_D$", "-D")) %>%
  full_join(readxl::read_excel("C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC4/Grain_Size/01_RawData/20220816_Mapping_Raw_GRN_SBR_RC4_S19S_1-277/20220816_Mapping_Raw_GRN_SBR_RC4_S19S_1-277.xlsx", skip =1) %>% 
              select(Sample_ID, Method_Deviation)) %>%
  rename(Sample_Name = Sample_ID,
         Methods_Deviation = Method_Deviation) %>% 
  mutate(Methods_Deviation = case_when(is.na(Methods_Deviation) ~ 'N/A',
                                       TRUE ~ Methods_Deviation),
         Methods_Deviation = str_replace(Methods_Deviation, ',', ';')) %>%
  # three samples were showing 100% silt but it was because of an error in the code, the deviation indicates they were not run, making all values -9999
  mutate(
    across(c(Percent_Fine_Sand, Percent_Med_Sand, Percent_Coarse_Sand, 
             Percent_Tot_Sand, Percent_Clay, Percent_Silt), 
           ~ case_when(
             str_detect(Methods_Deviation, "GRN_PREP_002") ~ -9999,
             TRUE ~ .x
           ))
  ) %>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name)%>%
  add_header_rows() %>%
  #add in header values
  mutate(across(V4:V9, ~ case_when(
    V1 == "Unit" ~ "percent",
    V1 == "Unit_Basis" ~ "as percent of dry weight",
    V1 == "MethodID_Analysis" ~ "GRN_T_AN_001",
    V1 == "MethodID_Inspection" ~ "GRN_T_IN_001",
    V1 == "MethodID_Storage" ~ "GRN_T_ST_001",
    V1 == "MethodID_Preservation" ~ "GRN_T_PRES_001",
    V1 == "MethodID_Preparation" ~ "GRN_T_PREP_001",
    V1 == "MethodID_DataProcessing" ~ "GRN_T_DP_001",
    V1 == "Analysis_DetectionLimit" ~ "0",
    V1 == "Analysis_Precision" ~ "-9999",
    V1 == "Data_Status" ~ "ready_to_use",
    TRUE ~ .x
  ))
  )


write_csv(grn_boye, str_replace(grn_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== dwa =================================

dwa_boye <- read_csv(dwa_data) %>%
  rename(Sample_Name = Sample_ID) %>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name)%>%
  mutate(Methods_Deviation = case_when(Sample_Name %in% c("S19S_0006_SED_INC-D", "S19S_0006_SED_INC-M", "S19S_0006_SED_INC-U", 
                                                          "S19S_0007_SED_INC-D", "S19S_0007_SED_INC-M", "S19S_0007_SED_INC-U", 
                                                          "S19S_0008_SED_INC-D", "S19S_0008_SED_INC-M", "S19S_0008_SED_INC-U", 
                                                          "S19S_0009_SED_INC-D", "S19S_0009_SED_INC-M", "S19S_0009_SED_INC-U", 
                                                          "S19S_0010_SED_INC-D", "S19S_0010_SED_INC-M", "S19S_0010_SED_INC-U", 
                                                          "S19S_0036_SED_INC-M") ~ "INC_QA_003",
                                       TRUE ~ "N/A" )) %>%
  add_header_rows() %>%
  #add in header values
  mutate(
    V4 = case_when(
      V1 == "Unit" ~ "grams",
      V1 == "Unit_Basis" ~ "as Wet Sediment",
      V1 == "MethodID_Analysis" ~ "DWA_T_AN_001",
      V1 == "MethodID_Inspection" ~ "DWA_T_IN_001",
      V1 == "MethodID_Storage" ~ "DWA_T_ST_001",
      V1 == "MethodID_Preservation" ~ "DWA_T_PRES_001",
      V1 == "MethodID_Preparation" ~ "DWA_T_PREP_001",
      V1 == "MethodID_DataProcessing" ~ "DWA_T_DP_001",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V4
    ),
    
    V5 = case_when(
      V1 == "Unit" ~ "grams",
      V1 == "Unit_Basis" ~ "as Dry Sediment",
      V1 == "MethodID_Analysis" ~ "DWA_T_AN_001",
      V1 == "MethodID_Inspection" ~ "DWA_T_IN_001",
      V1 == "MethodID_Storage" ~ "DWA_T_ST_001",
      V1 == "MethodID_Preservation" ~ "DWA_T_PRES_001",
      V1 == "MethodID_Preparation" ~ "DWA_T_PREP_001",
      V1 == "MethodID_DataProcessing" ~ "DWA_T_DP_001",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V5
    ),
    
    V6 = case_when(
      V1 == "Unit" ~ "grams",
      V1 == "Unit_Basis" ~ "as Water",
      V1 == "MethodID_Analysis" ~ "DWA_T_AN_001",
      V1 == "MethodID_Inspection" ~ "DWA_T_IN_001",
      V1 == "MethodID_Storage" ~ "DWA_T_ST_001",
      V1 == "MethodID_Preservation" ~ "DWA_T_PRES_001",
      V1 == "MethodID_Preparation" ~ "DWA_T_PREP_001",
      V1 == "MethodID_DataProcessing" ~ "DWA_T_DP_001",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V6
    ),
    
    V7 = case_when(
      V1 == "Unit" ~ "milliliters",
      V1 == "Unit_Basis" ~ "as Wet Sediment",
      V1 == "MethodID_Analysis" ~ "DWA_T_AN_001",
      V1 == "MethodID_Inspection" ~ "DWA_T_IN_001",
      V1 == "MethodID_Storage" ~ "DWA_T_ST_001",
      V1 == "MethodID_Preservation" ~ "DWA_T_PRES_001",
      V1 == "MethodID_Preparation" ~ "DWA_T_PREP_001",
      V1 == "MethodID_DataProcessing" ~ "DWA_T_DP_001",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V7
    ))


write_csv(dwa_boye, str_replace(dwa_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)


# =================================== fcs =================================


fcs_boye <- read_csv(fcs_data) %>%
  select(-Study_Code) %>%
  rename(Sample_Name = Sample_ID) %>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name)%>%
  add_column(Methods_Deviation = "N/A" ) %>%
  # 0097 was compiled across two locations (0097 and 0098) so throwing out the data; 0058 had -9999 for hetero and it was red in raw data so throwing out all values
  mutate(across(c(Total_Bacteria_cells_per_gram, Total_Photorophs_cells_per_gram, Total_Heterotrophs_cells_per_gram), 
                ~ case_when(
                  str_detect(Sample_Name, "S19S_0097_FCS|S19S_0058_FCS-M") ~ -9999,
                  TRUE ~ .x
                )))
  add_header_rows() %>%
  #add in header values
  mutate(
    V4 = case_when(
      V1 == "Unit" ~ "cells per gram",
      V1 == "MethodID_Analysis" ~ "FCS_T_AN_000",
      V1 == "MethodID_Inspection" ~ "FCS_T_IN_000",
      V1 == "MethodID_Storage" ~ "FCS_T_ST_000",
      V1 == "MethodID_Preservation" ~ "FCS_T_PRES_000",
      V1 == "MethodID_Preparation" ~ "FCS_T_PREP_000",
      V1 == "MethodID_DataProcessing" ~ "FCS_T_DP_000",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V4
    ),
    
    V5 = case_when(
      V1 == "Unit" ~ "cells per gram",
      V1 == "MethodID_Analysis" ~ "FCS_T_AN_000",
      V1 == "MethodID_Inspection" ~ "FCS_T_IN_000",
      V1 == "MethodID_Storage" ~ "FCS_T_ST_000",
      V1 == "MethodID_Preservation" ~ "FCS_T_PRES_000",
      V1 == "MethodID_Preparation" ~ "FCS_T_PREP_000",
      V1 == "MethodID_DataProcessing" ~ "FCS_T_DP_000",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V5
    ),
    
    V6 = case_when(
      V1 == "Unit" ~ "cells per gram",
      V1 == "MethodID_Analysis" ~ "FCS_T_AN_000",
      V1 == "MethodID_Inspection" ~ "FCS_T_IN_000",
      V1 == "MethodID_Storage" ~ "FCS_T_ST_000",
      V1 == "MethodID_Preservation" ~ "FCS_T_PRES_000",
      V1 == "MethodID_Preparation" ~ "FCS_T_PREP_000",
      V1 == "MethodID_DataProcessing" ~ "FCS_T_DP_000",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V6
    )
  )


write_csv(fcs_boye, str_replace(fcs_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)

# =================================== iso =================================


iso_boye <- read_csv(iso_data) %>%
  select(-Study_Code, -Date_Run) %>%
  rename(Sample_Name = Sample_ID) %>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name)%>%
  mutate(Methods_Deviation = case_when(Sample_Name %in% c("S19S_0062_BULK-D", "S19S_0012_BULK-M", "S19S_0012_BULK-U", 
                                                          "S19S_0049_BULK-U", "S19S_0056_BULK-M", "S19S_0069_BULK-M", 
                                                          "S19S_0071_BULK-D", "S19S_0085_BULK-U") ~ "ISO_RERUN_001",
                                       TRUE ~ "N/A" )) %>%
  add_header_rows() %>%
  #add in header values
  mutate(
    V4 = case_when(
      V1 == "Unit" ~ "per mil",
      V1 == "Unit_Basis" ~ "relative to Vienna Pee Dee Belemnite",
      V1 == "MethodID_Analysis" ~ "ISO_T_AN_000",
      V1 == "MethodID_Inspection" ~ "ISO_T_IN_000",
      V1 == "MethodID_Storage" ~ "ISO_T_ST_000",
      V1 == "MethodID_Preservation" ~ "ISO_T_PRES_000",
      V1 == "MethodID_Preparation" ~ "ISO_T_PREP_000",
      V1 == "MethodID_DataProcessing" ~ "ISO_T_DP_000",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V4
    ),
    
    V5 = case_when(
      V1 == "Unit" ~ "per mil",
      V1 == "Unit_Basis" ~ "relative to Vienna Pee Dee Belemnite",
      V1 == "MethodID_Analysis" ~ "ISO_T_AN_000",
      V1 == "MethodID_Inspection" ~ "ISO_T_IN_000",
      V1 == "MethodID_Storage" ~ "ISO_T_ST_000",
      V1 == "MethodID_Preservation" ~ "ISO_T_PRES_000",
      V1 == "MethodID_Preparation" ~ "ISO_T_PREP_000",
      V1 == "MethodID_DataProcessing" ~ "ISO_T_DP_000",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ V5
    )
  )


write_csv(iso_boye, str_replace(iso_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)


# =================================== xrf ============================


xrf_boye <- read_csv(xrf_data) %>%
  rename(Sample_Name = Sample_ID) %>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  arrange(Sample_Name) %>%
  add_column(Methods_Deviation = "N/A" ) %>%
  add_header_rows() %>%
  #add in header values
  mutate(
    across(V4:V14, ~ case_when(
      V1 == "Unit" ~ "weight percent",
      V1 == "MethodID_Analysis" ~ "XRF_T_AN_000",
      V1 == "MethodID_Inspection" ~ "XRF_T_IN_000",
      V1 == "MethodID_Storage" ~ "XRF_T_ST_000",
      V1 == "MethodID_Preservation" ~ "XRF_T_PRES_000",
      V1 == "MethodID_Preparation" ~ "XRF_T_PREP_000",
      V1 == "MethodID_DataProcessing" ~ "XRF_T_DP_000",
      V1 == "Analysis_DetectionLimit" ~ "-9999",
      V1 == "Analysis_Precision" ~ "-9999",
      V1 == "Data_Status" ~ "ready_to_use",
      TRUE ~ .x
    ))
  )


write_csv(xrf_boye, str_replace(xrf_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)
