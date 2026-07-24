"""Example: download CSV files from an ESS-DIVE landing page using the API."""

# Function, example, and readme were created using Chat GPT-5.5 in Codex.

from ESS_DIVE_download_API_function import download_essdive_csvs


# For detailed information on the function that uses the API to download csv
# files from an ESS-DIVE landing page, refer to the README.md file.


# USER INPUTS

your_package_link = "https://data.ess-dive.lbl.gov/view/doi%3A10.15485%2F3374642"


# RUN function (no modifications needed)

data_package_csvs = download_essdive_csvs(package_link=your_package_link)


# View csv files loaded into the dictionary
print(data_package_csvs.keys())


# Example: access individual csv files from the returned dictionary
field_metadata = data_package_csvs["WHONDRS_TAP_Field_Metadata"]
npoc_tn = data_package_csvs["WHONDRS_TAP_Water_NPOC_TN"]
