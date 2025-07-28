## 📊 Data Package Validation Results
**Generated:** Mon Jul 28 21:54:24 UTC 2025
**Commit:** facbd38777c8c74c049d310bfc33051bfcecb4b4
**Author:** Brieanne Forbes via GitHub action

### ⚠️ Validation Status
Direct function calls are being tested for compatibility.

### 📋 Validation Summary
```
=== DATA PACKAGE VALIDATION SUMMARY ===
Generated: 2025-07-28 21:11:33.532243 
Author: Brieanne Forbes via GitHub action 
Repository: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication 
Files processed: 4 

FILES ANALYZED:
  AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv: 91 rows, 9 columns
  All_dd_flmd_as_of_2025-06-05.csv: 119 rows, 5 columns
  data_dictionary_database.csv: 6036 rows, 9 columns
  file_level_metadata_database.csv: 1176 rows, 6 columns

CHECK RESULTS:
Validation checks failed - see log for details
HTML report generated: FALSE 
```

### 🔍 Processing Details
<details><summary>Click to expand validation log</summary>

```
=== RUNNING WORKING VALIDATION ===
ℹ SHA-1 hash of file is "4fa12e6789da6da22482a133d07f4efcdddae1ab"
ℹ SHA-1 hash of file is "e079ac6a08985588b6bc311458bc8142c43ad343"
ℹ SHA-1 hash of file is "3a2447c52efa15df1a81adf36b4f26632da11a36"
2025-07-28 21:27:20.322579 [INFO] Getting file paths from directory.
2025-07-28 21:27:20.324623 [INFO] Excluding 0 of 155 total file(s) in the directory.
2025-07-28 21:27:20.33578 [INFO] get_files() function complete.
2025-07-28 21:27:20.44245 [INFO] Planning to load 4 tabular files.
2025-07-28 21:27:20.442617 [INFO] Loading in file 1 of 4: AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv
2025-07-28 21:27:20.539964 [INFO] Loading in file 2 of 4: All_dd_flmd_as_of_2025-06-05.csv
2025-07-28 21:27:20.543877 [INFO] Loading in file 3 of 4: data_dictionary_database.csv
2025-07-28 21:27:20.571715 [INFO] Loading in file 4 of 4: file_level_metadata_database.csv
2025-07-28 21:27:20.57913 [INFO] load_tabular_data() function complete.
Warning message:
One or more parsing issues, call `problems()` on your data frame for details,
e.g.:
  dat <- vroom(...)
  problems(dat) 
Loaded 4 data files
Trying explicit input_parameters method...
2025-07-28 21:27:20.655043 [INFO] Running data checks on file 1 of 155: Data_Validation_Report_2025-07-28.txt
Failed with input_parameters: `pattern` must be a string, not NULL. 
Trying minimal parameters method...
Failed with minimal parameters: promise already under evaluation: recursive default argument reference or earlier problems? 
Trying do.call method...
Failed with do.call: promise already under evaluation: recursive default argument reference or earlier problems? 
❌ All validation methods failed
Validation process completed!
```
</details>

📁 **All results available in:** `data_checks_reports/`
