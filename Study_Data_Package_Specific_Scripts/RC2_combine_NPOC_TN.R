npoc_tn <- "C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Boye_Files/RC2/RC2_NPOC_TN_Check_for_Duplicates_2025-04-02_by_forb086.csv" %>%
  read_csv()
npoc <- "C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Boye_Files/RC2/RC2_NPOC_Check_for_Duplicates_2025-04-02_by_forb086.csv" %>%
  read_csv() %>%
  select(-duplicate)
tn <- "C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Boye_Files/RC2/RC2_TN_Check_for_Duplicates_2025-04-02_by_forb086.csv" %>%
  read_csv() %>%
  select(-duplicate)

combine_npoc_tn <- npoc %>%
  full_join(tn, by = 'Sample_ID')

columns_to_unite <- c("Date_of_Run", "Randomized_ID", "Methods_Deviation", "Method_Notes")

# Create a new dataframe with united columns
for (col in columns_to_unite) {
  combine_npoc_tn <- combine_npoc_tn %>%
    unite(!!col, all_of(paste0(col, ".x")), all_of(paste0(col, ".y")), sep = " <-NPOC; TN-> ", remove = TRUE, na.rm = TRUE)
}

full_combine <- npoc_tn %>%
  mutate(Date_of_Run = as.character(Date_of_Run),
         NPOC_mg_C_per_L = as.character(NPOC_mg_C_per_L)) %>%
  bind_rows(combine_npoc_tn%>%
              mutate(NPOC_mg_C_per_L = as.character(NPOC_mg_C_per_L)) )

write_csv(full_combine, "C:/Users/forb086/OneDrive - PNNL/Data Generation and Files/RC2/Boye_Files/RC2/RC2_NPOC_TN_Check_for_Duplicates_2025-04-02_by_forb086_combined.csv")
