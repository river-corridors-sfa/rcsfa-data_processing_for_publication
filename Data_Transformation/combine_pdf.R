# ==============================================================================
#
# Combine pdfs
#
# Status: Complete
# 
# ==============================================================================
#
# Author: Brieanne Forbes
# 21 Nov 2022
#
# ==============================================================================

library(qpdf)
rm(list=ls(all=T))

# ================================= User inputs ================================

pdf_dir <- 'Z:/RC2/03_Temporal_Study/02_MantaRiver/04_Plots'

outfile <- 'Z:/RC2/03_Temporal_Study/02_MantaRiver/05_PublishReadyData/RC2_2022-2024_Water_Temp_SpC_ChlA_TsPlot.pdf'

# out_dir <- ''

# ================================= combine pdfs ===============================

pdfs <- list.files(pdf_dir, 'pdf', full.names = T)

# outfile <- paste0(pdf_dir, pdf_outfile)

pdf_combine(input = pdfs, output = outfile)

# ================================= combine pdfs ===============================

# use the below code if the code errors because there are too many files

# outfile1 <- paste0(out_dir, '1.pdf')
# outfile2 <- paste0(out_dir, '12.pdf')
# outfile3 <- paste0(out_dir, '123.pdf')
# outfile4 <- paste0(out_dir, '1234.pdf')
# outfile5 <- paste0(out_dir, '12345.pdf')
# 
# group1 <- pdfs[1:100]
# 
# pdf_combine(input = group1, output = outfile1)
# 
# group2 <- c(outfile1, pdfs[101:200])
# 
# pdf_combine(input = group2, output = outfile2)
# 
# group3 <- c(outfile2, pdfs[201:300])
# 
# pdf_combine(input = group3, output = outfile3)
# 
# group4 <- c(outfile3, pdfs[301:400])
# 
# pdf_combine(input = group4, output = outfile4)
# 
# group5 <- c(outfile4, pdfs[401:484])
# 
# pdf_combine(input = group5, output = outfile5)




