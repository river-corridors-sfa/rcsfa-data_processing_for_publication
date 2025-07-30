# Data Package Checks In GitHub Actions README

For information on the underlying data package checks, see [README_data_package_checks.md](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Package_Validation/README_data_package_checks.md). 

## GitHub Action
Using the GitHub actions, we can automatically run the data checks report on the files in a GitHub repository when a commit is made. This means that authors can be checking that they are complying with RC-SFA requirements and recommendations from the beginning and during the iterative process of analyses. 

## GitHub Action
To implement the GitHub action, create a folder in your repository called "data_checks_reports". Add [this R markdown](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Package_Validation/functions/checks_report.Rmd) into that folder. Also add a folder called ".github" with a subfolder called "workflows". Add the [yml file]() (in this folder) to that the workflows folder within your repo. Once you commit this change, the GitHub action will start running and the data checks report will be outputted into your "data_checks_reports" folder. *Note: The GitHub action will create a commit for this so you will need to pull prior to your next commit.*

## Assumptions
Using this GitHub action for the data checks assumes that there are no header rows in your data (if a header row is hashed, this will automatically be skipped and is not considered having a header row). If you have header rows, the data checks will have to be run manually using [data_package_checks.R](https://github.com/river-corridors-sfa/rcsfa-data_processing_for_publication/blob/main/Data_Package_Validation/data_package_checks.R).