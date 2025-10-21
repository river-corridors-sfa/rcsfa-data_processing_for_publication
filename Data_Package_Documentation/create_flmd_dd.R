# create_flmd_dd.R #############################################################

# Objective: 
  # Create an FLMD with the cols: File_Name, File_Description, Standard, Header_Rows, Column_or_Row_Name_Position, File_Path
  # Create a DD with the cols: Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, Missing_Value_Code

# Directions: 
  # 1. Fill out user inputs; then run the chunk. 
  # 2. Run the following chunks (you do not need to edit the code): Prep Script, Get Files, Create FLMD, Create DD
  # 3. Optionally, add code into the "Data Package Specific Edits" section if needed
  # 4. Run the "Export" chunk (you do not need to edit the code)

# If you need to edit the functions `get_files()`, `create_flmd()`, or
# `create_dd()`, refer to test-create_flmd() and test-create_dd() to ensure that
# your updates work as expected and haven't broken any existing functionality.

rm(list=ls(all=T))

### USER INPUTS ################################################################

#### REQUIRED ----


# directory = string of the absolute folder file path; do not include "/" at end.
my_directory = "Z:/00_ESSDIVE/01_Study_DPs/SSS_Ecosystem_Respiration_Data_Package_v2/v2_SSS_Ecosystem_Respiration_Data_Package"

# dp_keyword = string of the data package name; this will be used to name the placeholder flmd, dd, readme files in the flmd and name the FLMD and DD files. Optional argument; default is "data_package".

my_dp_keyword = "v2_SSS_ER"


# out_dir = string of the absolute folder you want the flmd and dd saved to; do not include "/" at end.
my_out_dir = 'Z:/00_ESSDIVE/01_Study_DPs/SSS_Ecosystem_Respiration_Data_Package_v2'

# populate_dd_flmd = indicate if you would like query the database to populate the dd and flmd. T/F
populate_dd_flmd = T

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
  # files. Finally, bind the outputs from both runs to combine them into a
  # single FLMD.

# exclude_files = vector of files (relative file path + file name; no / at beginning of path) to exclude from within the dir. Optional argument; default is NA_character_. (Tip: Select files in file browser. Click "Copy Path". Paste within c() here. To add commas: Shift+Alt > drag to select all lines > end > comma) 
user_exclude_files =  c("Stream_Metabolizer/Histogram_Plots/histogram_SSS048_S29.png",
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

# add_placeholders = T/F where the user should select T if they want placeholder rows for the flmd, readme, and dd if those files are missing. Optional argument; default is FALSE.
user_add_placeholders = T

# query_header_info = T/F where the user should select T if header rows are present and F if all tabular files do NOT have header rows. Header rows that start with "#" can be considered as not having header rows. Optional argument; default is FALSE.  
user_query_header_info = T

# file_n_max = number of rows to load in. The only time you'd want to change this is if there are more than 20 rows before the data matrix starts; if that is the case, then increase this number. Optional argument; default is 20. 
user_view_n_max = 20

# add_boye_headers = T/F where the user should select T if they want placeholder rows in the dd for Boye header row names. Optional argument; default is FALSE.
user_add_boye_headers = F

# add_flmd_dd_headers = T/F where the user should select T if they want placeholder rows for FLMD and DD column headers. Optional argument; default is FALSE. 
user_add_flmd_dd_headers = T

# include_filenames = T/F to indicate whether you want to include the file name(s) the headers came from. Optional argument; default is F. 
user_include_filenames = T

# dd_database_path = absolute path to the dd database 
user_dd_database_path <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/data_dictionary_database.csv"

# flmd_database_path = absolute path to the flmd database 
user_flmd_database_path <- "C:/Brieanne/GitHub/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/file_level_metadata_database.csv"

### Prep Script ################################################################

# load libraries
library(tidyverse)
library(rlog)
library(fs)
library(devtools)
library(crayon)

# source functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_flmd.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_Documentation/functions/create_dd.R")
source_url("https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_Documentation/functions/query_dd_database.R")
source_url("https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_Documentation/functions/query_flmd_database.R")

### Get Files ##################################################################

my_files <- get_files(directory = my_directory, 
                      exclude_files = user_exclude_files, 
                      include_files = user_include_files, 
                      include_dot_files = user_include_dot_files)

### Create FLMD ################################################################

my_flmd<- create_flmd(files_df = my_files,
                       dp_keyword = my_dp_keyword,
                       add_placeholders = user_add_placeholders,
                       query_header_info = user_query_header_info,
                       view_n_max = user_view_n_max)


### Create DD ##################################################################

my_dd <- create_dd(files_df = my_files, 
                    flmd_df = my_flmd, 
                    add_boye_headers = user_add_boye_headers, 
                    add_flmd_dd_headers = user_add_flmd_dd_headers, 
                    include_filenames = user_include_filenames)


### Populate dd/flmd from database #############################################

if(populate_dd_flmd == T){

# dd_populated <-  query_dd_database(dd_database_abs_path = user_dd_database_path, 
#                                    dd_skeleton = my_dd)
# 
# flmd_populated <- query_flmd_database(flmd_database_abs_path = user_flmd_database_path, 
#                                     flmd_skeleton = my_flmd)


### Data Package Specific Edits ################################################

prelim_dd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/SSS_Ecosystem_Respiration_Data_Package/SSS_Ecosystem_Respiration_Data_Package/SSS_ER_dd.csv") %>%
  select(Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type)


dd_populated <- my_dd %>%
  rows_patch(prelim_dd, by = c("Column_or_Row_Name"), unmatched = 'ignore') %>%
  mutate(Term_Type = case_when(is.na(Term_Type) ~ "column_header",
                               T ~ Term_Type))

prelim_flmd <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/00_ARCHIVE-WHEN-PUBLISHED/SSS_Ecosystem_Respiration_Data_Package/SSS_Ecosystem_Respiration_Data_Package/SSS_ER_flmd.csv") %>%
  select(File_Name, File_Description)


flmd_populated <- my_flmd %>%
  rows_patch(prelim_flmd, by = c("File_Name"), unmatched = 'ignore')

### Export #####################################################################

write_csv(flmd_populated, file = paste0(my_out_dir, "/", my_dp_keyword, "_flmd.csv"), na = "")

write_csv(dd_populated, file = paste0(my_out_dir, "/", my_dp_keyword, "_dd.csv"), na = "")

} else{

write_csv(my_flmd, file = paste0(my_out_dir, "/", my_dp_keyword, "_flmd.csv"), na = "")

write_csv(my_dd, file = paste0(my_out_dir, "/", my_dp_keyword, "_dd.csv"), na = "")

}

