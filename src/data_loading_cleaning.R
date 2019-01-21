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


# write clean data file
write.csv(df, file = output)
  
}

# call main function
main()