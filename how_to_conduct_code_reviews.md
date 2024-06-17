# Code Reviews
This document explains how to conduct a code review.  
- A `formal` code review requires you to clone the script and run all the lines on your local machine.
- An `informal` code review requires you to read through the script, but don't need to run it on your machine.

## How to conduct a code review
1. When the author is ready for a code review, they select someone to review their code. The code reviewer should be someone who...
2. The author creates a new issue in the repo.
   - The title of the issue should include the name of the script and whether it's a formal or informal code review (e.g., "Formal code review of myscript.R").
   - The issue description should include a link to the script.
   - Use the "Assignees" section to assign the issue to your code reviwer.
4. The code reviewer will either run (formal) or read (informal) the script line by line. They will leave comments in the issue listing the line number and their comment (e.g., "L15: add more comments to explain the calculation"). The code reviewer assess for the following:
   - **Accessibility**: Are the comments and code sufficient enough to understand what is happening in each line? 
   - **Clarity**: Is there redudant code that can be written more efficiently or removed? 
   - **Accuracy**: Are calculations correct?
   - **Interoperability**: Does the code run cleanly on your machine?
5. When the code reviewer is done, they post the comment in the issue and remove themselves as the assignee and reassign the author.
6. The author makes revisions and when done, commits their changes and closes the issue. The author can close the issue with their commit by including the issue number in the commit message (e.g., "Updated code to resovle code review edits. Closes issue #4").


