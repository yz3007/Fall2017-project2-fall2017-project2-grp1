#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(geojsonio)
library(htmltools)
library(RColorBrewer)
# Define UI for application that draws a histogram
ui<- navbarPage( "Choose Your Life",
                       

                      theme = "bootstrap-2.css",
                      
                       #tabPanel("Sales",
                                
                      #          leafletOutput("BedroomSale",width = "100%", height = 700)
                                
                       #),
                 tabPanel("Sales",
                          #leafletOutput("BedroomSale",width = "100%", height = 700),                                
                          br(),
                          column(8,leafletOutput("BedroomSale", height="700px")),
                  
                          column(4,br(),br(),br(),br(),plotlyOutput("plot", height="300px")),
                          column(4,br(),br(),br(),br(),htmlOutput("text1")),
                          #Please add a box for the text !!
                          br()       
                          #absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                           #             draggable = TRUE, color = 'opacity:0.9',
                            #            top = 180, left = 60, right = "auto", bottom = "auto",
                             #           width = 350, height = "auto",
                              #          plotlyOutput("plot", height="300px")
                          
                        ),

                       navbarMenu("Rental",
                                  
                                  tabPanel("1-Bed Room",
                                  
                                           #leafletOutput("Bedroom1",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom1", height = 700)),
                                           column(4,br(),br(),br(),br(),plotlyOutput("plot1", height="300px")),
                                           column(4,br(),br(),br(),br(),textOutput("text2")),
                                           #Please add a box for the text !!
                                           br() 
                                           ),
                          
                               
                                  tabPanel("2-Bed Room",
                                           
                                           #leafletOutput("Bedroom2",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom2", height = 700)),
                                           column(4,br(),br(),br(),br(),plotlyOutput("plot2", height="300px")),
                                           column(4,br(),br(),br(),br(),textOutput("text3")),
                                           #Please add a box for the text !!
                                           br()                           
                                           ),
                                  tabPanel("3-Bed Room",
                                           
                                           #leafletOutput("Bedroom3",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom3", height = 700)),
                                           column(4,br(),br(),br(),br(),plotlyOutput("plot3", height="300px")),
                                           column(4,br(),br(),br(),br(),textOutput("text4")),
                                           #Please add a box for the text !!
                                           br()
                                           ),
                                  tabPanel("4-Bed Room",
                                          
                                           #leafletOutput("Bedroom4",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom4", height = 700)),
                                           column(4,br(),br(),br(),br(),plotlyOutput("plot4", height="300px")),
                                           column(4,br(),br(),br(),br(),textOutput("text5")),
                                           #Please add a box for the text !!
                                           br()
                                           ),
                                  tabPanel("5-Bed Room",
                                           
                                           #leafletOutput("Bedroom5",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom5", height = 700)),
                                           column(4,br(),br(),br(),br(),plotlyOutput("plot5", height="300px")),
                                           column(4,br(),br(),br(),br(),textOutput("text6")),
                                           #Please add a box for the text !!
                                           br()
                                           )
                                  
                       ),
                 navbarMenu("Summary",
                            tabPanel("Price Change",
                                     titlePanel("Price Change in Different Regions & Years"),
                                     sidebarLayout(
                                       sidebarPanel(
                                         
                                         sliderInput("obs", "Year",
                                                     min = as.Date("2011-09-01"), max = as.Date("2017-08-01"), 
                                                     value = as.Date("2011-09-01")
                                         ),
                                         width = 3
                                         
                                       ),
                                       mainPanel(
                                        plotlyOutput("dot_plot_sale")
                                       ),
                                       
                                       
                                     )
                                     ),
                            tabPanel("Rankings",
                                     titlePanel("Recent 3 Years Top 10 Rankings"),
                                     sidebarLayout(
                                       sidebarPanel(
                                         
                                         selectInput(inputId = "rankfact",
                                                     label  = "Choose a factor",
                                                     choices = c('Crime','Hospital','Gallery','Theatre','School'),
                                                     selected ='Health'),
                                         width = 3
                                         
                                       ),
                                       
                                       mainPanel(
                                         plotOutput("ranks", height = 600)#,
                                         #textOutput('instruction',height = '200px')
                                       )
                                       
                                     )
                            )
                            )
)

