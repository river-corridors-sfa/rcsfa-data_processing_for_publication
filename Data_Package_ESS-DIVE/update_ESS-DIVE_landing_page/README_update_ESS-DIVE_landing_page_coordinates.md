# How to update landing page coordinates
This describes the process for updating the coordinates on an ESS-DIVE landing page. Note that updating overwrites all existing coordinates. For example, if you wish to update 1 of 10 sites, you will need to provide all 10 correct sites . If you upload only the single corrected site, the landing page will remove the other 9 sites and only display the new single one you uploaded. 
## Prepare coordinates
Create a table with the following 3 (required) columns. Save it as a `.csv`.
| Description | Latitude | Longitude |
| ---- | ---- | ---- |
| `<chr>` A short description of the site that will appear on the landing page | `<num>` Latitude in decimal degress (WGS84) | `<num>` Longitude in decimal degress (WGS84) |
| E.g., PNNL Richland | 46.34515518 | -119.2794766 |
## About the function
The `update_landing_page_coordinates()` function has 4 (required) arguments:
1. `api_token`: This is your personal token. Sign into to ESS-DIVE > My Settings > Authentication Token > Copy Token
2. `essdive_id`: This is the identifier number from the data package you want to update. Get it from the ESS-DIVE landing page under the "General" section above the abstract (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721")
3. `coordinates_file_path`: This is the absolute file path of geospatial coordinates saved as a .csv with the columns: `Description`, `Latitude`, and `Longitude`
4. `upload_site`: Indicate if you want to update a data package on the sandbox vs main site; options include c(`main`, `sandbox`)

If the coordinates are successfully updated, the function will return the URL and name of the data package. 
## Run the function
The function has the following package and function dependencies. 
- library packages: `tidyverse`, `rlog`, `glue`, `jsonlite`, `devtools`, and `httr`
- functions: [rename_column_headers()](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Transformation/functions/rename_column_headers.R), [update_landing_page_coordinates()](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_coordinates.R)

You can either load these independently or use the below script to prepare the function. 
``` R
# load libraries
library(tidyverse)
library(rlog)
library(glue)
library(devtools) # for sourcing in script
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API
  
# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/functions/update_landing_page_coordinates.R")
```

Run the function. 
``` R
### Fill out arguments #########################################################
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "abcdefjhijklmnopqrstuvwxyz"

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-bb3760054337704-20240522T230449359525"

# this is the .csv absolute file path of the coordinates
your_coordinates_file_path <- "C:/Users/abc123/Desktop/update_coordinates.csv"

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "sandbox" 


### Run function ###############################################################

update_landing_page_coordinates(api_token = your_api_token,
                                essdive_id = your_essdive_id,
                                coordinates_file_path = your_coordinates_file_path,
                                upload_site = your_upload_site)
``` 
