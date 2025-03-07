### update_landing_page_authors.R ##############################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-06
# Date Updated: 2025-03-06

# This script contains 3 functions used to get author information for ESS-DIVE data packages. 
# get_authors_from_essdive_metaata() gets the list of names, 
# get_author_spreadsheet_info() uses those names to pull author metadata, 
# update_landing_page_authors() then updates a landing page with author info. 


get_authors_from_essdive_metadata <- function(essdive_metadata_file) {
  
  # Objective: 
    # Retrieve the list of authors from an ESS-DIVE Metadata .docx file
  
  # Assumptions: 
    # All authors are listed on a new line
    # Authors are listed below the text "Creators:" and above the text "Start date:"
    # Only authors are listed in between those patterns (all instruction text is removed)
  
  # Inputs: 
    # the absolute file path of the ess-dive metadata .docx file
  
  # Outputs: 
    # a df with 4 cols (name, first_name, middle_name, last_name) with each row representing a single author's name
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(officer) # for reading in docx file
  
  # read in file
  docx <- read_docx(essdive_metadata_file)
  docx_text <- docx_summary(docx)$text
  
  # define start and end patterns
  start_pattern <- "Creators:"
  end_pattern <- "Start date:"
  
  ### Extract authors ##########################################################
  
  # find indices where the patterns occur
  start_index <- grep(start_pattern, docx_text)
  end_index <- grep(end_pattern, docx_text)
  
  # extract text between indices
  if (length(start_index) > 0 && length(end_index) > 0 && start_index < end_index) {
    extracted_text <- docx_text[(start_index + 1):(end_index - 1)]
    
    # add to df
    author_names <- tibble(name = extracted_text) %>% 
      filter(!is.na(name) & name != "") %>% # remove blanks
      mutate(name = str_trim(name)) # strip white-space from beginning and ends
    
    print(author_names, n = nrow(author_names))
    
    # split names into first, middle, and last
    authors <- author_names %>% 
      mutate(name_split = str_split(name, " ")) %>% 
      mutate(
        first_name = map_chr(name_split, ~ ifelse(length(.x) > 1, .x[1], NA)),  # First name if available
        middle_name = map_chr(name_split, ~ ifelse(length(.x) == 3, .x[2], NA)), # Middle name if three parts
        last_name = map_chr(name_split, ~ ifelse(length(.x) > 1, last(.x), .x[1])) # Last name (or only name)
      ) %>%
      select(-name_split)  # Remove intermediate list column
    
    
  } else {
    warning("Start or end pattern not found, or they are in the wrong order.")
  }
  
  log_info("get_authors_from_essdive_metadata() complete")
  return(authors)
  
}

get_author_spreadsheet_info <- function(author_df, # df with 3 cols: first_name, middle_name, last_name
                                        author_info_file = "Z:/00_ESSDIVE/00_Instructions/RC_SFA_author_information.xlsx") { # absolute file path
  
  # Objective: 
    # Join the author spreadsheet info to the current author list
  
  # Assumptions: 
    # Input name options include: 
      # first, middle, and last
      # first, last
      # last
  
  # Inputs: 
    # df with 3 required cols (first_name, middle_name, last_name)
    # absolute file path of the author spreadsheet
  
  # Outputs: 
    # df with 5 cols: first_name, last_name, orcid, affiliation, email
  
  
  ### Prep Script ##############################################################
  
  # load libraries
  library(tidyverse)
  library(readxl)
  library(janitor) # for cleaning up col headers
  
  # load author spreadsheet
  author_spreadsheet <- read_excel(author_info_file, trim_ws = T) %>% 
    clean_names()
  
  
  ### Author lookup ############################################################
  
  # initialize empty df
  author_list <- list()
  
  # iterate through each author
  for (i in seq_len(nrow(author_df))) {
    
    current_row <- author_df[i, ]
    current_first <- current_row$first_name
    current_middle <- current_row$middle_name
    current_last <- current_row$last_name
    current_join <- NULL
   
    if (!is.na(current_first) & !is.na(current_middle) & !is.na(current_last)) {
      
     # attempt to match by first, middle, last name
      current_join <- author_spreadsheet %>% 
        filter(first_name == current_first, middle_name == current_middle, last_name == current_last)
      
    } else if (!is.na(current_first) & is.na(current_middle) & !is.na(current_last)) {
      
      # attempt to match by first, last
      current_join <- author_spreadsheet %>%
        filter(first_name == current_first, last_name == current_last)
      
    } else if (is.na(current_first) & is.na(current_middle) & !is.na(current_last)) {
      
      # attempt to match by last  
      current_join <- author_spreadsheet %>%
        filter(last_name == current_last)
      
    } else {
        
      log_warn(paste0("No match for `", current_row$name, "` in the author spreadsheet."))
      
    }
    
    if (nrow(current_join) == 1) {
      
      # join if a single match was found
      current_row <- current_row %>% 
        suppressWarnings(left_join(current_join))
      
      
    } else if (nrow(current_join) > 1) { 
      
      # check if multiple matches were found
      log_warn(paste0("Multiple matches found for `", current_row$name, "`: "))
      print(current_join)
      
    } else {
      # If no match, add warning
      log_warn(paste0("No matches found for `", current_row$name, "`."))
    }
    
    # clean up join
    current_join <- current_join %>% 
      select(first_name, middle_name, last_name, orcid, institution, e_mail) %>% 
      rename(email = e_mail)
    
    # add matches to list
    author_list[[current_row$name]] <- current_join
    
  }
  
  ### Author clean up ##########################################################
    
    # initialize final df
    author_info <- tibble(
      name = as.character(),
      first_name = as.character(),
      middle_name = as.character(),
      last_name = as.character(),
      orcid = as.character(),
      affiliation = as.character(),
      email = as.character()
    )
    
    # iterate through each name again
    for (i in seq_len(nrow(author_df))) {
      
      # get current name
      current_name <- author_df[i, ] %>% 
        pull(name)
      
      # look up name in list
      current_entry <- author_list[[current_name]]
      
      # if only 1 entry, save it to final df
      if (nrow(current_entry) == 1) {
        
        author_info <- bind_rows(author_info, current_entry)
        
      } else if (nrow(current_entry > 1)) { 
        
        # if multiple entries, only add name to list
        author_info <- author_info %>% 
          add_row(name = current_name)
        
      } else { 
  
        # if no entries, only add name to list
        author_info <- author_info %>% 
          add_row(name = current_name)
          
        }

    }
    
    # clean up author info
    author_info <- author_info %>% 
      mutate(first_name = case_when(!is.na(middle_name) ~ paste0(first_name, " ", middle_name), 
                                    T ~ first_name)) %>% 
      select(-middle_name) %>% 
      rename(is_missing = name)
    
    # if there are missing names, give a warning
    if (author_info %>% filter(!is.na(is_missing)) %>% nrow() > 0) {
      log_warn("There are possible errors in your author list.")
    }
    
    
    log_info("get_author_spreadsheet_info() complete")
    print(author_info, n = nrow(author_info))
    
    return(author_info)
    
}


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
