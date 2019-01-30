# app.R
# Fan and Aaron, January 2019

# This script read the shiny app script. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/library(rsconnect)


library(tidyverse)
library(shiny)
library(scales)
library(plotly)

library(shinythemes)
library(shinyWidgets)
library(shinyhelper)


# Load tidy survey data after gender and age values have been fixed
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

# Organize column names by general grouping and label with human readable names 
col_backround_info <- colnames(df)[1:12]

col_attitudes <- c("mental_health_consequence", "phys_health_consequence",
                   "coworkers", "supervisor","mental_health_interview",
                   "phys_health_interview", "mental_vs_physical",
                   "obs_consequence")

col_employer_policies <-c("Does employer provide mental health benefits?" = "benefits", 
                                 "Is there available info on care options" = "care_options", 
                                 "Has employer discussed mental health as part of a wellness program?" = "wellness_program",
                                 "Are there employer provided resources on how to seek help?" = "seek_help",
                                 "Is anonymity protected if using resources?" = "anonymity",
                                 "How easy is it to take leave for mental health?" = "leave")

col_attitudes_labels <- c("Q1. Mental Health Consequence",
                          "Q2. Physical Health Consequence",
                          "Q3. Talk with Coworkers", "Q4. Talk with Supervisor",
                          "Q5. Mental Health at Interview",
                          "Q6. Physical Health at Interview", 
                          "Q7. Mental vs Physical Health",
                          "Q8. Observed consequences")

name_change <- tibble(old_survey_q = col_attitudes, new_survey_q = col_attitudes_labels)

# Describe and format mental health survey questions to be used in the hovertext
question_text <- 
  c("<br>Q1. Mental Health Consequence:<br>  Do you think that discussing a<br> mental health issue with your<br> employer would have negative<br> consequences?",
    "<br>Q2. Physical Health Consequence:<br>  Do you think that discussing a<br> physical health issue with your<br> employer would have negative<br> consequences?",
    "<br>Q3. Talk with Coworkers:<br>  Would you be willing to discuss<br> a mental health issue with your<br> coworkers?",
    "<br>Q4. Talk with Supervisor:<br>  Would you be willing to discuss<br> a mental health issue with your<br> direct supervisor(s)?",
    "<br>Q5. Mental Health at Interview:<br>  Would you bring up a mental health<br> issue with a potential employer<br> in an interview?",
    "<br>Q6. Physical Health at Interview:<br>  Would you bring up a physical health<br> issue with a potential employer in an<br> interview?",
    "<br>Q7. Mental vs Physical Health:<br>  Do you feel that your employer<br> takes mental health as seriously<br> as physical health?",
    "<br>Q8. Observed consequences:<br>  Have you heard of or observed<br> negative consequences for<br> coworkers with mental health<br> conditions in your workplace?")


## Build Shiny App

# UI
ui <- fluidPage(
  
  theme = shinytheme("journal"),
  titlePanel("Do Employer Policies Effect Overall Employee Attitudes Towards Mental Health?",
             windowTitle = "Employer Policy vs Mental Health Attitude"),
  
  h4("Instructions"),
  
  h6("The dashboard visualizes survey results on employees attitudes to mental health. Employees were grouped based on how they answered their employer policy questions which can be toggled below. Each group of employees were aggregated to get an overall score on how positive their attitude was towards mental health based on the specific questions that were asked. The overall area of the plot gives insight into the overall positive attitude. With this insight you can compare different employees by policy group to see which policies made the biggest difference. For example, employers who make it very easy to take a leave of abscence tend to have employees with a significantly more positive atitude towards mental health. For more specific information, see the Read me tab located below."),
  
  sidebarLayout(
                sidebarPanel(
                  
                  tags$head(tags$style(type="text/css", 
                                       ".test_type {color: red;
                           font-size: 20px; 
                           font-style: italic;}")
                  ),
                  
                      selectInput(inputId = "employer_q",
                              label = "Employer Policy Survey Questions",
                              choices = col_employer_policies,
                              selected = "benefits"),
                  
                       uiOutput("secondSelection")
                  ),

                mainPanel(
                    tabsetPanel(type = "tabs",
                                tabPanel("Plot", plotlyOutput("scatterpolar")),
                                tabPanel("Read Me", br(),includeMarkdown("readme.md"))
                    )
                            
                )
   )
)

 
# Server
server <- function(input, output){
  
  output$secondSelection <- renderUI({
    checkboxGroupInput(inputId = "employer_q_options_var", 
                       label = NULL, 
                       choices = df[[input$employer_q]] %>% unique(), 
                       selected = df[[input$employer_q]] %>% unique())
  })
  
  
  df_summary <- reactive({
    df %>% 
      mutate_at(col_attitudes, funs(as.numeric(.))) %>% 
      mutate_at(col_attitudes, funs(rescale(.))) %>% 
      select(col_attitudes,foo = input$employer_q) %>% 
      group_by(foo) %>% 
      summarize_all(funs(mean(., na.rm = TRUE))) %>% 
      gather(-foo, key = "Survey_Questions", value = "Mean_response") %>% 
      filter(foo %in% input$employer_q_options_var) %>% 
      left_join(name_change, by = c("Survey_Questions" = "old_survey_q"))
   })
   
  employer_q_options <- reactive({
    df_summary() %>%
      pull(foo) %>% 
      unique()
   })
  
  hovertext <- reactive({
    paste(flatten_chr(map(question_text, rep, times = length(input$employer_q_options_var))), 
          "<br><br>Average Positivity Score:", 
          df_summary() %>% pull(Mean_response) %>% round(2))
  })
    
    
  
  
  
  
  output$scatterpolar <- renderPlotly({
    
    req(input$employer_q)
    
    p <- plot_ly(
      type = 'scatterpolar',
      mode = "markers",
      fill = "toself",
      alpha = 0.4,
      colors = "Paired") %>%
      
      layout(
        polar = list(
          radialaxis = list(
            visible = F,
            range = c(0,1)
          )
        )
      )  
    
    p <- df_summary() %>% 
            add_trace(p, data = ., theta = ~new_survey_q, r = ~Mean_response, color = ~foo, 
                      hoverinfo = "text", hovertext = hovertext(), marker = list(size = 7))
    
    
    p
    })
  
  
 
}

shinyApp(ui, server)