

# Load packages
library(tidyverse)
library(stringr)
library(patchwork) 

# ---- 1) Read & clean ---------------------------------------------------------
# Use forward slashes for Windows network path (simplest),
# or replace with "Z:\\00_ESSDIVE\\01_Study_DPs\\PRT_Data_Package\\PRT_Data_Package\\PRT_Sample_Data\\PRT_Water_Isotopes.csv"
csv_path <- "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package/PRT_Data_Package/PRT_Sample_Data/PRT_Water_Isotopes.csv"

# The file contains commented metadata lines starting with '#'.
# readr::read_csv(..., comment = "#") skips those rows.
dat_raw <- readr::read_csv(
  csv_path,
  skip = 2,
  show_col_types = FALSE,
  na = c('N/A', "NA", '-9999', '')
) %>% 
  filter(str_detect(Sample_Name, 'PRT2'))%>%
  mutate(
    rep     = str_to_lower(str_extract(Sample_Name, "[abcABC]$")),
    base_id = str_remove(Sample_Name, "(?i)[abc]$"),
    del_2H_per_mil = as.numeric(del_2H_per_mil),
    del_18O_per_mil = as.numeric(del_18O_per_mil)
  )


summarize <-  dat_raw %>%
  group_by(base_id) %>%
  summarise(mean_del_2H_per_mil = mean(del_2H_per_mil, na.rm = T),
            min_del_2H_per_mil = min(del_2H_per_mil, na.rm = T),
            max_del_2H_per_mil = max(del_2H_per_mil, na.rm = T),
            mean_del_18O_per_mil = mean(del_18O_per_mil, na.rm = T),
            min_del_18O_per_mil = min(del_18O_per_mil, na.rm = T),
            max_del_18O_per_mil = max(del_18O_per_mil, na.rm = T)) %>%
  filter(!is.na(mean_del_2H_per_mil))


# --- δ2H figure: mean with min–max range per base_id --------------------------
p_d2H <- ggplot(
  summarize,
  aes(x = base_id, y = mean_del_2H_per_mil)
) +
  geom_linerange(
    aes(ymin = min_del_2H_per_mil, ymax = max_del_2H_per_mil),
    linewidth = 0.7,
    color = "#2C7FB8"
  ) +
  geom_point(size = 2.2, color = "#084081") +
  labs(
    title = expression(paste("Replicate spread (a/b/c): ", delta^2, "H")),
    x = "Sample group (base_id)",
    y = expression(paste("Mean ", delta^2, "H (‰) with min–max range"))
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )

# --- δ18O figure: mean with min–max range per base_id -------------------------
p_d18O <- ggplot(
  summarize,
  aes(x = base_id, y = mean_del_18O_per_mil)
) +
  geom_linerange(
    aes(ymin = min_del_18O_per_mil, ymax = max_del_18O_per_mil),
    linewidth = 0.7,
    color = "#41AB5D"
  ) +
  geom_point(size = 2.2, color = "#005A32") +
  labs(
    title = expression(paste("Replicate spread (a/b/c): ", delta^18, "O")),
    x = "Sample group (base_id)",
    y = expression(paste("Mean ", delta^18, "O (‰) with min–max range"))
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major.x = element_blank()
  )

# Print plots
print(p_d2H)
print(p_d18O)

# Combine the plots vertically
combined_plot <- p_d2H / p_d18O


# Alternative: Save as PDF
ggsave(
  filename = "Z:/00_ESSDIVE/01_Study_DPs/PRT_Data_Package/isotope_replicate_spread.pdf",
  plot = combined_plot,
  width = 12,
  height = 10,
  bg = "white"
)
