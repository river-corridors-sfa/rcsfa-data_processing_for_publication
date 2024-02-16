### check_for_no_spaces.R ######################################################
# Date Created: 2024-02-13
# Author: Bibi Powers-McCormack

# Objective: checks a string to see if it contains any spaces

# Inputs: string

# Outputs: 
  # df with 
    # pass_check = T/F if the string passed the assessment
    # item = the string input
    # assessment = name of the assessment being completed


### FUNCTION ###################################################################

check_for_no_spaces <- function(string) {
  
  # check for spaces
  has_spaces <- grepl(" ", string)
  
  # return table
  result <- data.frame(
    pass_check = !has_spaces,
    item = string,
    assessment = "no_spaces",
    note = NA_character_)
  
  return(result)
  
}
