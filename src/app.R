library(tidyverse)
library(shiny)
library(scales)
library(plotly)

df <- read_csv("data/clean_survey.csv")

df <- mutate_at(df, vars(Gender:obs_consequence), funs(factor(.))) %>% 
  mutate_at(vars(work_interfere), 
            funs(fct_relevel(., c("Never", "Rarely", "Sometimes", "Often")))) %>% 
  mutate_at(vars(no_employees), 
            funs(fct_relevel(.,c("1-5", "6-25", "26-100", "100-500", "500-1000")))) %>% 
  mutate_at(vars(matches("consequence|interview"), -obs_consequence), 
            funs(fct_relevel(.,c("No", "Maybe", "Yes")))) %>% 
  mutate_at(vars(leave), 
            funs(fct_relevel(.,c("Don't know", "Very easy", "Somewhat easy", "Somewhat difficult", "Very difficult"))))

attitude_col = c("mental_health_consequence","phys_health_consequence",
                 "coworkers","supervisor","mental_health_interview",
                 "phys_health_interview", "mental_vs_physical",
                 "obs_consequence")


avg_results <- df %>% 
  select(attitude_col) %>% 
  mutate_all(funs(as.numeric(.))) %>% 
  mutate_all(funs(rescale(.)))

company_details <-colnames(df)[13:18]

ui <- fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "r1",
                  label = "Company Policies",
                  choices = company_details,
                  selected = "benefits")
    ),
    
    
    
    mainPanel(
      plotlyOutput("scatterpolar")
    )
    
    
  )
  
  
  
  
  
  
)

server <- function(input, output){
  output$scatterpolar <- renderPlotly({
    
    avg_results <- avg_results %>% 
      cbind(foo = df[[input$r1]]) %>% 
      group_by(foo) %>% 
      summarise_all(funs(mean(., na.rm = TRUE))) %>% 
      gather(-foo, key = "Survey_Questions", value = "Mean_response") %>% 
      spread(foo, Mean_response)
    
    p <- plot_ly(
      type = 'scatterpolar',
      mode = "markers",
      fill = "toself",
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