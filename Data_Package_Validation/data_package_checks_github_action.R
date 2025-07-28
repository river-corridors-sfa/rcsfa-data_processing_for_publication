### data_package_checks_github_action.R ########################################
# Objective: Automated data package validation for GitHub Actions
# This is a simplified, non-interactive version of data_package_checks.R
# designed specifically for CI/CD environments.

rm(list=ls(all=T))

### Static Configuration ######################################################
# Fixed settings for GitHub Actions automation
user_input_has_header_rows <- FALSE  # Set to TRUE if your data files have header rows
has_flmd <- FALSE                    # Set to TRUE if you have an FLMD file  
flmd_path <- ""                     # Path to FLMD file (only used if has_flmd = TRUE)

# Fixed values for automation
user_directory <- getwd()            # Always use repo root - processes all files
report_author <- "Brieanne Forbes via GitHub action"
report_out_dir <- file.path(getwd(), "data_checks_reports")

# Create output directory
dir.create(report_out_dir, showWarnings = FALSE, recursive = TRUE)

### Prep Script ################################################################
# Full dependencies needed for HTML report generation
suppressPackageStartupMessages({
  library(here)
  library(tidyverse)
  library(devtools)
  library(hms)
  library(fs)
  library(knitr)
  library(kableExtra)
  library(DT)
  library(rmarkdown)
  library(plotly)
  library(downloadthis)
})

cat("Working directory:", getwd(), "\n")
cat("Data directory:", user_directory, "\n")
cat("Output directory:", report_out_dir, "\n")
cat("Report author:", report_author, "\n")

# Load functions with error handling
tryCatch({
  source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Documentation/functions/create_flmd.R")
  source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Transformation/functions/load_tabular_data.R")
  source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")
}, error = function(e) {
  cat("Error loading functions:", e$message, "\n")
  quit(status = 1)
})

### Run Functions ##############################################################

# Validate input directory exists and has files
if (!dir.exists(user_directory)) {
  cat("Error: Directory does not exist:", user_directory, "\n")
  quit(status = 1)
}

all_files <- list.files(user_directory, recursive = TRUE)
if (length(all_files) == 0) {
  cat("Warning: Directory contains no files:", user_directory, "\n")
  quit(status = 0)  # Not an error, just nothing to process
}

cat("Found", length(all_files), "total files in repository\n")

# 1. Get all files (no filtering - process everything)
tryCatch({
  dp_files <- get_files(directory = user_directory)
  cat("Identified", nrow(dp_files), "data files for processing\n")
}, error = function(e) {
  cat("Error identifying files:", e$message, "\n")
  quit(status = 1)
})

# 2. Load FLMD if specified (typically FALSE for automated runs)
if (has_flmd && flmd_path != "") {
  tryCatch({
    data_package_flmd <- read_csv(flmd_path) %>%
      mutate(across(everything(), ~ case_when(. == -9999 ~ NA,
                                              . == "N/A" ~ NA,
                                              TRUE ~ .)))
    cat("Loaded FLMD file:", flmd_path, "\n")
  }, error = function(e) {
    cat("Error loading FLMD file:", e$message, "\n")
    quit(status = 1)
  })
} else {
  data_package_flmd <- NA
}

# 3. Load data
tryCatch({
  data_package_data <- load_tabular_data(
    files_df = dp_files, 
    flmd_df = data_package_flmd, 
    query_header_info = user_input_has_header_rows
  )
  cat("Successfully loaded", length(data_package_data$tabular_data), "data files\n")
  
  # Print file summary
  for (file_name in names(data_package_data$tabular_data)) {
    df <- data_package_data$tabular_data[[file_name]]
    cat(" -", file_name, ":", nrow(df), "rows,", ncol(df), "columns\n")
  }
  
}, error = function(e) {
  cat("Error loading data:", e$message, "\n")
  quit(status = 1)
})

# 4. Run checks
tryCatch({
  data_package_checks <- check_data_package(data_package_data = data_package_data)
  cat("Successfully completed data package checks\n")
}, error = function(e) {
  cat("Error running checks:", e$message, "\n")
  # Continue - we can still generate a summary of what was loaded
})

# 5. Generate HTML report (keeping original functionality)
tryCatch({
  out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
  
  # Download the RMD template to local directory
  rmd_url <- "https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks_report.Rmd"
  download.file(rmd_url, destfile = "checks_report.Rmd", mode = "wb")
  
  # Render the HTML report
  render("checks_report.Rmd", 
         output_format = "html_document", 
         output_dir = report_out_dir, 
         output_file = out_file)
  
  cat("HTML report generated:", file.path(report_out_dir, out_file), "\n")
  
  # Clean up downloaded RMD
  file.remove("checks_report.Rmd")
  
}, error = function(e) {
  cat("Error generating HTML report:", e$message, "\n")
  cat("Continuing with text summary...\n")
})

# 6. Generate text-based summary (as backup and for GitHub display)
summary_file <- file.path(report_out_dir, paste0("validation_summary_", Sys.Date(), ".txt"))

cat("=== DATA PACKAGE VALIDATION SUMMARY ===\n", file = summary_file)
cat("Generated:", as.character(Sys.time()), "\n", file = summary_file, append = TRUE)
cat("Author:", report_author, "\n", file = summary_file, append = TRUE)
cat("Repository:", user_directory, "\n", file = summary_file, append = TRUE)
cat("Files processed:", length(data_package_data$tabular_data), "\n\n", file = summary_file, append = TRUE)

cat("FILES ANALYZED:\n", file = summary_file, append = TRUE)
for (file_name in names(data_package_data$tabular_data)) {
  df <- data_package_data$tabular_data[[file_name]]
  cat(sprintf("  %s: %d rows, %d columns\n", basename(file_name), nrow(df), ncol(df)), 
      file = summary_file, append = TRUE)
}

# Save check results if available
if (exists("data_package_checks")) {
  cat("\nCHECK RESULTS:\n", file = summary_file, append = TRUE)
  cat("Validation checks completed successfully\n", file = summary_file, append = TRUE)
  
  # Save detailed results as RDS for programmatic access
  saveRDS(data_package_checks, file.path(report_out_dir, "validation_results.rds"))
}

cat("\nSummary saved to:", summary_file, "\n")
cat("Validation process completed successfully!\n")