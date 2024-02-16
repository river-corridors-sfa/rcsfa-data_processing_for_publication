### check_for_no_special_chrs.R ################################################
# Date Created: 2024-02-13
# Author: Bibi Powers-McCormack

# Objective: checks a string to see if it contains any special characters.

# Inputs: string

# Outputs: 
  # df with 
    # pass_check = T/F if the string passed the assessment
    # item = the string input
    # assessment = name of the assessment being completed


### FUNCTION ###################################################################

check_for_no_special_chrs <- function(string) {
  
  # split out by character
  split_chrs <- unlist(strsplit(string, ""))
  
  # check for special characters
  has_special_chrs <- length(grep("[^a-zA-Z0-9_/\\.-]", split_chrs)) > 0 # chrs allowed: lowercase letter, uppercase letter, digit, underscore, forward slash, backslash, period, or hyphen.
  
  # get the special character values
  if (has_special_chrs == FALSE) {
    special_characters <- "none"
  } else {
    special_characters <- paste0("\"", paste(grep("[^a-zA-Z0-9_/\\.-]", split_chrs, value = TRUE), collapse = ""), "\"")
  }
  
  # return table
  result <- data.frame(
    pass_check = !has_special_chrs,
    item = string,
    assessment = "no_special_chrs",
    note = paste("special characters:", special_characters, sep = " "))
  
  return(result)
  
}
