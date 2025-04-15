# How to upload data to an ESS-DIVE landing page
This describes the process for adding a file or zipped folder to an existing ESS-DIVE landing page. Note that if your new file name matches an existing file, this will replace the old file sharing the same name. 
## About the function
The `upload_landing_page_data()` function has 4 (required) arguments: 
1. `api_token`: This is your personal token. Sign into to ESS-DIVE > My Settings > Authentication Token > Copy Token
2. `essdive_id`: This is the identifier number from the data package you want to update. Get it from the ESS-DIVE landing page under the "General" section above the abstract (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721")
3. `file_to_upload`: This is the absolute file path of the file or zipped folder you want uploaded. 
4. `upload_site`: Indicate if you want to update a data package on the sandbox vs main site; options include c(`main`, `sandbox`)

If the data are successfully uploaded, the function will return an URL and name of the data package. 
## Run the function
The function has the following package dependencies: 
- library packages: `tidyverse`, `rlog`, `glue`, `jsonlite`, and `httr`

You can either load these independently or use the below script to prepare the function. 
``` R
# load libraries
library(tidyverse)
library(rlog)
library(glue)
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API
library(devtools) # for sourcing in script
  
# load function
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/functions/upload_landing_page_data.R")
```

Run the function. 
``` R
### Fill out arguments #########################################################
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "abcdefjhijklmnopqrstuvwxyz"

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-bb3760054337704-20240522T230449359525"

# this is the absolute file path of your file or zipped folder
your_data_file <- "C:/Users/abc123/Desktop/data.zip"

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "sandbox" 


### Run function ###############################################################

upload_landing_page_data(api_token = your_api_token,
                                essdive_id = your_essdive_id,
                                file_to_upload = your_data_file,
                                upload_site = your_upload_site)
``` 
