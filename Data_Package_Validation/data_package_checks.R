### data_package_checks.R ######################################################

# Objective: 


### User Inputs ################################################################




### Prep Script ################################################################
# Directions: Run this chunk without modification.

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
setwd("../...") # move wd back to the repo directory
getwd()


# load libraries
library(tidyverse)
library(rlog)
library(fs) # for tree diagram
library(clipr) # for copying to clipboard