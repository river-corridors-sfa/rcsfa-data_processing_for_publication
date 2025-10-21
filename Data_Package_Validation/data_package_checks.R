### data_package_checks.R ######################################################

# Objective: Use this script to run data package checks.

# This script walks you through the steps to read in the data and run it through
# the checks. It relies on `checks.R`, which is the script that houses the
# functions that validate the data and produce tabular outputs. Those tabular
# outputs are then read into the `checks_report.Rmd` file to create the graphics
# and visual report.

# See README_data_package_checks.md for more details on how to run or update the
# checks.

rm(list=ls(all=T))

### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

#### REQUIRED ----

# provide the absolute folder file path (do not include "/" at end)
user_directory <- "Z:/00_ESSDIVE/01_Study_DPs/SSS_Ecosystem_Respiration_Data_Package_v2/v2_SSS_Ecosystem_Respiration_Data_Package"

# provide the name of the person running the checks
report_author <- "Brieanne Forbes"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- "Z:/00_ESSDIVE/01_Study_DPs/SSS_Ecosystem_Respiration_Data_Package_v2"

# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- T

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- T

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- list.files(user_directory, pattern = 'flmd', full.names = T)

#### OPTIONAL ----

# TIPS for including/excluding files: 
  # Example 1: Suppose your data package contains 100 sensor files with
  # standardized "Goldman" headers and 5 regular CSV files. Instead of writing
  # out all 100 file names just to exclude them, you can use the include_files
  # argument to explicitly list the 5 files you do want to process. This is more
  # efficient and makes your code easier to manage.
  
  # Example 2: If you have 75 regular files and 3 files with header rows, you
  # can process them separately by first running the function with
  # query_header_info = TRUE and include_files set to the 3 files to extract
  # their header metadata. Then, run the function again with query_header_info =
  # FALSE and exclude_files set to the same 3 files to process the 75 regular
  # files.

# exclude_files = vector of files (relative file path + file name; no / at beginning of path) to exclude from within the dir. Optional argument; default is NA_character_. (Tip: Select files in file browser. Click "Copy Path". Paste within c() here. To add commas: Shift+Alt > drag to select all lines > end > comma) 

user_exclude_files = c("Stream_Metabolizer/Histogram_Plots/histogram_SSS048_S29.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS002_S30R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS003_S31.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS004_S55N.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS005_S57.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS006_S56N.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS007_S53.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS008_S52.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS009_S45.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS010_S10.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS011_S04.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS012_S50P.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS013_T07.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS014_T02.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS015_T03.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS016_T42.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS017_S58.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS018_S08.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS019_S03.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS020_T05P.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS021_S24.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS022_S15.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS023_U20.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS024_W20.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS025_S34R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS026_S36.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS027_S32.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS028_S42.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS029_S41R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS030_S43.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS031_S47R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS032_C21.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS033_S48R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS034_S18R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS035_S17R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS036_W10.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS037_S39.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS038_S38.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS039_S37.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS040_S54.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS041_S49R.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS042_S51.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS043_S11.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS044_S02.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS045_S01.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS046_S22RR.png",
                       "Stream_Metabolizer/Histogram_Plots/histogram_SSS047_S23.png",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS048_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS002_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS003_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS004_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS005_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS006_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS007_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS008_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS009_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS010_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS011_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS012_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS013_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS014_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS015_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS016_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS017_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS018_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS019_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS020_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS021_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS022_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS023_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS024_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS025_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS026_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS027_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS028_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS029_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS030_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS031_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS032_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS033_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS034_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS035_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS036_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS037_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS038_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS039_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS040_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS041_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS042_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS043_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS044_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS045_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS046_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/v2_SSS047_Temp_DO_Press_Depth.csv",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS048_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS002_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS003_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS004_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS005_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS006_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS007_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS008_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS009_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS010_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS011_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS012_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS013_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS014_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS015_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS016_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS017_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS018_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS019_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS020_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS021_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS022_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS023_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS024_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS025_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS026_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS027_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS028_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS029_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS030_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS031_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS032_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS033_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS034_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS035_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS036_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS037_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS038_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS039_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS040_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS041_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS042_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS043_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS044_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS045_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS046_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Inputs/Sensor_Files/Plots/SSS047_Temp_DO_Press_Depth_Plot.html",
                       "Stream_Metabolizer/Outputs/v2_SSS046_S22RR_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS047_S23_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS047_S23_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS047_S23_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS047_S23_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS047_S23_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS048_S29_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS048_S29_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS048_S29_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS048_S29_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS048_S29_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS002_S30R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS002_S30R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS002_S30R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS002_S30R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS002_S30R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS003_S31_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS003_S31_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS003_S31_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS003_S31_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS003_S31_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS004_S55N_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS004_S55N_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS004_S55N_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS004_S55N_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS004_S55N_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS005_S57_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS005_S57_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS005_S57_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS005_S57_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS005_S57_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS006_S56N_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS006_S56N_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS006_S56N_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS006_S56N_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS006_S56N_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS007_S53_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS007_S53_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS007_S53_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS007_S53_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS007_S53_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS008_S52_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS008_S52_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS008_S52_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS008_S52_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS008_S52_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS009_S45_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS009_S45_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS009_S45_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS009_S45_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS009_S45_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS010_S10_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS010_S10_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS010_S10_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS010_S10_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS010_S10_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS011_S04_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS011_S04_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS011_S04_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS011_S04_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS011_S04_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS012_S50P_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS012_S50P_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS012_S50P_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS012_S50P_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS012_S50P_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS013_T07_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS013_T07_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS013_T07_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS013_T07_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS013_T07_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS014_T02_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS014_T02_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS014_T02_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS014_T02_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS014_T02_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS015_T03_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS015_T03_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS015_T03_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS015_T03_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS015_T03_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS016_T42_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS016_T42_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS016_T42_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS016_T42_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS016_T42_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS017_S58_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS017_S58_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS017_S58_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS017_S58_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS017_S58_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS018_S08_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS018_S08_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS018_S08_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS018_S08_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS018_S08_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS019_S03_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS019_S03_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS019_S03_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS019_S03_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS019_S03_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS020_T05P_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS020_T05P_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS020_T05P_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS020_T05P_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS020_T05P_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS021_S24_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS021_S24_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS021_S24_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS021_S24_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS021_S24_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS022_S15_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS022_S15_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS022_S15_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS022_S15_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS022_S15_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS023_U20_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS023_U20_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS023_U20_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS023_U20_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS023_U20_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS024_W20_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS024_W20_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS024_W20_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS024_W20_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS024_W20_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS025_S34R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS025_S34R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS025_S34R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS025_S34R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS025_S34R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS026_S36_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS026_S36_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS026_S36_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS026_S36_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS026_S36_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS027_S32_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS027_S32_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS027_S32_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS027_S32_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS027_S32_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS028_S42_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS028_S42_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS028_S42_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS028_S42_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS028_S42_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS029_S41R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS029_S41R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS029_S41R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS029_S41R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS029_S41R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS030_S43_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS030_S43_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS030_S43_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS030_S43_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS030_S43_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS031_S47R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS031_S47R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS031_S47R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS031_S47R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS031_S47R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS032_C21_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS032_C21_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS032_C21_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS032_C21_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS032_C21_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS033_S48R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS033_S48R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS033_S48R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS033_S48R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS033_S48R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS034_S18R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS034_S18R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS034_S18R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS034_S18R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS034_S18R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS035_S17R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS035_S17R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS035_S17R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS035_S17R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS035_S17R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS036_W10_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS036_W10_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS036_W10_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS036_W10_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS036_W10_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS037_S39_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS037_S39_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS037_S39_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS037_S39_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS037_S39_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS038_S38_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS038_S38_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS038_S38_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS038_S38_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS038_S38_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS039_S37_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS039_S37_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS039_S37_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS039_S37_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS039_S37_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS040_S54_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS040_S54_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS040_S54_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS040_S54_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS040_S54_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS041_S49R_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS041_S49R_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS041_S49R_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS041_S49R_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS041_S49R_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS042_S51_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS042_S51_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS042_S51_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS042_S51_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS042_S51_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS043_S11_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS043_S11_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS043_S11_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS043_S11_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS043_S11_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS044_S02_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS044_S02_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS044_S02_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS044_S02_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS044_S02_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS045_S01_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS045_S01_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS045_S01_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS045_S01_SM_final_overall_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS045_S01_SM_output.HTML",
                       "Stream_Metabolizer/Outputs/v2_SSS046_S22RR_SM_final_daily_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS046_S22RR_SM_final_full_prediction_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS046_S22RR_SM_final_instant_fit_results.csv",
                       "Stream_Metabolizer/Outputs/v2_SSS046_S22RR_SM_final_overall_fit_results.csv"
                       )

# include_files = vector of files (relative file path + file name) to include from within the dir. Optional argument; default is NA_character_. 
user_include_files = NA_character_

# include_dot_files = T/F to indicate whether you want to include hidden files that begin with "." (usually github related files). Optional argument; default is FALSE.
user_include_dot_files = F


### Prep Script ################################################################
# Directions: Run this chunk without modification.
require(pacman)
p_load(here, # for setting wd at git repo
tidyverse,
rlog,
devtools, # for sourcing from github
hms, # for handling times
fs, # for tree diagram
clipr, # for copying to clipboard
knitr, # for kable
kableExtra, # for rmd report table styling
DT, # for interactive tables in report
rmarkdown, # for rendering report
plotly, # for interactive graphs
downloadthis, # for downloading tabular data report as .csv
cli) # for fnacy warning mesages 

current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("./..")

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Transformation/functions/load_tabular_data.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")


### Run Functions ##############################################################
# Directions: Run this chunk without modification. Answer inline prompts as they appear.

# confirm directory has files in it
# if (length(list.files(user_directory, recursive = T)) == 0) {
#   warning("Your directory has 0 files.")
# }

# 1. Get all files
dp_files <- get_files(directory = user_directory, 
                      exclude_files = user_exclude_files, 
                      include_files = user_include_files, 
                      include_dot_files = user_include_dot_files)


# 2. Load flmd if applicable
if (has_flmd == T) {
  data_package_flmd <- read_csv(flmd_path) %>% 
  # convert to R's NA
  mutate(across(everything(), ~ case_when(. == -9999 ~ NA, 
                                          . == "N/A" ~ NA,
                                          TRUE ~ .)))
} else if (has_flmd == F) {
  data_package_flmd <- NA 
  }


# 3. Load data
data_package_data <- load_tabular_data(files_df = dp_files, flmd_df = data_package_flmd, query_header_info = user_input_has_header_rows)

# preview data - this shows all the tabular data you loaded in so you can quickly check if it loaded in correctly without having to poke around in the nested lists
# invisible(lapply(names(data_package_data$tabular_data), function(name) {
#   cat("/n--- Data Preview of", name, "---/n")
#   glimpse(data_package_data$tabular_data[[name]])
# }))


# 4. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)


# 5. Generate report
out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document", output_dir = report_out_dir, output_file = out_file)
browseURL(paste0(report_out_dir, "/", out_file))

# 6. Check for duplicate sample names
for (file_path in names(data_package_data[["tabular_data"]])) {
  df <- data_package_data[["tabular_data"]][[file_path]]
  file_name <- basename(file_path)
  
  # Check if either Sample_Name or Sample_ID exists
  if ("Sample_Name" %in% colnames(df)) {
    # Check for duplicates in Sample_Name
    if (any(duplicated(df$Sample_Name))) {
      cli_alert_danger(paste("Duplicate Sample_Name values found in file:", file_name))
    } else {
      
      cli_alert_success('No duplicate Sample_Name values found')
    }
  }
  
  if ("Sample_ID" %in% colnames(df)) {
    # Check for duplicates in Sample_ID
    if (any(duplicated(df$Sample_ID))) {
      cli_alert_danger(paste("Duplicate Sample_ID values found in file:", file_name))
    }else {
      
      cli_alert_success('No duplicates Sample_ID values found')
    }
  }
}

# 7. Check that all numeric columns contain a Reported_Precision

if(any(str_detect(names(data_package_checks$input$tabular_data), "dd\\.csv$"))){
  
  dd_path <- names(data_package_checks$input$tabular_data)[
    str_detect(names(data_package_checks$input$tabular_data), "dd\\.csv$")
  ]
  
  ## Pull in dd to get units
  dd <- data_package_checks$input$tabular_data[[dd_path]]%>%
    select(Column_or_Row_Name, Data_Type, Reported_Precision)
  
  numeric <- dd %>%
    filter(Data_Type == 'numeric') %>%
    filter(Column_or_Row_Name != 'Reported_Precision')
  

  not_numeric <- dd %>%
    filter(Data_Type != 'numeric')
    
  if(any(numeric$Reported_Precision == -9999)){
    
    cli_alert_danger('A numeric column is missing a Reported_Precision')
  } else{
    
    cli_alert_success('All numeric columns have a Reported_Precision')
  }
  
  if(any(not_numeric$Reported_Precision != -9999)){
    
    cli_alert_danger('A non-numeric column contains a Reported_Precision')
  }else{
    
    cli_alert_success('All non-numeric columns do not have a Reported_Precision')
  }
  
  
}

# View tabular data ############################################################

tabular_data <- data_package_checks$tabular_report

# Find the path that contains "dd.csv"
dd_path <- names(data_package_checks$input$tabular_data)[
  str_detect(names(data_package_checks$input$tabular_data), "dd\\.csv$")
]

## Pull in dd to get units
dd <- data_package_checks$input$tabular_data[[dd_path]]%>%
  select(Column_or_Row_Name, Unit)

## look at missing values, negative values, num_empty_cells, duplicate rows, and non numeric data ####

view(tabular_data %>%
       filter(num_missing_rows>0))

view(tabular_data %>%
       filter(num_negative_rows>0))

view(tabular_data %>%
       filter(num_empty_cells>0))

view(tabular_data %>%
       filter(num_unique_rows!=num_rows))

view(tabular_data %>%
       filter(column_type != 'numeric'))

## look at min/max values ####

numeric_long <- tabular_data %>%
  left_join(dd, by = c('column_name' = 'Column_or_Row_Name')) %>%
  filter(column_type != 'POSIXct') %>%
  select(column_name, range_min, range_max, Unit) %>%
  mutate(range_min = as.numeric(range_min),
         range_max = as.numeric(range_max)) %>%
  filter(!is.na(range_min)) %>%
  rename(MIN = range_min,
         MAX = range_max) %>%
  pivot_longer(cols = c(MIN, MAX),
               names_to = "type",
               values_to = "value") %>%
  mutate(facet_label = paste0(column_name, " (", Unit, ") ", type)) %>%
  filter(!str_detect(column_name, "SSS|CM"))

plot <- ggplot(numeric_long, aes(x = value)) +
  geom_boxplot() +
  facet_wrap(~facet_label, scales = "free_x", ncol = 2) +
  theme_bw()  +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.title.x = element_blank(),
    plot.title = element_text(size = 10, color = "grey")
  ) +
  ggtitle(paste("The associated data checks report was created on", Sys.Date(), "by", report_author))

ggsave(
  paste0(report_out_dir, '/tabular_data_plots_',Sys.Date(),'.pdf'),
  plot,
  device = 'pdf',
  width = 10,
  height = 200,
  units = 'in',
  dpi = 300,
  limitsize = FALSE
)

