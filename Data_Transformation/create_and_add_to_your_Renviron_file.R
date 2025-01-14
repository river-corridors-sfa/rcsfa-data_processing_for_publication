### create_and_add_to_your_Renivon_file.R ######################################
# Author: Bibi Powers-McCormack
# Date Created: 2024-12-05
# Date Updated: 2024-12-05

# your .Renviron file can be created at any location, allowing you have separate
# ones for each project or a global one used for all projects. Your global
# .Renviron file is usually saved in your home directory.

# assumptions: 
  # this script currently only works on windows machines because of shell.exec()
  # this script currently only works within R studio because of selectDirectory()

### User inputs ################################################################
# choose where to save your .Renviron file
file_location <- "local" # choose between "local" to save to your working dir, or "global" to save to your home dir


### Run script #################################################################

# get path
if(file_location == "local") {
  
  change_wd <- readline(prompt = paste0("Would you like to change your working directory from '", getwd(), "'? Enter Y/N. If Y, select your working directory via the upcoming dialog box. "))
  if (change_wd == "Y") {
    setwd(rstudioapi::selectDirectory())
  }
  
  path <- file.path(paste0(getwd(), "/.Renviron"))
  
} else if (file_location == "global") {
  
  path <- file.path(Sys.getenv("HOME"), ".Renviron")
  
} else {
  
  stop("'file_location' was not correctly provided. You can choose from c('local', 'global').")
  
}

# create .Renvion file if it doesn't already exist
if (!file.exists(path)) {
  file.create(path)
  message(".Renviron file created at: ", path)
} else {
  message(".Renviron file already exists at: ", path)
}

# opens file for you to include whatever you want to your file
shell.exec(path) # include your text making sure to hit return to make a new empty line at the end, save, and exit

# reload the .Renviron file
readRenviron(path)

# show contents of file
print(readLines(path))

# to retrieve and confirm variables, type `Sys.getenv("API_KEY")`, where
# "API_KEY" is the name of your environmental variable, into the console