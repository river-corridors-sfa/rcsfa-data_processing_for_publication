### download_ESS-DIVE_landing_page_data_API_function.R #########################

# Download csv files from a public ESS-DIVE landing page using the ESS-DIVE API

# Function, example, and readme were created using Chat GPT-5.5 in Codex

### Function ###################################################################
download_essdive_csvs <- function(package_link) {
  if (!is.character(package_link) || length(package_link) != 1 || is.na(package_link)) {
    stop("package_link must be one ESS-DIVE data package URL.", call. = FALSE)
  }

  required_packages <- c("dplyr", "httr2", "purrr", "readr", "stringr", "tibble")
  missing_packages <- required_packages[
    !vapply(required_packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))
  ]

  if (length(missing_packages) > 0) {
    stop(
      "Please install required package(s): ",
      paste(missing_packages, collapse = ", "),
      call. = FALSE
    )
  }

  package_link <- package_link |>
    utils::URLdecode() |>
    stringr::str_trim() |>
    stringr::str_remove("#.*$") |>
    stringr::str_remove("[?].*$")

  package_id <- stringr::str_extract(
    package_link,
    stringr::regex("doi:10\\.[^[:space:]]+", ignore_case = TRUE)
  )

  if (is.na(package_id)) {
    package_id <- stringr::str_extract(
      package_link,
      stringr::regex("10\\.[^[:space:]]+", ignore_case = TRUE)
    )

    if (!is.na(package_id)) {
      package_id <- paste0("doi:", package_id)
    }
  }

  if (is.na(package_id)) {
    stop(
      "Could not find a DOI in package_link. Expected a link like ",
      "https://data.ess-dive.lbl.gov/view/doi:10.xxxx/xxxxx",
      call. = FALSE
    )
  }

  metadata_url <- paste0(
    "https://api.ess-dive.lbl.gov/packages/",
    utils::URLencode(package_id, reserved = TRUE)
  )

  metadata <- httr2::request(metadata_url) |>
    httr2::req_user_agent("R ESS-DIVE CSV downloader") |>
    httr2::req_options(http_version = 2L) |>
    httr2::req_retry(max_tries = 5) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = FALSE)

  if (!is.null(metadata$citation)) {
    cat("\nData package citation:\n")
    cat(metadata$citation, "\n\n")
    cat("Please add this citation to any resulting publications that use these data.\n\n")
  }

  distributions <- metadata$dataset$distribution

  if (is.null(distributions) || length(distributions) == 0) {
    stop("No files were found for this ESS-DIVE package.", call. = FALSE)
  }

  files <- purrr::map_dfr(distributions, function(file) {
    tibble::tibble(
      file_url = if (is.null(file$contentUrl)) NA_character_ else file$contentUrl,
      file_name = if (is.null(file$name)) NA_character_ else file$name,
      file_type = if (is.null(file$encodingFormat)) NA_character_ else file$encodingFormat
    )
  }) |>
    dplyr::filter(!is.na(.data$file_url)) |>
    dplyr::mutate(
      file_kind = dplyr::case_when(
        stringr::str_detect(.data$file_name, stringr::regex("[.]csv$", ignore_case = TRUE)) |
          stringr::str_detect(.data$file_type, stringr::regex("csv", ignore_case = TRUE)) ~ "csv",
        stringr::str_detect(.data$file_name, stringr::regex("[.]zip$", ignore_case = TRUE)) |
          stringr::str_detect(.data$file_type, stringr::regex("zip", ignore_case = TRUE)) ~ "zip",
        TRUE ~ "other"
      )
    ) |>
    dplyr::filter(.data$file_kind %in% c("csv", "zip"))

  if (nrow(files) == 0) {
    stop("No CSV files or ZIP files were found for this ESS-DIVE package.", call. = FALSE)
  }

  download_dir <- file.path(
    tempdir(),
    paste0("essdive_", stringr::str_replace_all(package_id, "[^A-Za-z0-9]+", "_"))
  )
  dir.create(download_dir, recursive = TRUE, showWarnings = FALSE)
  
  on.exit(unlink(download_dir, recursive = TRUE), add = TRUE)

  csv_files <- dplyr::filter(files, .data$file_kind == "csv")
  zip_files <- dplyr::filter(files, .data$file_kind == "zip")
  data_package_csvs <- list()

  for (i in seq_len(nrow(csv_files))) {
    file_path <- file.path(download_dir, csv_files$file_name[i])
    httr2::request(csv_files$file_url[i]) |>
      httr2::req_user_agent("R ESS-DIVE CSV downloader") |>
      httr2::req_options(http_version = 2L) |>
      httr2::req_retry(max_tries = 5) |>
      httr2::req_perform(path = file_path)

    object_name <- csv_files$file_name[i] |>
      basename() |>
      tools::file_path_sans_ext() |>
      stringr::str_replace_all("[^A-Za-z0-9_]+", "_") |>
      stringr::str_remove("^_+") |>
      stringr::str_remove("_+$")

    if (!nzchar(object_name)) {
      object_name <- "essdive_csv"
    }

    object_name <- make.names(object_name, unique = FALSE)
    data_package_csvs[[object_name]] <- suppressWarnings(
      readr::read_csv(
        file_path,
        comment = "#",
        show_col_types = FALSE
      )
    )
  }

  file_metadata <- data_package_csvs |>
    purrr::keep(~ all(c("File_Name", "Header_Rows", "Column_or_Row_Name_Position", "File_Path") %in% names(.x))) |>
    purrr::list_rbind()

  skipped_metadata_headers <- character()

  if (!is.null(file_metadata) && nrow(file_metadata) > 0) {
    for (i in seq_len(nrow(csv_files))) {
      file_path <- file.path(download_dir, csv_files$file_name[i])
      object_name <- csv_files$file_name[i] |>
        basename() |>
        tools::file_path_sans_ext() |>
        stringr::str_replace_all("[^A-Za-z0-9_]+", "_") |>
        stringr::str_remove("^_+") |>
        stringr::str_remove("_+$")

      if (!nzchar(object_name)) {
        object_name <- "essdive_csv"
      }

      object_name <- make.names(object_name, unique = FALSE)

      file_metadata_row <- file_metadata |>
        dplyr::filter(
          .data$File_Name == basename(csv_files$file_name[i]),
          .data$File_Path == "/"
        ) |>
        dplyr::slice(1)

      header_rows <- file_metadata_row |>
        dplyr::filter(.data$File_Name == basename(csv_files$file_name[i])) |>
        dplyr::pull(.data$Header_Rows) |>
        (\(x) suppressWarnings(as.numeric(x)))() |>
        purrr::discard(is.na)

      column_name_position <- file_metadata_row |>
        dplyr::filter(.data$File_Name == basename(csv_files$file_name[i])) |>
        dplyr::pull(.data$Column_or_Row_Name_Position) |>
        (\(x) suppressWarnings(as.numeric(x)))() |>
        purrr::discard(is.na)

      header_row <- if (length(column_name_position) > 0 && column_name_position[1] > 0) {
        column_name_position[1]
      } else {
        1
      }

      rows_before_data <- if (length(header_rows) > 0 && header_rows[1] > 0) {
        header_rows[1]
      } else {
        header_row
      }

      file_lines <- readr::read_lines(file_path)
      counted_line_numbers <- which(!stringr::str_starts(stringr::str_trim(file_lines), "#"))
      column_name_physical_line <- counted_line_numbers[header_row]
      first_data_physical_line <- counted_line_numbers[rows_before_data] + 1

      column_names <- readr::read_csv(
        I(file_lines[column_name_physical_line]),
        col_names = FALSE,
        show_col_types = FALSE
      ) |>
        unlist(use.names = FALSE) |>
        as.character()

      data_lines <- if (!is.na(first_data_physical_line)) {
        file_lines[first_data_physical_line:length(file_lines)]
      } else {
        character()
      }

      data_package_csvs[[object_name]] <- suppressWarnings(
        readr::read_csv(
          I(paste(data_lines, collapse = "\n")),
          col_names = column_names,
          show_col_types = FALSE
        )
      )

      if (rows_before_data > header_row) {
        skipped_metadata_headers <- c(
          skipped_metadata_headers,
          basename(csv_files$file_name[i])
        )
      }
    }
  }

  if (!is.null(file_metadata) && nrow(file_metadata) > 0 && nrow(zip_files) > 0) {
    csv_paths <- file_metadata |>
      dplyr::filter(stringr::str_detect(.data$File_Name, stringr::regex("[.]csv$", ignore_case = TRUE))) |>
      dplyr::pull(.data$File_Path) |>
      unique()

    zip_files <- zip_files |>
      dplyr::filter(purrr::map_lgl(.data$file_name, function(file_name) {
        zip_folder <- paste0("/", tools::file_path_sans_ext(file_name))
        any(stringr::str_starts(csv_paths, stringr::fixed(zip_folder)))
      }))
  }

  for (i in seq_len(nrow(zip_files))) {
    zip_path <- file.path(download_dir, zip_files$file_name[i])
    unzip_dir <- file.path(download_dir, tools::file_path_sans_ext(zip_files$file_name[i]))

    httr2::request(zip_files$file_url[i]) |>
      httr2::req_user_agent("R ESS-DIVE CSV downloader") |>
      httr2::req_options(http_version = 2L) |>
      httr2::req_retry(max_tries = 5) |>
      httr2::req_perform(path = zip_path)

    utils::unzip(zip_path, exdir = unzip_dir)

    csv_paths <- list.files(
      unzip_dir,
      pattern = "[.]csv$",
      recursive = TRUE,
      full.names = TRUE,
      ignore.case = TRUE
    )

    for (csv_path in csv_paths) {
      object_name <- csv_path |>
        basename() |>
        tools::file_path_sans_ext() |>
        stringr::str_replace_all("[^A-Za-z0-9_]+", "_") |>
        stringr::str_remove("^_+") |>
        stringr::str_remove("_+$")

      if (!nzchar(object_name)) {
        object_name <- "essdive_csv"
      }

      object_name <- make.names(object_name, unique = FALSE)

      csv_path_slash <- gsub("\\\\", "/", csv_path)
      unzip_dir_slash <- gsub("\\\\", "/", unzip_dir)
      relative_inside_zip <- stringr::str_remove(
        csv_path_slash,
        stringr::fixed(paste0(unzip_dir_slash, "/"))
      )
      relative_csv_path <- paste0(
        "/",
        tools::file_path_sans_ext(zip_files$file_name[i]),
        "/",
        relative_inside_zip
      ) |>
        stringr::str_replace_all("/+", "/")

      relative_csv_dir <- dirname(relative_csv_path)

      file_metadata_row <- if (!is.null(file_metadata) && nrow(file_metadata) > 0) {
        file_metadata |>
          dplyr::filter(
            .data$File_Name == basename(csv_path),
            .data$File_Path == relative_csv_dir
          ) |>
          dplyr::slice(1)
      } else {
        tibble::tibble()
      }

      header_rows <- if (!is.null(file_metadata) && nrow(file_metadata) > 0) {
        file_metadata_row |>
          dplyr::pull(.data$Header_Rows) |>
          (\(x) suppressWarnings(as.numeric(x)))() |>
          purrr::discard(is.na)
      } else {
        numeric()
      }

      column_name_position <- if (!is.null(file_metadata) && nrow(file_metadata) > 0) {
        file_metadata_row |>
          dplyr::pull(.data$Column_or_Row_Name_Position) |>
          (\(x) suppressWarnings(as.numeric(x)))() |>
          purrr::discard(is.na)
      } else {
        numeric()
      }

      header_row <- if (length(column_name_position) > 0 && column_name_position[1] > 0) {
        column_name_position[1]
      } else {
        1
      }

      rows_before_data <- if (length(header_rows) > 0 && header_rows[1] > 0) {
        header_rows[1]
      } else {
        header_row
      }

      file_lines <- readr::read_lines(csv_path)
      counted_line_numbers <- which(!stringr::str_starts(stringr::str_trim(file_lines), "#"))
      column_name_physical_line <- counted_line_numbers[header_row]
      first_data_physical_line <- counted_line_numbers[rows_before_data] + 1

      column_names <- readr::read_csv(
        I(file_lines[column_name_physical_line]),
        col_names = FALSE,
        show_col_types = FALSE
      ) |>
        unlist(use.names = FALSE) |>
        as.character()

      data_lines <- if (!is.na(first_data_physical_line)) {
        file_lines[first_data_physical_line:length(file_lines)]
      } else {
        character()
      }

      data_package_csvs[[object_name]] <- suppressWarnings(
        readr::read_csv(
          I(paste(data_lines, collapse = "\n")),
          col_names = column_names,
          show_col_types = FALSE
        )
      )

      if (rows_before_data > header_row) {
        skipped_metadata_headers <- c(
          skipped_metadata_headers,
          basename(csv_path)
        )
      }
    }
  }

  names(data_package_csvs) <- make.names(names(data_package_csvs), unique = TRUE)
  if (length(skipped_metadata_headers) > 0) {
    warning(
      "Metadata header rows were skipped for: ",
      paste(unique(skipped_metadata_headers), collapse = "; "),
      call. = FALSE
    )
  }

  data_package_csvs
}
