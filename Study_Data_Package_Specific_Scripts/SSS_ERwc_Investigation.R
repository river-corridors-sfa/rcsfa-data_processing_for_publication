
minidot_files_dir <- 'C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/03_MinidotManualChamber2hr/05_PublishReadyData'

minidot_files <- list.files(minidot_files_dir, '.csv', recursive = F, full.names = T)

combined <- tibble(site = as.character(),
                   Slope_1_Minutes = as.character(),
                   Slope_1_Unix = as.character(),
                   Slope_2_Minutes = as.character(),
                   Slope_2_Unix = as.character(),
                   Slope_3_Minutes = as.character(),
                   Slope_3_Unix = as.character(),
                   Slope_1_Days = as.character(),
                   Slope_2_Days = as.character(),
                   Slope_3_Days = as.character())

for (minidot_file in minidot_files) {
  
  data <- read_csv(minidot_file, comment = '#', na = c(NA, '-9999', 'N/A')) %>%  
    mutate(elapsed_minutes = as.numeric(DateTime - min(DateTime), units = "mins"),
           unix = as.numeric(DateTime),
           elapsed_days = as.numeric(DateTime - min(DateTime), units = "days"))
  
  data_reduced <- data %>%
    select(elapsed_minutes, Dissolved_Oxygen_1, Dissolved_Oxygen_2, Dissolved_Oxygen_3)
  
  # Reshape the dataframe into long format
  df_long <- data_reduced %>%  gather(key = "Measurement", value = "Dissolved_Oxygen", -elapsed_minutes)
  # Plot the scatter plot
  plot <- ggplot(df_long, aes(x = elapsed_minutes, y = Dissolved_Oxygen, color = Measurement)) +  
    geom_point() +  labs(x = "Elapsed Minutes", y = "Dissolved Oxygen") +  
    scale_color_manual(values = c("Dissolved_Oxygen_1" = "red", "Dissolved_Oxygen_2" = "blue", "Dissolved_Oxygen_3" = "green"))
  

  lm_1 <- lm(data$Dissolved_Oxygen_1~data$elapsed_minutes)

  slope_1 <- format(summary(lm_1)$coefficients[2], digits=2)
  
  lm_2 <- lm(data$Dissolved_Oxygen_2~data$elapsed_minutes)
  
  slope_2 <- format(summary(lm_2)$coefficients[2], digits=2)
  
  
  day_lm_1 <- lm(data$Dissolved_Oxygen_1~data$elapsed_days)
  
  day_slope_1 <- format(summary(day_lm_1)$coefficients[2], digits=2)
  
  day_lm_2 <- lm(data$Dissolved_Oxygen_2~data$elapsed_days)
  
  day_slope_2 <- format(summary(day_lm_2)$coefficients[2], digits=2)

  

  bad_lm_1 <- lm(data$Dissolved_Oxygen_1~data$unix)

  bad_slope_1 <- format(summary(bad_lm_1)$coefficients[2], digits=2)
  
  bad_lm_2 <- lm(data$Dissolved_Oxygen_2~data$unix)
  
  bad_slope_2 <- format(summary(bad_lm_2)$coefficients[2], digits=2)
  
  if('Dissolved_Oxygen_3' %in% colnames(data)){
  
  lm_3 <- lm(data$Dissolved_Oxygen_3~data$elapsed_minutes)
  
  slope_3 <- format(summary(lm_3)$coefficients[2], digits=2)
  
  day_lm_3 <- lm(data$Dissolved_Oxygen_3~data$elapsed_days)
  
  day_slope_3 <- format(summary(day_lm_3)$coefficients[2], digits=2)
  
  bad_lm_3 <- lm(data$Dissolved_Oxygen_3~data$unix)
  
  bad_slope_3 <- format(summary(bad_lm_3)$coefficients[2], digits=2)
  
  } else {
    
    lm_3 <- NA
    
    slope_3 <- NA
    
    bad_lm_3 <- NA
    
    bad_slope_3 <- NA
    
    day_slope_3 <- NA
    
    
  }

  row <- tibble(site = unique(data$Site_ID),
                Slope_1_Minutes = slope_1,
                Slope_1_Unix = bad_slope_1,
                Slope_2_Minutes = slope_2,
                Slope_2_Unix = bad_slope_2,
                Slope_3_Minutes = slope_3,
                Slope_3_Unix = bad_slope_3,
                Slope_1_Days = day_slope_1,
                Slope_2_Days = day_slope_2,
                Slope_3_Days = day_slope_3
                )

  combined <- combined %>%
    add_row(row)
  
}

format <- combined %>%
  mutate(Slope_1_Minutes_to_Day = as.numeric(Slope_1_Minutes) * 24 * 60,
         Slope_1_Unix_to_Day = as.numeric(Slope_1_Unix) * 60*60*24,
         Slope_2_Minutes_to_Day = as.numeric(Slope_2_Minutes) * 24 * 60,
         Slope_2_Unix_to_Day = as.numeric(Slope_2_Unix) * 60*60*24,
         Slope_3_Minutes_to_Day = as.numeric(Slope_3_Minutes) * 24 * 60,
         Slope_3_Unix_to_Day = as.numeric(Slope_3_Unix) * 60*60*24,
         Slope_1_Days = as.numeric(Slope_1_Days),
         Slope_2_Days = as.numeric(Slope_2_Days),
         Slope_3_Days = as.numeric(Slope_3_Days)) %>%
  mutate(ERwc_Minutes_to_Day = rowMeans(select(.,contains("Minutes_to_Day")),na.rm=T),
         ERwc_Unix_to_Day = rowMeans(select(.,contains("Unix_to_Day")),na.rm=T),
         ERwc_Day_to_Day = rowMeans(select(.,contains("_Days")),na.rm=T))%>%
  mutate(site = case_when(site == 'S63P' ~ 'S63',
                          site == 'S55' ~ 'S55N',
                          site == 'S56' ~ 'S56N',
                          site == 'T41' ~ 'T42',
                             TRUE ~ site))

depth <- read_csv('C:/Brieanne/GitHub/SSS_metabolism/Published_Data/v2_SSS_Data_Package/v2_SSS_Water_Depth_Summary.csv', comment = '#', na = '-9999') %>%
  select(Site_ID, Average_Depth)

ERwc <- format %>%
  select(site, ERwc_Minutes_to_Day, ERwc_Unix_to_Day) %>%
  left_join(depth, by = c('site' = 'Site_ID')) %>%
  mutate(depth_m = Average_Depth/100,
         ERwc_g_per_m2_per_day_FromMinutes = ERwc_Minutes_to_Day * depth_m,
         ERwc_g_per_m2_per_day_FromUnix = ERwc_Unix_to_Day * depth_m) %>%
  rename(Site_ID = site) 

ERtot_file <- 'C:/Brieanne/GitHub/SSS_metabolism/v2_SSS_Water_Sediment_Total_Respiration_GPP.csv'

ERtot <- read_csv(ERtot_file, comment = '#', na = c(NA, '-9999', 'N/A')) %>%
  select(Site_ID, Total_Ecosystem_Respiration_Square, Sediment_Respiration_Square, Gross_Primary_Production_Square)

join_wc_tot <- ERtot %>%
  full_join(ERwc) %>%
  select(Site_ID, Total_Ecosystem_Respiration_Square, ERwc_g_per_m2_per_day_FromMinutes) %>%
  mutate(ERSed_recalculate = Total_Ecosystem_Respiration_Square - ERwc_g_per_m2_per_day_FromMinutes)

melt_wc_tot <- melt(join_wc_tot) %>%
  filter(!is.na(value))

histo <- ggplot(melt_wc_tot %>% filter(variable == 'ERwc_g_per_m2_per_day_FromMinutes'), aes(x = value, fill = variable)) +  
  geom_histogram(binwidth = 0.5, alpha = 0.5) +  
  scale_fill_manual(values = c("blue", "red", 'purple')) +  labs(title = "SSS Histogram", x = "ERwc_g_per_m2_per_day")+
  geom_vline(xintercept = 0) +
  theme(legend.position = 'none')

density <- ggplot(melt_wc_tot %>% filter(variable == 'ERwc_g_per_m2_per_day_FromMinutes'), aes(x = value, fill = variable)) +  
  geom_density(alpha = 0.5) +  
  scale_fill_manual(values = c("blue", "red", 'purple')) +  labs(title = "SSS Density", x = "ERwc_g_per_m2_per_day")+
  geom_vline(xintercept = 0) +
  theme(legend.position = 'none')

# ================================================


summary <- read_csv("C:/Users/forb086/OneDrive - PNNL/Spatial Study 2022/03_MinidotManualChamber2hr/03_ProcessedData/MinidotManualChamber_Summary_Statistics.csv", comment = '#', na = c('NA', 'N/A', '-9999')) %>%
  mutate(DO_Slope_Corrected_1_perday = as.numeric(Dissolved_Oxygen_1_Slope) * 60*60*24,
         DO_Slope_Corrected_2_perday = as.numeric(Dissolved_Oxygen_2_Slope) * 60*60*24,
         DO_Slope_Corrected_3_perday = as.numeric(Dissolved_Oxygen_3_Slope) * 60*60*24) %>%
  mutate(ERwc_Corrected_g_per_m3_perday = rowMeans(select(.,contains("DO_Slope_Corrected")),na.rm=T))

depth <- read_csv('C:/Brieanne/GitHub/SSS_metabolism/Published_Data/v2_SSS_Data_Package/v2_SSS_Water_Depth_Summary.csv', comment = '#', na = '-9999') %>%
  select(Site_ID, Average_Depth)

ERwc_from_summary <- summary %>%
  select(Site_ID, ERwc_Corrected_g_per_m3_perday) %>%
  left_join(depth) %>%
  mutate(depth_m = Average_Depth/100,
         ERwc_Corrected_g_per_m2_perday = ERwc_Corrected_g_per_m3_perday * depth_m)

join_summary_wc_tot <- ERtot %>%
  full_join(ERwc_from_summary) %>%
  select(Site_ID, Total_Ecosystem_Respiration_Square, ERwc_Corrected_g_per_m2_perday, Gross_Primary_Production_Square) 


melt_summary <- melt(join_summary_wc_tot)

histo <- ggplot(melt_summary , aes(x = value, fill = variable)) +  
  geom_histogram(binwidth = 0.5, alpha = 0.5) +  
  scale_fill_manual(values = c("blue", "red", 'purple')) +  labs(title = "SSS Histogram", x = "Respiration (g_per_m2_per_day)")+
  geom_vline(xintercept = 0) 

density <- ggplot(melt_summary, aes(x = value, fill = variable)) +  
  geom_density(alpha = 0.5) +  
  scale_fill_manual(values = c("blue", "red", 'purple')) +  labs(title = "SSS Density", x = "Respiration (g_per_m2_per_day)")+
  geom_vline(xintercept = 0) 

scatter <- ggplot(join_summary_wc_tot %>% filter(Total_Ecosystem_Respiration_Square<0), aes(x=Total_Ecosystem_Respiration_Square, y = ERwc_Corrected_g_per_m2_perday)) +
  geom_point()+
  geom_abline(slope = 1, intercept = 0)



ERsed_tot_wc <- join_summary_wc_tot %>% 
  filter(Total_Ecosystem_Respiration_Square<0) %>%
  mutate(ERwc_Corrected_g_per_m2_perday = case_when(ERwc_Corrected_g_per_m2_perday > 0 ~ 0,
                                                    TRUE ~ ERwc_Corrected_g_per_m2_perday),
    ERsed = Total_Ecosystem_Respiration_Square - ERwc_Corrected_g_per_m2_perday,
         ERsed_contribution = ERsed/Total_Ecosystem_Respiration_Square)

hist_contrib <- hist(ERsed_tot_wc$contribution, breaks = 10)

scatter_ERsed_contrib <- plot(ERsed_tot_wc$ERsed_contribution ~ ERsed_tot_wc$Total_Ecosystem_Respiration_Square)

scatter_ERsed_GPP<- plot(ERsed_tot_wc$ERsed ~ ERsed_tot_wc$Gross_Primary_Production_Square)

summary(lm(ERsed_tot_wc$ERsed ~ ERsed_tot_wc$Gross_Primary_Production_Square))

melt_all <- melt(ERsed_tot_wc)

histo_all <- ggplot(melt_all , aes(x = value, fill = variable)) +  
  geom_histogram(binwidth = 0.5, alpha = 0.5) +  
  scale_fill_manual(values = c("blue", "red", 'purple')) +  labs(title = "SSS Histogram", x = "Respiration (g_per_m2_per_day)")+
  geom_vline(xintercept = 0) 

density_all <- ggplot(melt_all, aes(x = value, fill = variable)) +  
  geom_density(alpha = 0.5) +  
  scale_fill_manual(values = c("blue", "red", 'purple')) +  labs(title = "SSS Density", x = "Respiration (g_per_m2_per_day)")+
  geom_vline(xintercept = 0) 

scatter_tot_sed <- ggplot(ERsed_tot_wc, aes(x=Total_Ecosystem_Respiration_Square, y = ERsed)) +
  geom_point()+
  geom_abline(slope = 1, intercept = 0)

scatter_wc_depth <- ggplot(ERwc_from_summary, aes(x=ERwc_Corrected_g_per_m2_perday, y = depth_m)) +
  geom_point()

write_csv(ERsed_tot_wc, 'C:/Brieanne/GitHub/SSS_metabolism/Temp/SSS_Preliminary_ERwc_sed_tot.csv')




