# ==============================================================================
#
# make a tibble with one column of file names 
#
# ==============================================================================
#
# Author: Brieanne Forbes
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

dir <- 'Z:/00_ESSDIVE/01_Study_DPs/EWEB_Year2_Data_Package/EWEB_Year2_Data_Package/Absorbance'

# ================================ make tibble =================================

list <- list.files(dir, '.xml', recursive = T)

tibble <- tibble(File = list)%>%
  mutate(File = str_remove(File, '-.+'),
         File = str_remove(File, '\\..*'), 
         File = str_remove(File, '_DilCorr_Abs'))%>%
  distinct()

write_csv(tibble, 'C:/Users/forb086/OneDrive - PNNL/Desktop/WROL_TEMP.csv')
