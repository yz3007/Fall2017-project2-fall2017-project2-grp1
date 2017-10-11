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
                      theme =  "bootstrap-2.css",
                      #theme = shinytheme("united"),
                       ## 2D Map tab
                       tabPanel("Sales",
                                
                                leafletOutput("BedroomSale",width = "100%", height = 700)
                                
                               
                       ),
                       
                       ## end 2D Map tab
                       
                       ## Summary Statistics tab
                       navbarMenu("Rental",
                                  ##Regional Findings tabset
                                  tabPanel("1 Bedroom",
                                  
                                           leafletOutput("Bedroom1",width = "100%", height = 700)
                                           
                                           ),
                                  #end Regiona
                                  
                                  ### Exchange Rate
                                  tabPanel("2 Bedroom",
                                           
                                           leafletOutput("Bedroom2",width = "100%", height = 700)
                                                                      
                                           ),
                                  tabPanel("3 Bedroom",
                                           
                                           leafletOutput("Bedroom3",width = "100%", height = 700)
                                           
                                           ),
                                  tabPanel("4 Bedroom",
                                          
                                           leafletOutput("Bedroom4",width = "100%", height = 700)
                                           
                                           ),
                                  tabPanel("5+ Bedroom",
                                           
                                           leafletOutput("Bedroom5",width = "100%", height = 700)
                                           
                                           )
                                  
                       ),
                       tabPanel("Summary")
)

