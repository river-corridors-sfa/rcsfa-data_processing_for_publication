### check_for_invalid_chr_in_string.R ##################################################
# Date Created: 2024-02-16
# Author: Bibi Powers-McCormack

# Objective: checks a string to see if it contains any given characters

# Inputs: string, chr to look for

# Outputs: 
# df with 
# pass_check = T/F if the string passed the assessment
# item = the string input
# assessment = name of the assessment being completed


### FUNCTION ###################################################################

check_for_invalid_chr_in_string <- function(string, search_character) {
  
  # check for chr in string
  has_invalid_chr <- !str_detect(string, search_character)
  
  # return table
  result <- data.frame(
    pass_check = has_invalid_chr,
    item = string,
    assessment = paste0("no_invalid_chr: ", search_character),
    note = NA_character_)
  
  return(result)
  
}
