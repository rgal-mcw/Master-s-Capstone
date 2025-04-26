# Summary table for Capstone

library(tidyverse)
library(gtsummary)
library(gt)
library(webshot2)

cohort = read.csv('/Users/ryangallagher/desktop/MedicalCollegeofWisconsin/capstone/excel/cohort.csv')

# Add a binned year variable
cohort = cohort %>%
  mutate(
    year_of_birth_b = cut(year_of_birth,
                               # Creating breaks from 1998 to 2018
                               breaks = c(seq(from = 1998, to = 2014, by = 4), 2018),
                               include.lowest = TRUE,
                               right = FALSE,
                               # Custom labels for the bins
                               labels = c("1998-2001", "2002-2005", "2006-2009", "2010-2013", "2014-2018")
    )
  )
head(cohort)



cohort = cohort %>%
  rename(Sex=sex, Race=race, `Year of Birth`=year_of_birth_b, 
         Ethnicity=ethnicity, `Regional Location`=patient_regional_location) %>%
  distinct(patient_id, .keep_all = TRUE)
  
cohort = cohort %>% select(Sex, Race, `Year of Birth`, Ethnicity, `Regional Location`)

cohort = cohort %>% mutate(across(-`Year of Birth`, ~ifelse(. == '', 'Unknown', .)))

cohort = cohort %>% mutate(across(where(is.character), as.factor)) %>%
  mutate(across(where(is.factor), ~fct_relevel(., "Unknown", after = Inf)))

table = cohort %>%
  tbl_summary(
    by = Sex,
    statistic = list(
      #all_continuous() ~ "{mean} ({sd})", # for continuous variables
      all_categorical() ~ "{n} ({p}%)"   # for categorical variables
    )
  )


gt_table = as_gt(table) %>% 
  gt::tab_header(title = "Summary Statistics of SCD BMI Cohort")

gt_table
# Exporting as PNG
gtsave(gt_table, filename = "/Users/ryangallagher/Desktop/MedicalCollegeofWisconsin/capstone/excel/cohort_table.png", vwidth = 640, vheight = 480)

