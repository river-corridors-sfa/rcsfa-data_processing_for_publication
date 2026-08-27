# ==============================================================================
#
# Format PRT sensor data for publishing 
# 
# Status: In progress
#
# =============================================================================
#
# Author: Brieanne Forbes
# 19 August 2026

rm(list=ls(all=T))

library(tidyverse)
library(readxl)
library(qpdf)

# =============================== user inputs ================================

exo_folder <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/EXO'

headers_dir <- "C:/Users/forb086/OneDrive - PNNL/Core Richland and Sequim Lab-Field Team - Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Sensor_Header_Rows.xlsx"

inst_methods_dir <- "C:/Users/forb086/OneDrive - PNNL/Core Richland and Sequim Lab-Field Team - Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Installation_Methods.xlsx"

# =============================== find files ================================

setwd(exo_folder)

l1_files <- list.files('./03_ProcessedData_L1', 'csv', full.names = T) %>%
  str_subset("M01", negate = TRUE) # not publishing M01 in v2 of data package

l2_files <- "C:/Brieanne/GitHub/rcsfa-sensor-processing/Study_Specific_Sensor_Processing/PRT_EXO_L2/data/04_L2_manual_qc_cleaned.csv"

# ========================== read headers ======================================
headers <- read_xlsx(headers_dir, sheet = 'PRT') %>%
  mutate(InstallationMethod_ID = trimws(InstallationMethod_ID))  

inst_methods <- read_xlsx(inst_methods_dir)%>%
  filter(InstallationMethod_ID %in% headers$InstallationMethod_ID)

# ================================== L1 EXO =====================================

for (l1 in l1_files) {
  
  l1_data <- read_csv(l1, col_types = cols(.default = col_character())) %>%
    rename_with(
      ~ .x %>%
        str_remove("^Mean5sec_") %>%
        str_replace("^Stdev5sec_", "Stdev_")%>%
        str_remove("_YSI")%>%
        str_remove("_Calculated")
    ) %>%
    relocate(
      Dissolved_Oxygen_Saturation,
      Stdev_Dissolved_Oxygen_Saturation,
      .after = Stdev_Dissolved_Oxygen
    )%>%
    relocate(
      Out_of_Bounds,
      .after = n_burst
    )%>%
    mutate(DateTime = paste0(" ", as.character(DateTime)))
  
  columns <- colnames(l1_data)
  
  filtered_headers <- headers %>%
    filter(Sensor == 'exo' &Column_Header %in% columns)%>%
    arrange(match(Column_Header, columns)) %>%
    mutate(Instrument_Summary = str_replace(Instrument_Summary, "//.{1,}$", ""),
           header = paste0('# ', Column_Header,"; ", Unit, "; ", InstallationMethod_ID, "; ",Instrument_Summary, ".")) %>%
    select(header)


  data_headers <- tibble(header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary') %>%
    add_row(filtered_headers)

  n_rows <- nrow(data_headers) + 2

  data_headers <- data_headers %>%
    add_row(header = paste0('# HeaderRows_', n_rows),
            .before = 1)
  
  new_name <- l1 %>% str_replace('03_ProcessedData_L1', '05_PublishReadyData')%>% str_replace('L1_PRT', 'L1_PRT_Water')
  
  # write out headers
  write_csv(data_headers, new_name, col_names = F)
  
  # pause for 2 seconds in case it's trying to append before the headers are written out
  Sys.sleep(2)
  
  # write out data
  write_csv(l1_data, new_name, col_names = T, append = T)
  
}


# ================================== L2 EXO =====================================
# Flag-column names and corresponding output prefixes
flag_names <- c(
  f_Temp_C               = "Temp",
  f_SpCond_uScm          = "SpC",
  f_DO_mgl               = "DO",
  f_DO_percent_sat       = "DOsat",
  f_pH                   = "pH",
  f_Turbidity_FNU        = "Turb",
  f_fDOM_QSU_uncorrected = "fDOM",
  f_Depth_ft             = "Depth"
)

# Out-of-bounds measurement names and corresponding output prefixes
out_of_bounds_names <- c(
  Mean5sec_Temperature                             = "Temp",
  Mean5sec_Specific_Conductance                    = "SpC",
  Mean5sec_Dissolved_Oxygen_YSI                    = "DO",
  Mean5sec_Dissolved_Oxygen_Saturation_YSI         = "DOsat",
  Mean5sec_Dissolved_Oxygen_Saturation_Calculated  = "DOsat",
  Mean5sec_pH                                      = "pH",
  Mean5sec_Turbidity                               = "Turb",
  Mean5sec_fDOM_QSU                                = "fDOM",
  Mean5sec_fDOM_RFU                                = "fDOM",
  Mean5sec_Depth                                   = "Depth",
  Mean5sec_Battery                                 = "Battery",
  n_burst                                          = "Burst"
)

# Read and prepare L2 data
l2_data <- read_csv(l2_files) %>%
  mutate(
    row_id = row_number(),
    
    # Apply the DO concentration flag to DO saturation
    f_DO_percent_sat = f_DO_mgl,
    
    # Remove DO saturation values when DO is flagged
    DO_percent_sat = case_when(
      !is.na(f_DO_percent_sat) &
        !f_DO_percent_sat %in% c("", "N/A") ~ NA_real_,
      TRUE ~ DO_percent_sat
    )
  ) %>%
  filter(
    Site_ID != "M01"
  ) # Not publishing M01 in this update


# Convert existing flag columns -------------------------------------------

existing_flags <- l2_data %>%
  select(
    row_id,
    all_of(names(flag_names))
  ) %>%
  pivot_longer(
    cols = -row_id,
    names_to = "flag_col",
    values_to = "flag_value"
  ) %>%
  filter(
    !is.na(flag_value),
    !flag_value %in% c("", "N/A")
  ) %>%
  mutate(
    flag_prefix = unname(flag_names[flag_col]),
    
    # Split cells containing multiple flags
    flag_value = str_split(
      flag_value,
      "\\s*[,;]\\s*"
    )
  ) %>%
  unnest_longer(flag_value) %>%
  mutate(
    flag_value = str_trim(flag_value),
    
    # Remove an existing measurement prefix, if present
    flag_value = str_remove(
      flag_value,
      paste0("^", flag_prefix, "_")
    ),
    
    # Remove an existing version suffix, if present
    flag_value = str_remove(
      flag_value,
      "_01$"
    ),
    
    # Standardize "Other" as the general QC flag
    flag_value = if_else(
      flag_value == "Other",
      "QC",
      flag_value
    )
  ) %>%
  filter(
    !is.na(flag_value),
    !flag_value %in% c("", "N/A")
  ) %>%
  mutate(
    Flag = paste0(
      flag_prefix,
      "_",
      flag_value,
      "_01"
    )
  ) %>%
  select(
    row_id,
    Flag
  )


# Convert Out_of_Bounds values to flags ----------------------------------

out_of_bounds_long <- l2_data %>%
  select(
    row_id,
    Out_of_Bounds
  ) %>%
  filter(
    !is.na(Out_of_Bounds),
    !Out_of_Bounds %in% c("", "N/A")
  ) %>%
  mutate(
    Out_of_Bounds = str_split(
      Out_of_Bounds,
      "\\s*[,;]\\s*"
    )
  ) %>%
  unnest_longer(Out_of_Bounds) %>%
  mutate(
    Out_of_Bounds = str_trim(Out_of_Bounds)
  ) %>%
  filter(
    Out_of_Bounds != ""
  )

# Warn about Out_of_Bounds values that do not have a mapping
unknown_out_of_bounds <- out_of_bounds_long %>%
  filter(
    !Out_of_Bounds %in% names(out_of_bounds_names)
  ) %>%
  distinct(Out_of_Bounds) %>%
  pull(Out_of_Bounds)

if (length(unknown_out_of_bounds) > 0) {
  warning(
    "The following Out_of_Bounds values do not have flag mappings: ",
    paste(unknown_out_of_bounds, collapse = ", "),
    call. = FALSE
  )
}

out_of_bounds_flags <- out_of_bounds_long %>%
  mutate(
    flag_code = unname(
      out_of_bounds_names[Out_of_Bounds]
    )
  ) %>%
  filter(
    !is.na(flag_code)
  ) %>%
  mutate(
    Flag = paste0(
      flag_code,
      "_OOB_01"
    )
  ) %>%
  select(
    row_id,
    Flag
  )


# Combine flags for each row ---------------------------------------------

flags <- bind_rows(
  existing_flags,
  out_of_bounds_flags
) %>%
  distinct(
    row_id,
    Flag
  ) %>%
  summarise(
    Flag = paste(
      Flag,
      collapse = "; "
    ),
    .by = row_id
  )


# Format final L2 data ---------------------------------------------------

l2_data_formatted <- l2_data %>%
  left_join(
    flags,
    by = "row_id"
  ) %>%
  select(
    -row_id,
    -starts_with("f_"),
    -Notes,
    -Out_of_Bounds
  ) %>%
  rename(
    Temperature                 = Temp_C,
    Specific_Conductance        = SpCond_uScm,
    Dissolved_Oxygen            = DO_mgl,
    Dissolved_Oxygen_Saturation = DO_percent_sat,
    Turbidity                   = Turbidity_FNU,
    fDOM_QSU                    = fDOM_QSU_uncorrected,
    Depth                       = Depth_ft
  ) %>%
  mutate(
    across(
      where(is.character),
      ~ replace_na(.x, "N/A")
    ),
    across(
      where(is.numeric),
      ~ replace_na(.x, -9999)
    ),
    DateTime = format(
      as_datetime(DateTime),
      "%Y-%m-%d %H:%M:%S"
    )
  )

# output by calendar year for each site
write_l2_file <- function(df, headers, output_dir = "./05_PublishReadyData") {
  
  site <- unique(df$Site_ID)
  yr   <- unique(df$Year)
  
  output_data <- df %>%
    select(-Year)
  
  columns <- colnames(output_data)
  
  filtered_headers <- headers %>%
    filter(
      Sensor == "exo",
      Column_Header %in% columns
    ) %>%
    arrange(match(Column_Header, columns)) %>%
    mutate(
      Instrument_Summary = str_replace(
        Instrument_Summary,
        "//.{1,}$",
        ""
      ),
      header = paste0(
        "# ", Column_Header, "; ",
        Unit, "; ",
        InstallationMethod_ID, "; ",
        Instrument_Summary, "."
      )
    ) %>%
    select(header)
  
  data_headers <- bind_rows(
    tibble(
      header = "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary"
    ),
    filtered_headers
  )
  
  n_rows <- nrow(data_headers) + 2
  
  data_headers <- bind_rows(
    tibble(header = paste0("# HeaderRows_", n_rows)),
    data_headers
  )
  
  output_file <- file.path(
    output_dir,
    paste0("L2_PRT_Water_", site, "_", yr, "_EXO.csv")
  )
  
  write_csv(
    data_headers,
    output_file,
    col_names = FALSE
  )
  
  write_csv(
    output_data,
    output_file,
    col_names = TRUE,
    append = TRUE
  )
}


l2_data_formatted %>%
  mutate(Year = year(DateTime)) %>%
  group_by(Site_ID, Year) %>%
  group_split() %>%
  walk(~ write_l2_file(.x, headers))

## ================================== L2 EXO summary =====================================
sensor_monthly_summary <- function(data) {
  
  measurement_columns <- data %>%
    select(
      -any_of(c(
        "Site_ID",
        "DateTime",
        "Flag",
        "Out_of_Bounds"
      ))
    ) %>%
    select(where(is.numeric)) %>%
    colnames()
  
  summary_column_order <- sort(measurement_columns) %>%
    map(
      ~ paste0(
        c(
          "Mean_",
          "Median_",
          "Min_",
          "Max_",
          "Percent_Points_Removed_"
        ),
        .x
      )
    ) %>%
    unlist(use.names = FALSE)
  
  summary_long <- data %>%
    mutate(
      DateTime = as_datetime(DateTime),
      Month = floor_date(DateTime, unit = "month"),
      across(
        where(is.numeric),
        ~ na_if(.x, -9999)
      )
    ) %>%
    pivot_longer(
      cols = all_of(measurement_columns),
      names_to = "Measurement",
      values_to = "Value"
    ) %>%
    group_by(Site_ID, Month, Measurement) %>%
    summarise(
      DateTime_Start = min(DateTime, na.rm = TRUE),
      DateTime_End   = max(DateTime, na.rm = TRUE),
      Mean           = round(mean(Value, na.rm = TRUE), 3),
      Median         = round(median(Value, na.rm = TRUE), 3),
      Min            = round(min(Value, na.rm = TRUE), 3),
      Max            = round(max(Value, na.rm = TRUE), 3),
      Percent_Points_Removed = round(
        100 * sum(is.na(Value)) / n(),
        2
      ),
      .groups = "drop"
    )
  
  summary_wide <- summary_long %>%
    pivot_wider(
      names_from = Measurement,
      values_from = c(Mean, Median, Min, Max, Percent_Points_Removed),
      names_glue = "{.value}_{Measurement}"
    ) %>%
    mutate(
      across(
        where(is.numeric),
        ~ case_when(
          is.na(.x) | is.nan(.x) | is.infinite(.x) ~ -9999,
          TRUE ~ .x
        )
      ),
      DateTime_Start = paste0(
        " ",
        format(
          as_datetime(DateTime_Start),
          "%Y-%m-%d %H:%M:%S"
        )
      ),
      DateTime_End = paste0(
        " ",
        format(
          as_datetime(DateTime_End),
          "%Y-%m-%d %H:%M:%S"
        )
      )
    ) %>%
    arrange(Site_ID, Month) %>%
    select(
      Site_ID,
      DateTime_Start,
      DateTime_End,
      all_of(summary_column_order),
      -Month
    )
  
  return(summary_wide)
}

l2_monthly_summary <- sensor_monthly_summary(
  data = l2_data_formatted
)

# ================= Write L2 EXO monthly summary =================

summary_columns <- colnames(l2_monthly_summary %>% select(-Site_ID))

summary_headers <- headers %>%
  filter(Sensor == "exo_summary")

missing_headers <- setdiff(
  summary_columns,
  summary_headers$Column_Header
)

if (length(missing_headers) > 0) {
  warning(
    paste0(
      "The following L2 summary columns do not have header rows: ",
      paste(missing_headers, collapse = ", ")
    ),
    call. = FALSE
  )
}

filtered_summary_headers <- summary_headers %>%
  filter(Column_Header %in% summary_columns) %>%
  arrange(match(Column_Header, summary_columns)) %>%
  mutate(
    Instrument_Summary = str_replace(
      Instrument_Summary,
      "//.{1,}$",
      ""
    ),
    header = paste0(
      "# ", Column_Header, "; ",
      Unit, "; ",
      InstallationMethod_ID, "; ",
      Instrument_Summary, "."
    )
  ) %>%
  select(header)

summary_data_headers <- bind_rows(
  tibble(
    header = "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary"
  ),
  filtered_summary_headers
)

summary_n_rows <- nrow(summary_data_headers) + 2

summary_data_headers <- bind_rows(
  tibble(
    header = paste0("# HeaderRows_", summary_n_rows)
  ),
  summary_data_headers
)

summary_output_file <- file.path(
  "./05_PublishReadyData",
  "L2_PRT_Water_EXO_Monthly_Summary.csv"
)

# Write header rows
write_csv(
  summary_data_headers,
  summary_output_file,
  col_names = FALSE
)

# Append column names and summary data
write_csv(
  l2_monthly_summary,
  summary_output_file,
  col_names = TRUE,
  append = TRUE
)


# ================= plot L2 EXO data =================


exo_L2_plots <- function(L2_data,
                         plot_output_dir,
                         timezone = "Etc/GMT+8") {
  
  # Measurement names and corresponding flag prefixes
  measurement_names <- c(
    Temperature                 = "Temperature (°C)",
    Specific_Conductance        = "Specific Conductance (uS/cm)",
    Dissolved_Oxygen            = "Dissolved Oxygen (mg/L)",
    Dissolved_Oxygen_Saturation = "Dissolved Oxygen (% Sat)",
    pH                          = "pH",
    Turbidity                   = "Turbidity (FNU)",
    fDOM_QSU                    = "fDOM (QSU)",
    Depth                       = "Depth (m)"
  )
  
  flag_names <- c(
    Temperature                 = "Temp",
    Specific_Conductance        = "SpC",
    Dissolved_Oxygen            = "DO",
    Dissolved_Oxygen_Saturation = "DOsat",
    pH                          = "pH",
    Turbidity                   = "Turb",
    fDOM_QSU                    = "fDOM",
    Depth                       = "Depth"
  )
  
  # Check for required columns
  required_columns <- c("Site_ID", "DateTime", "Flag")
  
  missing_columns <- setdiff(required_columns, names(L2_data))
  
  if (length(missing_columns) > 0) {
    stop(
      "L2_data is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
  
  # Only plot measurements present in the tibble
  measurements_to_plot <- intersect(
    names(measurement_names),
    names(L2_data)
  )
  
  if (length(measurements_to_plot) == 0) {
    stop("No recognized EXO measurement columns were found in L2_data.")
  }
  
  dir_create(plot_output_dir)
  
  # Convert to long format and identify flagged values
  plot_long_data <- L2_data %>%
    mutate(
      DateTime = if (inherits(DateTime, "POSIXt")) {
        DateTime
      } else {
        ymd_hms(trimws(DateTime))
      },
      Year = year(DateTime)
    ) %>%
    pivot_longer(
      cols = all_of(measurements_to_plot),
      names_to = "Measurement",
      values_to = "Value"
    ) %>%
    mutate(
      Point_Removed = is.na(Value) | Value == -9999
    ) %>%
    group_by(Site_ID, Year) %>%
    mutate(
      Percent_Points_Removed = round(
        100 * sum(Point_Removed) / n(),
        3
      )
    ) %>%
    ungroup() %>%
    filter(!Point_Removed) %>%
    mutate(
      Measurement_Clean = recode(
        Measurement,
        !!!measurement_names
      ),
      Measurement_Clean = factor(
        Measurement_Clean,
        levels = unname(measurement_names[measurements_to_plot])
      )
    )
  
  # Split by site and calendar year
  plot_groups <- plot_long_data %>%
    filter(!is.na(Site_ID), !is.na(Year)) %>%
    group_by(Site_ID, Year) %>%
    group_split()
  
  plot_results <- map(
    plot_groups,
    function(site_year_data) {
      
      site_ID <- first(site_year_data$Site_ID)
      data_year <- first(site_year_data$Year)
      
      plot <- ggplot(
        site_year_data,
        aes(x = DateTime, y = Value)
      ) +
        geom_point(
          color = "black",
          size = 0.3,
          na.rm = TRUE
        ) +
        ggh4x::facet_wrap2(
          "Measurement_Clean",
          scales = "free_y",
          strip.position = "left",
          ncol = 1,
          trim_blank = FALSE
        ) +
        scale_x_datetime(
          date_labels = "%Y-%m-%d %H:%M"
        ) +
        labs(
          title = paste(
            "Site ID:", site_ID,
            "| Calendar Year:", data_year
          ),
          x = "DateTime",
          y = ""
        )+
        theme_bw() +
        theme(
          text = element_text(
            family = "serif",
            face = "plain"
          ),
          axis.title = element_text(size = 11),
          axis.text = element_text(size = 9),
          axis.text.x = element_text(
            angle = 0,
            hjust = 1
          ),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_line(
            color = "grey90",
            linewidth = 0.2
          ),
          strip.background = element_blank(),
          strip.text = element_text(
            size = 9,
            family = "serif"
          ),
          strip.placement = "outside",
          plot.title = element_text(
            size = 20,
            face = "bold",
            hjust = 0.5
          ),
          plot.margin = margin(0, 1, 0, 0, "cm"),
          plot.subtitle = element_text(
            size = 14,
            hjust = 0.5,
            margin = margin(b = 10)
          )
        )
      
      output_file <- path(
        plot_output_dir,
        paste0(
          "L2_PRT_",
          site_ID,
          "_",
          data_year,
          "_EXO.pdf"
        )
      )
      
      ggsave(
        filename = output_file,
        plot = plot,
        device = "pdf",
        width = 20,
        height = 14,
        units = "in"
      )
      
      cat("Saved:", output_file, "\n")
      
 
    }
  )
  
}

L2_plot_summary <- exo_L2_plots(
  L2_data = l2_data_formatted,
  plot_output_dir = "./04_Plots/L2"
)

# ================= combine plots =================

l1_exo_pdfs <- list.files('./04_Plots/L1', 'pdf', full.names = T) %>%
  str_subset("M01", negate = TRUE) # not publishing M01 in v2 of data package
l2_exo_pdfs <- list.files('./04_Plots/L2', 'pdf', full.names = T) %>%
  str_subset("M01", negate = TRUE) # not publishing M01 in v2 of data package


pdf_combine(input = l1_exo_pdfs, output = './05_PublishReadyData/L1_PRT_Water_EXO_Plots.pdf')
pdf_combine(input = l2_exo_pdfs, output = './05_PublishReadyData/L2_PRT_Water_EXO_Plots.pdf')


# =============================== BaroTROLL ==================================

barotroll_folder <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/BaroTROLL'

setwd(barotroll_folder)

baro_l1_files <- list.files('./03_ProcessedData_L1', 'csv', full.names = T)%>%
  str_subset("M01|G01|G02|M01A", negate = TRUE) # not publishing M01 in v2 of data package

baro_l2_files <- list.files('./03_ProcessedData_L2', 'csv', full.names = T)%>%
  str_subset("M01|G01|G02|M01A", negate = TRUE) # not publishing M01 in v2 of data package


# ================================== L1 BaroTROLL =====================================

for (l1 in baro_l1_files) {
  
  l1_data <- read_csv(l1, col_types = cols(.default = col_character())) %>%
    mutate(DateTime = paste0(" ", as.character(DateTime))) %>%
    rename(Pressure = Pressure_mBar,
           Air_Temperature = Air_Temp) %>% 
    mutate(Out_of_Bounds = str_replace(Out_of_Bounds, 'Air_Temp', 'Air_Temperature'),
           Out_of_Bounds = str_replace(Out_of_Bounds,'Pressure_mBar', 'Pressure'),
           Pressure = round(as.numeric(Pressure), 3)) %>%
    relocate(DateTime, Site_ID, Air_Temperature, Pressure, Out_of_Bounds)
  
  columns <- colnames(l1_data)
  
  filtered_headers <- headers %>%
    filter(str_to_lower(Sensor) == 'barotroll' & Column_Header %in% columns) %>%
    arrange(match(Column_Header, columns)) %>%
    mutate(
      Instrument_Summary = str_replace(Instrument_Summary, "//.{1,}$", ""),
      header = paste0(
        '# ', Column_Header, '; ',
        Unit, '; ',
        InstallationMethod_ID, '; ',
        Instrument_Summary, '.'
      )
    ) %>%
    select(header)
  
  data_headers <- tibble(header = '# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary') %>%
    add_row(filtered_headers)

  n_rows <- nrow(data_headers) + 2
  
  data_headers <- data_headers %>%
    add_row(
      header = paste0('# HeaderRows_', n_rows),
      .before = 1
    )
  
  new_name <- l1 %>%
    str_replace('03_ProcessedData_L1', '05_PublishReadyData')
  
  write_csv(data_headers, new_name, col_names = F)
  Sys.sleep(2)
  write_csv(l1_data, new_name, col_names = T, append = T)
}


# ================================== L2 BaroTROLL =====================================

baro_l2_data <- imap_dfr(
  baro_l2_files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    mutate(
      source_id = .y,
      row_id = row_number()
    )
)%>%
  mutate(
    Out_of_Bounds = str_replace_all(
      Out_of_Bounds,
      c(
        "Air_Temp" = "Air_Temperature",
        "Pressure_mBar" = "Pressure"
      )
    )
  ) %>%
  rename(
    Pressure = Pressure_mBar,
    Air_Temperature = Air_Temp
  )

interp_method_names <- c(
  linear_gap_fill      = "Pressure_Int_01",
  elevation_regression = "Pressure_Int_02",
  reference_regression = "Pressure_Int_03"
)


interp_flags <- baro_l2_data %>%
  select(source_id, row_id, Interpolation_Method) %>%
  filter(
    !is.na(Interpolation_Method),
    !Interpolation_Method %in% c("", "N/A")
  ) %>%
  mutate(
    Flag = unname(interp_method_names[Interpolation_Method])
  ) %>%
  filter(!is.na(Flag)) %>%
  select(source_id, row_id, Flag)

oob_flags <- baro_l2_data %>%
  select(source_id, row_id, Out_of_Bounds) %>%
  filter(
    str_trim(Out_of_Bounds) %in% c(
      "Air_Temperature",
      "Pressure"
    )
  ) %>%
  mutate(
    Flag = case_when(
      str_trim(Out_of_Bounds) == "Air_Temperature" ~ "Air_Temp_OOB_01",
      str_trim(Out_of_Bounds) == "Pressure" ~ "Press_OOB_01"
    )
  ) %>%
  select(source_id, row_id, Flag)

flags <- bind_rows(interp_flags, oob_flags) %>%
  distinct(source_id, row_id, Flag) %>%
  summarise(
    Flag = paste(Flag, collapse = "; "),
    .by = c(source_id, row_id)
  )


baro_l2_formatted <- baro_l2_data %>%
  left_join(flags, by = c("source_id", "row_id"))  %>%
  mutate(
    Air_Temperature = case_when(
      str_detect(Out_of_Bounds, "Air_Temperature") ~ NA,
      TRUE ~ Air_Temperature
    ),
    Pressure = case_when(
      str_detect(Out_of_Bounds, "Pressure") ~ NA,
      TRUE ~ Pressure
    ),
    DateTime = paste0(" ", format(DateTime, "%Y-%m-%d %H:%M:%S"))
  ) %>%
  select(
    -Out_of_Bounds,
    -Interpolation_Method,
    -Interpolated,
    -source_id,
    -row_id
  ) %>%
  relocate(
    DateTime, Site_ID, Air_Temperature, Pressure, Flag,
    .before = everything()
  ) %>%
  mutate(
    across(where(is.character), ~ replace_na(.x, "N/A")),
    across(where(is.numeric), ~ replace_na(.x, -9999))
  )

write_baro_l2_file <- function(df, headers, output_file) {
  
  output_data <- df
  columns <- colnames(output_data)
  
  filtered_headers <- headers %>%
    filter(
      str_to_lower(Sensor) == "barotroll",
      Column_Header %in% columns
    ) %>%
    arrange(match(Column_Header, columns)) %>%
    mutate(
      Instrument_Summary = str_replace(
        Instrument_Summary,
        "//.{1,}$",
        ""
      ),
      header = paste0(
        "# ", Column_Header, "; ",
        Unit, "; ",
        InstallationMethod_ID, "; ",
        Instrument_Summary, "."
      )
    ) %>%
    select(header)
  
  data_headers <- bind_rows(
    tibble(
      header = "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary"
    ),
    filtered_headers
  )
  
  n_rows <- nrow(data_headers) + 2
  
  data_headers <- bind_rows(
    tibble(header = paste0("# HeaderRows_", n_rows)),
    data_headers
  )
  
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  
  write_csv(
    data_headers,
    output_file,
    col_names = FALSE
  )
  
  write_csv(
    output_data,
    output_file,
    col_names = TRUE,
    append = TRUE
  )
}

baro_l2_formatted %>%
  mutate(
    Calendar_Year = year(
      ymd_hms(str_trim(DateTime))
    )
  ) %>%
  group_by(Site_ID, Calendar_Year) %>%
  group_walk(
    ~ {
      output_file <- file.path(
        "05_PublishReadyData",
        paste0(
          "L2_PRT_Air_",
          .y$Site_ID,
          "_",
          .y$Calendar_Year,
          "_BaroTROLL.csv"
        )
      )
      
      write_baro_l2_file(
        df = select(.x, -Calendar_Year),
        headers = headers,
        output_file = output_file
      )
    },
    .keep = TRUE
  )

# ========================== BaroTROLL monthly summary ==========================

baro_l2_monthly_summary <- sensor_monthly_summary(
  data = baro_l2_formatted
)

baro_summary_columns <- colnames(baro_l2_monthly_summary %>% select(-Site_ID))

baro_summary_headers <- headers %>%
  filter(str_to_lower(Sensor) == "barotroll_summary")

baro_missing_headers <- setdiff(
  baro_summary_columns,
  baro_summary_headers$Column_Header
)

if (length(baro_missing_headers) > 0) {
  warning(
    paste0(
      "The following BaroTROLL summary columns do not have header rows: ",
      paste(baro_missing_headers, collapse = ", ")
    ),
    call. = FALSE
  )
}

baro_filtered_summary_headers <- baro_summary_headers %>%
  filter(Column_Header %in% baro_summary_columns) %>%
  arrange(match(Column_Header, baro_summary_columns)) %>%
  mutate(
    Instrument_Summary = str_replace(
      Instrument_Summary,
      "//.{1,}$",
      ""
    ),
    header = paste0(
      "# ", Column_Header, "; ",
      Unit, "; ",
      InstallationMethod_ID, "; ",
      Instrument_Summary, "."
    )
  ) %>%
  select(header)

baro_summary_data_headers <- bind_rows(
  tibble(
    header = "# HeaderRows_Format: Column_Header; Unit; InstallationMethod_ID; Instrument_Summary"
  ),
  baro_filtered_summary_headers
)

baro_summary_n_rows <- nrow(baro_summary_data_headers) + 2

baro_summary_data_headers <- bind_rows(
  tibble(
    header = paste0("# HeaderRows_", baro_summary_n_rows)
  ),
  baro_summary_data_headers
)

baro_summary_output_file <- file.path(
  "./05_PublishReadyData",
  "L2_PRT_Air_Barotroll_Monthly_Summary.csv"
)

write_csv(
  baro_summary_data_headers,
  baro_summary_output_file,
  col_names = FALSE
)

write_csv(
  baro_l2_monthly_summary,
  baro_summary_output_file,
  col_names = TRUE,
  append = TRUE
)


# =============================== BaroTROLL plots ===============================

barotroll_plots <- function(sensor_data,
                            plot_output_dir,
                            data_level,
                            group_by_source_file = FALSE,
                            show_status = FALSE) {
  
  measurement_names <- c(
    Air_Temperature     = "Air Temperature (C)",
    Pressure = "Pressure (mBar)"
  )
  
  required_columns <- c("Site_ID", "DateTime")
  
  missing_columns <- setdiff(required_columns, names(sensor_data))
  
  if (length(missing_columns) > 0) {
    stop(
      "sensor_data is missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
  
  measurements_to_plot <- intersect(
    names(measurement_names),
    names(sensor_data)
  )
  
  if (length(measurements_to_plot) == 0) {
    stop("No recognized BaroTROLL measurement columns were found in sensor_data.")
  }
  
  dir_create(plot_output_dir)
  
  if (!"Out_of_Bounds" %in% names(sensor_data)) {
    sensor_data <- sensor_data %>%
      mutate(Out_of_Bounds = NA_character_)
  }
  
  if (!"Interpolated" %in% names(sensor_data)) {
    sensor_data <- sensor_data %>%
      mutate(Interpolated = FALSE)
  }
  
  if (!"Interpolation_Method" %in% names(sensor_data)) {
    sensor_data <- sensor_data %>%
      mutate(Interpolation_Method = NA_character_)
  }
  
  plot_long_data <- sensor_data %>%
    mutate(
      DateTime = if (inherits(DateTime, "POSIXt")) {
        DateTime
      } else {
        ymd_hms(trimws(DateTime))
      },
      Year = year(DateTime),
      Is_Interpolated =
        as.character(Interpolated) %in% c(
          "TRUE", "True", "true", "1", "Yes", "yes"
        ) |
        (
          !is.na(Interpolation_Method) &
            !Interpolation_Method %in% c("", "N/A")
        )
    ) %>%
    pivot_longer(
      cols = all_of(measurements_to_plot),
      names_to = "Measurement",
      values_to = "Value"
    ) %>%
    mutate(
      Point_Removed = is.na(Value) | Value == -9999
    ) %>%
    group_by(Site_ID, Year) %>%
    mutate(
      Percent_Points_Removed = round(
        100 * sum(Point_Removed) / n(),
        3
      )
    ) %>%
    ungroup() %>%
    filter(!Point_Removed) %>%
    mutate(
      Measurement_Clean = recode(
        Measurement,
        !!!measurement_names
      ),
      Measurement_Clean = factor(
        Measurement_Clean,
        levels = unname(measurement_names[measurements_to_plot])
      ),
      Point_Status = case_when(
        Measurement == "Air_Temperature" &
          str_detect(coalesce(Out_of_Bounds, ""), "Air_Temperature") ~
          "Flagged (out of bounds)",
        Measurement == "Pressure" &
          str_detect(coalesce(Out_of_Bounds, ""), "Pressure") ~
          "Flagged (out of bounds)",
        Measurement == "Pressure" & Is_Interpolated ~
          "Interpolated pressure",
        TRUE ~ "Observed points"
      )
    )
  
  if (group_by_source_file) {
    plot_groups <- plot_long_data %>%
      filter(!is.na(Site_ID), !is.na(Source_File)) %>%
      group_by(Source_File) %>%
      group_split()
  } else {
    plot_groups <- plot_long_data %>%
      filter(!is.na(Site_ID), !is.na(Year)) %>%
      group_by(Site_ID, Year) %>%
      group_split()
  }
  
  map(
    plot_groups,
    function(site_year_data) {
      
      site_ID <- first(site_year_data$Site_ID)
      data_year <- first(site_year_data$Year)
      
      plot_title <- paste("Site ID:", site_ID)
      plot_subtitle <- NULL
      
      if (group_by_source_file) {
        source_file <- first(site_year_data$Source_File)
        time_elapsed <- round(
          as.numeric(
            difftime(
              max(site_year_data$DateTime, na.rm = TRUE),
              min(site_year_data$DateTime, na.rm = TRUE),
              units = "days"
            )
          ),
          2
        )
        flagged_points <- sum(
          site_year_data$Point_Status == "Flagged (out of bounds)"
        )
        plot_subtitle <- paste0(
          "Time elapsed: ", time_elapsed,
          " days | Flagged points (red points): ", flagged_points
        )
        output_file <- path(
          plot_output_dir,
          str_replace(source_file, "\\.csv$", "_plot.pdf")
        )
      } else {
        output_file <- path(
          plot_output_dir,
          paste0(
            data_level,
            "_PRT_",
            site_ID,
            "_",
            data_year,
            "_BaroTROLL.pdf"
          )
        )
      }
      
      plot <- ggplot(
        site_year_data,
        aes(x = DateTime, y = Value)
      )
      
      if (show_status) {
        plot <- plot +
          geom_point(
            aes(color = Point_Status),
            size = 0.4,
            na.rm = TRUE
          ) +
          scale_color_manual(
            values = c(
              "Observed points" = "black",
              "Flagged (out of bounds)" = "#CC0000",
              "Interpolated pressure" = "#0072B2"
            ),
            breaks = c(
              "Flagged (out of bounds)",
              "Interpolated pressure"
            ),
            name = "Legend"
          )
      } else {
        plot <- plot +
          geom_point(
            color = "black",
            size = 0.3,
            na.rm = TRUE
          )
      }
      
      plot <- plot +
        ggh4x::facet_wrap2(
          "Measurement_Clean",
          scales = "free_y",
          strip.position = "left",
          ncol = 1,
          trim_blank = FALSE
        ) +
        scale_x_datetime(
          date_labels = "%Y-%m-%d %H:%M"
        ) +
        labs(
          title = plot_title,
          subtitle = plot_subtitle,
          x = "DateTime",
          y = ""
        ) +
        theme_bw() +
        theme(
          text = element_text(
            family = "serif",
            face = "plain"
          ),
          axis.title = element_text(size = 11),
          axis.text = element_text(size = 9),
          axis.text.x = element_text(
            angle = 0,
            hjust = 1
          ),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_line(
            color = "grey90",
            linewidth = 0.2
          ),
          strip.background = element_blank(),
          strip.text = element_text(
            size = 9,
            family = "serif"
          ),
          strip.placement = "outside",
          plot.title = element_text(
            size = 20,
            face = "bold",
            hjust = 0.5
          ),
          plot.margin = margin(0, 1, 0, 0, "cm"),
          plot.subtitle = element_text(
            size = 14,
            hjust = 0.5,
            margin = margin(b = 10)
          ),
          legend.position = "bottom",
          legend.title = element_text(size = 10, face = "bold"),
          legend.text = element_text(size = 9)
        )
      
      ggsave(
        filename = output_file,
        plot = plot,
        device = "pdf",
        width = 12,
        height = 7,
        units = "in"
      )
      
      cat("Saved:", output_file, "\n")
    }
  )
}

baro_l1_plot_data <- map_dfr(
  baro_l1_files,
  ~ read_csv(.x, show_col_types = FALSE) %>%
    rename(
      Pressure = Pressure_mBar,
      Air_Temperature = Air_Temp
    ) %>%
    mutate(
      Source_File = path_file(.x),
      Out_of_Bounds = str_replace_all(
        Out_of_Bounds,
        c(
          "Air_Temp" = "Air_Temperature",
          "Pressure_mBar" = "Pressure"
        )
      ),
      across(
        c(Air_Temperature, Pressure),
        ~ suppressWarnings(as.numeric(.x))
      )
    )
)

barotroll_plots(
  sensor_data = baro_l1_plot_data,
  plot_output_dir = "./04_Plots/L1",
  data_level = "L1",
  group_by_source_file = TRUE,
  show_status = TRUE
)

barotroll_plots(
  sensor_data = baro_l2_formatted,
  plot_output_dir = "./04_Plots/L2",
  data_level = "L2"
)

baro_l1_pdfs <- list.files(
  "./04_Plots/L1_BaroTROLL",
  "pdf",
  full.names = TRUE
)

baro_l2_pdfs <- list.files(
  "./04_Plots/L2_BaroTROLL",
  "pdf",
  full.names = TRUE
)

pdf_combine(
  input = baro_l1_pdfs,
  output = "./05_PublishReadyData/L1_PRT_Air_BaroTROLL_Plots.pdf"
)

pdf_combine(
  input = baro_l2_pdfs,
  output = "./05_PublishReadyData/L2_PRT_Air_BaroTROLL_Plots.pdf"
)




