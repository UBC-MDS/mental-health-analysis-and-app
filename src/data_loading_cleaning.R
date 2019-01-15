# data_loading.R
# Fan and Aaron, January 2019

# This script read the original data as .csv files, cleans the data, and writes it to a new file.
#
# This script takes two arguments: the path to the input file , and a path where to write the file to. 
#
# Usage: Rscript src/data_loading.R  data/survey.csv shiny_app/clean_survey.csv
#

suppressPackageStartupMessages(library(tidyverse))

# read in command line arguments
args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
out <- args[2]

# define main function
main <- function(){
  

# read in data
data <- read.csv(input, stringsAsFactors=FALSE)
  
# wrangle data


  
# write clean data file
write.csv(data, file = output)
  
}

# call main function
main()