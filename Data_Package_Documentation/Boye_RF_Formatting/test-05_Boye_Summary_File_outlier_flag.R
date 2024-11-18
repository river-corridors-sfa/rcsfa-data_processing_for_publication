### test-05_Boye_Summary_File.R ################################################
# Date Created: 2024-10-31
# Date Updated: 2024-11-18
# Author: Bibi Powers-McCormack

# Objective: 
  # create testing environment for Boye Summary file

# Directions: 
  # 1. Run prep script chunk
  # 2. Run create testing data Chunk
  # 3. Go to `05_Boye_Summary_File.R` and add temp_directory as dir (dir <- temp_directory) and material as water (material <- "water")
  # 4. Run `05_Boye_Summary_File.R` and stop before you write anything out
  # 5. Return to this script and run the run tests chunk


### Prep script ################################################################

library(tidyverse)
library(testthat)
library(rlog)


### Create testing data ########################################################

# create testing data
temp_directory <- tempdir()
log_info(paste0("Opening temp directory: ", temp_directory))
shell.exec(temp_directory)

# create 2 Water sample files
testing_data <- list(
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
    
    # these cols are pulled manually from RC-SFA_ColumnHeader_Lookup.csv: https://pnnl.sharepoint.com/:x:/r/teams/Lab-FieldTeam/Shared%20Documents/Data%20Generation%20and%20Files/Protocols-Guidance-Workflows-Methods/RC-SFA_ColumnHeader_Lookup.csv?d=w2d7744ec283a49b7922b6a31dabb1437&csf=1&web=1&e=owSrSk
    # the outlier values are manually pulled from Methods_Deviation_Codes (MethodsID_DataProcessing tab): https://pnnl.sharepoint.com/:x:/r/teams/Lab-FieldTeam/Shared%20Documents/Data%20Generation%20and%20Files/Protocols-Guidance-Workflows-Methods/Methods_Codes/Method_Deviation_Codes.xlsx?d=wfca78e071aa849c89a155dcd6501f37e&csf=1&web=1&e=UFWlwO&nav=MTVfezc2QUM2MTg0LUQ2QzUtNDE0My1BRTY2LTAzOEZBQzA5MDlCM30
       # note: need to finish creating this example df and add outliers
    Br_OUTLIER_000
    C_OUTLIER_000
    Ca_OUTLIER_000
    Cl_OUTLIER_000
    DIC_OUTLIER_000
    F_OUTLIER_000
    K_OUTLIER_000
    Li_OUTLIER_000
    Mg_OUTLIER_000
    N_OUTLIER_000
    Na_OUTLIER_000
    NH4_OUTLIER_000
    NO2_OUTLIER_000
    NO3_OUTLIER_000
    NPOC_OUTLIER_000
    PO4_OUTLIER_000
    RATE_OUTLIER_000
    SFE_OUTLIER_000
    SO4_OUTLIER_000
    TN_OUTLIER_000
    
    
    data = tibble(Field_Name, 
                  Sample_Name, 
                  Material, 
                  Methods_Deviation, 
                  X00681_NPOC_mg_per_L_as_C,
                  X00602_TN_mg_per_L_as_N,
                  X00691_DIC_mg_per_L_as_C,
                  X00530_TSS_mg_per_L,
                  NH4_mg_per_L_as_NH4,
                  X71870_Br_mg_per_L,
                  X00915_Ca_mg_per_L,
                  X00940_Cl_mg_per_L,
                  X00950_F_mg_per_L,
                  X01130_Li_mg_per_L,
                  X00925_Mg_mg_per_L,
                  X71851_NO3_mg_per_L_as_NO3,
                  X71856_NO2_mg_per_L_as_NO2,
                  X00653_PO4_mg_per_L_as_PO4,
                  X00935_K_mg_per_L,
                  X00930_Na_mg_per_L,
                  X00945_SO4_mg_per_L_as_SO4,
                  X01472_N_percent_per_mg,
                  X01463_C_percent_per_mg,
                  pH,
                  Mean_pH,
                  StDev_pH,
                  Specific_Conductance_microsiemens_per_centimeter,
                  Mean_Specific_Conductance_microsiemens_per_centimeter,
                  StDev_Mean_Specific_Conductance_microsiemens_per_centimeter,
                  Temperature_degrees_Celsius,
                  Mean_Temperature_degrees_Celsius,
                  StDev_Temperature_degrees_Celsius,
                  Fe_mg_per_L,
                  Mean_Fe_mg_per_L,
                  StDev_Fe_mg_per_L,
                  Fe_mg_per_kg,
                  Mean_Fe_mg_per_kg,
                  StDev_Fe_mg_per_mg,
                  Wet_Sediment_Mass_g,
                  Dry_Sediment_Mass_g,
                  Water_Mass_g,
                  Wet_Sediment_mL,
                  MBD_P_mg_per_L,
                  Total_Ca_mg_per_L,
                  Total_Mg_mg_per_L,
                  Total_P_mg_per_L,
                  Total_K_mg_per_L,
                  Total_Na_mg_per_L,
                  Total_S_mg_per_L,
                  Total_Al_mg_per_L,
                  Total_Fe_mg_per_L,
                  `52718_Total_Ca_mg_per_kg`,
                  `52719_Total_Mg_mg_per_kg`,
                  `52720_Total_K_mg_per_kg`,
                  `52721_Total_Na_mg_per_kg`,
                  `01466_Total_S_mg_per_kg`,
                  `01462_Total_Al_mg_per_kg`,
                  `01464_Total_Fe_mg_per_kg`,
                  Total_P_mg_per_L,
                  Total_P_mg_per_kg,
                  Total_Ca_mg_per_kg,
                  Total_Mg_mg_per_kg,
                  Total_P_mg_per_kg,
                  Total_K_mg_per_kg,
                  Total_Na_mg_per_kg,
                  Total_S_mg_per_kg,
                  Total_Al_mg_per_kg,
                  Total_Fe_mg_per_kg,
                  Dissolved_Oxygen_mg_per_L,
                  Quartz_percent,
                  Albite_percent,
                  Microcline_percent,
                  Muscovite_percent,
                  Chlorite_percent,
                  Amphibole_percent,
                  Pyroxene_percent,
                  Calcite_percent,
                  Apatite_percent,
                  Crystallinity,
                  Dolomite_percent,
                  Smectite_percent,
                  `01397_N_percent_per_mg`,
                  `01395_C_percent_per_mg`,
                  Specific_Surface_Area_m2_per_g,
                  Wet_Sediment_Mass_Added_Water_g,
                  Added_Water_Mass_g,
                  Total_Water_Mass_g,
                  Initial_Water_Mass_g,
                  Final_Water_Mass_g,
                  Incubation_Water_Mass_g,
                  Wet_Sediment_Mass_MOI_g,
                  Dry_Sediment_Mass_MOI_g,
                  `62948_Gravimetric_Moisture_g_per_g`,
                  `62948_Initial_Gravimetric_Moisture_g_per_g`,
                  `62948_Final_Gravimetric_Moisture_g_per_g`,
                  Water_Mass_MOI_g,
                  Elapsed_Minute,
                  Date,
                  Respiration_Rate_mg_DO_per_L_per_H,
                  Mean_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H,
                  StDev_WithOutliers_Respiration_Rate_mg_DO_per_L_per_H,
                  Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H,
                  StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_L_per_H,
                  Respiration_Rate_mg_DO_per_kg_per_H,
                  Mean_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H,
                  StDev_WithOutliers_Respiration_Rate_mg_DO_per_kg_per_H,
                  Mean_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H,
                  StDev_OutliersRemoved_Respiration_Rate_mg_DO_per_kg_per_H,
                  Respiration_R_Squared,
                  Respiration_R_Squared_Adj,
                  Respiration_p_value,
                  Total_Incubation_Time_Min,
                  Number_Points_In_Respiration_Regression,
                  Number_Points_Removed_Respiration_Regression,
                  DO_Concentration_At_Incubation_Time_Zero,
                  ATP_nanomoles_per_L,
                  Mean_ATP_nanomol_per_L,
                  StDev_ATP_nanomol_per_L,
                  ATP_picomoles_per_g,
                  Mean_ATP_picomol_per_g,
                  StDev_ATP_picomol_per_g,
                  Extractable_NPOC_mg_per_kg,
                  Extractable_TN_mg_per_kg,
                  Extractable_NPOC_mg_per_L,
                  Extractable_TN_mg_per_L,
                  B6CA_uM,
                  B5CA_uM,
                  Percent_Fine_Sand,
                  Percent_Med_Sand,
                  Percent_Coarse_Sand,
                  Percent_Tot_Sand,
                  Percent_Silt,
                  Percent_Clay)
    
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



### Run tests ##################################################################


test_that("summary data output as expected", {
  
  expect_equal(summary, ABC_Water_Summary$data)
  
  
})


test_that("summary headers output as expected", {
  
  expect_equal(combine_headers, ABC_Water_Summary$headers)
  
})
