# ==============================================================================
#
# Check that two folder consist of the same files
#
# Status: Complete
#
# ==============================================================================
#
# Author: Brieanne Forbes
# 9 September 2023
#
# ==============================================================================

dir <- 'Z:/RC3/00_Schneider_Springs_Fire_2023/01_FieldPhotos/01_RawData/Environmental_Context_Photos'

files <- list.files(dir, recursive = T)

dir2 <- 'C:/Brieanne/Environmental_Context_Photos'

files2 <- list.files(dir2, recursive = T)

check <- files == files2 

test <- 'FALSE' %in% check

if(test == 'FALSE'){
  
  print('Folders match')
  
} else{
  
  warning('FOLDERS DO NOT MATCH')
  
}
