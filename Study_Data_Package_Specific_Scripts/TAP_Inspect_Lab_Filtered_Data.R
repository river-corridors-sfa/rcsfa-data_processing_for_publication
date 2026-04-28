# Load required libraries
library(tidyverse)
library(readr)

# Read the field metadata file
field_metadata <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Field_Metadata.csv") 

# Clean up the water data column names and remove any extra rows
water_data <- read_csv("Z:/00_ESSDIVE/01_Study_DPs/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Data_Package/WHONDRS_TAP_Sample_Data/WHONDRS_TAP_Water_Sample_Data_Summary.csv", 
                       skip = 2,
                       na = c( '', '-9999', 'N/A', 'NA')
)  %>%
  filter(!is.na(Sample_Name)) %>%
  select(-Field_Name) %>%# Remove the first column as it's not needed
  mutate(across(c(`00940_Cl_mg_per_L`, `71856_NO2_mg_per_L_as_NO2`, 
                  `00945_SO4_mg_per_L_as_SO4`, `71851_NO3_mg_per_L_as_NO3`, 
                  `Mean_00681_NPOC_mg_per_L_as_C`, `Mean_00602_TN_mg_per_L_as_N`), 
                as.numeric))

# Combine the datasets by matching sample IDs
# Extract Parent_ID from field metadata and Sample_Name from water data
combined_data <- field_metadata %>%
  left_join(water_data, by = c("Parent_ID" = "Sample_Name"))

# Create a flag for lab-filtered samples
# Check if "filtered in the lab" appears in the Notes column
combined_data <- combined_data %>%
  mutate(
    lab_filtered = case_when(
      str_detect(tolower(Notes), "filtered") ~ "Lab Filtered",
      TRUE ~ "Not Lab Filtered"
    )
  ) %>%
  select(Parent_ID, '00940_Cl_mg_per_L', "71856_NO2_mg_per_L_as_NO2" ,
         "00945_SO4_mg_per_L_as_SO4", "71851_NO3_mg_per_L_as_NO3", 
         "Mean_00681_NPOC_mg_per_L_as_C", "Mean_00602_TN_mg_per_L_as_N",
         lab_filtered)

# Create the figure
library(ggplot2)
library(patchwork)

# Create plots for all ion concentrations
# Chloride plot
p1 <- ggplot(combined_data, aes(x = reorder(Parent_ID, `00940_Cl_mg_per_L`), 
                                y = `00940_Cl_mg_per_L`,
                                color = lab_filtered)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "Chloride Concentrations",
       x = "Sample ID",
       y = "Cl⁻ (mg/L)",
       color = "Filtration Status") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6)) +
  scale_color_manual(values = c("Not Lab Filtered" = "blue", "Lab Filtered" = "red")) +
  scale_y_log10()

# Nitrite plot
p2 <- ggplot(combined_data, aes(x = reorder(Parent_ID, `71856_NO2_mg_per_L_as_NO2`), 
                                y = `71856_NO2_mg_per_L_as_NO2`,
                                color = lab_filtered)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "Nitrite Concentrations",
       x = "Sample ID",
       y = "NO₂⁻ (mg/L as NO₂)",
       color = "Filtration Status") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6)) +
  scale_color_manual(values = c("Not Lab Filtered" = "blue", "Lab Filtered" = "red"))

# Sulfate plot
p3 <- ggplot(combined_data, aes(x = reorder(Parent_ID, `00945_SO4_mg_per_L_as_SO4`), 
                                y = `00945_SO4_mg_per_L_as_SO4`,
                                color = lab_filtered)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "Sulfate Concentrations",
       x = "Sample ID",
       y = "SO₄²⁻ (mg/L as SO₄)",
       color = "Filtration Status") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6)) +
  scale_color_manual(values = c("Not Lab Filtered" = "blue", "Lab Filtered" = "red")) +
  scale_y_log10()

# Nitrate plot
p4 <- ggplot(combined_data, aes(x = reorder(Parent_ID, `71851_NO3_mg_per_L_as_NO3`), 
                                y = `71851_NO3_mg_per_L_as_NO3`,
                                color = lab_filtered)) +
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "Nitrate Concentrations",
       x = "Sample ID",
       y = "NO₃⁻ (mg/L as NO₃)",
       color = "Filtration Status") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 6)) +
  scale_color_manual(values = c("Not Lab Filtered" = "blue", "Lab Filtered" = "red"))

# Combine all ion plots
ion_plots <- (p1 | p2) / (p3 | p4) + 
  plot_layout(guides = "collect") +
  plot_annotation(title = "Ion Concentrations with Lab Filtration Status")

# Display the plot
print(ion_plots)

# Optional: Create a summary table of lab-filtered samples
lab_filtered_summary <- combined_data %>%
  filter(lab_filtered == "Lab Filtered") %>%
  select(Parent_ID, Contact_Name, Organization, Site_Name, Country, Notes)

print("Lab-filtered samples:")
print(lab_filtered_summary)

# Save the plot
ggsave("water_quality_with_filtration_status.png", combined_plot, 
       width = 12, height = 10, dpi = 300)