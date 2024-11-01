### test-05_Boye_Summary_File.R ################################################
# Date Created: 2024-10-31
# Date Updated: 2024-10-31
# Author: Bibi Powers-McCormack

# Objective: 
  # create testing environment for Boye Summary file


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
                                      "Data_Status",               "N/A",       "N/A",       "ready_to_use",            "ready_to_use",             "N/A"))
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
