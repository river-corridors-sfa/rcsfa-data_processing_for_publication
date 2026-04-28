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

# =================================== boye function ============================

add_header_rows <- function(input_file) {
  
  # Get column count (original columns only)
  n_cols <- ncol(input_file)
  
  # Create header rows as a proper input_file frame - 14 rows total to match the format [2]
  
  # Create column names for the header structure
  col_names <- paste0("V", 1:(n_cols + 1))
  
  # Build each header row as a named vector, then combine
  header_input_file <- list(
    # Row 1: #Columns
    c("#Columns", as.character(n_cols), rep("", n_cols - 1)),
    # Row 2: #Header_Rows  
    c("#Header_Rows", "12", rep("", n_cols - 1)),
    # Row 3: Field_Name
    c("Field_Name", names(input_file)),
    # Row 4: Unit
    c("Unit", rep("[FILL IN]", n_cols)),
    # Row 5: Unit_Basis
    c("Unit_Basis", rep("[FILL IN]", n_cols)),
    # Row 6: MethodID_Analysis
    c("MethodID_Analysis", rep("[FILL IN]", n_cols)),
    # Row 7: MethodID_Inspection
    c("MethodID_Inspection", rep("[FILL IN]", n_cols)),
    # Row 8: MethodID_Storage
    c("MethodID_Storage", rep("[FILL IN]", n_cols)),
    # Row 9: MethodID_Preservation
    c("MethodID_Preservation", rep("[FILL IN]", n_cols)),
    # Row 10: MethodID_Preparation
    c("MethodID_Preparation", rep("[FILL IN]", n_cols)),
    # Row 11: MethodID_input_fileProcessing
    c("MethodID_DataProcessing", rep("[FILL IN]", n_cols)),
    # Row 12: Analysis_DetectionLimit
    c("Analysis_DetectionLimit", rep("[FILL IN]", n_cols)),
    # Row 13: Analysis_Precision
    c("Analysis_Precision", rep("[FILL IN]", n_cols)),
    # Row 14: input_file_Status
    c("Data_Status", rep("[FILL IN]", n_cols))
  )
  
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
  add_header_rows()

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
  mutate(Methods_Deviation = ifelse(Methods_Deviation == "", "N/A", Methods_Deviation))%>%
  add_column('FTICR-MS' = 'See_FTICR_folder_for_data', .before = 'Methods_Deviation')%>%
  rename(Sample_Name = Sample_ID)%>%
  add_column(Material = 'Sediment', .after = 'Sample_Name') %>%
  add_header_rows()

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
  add_header_rows()

write_csv(norm_inc_boye, str_replace(norm_inc_data, '.csv', '_BoyeTransformed.csv'), na = '-9999', col_names = F)


