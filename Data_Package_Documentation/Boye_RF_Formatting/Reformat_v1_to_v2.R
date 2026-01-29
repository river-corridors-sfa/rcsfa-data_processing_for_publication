# ==============================================================================
#
# Reformat Boye rf v1 into v2
#
# Status: In progress
#
# Note: need to check how we are handling our column headers
# Note: once we determine standard and keywords, I can input them in the cli 
#   reminder so I can just copy paste them; can also add the readme langauge 
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 29 January 2026
#
# ==============================================================================
require(pacman)
p_load(tidyverse,
       cli)

rm(list=ls(all=T))

# ================================= User inputs ================================

# choose all v1 files to convert
v1_files <- choose.files()

# ================================= update v1 to v2=============================

for (v1_input in v1_files) {
  
  
  v1 <- read_csv(v1_input, skip = 2) 
  
  
  header_row_data <- setNames(as.list(headers), headers)
  
  v2 <- v1 %>%
    add_row(!!!header_row_data, .before = which(v1$Field_Name == "#Start_Data")) %>%
    mutate(Field_Name = str_replace(Field_Name, 'Unit_Basis', '#unit_basis'),
           Field_Name = str_replace(Field_Name, 'Unit', '#unit'),
           Field_Name = str_replace(Field_Name, 'MethodID_Analysis', '#method_id_analysis'),
           Field_Name = str_replace(Field_Name, 'MethodID_Inspection', '#method_id_inspection'),
           Field_Name = str_replace(Field_Name, 'MethodID_Storage', '#method_id_storage'),
           Field_Name = str_replace(Field_Name, 'MethodID_Preservation', '#method_id_preservation'),
           Field_Name = str_replace(Field_Name, 'MethodID_Preparation', '#method_id_preparation'),
           Field_Name = str_replace(Field_Name, 'MethodID_DataProcessing', '#method_id_dataprocessing'),
           Field_Name = str_replace(Field_Name, 'Analysis_DetectionLimit', '#analysis_detection_limit'),
           Field_Name = str_replace(Field_Name, 'Analysis_Precision', '#analysis_precision'),
           Field_Name = str_replace(Field_Name, 'Data_Status', '#data_status'),
           Field_Name = str_replace(Field_Name, '#Start_Data', 'N/A'),
           Field_Name = str_replace(Field_Name, 'MethodID', 'method_id'),
           Field_Name = str_replace(Field_Name, 'MethodID', 'method_id')
    ) %>%
    filter(Field_Name != '#End_Data')  %>%
    rename('#Field_Name' = Field_Name)
  
  write_csv(v2, v1_input)
  
}



post_conversion_reminders <- function() {
  cli_h2("Reminders")
  cli_ol()
  cli_li("Update standard column in FLMD")
  cli_li("Update standard keyword on ESS-DIVE")
  cli_li("Document rf changes in README change history")
  cli_end()
}

# Call the function to display the checklist
post_conversion_reminders()
