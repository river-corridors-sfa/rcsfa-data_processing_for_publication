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
user_directory <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Bao_2025_GameCamera_Manuscript_Data_Package/Data_Package"

# provide the name of the person running the checks
report_author <- "Brieanne Forbes"

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Bao_2025_GameCamera_Manuscript_Data_Package/"

# do the tabular files have header rows? (T/F) - header rows that start with "#" can be considered as not having header rows
user_input_has_header_rows <- F

# do you already have an FLMD that has Header_Rows and Column_or_Row_Name_Position filled out? (T/F)
has_flmd <- F

# if T, then provide the absolute file path of the existing flmd file
flmd_path <- ""

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

user_exclude_files = c("label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231222_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231222_154212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231223_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231223_154212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231224_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231224_154212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231228_094212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231228_094212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231229_094212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231229_094212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231230_114212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231230_114212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240102_114212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240102_114212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240103_074212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240103_074212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240103_114212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240103_114212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240104_094212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20240104_094212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230713_060308PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230713_060308PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230714_060308PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230714_060308PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230717_060308PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230717_060308PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230717_201346PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230717_201346PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230718_041346PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230718_041346PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230719_041346PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230719_041346PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230725_041346PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230725_041346PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230725_041346PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230725_041346PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230726_041346PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230726_041346PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230807_192912PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230807_192912PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230811_192912PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20230811_192912PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120358PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120358PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120358PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120358PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120748PST_RefPhoto-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120748PST_RefPhoto-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120748PST_RefPhoto-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231018_120748PST_RefPhoto-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231021_170820PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231021_170820PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231021_170820PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231021_170820PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231027_170820PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231027_170820PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231102_175822PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231102_175822PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231104_172820PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231104_172820PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231104_172820PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231104_172820PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231106_072822PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231106_072822PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231106_075822PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231106_075822PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231109_065822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231109_065822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231109_065822PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231109_065822PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231110_065820PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231110_065820PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231112_162820PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231112_162820PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231113_065820PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231113_065820PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231121_070000PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231121_070000PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231122_163000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231122_163000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231128_163000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231128_163000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231201_073002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231201_073002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231201_163000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231201_163000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231205_160000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231205_160000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231206_080002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231206_080002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231208_090844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231208_090844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231208_130844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231208_130844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231209_090844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231209_090844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231216_090844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231216_090844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231223_090844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231223_090844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231223_130844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231223_130844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231231_090844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20231231_090844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20240103_130844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20240103_130844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20240104_090844PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S30R_20240104_090844PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230819_191258PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230819_191258PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230820_191300PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230820_191300PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230822_191258PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230822_191258PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230824_191300PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230824_191300PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230825_191258PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20230825_191258PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231018_131222PST_RefPhoto-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231018_131222PST_RefPhoto-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231018_131222PST_RefPhoto-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231018_131222PST_RefPhoto-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231019_061352PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231019_061352PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231020_061352PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231020_061352PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231020_061352PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231020_061352PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231021_171352PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231021_171352PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231023_061352PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231023_061352PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231025_071352PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231025_071352PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231025_071352PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231025_071352PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231025_071352PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231025_071352PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231028_171352PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231028_171352PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231101_175056PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231101_175056PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231103_175056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231103_175056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_102056PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_102056PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_105056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_105056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_112056PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_112056PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_175056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231104_175056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231106_085056PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231106_085056PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231107_165056PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231107_165056PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231108_165056PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231108_165056PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231109_065056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231109_065056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231110_075056PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231110_075056PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231111_165056PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231111_165056PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231113_065056PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231113_065056PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231114_065056PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231114_065056PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231114_065056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231114_065056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231115_065056PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231115_065056PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231115_065056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231115_065056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231115_164456PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231115_164456PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231122_074456PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231122_074456PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231123_164458PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231123_164458PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231126_071458PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231126_071458PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231204_094458PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231204_094458PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231206_144458PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231206_144458PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231208_071344PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231208_071344PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231213_074344PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231213_074344PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231219_081346PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231219_081346PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231222_164046PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231222_164046PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231226_074046PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231226_074046PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231228_074046PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231228_074046PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231229_164046PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231229_164046PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231231_074046PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20231231_074046PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240103_074046PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240103_074046PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240103_084046PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240103_084046PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240103_164046PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240103_164046PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240104_084046PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S31_20240104_084046PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230517_105050PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230517_105050PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230517_150002PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230517_150002PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230520_150000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230520_150000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230530_150002PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230530_150002PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230531_070002PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230531_070002PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230531_092414PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230531_092414PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230601_150000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230601_150000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230602_150000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230602_150000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230604_110002PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230604_110002PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230605_070000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230605_070000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230609_150000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230609_150000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230613_190000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230613_190000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230616_070000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230616_070000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230618_070002PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230618_070002PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230619_110000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230619_110000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230627_090110PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230627_090110PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230628_070002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230628_070002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230704_070002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230704_070002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230704_110002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230704_110002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230704_110002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230704_110002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230705_070002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230705_070002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230706_070002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230706_070002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230710_110000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230710_110000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230710_190002PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230710_190002PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230711_110000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230711_110000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230716_070002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230716_070002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230716_110002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230716_110002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230721_070000PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230721_070000PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230721_190002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230721_190002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230722_110000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230722_110000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230724_070000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230724_070000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230726_110000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230726_110000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230726_150000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230726_150000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230726_150000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230726_150000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230727_150000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230727_150000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230728_110000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230728_110000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230728_150000PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230728_150000PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230729_190002PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230729_190002PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230730_190002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230730_190002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230803_190000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230803_190000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230907_170002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230907_170002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230908_150002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230908_150002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230919_090000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230919_090000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230920_150002PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230920_150002PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230922_110000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230922_110000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230922_150002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230922_150002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230926_090000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230926_090000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230926_110000PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230926_110000PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230930_170002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20230930_170002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231004_150002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231004_150002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231004_170002PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231004_170002PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231005_170002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231005_170002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231006_170000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231006_170000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231006_170000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231006_170000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231009_170002PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231009_170002PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231010_090002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231010_090002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231015_090002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231015_090002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231015_110000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231015_110000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231016_090000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231016_090000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231018_090002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231018_090002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231018_110000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231018_110000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231018_160000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231018_160000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231019_160002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231019_160002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231023_100000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231023_100000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231023_160002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231023_160002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231027_080002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231027_080002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231027_160002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231027_160002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231027_180000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231027_180000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231029_160002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231029_160002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231029_160002PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231029_160002PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231102_160000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231102_160000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231102_180002PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231102_180002PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231106_170000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231106_170000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231107_150002PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231107_150002PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231108_150000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231108_150000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231110_110002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231110_110002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231112_150000PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231112_150000PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231207_110002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231207_110002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231208_090002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231208_090002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231208_150000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231208_150000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231208_150000PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231208_150000PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231223_090002PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231223_090002PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231223_150000PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231223_150000PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231229_150000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20231229_150000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20240104_110000PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S32_20240104_110000PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230704_142610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230704_142610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230708_082610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230708_082610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230710_082610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230710_082610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230731_202610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230731_202610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230802_142610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230802_142610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230811_162610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230811_162610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230820_062610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230820_062610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230820_182610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230820_182610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230822_182610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230822_182610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230823_162610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230823_162610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230825_102610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230825_102610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230828_182610PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230828_182610PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230831_095106PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230831_095106PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230906_095106PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230906_095106PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230907_135106PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230907_135106PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230908_115106PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230908_115106PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230914_074530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230914_074530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230914_174528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230914_174528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230917_114528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230917_114528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230917_134530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230917_134530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230918_094528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230918_094528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230922_174528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230922_174528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230924_074530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230924_074530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230924_134528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230924_134528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230924_174530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230924_174530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230929_114528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20230929_114528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231005_074528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231005_074528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231007_094530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231007_094530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231009_094530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231009_094530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231009_174528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231009_174528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231012_094530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231012_094530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231012_114528PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231012_114528PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231013_094530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231013_094530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231017_094530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231017_094530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231018_094530PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231018_094530PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231019_093822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231019_093822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231020_093824PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231020_093824PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231020_113822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231020_113822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231021_093822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231021_093822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231023_133822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231023_133822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231024_093824PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231024_093824PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231031_093822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231031_093822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231101_093824PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231101_093824PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231102_113822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231102_113822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231105_083822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231105_083822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231108_083822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231108_083822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231109_063822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231109_063822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231109_103822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231109_103822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231110_083822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231110_083822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231111_103822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231111_103822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231112_103822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231112_103822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231113_123822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231113_123822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231115_083822PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231115_083822PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231117_103718PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231117_103718PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231118_083718PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231118_083718PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231119_103718PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231119_103718PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231206_115250PST_RefPhoto-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231206_115250PST_RefPhoto-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231206_115250PST_RefPhoto-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231206_115250PST_RefPhoto-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231207_080936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231207_080936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231209_080936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231209_080936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231211_080938PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231211_080938PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231213_080936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231213_080936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231215_080938PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231215_080938PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231217_080936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231217_080936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231219_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231219_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231221_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231221_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231223_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231223_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231225_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231225_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231227_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231227_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231229_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231229_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231231_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20231231_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20240102_100936PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S38_20240102_100936PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230519_150000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230519_150000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230521_190000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230521_190000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230522_190002PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230522_190002PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230527_190000PST.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230527_190000PST.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230717_110216PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230717_110216PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230717_110216PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230717_110216PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230717_110216PST-8.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230717_110216PST-8.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230729_150606PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230729_150606PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230802_150606PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230802_150606PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230810_070010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230810_070010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230810_150010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230810_150010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230811_150010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230811_150010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230813_070010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230813_070010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230815_070010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230815_070010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230816_050010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230816_050010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230818_070010PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230818_070010PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230820_142722PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230820_142722PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230823_142724PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230823_142724PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230824_182722PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230824_182722PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_100656PST_RefPhoto-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_100656PST_RefPhoto-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_161056PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_161056PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_161056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_161056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_181056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230912_181056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230913_061054PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230913_061054PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230913_141054PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230913_141054PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230916_181056PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230916_181056PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230917_141054PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230917_141054PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230919_081056PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230919_081056PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230919_141056PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230919_141056PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230923_121056PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230923_121056PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230924_061054PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230924_061054PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230927_161056PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230927_161056PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230927_181054PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230927_181054PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230928_061054PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230928_061054PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230929_061054PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20230929_061054PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231004_062744PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231004_062744PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231004_142744PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231004_142744PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231004_142744PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231004_142744PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231007_142744PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231007_142744PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231007_162744PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231007_162744PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231008_062744PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231008_062744PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231008_062744PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231008_062744PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231014_142744PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231014_142744PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231015_142744PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231015_142744PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231018_062744PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231018_062744PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231018_062744PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231018_062744PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231018_151650PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231018_151650PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231022_151650PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231022_151650PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231022_171650PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231022_171650PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231023_151648PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231023_151648PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231027_151650PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231027_151650PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231027_171648PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231027_171648PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231029_171648PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231029_171648PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231030_151650PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231030_151650PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231031_142752PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231031_142752PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231104_162752PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231104_162752PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231108_132752PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231108_132752PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231109_132752PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231109_132752PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231111_112750PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231111_112750PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231111_152750PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231111_152750PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231112_152752PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231112_152752PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231113_132752PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231113_132752PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231113_132752PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231113_132752PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231114_152750PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231114_152750PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231115_072752PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231115_072752PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231119_074924PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231119_074924PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231119_154924PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231119_154924PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231123_154926PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231123_154926PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231125_074924PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231125_074924PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231126_094926PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231126_094926PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231126_154924PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231126_154924PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231130_074926PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231130_074926PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231201_154924PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231201_154924PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231203_094924PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231203_094924PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231203_154926PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231203_154926PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231206_134926PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231206_134926PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231207_130802PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231207_130802PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231208_150802PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231208_150802PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231210_090802PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231210_090802PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231212_130800PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231212_130800PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231213_090802PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231213_090802PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231222_111428PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231222_111428PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231222_131428PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231222_131428PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231225_151428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231225_151428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231226_131428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231226_131428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231228_151428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231228_151428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231229_091428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231229_091428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231229_111428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231229_111428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231229_131428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231229_131428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231230_151428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231230_151428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231231_111428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231231_111428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231231_151428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20231231_151428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240101_091428PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240101_091428PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240102_091428PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240102_091428PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240102_111428PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240102_111428PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240102_131428PST-5.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63_20240102_131428PST-5.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230627_130108PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230627_130108PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230627_130108PST-2.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230627_130108PST-2.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230628_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230628_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230701_080940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230701_080940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230715_080940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230715_080940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230721_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230721_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230723_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230723_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230729_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230729_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230807_080940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230807_080940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230809_160940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230809_160940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230809_180940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230809_180940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230811_140940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230811_140940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230813_160940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230813_160940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230813_180940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230813_180940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230815_160940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230815_160940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230816_120940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230816_120940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230817_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230817_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230819_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230819_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230821_200940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230821_200940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230824_100940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230824_100940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230827_100940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230827_100940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230827_180940PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230827_180940PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230902_063838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230902_063838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230905_063838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230905_063838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230905_183838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230905_183838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230906_123838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230906_123838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230910_183838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230910_183838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230911_083838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230911_083838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230911_123838PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230911_123838PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230926_103824PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20230926_103824PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231018_122318PST-3.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231018_122318PST-3.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231018_122318PST-4.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231018_122318PST-4.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231019_102316PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231019_102316PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231021_102316PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231021_102316PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231022_102316PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231022_102316PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231023_102318PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231023_102318PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231101_142316PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231101_142316PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231102_142316PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231102_142316PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231114_072318PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231114_072318PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231115_092316PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231115_092316PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231206_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231206_154212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231208_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231208_154212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231210_074212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231210_074212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231210_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231210_154212PST-1.png",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231221_154212PST-1.json",
                       "label_data/YRB_wildlife_cam_data_labeled/RMP_S63P_20231221_154212PST-1.png")

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

