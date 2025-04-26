
library(readr)
library(tidyverse)


female_scd = read_csv("~/Desktop/MedicalCollegeofWisconsin/capstone/percentile_tables/female_scd_tab.csv")
female_scd = female_scd %>% filter(age > 1) %>% rename(BMI = median_BMI)
View(female_scd)

male_scd = read_csv("~/Desktop/MedicalCollegeofWisconsin/capstone/percentile_tables/male_scd_tab.csv")
male_scd = male_scd %>% filter(age > 1) %>% rename(BMI = median_BMI)
View(male_scd)


#Make a table to give top 5 and bottom 5 bmi per percentile

male_p3 = male_scd %>% filter(QUANTILE==0.03) %>% arrange(desc(BMI))
top_5_p3 = head(male_p3$BMI, 5)
bottom_5_p3 = tail(male_p3$BMI, 5)
c(top_5_p3, bottom_5_p3)
