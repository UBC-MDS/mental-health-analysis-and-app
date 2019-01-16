# data_loading.R
# Fan and Aaron, January 2019

# This script read the original data as .csv files, cleans the data, and writes it to a new file.
#
# This script takes two arguments: the path to the input file , and a path where to write the file to. 
#
# Usage: Rscript src/data_loading_cleaning.R  data/survey.csv shiny_app/clean_survey.csv
#

suppressPackageStartupMessages(library(tidyverse))
library(forcats)

# read in command line arguments
args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
output <- args[2]

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


# Remove rows with odd age values, and add age group column
df <- df %>% filter(Age < 100 & Age > 18) %>%
             mutate(age_group = ifelse(Age > 18 & Age < 30, "19-29",
                    ifelse(Age >29 & Age <40, "30-39",
                           ifelse(Age > 39 & Age <50,"40-49",
                                  ifelse(Age>49 & Age <60,"50-59",
                                         ifelse(Age>59 & Age<70,"60-69","70+"))))))



# Convert apropriate columns to factors and order correctly
df <- mutate_at(df, vars(Gender:obs_consequence), funs(factor(.))) %>% 
  mutate_at(vars(work_interfere), funs(fct_relevel(., c("Never", "Rarely", "Sometimes", "Often")))) %>% 
  mutate_at(vars(no_employees), funs(fct_relevel(.,c("1-5", "6-25", "26-100", "100-500", "500-1000")))) %>% 
  mutate_at(vars(matches("consequence|interview"), -obs_consequence), funs(fct_relevel(.,c("No", "Maybe", "Yes")))) %>% 
  mutate_at(vars(leave), funs(fct_relevel(.,c("Don't know", "Very easy", "Somewhat easy", "Somewhat difficult", "Very difficult")))) 


# Add ranking information of selected features
df <- df %>% mutate(seek_help_rank = ifelse(seek_help == "Yes",1,
                                     ifelse(seek_help == "No",-1,0))) %>%
      mutate(mental_health_consequence_rank = ifelse(mental_health_consequence == "Yes",1,
                                 ifelse(mental_health_consequence == "No",-1,0))) %>%
      mutate(phys_health_consequence_rank = ifelse(phys_health_consequence == "Yes",1,
                                                 ifelse(phys_health_consequence == "No",-1,0))) %>%
      mutate(coworkers_rank = ifelse(coworkers == "Yes",1,
                                               ifelse(coworkers == "No",-1,0))) %>%
      
      mutate(supervisor_rank = ifelse(supervisor == "Yes",1,
                                 ifelse(supervisor == "No",-1,0))) %>%
      mutate(mental_health_interview_rank = ifelse(mental_health_interview == "Yes",1,
                                  ifelse(mental_health_interview == "No",-1,0))) %>%
      mutate(phys_health_interview_rank = ifelse(phys_health_interview == "Yes",1,
                                               ifelse(phys_health_interview == "No",-1,0))) %>%
      mutate(mental_vs_physical_rank = ifelse(mental_vs_physical == "Yes",1,
                                             ifelse(mental_vs_physical == "No",-1,0))) %>%
      mutate(treatment_rank = ifelse(treatment == "Yes",1,0))
     
      
      
# write clean data file
write.csv(df, file = output)
  
}

# call main function
main()