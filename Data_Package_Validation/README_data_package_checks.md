# Data Package Checks README
This readme describes the background context, development, and use of the data package checks. 
## what and why data checks
The idea for developing a system to computationally check a data package arose out of a desire to ensure data quality and consistency while reducing manual effort and human error when publishing data packages. 

The data management team (Amy, Brie, Bibi) brainstormed a series of checks to build out. In brief, the data checks were developed to detect missing or unexpected values, identify anomalies, and check for standardized compliance with [ESS-DIVE reporting format](https://ess-dive.lbl.gov/data-reporting-formats/) guidelines. 

However, the data checks are not intended to interpret the meaning of the data, assess scientific validity, fix issues that were detected, or replace human judgement. Authors and domain experts must still review the data and make context-specific decisions before publishing. 
## how the data checks were developed
I (Bibi) developed the structure and code for the bulk of the data checks, with support from Brie and Amy. The code was developed and version controlled in the `rcsfa-data_processing_for_publication` GitHub repo ([link](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication)). 

Here is the approach I took to create the checks. I first wrote `checks.R` and `test-checks.R`, which contains all of the functions used to check the data and confirm those functions run as intended. I then wrote code (`checks_report.Rmd`) to visualize the results. All of those functions and code are sourced into in `data_package_checks.R` to provide a single place to go to run checks for each data package. 

For a bit more detail about each of those 4 scripts and an explanation of the functions: 
### `checks.R`
This script contains 3 parts and is the meat of the data checks. 

Part 1 is a modular user-defined list that lets the user adjust common parameters. These parameters include required file strings, what's considered a special character, a non-complete list of proprietary formats that aren't allowed, and values that count as missing values. While not designed to change between data packages, I thought these parameters were the most likely to change after larger project wide decisions or updates to reporting formats. Separating these inputs will hopefully allow for some modularity and prolong the lifespan of the code written in Parts 2 and 3. 

Part 2 contains the core functions responsible for performing data quality checks. Each function examines an aspect of the input data package and returns a standardized data checks df with the following fields: `requirement`, `pass_check`, `assessment`, `source`, `value`, and `file`. The checks use the input parameters defined in Part 1 to check for the following:
- `check_for_required_file_strings()` = given all files listed in the directory, when the files match the required file strings provided in Part 1, then the check passes. 
- `check_for_no_special_chrs()` = given a string (either a file, folder, or column name), when the string does not contain any of the special characters provided in Part 1, then the check passes.  
- `check_for_no_proprietary_files()` = given a file name, when the string doesn't match any of the extensions provided in Part 1, then the check passes.
- `check_for_unique_names()` = given a column header and a vector of all column headers in the data package, when the string is not present more than once in the vector, then the check passes. 
- `check_for_empty_column_headers()` = given a string, when it says "EMPTY_COLUMN_HEADER", then the check fails. `check_data_package()` temporarily renames any unnamed column to "EMPTY_COLUMN_HEADER", so this check will flag text strings that match that temporary column name, essentially checking if there are any column headers that are empty in the actual data package files. 
- `create_range_report()` = given a data frame, when each column is parsed, then it creates a new df where each row indicates the column's name, data type, number of rows, number of unique rows, number of missing rows, and a preview of the most common values. If applicable, it also gives the min value, max value, and a count of how many negative values are present. 

Part 3 is the final function that combines Parts 1 and 2 to run checks at a data package level. While this entire script is sourced into `data_package_checks.R`, it's this only this final function that's actually used (with all of the Part 2 functions embedded within) in other scripts.
- `check_data_package()` = loops through all files in the data package and runs the checks from Part 2 on each folder, file, and column name the data package. It relies on the standardized outputs of each of the checks functions in Part 2 to be able to aggregate and then summarize the results. The inputs are the data package list generated from `load_tabular_data_from_flmd()` and the `input_parameters` identified at the top of `checks.R`. The output of this function returns a list that includes a tibble of all checks, a tibble that summarizes those checks, and a tibble with the tabular range reports. This output serves as the input for `checks_report.Rmd`. 
### `test-checks.R`
This script is meant to confirm the functions in the `checks.R` file behave as expected under different conditions. Generally each function is tested to show that the code runs as expected for typical inputs and edge cases and that it also throws errors and warnings as expected. Anytime an update is made to the functions within `checks.R`, follow the directions commented at the top of the `test-checks.R` to add to and/or rerun the test script to confirm that your new changes didn't break any existing functionality. The functions were written with a TDD process (search "briefly explain test driven development with test that" in ChatGPT for more details). 
### `checks_report.Rmd`
This script uses the outputs from `check_data_package()` to create a visual report for each data package check, telling you which checks the data package passed. It is broken into 3 parts. Part 1 gives you an overview and tells you whether your data package passed required and strongly recommended tests. Part 2 breaks down those results into tables and figures for each check. Part 3 gives you a detailed report separating out the failed and passed checks. 

While you can run and test the code chunk by chunk, to generate the full html report use the `render()` function. 
``` R
# set the working directory to `rcsfa-data_processing_for_publication`

# then run `render()`
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document")`. 
```
### `data_package_checks.R`
This is the script you will primarily interface with. It sources in all the functions and scripts mentioned above. After asking for data package specific inputs, it loads in your data package data, runs the checks, and then generates the html report. 
## existing limitations and considerations
A few notes on the limitations of these data checks. 
- For a more detailed list of assumptions made for each function or script, see the comments in the script. 
- This pipeline was developed and tested on a Windows 10 machine with R version 4.3.1 "Beagle Scouts" and the following R packages: `tidyverse` v2.0.0,  `rlog` v0.1.0, `devtools` v2.4.5, `hms` v1.1.3, `fs` v1.6.2, `clipr` v0.8.0, `knitr` v1.4.3, `kableExtra` v1.4.0, `DT` v0.3.3, `rmarkdown` v2.2.3, `plotly` v4.10.4, `downloadthis` v.0.4.1
- These data checks were designed to enhance compliance with ESS-DIVE reporting formats and Fusion database. 
- The tabular range reports currently only work on .csv and .tsv file extensions. 
- It relies on the output of `load_tabular_data_from_flmd()`. This function was built out to accommodate reading in files that have header info. This function and aspect of the data checks could be streamlined and made more efficient if all files did not have header rows. 
- Any header rows that were removed in order to parse the tabular data are not included or accessed in the data checks. 
- The checks focus on structural compliance (e.g., required fields, file presence), not content accuracy or domain-specific logic (e.g., biologically plausible values).
- The pipeline may be slow or memory-intensive on very large datasets or directories with deeply nested files.
- A few ideas for future enhancements: 
	- Incorporating reporting format specific checks (e.g., FLMD checks that confirm the Standard matches the reporting format keywords).
	- Sample name and rep checks that compare sample names across files. 
	- A check that looks for lowercase, title case, and capital differences for column headers that share the same definition (e.g., Site_ID vs site_id)
## FAQs

### how to run data checks on a daily basis
In short, I wrote `data_package_checks.R` as a way to easily and consistently run the data checks. This script asks for some user inputs and then runs all the code in the correct order. However, if you wish to create a separate script to run the checks, you can reference these code chunks below. 
#### clone the GitHub repo
Clone this repo to your local machine: https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication.git
``` bash
# open terminal (mac) or git bash (windows)

# check your current location
pwd
# change to the parent directory you want the repo to be saved to
cd Desktop
# now clone the repo
git clone https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication.git
```
#### define the user inputs
Copy this chunk into your script, fill out the 3 user inputs, and then run this chunk. 
``` R
# absolute path of the data package directory (do not include a "/" at the end)
directory <- ""

# provide the name of the person running the checks
report_author <- ""

# provide the directory (do not include "/" at the end) for the data package report - the report will be saved as Checks_Report_YYYY-MM-DD.html
report_out_dir <- ""

# does the tabular files have header rows? (T/F)
user_input_has_header_rows <- T
```
#### set your working directory and load libraries
Copy this chunk into your script, set your working directory, and then run this chunk. 
``` R
# the render() function requires you to have the wd set to the rcsfa-data_processing_for_publication repo
current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))
setwd("./..")

# load libraries - use `install.packages()` in the console if you don't have any
library(tidyverse)
library(rlog)
library(devtools) # for sourcing from github
library(hms) # for handling times
library(fs) # for tree diagram
library(clipr) # for copying to clipboard
library(knitr) # for kable
library(kableExtra) # for rmd report table styling
library(DT) # for interactive tables in report
library(rmarkdown) # for rendering report
library(plotly) # for interactive graphs
library(downloadthis) # for downloading tabular data report as .csv

# load functions
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Transformation/functions/load_tabular_data_from_flmd.R") # note: will need to update this link after I merge branches
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/database_v2/Data_Package_Documentation/functions/create_flmd_skeleton_v2.R") # note: will need to update this link after I merge branches
source_url("https://raw.githubusercontent.com/river-corridors-sfa/rcsfa-data_processing_for_publication/main/Data_Package_Validation/functions/checks.R")
```
#### load in the data
Copy this chunk into your script, run it without modification, and answer inline prompts as they appear. 
``` R
# confirm directory has files in it
if (length(list.files(directory, recursive = T)) == 0) {
  warning("Your directory has 0 files.")
}

# 1. Load flmd
data_package_flmd <- create_flmd_skeleton(directory = directory, query_header_info = user_input_has_header_rows) %>% 
  # convert to R's NA
  mutate(across(everything(), ~ case_when(. == -9999 ~ NA, 
                                          . == "N/A" ~ NA,
                                          TRUE ~ .)))

# 2. Load data
data_package_data <- load_tabular_data_from_flmd(directory = directory, flmd_df = data_package_flmd, query_header_info = user_input_has_header_rows)

# preview data
invisible(lapply(names(data_package_data$tabular_data), function(name) {
  cat("\n--- Data Preview of", name, "---\n")
  glimpse(data_package_data$tabular_data[[name]])
  print(data_package_data$tabular_data[[name]])
}))
```
#### run the checks
Copy this chunk into your script and run it without modification. 
``` R 
# 3. Run checks
data_package_checks <- check_data_package(data_package_data = data_package_data, input_parameters = input_parameters)
```
#### generate the report
Copy this chunk into your script and run it without modification. It will output the html report into `~/Data_Package_Validation/functions`
``` R
# 4. Generate report
out_file <- paste0("Checks_Report_", Sys.Date(), ".html")
render("./Data_Package_Validation/functions/checks_report.Rmd", output_format = "html_document", output_dir = report_out_dir, output_file = out_file)
browseURL(paste0(report_out_dir, "/", out_file))
```
### how to approach trouble shooting if the code breaks
1. Restart your R session and try again. 
2. Make sure all the data loaded in correctly. See the comments in the `check_data_package()` function for the list structure that's required. 
3. Double check that your inputs are in the correct format. Open each function or see the `checks.R` script comments for each function's inputs, dependencies, and assumptions. 
4. If it's still broken, open `check.R` and run through the `check_data_package()` function line by line. Then run each chunk in `checks_report.Rmd` to make sure each chunk runs before generating the report with the `render()` function. If you make any edits to the `checks.R` function, make sure to rerun `test-checks.R` to confirm you didn't break anything in the process of fixing your issue. See the section below (how to approach updating the code) for more details if you're editing the code. 
5. If it's still not working, open up `test-checks.R` to confirm the underlying function tests still pass. You can also try running the checks on another data package or a sub directory to see if the issue repeats itself. 
6. If it's still angry, give up and try again tomorrow lol. 
### how to approach updating the code
#### if you want to fix an existing check:
1. Open up the `test-checks.R` and figure out which checks are failing. If none are failing, write a new test that describes the behavior you want. This test should fail. 
2. Update the function to fix the code. 
3. Return to the test and rerun it. It should pass. 
4. If you continue to make updates to the function, make sure the tests still pass. 
5. Once you think you're all done making fixes, restart R and then rerun all checks in `test-checks.R`. Then rerun your data package to confirm the code runs smoothly within the whole workflow. 
#### if you want to add a new check
This process is similar to fixing an existing check. To continue to follow a test-driven development approach: 
1. Open up `test-checks.R` and write a series of new tests to describe the expected behavior you want. These tests should include typical inputs and edge cases, as well as the errors or warnings you expect the function to throw. 
2. Open `checks.R` and write the new function. Try to match the input and output formats of the other functions for consistency. 
3. Return to `test-checks.R` and rerun the checks. Iterate until the tests pass. 
4. Now integrate the new function you wrote into the `check_data_package()` function and the `checks_report.Rmd` script. 
#### if you want to modify the report
For modifying `checks_report.Rmd`, I don't have specific guidance nor did I use a TDD approach for it, so modify however best fits with your workflow. However, this is generally how I did it: 
1. Edit a specific chunk. 
2. Run the chunk in isolation to make sure it runs. 
3. Open `data_package_checks.R` and run a data package through the checks and render the report. 
4. Check the report for section you updated. 
