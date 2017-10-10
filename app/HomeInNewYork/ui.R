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
                       
                       ##link to css.file
                      theme = "bootstrap-2.css",
                      #theme = shinytheme("united"),
                       ## 2D Map tab
                       tabPanel("Sales",
                                
                                leafletOutput("BedroomSale",width = "100%", height = 700),
                                
                                absolutePanel(id = "S1", class = "panel panel-default", fixed = TRUE,
                                              draggable = TRUE, style = 'opacity:0.85',
                                              top = 100, left = 60, right = "auto", bottom = "auto",
                                              width = 200, height = "auto",
                                             
                                              h2('Sales'),
                                              
                                              checkboxGroupInput(inputId = "S_Factors", 
                                                                 label = "Factors",
                                                                 c("Transportation" = 'subway','Hospital'="hospital",#'School'="school",
                                                                   'Arts'="art"
                                                                   ,'Crime'="crime", 'Theater'="theatre"))
                                              
                                )
                       ),
                       
                       ## end 2D Map tab
                       
                       ## Summary Statistics tab
                       navbarMenu("Rental",
                                  ##Regional Findings tabset
                                  tabPanel("1-Bed Room",
                                  
                                           leafletOutput("Bedroom1",width = "100%", height = 700),
                                           absolutePanel(id = "R1", class = "panel panel-default", fixed = TRUE,
                                                         draggable = TRUE, style = 'opacity:0.85',
                                                         top = 100, left = 60, right = "auto", bottom = "auto",
                                                         width = 200, height = "auto",
                                                         h2('1-Bed Room'),
                                                         checkboxGroupInput(inputId = "R1_Factors", 
                                                                            label = "Factors",
                                                                            c("Transportation" = 'subway','Hospital'="hospital",#'School'="school",
                                                                              'Arts'="art"
                                                                              ,'Crime'="crime", 'Theater'="theatre"))
                                           )),
                                  #end Regiona
                                  
                                  ### Exchange Rate
                                  tabPanel("2-Bed Room",
                                           
                                           leafletOutput("Bedroom2",width = "100%", height = 700),
                                           absolutePanel(id = "R2", class = "panel panel-default", fixed = TRUE,
                                                         draggable = TRUE, style = 'opacity:0.85',
                                                         top = 100, left = 60, right = "auto", bottom = "auto",
                                                         width = 200, height = "auto",
                                                         h2('2-Bed Room'),
                                                         checkboxGroupInput(inputId = "R2_Factors", 
                                                                            label = "Factors",
                                                                            c("Transportation" = 'subway','Hospital'="hospital",#'School'="school",
                                                                              'Arts'="art"
                                                                              ,'Crime'="crime", 'Theater'="theatre"))
                                           )),
                                  tabPanel("3-Bed Room",
                                           
                                           leafletOutput("Bedroom3",width = "100%", height = 700),
                                           absolutePanel(id = "R3", class = "panel panel-default", fixed = TRUE,
                                                         draggable = TRUE, style = 'opacity:0.85',
                                                         top = 100, left = 60, right = "auto", bottom = "auto",
                                                         width = 200, height = "auto",
                                                         h2('3-Bed Room'),
                                                         checkboxGroupInput(inputId = "R3_Factors", 
                                                                            label = "Factors",
                                                                            c("Transportation" = 'subway','Hospital'="hospital",#'School'="school",
                                                                              'Arts'="art"
                                                                              ,'Crime'="crime", 'Theater'="theatre"))
                                           )),
                                  tabPanel("4-Bed Room",
                                          
                                           leafletOutput("Bedroom4",width = "100%", height = 700),
                                           absolutePanel(id = "R4", class = "panel panel-default", fixed = TRUE,
                                                         draggable = TRUE, style = 'opacity:0.85',
                                                         top = 100, left = 60, right = "auto", bottom = "auto",
                                                         width = 200, height = "auto",
                                                         h2('4-Bed Room'),
                                                         checkboxGroupInput(inputId = "R4_Factors", 
                                                                            label = "Factors",
                                                                            c("Transportation" = 'subway','Hospital'="hospital",#'School'="school",
                                                                              'Arts'="art"
                                                                              ,'Crime'="crime", 'Theater'="theatre"))
                                           )),
                                  tabPanel("5-Bed Room",
                                           
                                           leafletOutput("Bedroom5",width = "100%", height = 700),
                                           absolutePanel(id = "R5", class = "panel panel-default", fixed = TRUE,
                                                         draggable = TRUE, style = 'opacity:0.85',
                                                         top = 100, left = 60, right = "auto", bottom = "auto",
                                                         width = 200, height = "auto",
                                                         h2('5-Bed Room'),
                                                         checkboxGroupInput(inputId = "R5_Factors", 
                                                                            label = "Factors",
                                                                            c("Transportation" = 'subway','Hospital'="hospital",#'School'="school",
                                                                              'Arts'="art"
                                                                              ,'Crime'="crime", 'Theater'="theatre"))
                                           ))
                                  
                                  ### end Mirror Histogram
                       ),
                       tabPanel("Summary")
)

