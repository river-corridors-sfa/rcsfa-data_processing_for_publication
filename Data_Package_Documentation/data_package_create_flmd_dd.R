### data_package_create_flmd_dd.R ##############################################

# Objective: 
  # Run this script to generate dd and flmds.
  # It will create empty data dictionary and file-level metadata skeletons.
  # Then it will begin to fill in those skeletons by querying the database. 


### User Inputs ################################################################
# Directions: Fill out the user inputs. Then run the chunk.

# data package directory (do not include a "/" at the end)
directory <- "C:/Users/powe419/Desktop/bpowers_github_repos/Barnes_2024_BSLE_P_Gradient_Manuscript_Data_Package/rcsfa-RC3-BSLE_P" # commit 0038170cccf47d4bd56fadb5da114ddf810e4f2d

# directory where you want the dd and flmd to be written out to (do not include a "/" at the end)
out_directory <- "C:/Users/powe419/OneDrive - PNNL/Desktop/BP PNNL/INBOX/data_package_skeletons"
  

### Prep Script ################################################################
# Directions: Run this chunk without modification.

# load libraries
library(rstudioapi)
library(tidyverse)
library(rlog)
library(fs)
library(clipr)
library(tools)

# set working directory to this GitHub repo (rcsfa-data-processing-for-publication)
current_path <- rstudioapi::getActiveDocumentContext()$path # get current path
setwd(dirname(current_path)) # set wd to current path
rm(current_path)
setwd("../...") # move wd back to the repo directory
getwd()

# load functions
source("./Data_Transformation/functions/load_tabular_data.R")
source("./Data_Package_Documentation/functions/create_dd_skeleton.R")
source("./Data_Package_Documentation/functions/create_flmd_skeleton.R")
source("./Data_Package_Documentation/functions/query_dd_database.R")
source("./Data_Package_Documentation/functions/query_flmd_database.R")


# load helper functions
source("./Data_Transformation/functions/rename_column_headers.R")


### Run Functions ##############################################################
# Directions: Run chunk without modification. Answer inline prompts as they appear. 

exclude_patterns <- c(
  "data/Archive/", 
  "data/BSLE_Data_Package_v3", 
  "data/summary_leachate_conc.csv", 
  "data/summary_NMR_spike.csv", 
  "data/summary_solids_conc.csv", 
  "data/summary_solids_nmr.csv", 
  "data/solids_nmrEE.csv", 
  "data/summary_stoich.csv", 
  "figures/Archive", 
  "figures/leach.Pnorm.conc.mbd.pdf", 
  "figures/leachPnorm.conc.pdf", 
  "figures/pH_BS.pdf", 
  "figures/aq_pH.pdf", 
  "figures/LCF72.pdf", 
  "figures/LCF11.pdf", 
  "figures/LCF14.pdf", 
  "figures/LCF50.pdf", 
  "figures/LCF2.pdf", 
  "figures/LCF7.pdf", 
  "figures/LCF13.pdf", 
  "figures/XANES_stacked_spectra_rc.pdf", 
  "figures/SB.mod.xanes.pdf", 
  "figures/SB.low.xanes.pdf", 
  "figures/SB.raw.xanes.pdf", 
  "figures/DF.high.xanes.pdf", 
  "figures/DF.mod.xanes.pdf", 
  "figures/DF.low.xanes.pdf", 
  "figures/DF.raw.xanes.pdf", 
  "figures/xanes.legend.pdf", 
  "figures/XANES_stacked_spectra_sb.pdf", 
  "figures/XANES_stacked_spectra_df.pdf", 
  "figures/mono_die_loss.pdf", 
  "figures/SB.mod.nmr.pdf", 
  "figures/SB.low.nmr.pdf", 
  "figures/SB.raw.nmr.pdf", 
  "figures/DF.high.nmr.pdf", 
  "figures/DF.mod.nmr.pdf", 
  "figures/DF.low.nmr.pdf", 
  "figures/DF.raw.nmr.pdf", 
  "figures/nmr.legend.pdf", 
  "figures/NMR_stacked_spectra_sb.pdf", 
  "figures/NMR_stacked_spectra_df.pdf", 
  "figures/solid.P.BS.fig.pdf", 
  "figures/leach.Pnorm.conc.mbd2.pdf", 
  "figures/Char_Photos_Figure.pdf", 
  "figures/Char_Photos_Figure.pptx", 
  "figures/XANES_LCF_individual_sample_table", 
  "figures/XANES_LCF_individual_sample_table", 
  "figures/pH_fig.pdf", 
  "figures/pH_fig.pptx", 
  "figures/Path_Analysis_Conceptual_Model.pdf", 
  "figures/Path_Analysis_Conceptual_Model.pptx", 
  "figures/Path_Analysis.pdf", 
  "figures/Path_Analysis.pptx", 
  "figures/XANES_Spectra_Pie.pdf", 
  "figures/XANES_Spectra_Pie.pptx", 
  "figures/NMR_Spectra_Pie.pdf", 
  "figures/NMR_Spectra_Pie.pptx", 
  "figures/LCF_Eample_Samples_Tall.pdf", 
  "figures/LCF_Eample_Samples_Tall.pptx", 
  "figures/NMR_Methods.pdf", 
  "figures/NMR_Methods.pptx", 
  "figures/NMR_spiking.pdf", 
  "figures/NMR_spiking.pptx", 
  "figures/NMR_regions.pdf", 
  "figures/NMR_regions.pptx", 
  "figures/NMR region example sample.pdf", 
  "figures/spike example figure_solid 11.pdf", 
  "figures/spike example figure_solid 11.mnova", 
  "figures/LCF_Example_Samples.pptx", 
  "figures/Graphical_Abstract_final.pptx", 
  "figures/Graphical_Abstract_final.pdf", 
  "figures/leach.Pnorm.conc copy.pdf", 
  "figures/Leachate_P_Conc.pdf", 
  "figures/Leachate_P_Conc.pptx", 
  "figures/Solid_P_Conc.pdf", 
  "figures/Solid_P_Conc.pptx", 
  "figures/conceptual_model.pdf", 
  "figures/conceptual_model.pptx", 
  "figures/Graphical_Abstract.pdf", 
  "figures/Graphical_Abstract.pptx", 
  "figures/burn_conditions_pca.pdf", 
  "figures/Mono_Di_Percent_Loss.pdf", 
  "figures/Mono_Di_perc_loss_fig.pdf", 
  "figures/Mono_Di_Percent_Loss.png", 
  "figures/XANES_RefCompd_Table_SubsetforLCF.xlsx", 
  "figures/SEM3.pdf", 
  "figures/Stoichiometry_table.xlsx", 
  "figures/LCF_Example_Samples.pdf", 
  "figures/each.charnorm.conc.pdf", 
  "figures/p_pa.pdf", 
  "figures/SEM1.pdf", 
  "figures/p_pa2.pdf", 
  "figures/corr_element_char_sage.pdf", 
  "figures/corr_element_char_doug.pdf", 
  "figures/corr_element_char_allecosystem.pdf", 
  "figures/solid.element.corr.all.pdf", 
  "figures/leach.conc.pdf", 
  "figures/Leachate_stacked_bar.pdf", 
  "figures/Leachate.unfilt.total.P.BS.boxplot.pdf", 
  "figures/Leachate.filt0.7.total.P.BS.boxplot.pdf", 
  "figures/Leachate.total.P.BS.boxplot.pdf", 
  "figures/MBD.BS.fig.pdf", 
  "figures/Solid_Conc_Table.xlsx", 
  "figures/leachate_conc.pptx", 
  "scripts/Archive"
)

exclude_regex <- paste0("(", paste(exclude_patterns, collapse = "|"), ")")
all_files <- list.files(directory, recursive = T)
filtered_files <- all_files[!grepl(exclude_regex, all_files)]

# 1. Load data
data_package_data <- load_tabular_data(directory, exclude_files = filtered_files)



# 2a. create dd skeleton
dd_skeleton <- create_dd_skeleton(data_package_data$headers)


# 2b. populate dd
# dd_skeleton_populated <- query_dd_database(dd_skeleton)


# 3a. create flmd skeleton
flmd_skeleton <- create_flmd_skeleton(data_package_data$file_paths_relative)


# 3b. populate flmd
# flmd_skeleton_populated <- query_flmd_database(flmd_skeleton)

### DP Specific Edits ##########################################################

# left join prelim dd to this dd

prelim_dd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-RC4-WROL-YRB_DOM_Diversity/data_package_preparation/Ryan_2024_WROL_YRB_DOM_Diversity_dd.csv", skip = 1)

dd_skeleton <- dd_skeleton %>% 
  select(Column_or_Row_Name) %>% 
  left_join(prelim_dd, by = c("Column_or_Row_Name")) %>%
  arrange(Column_or_Row_Name)

# left join prelim flmd to this flmd

prelim_flmd <- read_csv("C:/Users/powe419/Desktop/bpowers_github_repos/rcsfa-RC4-WROL-YRB_DOM_Diversity/data_package_preparation/Ryan_2024_WROL_YRB_DOM_Diversity_flmd.csv", skip = 1) %>%
  select(-File_Path)

flmd_skeleton <- flmd_skeleton %>% 
  select(File_Name, File_Path) %>% 
  left_join(prelim_flmd, by = c("File_Name")) %>% 
  select(-File_Path, File_Path)

# add status column to list the cols that need to be filled in
find_na_columns <- function(row) {
  na_cols <- names(row)[is.na(row)]
  if (length(na_cols) == 0) {
    return("None")
  } else {
    return(paste(na_cols, collapse = ", "))
  }
}

# Using mutate and across to apply find_na_columns
flmd_skeleton_with_status <- flmd_skeleton %>%
  rowwise() %>%
  mutate(status = find_na_columns(cur_data())) %>% 
  select(status, everything())

# get headers
headers <- data_package_data$headers %>%
  mutate(file = basename(file)) %>% 
  group_by(header) %>% 
  summarise(header_count = n(),
            files = toString(file)) %>% 
  ungroup() %>% 
  arrange(header, .locale = "en")


### Export #####################################################################
# Directions: 
  # Export out .csvs at your choosing. Only run the lines you want. 
  # After exporting, remember to properly rename the dd and flmd files and to update the flmd to reflect such changes.

# write out data package data
save(data_package_data, file = paste0(out_directory, "/data_package_data.rda"))

# write out skeleton dd
write_csv(dd_skeleton, paste0(out_directory, "/skeleton_dd.csv"), na = "")

# write out populated dd
write_csv(dd_skeleton_populated, paste0(out_directory, "/skeleton_populated_dd.csv"), na = "")

# write out skeleton flmd
write_csv(flmd_skeleton, paste0(out_directory, "/skeleton_flmd.csv"), na = "")

# writ eout populated flmd
write_csv(flmd_skeleton_populated, paste0(out_directory, "/skeleton_populated_flmd.csv"), na = "")

# open the directory the files were saved to
shell.exec(out_directory)


