# data_loading.R
# Fan and Aaron, January 2019

# This script read the original data as .csv files, cleans the data, and writes it to a new file.
#
# This script takes two arguments: the path to the input file , and a path where to write the file to. 
#
# Usage: Rscript src/data_loading.R  data/survey.csv shiny_app/clean_survey.csv
#

suppressPackageStartupMessages(library(tidyverse))
library(forcats)

# read in command line arguments
args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
out <- args[2]

# define main function
main <- function(){
  

# read in data
df <- read_csv(input)
  
## wrangle data

# Clean the Gender descriptions to be Male, Female, or Other
df <- df %>% mutate(Gender = str_to_lower(Gender),
                    Gender = case_when(
                      Gender %in% c("male", "m", "mal", "maile", "cis male", "male (cis)",
                                    "man", "msle", "make", "mail", "malr", "cis man") ~ "Male",
                      Gender %in% c("female", "f", "cis female", "femake",
                                    "cis-female/femme", "female (cis)", "femail") ~ "Female",
                      TRUE ~ "Other"),
                    Gender = as.factor(Gender))


# Remove rows with odd age values
df <- df %>% filter(Age < 100 & Age > 18)


# Convert apropriate columns to factors and order correctly
df <- mutate_at(df, vars(Gender:obs_consequence), funs(factor(.))) %>% 
  mutate_at(vars(work_interfere), funs(fct_relevel(., c("Never", "Rarely", "Sometimes", "Often")))) %>% 
  mutate_at(vars(no_employees), funs(fct_relevel(.,c("1-5", "6-25", "26-100", "100-500", "500-1000")))) %>% 
  mutate_at(vars(matches("consequence|interview"), -obs_consequence), funs(fct_relevel(.,c("No", "Maybe", "Yes")))) %>% 
  mutate_at(vars(leave), funs(fct_relevel(.,c("Don't know", "Very easy", "Somewhat easy", "Somewhat difficult", "Very difficult"))))


  
# write clean data file
write.csv(df, file = output)
  
}

# call main function
main()