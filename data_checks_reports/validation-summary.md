## 📊 Data Package Validation Results
**Generated:** Mon Jul 28 21:18:46 UTC 2025
**Commit:** 0085ca44b4e36d8fc40a45dfe6bd505fb614a9ed
**Author:** Brieanne Forbes via GitHub action

### ✅ Validation Status
- **Data Loading**: SUCCESS ✅
- **File Processing**: SUCCESS ✅
- **Summary Generation**: SUCCESS ✅

### 📋 Validation Report
```
======================================
    DATA PACKAGE VALIDATION REPORT    
======================================
Generated:  2025-07-28 21:18:46.192501 
Author:  Brieanne Forbes via GitHub action 
Repository:  rcsfa-data_processing_for_publication 
Total files found:  152 
Data files processed:  4 

VALIDATION STATUS:
⚠️  Data validation checks: SKIPPED (function compatibility issue)
✅ Data loading and parsing: SUCCESS
✅ File structure analysis: COMPLETE

DATA FILES ANALYZED:
==================

📄 AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv
   Dimensions: 91 rows × 9 columns
   Path: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv
   Columns:  Dataset Summary Title, Study Code, Link, RC/ST, Type, Material, Newly Added Data Types, Publish_Date, Keywords

📄 All_dd_flmd_as_of_2025-06-05.csv
   Dimensions: 119 rows × 5 columns
   Path: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/All_dd_flmd_as_of_2025-06-05.csv
   Columns:  archived_dd_flmd, sans_dir, date_file_modified, airtable_title, exclude

📄 data_dictionary_database.csv
   Dimensions: 6036 rows × 9 columns
   Path: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/data_dictionary_database.csv
   Columns:  index, Column_or_Row_Name, Unit, Definition, Data_Type, Term_Type, date_published, dd_filename, dd_source

📄 file_level_metadata_database.csv
   Dimensions: 1176 rows × 6 columns
   Path: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication/Data_Package_Documentation/database/file_level_metadata_database.csv
   Columns:  index, File_Name, File_Description, date_published, flmd_filename, flmd_source
==================
Total data rows: 7422
Largest file columns: 9
Average file size: 1855.5 rows

======================================
Report complete. All processable data files have been analyzed.
```

### 🔍 Detailed Processing Log
<details><summary>Click to expand full validation log</summary>

```
=== DATA PACKAGE VALIDATION STARTING ===
Working directory: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication 
Report author: Brieanne Forbes via GitHub action 

Loading validation functions...
ℹ SHA-1 hash of file is "4fa12e6789da6da22482a133d07f4efcdddae1ab"
ℹ SHA-1 hash of file is "e079ac6a08985588b6bc311458bc8142c43ad343"
ℹ SHA-1 hash of file is "3a2447c52efa15df1a81adf36b4f26632da11a36"
✅ Functions loaded successfully

Found 152 total files in repository
2025-07-28 21:18:45.819379 [INFO] Getting file paths from directory.
2025-07-28 21:18:45.821258 [INFO] Excluding 0 of 152 total file(s) in the directory.
2025-07-28 21:18:45.895169 [INFO] get_files() function complete.
Identified 152 data files for processing

Loading data files...
2025-07-28 21:18:46.00043 [INFO] Planning to load 4 tabular files.
2025-07-28 21:18:46.000589 [INFO] Loading in file 1 of 4: AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv
2025-07-28 21:18:46.095317 [INFO] Loading in file 2 of 4: All_dd_flmd_as_of_2025-06-05.csv
2025-07-28 21:18:46.099008 [INFO] Loading in file 3 of 4: data_dictionary_database.csv
2025-07-28 21:18:46.124469 [INFO] Loading in file 4 of 4: file_level_metadata_database.csv
2025-07-28 21:18:46.131682 [INFO] load_tabular_data() function complete.
Warning message:
One or more parsing issues, call `problems()` on your data frame for details,
e.g.:
  dat <- vroom(...)
  problems(dat) 
✅ Successfully loaded 4 data files

FILES LOADED:
  📄 AirTable_DataPackagesInPipeline-PublishedBrief_as_of_2025-06-06.csv: 91 rows, 9 columns
  📄 All_dd_flmd_as_of_2025-06-05.csv: 119 rows, 5 columns
  📄 data_dictionary_database.csv: 6036 rows, 9 columns
  📄 file_level_metadata_database.csv: 1176 rows, 6 columns

Attempting validation checks...
⚠️  Validation checks failed: promise already under evaluation: recursive default argument reference or earlier problems? 
   Continuing with file summary...

Generating summary report...

SUMMARY STATISTICS:
Warning message:
In sprintf("\nSUMMARY STATISTICS:\n", file = summary_file, append = TRUE) :
  2 arguments not used by format '
SUMMARY STATISTICS:
'
✅ Summary report saved to: /home/runner/work/rcsfa-data_processing_for_publication/rcsfa-data_processing_for_publication/data_checks_reports/Data_Validation_Report_2025-07-28.txt 
✅ Data package validation completed successfully!
[1] FALSE
```
</details>

📁 **All files available in:** `data_checks_reports/`
