### Chen_2024_YOLO_v2_DP_Prep.R ################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-27
# Date Updated: 2025-06-27

# Objective: 


### create flmd and dd #########################################################
#Brie is running the flmd and dd skeletons on the remote computers and saving
#the outputs into the secret folder archive. This script takes those prelim
#files and combines it with v1 to produce the actual v2 flmd and dds.

# the goal is now to combine the old definitions from v1 into the new prelim files.

# load libraries
library(tidyverse)

# load in rda file
setwd("Z:/00_ESSDIVE/03_Manuscript_DPs/Chen_2024_YOLO_v2")
load("./Archive/data_package_data.rda")

# load in preliminary flmd and dd
flmd_prelim <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Chen_2024_YOLO_v2/Archive/skeleton_flmd.csv" %>% 
  read_csv(.)
dd_prelim <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Chen_2024_YOLO_v2/Archive/skeleton_dd.csv" %>% 
  read_csv(.)

# load in v1 flmd and dd
flmd_v1 <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Chen_2024_YOLO_v2/Archive/flmd_v1.csv" %>% 
  read_csv(.) %>% 
  mutate(File_Path = str_replace_all(File_Path, "\\\\", "/"))

dd_v1 <- "Z:/00_ESSDIVE/03_Manuscript_DPs/Chen_2024_YOLO_v2/Archive/dd_v1.csv" %>% 
  read_csv(.)

# lets start with the dd

# get file header counts
headers <- data_package_data$headers %>%
  mutate(file = basename(file)) %>% 
  group_by(header) %>% 
  summarise(header_count = n(),
            files = toString(file)) %>% 
  ungroup() %>% 
  arrange(header, .locale = "en")

# additional flmd definitions
dd_template <- tribble(~Column_or_Row_Name, ~Unit, ~Definition, ~Data_Type,
                       # flmd
                       "File_Name",	"N/A",	"Name of files in the data package.", "text",
                       "File_Description",	"N/A",	"A brief description of the files in the data package.",	"text",
                       "Standard",	"N/A",	"ESS-DIVE Reporting Format or other standard applied to the data file.",	"text",
                       "Missing_Value_Codes",	"N/A",	'Cells with missing data are represented with a missing value code rather than an empty cell. This column describes which missing value codes were used. The recommendation for numeric data is "-9999" and for character data is "N/A".',	"text",
                       "File_Path",	"N/A",	"File path within the data package.",	"text")

# add files to dd and edit cols and rows
dd_with_header_counts <- dd_prelim %>%
  select(Column_or_Row_Name) %>% 
  left_join(dd_v1, by = "Column_or_Row_Name") %>% 
  
  # edit cols
  select(-Term_Type) %>% 

  # edit rows
  left_join(headers, by = join_by("Column_or_Row_Name" == "header")) %>% # add header counts
  mutate(Unit = str_replace_all(Unit, "_", " ")) %>% # replace unit underscores with spaces
  mutate(Column_or_Row_Name = case_when(Column_or_Row_Name == "...287" ~ "", # replace R's default col names for empty cols
                                        T ~ Column_or_Row_Name)) %>% 
  add_row(dd_template) %>% 
  arrange(Column_or_Row_Name)


# now lets take a brief look at the flmd
flmd <- flmd_prelim %>% 
  mutate(File_Path = str_replace_all(File_Path, "v2_Chen_2024_YOLO", "YOLO_ESSDive")) %>% 
  select(File_Name, File_Path) %>%
  left_join(flmd_v1, by = c("File_Name", "File_Path")) %>%

  # edit cols
  select(-c(Date_Start, Date_End)) %>% 

  # edit rows
  mutate(File_Path = str_replace_all(File_Path, "YOLO_ESSDive", "v2_Chen_2024_YOLO")) %>% # fix file path
  
  mutate(File_Name = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "v2_Chen_2024_YOLO_flmd.csv", # rename flmd and dd
                               str_detect(File_Name, "_dd\\.csv$") ~ "v2_Chen_2024_YOLO_dd.csv",
                               T ~ File_Name)) %>% 
  mutate(File_Description = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "File-level metadata that lists and describes all of the files contained in the data package.", # add definitions for flmd, dd, and readme
                                      str_detect(File_Name, "_dd\\.csv$") ~ 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
                                      str_detect(File_Name, "readme") ~ 'Data package level readme. Contains data package summary; acknowledgements; and contact information.',
                                      T ~ File_Description)) %>% 
  add_row(File_Name = "v2_readme_Chen_2024_YOLO.pdf", # add readme row
          File_Description = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
          Standard = "N/A",
          Missing_Value_Codes = "N/A", 
          File_Path = NA_character_) %>% 
  mutate(File_Path = case_when(File_Name %in% c("v2_Chen_2024_YOLO_flmd.csv", "v2_Chen_2024_YOLO_dd.csv", "v2_readme_Chen_2024_YOLO.pdf") ~ "/v2_Chen_2024_YOLO", # update file paths
                               T ~ File_Path)) %>% 
  mutate(Missing_Value_Codes = case_when(str_detect(File_Name, "\\.(csv|tsv)$") ~ '"N/A"; "-9999"; ""; "NA"',
                                         T ~ "N/A")) %>% # add missing value codes for .csv files
  mutate(Standard = case_when(str_detect(File_Name, "_flmd\\.csv$") ~ "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", # add standard for FLMD
                              str_detect(File_Name, "\\.(csv|tsv)$") ~ "ESS-DIVE CSV v1", # add standard for .csv files
                              T ~ "N/A")) %>% 
  # sort rows by readme, flmd, dd, and then by File_Path, File_Name
  mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = F) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(-sort_order) %>% 
  select(File_Name, File_Description, Standard, Missing_Value_Codes, File_Path) 

# export
write_csv(flmd, file = "./v2_Chen_2024_YOLO/v2_Chen_2024_YOLO_flmd.csv", na = "")
write_csv(dd_with_header_counts, file = "./v2_Chen_2024_YOLO/v2_Chen_2024_YOLO_dd.csv", na = "")
  
# open folder
shell.exec("Z:/00_ESSDIVE/03_Manuscript_DPs/Chen_2024_YOLO_v2") # on windows


### update flmd and dd #########################################################

# Chen removed files from the data package and Brie reran the FLMD and DD on the
# remote. I am reading in those updated FLMD and DD files and joining it with
# the previous versions

library(tidyverse)

# FLMD - combine prelim and already populated FLMD with the new one we reran

# read in prelim
flmd_prelim <- read_csv("C:/Users/powe419/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/v2_Chen_2024_YOLO/Archive/20250626_v2_Chen_2024_YOLO_flmd.csv") %>% 
  mutate(File_Name = case_when(File_Name == "Citation Requirements.txt" ~ "Citation_Requirements.txt",
                               File_Name == "Image resolutions.txt" ~ "Image_resolutions.txt", 
                               T ~ File_Name),
         full = paste0(File_Path, "/", File_Name)) %>% 
  select(full, File_Description)

# read in flmd
flmd_rerun <- read_csv("C:/Users/powe419/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/v2_Chen_2024_YOLO/Archive/20250627_v2_Chen_2024_YOLO_flmd.csv") %>% 
  mutate(File_Path = str_replace_all(File_Path, "/WRRYOLOPaperVersion2", "/v2_Chen_2024_YOLO"))

# check on file differences
setdiff(flmd_prelim$File_Name, flmd_rerun$File_Name) # files removed - approved
setdiff(flmd_rerun$File_Name, flmd_prelim$File_Name) # files added - also approved

# combine 
flmd <- flmd_rerun %>% 
  mutate(full = paste0(File_Path, "/", File_Name)) %>% 
  rows_patch(., flmd_prelim, unmatched = "ignore")

flmd <- flmd %>% 
# edit
  # fill in all header rows with defaults
  mutate(Header_Rows = case_when(str_detect(File_Name, "\\.csv$|\\.tsv$") ~ 1, 
                                 T ~ Header_Rows),
         Column_or_Row_Name_Position = case_when(str_detect(File_Name, "\\.csv$|\\.tsv$") ~ 1, 
                                                 T ~ Column_or_Row_Name_Position)) %>% 
  # remove old dd and flmd
  filter(!File_Name %in% c("dd.csv", "flmd.csv", "readme_v2_Chen_2024_YOLO.pdf")) %>% 
  
  # add dd
  add_row(
    "File_Name" = "v2_Chen_2024_YOLO_flmd.csv",
    "File_Description" = "File-level metadata that lists and describes all of the files contained in the data package.",
    "Standard" = "ESS-DIVE FLMD v1; ESS-DIVE CSV v1",
    "Header_Rows" = 1,
    "Column_or_Row_Name_Position" = 1,
    "File_Path" = "/v2_Chen_2024_YOLO"
  ) %>% 
  
  # add flmd
  add_row(
    "File_Name" = "v2_Chen_2024_YOLO_dd.csv",
    "File_Description" = 'Data dictionary that defines column and row headers across all tabular data files (files ending in ".csv" or ".tsv") in the data package.',
    "Standard" = "ESS-DIVE FLMD v1; ESS-DIVE CSV v1", 
    "Header_Rows" = 1,
    "Column_or_Row_Name_Position" = 1,
    "File_Path" = "/v2_Chen_2024_YOLO"
  ) %>% 
  
  # add readme
  add_row(
    "File_Name" = "v2_readme_Chen_2024_YOLO.csv",
    "File_Description" = "Data package level readme. Contains data package summary; acknowledgements; and contact information.",
    "Standard" = "N/A", 
    "Header_Rows" = -9999,
    "Column_or_Row_Name_Position" = -9999,
    "File_Path" = "/v2_Chen_2024_YOLO"
  ) %>% 

  # fix order
  mutate(sort_order = case_when(grepl("readme", File_Name, ignore.case = T) ~ 1,
                                grepl("flmd.csv", File_Name, ignore.case = T) ~ 2, 
                                grepl("dd.csv", File_Name, ignore.case = T) ~ 3,
                                T ~ 4)) %>% 
  arrange(sort_order, File_Path, File_Name) %>% 
  select(c(-sort_order, -full))


# export
write_csv(flmd, "C:/Users/powe419/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/v2_Chen_2024_YOLO/v2_Chen_2024_YOLO_flmd.csv", na = "")


# DD - combine prelim and already populated DD with the new one we reran

# read in prelim
dd_prelim <- read_csv("C:/Users/powe419/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/v2_Chen_2024_YOLO/Archive/20250626_v2_Chen_2024_YOLO_dd.csv") %>% 
  select(-c(header_count, files))

# read in dd
dd_rerun <- read_csv("C:/Users/powe419/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/v2_Chen_2024_YOLO/Archive/20250627_v2_Chen_2024_YOLO_dd.csv")

# check on file differences
setdiff(dd_prelim$Column_or_Row_Name, dd_rerun$Column_or_Row_Name) # cols removed - approved
setdiff(dd_rerun$Column_or_Row_Name, dd_prelim$Column_or_Row_Name) # cols added - also approved

# combine 
dd <- dd_rerun %>% 
  rows_patch(., dd_prelim, unmatched = "ignore") %>% 

# edit
  # add term type
  mutate(Term_Type = "column_header") %>% 

  # remove rows
  filter(!Column_or_Row_Name %in% c("Date_Start", "Date_End")) %>% 
  
  # sort
  arrange(tolower(Column_or_Row_Name))

# export
write_csv(dd, "C:/Users/powe419/OneDrive - PNNL/Documents - RC-SFA/Data Management and Publishing/Data-Publishing/Manuscript-Data-Package/Files-for-review/v2_Chen_2024_YOLO/v2_Chen_2024_YOLO_dd.csv", na = "")


