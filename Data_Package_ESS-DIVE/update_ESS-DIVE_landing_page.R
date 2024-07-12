### update_ESS-DIVE_landing_page.R #############################################
# Date Created: 2024-05-20
# Date Updated: 2024-05-22
# Author: Bibi Powers-McCormack

# Objective: 

# Assumptions: 

# Inputs: 
  # see the `Load user inputs` section
  # see the `Load static inputs` section

# Outputs: 

# Notes: 
  # current status: work in progress. 
    # First attempting to create a static script to create and then update a DP.
    # Then will modify to add site coordinates into landing page. 
    # Then will modify into a pipeline.


### Prep script ################################################################
# Directions: RUn this chunk without modification. 

# load libraries
library(tidyverse)
library(rlog)
library(glue)
library(jsonlite)
library(httr)


### Load user inputs ###########################################################
# Directions: Fill in user input strings

user_inputs <- list(
  
  # this is the API token from ESS-DIVE
  user_token = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDktMDAwNS0yMTI1LTEyNjgiLCJmdWxsTmFtZSI6IkJlY2sgUG93ZXJzLU1jQ29ybWFjayIsImlzc3VlZEF0IjoiMjAyNC0wNS0yMlQxNzowOTozOS43MzIrMDA6MDAiLCJjb25zdW1lcktleSI6InRoZWNvbnN1bWVya2V5IiwiZXhwIjoxNzE2NDYyNTc5LCJ1c2VySWQiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDktMDAwNS0yMTI1LTEyNjgiLCJ0dGwiOjY0ODAwLCJpYXQiOjE3MTYzOTc3Nzl9.OdbDSIdeFrEvjzDGQHclY2JNlFqr-MivncQJ1mFngKphB9uN7GOjjTKZ8PPeFUnUbn9yf9FlKUOmGcA7gKCgfPXOw9NjH37oqJA8_VVDDfzN5V2U0xL8gGpab3SqYcEaF5UK5GZBcpZKws5I3XkrjwBK_F8Q929wr0ElyrqHlC4VEQGFb48ilAkp0fAiTz73or4yv1q93AdT9fkAQJ_JwqxNzJO3fD8ACEThCPFPhhgOh5AQ2OzeMEQalkXzx_IScr4e0hLzJ-IC9ccCjZTcrtyryTW-TSI9Ls4yqN0Qe47WJ5QrTmjNCT1cTK_CB5X9km7N6KfZZw_zYBJpLSt2SQ",
  
  # ess-dive site (options: "https://api-sandbox.ess-dive.lbl.gov" OR "https://api.ess-dive.lbl.gov")
  user_upload_site = "https://api-sandbox.ess-dive.lbl.gov"
)


### Load static inputs #########################################################
# Directions: Run this chunk without modification
# this generates any remaining inputs

static_inputs <- list(
  header_authorization = paste0("bearer ", user_inputs$user_token),
  call_post_package = as.character(glue("{user_inputs$user_upload_site}/packages"))
)


### Create json list ###########################################################
# Directions: Run this chunk without modification
# this first creates an R list with all the input parameters
# the required parameters are indicated with an asterisk

log_info("Creating JSON list.")


json_list <- list(
  
  `@context` = "http://schema.org/", #*
  `@type` = "Dataset", #*
  
  name = "BP Example Data Package v1", #title*
  # alternateName = "", #alternate name
  description = "Description v1", #abstract*
  keywords = list("keyword1", "keyword2", "keyword3"), #keywords*
  variableMeasured = list("variable1", "variable2"), #data variables
  datePublished = Sys.Date(), #publication date
  license = "http://creativecommons.org/licenses/by/4.0/", #usage rights* 
  provider = list(identifier = list(
                    `@type` = "PropertyValue",
                    propertyID = "ess-dive",
                    value = "d12f558e-bcc7-44ca-8f16-6a37b0dae7f4" #project id* from https://docs.google.com/spreadsheets/d/179SOyv42wXbP4owWZtUg3RqhW9dPOyENYcVYuUCcqwg/edit#gid=1921074133
                  ),
                  member = list(
                    `@id` = "https://orcid.org/0000-0003-0490-6451", 
                    givenName = "Timothy D.", 
                    familyName = "Scheibe", 
                    email = "tim.scheibe@pnnl.gov",
                    affiliation = "Pacific Northwest National Laboratory"
                    )),
  funder = list(`@id` = "http://dx.doi.org/10.13039/100006206",
                name = "U.S. DOE > Office of Science > Biological and Environmental Research (BER)"), #funding organization
  # award = "", #DOE contracts number
  # citation = "", #related references
  editor = list(`@id` = "https://orcid.org/0009-0005-2125-1268",
                givenName = "Beck",
                familyName = "Powers-McCormack",
                email = "bibipowers-mccormack@pnnl.gov"), #contact*
  creator = #creators
    list(`@id` = "https://orcid.org/0009-0005-2125-1268", #orcid
         givenName = "Beck", #first name
         familyName = "Powers-McCormack", #last name
         affiliation = "Pacific Northwest National Laboratory"), #institution
  # contributor = "", #contributors
  # temporalCoverage = list(
  #   startDate = "", #start date
  #   endDate = "" #end date
  # ),
  # spatialCoverage = list(
  #   list(description = "geographic location description v1", #geographic description
  #        geo = 
  #          list(name = "Northwest",
  #            latitude = 56.38609, # geographic coordinates
  #            longitude = -121.45047)),
  #   list(description = "", 
  #        geo = 
  #          list(name = "Southeast",
  #             latitude = 56.38609, 
  #             longitude = -121.45047))),
  measurementTechnique = "Methods v1" #methods
)


### Checking list ##############################################################
# Directions: Run this chunk without modification
# this runs checks to make sure the R list is complete



### Create json str from list ##################################################
# Directions: Run this chunk without modification
# this converts the R list into a JSON string

json_str <- toJSON(json_list, auto_unbox = T, pretty = T)
# json_list <- fromJSON(json_str)

library(clipr)
write_clip(json_str)

### Upload data package to ESS-DIVE ############################################

upload_via_api <- POST(url = static_inputs$call_post_package,
                       body = json_str, 
                       add_headers(Authorization = static_inputs$header_authorization,
                                   "Content-Type" = "application/json"))


post_package_text <- content(upload_via_api, "text", encoding = "UTF-8")
post_package_json <- fromJSON(post_package_text)

if(!http_error(upload_via_api) ){
  attributes(post_package_json)
  cat("View URL: ")
  cat(post_package_json$viewUrl)
  cat("\n")
  cat("Name: ")
  cat(post_package_json$dataset$name)
}else {
  print(http_status(upload_via_api))
  message(post_package_json)
}


### Update ESS-DIVE landing page ###############################################
# note that updates to each section replace what was previously there


# update to v2 (change title)
user_input_essdive_id <- "ess-dive-ee2f1c5173c98ca-20240522T182138080471"

json_list_v2 <- list(
  name = "BP Example Data Package v2" #title*
)

json_str_v2 <- toJSON(json_list_v2, auto_unbox = T, pretty = T)

write_clip(json_str_v2)

update_via_api <- PUT(url = paste0(static_inputs$call_post_package, "/", user_input_essdive_id),
                      body = json_str_v2,
                      add_headers(Authorization = static_inputs$header_authorization,
                                  "Content-Type" = "application/json"))

put_package_text <- content(update_via_api, "text")
put_package_json <- fromJSON(put_package_text)

# Check the status and review the results
if(!http_error(update_via_api) ){
  attributes(put_package_json)
  cat("View URL: ")
  cat(put_package_json$viewUrl)
  cat("\n")
  cat("Name: ")
  cat(put_package_json$dataset$name)
}else {
  print(http_status(update_via_api))
  message(put_package_text)
}


### update again to v3 (add coords)
user_input_essdive_id <- "ess-dive-8c7ce3eb9cb4250-20240522T185759146692"

json_list_v3 <- list(
  name = "BP Example Data Package v3", #title*
  spatialCoverage = list(
      list(description = "geographic location description v3", #geographic description
           geo = list(
             list(name = "Northwest",
               latitude = 56.38609, # geographic coordinates
               longitude = -121.45047),
             list(name = "Southeast",
                latitude = 56.38609,
                longitude = -121.45047))))
)

json_str_v3 <- toJSON(json_list_v3, auto_unbox = T, pretty = T)

write_clip(json_str_v3)

update_via_api <- PUT(url = paste0(static_inputs$call_post_package, "/", user_input_essdive_id),
                      body = json_str_v3,
                      add_headers(Authorization = static_inputs$header_authorization,
                                  "Content-Type" = "application/json"))

put_package_text <- content(update_via_api, "text")
put_package_json <- fromJSON(put_package_text)

# Check the status and review the results
if(!http_error(update_via_api) ){
  attributes(put_package_json)
  cat("View URL: ")
  cat(put_package_json$viewUrl)
  cat("\n")
  cat("Name: ")
  cat(put_package_json$dataset$name)
}else {
  print(http_status(update_via_api))
  message(put_package_text)
}


### update to v4 (add more coords)
user_input_essdive_id <- "ess-dive-9b4c92d0c8aae96-20240522T194054118315"

json_list_v4 <- list(
  name = "BP Example Data Package v4", #title*
  spatialCoverage = list(
    list(description = "geographic location description change to Richland v4", #geographic description
         geo = list(
           list(name = "Northwest",
                latitude = 46.34505149590734, # geographic coordinates
                longitude = -119.27934782172696),
           list(name = "Southeast",
                latitude = 56.38609,
                longitude = -121.45047))),
    list(description = "geographic location description add Sequim v4",
         geo = list(
           list(name = "Northwest",
                latitude = 48.07700161622627,
                longitude = -123.04651782941667),
           list(name = "Southeast",
                latitude = 48.07700161622627,
                longitude = -123.04651782941667))))
)

json_str_v4 <- toJSON(json_list_v4, auto_unbox = T, pretty = T)

write_clip(json_str_v4)

update_via_api <- PUT(url = paste0(static_inputs$call_post_package, "/", user_input_essdive_id),
                      body = json_str_v4,
                      add_headers(Authorization = static_inputs$header_authorization,
                                  "Content-Type" = "application/json"))

put_package_text <- content(update_via_api, "text")
put_package_json <- fromJSON(put_package_text)

# Check the status and review the results
if(!http_error(update_via_api) ){
  attributes(put_package_json)
  cat("View URL: ")
  cat(put_package_json$viewUrl)
  cat("\n")
  cat("Name: ")
  cat(put_package_json$dataset$name)
}else {
  print(http_status(update_via_api))
  message(put_package_text)
}


### update to v5 (fix coords)
user_input_essdive_id <- "ess-dive-8bfeda9e12b4907-20240522T204804805253"

json_list_v5 <- list(
  name = "BP Example Data Package v5", #title*
  spatialCoverage = list(
    list(description = "geographic location description change to Richland v5", #geographic description
         geo = list(
           list(name = "Northwest",
                latitude = 46.34505149590734, # geographic coordinates
                longitude = -119.27934782172696),
           list(name = "Southeast",
                latitude = 46.34505149590734,
                longitude = -119.27934782172696))))
)

json_str_v5 <- toJSON(json_list_v5, auto_unbox = T, pretty = T)

write_clip(json_str_v5)

update_via_api <- PUT(url = paste0(static_inputs$call_post_package, "/", user_input_essdive_id),
                      body = json_str_v5,
                      add_headers(Authorization = static_inputs$header_authorization,
                                  "Content-Type" = "application/json"))

put_package_text <- content(update_via_api, "text")
put_package_json <- fromJSON(put_package_text)

# Check the status and review the results
if(!http_error(update_via_api) ){
  attributes(put_package_json)
  cat("View URL: ")
  cat(put_package_json$viewUrl)
  cat("\n")
  cat("Name: ")
  cat(put_package_json$dataset$name)
}else {
  print(http_status(update_via_api))
  message(put_package_text)
}

