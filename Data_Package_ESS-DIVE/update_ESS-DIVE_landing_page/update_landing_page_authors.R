### update_landing_page_authors.R ##############################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-06
# Date Updated: 2025-03-06


update_landing_page_authors <- function(api_token, # this is your personal API token that you can get after signing into ess-dive
                                         essdive_id, # this is the identifier number from the data package you want to update
                                         author_df, # this is the df with the authors. Required cols: first_name, last_name, orcid, affiliation, email. Additional cols are okay (but will be dropped) and okay if there are NAs in orcid, affiliation, email cols
                                         upload_site = c("main", "sandbox")) {
  
  # Objective: 
    # Update a landing page with new authors
  
  # Assumptions: 
    # Any update will overwrite all existing authors.
    # The author_df requires these cols: "first_name", "last_name", "orcid", "affiliation", "email"
      # if additional cols exist in the df, this function will drop them
      # "first_name" and "last_name" cols are required to be filled out; all others can have NA values if needed
    # Requires the following dependencies
      # packages: tidyverse, rlog, glue, jsonlite, httr, devtools
      # functions: rename_column_headers()
  
  # Inputs: 
    # Personal API token from ESS-DIVE
    # ESS-DIVE identifier (can be located on landing page under "General" section (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721))
    # df with author information
    # Upload site (either "main" or "sandbox)
      # main: https://data.ess-dive.lbl.gov/data
      # sandbox: https://data-sandbox.ess-dive.lbl.gov/data
  
  # Outputs: 
    # The function returns a written message that the data package has been updated
    # It will include the URL and name of the data package
  
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(glue)
  library(devtools) # for sourcing in script
  library(jsonlite) # for converting to json-ld file
  library(httr) # for uploading to the API
  
  # load helper functions
  source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/refs/heads/main/Data_Transformation/functions/rename_column_headers.R")
  
  
  # clean up user inputs
  
  user_input_essdive_id <- essdive_id

  
  # apply ess-dive site given input (options: "https://api-sandbox.ess-dive.lbl.gov" OR "https://api.ess-dive.lbl.gov")
  if (upload_site == "main") {
    
    user_input_upload_site <- "https://api.ess-dive.lbl.gov"
    
  } else if (upload_site == "sandbox") {
    
    user_input_upload_site <- "https://api-sandbox.ess-dive.lbl.gov"
    
  } else {
    log_fatal(glue("Upload site not found. You entered `{upload_site}`. Please indicate either `main` or `sandbox`."))
    stop("Function terminating.")
  }
  
  log_info(glue("Updating {upload_site} landing page (id = {user_input_essdive_id})."))
  
  
  ### Convert author df to R list to JSON ######################################
  
  log_info("Preparing authors.")
  
  # check correct column headers exist
  required_cols <- c( "orcid", "first_name", "last_name", "affiliation", "email")
  author_df <- rename_column_headers(author_df, required_cols)
  missing_cols <- setdiff(required_cols, colnames(author_df))
  
  if (!all(required_cols %in% colnames(author_df))) {
    
    # if necessary headers don't exist, returns error message and stops function
    log_fatal(paste0("Missing columns: ", paste(missing_cols, collapse = ", ")))
    stop("Function terminating.")
    
  } else {
    
    # select the required cols
    author_df <- author_df %>% 
      select(first_name, last_name, orcid, affiliation, email)
    
    # if first_name or last_name is NA, then stop function
    if (any(is.na(author_df$first_name)) || any(is.na(author_df$last_name))) { # || means that if either condition is T the function stops
  
      log_fatal("A first or last name is missing. These fields are required.")
      stop("Function terminating.")
      
    } else {
      
      # otherwise, show author list
      print(author_df, n = nrow(author_df))
      
      cat("Okay to proceed?")
      
      user_prompt <- readline(prompt = "Y/N?: ")
      
      if (tolower(user_prompt) != "y") {
        
        # if user indicates anything except for "Y", then function stops
        stop("Function terminating.")
        
      }
      
    }
    
    
    
  }
  
  # initiate empty list
  creator_list <- list()
  
  # loop through each row of authors and convert it to an R list
  for (i in 1:nrow(author_df)) {
    
    current_row <- author_df[i, ]
    
    log_info(glue("Preparing author info for `{current_row$first_name} {current_row$last_name}`."))
    
    # create a list for the i-th author
    current_list <- list(
      givenName = current_row$first_name,
      familyName = current_row$last_name
    )
    
    # conditionally add fields only if they are not empty (NA or "")
    if (!is.na(current_row$affiliation) && current_row$affiliation != "") {
      current_list$affiliation <- current_row$affiliation
    }
    
    if (!is.na(current_row$email) && current_row$email != "") {
      current_list$email <- current_row$email
    }
    
    if (!is.na(current_row$orcid) && current_row$orcid != "") {
      current_list$`@id` <- paste0("https://orcid.org/", current_row$orcid)
    }
    
    # add list to growing creator list
    creator_list[[i]] <- current_list
  }
  
  # add all authors to parent list
  creator <- list(creator = creator_list)
  
  # convert to JSON
  json_str <- toJSON(creator, auto_unbox = T, pretty = T)
  
  
  ### Update landing page via API with PUT #####################################
  
  # prepare to update
  header_authorization <- paste0("bearer ", api_token)
  upload_url <- as.character(glue("{user_input_upload_site}/packages/{user_input_essdive_id}"))
  
  # update with API
  update_via_api <- PUT(url = upload_url,
                        body = json_str,
                        add_headers(Authorization = header_authorization,
                                    "Content-Type" = "application/json"))
  
  
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
  
  log_info("update_landing_page_authors() complete")
  
  
}
