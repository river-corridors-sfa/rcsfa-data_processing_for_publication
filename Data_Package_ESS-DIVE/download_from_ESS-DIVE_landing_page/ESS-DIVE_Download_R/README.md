# Function: `download_and_read_data()`
## Objective
The `download_and_read_data()` function downloads data from [ESS-DIVE](https://data.ess-dive.lbl.gov/data) to a local directory on your computer and then reads the downloaded csv files into R's global environment as a list.
## Directions
1. Locate the data package on [ESS-DIVE](https://data.ess-dive.lbl.gov/data).
2. Identify the file you want to download. This could be the entire data package ("Download All"), a specific file, or a zipped folder. 
3. Source in the [function](https://github.com/river-corridors-sfa/rcsfa-essdive-api/blob/main/ESS-DIVE_Download_R/script_ess_dive_file_download_function.R) by pasting the following code at the top of your R script.

``` R
# Load devtools package
library(devtools)

# Specify the GitHub URL of the script
github_url <- "https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/download_from_ESS-DIVE_landing_page/ESS-DIVE_Download_R/script_ess_dive_file_download_function.R"

# Source the script from GitHub
source_url(github_url)
```

4. Use the function to download and read in the data. The `download_and_read_data()` function takes five arguments (3 required, 2 optional):
	- `target_url` = The URL of a specific file you want to download from ESS-DIVE
 		- To get the url, you will need to go to the data package on ESS-DIVE, hover over the green download button of the file, zip, or download all button, right click, and select "copy link address". 
	- `filename` = The filename of the file you want to download from ESS-DIVE. The filename indicates the name of the file as it  will be saved on  your computer, it does not have to match the file name on ESS-DIVE, but we recommend it does for traceability.
	- `downloads_folder` = Target folder to store the downloaded file
	- `rm_zip` = Whether to remove the downloaded zip file after unzipped the file, default is FALSE
	- `rm_unzip_folder`: Whether to remove the unzip_folder after reading data into R, default is FALSE  
``` R
# Example from Spatial Study 2022: https://data.ess-dive.lbl.gov/view/doi:10.15485/1969566
csv_files_from_data_package <- download_and_read_data(
	target_url = "https://data.ess-dive.lbl.gov/catalog/d1/mn/v2/object/ess-dive-e99c54f68893641-20230824T171850688",
	filename = "v2_SSS_Data_Package.zip",
	downloads_folder = "C:/Users/jdoe123/Downloads")`
```

5. See [script_ess_dive_file_download_example.R](https://github.com/river-corridors-sfa/rcsfa-essdive-api/blob/main/ESS-DIVE_Download_R/script_ess_dive_file_download_example.R) for more examples on how to use the function.
