#### Team Members | Github:
* Fan Nie | [Jamienie](https://github.com/Jamienie?tab=repositories)
* Aaron Quinton | [aaronquinton](https://github.com/aaronquinton)

#### Functionality
Our shiny application includes a landing page with an interactive radar plot and a drop down list dictating the contents to be plotted. 

#### Interpretation
The radar plot identifies the eight survey questions in our raw data that all pertained to the employee's attitude towards mental health. All of these survey responses were categorical, but with an inherit order (ex. No, Maybe, Yes). These were assigned a number and scaled to be between Zero and One. A zero implies their answer to the survey question indicated a negative attitude, while a 1 indicated their attitude is positive. These scores were then averaged across all the employees with consideration to their company's policies.

The larger the area in the radar plot, the overall more positive the attitude is towards mental health. Given this insight, we are able to compare different company policies and compare the difference in mental health attitudes.

#### Rationale
The main use case discussed in the original proposal was to provide a quick summary on the attitudes towards mental health and see how this is related to company policies. Additional to this, the goal for the application was to tailor these insights considering employees of relevant backgrounds.

With this proposal in mind, we wanted the visualization to primarily focus on the mental health attitudes which is why we chose the plot to focus on the mental health related survey responses. Instead of giving an overall positive or negative score to mental health, we wanted to show the average attitude based on each question and let the visual speak to the overall.


