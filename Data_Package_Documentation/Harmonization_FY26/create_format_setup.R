# ==============================================================================
#
# Set up script for create_format.R function
#
# Status: in progress
#
#
# ==============================================================================
#
# Brieanne Forbes (brieanne.forbes@pnnl.gov)
# 11 August 2025
#
# ==============================================================================

library(tidyverse)

rm(list=ls(all=T))

current_path <- rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# ================================ User Inputs =================================