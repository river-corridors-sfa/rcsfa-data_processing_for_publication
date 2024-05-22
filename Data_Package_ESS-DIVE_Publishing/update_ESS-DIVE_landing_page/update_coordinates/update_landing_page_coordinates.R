### update_landing_page_coordinates.R ##########################################
# Date Created: 2024-05-22
# Date Updated: 2024-05-22
# Author: Bibi Powers-McCormack

# Objective: 
  # Update a landing page with new coordinates

# Assumptions: 
  # Any update will overwrite all existing coordinates.
  # The coordinates .csv requires the columns: "Description", "Latitude", and "Longitude"
  
# Inputs: 
  # ESS-DIVE identifer (can be located on landing page under "General" section (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721))
  # Absoulte file path of geospatial coordinates saved as a .csv with the columns: "Description", "Latitude", and "Longitude"

# Outputs: 
  # The function returns a written message that the data package has been updated
  # It will include the URL and name of the data package

api_token <- "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDktMDAwNS0yMTI1LTEyNjgiLCJmdWxsTmFtZSI6IkJlY2sgUG93ZXJzLU1jQ29ybWFjayIsImlzc3VlZEF0IjoiMjAyNC0wNS0yMlQxNzowOTozOS43MzIrMDA6MDAiLCJjb25zdW1lcktleSI6InRoZWNvbnN1bWVya2V5IiwiZXhwIjoxNzE2NDYyNTc5LCJ1c2VySWQiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDktMDAwNS0yMTI1LTEyNjgiLCJ0dGwiOjY0ODAwLCJpYXQiOjE3MTYzOTc3Nzl9.OdbDSIdeFrEvjzDGQHclY2JNlFqr-MivncQJ1mFngKphB9uN7GOjjTKZ8PPeFUnUbn9yf9FlKUOmGcA7gKCgfPXOw9NjH37oqJA8_VVDDfzN5V2U0xL8gGpab3SqYcEaF5UK5GZBcpZKws5I3XkrjwBK_F8Q929wr0ElyrqHlC4VEQGFb48ilAkp0fAiTz73or4yv1q93AdT9fkAQJ_JwqxNzJO3fD8ACEThCPFPhhgOh5AQ2OzeMEQalkXzx_IScr4e0hLzJ-IC9ccCjZTcrtyryTW-TSI9Ls4yqN0Qe47WJ5QrTmjNCT1cTK_CB5X9km7N6KfZZw_zYBJpLSt2SQ"

essdive_id <- "ess-dive-e51251ad488b35f-20240522T205038891721"

coordinates_file_path <- "C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-data_proceesing_for_publication/Data_Package_ESS-DIVE_Publishing/update_ESS-DIVE_landing_page/update_coordinates/update_coordinates_template.csv"

upload_site <- "sandbox" # options include c("main", "sandbox")

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../../..") # move wd back to the repo directory
getwd()


### FUNCTION ###################################################################

### Prep script ################################################################

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

if (upload_site == "main") {
  
  user_input_upload_site <- "https://api.ess-dive.lbl.gov"
  
} else if (upload_site == "sandbox") {
  
  user_input_upload_site <- "https://api-sandbox.ess-dive.lbl.gov"
  
} else {
  log_fatal(glue("Upload site not found. You entered `{upload_site}`. Please indicate either `main` or `sandbox`."))
  stop("Function terminating.")
}

log_info(glue("Updating {upload_site} landing page (id = {user_input_essdive_id}) with coordinates from `{basename(user_input_coordinates_file_path)}`."))


### Convert coordinates from csv to R list to JSON #############################

log_info("Preparing coordinates.")

# read in file
coordinates_csv <- read_csv(user_input_coordinates_file_path, show_col_types = F)

# check correct column headers exist
required_cols <- c("Description", "Latitude", "Longitude")
coordinates_csv <- rename_column_headers(coordinates_csv, required_cols)
missing_cols <- setdiff(required_cols, colnames(coordinates_csv))

if (!all(required_cols %in% colnames(coordinates_csv))) {

  log_fatal(paste0("Missing columns: ", paste(missing_cols, collapse = ", ")))
  stop("Function terminating.")
  
} else {
  coordinates_csv <- coordinates_csv %>% 
    select(Description, Latitude, Longitude)
}


# loop through each set of coordinates and convert it to an R list

# initiate empty list
spatialCoverage_list <- list()

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

# updating with API
update_via_api <- PUT(url = upload_url,
                      body = json_str,
                      add_headers(Authorization = header_authorization,
                                  "Content-Type" = "application/json"))


# Check the status and review the results
put_package_text <- content(update_via_api, "text", encoding = "UTF-8")
put_package_json <- fromJSON(put_package_text)

if(!http_error(update_via_api) ){
  
  log_info("API update successful.")
  
  attributes(put_package_json)
  cat("View URL: ")
  cat(put_package_json$viewUrl)
  cat("\n")
  cat("Name: ")
  cat(put_package_json$dataset$name)
}else {
  
  log_error("API update error.")
  
  print(http_status(update_via_api))
  message(put_package_text)
}

log_info("update_landing_page_coordinates complete")


