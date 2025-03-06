# How to update landing page authors
This describes the process for updating the creator/author list on an ESS-DIVE landing page. Note that updating overwrites all existing authors. For example, if you wish to add an author, you will need to provide all existing authors plus the new one. If you upload only that single new author, the landing page will remove all other authors and only display the new one you uploaded. 

## Prepare authors
Create a data frame with 5 (required) columns. 

| first_name                                                                          | last_name                                               | orcid                                                                   | affiliation                                                                   | email                                                    |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------- |
| `<chr>` The author's first name. Add middle names here too. This field is required. | `<chr>` The author's last name. This field is required. | `<num>` The author's ORICD number. If not applicable, leave empty (NA). | The author's institution or affiliation. If not applicable, leave empty (NA). | The author's email. If not applicable, leave empty (NA). |
| E.g., Joe                                                                           | Smith                                                   | 0000-0000-0000-1234                                                     | Pacific Northwest National Laboratory                                         | joe.smith@pnnl.gov                                       |

``` R
# example
my_author_df <- tibble(
  first_name = c("Alice Marie", "Bob", "Charlie"),
  last_name = c("Johnson", "Lee", "Smith"),
  orcid = c("0000-0000-0000-1111", NA, "0000-0000-0000-2222"),
  affiliation = c("University of Washington", "Pacific Northwest National Laboratory", NA),
  email = c("alice.johnson@uw.edu", "bob.lee@pnnl.gov", NA)
)
```

## About the function
The `update_landing_page_authors()` function has 4 (required) arguments: 
1. `api_token`: This is your personal token. Sign into to ESS-DIVE > My Settings > Authentication Token > Copy Token
2. `essdive_id`: This is the identifier number from the data package you want to update. Get it from the ESS-DIVE landing page under the "General" section above the abstract (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721")
3. `author_df`: This is the data frame you created above with the columns: `first_name`, `last_name`, `orcid`, `affiliation`, and `email`. Additional columns in this data frame will be dropped. 
4. `upload_site`: Indicate if you want to update a data package on the sandbox vs main site; options include c(`main`, `sandbox`)

If the authors are successfully updated, the function will return the URL and name of the data package. 
## Run the function
The function has the following package and function dependencies. 
- library packages: `tidyverse`, `rlog`, `glue`, `jsonlite`, `devtools`, and `httr`
- functions: [rename_column_headers()](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Transformation/functions/rename_column_headers.R), [update_landing_page_authors()](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_authors.R)

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
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Package_ESS-DIVE/update_ESS-DIVE_landing_page/update_landing_page_authors.R")
```

Run the function. 
``` R
### Fill out arguments #########################################################
# this is your personal token that you can get after signing into ess-dive
your_api_token <- "abcdefjhijklmnopqrstuvwxyz"

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
your_essdive_id <- "ess-dive-bb3760054337704-20240522T230449359525"

# this is the author data frame you already made
your_author_df <- my_author_df

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
your_upload_site <- "sandbox" 


### Run function ###############################################################

update_landing_page_authors(api_token = your_api_token,
                            essdive_id = your_essdive_id,
                            author_df = your_author_df,
                            upload_site = your_upload_site)
``` 
