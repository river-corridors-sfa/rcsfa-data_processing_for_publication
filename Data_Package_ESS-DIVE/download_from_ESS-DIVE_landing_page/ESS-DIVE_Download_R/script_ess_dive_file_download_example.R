# download data from ESS-DIVE
# Xinming Lin Nov 1st 2023
# edited by Brieanne Forbes 
###############################################################################
# Downloading data from ESS-DIVE
###############################################################################
rm(list=ls(all=TRUE))
# Loading/installing required libraries
librarian::shelf(tidyverse,
                 curl,
                 data.table,
                 utils,
                 purrr)
################################################################################
# Inputs to the function:

# target_url: the URL of a specific file you want to download from ESS-DIVE
# filename: the filename of the file you want to download from ESS-DIVE
# downloads_folder: target folder to store the downloaded file 
# rm_zip: whether to remove the downloaded zip file after unzipped the file, default is FALSE
# rm_unzip_folder: whether to remove the unzip_folder after reading data into R, default is FALSE

################################################################################

# Set the path to the downloads folder
# could put a file path to different folder if wanted
downloads_folder <- if (Sys.getenv("OS")=="Windows_NT"){
  file.path("C:/Users", Sys.getenv("USERNAME"), "Downloads")
} else{file.path(Sys.getenv("HOME"), "Downloads")}

current_path <- rstudioapi::getActiveDocumentContext()$path 

# get path to function, assuming its in the same folder as this script
# can change to just a file path if not
function_path <- str_replace(current_path, '_example', '_function')

source(function_path)


################################################################################


# To get the url of the file we want to download, you will need to go to the 
# data package, right click the download button of the file, zip, or download 
# all button and select "copy link address". 

# The filename indicates the name of the file as it  will be saved on  your 
# computer, it does not have to match the file name on ESS-DIVE, but we 
# recommend it does for traceability. 

# After you have downloaded and read in the files, you can use the dollar sign
# to look within the folder and subfolders. See example 2 for an example of this. 

# example 1
# Spatial Study 2022
# https://data.ess-dive.lbl.gov/view/doi:10.15485/1969566
filename<-'v2_SSS_flmd.csv'
target_url <-'https://data.ess-dive.lbl.gov/catalog/d1/mn/v2/object/ess-dive-ca0673c4b0339ec-20230824T171850694'
data_in_file1 <-download_and_read_data(target_url,filename,downloads_folder)

# example 2 
# Spatial Study 2022
# https://data.ess-dive.lbl.gov/view/doi:10.15485/1969566
filename<-'v2_SSS_Data_Package.zip'
target_url <-'https://data.ess-dive.lbl.gov/catalog/d1/mn/v2/object/ess-dive-e99c54f68893641-20230824T171850688'
data_in_file2 <-download_and_read_data(target_url,filename,downloads_folder)
metadata <- data_in_file2$v2_SSS_Field_Metadata.csv
hobo_summary <- data_in_file2$DepthHOBO$v2_SSS_Water_Press_Temp_Summary.csv

# example 3 
# Spatial microbial respiration variations in the hyporheic zones within the Columbia River Basin
# https://data.ess-dive.lbl.gov/view/doi:10.15485/1962818
filename<-'model_inputs.zip'
target_url <-'https://data.ess-dive.lbl.gov/catalog/d1/mn/v2/object/ess-dive-ef92031cc1bc9c5-20230310T201704004'
data_in_file3 <-download_and_read_data(target_url,filename,downloads_folder)

# example 4 (the whole package) 
# The East River, Colorado, Watershed
# https://data.ess-dive.lbl.gov/view/doi:10.15485/1969566
filename<-'Dataset.zip'
target_url <-'https://data.ess-dive.lbl.gov/catalog/d1/mn/v2/packages/application%2Fbagit-1.0/ess-dive-909866f61f9cfca-20230914T182609104'
data_in_file4 <-download_and_read_data(target_url,filename,downloads_folder)

