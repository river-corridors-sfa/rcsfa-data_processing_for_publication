### update_landing_page_coordinates_config.R ###################################

# Use this script to provide the user inputs for updating coordinates on the landing page

# This script sources in `update_landing_page_coordinates.R`: 
  
  # Objective: 
    # Update a landing page with new coordinates
  
  # Assumptions: 
    # The working directory is set to the `rcsfa-data_processing_for_publication` repo
    # Any update will overwrite all existing coordinates.
    # The coordinates .csv requires the columns: "Description", "Latitude", and "Longitude"
  
  # Inputs: 
    # ESS-DIVE identifier (can be located on landing page under "General" section (e.g., "ess-dive-e51251ad488b35f-20240522T205038891721))
    # Absolute file path of geospatial coordinates saved as a .csv with the columns: "Description", "Latitude", and "Longitude"
  
  # Outputs: 
    # Returns a written message that the data package has been updated
    # It will include the URL and name of the data package


### Prep script ################################################################
# Directions: Run this chunk without modification

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../../..") # move wd back to the repo directory
getwd()

# load libraries
library(tidyverse)
library(rlog)
library(glue)
library(jsonlite) # for converting to json-ld file
library(httr) # for uploading to the API

# load functions
source("./Data_Package_ESS-DIVE_Publishing/update_ESS-DIVE_landing_page/update_coordinates/update_landing_page_coordinates.R")
source("./Data_Transformation/functions/rename_column_headers.R")


### Provide User Inputs ########################################################
# Directions: Fill out these user inputs

# this is your personal token that you can get after signing into ess-dive
api_token <- "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDktMDAwNS0yMTI1LTEyNjgiLCJmdWxsTmFtZSI6IkJlY2sgUG93ZXJzLU1jQ29ybWFjayIsImlzc3VlZEF0IjoiMjAyNC0wNS0yMlQxNzowOTozOS43MzIrMDA6MDAiLCJjb25zdW1lcktleSI6InRoZWNvbnN1bWVya2V5IiwiZXhwIjoxNzE2NDYyNTc5LCJ1c2VySWQiOiJodHRwOlwvXC9vcmNpZC5vcmdcLzAwMDktMDAwNS0yMTI1LTEyNjgiLCJ0dGwiOjY0ODAwLCJpYXQiOjE3MTYzOTc3Nzl9.OdbDSIdeFrEvjzDGQHclY2JNlFqr-MivncQJ1mFngKphB9uN7GOjjTKZ8PPeFUnUbn9yf9FlKUOmGcA7gKCgfPXOw9NjH37oqJA8_VVDDfzN5V2U0xL8gGpab3SqYcEaF5UK5GZBcpZKws5I3XkrjwBK_F8Q929wr0ElyrqHlC4VEQGFb48ilAkp0fAiTz73or4yv1q93AdT9fkAQJ_JwqxNzJO3fD8ACEThCPFPhhgOh5AQ2OzeMEQalkXzx_IScr4e0hLzJ-IC9ccCjZTcrtyryTW-TSI9Ls4yqN0Qe47WJ5QrTmjNCT1cTK_CB5X9km7N6KfZZw_zYBJpLSt2SQ"

# this is the identifier number from the data package you want to update - you can get it from the ess-dive landing page
essdive_id <- "ess-dive-bb3760054337704-20240522T230449359525"

# this is the .csv absolute file path of the coordinates
coordinates_file_path <- "C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-data_proceesing_for_publication/Data_Package_ESS-DIVE_Publishing/update_ESS-DIVE_landing_page/update_coordinates/update_coordinates_template.csv"

# indicate if you want to update a data package on the sandbox vs main site - options include c("main", "sandbox")
upload_site <- "sandbox" 


### Run function ###############################################################
# Directions: Run this chunk without modification

update_landing_page_coordinates(api_token = api_token,
                                essdive_id = essdive_id,
                                coordinates_file_path = coordinates_file_path,
                                upload_site = upload_site)
