# download data from ESS-DIVE
# Xinming Lin Nov 1st 2023
###############################################################################
# Downloading data from ESS-DIVE
###############################################################################
# # Loading/installing required libraries
librarian::shelf(tidyverse,
                 curl,
                 data.table,
                 utils,
                 purrr)
################################################################################
## function to download file from ESS-DIVE and read file into R
# only files in .csv format will be read into R
download_and_read_data<-function(target_url,filename,downloads_folder,rm_zip=FALSE,rm_unzip_folder=FALSE){
  # target_url: the URL of a specific file you want to download from ESS-DIVE
  # filename: the filename of the file you want to download from ESS-DIVE
  # downloads_folder: target folder to store the downloaded file 
  # rm_zip: whether to remove the downloaded zip file after unzipped the file, default is FALSE
  # rm_unzip_folder: whether to remove the unzip_folder after reading data into R, default is FALSE
  
  cat("WARNING: A newer version of the data package version may be available. \nProviding an outdated URL will result in downloading an older version.\n\nCheck ESS-DIVE for updates before proceeding. Do you want to continue?")
  
  response <- readline(prompt = "(Y/N): ")
  
  if (tolower(response) == "y") {

    

  } else if (tolower(response) == "n") {

    stop("Stopping function.")

  } else {

    stop("ERROR. Stopping function.")
  }
  
  existed_files<- list.files(downloads_folder)
  destfile <-file.path(downloads_folder,filename)
  if (!filename %in% existed_files){
    cat("Downloading...")
    cat("\n")
    curl_download(target_url, destfile =destfile)
  }else{
    cat( filename,'already in folder. Skipping download. Will read in existing files. ')
    cat("\n")
  }
  # Wait for the download to complete
  while (length(list.files(path = downloads_folder, pattern = filename)) == 0) {
    Sys.sleep(5)
  }
  
  # Check if the file is a zip file
  is_zip <- tools::file_ext(destfile) == "zip"
  
  #
  if (length(list.files(downloads_folder,patt=filename))>0){
    if (grepl('.csv',filename)){
      data_name <- tools::file_path_sans_ext(basename(destfile))
      data_in_file<- read.csv(destfile)
      #lines <- readLines(destfile)
      #sidx<-max(grep("#", lines,ignore.case = TRUE))
      #data_in_file[[data_name]]<- read.csv(destfile,header = TRUE,skip=sidx)
    }
    else if (is_zip) {
      # Extract the file name without the extension
      folder_name <- tools::file_path_sans_ext(basename(destfile))
      # Create a new directory with the file name
      new_dir <- file.path(downloads_folder, folder_name)
      if(!dir.exists(new_dir)==T){
        dir.create(new_dir)
        # Unzip the file into the new directory
        unzip(destfile, exdir = new_dir)
        cat('unzipping file', destfile)
        cat("\n")
      }else {
        check_files = list.files(new_dir)
        if (length(check_files)==0){
          unzip(destfile, exdir = new_dir)
          cat('unzipping file', destfile)
          cat("\n")
        }else {
          # doing nothing if files have already been unzipped
          cat("\n")
        }
 
      }
      # all files in folder
      zfiles <- unzip(destfile, list = TRUE)$Name
      # non-photo zip file in sub folders
      zfiles <- zfiles[-grep('Photos',zfiles,ignore.case = TRUE)] # filters out any file names that contain "photos" (case insensitive)
      # Loop through each file and extract
      for (file in zfiles) {
        if(grepl('.zip',file,ignore.case = TRUE)){ # if there are more nested zip files...
          idir <- file.path(new_dir, gsub('.zip', '', file)) # creates a new dir for the sub zip
          if(!dir.exists(idir)==T){dir.create(idir)}
          unzip(file.path(new_dir, file), exdir = idir) # unzips
          if(rm_zip==TRUE){
            file.remove(file.path(new_dir, file)) # removes zip if user had indicated it
          }
        }
      }
      # Get the extracted file paths
      #extracted_files <- list.files(path = new_dir, full.names = TRUE)
      extracted_files <- list.files(path = new_dir)
      
      # Remove the zip file 
      if(rm_zip==TRUE){
        file.remove(destfile)
      }
      # Print the file names within the folder
      cat("Files and folders in", new_dir, "folder:\n")
      cat(paste0(extracted_files, "\n"), sep = "")
      cat("\n")
      cat("Reading in files...")
      cat("\n")
      data_in_file <- list()
      # read the extracted files in folder
      for (fd in extracted_files){
        # check if subfolder exist
        if (dir.exists(file.path(new_dir,fd))){
          # read data in subfolder
          l1_subfolder <- file.path(new_dir,fd)
          l1_files <- list.files(l1_subfolder); 
          l1_files <- l1_files[-grep('.zip',l1_files,ignore.case = TRUE)]
          if (length(l1_files)>0){
            data_sub_file <- list()
            for (sf in l1_files){
              if (dir.exists(file.path(l1_subfolder,sf))){
                l2_subfolder <- file.path(l1_subfolder,sf)
                list_i_files <- list.files(l2_subfolder, pattern = ".csv", recursive = T, full.names = TRUE)
                if (length(list_i_files)>0){
                  #list_sub_names <- list.files(subfolder, pattern = ".csv", recursive = T)
                  lines <- readLines(list_i_files[1])
                  if (any(grepl("#", lines,ignore.case = TRUE))){
                    sidx<-max(grep("#", lines,ignore.case = TRUE))
                    DT <- lapply(list_i_files, function(x) fread(x, skip=sidx, sep=","))
                  }else{
                    DT <- lapply(list_i_files, function(x) fread(x, sep=","))
                  }
                  names(DT) <- sub(".*/", "", list_i_files)
                  data_sub_file[[sf]]<-DT
                }
              }else if(grepl('.csv',sf)){
                l2_fdata<- read_csv(file.path(l1_subfolder, sf), show_col_types = F)
                data_sub_file[[sf]]<- l2_fdata
              }
            }
            # 
            data_in_file[[fd]] <-data_sub_file
          }else{
            list_sub_files <- list.files(l1_subfolder, pattern = ".csv", recursive = T, full.names = TRUE)
            if (length(list_sub_files)>0){
              #list_sub_names <- list.files(subfolder, pattern = ".csv", recursive = T)
              lines <- readLines(list_sub_files[1])
              if (any(grepl("#", lines,ignore.case = TRUE))){
                sidx<-max(grep("#", lines,ignore.case = TRUE))
                DT <- lapply(list_sub_files, function(x) fread(x, skip=sidx, sep=","))
              }else{
                DT <- lapply(list_sub_files, function(x) fread(x, sep=","))
              }
              
              names(DT) <- sub(".*/", "", list_sub_files)
              data_in_file[[fd]]<-DT
            }
          } 
          

        }
        else if(grepl('.csv',fd)){
          # read .csv files in folder
          #dname <- tools::file_path_sans_ext(basename(fd))
          fdata<- read_csv(file.path(new_dir, fd), show_col_types = F)
          data_in_file[[fd]]<- fdata
        }
      }
      
    } 
    if (rm_unzip_folder==TRUE){
      # delete the un_zip directory 
      unlink(new_dir,recursive=TRUE) 
    }
    cat('\n')
    cat('\n')
    cat("STATUS: download_and_read_data() complete.\nThe data package", filename, "can be found in", downloads_folder)
    cat('\n')
    cat("WARNING: The .csv files have been loaded in, however you may experience parsing issues.")
    cat('\n')
    return(data_in_file)
  }else{
    cat("Downloaded file:", filename)
    print('No CSV file found !')
  }
  
}
