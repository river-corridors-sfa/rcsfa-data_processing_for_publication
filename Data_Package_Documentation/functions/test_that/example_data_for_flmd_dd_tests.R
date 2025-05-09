# example_data_for_flmd_dd_tests.R #############################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-01
# Date Updated: 2025-05-02

# Objective: 


### Prep script ################################################################

# load libraries
library(tidyverse)
library(rlog)


### Create directories #########################################################

# create temporary testing directory
create_test_dir <- function(root = tempdir()) {
  # Create root data package directory
  base_dir <- file.path(root, "example_data_package")
  fs::dir_create(base_dir)
  
  # Create subdirectories
  fs::dir_create(file.path(base_dir, "data"))
  fs::dir_create(file.path(base_dir, "scripts"))
  
  return(base_dir)
}

### Create example data #########################################################

# add readme
add_example_readme <- function(directory){
  
  # open PDF device
  pdf(file.path(directory, "readme_example_data_package.pdf"), width = 8, height = 11)
  
  # Sst up empty plot area
  plot.new()
  text(0.5, 0.5, "This is a pdf placeholder", cex = 1.5)
  
  # close PDF device
  dev.off()
  
  log_info("add_example_readme() complete")
  
}


# add flmd
add_example_flmd <- function(directory){
  
  example_flmd <- tibble(
    File_Name = c("data_2020.csv", "survey_2021.csv", "results_old.csv"),
    File_Description = c("Annual data", "User survey", "Archived results"),
    Standard = c("ESS-DIVE CSV v1", "ESS-DIVE CSV v1", "ESS-DIVE CSV v1"),
    Header_Rows = c(4, 1, 1),
    Column_or_Row_Name_Position = c(1, 1, 1),
    File_Path = c("data/raw/data_2020.csv", "data/interim/survey_2021.csv", "archive/results_old.csv")
  )
  
  write_csv(example_flmd, file.path(directory, "example_flmd.csv"))
  
  log_info("add_example_flmd() complete")
  
}


# add dd
add_example_dd <- function(directory){
  
  example_dd <- tibble(
    Column_or_Row_Name = c("Temperature", "pH", "Dissolved_Oxygen"),
    Unit = c("degree_celsius", "pH", "milligrams perv liter"),
    Definition = c(
      "Water temperature measured at the time of sampling",
      "Acidity/alkalinity of the water sample",
      "Amount of dissolved oxygen in the water sample"
    ),
    Missing_Value_Code = '"-9999"; "N/A"; ""; "NA',
    Data_Type = c("numeric", "numeric", "numeric")
  )
  
  write_csv(example_dd, file.path(directory, "example_dd.csv"))
  
  log_info("add_example_dd() complete")
  
}


# add boye
add_example_boye <- function(directory){
  
  tribble(
    ~V1,                   ~V2,             ~V3,               ~V4,                            ~V5,                            ~V6,
    "#Columns",            "6",             NA,                NA,                             NA,                             NA,
    "#Header_Rows",        "5",             NA,                NA,                             NA,                             NA,
    "Field_Name",          "Sample_Name",   "Material",        "00681_NPOC_mg_per_L_as_C",     "00602_TN_mg_per_L_as_N",       "Methods_Deviation",
    "Unit",                "N/A",           "N/A",             "milligrams_per_liter",         "milligrams_per_liter",         "N/A",
    "Unit_Basis",          "N/A",           "N/A",             "as_dissolvable_Carbon",        "as_dissolvable_Nitrogen",      "N/A",
    "MethodID_Analysis",   "N/A",           "N/A",             "NPOC_T_AN_000",                "TN_T_AN_000",                  "N/A",
    "MethodID_Inspection", "N/A",           "N/A",             "NPOC_T_IN_000",                "TN_T_IN_000",                  "N/A",
    "MethodID_Storage",    "N/A",           "N/A",             "NPOC_T_ST_000",                "TN_T_ST_000",                  "N/A",
    "MethodID_Preservation","N/A",          "N/A",             "NPOC_T_PRES_000",              "TN_T_PRES_000",                "N/A",
    "MethodID_Preparation","N/A",           "N/A",             "NPOC_T_PREP_000",              "TN_T_PREP_000",                "N/A",
    "MethodID_DataProcessing","N/A",        "N/A",             "NPOC_T_DP_000",                "TN_T_DP_000",                  "N/A",
    "Analysis_DetectionLimit","-9999",      "-9999",           "0.09",                         "0.01",                         "N/A",
    "Analysis_Precision",  "-9999",         "-9999",           "-9999",                        "-9999",                        "N/A",
    "Data_Status",         "N/A",           "N/A",             "ready_to_use",                 "ready_to_use",                 "N/A",
    "#Start_Data",         "SSS001_OCN-1",  "Liquid>aqueous",  "0.94",                         "TN_Below_0.1_ppm_Standard|0.05_ppm_Raw_Not_Corrected|0.05_ppm_Final_Corrected", "DTL_003",
    "N/A",                 "SSS001_OCN-2",  "Liquid>aqueous",  "1.03",                         "TN_Below_0.1_ppm_Standard|0.05_ppm_Raw_Not_Corrected|0.05_ppm_Final_Corrected", "DTL_003"
  )
  %>% 
    write_csv(., na = "", col_names = F, 
                file.path(directory, "data", "example_boye.csv"))
  
  log_info("add_example_boye() complete")
  
}


# add goldman
add_example_goldman <- function(directory){
  
  tribble(
    ~V1, ~V2, ~V3, ~V4, ~V5, ~V6, ~V7,
    "# HeaderRows_8", NA, NA, NA, NA, NA, NA,
    "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary", NA, NA, NA, NA, NA, NA,
    "# DateTime; YYYY-MM-DDhh:mm:ss; Minidot_03; PME miniDOT Logger real time clock.", NA, NA, NA, NA, NA, NA,
    "# Battery; volts; Minidot_03; PME miniDOT Logger internal batteries.", NA, NA, NA, NA, NA, NA,
    "# Temperature; degree_celsius; Minidot_03; PME miniDOT Logger with temperature sensor.", NA, NA, NA, NA, NA, NA,
    "# Dissolved_Oxygen; milligrams_per_liter; Minidot_03; PME miniDOT Logger with optical dissolved oxygen sensor (fluorescence quenching).", NA, NA, NA, NA, NA, NA,
    "# Dissolved_Oxygen_Saturation; percent_saturation; Minidot_03; PME MiniDOT Logger with optical dissolved oxygen sensor (fluorescence quenching). Calculated using Garcia & Gordon (1992) equation.", NA, NA, NA, NA, NA, NA,
    "DateTime", "Parent_ID", "Site_ID", "Battery", "Temperature", "Dissolved_Oxygen", "Dissolved_Oxygen_Saturation",
    "2022-07-26 00:00:00", "SSS001", "S63", "3.49", "17.507", "8.829", "99.023",
    "2022-07-26 00:01:00", "SSS001", "S63", "3.49", "17.49", "8.836", "99.056",
    "2022-07-26 00:02:00", "SSS001", "S63", "3.49", "17.49", "8.839", "99.087"
  ) %>% 
    write_csv(., na = "", col_names = F, 
              file.path(directory, "data", "example_goldman.csv"))
  
  log_info("add_example_goldman() complete")
  
}



# add regular csv
add_example_data <- function(directory){
  
  write_csv(tibble(
    id = 1:3, 
    value = c(10, 20, 30)),
    file.path(directory, "data", "file_a.csv"))
  
  write_csv(tibble(
    ID = 1:3,
    Name = c("Alice", "Bob", "Charlie"),
    Score = c(85.5, 92.0, 78.3),
    Passed = Score >= 80), 
    file.path(directory, "data", "file_b.csv"))
  
  log_info("add_example_data() complete")
  
}

# add csv with header row below column name
add_example_data_with_header_rows <- function(directory){
  
  
  write_csv(tibble(
    Name = c("HEADER ROW", "Alice", "Bob", "Charlie"),
    Score = c(NA, 85.5, 92.0, 78.3),
    Passed = Score >= 80), 
    file.path(directory, "data", "file_c.csv"))
  
  log_info("add_example_data_with_header_rows() complete")
  
}


# add script
add_example_script <- function(directory){
  
  write_lines(
    c("# Example R script", "print('Hello world')"),
    file.path(directory, "scripts", "01_script.R")
  )
  
  log_info("add_example_script() complete")
}

