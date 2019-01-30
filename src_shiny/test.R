library(tidyverse)
library(scales)
library(hrbrthemes)

df <- read_csv("clean_survey.csv")

# Factorize the survey responses in an order consistent with negative to positive attitudes towards mental health

df <- df %>% 
  mutate_at(vars(Gender:obs_consequence), funs(factor(.))) %>% 
  mutate_at(vars(work_interfere), 
            funs(fct_relevel(., c("Never", "Rarely", "Sometimes", "Often")))) %>% 
  mutate_at(vars(no_employees), 
            funs(fct_relevel(.,c("1-5", "6-25", "26-100", "100-500", "500-1000")))) %>% 
  mutate_at(vars(leave), 
            funs(fct_relevel(.,c("Don't know", "Very easy", "Somewhat easy", "Somewhat difficult", "Very difficult")))) %>% 
  mutate_at(vars(mental_health_consequence, phys_health_consequence),
            funs(fct_relevel(., c("Yes","Maybe","No")))) %>% 
  mutate_at(vars(coworkers, supervisor),
            funs(fct_relevel(., c("No","Some of them","Yes")))) %>% 
  mutate_at(vars(mental_health_interview, phys_health_interview),
            funs(fct_relevel(., c("No","Maybe","Yes")))) %>% 
  mutate_at(vars(mental_vs_physical),
            funs(fct_relevel(., c("No","Don't know","Yes")))) %>% 
  mutate_at(vars(obs_consequence),
            funs(fct_relevel(., c("Yes","No")))) 
col_backround_info <- colnames(df)[1:12]

col_employer_policies <-c("Does employer provide mental health benefits?" = "benefits", 
                          "Is there available info on care options" = "care_options", 
                          "Has employer discussed mental health as part of a wellness program?" = "wellness_program",
                          "Are there employer provided resources on how to seek help?" = "seek_help",
                          "Is anonymity protected if using resources?" = "anonymity",
                          "How easy is it to take leave for mental health?" = "leave")

col_attitudes <- c("1. Mental Health Consequence" =  "mental_health_consequence",
                   "2. Physical Health Consequene" = "phys_health_consequence",
                   "3. Talk with Coworkers" = "coworkers",
                   "4. Talk with Supervisor" = "supervisor",
                   "5. Discuss Mental Health at Interview" = "mental_health_interview",
                   "6. Discuss Physical Health at Interview" = "phys_health_interview",
                   "7. Mental vs Physical Health" = "mental_vs_physical",
                   "8. Observed consequences" = "obs_consequence")

df_attitudes <- df %>% 
  select(col_attitudes) %>% 
  mutate_all(funs(as.numeric(.))) %>% 
  mutate_all(funs(rescale(.)))

test <- df_attitudes%>%gather(questions, value) 
test_p <-test%>%group_by(questions,value)%>%count(value)
test_p %>% ggplot(aes(questions, n, fill =value)) +
  geom_bar(position = "fill", stat = "identity") +
  scale_y_continuous(labels = percent)





#(p <- ggplot(df_attitudes, aes(category, value, fill = variable)) +
#    geom_bar(position = "fill", stat = "identity") +
#    scale_y_continuous(labels = percent)
#)