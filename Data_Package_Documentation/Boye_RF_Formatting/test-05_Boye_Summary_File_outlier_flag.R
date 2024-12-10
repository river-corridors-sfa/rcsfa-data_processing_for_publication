### test-05_Boye_Summary_File.R ################################################
# Date Created: 2024-10-31
# Date Updated: 2024-12-10
# Author: Bibi Powers-McCormack

# Objective: 
  # create testing environment for Boye Summary file

# Directions: 
  # 1. Run prep script chunk
  # 2. Go to `05_Boye_Summary_File.R` and run the code to load the functions
  # 3. Return to this script and run the `Run tests for calculations` chunk


  # .. Go to `05_Boye_Summary_File.R` and add temp_directory as dir (dir <- temp_directory) and material as water (material <- "water")
  # .. Run `05_Boye_Summary_File.R` and stop before you write anything out
  # .. Return to this script and run the run tests chunk

# Tests: 
  # These tests are separated into two chunks. The first chunk confirms that the
  # outliers are being removed and the averages calculated correctly. The second
  # test chunk confirms that the inputs are being read in and the outputs are
  # being generated correctly.
  
  # CALCULATION TESTS: 
  # test that outlier flags are correctly assigned by mapping the outlier text to the column name
  # test that outlier flags drops the corresponding value to NA
  # test that average works when all reps are included
  # test that average works when some reps are NA
  # test that Mean_Missing_Rep flag is applied when averaging includes NA values
  # test that column headers with multiple reps are renamed to have "Mean_" appended to title

  # INPUT/OUTPUT TESTS: 
  # test that header rows are aligned


### Prep script ################################################################

library(tidyverse)
library(testthat)
library(rlog)

# create testing data

# the outlier values are manually pulled from Methods_Deviation_Codes (MethodsID_DataProcessing tab): https://pnnl.sharepoint.com/:x:/r/teams/Lab-FieldTeam/Shared%20Documents/Data%20Generation%20and%20Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Deviation_Codes.xlsx?d=wfca78e071aa849c89a155dcd6501f37e&csf=1&web=1&e=UFWlwO&nav=MTVfezc2QUM2MTg0LUQ2QzUtNDE0My1BRTY2LTAzOEZBQzA5MDlCM30
Methods_Deviation_outlier_options <- c("Br_OUTLIER_000", "C_OUTLIER_000", "Ca_OUTLIER_000", "Cl_OUTLIER_000", "DIC_OUTLIER_000", "F_OUTLIER_000", "K_OUTLIER_000", "Li_OUTLIER_000", "Mg_OUTLIER_000", "N_OUTLIER_000", "Na_OUTLIER_000", "NH4_OUTLIER_000", "NO2_OUTLIER_000", "NO3_OUTLIER_000", "NPOC_OUTLIER_000", "PO4_OUTLIER_000", "Rate_OUTLIER_000", "SFE_OUTLIER_000", "SO4_OUTLIER_000", "TN_OUTLIER_000")


create_wide_testing_data <- function(outlier_options, set_seed = 637) {
  
  set.seed(set_seed)
  
  # these cols are pulled manually from RC-SFA_ColumnHeader_Lookup.csv: https://pnnl.sharepoint.com/:x:/r/teams/Lab-FieldTeam/Shared%20Documents/Data%20Generation%20and%20Files/Protocols-Guidance-Workflows-Methods/RC-SFA_ColumnHeader_Lookup.csv?d=w2d7744ec283a49b7922b6a31dabb1437&csf=1&web=1&e=owSrS
  testing_data <- tibble(Field_Name = NA_character_, 
                         Sample_Name = paste0("ABC_", sprintf("%03d", seq_along(outlier_options)), "_OCN-1"), 
                         Material = "Liquid>aqueous", 
                         Methods_Deviation = outlier_options, 
                         X00681_NPOC_mg_per_L_as_C = runif(length(outlier_options), min = 0, max = 1),
                         X00602_TN_mg_per_L_as_N = runif(length(outlier_options), min = 0, max = 1),
                         X00691_DIC_mg_per_L_as_C = runif(length(outlier_options), min = 0, max = 1),
                         X00530_TSS_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         NH4_mg_per_L_as_NH4 = runif(length(outlier_options), min = 0, max = 1),
                         X71870_Br_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X00915_Ca_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X00940_Cl_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X00950_F_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X01130_Li_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X00925_Mg_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X71851_NO3_mg_per_L_as_NO3 = runif(length(outlier_options), min = 0, max = 1),
                         X71856_NO2_mg_per_L_as_NO2 = runif(length(outlier_options), min = 0, max = 1),
                         X00653_PO4_mg_per_L_as_PO4 = runif(length(outlier_options), min = 0, max = 1),
                         X00935_K_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X00930_Na_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         X00945_SO4_mg_per_L_as_SO4 = runif(length(outlier_options), min = 0, max = 1),
                         X01472_N_percent_per_mg = runif(length(outlier_options), min = 0, max = 1),
                         X01463_C_percent_per_mg = runif(length(outlier_options), min = 0, max = 1),
                         pH = runif(length(outlier_options), min = 0, max = 1),
                         Mean_pH = runif(length(outlier_options), min = 0, max = 1),
                         StDev_pH = runif(length(outlier_options), min = 0, max = 1),
                         Specific_Conductance_microsiemens_per_centimeter = runif(length(outlier_options), min = 0, max = 1),
                         Mean_Specific_Conductance_microsiemens_per_centimeter = runif(length(outlier_options), min = 0, max = 1),
                         StDev_Mean_Specific_Conductance_microsiemens_per_centimeter = runif(length(outlier_options), min = 0, max = 1),
                         Temperature_degrees_Celsius = runif(length(outlier_options), min = 0, max = 1),
                         Mean_Temperature_degrees_Celsius = runif(length(outlier_options), min = 0, max = 1),
                         StDev_Temperature_degrees_Celsius = runif(length(outlier_options), min = 0, max = 1),
                         Fe_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Mean_Fe_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         StDev_Fe_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Fe_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Mean_Fe_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         StDev_Fe_mg_per_mg = runif(length(outlier_options), min = 0, max = 1),
                         Wet_Sediment_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Dry_Sediment_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Water_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Wet_Sediment_mL = runif(length(outlier_options), min = 0, max = 1),
                         MBD_P_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_Ca_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_Mg_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_P_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_K_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_Na_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_S_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_Al_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Total_Fe_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         `52718_Total_Ca_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         `52719_Total_Mg_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         `52720_Total_K_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         `52721_Total_Na_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         `01466_Total_S_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         `01462_Total_Al_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         `01464_Total_Fe_mg_per_kg` = runif(length(outlier_options), min = 0, max = 1),
                         Total_Ca_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_Mg_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_P_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_K_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_Na_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_S_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_Al_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Total_Fe_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Dissolved_Oxygen_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Quartz_percent = runif(length(outlier_options), min = 0, max = 1),
                         Albite_percent = runif(length(outlier_options), min = 0, max = 1),
                         Microcline_percent = runif(length(outlier_options), min = 0, max = 1),
                         Muscovite_percent = runif(length(outlier_options), min = 0, max = 1),
                         Chlorite_percent = runif(length(outlier_options), min = 0, max = 1),
                         Amphibole_percent = runif(length(outlier_options), min = 0, max = 1),
                         Pyroxene_percent = runif(length(outlier_options), min = 0, max = 1),
                         Calcite_percent = runif(length(outlier_options), min = 0, max = 1),
                         Apatite_percent = runif(length(outlier_options), min = 0, max = 1),
                         Crystallinity = runif(length(outlier_options), min = 0, max = 1),
                         Dolomite_percent = runif(length(outlier_options), min = 0, max = 1),
                         Smectite_percent = runif(length(outlier_options), min = 0, max = 1),
                         `01397_N_percent_per_mg` = runif(length(outlier_options), min = 0, max = 1),
                         `01395_C_percent_per_mg` = runif(length(outlier_options), min = 0, max = 1),
                         Specific_Surface_Area_m2_per_g = runif(length(outlier_options), min = 0, max = 1),
                         Wet_Sediment_Mass_Added_Water_g = runif(length(outlier_options), min = 0, max = 1),
                         Added_Water_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Total_Water_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Initial_Water_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Final_Water_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Incubation_Water_Mass_g = runif(length(outlier_options), min = 0, max = 1),
                         Wet_Sediment_Mass_MOI_g = runif(length(outlier_options), min = 0, max = 1),
                         Dry_Sediment_Mass_MOI_g = runif(length(outlier_options), min = 0, max = 1),
                         `62948_Gravimetric_Moisture_g_per_g` = runif(length(outlier_options), min = 0, max = 1),
                         `62948_Initial_Gravimetric_Moisture_g_per_g` = runif(length(outlier_options), min = 0, max = 1),
                         `62948_Final_Gravimetric_Moisture_g_per_g` = runif(length(outlier_options), min = 0, max = 1),
                         Water_Mass_MOI_g = runif(length(outlier_options), min = 0, max = 1),
                         Elapsed_Minute = runif(length(outlier_options), min = 0, max = 1),
                         Date = runif(length(outlier_options), min = 0, max = 1),
                         Respiration_Rate_mg_DO_per_L_per_H = runif(length(outlier_options), min = 0, max = 1),
                         Mean_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H = runif(length(outlier_options), min = 0, max = 1),
                         StDev_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H = runif(length(outlier_options), min = 0, max = 1),
                         Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H = runif(length(outlier_options), min = 0, max = 1),
                         StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H = runif(length(outlier_options), min = 0, max = 1),
                         Respiration_Rate_mg_DO_per_kg_per_H = runif(length(outlier_options), min = 0, max = 1),
                         Mean_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(outlier_options), min = 0, max = 1),
                         StDev_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(outlier_options), min = 0, max = 1),
                         Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(outlier_options), min = 0, max = 1),
                         StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(outlier_options), min = 0, max = 1),
                         Respiration_R_Squared = runif(length(outlier_options), min = 0, max = 1),
                         Respiration_R_Squared_Adj = runif(length(outlier_options), min = 0, max = 1),
                         Respiration_p_value = runif(length(outlier_options), min = 0, max = 1),
                         Total_Incubation_Time_Min = runif(length(outlier_options), min = 0, max = 1),
                         Number_Points_In_Respiration_Regression = runif(length(outlier_options), min = 0, max = 1),
                         Number_Points_Removed_Respiration_Regression = runif(length(outlier_options), min = 0, max = 1),
                         DO_Concentration_At_Incubation_Time_Zero = runif(length(outlier_options), min = 0, max = 1),
                         ATP_nanomoles_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Mean_ATP_nanomol_per_L = runif(length(outlier_options), min = 0, max = 1),
                         StDev_ATP_nanomol_per_L = runif(length(outlier_options), min = 0, max = 1),
                         ATP_picomoles_per_g = runif(length(outlier_options), min = 0, max = 1),
                         Mean_ATP_picomol_per_g = runif(length(outlier_options), min = 0, max = 1),
                         StDev_ATP_picomol_per_g = runif(length(outlier_options), min = 0, max = 1),
                         Extractable_NPOC_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Extractable_TN_mg_per_kg = runif(length(outlier_options), min = 0, max = 1),
                         Extractable_NPOC_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         Extractable_TN_mg_per_L = runif(length(outlier_options), min = 0, max = 1),
                         B6CA_uM = runif(length(outlier_options), min = 0, max = 1),
                         B5CA_uM = runif(length(outlier_options), min = 0, max = 1),
                         Percent_Fine_Sand = runif(length(outlier_options), min = 0, max = 1),
                         Percent_Med_Sand = runif(length(outlier_options), min = 0, max = 1),
                         Percent_Coarse_Sand = runif(length(outlier_options), min = 0, max = 1),
                         Percent_Tot_Sand = runif(length(outlier_options), min = 0, max = 1),
                         Percent_Silt = runif(length(outlier_options), min = 0, max = 1),
                         Percent_Clay = runif(length(outlier_options), min = 0, max = 1))
  
  return(testing_data)
}

create_long_testing_data <- function(long_testing_data) {
  
  testing_data <- long_testing_data %>% 
    
    select(-Field_Name) %>% 
    mutate(file_name = "testing_data.csv") %>% 
    
    # remove IGSN column if it exists
    select(-any_of("IGSN")) %>% 
    
    # add user input material
    mutate(user_provided_material = "Water") %>% 
    
    # split out sample name
    separate(Sample_Name, into = c("parent_analyte", "rep"), sep = "-", remove = FALSE) %>%
    separate(parent_analyte, into = c("parent_id", "analyte"), sep = "_(?=[^_]+$)", remove = TRUE, extra = "merge") %>% 
    
    # count number of reps
    group_by(parent_id) %>% 
    mutate(number_of_reps = n_distinct(rep)) %>% 
    
    # pivot longer
    group_by(across(c(Sample_Name, parent_id, analyte, rep, Material, Methods_Deviation, file_name, user_provided_material, number_of_reps))) %>% 
    pivot_longer(cols = -group_cols(), # pivoting all cols that aren't grouped
                 names_to = "data_type", 
                 values_to = "data_value") %>% 
    ungroup()
  
  return(testing_data)
  
}


### Run tests for calculations #################################################

test_that("flags are correctly assigned", {
  # this test checks that the outliers are correctly identified
  
  testing_data <- create_long_testing_data(create_wide_testing_data(outlier_options = Methods_Deviation_outlier_options, set_seed = 637))
  
  result <- assign_flags(testing_data)
  
  expected_result <- testing_data %>% 
    mutate(`_data_type` = case_when(!is.na(Methods_Deviation) ~ paste0("_", data_type))) %>% 
    mutate(Outlier = case_when((Methods_Deviation == "Br_OUTLIER_000" & data_type %in% c("X71870_Br_mg_per_L")) ~ "_Br_",
                               (Methods_Deviation == "C_OUTLIER_000" & data_type %in% c("X01463_C_percent_per_mg", "01395_C_percent_per_mg")) ~ "_C_",
                               (Methods_Deviation == "Ca_OUTLIER_000" & data_type %in% c("X00915_Ca_mg_per_L", "Total_Ca_mg_per_L", "52718_Total_Ca_mg_per_kg", "Total_Ca_mg_per_kg")) ~ "_Ca_",
                               (Methods_Deviation == "Cl_OUTLIER_000" & data_type %in% c("X00940_Cl_mg_per_L")) ~ "_Cl_",
                               (Methods_Deviation == "DIC_OUTLIER_000" & data_type %in% c("X00691_DIC_mg_per_L_as_C")) ~ "_DIC_",
                               (Methods_Deviation == "F_OUTLIER_000" & data_type %in% c("X00950_F_mg_per_L")) ~ "_F_",
                               (Methods_Deviation == "K_OUTLIER_000" & data_type %in% c("X00935_K_mg_per_L", "Total_K_mg_per_L", "52720_Total_K_mg_per_kg", "Total_K_mg_per_kg")) ~ "_K_",
                               (Methods_Deviation == "Li_OUTLIER_000" & data_type %in% c("X01130_Li_mg_per_L")) ~ "_Li_",
                               (Methods_Deviation == "Mg_OUTLIER_000" & data_type %in% c("X00925_Mg_mg_per_L", "Total_Mg_mg_per_L", "52719_Total_Mg_mg_per_kg", "Total_Mg_mg_per_kg")) ~ "_Mg_",
                               (Methods_Deviation == "N_OUTLIER_000" & data_type %in% c("X01472_N_percent_per_mg", "01397_N_percent_per_mg")) ~ "_N_",
                               (Methods_Deviation == "Na_OUTLIER_000" & data_type %in% c("X00930_Na_mg_per_L", "Total_Na_mg_per_L", "52721_Total_Na_mg_per_kg", "Total_Na_mg_per_kg")) ~ "_Na_",
                               (Methods_Deviation == "NH4_OUTLIER_000" & data_type %in% c("NH4_mg_per_L_as_NH4")) ~ "_NH4_",
                               (Methods_Deviation == "NO2_OUTLIER_000" & data_type %in% c("X71856_NO2_mg_per_L_as_NO2")) ~ "_NO2_",
                               (Methods_Deviation == "NO3_OUTLIER_000" & data_type %in% c("X71851_NO3_mg_per_L_as_NO3")) ~ "_NO3_",
                               (Methods_Deviation == "NPOC_OUTLIER_000" & data_type %in% c("X00681_NPOC_mg_per_L_as_C", "Extractable_NPOC_mg_per_kg", "Extractable_NPOC_mg_per_L")) ~ "_NPOC_",
                               (Methods_Deviation == "PO4_OUTLIER_000" & data_type %in% c("X00653_PO4_mg_per_L_as_PO4")) ~ "_PO4_",
                               (Methods_Deviation == "Rate_OUTLIER_000" & data_type %in% c("Respiration_Rate_mg_DO_per_L_per_H", "Mean_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H", "StDev_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H", "Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H", "StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H", "Respiration_Rate_mg_DO_per_kg_per_H", "Mean_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H", "StDev_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H", "Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H", "StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H")) ~ "_Rate_",
                               (Methods_Deviation == "SFE_OUTLIER_000" & data_type %in% c("")) ~ "_SFE_",
                               (Methods_Deviation == "SO4_OUTLIER_000" & data_type %in% c("X00945_SO4_mg_per_L_as_SO4")) ~ "_SO4_",
                               (Methods_Deviation == "TN_OUTLIER_000" & data_type %in% c("X00602_TN_mg_per_L_as_N", "Extractable_TN_mg_per_kg", "Extractable_TN_mg_per_L")) ~ "_TN_")) %>% 
    select(colnames(result))

  # note: here are the remaining columns that do NOT yet have an associated
  # outlier (an thus are not being evaluated or considered if these columns
  # conflict with existing outlier flags). If additional outlier flags are
  # used, make sure to add them to this test. To do that, add the new outlier to
  # the `Methods_Deviation_outlier_options` vector in this script. Then add a
  # new row to the `expected_result` case_when statements that indicates which
  # columns the outlier should be flagging.
  
    # X00530_TSS_mg_per_L
    # pH
    # Mean_pH
    # StDev_pH
    # Specific_Conductance_microsiemens_per_centimeter
    # Mean_Specific_Conductance_microsiemens_per_centimeter
    # StDev_Mean_Specific_Conductance_microsiemens_per_centimeter
    # Temperature_degrees_Celsius
    # Mean_Temperature_degrees_Celsius
    # StDev_Temperature_degrees_Celsius
    # Fe_mg_per_L
    # Mean_Fe_mg_per_L
    # StDev_Fe_mg_per_L
    # Fe_mg_per_kg
    # Mean_Fe_mg_per_kg
    # StDev_Fe_mg_per_mg
    # Wet_Sediment_Mass_g
    # Dry_Sediment_Mass_g
    # Water_Mass_g
    # Wet_Sediment_mL
    # MBD_P_mg_per_L
    # Total_P_mg_per_L
    # Total_S_mg_per_L
    # Total_Al_mg_per_L
    # Total_Fe_mg_per_L
    # `01466_Total_S_mg_per_kg`
    # `01462_Total_Al_mg_per_kg`
    # `01464_Total_Fe_mg_per_kg`
    # Total_P_mg_per_kg
    # Total_S_mg_per_kg
    # Total_Al_mg_per_kg
    # Total_Fe_mg_per_kg
    # Dissolved_Oxygen_mg_per_L
    # Quartz_percent
    # Albite_percent
    # Microcline_percent
    # Muscovite_percent
    # Chlorite_percent
    # Amphibole_percent
    # Pyroxene_percent
    # Calcite_percent
    # Apatite_percent
    # Crystallinity
    # Dolomite_percent
    # Smectite_percent
    # Specific_Surface_Area_m2_per_g
    # Wet_Sediment_Mass_Added_Water_g
    # Added_Water_Mass_g
    # Total_Water_Mass_g
    # Initial_Water_Mass_g
    # Final_Water_Mass_g
    # Incubation_Water_Mass_g
    # Wet_Sediment_Mass_MOI_g
    # Dry_Sediment_Mass_MOI_g
    # `62948_Gravimetric_Moisture_g_per_g`
    # `62948_Initial_Gravimetric_Moisture_g_per_g`
    # `62948_Final_Gravimetric_Moisture_g_per_g`
    # Water_Mass_MOI_g
    # Elapsed_Minute
    # Date
    # Respiration_R_Squared
    # Respiration_R_Squared_Adj
    # Respiration_p_value
    # Total_Incubation_Time_Min
    # Number_Points_In_Respiration_Regression
    # Number_Points_Removed_Respiration_Regression
    # DO_Concentration_At_Incubation_Time_Zero
    # ATP_nanomoles_per_L
    # Mean_ATP_nanomol_per_L
    # StDev_ATP_nanomol_per_L
    # ATP_picomoles_per_g
    # Mean_ATP_picomol_per_g
    # StDev_ATP_picomol_per_g
    # B6CA_uM
    # B5CA_uM
    # Percent_Fine_Sand
    # Percent_Med_Sand
    # Percent_Coarse_Sand
    # Percent_Tot_Sand
    # Percent_Silt
    # Percent_Clay
  
  expect_equal(object = result, 
               expected = expected_result)
  
  
})

test_that("flags are correctly applied", {
  # this test checks that the outliers are dropped based on the match between the outlier flag and the column name
  
  testing_data <- create_wide_testing_data(outlier_options = Methods_Deviation_outlier_options, set_seed = 637) %>% 
    create_long_testing_data(.) %>% 
    assign_flags(.)
  
  result <- apply_flags(testing_data)
  
  expected_result <- testing_data %>% 
    mutate(data_value = case_when(!is.na(Outlier) ~ NA_real_, T ~ data_value)) %>% 
    select(-`_data_type`, -Methods_Deviation, -Outlier) %>% # drop Methods Deviation col
    distinct() %>% 
    ungroup()
    
  expect_equal(object = result,
               expected = expected_result)
  
})

test_that("average works when all reps are included", {
  # this test checks that data with 3 reps and no NAs are correctly averaged
  
  testing_data <- tribble(~Sample_Name,      ~parent_id, ~analyte, ~rep, ~Material, ~Methods_Deviation, ~file_name, ~user_provided_material, ~number_of_reps, ~data_type,                   ~data_value,
                          "ABC_0001_GRA-1",  "ABC_0001", "GRA",    1,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.25,
                          "ABC_0001_GRA-2",  "ABC_0001", "GRA",    2,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.75,
                          "ABC_0001_GRA-3",  "ABC_0001", "GRA",    3,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.95,
                          "ABC_0002_GRA-1",  "ABC_0002", "GRA",    1,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.45,
                          "ABC_0002_GRA-2",  "ABC_0002", "GRA",    2,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.35,
                          "ABC_0002_GRA-3",  "ABC_0002", "GRA",    3,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.75)
  
  result <- calculate_summary(testing_data)
  
  expected_result <- tribble(~Sample_Name,     ~Material,        ~average, ~data_type,                  ~file_name, ~summary_header_name,             ~Mean_Missing_Reps,
                             "ABC_0001_Water", "Liquid>aqueous",  0.650     , "00681_NPOC_mg_per_L_as_C",  "File_A",    "Mean_00681_NPOC_mg_per_L_as_C", FALSE,
                             "ABC_0002_Water", "Liquid>aqueous",  0.517       , "00681_NPOC_mg_per_L_as_C",  "File_A",    "Mean_00681_NPOC_mg_per_L_as_C", FALSE
                             )
  
  expect_equal(object = result, 
               expected = expected_result)
  
})

test_that("average works when some reps are NA", {
  # this test checks that data with 3 reps, including some with NA values but no methods deviations, are correctly averaged
  
  testing_data <- tribble(~Sample_Name,      ~parent_id, ~analyte, ~rep, ~Material, ~Methods_Deviation, ~file_name, ~user_provided_material, ~number_of_reps, ~data_type,                   ~data_value,
                          "ABC_0001_GRA-1",  "ABC_0001", "GRA",    1,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.25,
                          "ABC_0001_GRA-2",  "ABC_0001", "GRA",    2,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    NA_real_,
                          "ABC_0001_GRA-3",  "ABC_0001", "GRA",    3,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    NA_real_,
                          "ABC_0002_GRA-1",  "ABC_0002", "GRA",    1,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.45,
                          "ABC_0002_GRA-2",  "ABC_0002", "GRA",    2,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.35,
                          "ABC_0002_GRA-3",  "ABC_0002", "GRA",    3,   "Liquid>aqueous", NA_character_, "File_A", "Water",                   3,              "00681_NPOC_mg_per_L_as_C",    0.75)
  
  result <- calculate_summary(testing_data)
  
  expected_result <- tribble(~Sample_Name,     ~Material,        ~average, ~data_type,                  ~file_name, ~summary_header_name,             ~Mean_Missing_Reps,
                             "ABC_0001_Water", "Liquid>aqueous",  0.250     , "00681_NPOC_mg_per_L_as_C",  "File_A",    "Mean_00681_NPOC_mg_per_L_as_C", TRUE,
                             "ABC_0002_Water", "Liquid>aqueous",  0.517       , "00681_NPOC_mg_per_L_as_C",  "File_A",    "Mean_00681_NPOC_mg_per_L_as_C", FALSE
                             )
  
  expect_equal(object = result, 
               expected = expected_result)
  
})


### Run tests for inputs & outputs #############################################








































### OLD TESTS ##################################################################



### Create testing data ########################################################

# test that files are read and pivoted longer
test_that("files are read in and pivoted longer", {
  
  # create testing data
  temp_directory <- tempdir()
  log_info(paste0("Opening temp directory: ", temp_directory))
  shell.exec(temp_directory)
  
  testing_data <- list(
    # create 2 Water sample files
    ABC_Water_Ions = list(
      data = tribble(~Field_Name, ~Sample_Name, ~Material,                    ~NH4_mg_per_L_as_NH4, ~`00915_Ca_mg_per_L`, ~Methods_Deviation,  # has only 1 rep
                     "#Start_Data",        "ABC_001_WIN-1", "Liquid>aqueous",   ".123",               ".192",   "Ca_OUTLIER",
                     "N/A",                "ABC_002_WIN-1", "Liquid>aqueous",   ".456",               ".021",   "",
                     "N/A",                "ABC_003_WIN-1", "Liquid>aqueous",   ".789",               ".222",   "",
                     "N/A",                "ABC_004_WIN-1", "Liquid>aqueous",   ".101",               ".324",   "", 
                     "N/A",                "ABC_005_WIN-1", "Liquid>aqueous",   ".112",               ".252",   "Ca_OUTLIER; NH4_OUTLIER",
                     "N/A",                "ABC_006_WIN-1", "Liquid>aqueous",   ".131",               ".627",   "",
                     "N/A",                "ABC_007_WIN-1", "Liquid>aqueous",   ".415",               ".282",   "NH4_OUTLIER", 
                     "N/A",                "ABC_008_WIN-1", "Liquid>aqueous",   ".161",               ".930",   "",
                     "N/A",                "ABC_009_WIN-1", "Liquid>aqueous",   ".718",               ".313",   "",
                     "#End_Data",           "N/A",           "N/A",            "N/A",                  "N/A",   "N/A"),
      
      headers = tribble(~Field_Name, ~Sample_Name,    ~Material,      ~NH4_mg_per_L_as_NH4,   ~`00915_Ca_mg_per_L`, ~Methods_Deviation,
                        "Unit",                        "N/A",           "N/A",          "milligrams_per_liter", "milligrams_per_liter", "N/A",
                        "Unit_Basis",                  "N/A",           "N/A",          "as_Ammonium",          "as_Calcium",          "N/A",
                        "MethodID_Analysis",           "N/A",           "N/A",          "ION_T_AN_005",         "ION_T_AN_005",        "N/A",
                        "MethodID_Inspection",         "N/A",           "N/A",          "ION_T_IN_005",         "ION_T_IN_005",        "N/A",
                        "MethodID_Storage",            "N/A",           "N/A",          "ION_T_ST_005",         "ION_T_ST_005",        "N/A",
                        "MethodID_Preservation",       "N/A",           "N/A",          "ION_T_PRES_005",       "ION_T_PRES_005",      "N/A",
                        "MethodID_Preparation",        "N/A",           "N/A",          "ION_T_PREP_005",       "ION_T_PREP_005",      "N/A",
                        "MethodID_DataProcessing",     "N/A",           "N/A",          "ION_T_DP_005",         "ION_T_DP_005",        "N/A",
                        "Analysis_DetectionLimit",     "-9999",         "-9999",        "0.13",                 "0.77",                "N/A",
                        "Analysis_Precision",          "-9999",         "-9999",        "-9999",                "-9999",               "N/A",
                        "Data_Status",                 "N/A",           "N/A",          "ready_to_use",         "ready_to_use",        "N/A")),
    
    ABC_Water_NPOC_TN = list(
      data = tribble(~Field_Name, ~Sample_Name, ~Material, ~`00681_NPOC_mg_per_L_as_C`, ~`00602_TN_mg_per_L_as_N`, ~Methods_Deviation,  # has 3 reps
                     "#Start_Data", "ABC_001_OCN-1", "Liquid>aqueous", ".500", ".1", "",
                     "N/A",         "ABC_001_OCN-2", "Liquid>aqueous", ".550", ".2", "",
                     "N/A",         "ABC_001_OCN-3", "Liquid>aqueous", ".600", ".3", "TN_OUTLIER",
                     "N/A",         "ABC_002_OCN-1", "Liquid>aqueous", ".777", ".787", "TN_CV_30",
                     "N/A",         "ABC_002_OCN-2", "Liquid>aqueous", ".777", ".788", "",
                     "N/A",         "ABC_002_OCN-3", "Liquid>aqueous", ".777", ".789", "",
                     "N/A",         "ABC_003_OCN-1", "Liquid>aqueous", ".123", ".234", "NPOC_OUTLIER",
                     "N/A",         "ABC_003_OCN-2", "Liquid>aqueous", ".456", ".234", "NPOC_CV_30; NPOC_OUTLIER",
                     "N/A",         "ABC_003_OCN-3", "Liquid>aqueous", ".789", ".236", "TN_OUTLIER; NPOC_OUTLIER",
                     "#End_Data",   "N/A",           "N/A",            "N/A",  "N/A",   "N/A"),
      
      headers = tribble(~Field_Name,	~Sample_Name,	~Material,	~`00681_NPOC_mg_per_L_as_C`, ~`00602_TN_mg_per_L_as_N`, ~Methods_Deviation,
                        "Unit",                      "N/A",        "N/A",      "milligrams_per_liter",    "milligrams_per_liter",    "N/A",
                        "Unit_Basis",                "N/A",       "N/A",       "as_dissolvable_Carbon",   "as_dissolvable_Nitrogen", "N/A",
                        "MethodID_Analysis",         "N/A",       "N/A",       "NPOC_T_AN_000",           "TN_T_AN_000",             "N/A",
                        "MethodID_Inspection",       "N/A",       "N/A",       "NPOC_T_IN_000",           "TN_T_IN_000",             "N/A",
                        "MethodID_Storage",          "N/A",       "N/A",       "NPOC_T_ST_000",           "TN_T_ST_000",             "N/A",
                        "MethodID_Preservation",     "N/A",       "N/A",       "NPOC_T_PRES_000",         "TN_T_PRES_000",           "N/A",
                        "MethodID_Preparation",      "N/A",       "N/A",       "NPOC_T_PREP_000",         "TN_T_PREP_000",           "N/A",
                        "MethodID_DataProcessing",   "N/A",       "N/A",       "NPOC_T_DP_000",           "TN_T_DP_000",             "N/A",
                        "Analysis_DetectionLimit",   "-9999",     "-9999",     "0.27",                    "0.07",                    "N/A",
                        "Analysis_Precision",        "-9999",     "-9999",     "-9999",                   "-9999",                   "N/A",
                        "Data_Status",               "N/A",       "N/A",       "ready_to_use",            "ready_to_use",             "N/A")))
  
  # write out testing data
  top <- tibble('one' = as.character(),
                'two' = as.numeric()) %>%
    add_row(one = '#Columns',
            two = 8) %>%
    add_row(one = '#Header_Rows',
            two = 8)
  
  for (i in seq_along(testing_data)) {
    
    headers <- testing_data[[i]]$headers
    data <- testing_data[[i]]$data
    
    dataset_name <- names(testing_data)[i]
    
    out_file <- paste0(temp_directory, "/", dataset_name, ".csv")
    
    write_csv(top, out_file, col_names = F)
    
    write_csv(headers, out_file, append = T, col_names = T)
    
    write_csv(data, out_file, append = T, na = '')
    
  }
  
  shell.exec(temp_directory)
  
  # now read those files back in
  
  data <- read_in_files()
  
  # check that the read in files match that exported out files
  expect_equal()
  
  
})


# test that outliers are removed via their flag look up



# test that averaging combines all reps for a given sample



# test that col headers output correctly























################################################################################


# create testing data
temp_directory <- tempdir()
log_info(paste0("Opening temp directory: ", temp_directory))
shell.exec(temp_directory)

# the outlier values are manually pulled from Methods_Deviation_Codes (MethodsID_DataProcessing tab): https://pnnl.sharepoint.com/:x:/r/teams/Lab-FieldTeam/Shared%20Documents/Data%20Generation%20and%20Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Deviation_Codes.xlsx?d=wfca78e071aa849c89a155dcd6501f37e&csf=1&web=1&e=UFWlwO&nav=MTVfezc2QUM2MTg0LUQ2QzUtNDE0My1BRTY2LTAzOEZBQzA5MDlCM30
Methods_Deviation_outlier_options <- c("Br_OUTLIER_000", "C_OUTLIER_000", "Ca_OUTLIER_000", "Cl_OUTLIER_000", "DIC_OUTLIER_000", "F_OUTLIER_000", "K_OUTLIER_000", "Li_OUTLIER_000", "Mg_OUTLIER_000", "N_OUTLIER_000", "Na_OUTLIER_000", "NH4_OUTLIER_000", "NO2_OUTLIER_000", "NO3_OUTLIER_000", "NPOC_OUTLIER_000", "PO4_OUTLIER_000", "Rate_OUTLIER_000", "SFE_OUTLIER_000", "SO4_OUTLIER_000", "TN_OUTLIER_000")

set.seed(637)

testing_data <- list(
  # create 2 Water sample files
  ABC_Water_Ions = list(
    data = tribble(~Field_Name, ~Sample_Name, ~Material,                    ~NH4_mg_per_L_as_NH4, ~`00915_Ca_mg_per_L`, ~Methods_Deviation,  # has only 1 rep
                    "#Start_Data",        "ABC_001_WIN-1", "Liquid>aqueous",   ".123",               ".192",   "Ca_OUTLIER",
                    "N/A",                "ABC_002_WIN-1", "Liquid>aqueous",   ".456",               ".021",   "",
                    "N/A",                "ABC_003_WIN-1", "Liquid>aqueous",   ".789",               ".222",   "",
                    "N/A",                "ABC_004_WIN-1", "Liquid>aqueous",   ".101",               ".324",   "", 
                    "N/A",                "ABC_005_WIN-1", "Liquid>aqueous",   ".112",               ".252",   "Ca_OUTLIER; NH4_OUTLIER",
                    "N/A",                "ABC_006_WIN-1", "Liquid>aqueous",   ".131",               ".627",   "",
                    "N/A",                "ABC_007_WIN-1", "Liquid>aqueous",   ".415",               ".282",   "NH4_OUTLIER", 
                    "N/A",                "ABC_008_WIN-1", "Liquid>aqueous",   ".161",               ".930",   "",
                    "N/A",                "ABC_009_WIN-1", "Liquid>aqueous",   ".718",               ".313",   "",
                   "#End_Data",           "N/A",           "N/A",            "N/A",                  "N/A",   "N/A"),
    
  headers = tribble(~Field_Name, ~Sample_Name,    ~Material,      ~NH4_mg_per_L_as_NH4,   ~`00915_Ca_mg_per_L`, ~Methods_Deviation,
                    "Unit",                        "N/A",           "N/A",          "milligrams_per_liter", "milligrams_per_liter", "N/A",
                    "Unit_Basis",                  "N/A",           "N/A",          "as_Ammonium",          "as_Calcium",          "N/A",
                    "MethodID_Analysis",           "N/A",           "N/A",          "ION_T_AN_005",         "ION_T_AN_005",        "N/A",
                    "MethodID_Inspection",         "N/A",           "N/A",          "ION_T_IN_005",         "ION_T_IN_005",        "N/A",
                    "MethodID_Storage",            "N/A",           "N/A",          "ION_T_ST_005",         "ION_T_ST_005",        "N/A",
                    "MethodID_Preservation",       "N/A",           "N/A",          "ION_T_PRES_005",       "ION_T_PRES_005",      "N/A",
                    "MethodID_Preparation",        "N/A",           "N/A",          "ION_T_PREP_005",       "ION_T_PREP_005",      "N/A",
                    "MethodID_DataProcessing",     "N/A",           "N/A",          "ION_T_DP_005",         "ION_T_DP_005",        "N/A",
                    "Analysis_DetectionLimit",     "-9999",         "-9999",        "0.13",                 "0.77",                "N/A",
                    "Analysis_Precision",          "-9999",         "-9999",        "-9999",                "-9999",               "N/A",
                    "Data_Status",                 "N/A",           "N/A",          "ready_to_use",         "ready_to_use",        "N/A")),
  
  ABC_Water_NPOC_TN = list(
    data = tribble(~Field_Name, ~Sample_Name, ~Material, ~`00681_NPOC_mg_per_L_as_C`, ~`00602_TN_mg_per_L_as_N`, ~Methods_Deviation,  # has 3 reps
                   "#Start_Data", "ABC_001_OCN-1", "Liquid>aqueous", ".500", ".1", "",
                   "N/A",         "ABC_001_OCN-2", "Liquid>aqueous", ".550", ".2", "",
                   "N/A",         "ABC_001_OCN-3", "Liquid>aqueous", ".600", ".3", "TN_OUTLIER",
                   "N/A",         "ABC_002_OCN-1", "Liquid>aqueous", ".777", ".787", "TN_CV_30",
                   "N/A",         "ABC_002_OCN-2", "Liquid>aqueous", ".777", ".788", "",
                   "N/A",         "ABC_002_OCN-3", "Liquid>aqueous", ".777", ".789", "",
                   "N/A",         "ABC_003_OCN-1", "Liquid>aqueous", ".123", ".234", "NPOC_OUTLIER",
                   "N/A",         "ABC_003_OCN-2", "Liquid>aqueous", ".456", ".234", "NPOC_CV_30; NPOC_OUTLIER",
                   "N/A",         "ABC_003_OCN-3", "Liquid>aqueous", ".789", ".236", "TN_OUTLIER; NPOC_OUTLIER",
                   "#End_Data",   "N/A",           "N/A",            "N/A",  "N/A",   "N/A"),
  
  headers = tribble(~Field_Name,	~Sample_Name,	~Material,	~`00681_NPOC_mg_per_L_as_C`, ~`00602_TN_mg_per_L_as_N`, ~Methods_Deviation,
                                      "Unit",                      "N/A",        "N/A",      "milligrams_per_liter",    "milligrams_per_liter",    "N/A",
                                      "Unit_Basis",                "N/A",       "N/A",       "as_dissolvable_Carbon",   "as_dissolvable_Nitrogen", "N/A",
                                      "MethodID_Analysis",         "N/A",       "N/A",       "NPOC_T_AN_000",           "TN_T_AN_000",             "N/A",
                                      "MethodID_Inspection",       "N/A",       "N/A",       "NPOC_T_IN_000",           "TN_T_IN_000",             "N/A",
                                      "MethodID_Storage",          "N/A",       "N/A",       "NPOC_T_ST_000",           "TN_T_ST_000",             "N/A",
                                      "MethodID_Preservation",     "N/A",       "N/A",       "NPOC_T_PRES_000",         "TN_T_PRES_000",           "N/A",
                                      "MethodID_Preparation",      "N/A",       "N/A",       "NPOC_T_PREP_000",         "TN_T_PREP_000",           "N/A",
                                      "MethodID_DataProcessing",   "N/A",       "N/A",       "NPOC_T_DP_000",           "TN_T_DP_000",             "N/A",
                                      "Analysis_DetectionLimit",   "-9999",     "-9999",     "0.27",                    "0.07",                    "N/A",
                                      "Analysis_Precision",        "-9999",     "-9999",     "-9999",                   "-9999",                   "N/A",
                                      "Data_Status",               "N/A",       "N/A",       "ready_to_use",            "ready_to_use",             "N/A")),
  
  ABC_Water_all_columns = list(
    
    # these cols are pulled manually from RC-SFA_ColumnHeader_Lookup.csv: https://pnnl.sharepoint.com/:x:/r/teams/Lab-FieldTeam/Shared%20Documents/Data%20Generation%20and%20Files/Protocols-Guidance-Workflows-Methods/RC-SFA_ColumnHeader_Lookup.csv?d=w2d7744ec283a49b7922b6a31dabb1437&csf=1&web=1&e=owSrS
    data = tibble(Field_Name = NA_character_, 
                  Sample_Name = paste0("ABC_", sprintf("%03d", seq_along(Methods_Deviation_outlier_options)), "_OCN-1"), 
                  Material = "Liquid>aqueous", 
                  Methods_Deviation = Methods_Deviation_outlier_options, 
                  X00681_NPOC_mg_per_L_as_C = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00602_TN_mg_per_L_as_N = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00691_DIC_mg_per_L_as_C = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00530_TSS_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  NH4_mg_per_L_as_NH4 = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X71870_Br_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00915_Ca_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00940_Cl_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00950_F_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X01130_Li_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00925_Mg_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X71851_NO3_mg_per_L_as_NO3 = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X71856_NO2_mg_per_L_as_NO2 = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00653_PO4_mg_per_L_as_PO4 = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00935_K_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00930_Na_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X00945_SO4_mg_per_L_as_SO4 = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X01472_N_percent_per_mg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  X01463_C_percent_per_mg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  pH = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_pH = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_pH = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Specific_Conductance_microsiemens_per_centimeter = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_Specific_Conductance_microsiemens_per_centimeter = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_Mean_Specific_Conductance_microsiemens_per_centimeter = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Temperature_degrees_Celsius = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_Temperature_degrees_Celsius = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_Temperature_degrees_Celsius = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Fe_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_Fe_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_Fe_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Fe_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_Fe_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_Fe_mg_per_mg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Wet_Sediment_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Dry_Sediment_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Water_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Wet_Sediment_mL = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  MBD_P_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Ca_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Mg_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_P_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_K_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Na_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_S_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Al_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Fe_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `52718_Total_Ca_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `52719_Total_Mg_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `52720_Total_K_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `52721_Total_Na_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `01466_Total_S_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `01462_Total_Al_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `01464_Total_Fe_mg_per_kg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Ca_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Mg_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_P_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_K_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Na_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_S_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Al_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Fe_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Dissolved_Oxygen_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Quartz_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Albite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Microcline_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Muscovite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Chlorite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Amphibole_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Pyroxene_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Calcite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Apatite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Crystallinity = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Dolomite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Smectite_percent = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `01397_N_percent_per_mg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `01395_C_percent_per_mg` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Specific_Surface_Area_m2_per_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Wet_Sediment_Mass_Added_Water_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Added_Water_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Water_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Initial_Water_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Final_Water_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Incubation_Water_Mass_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Wet_Sediment_Mass_MOI_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Dry_Sediment_Mass_MOI_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `62948_Gravimetric_Moisture_g_per_g` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `62948_Initial_Gravimetric_Moisture_g_per_g` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  `62948_Final_Gravimetric_Moisture_g_per_g` = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Water_Mass_MOI_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Elapsed_Minute = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Date = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Respiration_Rate_mg_DO_per_L_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Respiration_Rate_mg_DO_per_kg_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Respiration_R_Squared = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Respiration_R_Squared_Adj = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Respiration_p_value = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Total_Incubation_Time_Min = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Number_Points_In_Respiration_Regression = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Number_Points_Removed_Respiration_Regression = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  DO_Concentration_At_Incubation_Time_Zero = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  ATP_nanomoles_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_ATP_nanomol_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_ATP_nanomol_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  ATP_picomoles_per_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Mean_ATP_picomol_per_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  StDev_ATP_picomol_per_g = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Extractable_NPOC_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Extractable_TN_mg_per_kg = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Extractable_NPOC_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Extractable_TN_mg_per_L = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  B6CA_uM = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  B5CA_uM = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Percent_Fine_Sand = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Percent_Med_Sand = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Percent_Coarse_Sand = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Percent_Tot_Sand = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Percent_Silt = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1),
                  Percent_Clay = runif(length(Methods_Deviation_outlier_options), min = 0, max = 1))
    
  )
  
)

# write out testing data
top <- tibble('one' = as.character(),
              'two' = as.numeric()) %>%
  add_row(one = '#Columns',
          two = 8) %>%
  add_row(one = '#Header_Rows',
          two = 8)

for (i in seq_along(testing_data)) {
  
  headers <- testing_data[[i]]$headers
  data <- testing_data[[i]]$data
  
  dataset_name <- names(testing_data)[i]
  
  out_file <- paste0(temp_directory, "/", dataset_name, ".csv")
  
  write_csv(top, out_file, col_names = F)
  
  write_csv(headers, out_file, append = T, col_names = T)
  
  write_csv(data, out_file, append = T, na = '')
  
}

shell.exec(temp_directory)



### Run tests ##################################################################


test_that("summary data output as expected", {
  
  
  # create expected summary file
  ABC_Water_Summary <- list(
    data = tribble(
      ~Field_Name,              ~Sample_Name, ~Material,          ~NH4_mg_per_L_as_NH4,  ~`00915_Ca_mg_per_L`,      ~`Mean_00681_NPOC_mg_per_L_as_C`,  ~`Mean_00602_TN_mg_per_L_as_N`, ~Mean_Missing_Reps,
      "#Start_Data",          "ABC_001_Water", "Liquid>aqueous",   .123,                   -9999,                       .550,                             .15,                              TRUE, 
      "N/A",                  "ABC_002_Water", "Liquid>aqueous",   .456,                   .021,                        .777,                             .788,                             FALSE,  
      "N/A",                  "ABC_003_Water", "Liquid>aqueous",   .789,                   .222,                        -9999,                            .234,                             TRUE,  
      "N/A",                  "ABC_004_Water", "Liquid>aqueous",   .101,                   .324,                        -9999,                            -9999,                            FALSE,  
      "N/A",                  "ABC_005_Water", "Liquid>aqueous",   -9999,                  -9999,                       -9999,                            -9999,                            TRUE,  
      "N/A",                  "ABC_006_Water", "Liquid>aqueous",   .131,                   .627,                        -9999,                            -9999,                            FALSE,    
      "N/A",                  "ABC_007_Water", "Liquid>aqueous",   -9999,                  .282,                        -9999,                            -9999,                            TRUE,  
      "N/A",                  "ABC_008_Water", "Liquid>aqueous",   .161,                   .930,                        -9999,                            -9999,                            FALSE,  
      "N/A",                  "ABC_009_Water", "Liquid>aqueous",   .718,                   .313,                        -9999,                            -9999,                            FALSE,  
      "#End_Data",             NA,             NA,                 NA,                     NA,                          NA,                               NA,                               NA 
    ),
    
    headers = tribble(
      ~Field_Name,              ~Sample_Name, ~Material,          ~NH4_mg_per_L_as_NH4,      ~`00915_Ca_mg_per_L`,      ~`Mean_00681_NPOC_mg_per_L_as_C`,  ~`Mean_00602_TN_mg_per_L_as_N`, ~Mean_Missing_Reps,
      "Unit",                   "N/A",        "N/A",              "milligrams_per_liter",    "milligrams_per_liter",    "milligrams_per_liter",      "milligrams_per_liter",       "N/A",                             
      "Unit_Basis",            "N/A",        "N/A",              "as_Ammonium",             "as_Calcium",             "as_dissolvable_Carbon",    "as_dissolvable_Nitrogen",       "N/A",                          
      "MethodID_Analysis",     "N/A",        "N/A",              "ION_T_AN_005",            "ION_T_AN_005",          "NPOC_T_AN_000",            "TN_T_AN_000",                    "N/A",             
      "MethodID_Inspection",   "N/A",        "N/A",              "ION_T_IN_005",            "ION_T_IN_005",          "NPOC_T_IN_000",            "TN_T_IN_000",                    "N/A",             
      "MethodID_Storage",      "N/A",        "N/A",              "ION_T_ST_005",            "ION_T_ST_005",          "NPOC_T_ST_000",            "TN_T_ST_000",                    "N/A",             
      "MethodID_Preservation",  "N/A",        "N/A",              "ION_T_PRES_005",          "ION_T_PRES_005",        "NPOC_T_PRES_000",          "TN_T_PRES_000",                 "N/A",                
      "MethodID_Preparation",   "N/A",        "N/A",              "ION_T_PREP_005",          "ION_T_PREP_005",        "NPOC_T_PREP_000",          "TN_T_PREP_000",                 "N/A",                
      "MethodID_DataProcessing","N/A",        "N/A",              "ION_T_DP_005",            "ION_T_DP_005",          "NPOC_T_DP_000",            "TN_T_DP_000",                   "N/A",              
      "Analysis_DetectionLimit","-9999",      "-9999",            "0.13",                    "0.77",                  "0.27",                     "0.07",                          "N/A",       
      "Analysis_Precision",     "-9999",      "-9999",            "-9999",                   "-9999",                 "-9999",                    "-9999",                         "N/A",        
      "Data_Status",            "N/A",        "N/A",              "ready_to_use",            "ready_to_use",          "ready_to_use",             "ready_to_use",                  "N/A"
    )
    
  )
  
  expect_equal(summary, ABC_Water_Summary$data)
  
  
})


test_that("summary headers output as expected", {
  
  expect_equal(combine_headers, ABC_Water_Summary$headers)
  
})



ABC_Water_all_columns_Summary <- testing_data$ABC_Water_all_columns$data %>%
  mutate(across(where(is.numeric),
                      ~ case_when(str_detect(Methods_Deviation, "Br_OUTLIER_000") & str_detect(cur_column(), "_Br_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "C_OUTLIER_000") & str_detect(cur_column(), "_C_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "Ca_OUTLIER_000") & str_detect(cur_column(), "_Ca_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "Cl_OUTLIER_000") & str_detect(cur_column(), "_Cl_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "DIC_OUTLIER_000") & str_detect(cur_column(), "_DIC_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "F_OUTLIER_000") & str_detect(cur_column(), "_F_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "K_OUTLIER_000") & str_detect(cur_column(), "_K_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "Li_OUTLIER_000") & str_detect(cur_column(), "_Li_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "Mg_OUTLIER_000") & str_detect(cur_column(), "_Mg_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "N_OUTLIER_000") & str_detect(cur_column(), "_N_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "Na_OUTLIER_000") & str_detect(cur_column(), "_Na_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "NH4_OUTLIER_000") & str_detect(cur_column(), "_NH4_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "NO2_OUTLIER_000") & str_detect(cur_column(), "_NO2_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "NO3_OUTLIER_000") & str_detect(cur_column(), "_NO3_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "NPOC_OUTLIER_000") & str_detect(cur_column(), "_NPOC_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "PO4_OUTLIER_000") & str_detect(cur_column(), "_PO4_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "Rate_OUTLIER_000") & str_detect(cur_column(), "_Rate_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "SFE_OUTLIER_000") & str_detect(cur_column(), "_SFE_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "SO4_OUTLIER_000") & str_detect(cur_column(), "_SO4_") ~ NA_real_,
                                  str_detect(Methods_Deviation, "TN_OUTLIER_000") & str_detect(cur_column(), "_TN_") ~ NA_real_,
                                  T ~ .)),
         across(where(is.numeric), ~ replace_na(., -9999)))
  