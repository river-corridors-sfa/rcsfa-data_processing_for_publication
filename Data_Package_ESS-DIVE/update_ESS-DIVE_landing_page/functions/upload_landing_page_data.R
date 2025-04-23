### upload_landing_page_data.R #################################################
# Date Created: 2025-04-10
# Date Updated: 2025-04-23
# Author: Bibi Powers-McCormack


### FUNCTION ###################################################################

upload_landing_page_data <- function(api_token, # this is your personal API token that you can get after signing into ess-dive
                                     essdive_id, # this is the identifier number from the data package you want to update
                                     file_to_upload, # string of absolute file path to upload - can be a single file or a .zip
                                     upload_site = c("main", "sandbox")) { # indicate if you want to update a data package on the sandbox vs main site
  
  # Objective:
    # Upload a file or zipped folder to an existing ESS-DIVE dataset
  
  # Assumptions:
    # If the file name is new, it will add it. 
    # If the file name already exists, it will replace the file with the same name. 
    # Works with only one file or folder at a time.
    # Zipped folders must be zipped before being passed to the function.
    # This script requires the following dependencies:
    #   - packages: tidyverse, rlog, glue, httr, jsonlite
  
  # Inputs:
    # - api_token: ESS-DIVE API token (string)
    # - essdive_id: ESS-DIVE dataset ID (string)
    # - file_to_upload: Absolute file path (string)
    # - upload_site: Choose either "main" or "sandbox"
  
  # Outputs:
    # The function returns a written message that the data package has been updated
    # It will include the URL and name of the data package
  
  ### Prep script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(glue)
  library(httr) # for uploading to the API
  library(jsonlite) # for converting between JSON-ld
  
  
  
  ### Verify inputs ############################################################
  
  # confirm the user only provided a single file
  if (length(file_to_upload) != 1) {
    log_fatal("The file you provided could not be processed. 
              file_to_upload must be a single character string (e.g., file_to_upload = 'C:/Users/abc123/Desktop/data.zip').
              If you have multiple files, call the function separately for each one.")
    stop("Function terminating.")
  }
  
  
  # apply ess-dive site given input (options: "https://api-sandbox.ess-dive.lbl.gov" OR "https://api.ess-dive.lbl.gov")
  if (upload_site == "main") {
    
    user_input_upload_site <- "https://api.ess-dive.lbl.gov"
    
  } else if (upload_site == "sandbox") {
    
    user_input_upload_site <- "https://api-sandbox.ess-dive.lbl.gov"
    
  } else {
    log_fatal(glue("Upload site not found. You entered `{upload_site}`. Please indicate either `main` or `sandbox`."))
    stop("Function terminating.")
  }
  
  log_warn("IF THE NAME OF YOUR NEW FILE MATCHES AN EXISTING FILE, IT WILL REPLACE IT.")
  log_info(glue("Updating {upload_site} landing page (id = {essdive_id})."))
  

  ### Update landing page via API ##############################################
  
  # prepare to update
  header_authorization <- paste0("bearer ", api_token)
  upload_url <- as.character(glue("{user_input_upload_site}/packages/{essdive_id}"))
  
  
  # update via API
  update_via_api <- PUT(url = upload_url,
                        body = list(data = upload_file(file_to_upload[1])),
                        add_headers(Authorization = header_authorization, 
                                    encode = "multipart"))
  
  # check the status and review the results
  put_package_text <- content(update_via_api, "text", encoding = "UTF-8")
  put_package_json <- fromJSON(put_package_text)
  
  if(!http_error(update_via_api) ){
    
    log_info("API update successful.")
    
    # displays URL and data package name
    attributes(put_package_json)
    cat("View URL: ")
    cat(put_package_json$viewUrl)
    cat("\n")
    cat("Name: ")
    cat(put_package_json$dataset$name)
    cat("\n")
  }else {
    
    log_error("API update error.")
    
    # displays error message
    print(http_status(update_via_api))
    message(put_package_text)
  }
  
  log_info("upload_landing_page_data() complete")
  
}

