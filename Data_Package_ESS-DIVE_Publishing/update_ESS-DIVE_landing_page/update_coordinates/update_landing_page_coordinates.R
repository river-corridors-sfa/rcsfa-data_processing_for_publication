### update_landing_page_coordinates.R ##########################################
# Date Created: 2024-05-22
# Date Updated: 2024-05-22
# Author: Bibi Powers-McCormack

# Objective: 
  # Update a landing page with new coordinates

# Assumptions: 
  # The working directory is set to the `rcsfa-data_processing_for_publication` repo
  # Any update will overwrite all existing coordinates.
  # The coordinates .csv requires the columns: "Description", "Latitude", and "Longitude"
  
# Inputs: 
  # ESS-DIVE identifer (can be located on landing page under "General" section (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721))
  # Absoulte file path of geospatial coordinates saved as a .csv with the columns: "Description", "Latitude", and "Longitude"

# Outputs: 
  # The function returns a written message that the data package has been updated
  # It will include the URL and name of the data package


### FUNCTION ###################################################################

update_landing_page_coordinates <- function(api_token, # this is your personal API token that you can get after signing into ess-dive
                                            essdive_id, # this is the identifier number from the data package you want to update
                                            coordinates_file_path, # this is the .csv file path of the coordinates
                                            upload_site = c("main", "sandbox")) { # indicate if you want to update a data package on the sandbox vs main site
  
  ### Prep script ##############################################################
  
  # load helper functions
  source("./Data_Transformation/functions/rename_column_headers.R")
  
  # load libraries
  library(tidyverse)
  library(rlog)
  library(glue)
  library(jsonlite) # for converting to json-ld file
  library(httr) # for uploading to the API
  
  
  # clean up user inputs
  
  user_input_essdive_id <- essdive_id
  
  user_input_coordinates_file_path <- coordinates_file_path
  
  # apply ess-dive site given input (options: "https://api-sandbox.ess-dive.lbl.gov" OR "https://api.ess-dive.lbl.gov")
  if (upload_site == "main") {
    
    user_input_upload_site <- "https://api.ess-dive.lbl.gov"
    
  } else if (upload_site == "sandbox") {
    
    user_input_upload_site <- "https://api-sandbox.ess-dive.lbl.gov"
    
  } else {
    log_fatal(glue("Upload site not found. You entered `{upload_site}`. Please indicate either `main` or `sandbox`."))
    stop("Function terminating.")
  }
  
  log_info(glue("Updating {upload_site} landing page (id = {user_input_essdive_id}) with coordinates from `{basename(user_input_coordinates_file_path)}`."))
  
  
  ### Convert coordinates from csv to R list to JSON ###########################
  
  log_info("Preparing coordinates.")
  
  # read in file
  coordinates_csv <- read_csv(user_input_coordinates_file_path, show_col_types = F)
  
  # check correct column headers exist
  required_cols <- c("Description", "Latitude", "Longitude")
  coordinates_csv <- rename_column_headers(coordinates_csv, required_cols)
  missing_cols <- setdiff(required_cols, colnames(coordinates_csv))
  
  if (!all(required_cols %in% colnames(coordinates_csv))) {
    
    # if necessary headers don't exist, returns error message and stops function
    log_fatal(paste0("Missing columns: ", paste(missing_cols, collapse = ", ")))
    stop("Function terminating.")
    
  } else {
    
    # select the 3 required cols
    coordinates_csv <- coordinates_csv %>% 
      select(Description, Latitude, Longitude)
  }
  
  
  # initiate empty list
  spatialCoverage_list <- list()
  
  # loop through each set of coordinates and convert it to an R list
  for (i in 1:nrow(coordinates_csv)) {
    
    current_row <- coordinates_csv[i, ]
    
    log_info(glue("Preparing coordinates for `{current_row$Description}`"))
    
    # create a list for i-th location
    current_list <- list(
      description = current_row$Description,
      geo = list(
        list(name = "Northwest",
             latitude = current_row$Latitude,
             longitude = current_row$Longitude),
        list(name = "Southeast",
             latitude = current_row$Latitude,
             longitude = current_row$Longitude)))
    
    # add list to spatialCoverage parent list
    spatialCoverage_list[[i]] <- current_list
    
  }
  
  # add coordinate lists into parent list
  spatialCoverage <- list(spatialCoverage = spatialCoverage_list)
  
  # convert to JSON
  json_str <- toJSON(spatialCoverage, auto_unbox = T, pretty = T)
  
  
  ### Update landing page via API with PUT #######################################
  
  # prepare to update
  header_authorization <- paste0("bearer ", api_token)
  upload_url <- as.character(glue("{user_input_upload_site}/packages/{essdive_id}"))
  
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
  }else {
    
    log_error("API update error.")
    
    # displays error message
    print(http_status(update_via_api))
    message(put_package_text)
  }
  
  log_info("update_landing_page_coordinates complete")
  
}




