### Chen_2024_YOLO_v2_DP_Prep.R ################################################
# Author: Bibi Powers-McCormack
# Date Created: 2025-03-27
# Date Updated: 2025-04-03

# Objective: 


### create flmd and dd #########################################################
#Brie is running the flmd and dd skeletons on the remote computers and saving
#the outputs into the secret folder archive. This script takes those prelim
#files and combines it with v1 to produce the actual v2 flmd and dds.

# the goal is now to combine the old definitions from v1 into the new prelim files.

# load libraries
library(tidyverse)

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
dd_prelim %>% 
  select(Column_or_Row_Name) %>% 
  left_join(dd_v1, by = "Column_or_Row_Name") %>% 
  
  # edit cols
  select(-Term_Type) %>% 

  # edit rows
  mutate(Column_or_Row_Name = case_when(Column_or_Row_Name == "...287" ~ "",
                                        T ~ Column_or_Row_Name)) %>% 
  View()

# now lets take a brief look at the flmd
flmd_prelim %>% 
  mutate(File_Path = str_replace_all(File_Path, "v2_Chen_2024_YOLO", "YOLO_ESSDive")) %>% 
  select(File_Name, File_Path) %>%
  left_join(flmd_v1, by = c("File_Name", "File_Path")) %>%

  # edit cols
  select(-c(Date_Start, Date_End)) %>% 

  # edit rows
  mutate(File_Path = str_replace_all(File_Path, "YOLO_ESSDive", "v2_Chen_2024_YOLO")) %>% 


  View()
  
flmd_v1 %>% 
  select(File_Name) %>% 
  anti_join(flmd_prelim, by = "File_Name") %>% 
  View()





