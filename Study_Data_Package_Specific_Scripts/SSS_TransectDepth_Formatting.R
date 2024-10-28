# ==============================================================================
# format SSS transect depth in the Goldman format for publishing to ESS-DIVE
#
# Status: In progress. 
# ==============================================================================
#
# Author: Brieanne Forbes 
# 1 March 2023
#
# ==============================================================================

library(tidyverse)

# ================================= User inputs ================================

data <- read_csv('Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Data_Package/SSS_Data_Package/SSS_Water_Transect_Depth.csv',
                 na = c('-9999','N/A')) %>%
  select(-contains('Bank_Depth')) %>%
  rename(Transect_Two_Distance_m = Trasect_Two_Distance_m)

outfile <- 'Z:/00_Cross-SFA_ESSDIVE-Data-Package-Upload/01_Data-Package-Folders/SSS_Data_Package/SSS_Data_Package/SSS_Water_Transect_Depth_Formatted.csv'

# ================================= pivot longer ===============================

parents <- data$Parent_ID

data <- data %>%
  rename(Transect_One_Distance_m = Sensor_Distance_m, 
         Transect_Two_Distance_m = Transect_One_Distance_m, 
         Transect_Three_Distance_m = Transect_Two_Distance_m, 
         Transect_Four_Distance_m = Transect_Three_Distance_m, 
         Transect_Five_Distance_m = Transect_Four_Distance_m, 
         Transect_Six_Distance_m = Transect_Five_Distance_m, 
         Transect_Seven_Distance_m = Transect_Six_Distance_m, 
         Transect_Eight_Distance_m = Transect_Seven_Distance_m, 
         Transect_Nine_Distance_m = Transect_Eight_Distance_m, 
         Transect_Ten_Distance_m = Transect_Nine_Distance_m)

combined <- tibble(Parent_ID = as.character(),
                   Site_ID = as.character(),
                   Date = as.character(),
                   Time_Zone = as.character(),
                   Start_Time = as.character(),
                   End_Time = as.character(),
                   Notes = as.character(),
                   Transect	= as.character(),
                   Latitude	 = as.character(),
                   Longitude	 = as.character(),
                   GPS_Accuracy_ft = as.character(),
                   River_Width_m	 = as.character(),
                   Point_A_Depth_cm	 = as.character(),
                   Point_B_Depth_cm	 = as.character(),
                   Point_C_Depth_cm	 = as.character(),
                   Point_D_Depth_cm	 = as.character(),
                   Point_E_Depth_cm	 = as.character(),
                   Point_F_Depth_cm = as.character(),
                   Distance_m = as.character())

for (parent in parents) {
  
  parent_data <- data %>%
    filter(Parent_ID == parent)
  
  long_1 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
            "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_One')) %>%
    add_column(Transect = '1') %>%
    rename_with(~ gsub('Transect_One_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))
  
  long_2 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Two')) %>%
    add_column(Transect = '2') %>%
    rename_with(~ gsub('Transect_Two_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999)) %>%
    mutate(Distance_m = Distance_m + long_1$Distance_m)
  
  long_3 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Three')) %>%
    add_column(Transect = '3') %>%
    rename_with(~ gsub('Transect_Three_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_2$Distance_m)
  
  long_4 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Four')) %>%
    add_column(Transect = '4') %>%
    rename_with(~ gsub('Transect_Four_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_3$Distance_m)
  
  long_5 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Five')) %>%
    add_column(Transect = '5') %>%
    rename_with(~ gsub('Transect_Five_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_4$Distance_m)
  
  long_6 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Six')) %>%
    add_column(Transect = '6') %>%
    rename_with(~ gsub('Transect_Six_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_5$Distance_m)
  
  long_7 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Seven')) %>%
    add_column(Transect = '7') %>%
    rename_with(~ gsub('Transect_Seven_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_6$Distance_m)
  
  long_8 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Eight')) %>%
    add_column(Transect = '8') %>%
    rename_with(~ gsub('Transect_Eight_', "", .x))%>%
    mutate(Distance_m = Distance_m + long_7$Distance_m)
  
  long_9 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Nine')) %>%
    add_column(Transect = '9') %>%
    rename_with(~ gsub('Transect_Nine_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_8$Distance_m)
  
  long_10 <- parent_data %>%
    select("Parent_ID","Site_ID","Date","Time_Zone",
           "Start_Time","End_Time","GPS_Accuracy_ft","Notes",contains('Transect_Ten')) %>%
    add_column(Transect = '10') %>%
    rename_with(~ gsub('Transect_Ten_', "", .x)) %>%
    add_column(Point_F_Depth_cm = as.numeric(-9999))%>%
    mutate(Distance_m = Distance_m + long_9$Distance_m)
  
  all_long <- long_1 %>%
    add_row(long_2)%>%
    add_row(long_3)%>%
    add_row(long_4)%>%
    add_row(long_5)%>%
    add_row(long_6)%>%
    add_row(long_7)%>%
    add_row(long_8)%>%
    add_row(long_9)%>%
    add_row(long_10) %>%
    mutate(across(everything(), as.character))
  
  combined <- combined %>%
    add_row(all_long)
  
}

outdata <- combined %>%
  select(-Latitude, -Longitude, -GPS_Accuracy_ft) %>%
  rename(Distance_to_Sensor_m = Distance_m)

write_csv(outdata, outfile)
