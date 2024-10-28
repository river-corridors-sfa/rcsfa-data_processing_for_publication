### compare_versions.R ##############################################################
# Date Created: 2023-10-31
# Author: Bibi Powers-McCormack
# Objective: compare two different versions of the same file to identify differences


### Prep #######################################################################

# load libraries
library(tidyverse) # used to read in files
library(daff) # used to compare dfs (with diff_data())
library(tools) # to remove file extension when exporting


# load data
previous_version_path <- file.choose()
new_version_path <- file.choose()
previous_version <- read_csv(previous_version_path)
new_version <- read_csv(new_version_path)

# set out dir
out_dir <- "C:/Users/powe419/Downloads" # only necessary if you plan to save your output; usually viewing with the render_diff() function is sufficient


### Compare versions ###########################################################

compare_versions <- daff::diff_data(previous_version, new_version, 
                                    ordered = F, # set to T if the order of rows matter; set to F if you don't want to compare the row order (F will only look at modified, deleted, and added)
                                    id = c(""), # use this to add primary keys that the match will use to compare; otherwise comment this line out
                                    unchanged_context = 0 # use this to only show the areas that have changes (the default shows nearby unchanged rows for context)
                                    )


### View comparison ###########################################################

# print results to console
print(compare_versions)

# view html
render_diff(compare_versions, view = TRUE)

# how to interpret
  # the @@ column denotes the change
      # green +++ = added rows or columns
      # red --- = removed rows or columns
      # blue -> = changed cells - within the cell that changed you will see the changes separated by an arrow: "old data" -> "new data"
      # yellow ##:## = the location of the original column/row : the location of the updated column/row


### Save comparison ############################################################

out_file_name <- paste0("compare_versions_", format(Sys.Date(), "%Y%m%d"), "_", file_path_sans_ext(basename(previous_version_path)), "_vs_", file_path_sans_ext(basename(new_version_path)), ".html")

# save html
render_diff(compare_versions, file = paste0(out_dir, "/", out_file_name))
