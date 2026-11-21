# ==============================================================================
#
# Format PRT sensor data for publishing 
# 
# Status: In progress

# Note: need to filter L1 and L2 for barotroll 
#
# =============================================================================
#
# Author: Brieanne Forbes
# 19 August 2026 (last revised 2026-10-30)

rm(list=ls(all=T))

library(tidyverse)
library(readxl)
library(qpdf)
library(fs)

# =============================== user inputs ================================

exo_folder <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/EXO'

headers_dir <- "C:/Users/forb086/OneDrive - PNNL/Core Richland and Sequim Lab-Field Team - Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Sensor_Header_Rows.xlsx"

inst_methods_dir <- "C:/Users/forb086/OneDrive - PNNL/Core Richland and Sequim Lab-Field Team - Data Generation and Files/Workflows-MethodsCodes/Methods_Codes/Installation_Methods_and_Flags.xlsx"

cutoff <- as.Date("2026-06-09") # cutoff for v1 of data package

cutoffs <- tribble( # data after the trip are removed from v1, these datetimes are from the field metadata
  ~Site_ID, ~Cutoff,
  "M03",  "2026-06-09 08:15",
  "NF01", "2026-06-09 12:30",
  "M01",  "2026-06-10 15:30",
  "SF01", "2026-06-10 09:05",
  "M02",  "2026-06-10 12:00"
) %>%
  mutate(Cutoff = ymd_hm(Cutoff))


# =============================== find files ================================

setwd(exo_folder)

l1_files <- list.files(
  "./03_ProcessedData_L1",
  pattern = "\\.csv$",
  full.names = TRUE
) %>%
  str_subset("M01", negate = TRUE) # not publishing M01 in v2 of data package


file_dates <- as.Date(str_extract(basename(l1_files), "\\d{4}-\\d{2}-\\d{2}"))

l1_files <- l1_files[file_dates < cutoff]

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
  
  # Get first date in the data
  first_date <- l1_data %>%
    pull(DateTime) %>%
    first() %>%
    as.Date() %>%
    format("%Y-%m-%d")
  
  # Update output filename
  new_name <- l1 %>%
    str_replace("03_ProcessedData_L1", "05_PublishReadyData") %>%
    str_replace("L1_PRT", "L1_PRT_Water") %>%
    str_replace("\\d{4}-\\d{2}-\\d{2}(?=_EXO\\.csv$)", first_date)
  
  # write out headers
  write_csv(data_headers, new_name, col_names = F, append = F)
  
  # pause for 2 seconds in case it's trying to append before the headers are written out
  Sys.sleep(2)
  
  # write out data
  write_csv(l1_data, new_name, col_names = T, append = T)
  
}

# ================================== L2 EXO =====================================

# Flag-column names and corresponding output prefixes
flag_names <- c(
  f_Temp_C        = "Temp",
  f_SpCond_uScm   = "SpC",
  f_DO_mgl        = "DO",
  f_DO_percent_sat = "DOsat",
  f_pH            = "pH",
  f_Turbidity_FNU = "Turb",
  f_fDOM_QSU      = "fDOM",
  f_Depth_ft      = "Depth"
)

# Out-of-bounds measurement names and corresponding output prefixes
out_of_bounds_names <- c(
  Mean5sec_Temperature                            = "Temp",
  Mean5sec_Specific_Conductance                   = "SpC",
  Mean5sec_Dissolved_Oxygen_YSI                   = "DO",
  Mean5sec_Dissolved_Oxygen_Saturation_YSI        = "DOsat",
  Mean5sec_Dissolved_Oxygen_Saturation_Calculated = "DOsat",
  Mean5sec_pH                                     = "pH",
  Mean5sec_Turbidity                              = "Turb",
  Mean5sec_fDOM_QSU                               = "fDOM",
  Mean5sec_Absolute_Pressure                      = "AbsPress",
  Mean5sec_Depth                                  = "Depth",
  Mean5sec_Battery                                = "Battery",
  n_burst                                         = "Burst"
)

# Drift correction measurement names
drift_names <- c(
  "Water temperature"    = "Temp",
  "Specific conductance" = "SpC",
  "DO (mg/L)"             = "DO",
  "calc. DO (% sat)"      = "DOsat",
  "pH"                    = "pH",
  "Turbidity"             = "Turb",
  "fDOM (temp-corrected)" = "fDOM",
  "Depth (ft)"            = "Depth"
)

# Read and prepare L2 data -----------------------------------------------

l2_data <- read_csv(l2_files) %>%
  select(-fDOM_QSU_uncorrected, -f_fDOM_QSU_uncorrected) %>%
  rename(
    fDOM_QSU = fDOM_QSU_corrected,
    f_fDOM_QSU = f_fDOM_QSU_corrected
  ) %>%
  filter(Site_ID != "M01") %>%
  left_join(cutoffs, by = "Site_ID") %>%
  filter(is.na(Cutoff) | DateTime < Cutoff) %>%
  select(-Cutoff) %>% 
  
  # Remove duplicate timestamps where Out_of_Bounds contains n_burst
  group_by(Site_ID, DateTime) %>%
  filter(
    !(n() > 1 &
        str_detect(coalesce(Out_of_Bounds, ""), fixed("n_burst")))
  ) %>%
  ungroup() %>%
  
  # Remove unwanted existing flag reasons
  mutate(
    across(
      starts_with("f_"),
      ~ map_chr(
        str_split(coalesce(.x, ""), "\\s*[,;]\\s*"),
        function(x) {
          x <- str_trim(x)
          x <- x[!x %in% c("", "N/A", "L1 OOB", "Drift")]
          
          if (length(x) == 0) {
            NA_character_
          } else {
            str_c(x, collapse = "; ")
          }
        }
      )
    ),
    row_id = row_number()
  )

# Convert existing flag columns -----------------------------------------

existing_flags <- l2_data %>%
  select(row_id, all_of(names(flag_names))) %>%
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
    flag_value = str_split(flag_value, "\\s*[,;]\\s*")
  ) %>%
  unnest_longer(flag_value) %>%
  mutate(
    flag_value = str_trim(flag_value),
    flag_value = str_remove(
      flag_value,
      paste0("^", flag_prefix, "_")
    ),
    flag_value = str_remove(flag_value, "_01$"),
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
    Flag = paste0(flag_prefix, "_", flag_value, "_01")
  ) %>%
  select(row_id, Flag)

# Convert Out_of_Bounds values to flags ----------------------------------

out_of_bounds_long <- l2_data %>%
  select(row_id, Out_of_Bounds) %>%
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
  filter(Out_of_Bounds != "")

# Warn about unexpected OOB values
unknown_out_of_bounds <- out_of_bounds_long %>%
  filter(
    !Out_of_Bounds %in% names(out_of_bounds_names),
    Out_of_Bounds != "Mean5sec_fDOM_RFU"
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
    flag_code = unname(out_of_bounds_names[Out_of_Bounds])
  ) %>%
  filter(!is.na(flag_code)) %>%
  mutate(
    Flag = paste0(flag_code, "_OOB_01")
  ) %>%
  select(row_id, Flag)


# Convert drift_correction values to flags -------------------------------

drift_flags <- l2_data %>%
  select(row_id, drift_correction) %>%
  filter(
    !is.na(drift_correction),
    !drift_correction %in% c("", "N/A")
  ) %>%
  separate_rows(drift_correction, sep = "\\s*\\|\\s*") %>%
  mutate(
    drift_correction = str_trim(drift_correction),
    
    # Remove the descriptive prefix if it is present
    measurement = str_remove(
      drift_correction,
      "^Drift correction:\\s*"
    ),
    
    flag_prefix = unname(drift_names[measurement])
  ) %>%
  filter(
    !is.na(flag_prefix),
    flag_prefix != ""
  ) %>%
  mutate(
    Flag = paste0(flag_prefix, "_DriftCorr_01")
  ) %>%
  select(row_id, Flag)

# Convert step-change corrections to flags -------------------------------

step_correction_flags <- l2_data %>%
  select(row_id, step_change_correction) %>%
  filter(
    !is.na(step_change_correction),
    !step_change_correction %in% c("", "N/A")
  ) %>%
  mutate(
    Flag = case_when(
      step_change_correction == "Step change correction: pH" ~
        "pH_StepCorr_01",
      
      step_change_correction ==
        "Step change correction not applied - insufficient baseline: pH" ~
        "pH_NoStepCorr_01",
      
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(Flag)) %>%
  select(row_id, Flag)

# Flag drift corrections that could not be applied ----------------------

drift_not_corrected_flags <- l2_data %>%
  select(row_id, drift_correction) %>%
  filter(
    !is.na(drift_correction),
    !drift_correction %in% c("", "N/A")
  ) %>%
  separate_rows(drift_correction, sep = "\\s*\\|\\s*") %>%
  mutate(
    drift_correction = str_trim(drift_correction)
  ) %>%
  filter(
    drift_correction ==
      "Drift correction not applied - would create negative values: Turbidity"
  ) %>%
  mutate(
    Flag = "Turb_NoDriftCorr_01"
  ) %>%
  select(row_id, Flag)

# Combine flags for each row ---------------------------------------------

flags <- bind_rows(
  existing_flags,
  out_of_bounds_flags,
  drift_flags,
  step_correction_flags,
  drift_not_corrected_flags
) %>%
  distinct(row_id, Flag) %>%
  summarise(
    Flag = paste(Flag, collapse = "; "),
    .by = row_id
  )

# Clean Notes ------------------------------------------------------------

clean_exo_notes <- function(x) {
  
  recognized_drift_notes <- paste0(
    "Drift correction: ",
    names(drift_names)
  )
  
  notes_to_remove <- c(
    recognized_drift_notes,
    "Baseline correction",
    "Drift correction not applied: would create negative turbidity"
  )
  
  map_chr(x, function(note) {
    
    if (is.na(note) || str_trim(note) == "") {
      return(NA_character_)
    }
    
    remaining <- str_split(note, fixed("|"))[[1]] %>%
      str_trim()
    
    remaining <- remaining[
      !remaining %in% notes_to_remove &
        remaining != ""
    ]
    
    if (length(remaining) == 0) {
      NA_character_
    } else {
      str_c(remaining, collapse = " | ")
    }
  })
}

# Format final L2 data ---------------------------------------------------

l2_data_formatted <- l2_data %>%
  left_join(flags, by = "row_id") %>%
  mutate(
    Notes = clean_exo_notes(Notes)
  ) %>%
  select(
    -row_id,
    -starts_with("f_"),
    -Out_of_Bounds
  ) %>%
  rename(
    Temperature                 = Temp_C,
    Specific_Conductance        = SpCond_uScm,
    Dissolved_Oxygen            = DO_mgl,
    Dissolved_Oxygen_Saturation = DO_percent_sat,
    Turbidity                   = Turbidity_FNU,
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
    DateTime = paste0(' ', format(
      as_datetime(DateTime),
      "%Y-%m-%d %H:%M:%S"
    ))
  )

# Verify no correction notes remain -------------------------------------

remaining_correction_notes <- l2_data_formatted %>%
  filter(
    str_detect(
      coalesce(Notes, ""),
      regex("Baseline correction|Drift correction", ignore_case = TRUE)
    )
  ) %>%
  count(Notes, sort = TRUE)

print(remaining_correction_notes)

# Confirm no duplicate timestamps remain --------------------------------

remaining_duplicates <- l2_data_formatted %>%
  count(Site_ID, DateTime) %>%
  filter(n > 1)

print(remaining_duplicates)

# Format final L2 data ---------------------------------------------------



l2_data_formatted <- l2_data %>%
  left_join(flags, by = "row_id") %>%
  mutate(
    Notes = clean_exo_notes(Notes)
  ) %>%
  select(
    -row_id,
    -starts_with("f_"),
    -Out_of_Bounds,
    -step_change_correction,
    -drift_correction,
    -Notes,
    -flag_description
  ) %>%
  rename(
    Temperature                 = Temp_C,
    Specific_Conductance        = SpCond_uScm,
    Dissolved_Oxygen            = DO_mgl,
    Dissolved_Oxygen_Saturation = DO_percent_sat,
    Turbidity                   = Turbidity_FNU,
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
    across(
      where(is.numeric),
      ~ round(.x, 3)
    ),
    DateTime = paste0(
      " ",
      format(
        as_datetime(DateTime),
        "%Y-%m-%d %H:%M:%S"
      )
    )
    
  )

missing_headers <- setdiff(
  names(l2_data_formatted),
  c(
    headers %>%
      filter(Sensor == "exo") %>%
      pull(Column_Header),
    "Site_ID", "Notes", "Flag", 'flag_description'
  )
)

if (length(missing_headers) > 0) {
  warning(
    "Missing L2 EXO header definitions: ",
    paste(missing_headers, collapse = ", ")
  )
}

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

l1_exo_pdfs <- list.files("./04_Plots/L1", pattern = "\\.pdf$", full.names = TRUE) %>%
  str_subset("M01", negate = TRUE) # not publishing M01 in v2 of data package

file_dates <- as.Date(str_extract(basename(l1_exo_pdfs), "\\d{4}-\\d{2}-\\d{2}"))

l1_exo_pdfs <- l1_exo_pdfs[
  is.na(file_dates) | file_dates < cutoff
]

l2_exo_pdfs <- list.files('./04_Plots/L2', 'pdf', full.names = T) %>%
  str_subset("M01", negate = TRUE) # not publishing M01 in v2 of data package


pdf_combine(input = l1_exo_pdfs, output = './05_PublishReadyData/L1_PRT_Water_EXO_Plots.pdf')
pdf_combine(input = l2_exo_pdfs, output = './05_PublishReadyData/L2_PRT_Water_EXO_Plots.pdf')


# =============================== BaroTROLL ==================================

barotroll_folder <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/BaroTROLL'

setwd(barotroll_folder)

baro_l1_files <- list.files("./03_ProcessedData_L1", pattern = "\\.csv$", full.names = TRUE) %>%
  str_subset("M01|G01|G02|M01A", negate = TRUE) # not publishing these in v2

l1_dates <- as.Date(str_extract(basename(baro_l1_files), "\\d{4}-\\d{2}-\\d{2}"))
baro_l1_files <- baro_l1_files[is.na(l1_dates) | l1_dates < cutoff] # skipping files that were after the cutoff for v1

baro_l2_files <- list.files("./03_ProcessedData_L2", pattern = "\\.csv$", full.names = TRUE) %>%
  str_subset("M01|G01|G02|M01A|Summary|Regression", negate = TRUE)

baro_l2_summary <- list.files('./03_ProcessedData_L2', 'csv', full.names = T)%>%
  str_subset("Summary")

# ================================== L1 BaroTROLL =====================================

for (l1 in baro_l1_files) {
  
  l1_data <- read_csv(l1, col_types = cols(.default = col_character())) %>%
    mutate(DateTime = paste0(" ", as.character(DateTime))) %>%
    mutate(Pressure = round(as.numeric(Pressure), 3)) %>%
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


# ============================== L2 BaroTROLL ==================================

baro_l2_data <- imap_dfr(
  baro_l2_files,
  ~ read_csv(
    .x,
    col_types = cols(DateTime = col_character()),
    show_col_types = FALSE
  ) %>%
    mutate(
      source_id = .y,
      row_id = row_number()
    )
) %>%
  mutate(
    DateTime = str_trim(DateTime),
    
    # Add midnight when only a date is present
    DateTime = if_else(
      str_detect(DateTime, "^\\d{4}-\\d{2}-\\d{2}$"),
      paste(DateTime, "00:00:00"),
      DateTime
    ),
    
    DateTime = lubridate::ymd_hms(DateTime)
  ) %>%
  left_join(cutoffs, by = "Site_ID") %>%
  filter(is.na(Cutoff) | DateTime <= Cutoff) %>%
  select(-Cutoff)


# Write a file with header rows
write_baro_l2_file <- function(df, headers, output_file) {
  
  columns <- names(df)
  
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
      header = paste0(
        "# HeaderRows_Format: Column_Header; Unit; ",
        "InstallationMethod_ID; Instrument_Summary"
      )
    ),
    filtered_headers
  )
  
  data_headers <- bind_rows(
    tibble(header = paste0("# HeaderRows_", nrow(data_headers) + 2)),
    data_headers
  )
  
  dir.create(
    dirname(output_file),
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  write_csv(
    data_headers,
    output_file,
    col_names = FALSE
  )
  
  write_csv(
    df,
    output_file,
    col_names = TRUE,
    append = TRUE
  )
}


# Export by site and year
baro_l2_data %>%
  mutate(
    Calendar_Year = lubridate::year(DateTime),
    DateTime = paste0(
      " ",
      format(DateTime, "%Y-%m-%d %H:%M:%S")
    )
  ) %>%
  select(-source_id, -row_id) %>%
  group_by(Site_ID, Calendar_Year) %>%
  group_walk(
    ~ {
      output_file <- file.path(
        "./05_PublishReadyData",
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
# ========================== BaroTROLL monthly summary =========================

source("C:/Brieanne/GitHub/rcsfa-sensor-processing/sensor_summary_function.R")
source("C:/Brieanne/GitHub/rcsfa-sensor-processing/L1_L2_barotroll_processing_functions.R")

baro_l2_monthly_summary <- sensor_summary(
  data           = baro_l2_data %>% select(-source_id, -row_id),
  summary_period = "monthly",
  battery_remove = TRUE
) %>%
  mutate(DateTime_Start = paste0(" ", DateTime_Start),
         DateTime_End = paste0(" ", DateTime_End))

baro_summary_columns <- baro_l2_monthly_summary %>% select(-Site_ID) %>% colnames()

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

baro_l1_pdfs <- list.files(
  "./04_Plots/L1",
  "pdf",
  full.names = TRUE) %>% 
  str_subset('M01', negate = T)

pdf_dates <- as.Date(
  str_extract(basename(baro_l1_pdfs), "\\d{4}-\\d{2}-\\d{2}")
)

baro_l1_pdfs <- baro_l1_pdfs[
  is.na(pdf_dates) | pdf_dates < cutoff
]

pdf_combine(
  input = baro_l1_pdfs,
  output = "./05_PublishReadyData/L1_PRT_Air_BaroTROLL_Plots.pdf"
)

out_plot_L2_dir <- ('./04_Plots/L2')

# have to remake L2 plots to remove data after june 
baro_l2_data %>%
  mutate(
    DateTime = parse_date_time(
      as.character(DateTime),
      orders = c("ymd HMS", "ymd HM"),
      tz = "UTC"
    )
  ) %>%
  
  # Remove observations after site-specific cutoffs
  left_join(cutoffs, by = "Site_ID") %>%
  filter(
    !is.na(DateTime),
    is.na(Cutoff) | DateTime <= Cutoff
  ) %>%
  select(-Cutoff) %>%
  
  # Convert to long format expected by baro_plots()
  pivot_longer(
    cols = c(Air_Temperature, Pressure),
    names_to = "Measurement",
    values_to = "Value"
  ) %>%
  
  mutate(Year = year(DateTime)) %>%
  group_by(Site_ID, Year) %>%
  group_split() %>%
  walk(function(x) {
    
    site_ID <- unique(x$Site_ID)
    yr <- unique(x$Year)
    
    plot_data <- x %>%
      select(-Year)
    
    p <- baro_plots(
      long_data = plot_data,
      data_level = "L2"
    )
    
    ggsave(
      file.path(
        out_plot_L2_dir,
        paste0(
          "L2_PRT_Air_",
          site_ID,
          "_",
          yr,
          "_Barotroll.pdf"
        )
      ),
      p,
      device = "pdf",
      width = 10,
      height = 6,
      units = "in",
      dpi = 300
    )
  })

baro_l2_pdfs <- list.files(out_plot_L2_dir, full.names = TRUE) %>%
  str_subset("archive", negate = TRUE) %>%
  str_subset("M01", negate = TRUE)

pdf_combine(
  input = baro_l2_pdfs,
  output = "./05_PublishReadyData/L2_PRT_Air_BaroTROLL_Plots.pdf"
)

# ============================== Rain Gauge ====================================

rain_folder <- 'C:/Users/forb086/OneDrive - PNNL/RC-SFA - Documents/Study_PRT/Rain_Gauge'

setwd(rain_folder)

rain_l1_files <- list.files("./03_ProcessedData_L1", pattern = "\\.csv$", full.names = TRUE) 

rain_l2_files <- list.files("./03_ProcessedData_L2", pattern = "\\.csv$", full.names = TRUE)

# ========================== Add rain gauge headers ===========================

rain_headers <- headers %>%
  filter(
    str_remove_all(str_to_lower(Sensor), "[^a-z0-9]") %in%
      c("raingauge", "raingaugesummary")
  )

write_rain_file <- function(input_file) {
  
  output_data <- read_csv(
    input_file,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE
  ) %>%
    mutate(
      across(
        matches("^DateTime($|_)", ignore.case = TRUE),
        ~ if_else(
          is.na(.x),
          NA_character_,
          paste0(" ", str_trim(as.character(.x)))
        )
      )
    )
  
  columns <- names(output_data)
  
  sensor_type <- if (
    str_detect(basename(input_file), regex("summary", ignore_case = TRUE))
  ) {
    "raingaugesummary"
  } else {
    "raingauge"
  }
  
  file_headers <- rain_headers %>%
    filter(
      str_remove_all(str_to_lower(Sensor), "[^a-z0-9]") == sensor_type
    )
  
  missing_headers <- setdiff(
    columns,
    c(file_headers$Column_Header, "Site_ID", "Out_of_Bounds", "Flag")
  )
  
  if (length(missing_headers) > 0) {
    stop(
      "Missing rain gauge header definitions for ",
      basename(input_file), ": ",
      paste(missing_headers, collapse = ", ")
    )
  }
  
  filtered_headers <- file_headers %>%
    filter(Column_Header %in% columns) %>%
    arrange(match(Column_Header, columns)) %>%
    mutate(
      Instrument_Summary = str_remove(Instrument_Summary, "//.*$"),
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
      header = paste0(
        "# HeaderRows_Format: Column_Header; Unit; ",
        "InstallationMethod_ID; Instrument_Summary"
      )
    ),
    filtered_headers
  )
  
  data_headers <- bind_rows(
    tibble(header = paste0("# HeaderRows_", nrow(data_headers) + 2)),
    data_headers
  )
  
  output_name <- basename(input_file) %>%
    str_replace("^L1_", "L1_PRT_") %>%
    str_replace("^L2_PRT_Precipitation_", "L2_PRT_")
  
  output_file <- file.path(
    "./05_PublishReadyData",
    output_name
  )
  
  write_csv(data_headers, output_file, col_names = FALSE)
  
  write_csv(
    output_data,
    output_file,
    col_names = TRUE,
    append = TRUE
  )
}

walk(rain_l1_files, write_rain_file)

# Write L2 data files separately
walk(
  rain_l2_files %>%
    str_subset(regex("summary", ignore_case = TRUE), negate = TRUE),
  write_rain_file
)

# Combine summaries across years
rain_summary_files <- rain_l2_files %>%
  str_subset(regex("summary", ignore_case = TRUE))

rain_summary_data <- map_dfr(
  rain_summary_files,
  ~ read_csv(
    .x,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE
  )
)

# Temporary input uses "Summary" to select rain_gauge_summary headers
rain_summary_temp_dir <- tempfile("rain_summary_")
dir.create(rain_summary_temp_dir)

rain_summary_temp <- file.path(
  rain_summary_temp_dir,
  "L2_PRT_RainGauge_Monthly_Summary.csv"
)

write_csv(rain_summary_data, rain_summary_temp)

write_rain_file(rain_summary_temp)

unlink(rain_summary_temp_dir, recursive = TRUE)


# ========================== Combine rain gauge plots =========================

combine_rain_plots <- function(plot_dir, output_file) {
  
  plot_files <- list.files(
    plot_dir,
    pattern = "\\.pdf$",
    full.names = TRUE,
    ignore.case = TRUE
  ) %>%
    str_subset(regex("archive", ignore_case = TRUE), negate = TRUE) %>%
    sort()
  
  if (length(plot_files) > 0) {
    qpdf::pdf_combine(
      input = plot_files,
      output = output_file
    )
  } else {
    message("No PDFs found in ", plot_dir)
  }
}

combine_rain_plots(
  "./04_Plots/L1",
  "./05_PublishReadyData/L1_PRT_RainGauge_Plots.pdf"
)

combine_rain_plots(
  "./04_Plots/L2",
  "./05_PublishReadyData/L2_PRT_RainGauge_Plots.pdf"
)


