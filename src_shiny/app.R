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


# Collect and scale mental health attiude columns
df_attitudes <- df %>% 
  select(col_attitudes) %>% 
  mutate_all(funs(as.numeric(.))) %>% 
  mutate_all(funs(rescale(.)))


## Build Shiny App

# UI
ui <- fluidPage(
  

  
  theme = shinytheme("darkly"),
  titlePanel("Does Employer Policy Effect Employee's Attitude Towards Mental Health?",
             windowTitle = "Employer Policy vs Mental Health Attitude"),
  sidebarLayout(
                sidebarPanel(
                  
                  tags$head(tags$style(type="text/css", 
                                       ".test_type {color: red;
                           font-size: 20px; 
                           font-style: italic;}"
                  )
                  ),
                  
                      selectInput(inputId = "r1",
                              label = "Employer Policy Survey Questions on Attitude towards Mental Health",
                              choices = col_employer_policies,
                              selected = "benefits"),
                       br(),            
                                   
                     # prettyRadioButtons(inputId = "radio1",
                      #             label = "Click me!",
                       #            choices = c("Click me !", "Me !", "Or me !")),
                        #           verbatimTextOutput(outputId = "res1"),
                      
                       hr(),
                      p("click the",span("?", style = "color:blue"),"on the right top corner of the webpage for detailed explations of the plot"),
                      br(),
                  p("1. mental health consequence: Do employees think that discussing a mental health issue with employer would have negative consequences?"),
                  br(),

                   p("2. physical health consequence: Do employees think that discussing a physical health issue with employer would have negative consequences?"),
                    br(),
                  p("3. Talk with coworkers: Would employee be willing to discuss a mental health issue with coworkers?"),
                   br(), 
                  p("4. Talk with supervisor: Would employee be willing to discuss a mental health issue with direct supervisor(s)?"),
                    br(),
                  p("5. Discuss Mental Health at Interview: Would employee bring up a mental health issue with a potential employer in an interview?"),
                    br(),
                    p("6. Discuss Physical Health at Interview:Would employee bring up a physical health issue with a potential employer in an interview?"),
                   br(), 
                  p("7. Mental vs Physical Health: Do you feel that employer takes mental health as seriously as physical health?"),
                   br(), 
                  p("8. Observed consequences:Has employee heard of or observed negative consequences for coworkers with mental health conditions in your workplace?")
                       


                   ),
                
                    
                mainPanel(
                    tabsetPanel(type = "tabs",
                            tabPanel("Read Me", br(),includeMarkdown("readme.md")),
                            
                            tabPanel("Plot", plotlyOutput("scatterpolar")%>%
                                       helper(size = "l", 
                                              content = "PlotHelp")))
                )
    
   )
)

 
# Server
server <- function(input, output){
  
  observe_helpers()
  
  output$scatterpolar <- renderPlotly({
    
    avg_results <- df_attitudes %>% 
      cbind(foo = df[[input$r1]]) %>% 
      group_by(foo) %>% 
      summarise_all(funs(mean(., na.rm = TRUE))) %>% 
      gather(-foo, key = "Survey_Questions", value = "Mean_response") %>% 
      spread(foo, Mean_response)
    
    p <- plot_ly(
      type = 'scatterpolar',
      mode = "markers",
   #   fill = "toself",
      alpha = 0.4,
      colors = "Blues"
      
    )
    
    for(i in seq_along(avg_results)[-1]){
      p <- p %>% add_trace(
        r = avg_results %>% pull(i),
        theta = avg_results %>% pull(Survey_Questions),
        name = colnames(avg_results)[i]
      )
    }
    
    p %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = T,
            range = c(0,1)
          )
        )
      )
    
    })
  
  
 
}

shinyApp(ui, server)