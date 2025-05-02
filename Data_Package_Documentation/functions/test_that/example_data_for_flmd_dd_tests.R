# example_data_for_flmd_dd_tests.R #############################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-05-01
# Date Updated: 2025-05-02

# Objective: 


### Prep script ################################################################




# create temporary testing directory
create_test_dir <- function(root = tempdir()) {
  # Create root data package directory
  base_dir <- file.path(root, "example_data_package")
  fs::dir_create(base_dir)
  
  # Create subdirectories
  fs::dir_create(file.path(base_dir, "data"))
  fs::dir_create(file.path(base_dir, "scripts"))
  
  # Create example files with optional content
  readr::write_lines("This is a PDF placeholder.", file.path(base_dir, "readme_example_data_package.pdf"))
  
  # Data file in data/
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(10, 20, 30)),
    file.path(base_dir, "data", "file_a.csv")
  )
  
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(40, 50, 60)),
    file.path(base_dir, "file_flmd.csv")
  )
  
  readr::write_csv(
    tibble::tibble(id = 1:3, value = c(70, 80, 90)),
    file.path(base_dir, "file_dd.csv")
  )
  
  # R script in scripts/
  readr::write_lines(
    c("# Example R script", "print('Hello world')"),
    file.path(base_dir, "scripts", "01_script.R")
  )
  
  return(base_dir)
}



# exampele boye file

library(tibble)

tribble(
  ~V1,               ~V2,         ~V3,                                                            ~V4,                ~V5,                                ~V6,                          ~V7,
  "#Columns",        "6",         NA,                                                             NA,                 NA,                                 NA,                          NA,
  "#Header_Rows",    "5",         NA,                                                             NA,                 NA,                                 NA,                          NA,
  "Column_Name",     "Sample_Name", "Material",                                                  "imidacloprid",     "MethodID_Analysis_imidacloprid",   "Analysis_Detection_Limit_imidacloprid", "Notes_imidacloprid",
  "Unit",            "N/A",       "N/A",                                                          "microgram_per_liter", "N/A",                            "N/A",                        "N/A",
  "Unit_Basis",      "N/A",       "N/A",                                                          "molecular_weight", "N/A",                               "N/A",                        "N/A",
  "Analysis_Precision", "-9999", "-9999",                                                        "-9999",            "-9999",                            "-9999",                     "-9999",
  "Data_Status",     "N/A",       "N/A",                                                          "QAQC_final",       "N/A",                               "N/A",                        "N/A",
  "#Start_Data",     "M42_2007",  "liquid environmental material: liquid water: surface water",   "0.16",             "OMK57",                            "0.08",                      "N/A",
  "N/A",             "M42_2008",  "liquid environmental material: liquid water: surface water",   "-9999",            "OMK57",                            "0.2",                       "Below detection limit",
  "N/A",             "M42_2009",  "liquid environmental material: liquid water: surface water",   "0.13",             "OMK59",                            "0.003",                     "Methodology and detection limit change",
  "N/A",             "M42_2010",  "liquid environmental material: liquid water: surface water",   "0.09",             "OMK59",                            "0.003",                     "N/A",
  "N/A",             "M42_2011",  "liquid environmental material: liquid water: surface water",   "0.18",             "OMK59",                            "0.001",                     "N/A",
  "N/A",             "M42_2012",  "liquid environmental material: liquid water: surface water",   "0.14",             "OMK59",                            "0.002",                     "N/A",
  "#End_Data",       NA,          NA,                                                             NA,                 NA,                                 NA,                          NA
)


# example goldman file

library(tibble)

tribble(
  ~DateTime, ~Parent_ID, ~Site_ID, ~Battery, ~Temperature, ~Dissolved_Oxygen, ~Dissolved_Oxygen_Saturation,
  "# HeaderRows_8", NA, NA, NA, NA, NA, NA,
  "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary", NA, NA, NA, NA, NA, NA,
  "# DateTime; YYYY-MM-DDhh:mm:ss; Minidot_03; PME miniDOT Logger real time clock.", NA, NA, NA, NA, NA, NA,
  "# Battery; volts; Minidot_03; PME miniDOT Logger internal batteries.", NA, NA, NA, NA, NA, NA,
  "# Temperature; degree_celsius; Minidot_03; PME miniDOT Logger with temperature sensor.", NA, NA, NA, NA, NA, NA,
  "# Dissolved_Oxygen; milligrams_per_liter; Minidot_03; PME miniDOT Logger with optical dissolved oxygen sensor (fluorescence quenching).", NA, NA, NA, NA, NA, NA,
  "# Dissolved_Oxygen_Saturation; percent_saturation; Minidot_03; PME MiniDOT Logger with optical dissolved oxygen sensor (fluorescence quenching). Calculated using Garcia & Gordon (1992) equation.", NA, NA, NA, NA, NA, NA,
  "2022-07-26 00:00:00", "SSS001", "S63", 3.49, 17.507, 8.829, 99.023,
  "2022-07-26 00:01:00", "SSS001", "S63", 3.49, 17.49, 8.836, 99.056,
  "2022-07-26 00:02:00", "SSS001", "S63", 3.49, 17.49, 8.839, 99.087
)
