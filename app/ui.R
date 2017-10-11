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
library(htmltools)
library(RColorBrewer)
library(plotly)
library(rgdal)
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
                          column(4,htmlOutput("text01")),
                          tags$head(tags$style("#text01{color: black;
                                 font-size: 20px;
                                               font-style: bold;
                                               }"
                         )
                          ),
                          column(4,plotlyOutput("plot", height="300px")),
                          column(4,br(),br(),htmlOutput("text1")),
                         tags$head(tags$style("#text1{color: black;
                                 font-size: 10px;
                                              
                                              }"
                         )
                         ),
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
                                           column(4,htmlOutput("text02")),
                                           tags$head(tags$style("#text02{color: black;
                                                                font-size: 20px;
                                                                font-style: bold;
                                                                }"
                         )
                                           ),
                                           column(4,plotlyOutput("plot1", height="300px")),
                                           column(4,br(),br(),htmlOutput("text2")),
                         tags$head(tags$style("#text2{color: black;
                                 font-size: 10px;
                                              
                                              }"
                         )
                         ),
                         #Please add a box for the text !!
                                           br() 
                                           ),
                          
                               
                                  tabPanel("2-Bed Room",
                                           
                                           #leafletOutput("Bedroom2",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom2", height = 700)),
                                           column(4,htmlOutput("text03")),
                                           tags$head(tags$style("#text03{color: black;
                                                                font-size: 20px;
                                                                font-style: bold;
                                                                }"
                         )
                                           ),
                                           column(4,plotlyOutput("plot2", height="300px")),
                                           column(4,br(),br(),htmlOutput("text3")),
tags$head(tags$style("#text3{color: black;
                                 font-size: 10px;
                                                                                                                  
                                                                                                                  }"
                         )
                                           ),
                         
                                           #Please add a box for the text !!
                                           br()                           
                                           ),
                                  tabPanel("3-Bed Room",
                                           
                                           #leafletOutput("Bedroom3",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom3", height = 700)),
                                           column(4,htmlOutput("text04")),
                                           tags$head(tags$style("#text04{color: black;
                                                                font-size: 20px;
                                                                font-style: bold;
                                                                }"
                         )
                                           ),
                                           column(4,plotlyOutput("plot3", height="300px")),
                                           column(4,br(),br(),htmlOutput("text4")),
                         tags$head(tags$style("#text4{color: black;
                                 font-size: 10px;
                                              
                                              }"
                         )
                         ),
                                           #Please add a box for the text !!
                                           br()
                                           ),
                                  tabPanel("4-Bed Room",
                                          
                                           #leafletOutput("Bedroom4",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom4", height = 700)),
                                           column(4,htmlOutput("text05")),
                                           tags$head(tags$style("#text05{color: black;
                                                                font-size: 20px;
                                                                font-style: bold;
                                                                }"
                         )
                                           ),
                                           column(4,plotlyOutput("plot4", height="300px")),
                                           column(4,br(),br(),htmlOutput("text5")),
                         tags$head(tags$style("#text5{color: black;
                                 font-size: 10px;
                                              
                                              }"
                         )
                         ),
                                           #Please add a box for the text !!
                                           br()
                                           ),
                                  tabPanel("5-Bed Room",
                                           
                                           #leafletOutput("Bedroom5",width = "100%", height = 700)
                                           br(),
                                           column(8,leafletOutput("Bedroom5", height = 700)),
                                           column(4,htmlOutput("text06")),
                                           tags$head(tags$style("#text06{color: black;
                                                                font-size: 20px;
                                                                font-style: bold;
                                                                }"
                         )
                                           ),
                                           column(4,plotlyOutput("plot5", height="300px")),
                                           column(4,br(),br(),htmlOutput("text6")),
                         tags$head(tags$style("#text6{color: black;
                                 font-size: 10px;
                                              
                                              }"
                         )
                         ),
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
                                     titlePanel("Recent 3 Years Rankings"),
                                     sidebarLayout(
                                       sidebarPanel(
                                         
                                         selectInput(inputId = "rankfact",
                                                     label  = "Choose a factor",
                                                     choices = c('Crime','Hospital','Gallery'),
                                                     selected ='Hospital'),
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

