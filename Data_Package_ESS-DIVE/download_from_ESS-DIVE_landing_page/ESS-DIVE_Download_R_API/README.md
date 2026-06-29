# How to download csv files from an ESS-DIVE landing page using the API
This describes the process for downloading all csv files from a public ESS-DIVE landing page using the ESS-DIVE API. The function only requires the ESS-DIVE data package landing page link. It identifies csv files from the package metadata, downloads csv files and relevant zipped folders, and reads the csv files into R as a named list.

## About the function
The `download_essdive_csvs()` function has 1 (required) argument:
1. `package_link`: This is the ESS-DIVE landing page link for a public data package. The link can be copied directly from the browser.

Accepted link formats include:
- `https://data.ess-dive.lbl.gov/view/doi%3A10.15485%2F3374642`
- `https://data.ess-dive.lbl.gov/view/doi:10.15485/3374642`
- `https://data.ess-dive.lbl.gov/datasets/doi:10.15485/3374642`

If the data package is successfully downloaded, the function will print the data package citation in the console and return a named list of data frames. Add the printed citation to any resulting publications that use these data. The list contains the csv files in the data package. If file-level metadata are available, the function uses the `Header_Rows` and `Column_or_Row_Name_Position` columns to skip metadata header rows before reading tabular data.

## Run the function
The function has the following package dependencies:
- library packages: `tidyverse`, `dplyr`, `httr2`, `purrr`, `readr`, `stringr`, and `tibble`

``` R
# source the function
source_url('https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/raw/refs/heads/main/Data_Package_ESS-DIVE/download_from_ESS-DIVE_landing_page/ESS-DIVE_Download_R_API/ESS-DIVE_download_API_function.R')

# this is the ESS-DIVE landing page link for a public data package
your_package_link <- "https://data.ess-dive.lbl.gov/view/doi%3A10.15485%2F3374642"


data_package_csvs <- download_essdive_csvs(package_link = your_package_link)
```

The returned object is a named list. Use the dollar sign to access individual csv files.

``` R
names(data_package_csvs)

field_metadata <- data_package_csvs$WHONDRS_TAP_Field_Metadata
npoc_tn <- data_package_csvs$WHONDRS_TAP_Water_NPOC_TN
```

## Notes
- This function is intended for public ESS-DIVE data packages.
- The function downloads files to a temporary folder created by R.
- The function reads top-level csv files and csv files inside relevant zip files.
- The function prints the ESS-DIVE data package citation in the console.
- If metadata header rows are skipped, the function returns a warning listing the affected file names.
