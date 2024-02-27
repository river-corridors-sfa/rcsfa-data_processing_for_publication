### create_directory_tree.R #############
# Date created: 2024-02-26
# Author: Bibi Powers-McCormack

# Objective: 


###

create_directory_tree <-  function(directory, out_directory = "") {
  
  # load libraries
  library(fs)
  library(rlog)
  
  log_info(paste0("Displaying the tree for '", directory, "'"))
  
  # visualize tree in console
  dir_tree(directory, recurse = T)
  
  # save tree as markdown file
  
  if (out_directory != "") {
  
    user_prompt <- readline(paste0("Do you want to save the tree as a markdown file to ", out_directory, "? (Y/N) "))
    
    if (user_prompt == tolower("y")) {
      
      tree_output <- capture.output(dir_tree(directory, recurse = T))
      
      writeLines(tree_output, paste0(out_directory, "/directory_tree.md"))
      
      shell.exec(paste0(out_directory, "/directory_tree.md"))
      shell.exec(out_directory)
      
      log_info(paste0("Tree saved: ", out_directory, "/directory_tree.md"))
    } 
    
    } else {
      
      log_info("Not saving.")
    
  }
  
  log_info("create_directory_tree complete")

}

