"""Download CSV files from a public ESS-DIVE landing page using the ESS-DIVE API.

Function, example, and readme were created using Chat GPT-5.5 in Codex.
"""

from __future__ import annotations

import csv
import io
import json
import re
import tempfile
import time
import warnings
import zipfile
from pathlib import Path, PurePosixPath
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote, unquote
from urllib.request import Request, urlopen

import pandas as pd


def download_essdive_csvs(package_link: str) -> dict[str, pd.DataFrame]:
    """Download all CSV files from a public ESS-DIVE data package.

    Parameters
    ----------
    package_link
        ESS-DIVE landing page link for a public data package.

    Returns
    -------
    dict[str, pandas.DataFrame]
        Dictionary of CSV files read as pandas DataFrames.
    """
    if not isinstance(package_link, str) or not package_link.strip():
        raise ValueError("package_link must be one ESS-DIVE data package URL.")

    package_link = _clean_package_link(package_link)
    package_id = _extract_package_id(package_link)

    if package_id is None:
        raise ValueError(
            "Could not find a DOI in package_link. Expected a link like "
            "https://data.ess-dive.lbl.gov/view/doi:10.xxxx/xxxxx"
        )

    metadata_url = f"https://api.ess-dive.lbl.gov/packages/{quote(package_id, safe='')}"
    metadata = _get_json(metadata_url)

    citation = metadata.get("citation")
    if citation is not None:
        print("\nData package citation:")
        print(citation, "\n")
        print("Please add this citation to any resulting publications that use these data.\n")

    distributions = metadata.get("dataset", {}).get("distribution")
    if distributions is None:
        raise ValueError("No files were found for this ESS-DIVE package.")
    if isinstance(distributions, dict):
        distributions = [distributions]
    if len(distributions) == 0:
        raise ValueError("No files were found for this ESS-DIVE package.")

    files = []
    for file_info in distributions:
        file_url = file_info.get("contentUrl")
        file_name = file_info.get("name")
        file_type = file_info.get("encodingFormat")
        if file_url is None:
            continue

        file_kind = _file_kind(file_name, file_type)
        if file_kind in {"csv", "zip"}:
            files.append(
                {
                    "file_url": file_url,
                    "file_name": file_name or Path(file_url).name,
                    "file_type": file_type,
                    "file_kind": file_kind,
                }
            )

    if len(files) == 0:
        raise ValueError("No CSV files or ZIP files were found for this ESS-DIVE package.")

    csv_files = [file_info for file_info in files if file_info["file_kind"] == "csv"]
    zip_files = [file_info for file_info in files if file_info["file_kind"] == "zip"]
    data_package_csvs: dict[str, pd.DataFrame] = {}
    skipped_metadata_headers: list[str] = []

    download_prefix = re.sub(r"[^A-Za-z0-9]+", "_", package_id)
    with tempfile.TemporaryDirectory(prefix=f"essdive_{download_prefix}_") as download_dir:
        download_path = Path(download_dir)

        for file_info in csv_files:
            file_path = download_path / file_info["file_name"]
            _download_file(file_info["file_url"], file_path)
            object_name = _object_name(file_info["file_name"])
            data_package_csvs[object_name] = pd.read_csv(file_path, comment="#")

        file_metadata = _collect_file_metadata(data_package_csvs.values())

        if file_metadata is not None and not file_metadata.empty:
            for file_info in csv_files:
                file_path = download_path / file_info["file_name"]
                object_name = _object_name(file_info["file_name"])
                file_metadata_row = file_metadata[
                    (file_metadata["File_Name"] == Path(file_info["file_name"]).name)
                    & (file_metadata["File_Path"] == "/")
                ].head(1)

                data_package_csvs[object_name] = _read_csv_using_file_metadata(
                    file_path,
                    file_metadata_row,
                )

                if _skipped_metadata_header(file_metadata_row):
                    skipped_metadata_headers.append(Path(file_info["file_name"]).name)

        if file_metadata is not None and not file_metadata.empty and len(zip_files) > 0:
            csv_paths = file_metadata.loc[
                file_metadata["File_Name"].astype(str).str.contains(
                    r"[.]csv$", case=False, na=False
                ),
                "File_Path",
            ].dropna().astype(str).unique()

            filtered_zip_files = []
            for file_info in zip_files:
                zip_folder = f"/{Path(file_info['file_name']).stem}"
                if any(path.startswith(zip_folder) for path in csv_paths):
                    filtered_zip_files.append(file_info)
            zip_files = filtered_zip_files

        for file_info in zip_files:
            zip_path = download_path / file_info["file_name"]
            _download_file(file_info["file_url"], zip_path)
            with zipfile.ZipFile(zip_path) as archive:
                for member in _csv_zip_members(archive):
                    member_path = PurePosixPath(member.filename)
                    object_name = _object_name(member_path.name)
                    relative_csv_path = PurePosixPath(
                        "/",
                        Path(file_info["file_name"]).stem,
                        member_path.as_posix(),
                    ).as_posix()
                    relative_csv_dir = str(PurePosixPath(relative_csv_path).parent)

                    if file_metadata is not None and not file_metadata.empty:
                        file_metadata_row = file_metadata[
                            (file_metadata["File_Name"] == member_path.name)
                            & (file_metadata["File_Path"] == relative_csv_dir)
                        ].head(1)
                    else:
                        file_metadata_row = pd.DataFrame()

                    with archive.open(member) as member_file:
                        file_lines = io.TextIOWrapper(
                            member_file,
                            encoding="utf-8-sig",
                            newline="",
                        ).read().splitlines()

                    data_package_csvs[object_name] = _read_csv_lines_using_file_metadata(
                        file_lines,
                        file_metadata_row,
                    )

                    if _skipped_metadata_header(file_metadata_row):
                        skipped_metadata_headers.append(member_path.name)

    if len(skipped_metadata_headers) > 0:
        warnings.warn(
            "Metadata header rows were skipped for: "
            + "; ".join(dict.fromkeys(skipped_metadata_headers)),
            stacklevel=2,
        )

    return _make_unique_names(data_package_csvs)


def _clean_package_link(package_link: str) -> str:
    package_link = unquote(package_link).strip()
    package_link = re.sub(r"#.*$", "", package_link)
    package_link = re.sub(r"[?].*$", "", package_link)
    return package_link


def _extract_package_id(package_link: str) -> str | None:
    doi_match = re.search(r"doi:10\.\S+", package_link, flags=re.IGNORECASE)
    if doi_match is not None:
        return doi_match.group(0)

    bare_doi_match = re.search(r"10\.\S+", package_link, flags=re.IGNORECASE)
    if bare_doi_match is not None:
        return f"doi:{bare_doi_match.group(0)}"

    return None


def _get_json(url: str) -> Any:
    with _urlopen_with_retry(url, timeout=60) as response:
        return json.loads(response.read().decode("utf-8"))


def _urlopen_with_retry(url: str, timeout: int) -> Any:
    request = Request(url, headers={"User-Agent": "Python ESS-DIVE CSV downloader"})
    retry_statuses = {429, 500, 502, 503, 504}
    last_error: Exception | None = None

    for attempt in range(5):
        try:
            return urlopen(request, timeout=timeout)
        except HTTPError as error:
            if error.code not in retry_statuses:
                raise
            last_error = error
        except URLError as error:
            last_error = error

        if attempt < 4:
            time.sleep(0.5 * (2**attempt))

    if last_error is not None:
        raise last_error
    raise RuntimeError(f"Could not open URL: {url}")


def _file_kind(file_name: Any, file_type: Any) -> str:
    file_name = "" if file_name is None else str(file_name)
    file_type = "" if file_type is None else str(file_type)
    if re.search(r"[.]csv$", file_name, flags=re.IGNORECASE) or re.search(
        "csv", file_type, flags=re.IGNORECASE
    ):
        return "csv"
    if re.search(r"[.]zip$", file_name, flags=re.IGNORECASE) or re.search(
        "zip", file_type, flags=re.IGNORECASE
    ):
        return "zip"
    return "other"


def _download_file(url: str, file_path: Path) -> None:
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with _urlopen_with_retry(url, timeout=120) as response:
        with file_path.open("wb") as file_handle:
            while True:
                chunk = response.read(1024 * 1024)
                if not chunk:
                    break
                if chunk:
                    file_handle.write(chunk)


def _csv_zip_members(archive: zipfile.ZipFile) -> list[zipfile.ZipInfo]:
    csv_members = []
    for member in archive.infolist():
        if member.is_dir() or not member.filename.lower().endswith(".csv"):
            continue

        member_path = PurePosixPath(member.filename)
        if member_path.is_absolute() or ".." in member_path.parts:
            continue

        csv_members.append(member)

    return sorted(csv_members, key=lambda member: member.filename.lower())


def _object_name(file_name: str) -> str:
    object_name = Path(file_name).stem
    object_name = re.sub(r"[^A-Za-z0-9_]+", "_", object_name)
    object_name = re.sub(r"^_+", "", object_name)
    object_name = re.sub(r"_+$", "", object_name)
    if not object_name:
        object_name = "essdive_csv"
    return _make_r_name(object_name)


def _make_r_name(name: str) -> str:
    if re.match(r"^[A-Za-z]", name) is None:
        name = f"X{name}"
    reserved_words = {
        "if",
        "else",
        "repeat",
        "while",
        "function",
        "for",
        "in",
        "next",
        "break",
        "TRUE",
        "FALSE",
        "NULL",
        "Inf",
        "NaN",
        "NA",
        "NA_integer_",
        "NA_real_",
        "NA_complex_",
        "NA_character_",
    }
    if name in reserved_words:
        name = f"{name}."
    return name


def _collect_file_metadata(dataframes: Any) -> pd.DataFrame | None:
    required_columns = {
        "File_Name",
        "Header_Rows",
        "Column_or_Row_Name_Position",
        "File_Path",
    }
    metadata_frames = [
        dataframe
        for dataframe in dataframes
        if required_columns.issubset(set(dataframe.columns))
    ]
    if len(metadata_frames) == 0:
        return None
    return pd.concat(metadata_frames, ignore_index=True)


def _read_csv_using_file_metadata(file_path: Path, file_metadata_row: pd.DataFrame) -> pd.DataFrame:
    return _read_csv_lines_using_file_metadata(
        file_path.read_text(encoding="utf-8-sig").splitlines(),
        file_metadata_row,
    )


def _read_csv_lines_using_file_metadata(
    file_lines: list[str],
    file_metadata_row: pd.DataFrame,
) -> pd.DataFrame:
    header_rows = _metadata_number(file_metadata_row, "Header_Rows")
    column_name_position = _metadata_number(file_metadata_row, "Column_or_Row_Name_Position")

    header_row = column_name_position if column_name_position is not None and column_name_position > 0 else 1
    rows_before_data = header_rows if header_rows is not None and header_rows > 0 else header_row

    counted_indexes = [
        index
        for index, line in enumerate(file_lines)
        if not line.strip().startswith("#")
    ]

    if len(counted_indexes) < header_row:
        return pd.DataFrame()

    column_name_physical_index = counted_indexes[int(header_row) - 1]
    column_names = next(csv.reader([file_lines[column_name_physical_index]]))

    if len(counted_indexes) < rows_before_data:
        return pd.DataFrame(columns=column_names)

    first_data_physical_index = counted_indexes[int(rows_before_data) - 1] + 1
    data_lines = file_lines[first_data_physical_index:]

    if len(data_lines) == 0:
        return pd.DataFrame(columns=column_names)

    csv_text = "\n".join(data_lines)
    if not csv_text.strip():
        return pd.DataFrame(columns=column_names)

    return pd.read_csv(io.StringIO(csv_text), names=column_names)


def _metadata_number(file_metadata_row: pd.DataFrame, column_name: str) -> float | None:
    if file_metadata_row.empty or column_name not in file_metadata_row:
        return None
    values = pd.to_numeric(file_metadata_row[column_name], errors="coerce").dropna()
    if values.empty:
        return None
    return float(values.iloc[0])


def _skipped_metadata_header(file_metadata_row: pd.DataFrame) -> bool:
    header_rows = _metadata_number(file_metadata_row, "Header_Rows")
    column_name_position = _metadata_number(file_metadata_row, "Column_or_Row_Name_Position")
    header_row = column_name_position if column_name_position is not None and column_name_position > 0 else 1
    rows_before_data = header_rows if header_rows is not None and header_rows > 0 else header_row
    return rows_before_data > header_row


def _make_unique_names(dataframes: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    unique_dataframes: dict[str, pd.DataFrame] = {}
    seen: dict[str, int] = {}

    for name, dataframe in dataframes.items():
        if name not in seen:
            seen[name] = 0
            unique_name = name
        else:
            seen[name] += 1
            unique_name = f"{name}.{seen[name]}"
            while unique_name in unique_dataframes:
                seen[name] += 1
                unique_name = f"{name}.{seen[name]}"
        unique_dataframes[unique_name] = dataframe

    return unique_dataframes
