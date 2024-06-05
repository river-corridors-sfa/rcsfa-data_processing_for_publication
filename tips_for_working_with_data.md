# Tips for Working with Data
This document contains helpful tips for working with RC SFA data.
## How to use the data dictionary's missing value codes column
The missing value codes column in the dd indicates the code that is used to represent that a given cell does not contain data. Although R prefers `NA`, ESS-DIVE reporting formats prefer `N/A` for character columns and `-9999` for numeric columns. This code example references the missing value codes in the dd to create a vector containing a unique list of all missing value codes that were listed in the dd. It then uses that vector to convert values to R's preferred `NA` value.  

Assumptions: 
- All values listed in the dd will be contained in this vector, meaning that it doesn't account for file to file differences. 
- If any of the values listed anywhere in the missing value codes vector are real values, the code will be stripping actual data (e.g., `-9999` is a real value, `NA` is a real value short for "North America").
``` R
library(tidyverse)

# Load the missing value codes from a CSV file
missing_value_codes <- read_csv("example_dd.csv") %>%  # Read the dd file in
  pull(Missing_Value_Codes) %>%  # Extract the 'Missing_Value_Codes' column as a vector
  str_replace_all(c('"' = '', " " = "")) %>%  # Remove quotes and spaces from the missing value codes
  str_split(";", simplify = TRUE) %>%  # Split the missing value codes at each semicolon to create a vector
  unique()  # Remove duplicate missing value codes from the vector

# Use the missing_value_codes vector to convert to R's preferred NA when reading in files
df <- read_csv("example_data_file.csv", na = missing_value_codes)
```
Alternatively, if you wished to hard code in missing value codes, you can do it like this: 
``` R
df <- read_csv("example_data_file.csv", na = c("NA", "-9999", "", "N/A"))
```
