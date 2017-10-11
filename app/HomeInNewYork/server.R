#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shinydashboard)
library(shiny)
library(leaflet)
library(dplyr)
library(geojsonio)
library(htmltools)
library(RColorBrewer)
# Preparation
nycounties <- geojson_read("nyczip.geojson", what = "sp")
sales <- read.csv("Sale_Data.csv", header=TRUE, stringsAsFactors = FALSE)
nycounties$postalCode <- as.numeric(as.character(nycounties$postalCode))
dat <- nycounties@data
salesPrice <- NULL
for(i in 1:nrow(dat)){
  zip <- dat$postalCode[i]
  salesPrice <- c(salesPrice, sales$Price_Predict[sales$RegionName == zip])
}
nycounties@data$sales <- salesPrice

# Load data
rental <- read.csv("Rental_Data.csv", header=TRUE, stringsAsFactors = FALSE)
dat <- nycounties@data
l <- list()
for (i in 1:5){
  s<-read.csv(paste("rental_bed",i,".csv", sep=""), header=TRUE, stringsAsFactors = FALSE)
  # s$RegionName <- as.character(s$RegionName)
  
  rentalPrice <- NULL
  
  for(j in 1:nrow(dat)){
    zip <- dat$postalCode[j]
    rentalPrice <- c(rentalPrice, s$Price_Predict[s$RegionName == zip])
  }
  
  l[[i]] <- rentalPrice
}
nycounties@data$rental_Bed1 <- l[[1]]
nycounties@data$rental_Bed2 <- l[[2]]
nycounties@data$rental_Bed3 <- l[[3]]
nycounties@data$rental_Bed4 <- l[[4]]
nycounties@data$rental_Bed5 <- l[[5]]

hospital <- read.csv("Hospital_Data.csv", header=TRUE, stringsAsFactors = FALSE)
hospital$longitude <- hospital$Longitude
hospital$latitude <- hospital$Latitude
#art
art <- read.csv("Art_Gallery_Data.csv", header=TRUE, stringsAsFactors = FALSE)
art$longitude <- art$long
art$latitude <- art$lat
#theatre
theatre <- read.csv("Theatre_Data.csv", header=TRUE, stringsAsFactors = FALSE)

theatre$longitude <- theatre$long
theatre$latitude <- theatre$lat
#subway
subway <- read.csv("Subway_Data.csv", header=TRUE, stringsAsFactors = FALSE)
subway$longitude <- subway$Long
subway$latitude <- subway$Lat
#crime
crime <- read.csv("Crime_Data.csv", header=TRUE, stringsAsFactors = FALSE)
crime <- crime %>% na.omit() 
crime$longitude <- crime$Longitude
crime$latitude <- crime$Latitude
#total
data.list <- list(crime=crime,subway=subway,theatre=theatre,art = art,hospital=hospital)

#Icon marker
IconMaker <- function(address){
  icon <- makeIcon(
    iconUrl = address,
    iconWidth = 30, iconHeight = 30,
    iconAnchorX = 0, iconAnchorY = 0)
}

iconS <-list()

iconS$hospital <- IconMaker("Hospital.png")

iconS$art <- IconMaker("Gallery.png")

iconS$theatre <- IconMaker("Theatre.png")

iconS$subway <- IconMaker("Subway.png")

iconS$crime <- IconMaker("Crime.png")

# Pops
pops <- list()
pops$hospital <- paste0("<center><strong style='color:blue'>",hospital$Facility.Name,"</strong>","<br/>",hospital$Phone, "<br/>", hospital$address, "</center>")
pops$art <- paste0("<center><strong style='color:blue'>",art$NAME,"</strong>","<br/>",paste(art$ADDRESS1, art$ADDRESS2), "</center>")
pops$theatre <- paste0("<center><strong style='color:blue'>",theatre$NAME,"</strong>","<br/>",paste(theatre$ADDRESS1, theatre$ADDRESS2), "</center>")
pops$subway <- paste0("<center><strong style='color:blue'>",subway$NAME,"</strong>","<br/>",subway$LINE, "</center>")
pops$crime <- paste0("<center><strong style='color:blue'>",crime$LAW_CAT_CD,"</strong>","<br/>",crime$BORO_NM, "</center>")

#Basemap
basemap <- leaflet(nycounties) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% addTiles()

# Sales Map
bins <- c(0, 500, 1000, 1500, 2000, 2500,Inf)
#    YlGnBu (YlOrBr) (YlGn) Blues Reds (Accent) Oranges Purples
pal <- colorBin("YlOrRd", domain = nycounties$sales, bins = bins)
labels_sales <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Price Per Square Feet(PPSF): <strong>$%g/ft<sup>2</sup></strong>",
  as.character(nycounties$postalCode), nycounties$sales
) %>% lapply(htmltools::HTML)

salesMap <- basemap %>% addPolygons(
  fillColor = pal(nycounties$sales),
  color = "#444444", 
  weight = 2, 
  smoothFactor = 0.5, 
  opacity = 1.0, 
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#355C7D",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels_sales,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")
)  %>% addLegend(pal = pal, 
                 values = nycounties$sales,
                 opacity = 0.7, 
                 title = 'Price Per Square Feet',
                 position = "bottomright") %>% addLayersControl(
                   
                 ) %>% addLayersControl(
                   overlayGroup = c("salesMap"),
                   options = layersControlOptions(collapsed = FALSE)
                 )

# Rental Data
# rent_data : data set which consists of 5 types of bedrooms
# bed: type of bedroom such as 1,2,3,4,5 

bin1 <- c(0, 1000, 2000, 3000, 4000,Inf) #bed 1
bin2 <- c(0,1000,2000,3000,4000,5000,6000,7000, Inf) #bed2
bin3 <- c(0,2000,4000,6000,8000,Inf) #bed3
bin4 <- c(0,2000,4000,6000,8000,10000,Inf) #bed4
bin5 <- c(0,2000,4000,6000,8000,10000,Inf) #bed5


#YlGnBu (YlOrBr) (YlGn) Blues Reds (Accent) Oranges Purples
pal1 <- colorBin("YlGnBu", domain = nycounties$rental_Bed1, bins = bin1)
pal2 <- colorBin("Blues", domain = nycounties$rental_Bed2, bins = bin2)
pal3 <- colorBin("Reds", domain = nycounties$rental_Bed3, bins = bin3)
pal4 <- colorBin("Oranges", domain = nycounties$rental_Bed4, bins = bin4)
pal5 <- colorBin("Purples", domain = nycounties$rental_Bed5, bins = bin5)

labels_bed1 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed1
) %>% lapply(htmltools::HTML)


rental1bed <- basemap %>% addPolygons(
  fillColor = pal1(nycounties$rental_Bed1),
  color = "#444444", 
  weight = 2, 
  smoothFactor = 0.5, 
  opacity = 1.0, 
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#355C7D",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels_bed1,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")
)  %>% addLegend(pal = pal1, 
                 values = nycounties$rental_Bed1,
                 opacity = 0.7, 
                 title = 'Rental Price For 1 Bedroom',
                 position = "bottomright")

labels_bed2 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed2
) %>% lapply(htmltools::HTML)


rental2bed <- basemap %>% addPolygons(
  fillColor = pal2(nycounties$rental_Bed2),
  color = "#444444", 
  weight = 2, 
  smoothFactor = 0.5, 
  opacity = 1.0, 
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#355C7D",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels_bed2,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")
)  %>% addLegend(pal = pal2, 
                 values = nycounties$rental_Bed2,
                 opacity = 0.7, 
                 title = 'Rental Price For 2 Bedrooms',
                 position = "bottomright")

labels_bed3 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed3
) %>% lapply(htmltools::HTML)


rental3bed <- basemap %>% addPolygons(
  fillColor = pal3(nycounties$rental_Bed3),
  color = "#444444", 
  weight = 2, 
  smoothFactor = 0.5, 
  opacity = 1.0, 
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#355C7D",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels_bed3,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")
)  %>% addLegend(pal = pal3, 
                 values = nycounties$rental_Bed3,
                 opacity = 0.7, 
                 title = 'Rental Price For 3 Bedrooms',
                 position = "bottomright")

labels_bed4 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed4
) %>% lapply(htmltools::HTML)


rental4bed <- basemap %>% addPolygons(
  fillColor = pal4(nycounties$rental_Bed4),
  color = "#444444", 
  weight = 2, 
  smoothFactor = 0.5, 
  opacity = 1.0, 
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#355C7D",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels_bed4,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")
)  %>% addLegend(pal = pal4, 
                 values = nycounties$rental_Bed4,
                 opacity = 0.7, 
                 title = 'Rental Price For 4 Bedrooms',
                 position = "bottomright")

labels_bed5 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed5
) %>% lapply(htmltools::HTML)


rental5bed <- basemap %>% addPolygons(
  fillColor = pal5(nycounties$rental_Bed5),
  color = "#444444", 
  weight = 2, 
  smoothFactor = 0.5, 
  opacity = 1.0, 
  dashArray = "3",
  fillOpacity = 0.7,
  highlight = highlightOptions(
    weight = 5,
    color = "#355C7D",
    dashArray = "",
    fillOpacity = 0.7,
    bringToFront = TRUE),
  label = labels_bed5,
  labelOptions = labelOptions(
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")
)  %>% addLegend(pal = pal5, 
                 values = nycounties$rental_Bed5,
                 opacity = 0.7, 
                 title = 'Rental Price For 5 Bedrooms',
                 position = "bottomright")

#functions



# Define server logic required to draw a histogram
server <- function(input, output) {
  output$BedroomSale <- renderLeaflet({
    sales <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        fillColor = pal(nycounties$sales),
        color = "#444444", 
        weight = 2, 
        smoothFactor = 0.5, 
        opacity = 1.0, 
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#355C7D",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels_sales,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto"))%>% addLegend(pal = pal, 
                                            values = nycounties$sales,
                                            opacity = 0.7, 
                                            title = 'Price Per Square Feet',
                                            position = "bottomright") 
    
    sales %>% addMarkers(lng = hospital$Longitude, lat = hospital$Latitude, clusterOptions = markerClusterOptions() , popup = pops[['hospital']], icon=iconS[['hospital']], group="hospital") %>% 
      addMarkers(lng = art$long, lat = art$lat,clusterOptions = markerClusterOptions() , popup = pops[['art']], icon=iconS[['art']], group="gallery") %>% addMarkers(lng = theatre$long, lat = theatre$lat,clusterOptions = markerClusterOptions() , popup = pops[['theatre']], icon=iconS[['theatre']], group="theatre") %>%
      addMarkers(lng = subway$Long, lat = subway$Lat,clusterOptions = markerClusterOptions(), popup = pops[['subway']], icon=iconS[['subway']], group="subway") %>% addMarkers(lng = crime$Longitude, lat = crime$Latitude,clusterOptions = markerClusterOptions(), popup = pops[['crime']], icon=iconS[['crime']], group="crime") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime"))
    
  })
  output$Bedroom1 <- renderLeaflet({
    rental1bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        fillColor = pal1(nycounties$rental_Bed1),
        color = "#444444", 
        weight = 2, 
        smoothFactor = 0.5, 
        opacity = 1.0, 
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#355C7D",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels_bed1,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      )  %>% addLegend(pal = pal1, 
                       values = nycounties$rental_Bed1,
                       opacity = 0.7, 
                       title = 'Rental Price For 1 Bedroom',
                       position = "bottomright") 
    
    rental1bed %>% addMarkers(lng = hospital$Longitude, lat = hospital$Latitude, clusterOptions = markerClusterOptions() , popup = pops[['hospital']], icon=iconS[['hospital']], group="hospital") %>% 
      addMarkers(lng = art$long, lat = art$lat,clusterOptions = markerClusterOptions() , popup = pops[['art']], icon=iconS[['art']], group="gallery") %>% addMarkers(lng = theatre$long, lat = theatre$lat,clusterOptions = markerClusterOptions() , popup = pops[['theatre']], icon=iconS[['theatre']], group="theatre") %>%
      addMarkers(lng = subway$Long, lat = subway$Lat,clusterOptions = markerClusterOptions(), popup = pops[['subway']], icon=iconS[['subway']], group="subway") %>% addMarkers(lng = crime$Longitude, lat = crime$Latitude,clusterOptions = markerClusterOptions(), popup = pops[['crime']], icon=iconS[['crime']], group="crime") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime"))
  })
  output$Bedroom2 <- renderLeaflet({
    rental2bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        fillColor = pal2(nycounties$rental_Bed2),
        color = "#444444", 
        weight = 2, 
        smoothFactor = 0.5, 
        opacity = 1.0, 
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#355C7D",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels_bed2,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      )  %>% addLegend(pal = pal2, 
                       values = nycounties$rental_Bed2,
                       opacity = 0.7, 
                       title = 'Rental Price For 2 Bedrooms',
                       position = "bottomright") 
    
    rental2bed %>% addMarkers(lng = hospital$Longitude, lat = hospital$Latitude, clusterOptions = markerClusterOptions() , popup = pops[['hospital']], icon=iconS[['hospital']], group="hospital") %>% 
      addMarkers(lng = art$long, lat = art$lat,clusterOptions = markerClusterOptions() , popup = pops[['art']], icon=iconS[['art']], group="gallery") %>% addMarkers(lng = theatre$long, lat = theatre$lat,clusterOptions = markerClusterOptions() , popup = pops[['theatre']], icon=iconS[['theatre']], group="theatre") %>%
      addMarkers(lng = subway$Long, lat = subway$Lat,clusterOptions = markerClusterOptions(), popup = pops[['subway']], icon=iconS[['subway']], group="subway") %>% addMarkers(lng = crime$Longitude, lat = crime$Latitude,clusterOptions = markerClusterOptions(), popup = pops[['crime']], icon=iconS[['crime']], group="crime") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime"))
  })
  output$Bedroom3 <- renderLeaflet({
    rental3bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        fillColor = pal3(nycounties$rental_Bed3),
        color = "#444444", 
        weight = 2, 
        smoothFactor = 0.5, 
        opacity = 1.0, 
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#355C7D",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels_bed3,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      )  %>% addLegend(pal = pal3, 
                       values = nycounties$rental_Bed3,
                       opacity = 0.7, 
                       title = 'Rental Price For 3 Bedrooms',
                       position = "bottomright")
    
    rental3bed %>% addMarkers(lng = hospital$Longitude, lat = hospital$Latitude, clusterOptions = markerClusterOptions() , popup = pops[['hospital']], icon=iconS[['hospital']], group="hospital") %>% 
      addMarkers(lng = art$long, lat = art$lat,clusterOptions = markerClusterOptions() , popup = pops[['art']], icon=iconS[['art']], group="gallery") %>% addMarkers(lng = theatre$long, lat = theatre$lat,clusterOptions = markerClusterOptions() , popup = pops[['theatre']], icon=iconS[['theatre']], group="theatre") %>%
      addMarkers(lng = subway$Long, lat = subway$Lat,clusterOptions = markerClusterOptions(), popup = pops[['subway']], icon=iconS[['subway']], group="subway") %>% addMarkers(lng = crime$Longitude, lat = crime$Latitude,clusterOptions = markerClusterOptions(), popup = pops[['crime']], icon=iconS[['crime']], group="crime") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime"))
  })
  output$Bedroom4 <- renderLeaflet({
    rental4bed  <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        fillColor = pal4(nycounties$rental_Bed4),
        color = "#444444", 
        weight = 2, 
        smoothFactor = 0.5, 
        opacity = 1.0, 
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#355C7D",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels_bed4,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      )  %>% addLegend(pal = pal4, 
                       values = nycounties$rental_Bed4,
                       opacity = 0.7, 
                       title = 'Rental Price For 4 Bedrooms',
                       position = "bottomright")
    
    rental4bed %>% addMarkers(lng = hospital$Longitude, lat = hospital$Latitude, clusterOptions = markerClusterOptions() , popup = pops[['hospital']], icon=iconS[['hospital']], group="hospital") %>% 
      addMarkers(lng = art$long, lat = art$lat,clusterOptions = markerClusterOptions() , popup = pops[['art']], icon=iconS[['art']], group="gallery") %>% addMarkers(lng = theatre$long, lat = theatre$lat,clusterOptions = markerClusterOptions() , popup = pops[['theatre']], icon=iconS[['theatre']], group="theatre") %>%
      addMarkers(lng = subway$Long, lat = subway$Lat,clusterOptions = markerClusterOptions(), popup = pops[['subway']], icon=iconS[['subway']], group="subway") %>% addMarkers(lng = crime$Longitude, lat = crime$Latitude,clusterOptions = markerClusterOptions(), popup = pops[['crime']], icon=iconS[['crime']], group="crime") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime"))
  })
  output$Bedroom5 <- renderLeaflet({
    rental5bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        fillColor = pal5(nycounties$rental_Bed5),
        color = "#444444", 
        weight = 2, 
        smoothFactor = 0.5, 
        opacity = 1.0, 
        dashArray = "3",
        fillOpacity = 0.7,
        highlight = highlightOptions(
          weight = 5,
          color = "#355C7D",
          dashArray = "",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels_bed5,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
      )  %>% addLegend(pal = pal5, 
                       values = nycounties$rental_Bed5,
                       opacity = 0.7, 
                       title = 'Rental Price For 5 Bedrooms',
                       position = "bottomright")
    
    rental5bed %>% addMarkers(lng = hospital$Longitude, lat = hospital$Latitude, clusterOptions = markerClusterOptions() , popup = pops[['hospital']], icon=iconS[['hospital']], group="hospital") %>% 
      addMarkers(lng = art$long, lat = art$lat,clusterOptions = markerClusterOptions() , popup = pops[['art']], icon=iconS[['art']], group="gallery") %>% addMarkers(lng = theatre$long, lat = theatre$lat,clusterOptions = markerClusterOptions() , popup = pops[['theatre']], icon=iconS[['theatre']], group="theatre") %>%
      addMarkers(lng = subway$Long, lat = subway$Lat,clusterOptions = markerClusterOptions(), popup = pops[['subway']], icon=iconS[['subway']], group="subway") %>% addMarkers(lng = crime$Longitude, lat = crime$Latitude,clusterOptions = markerClusterOptions(), popup = pops[['crime']], icon=iconS[['crime']], group="crime") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime"))
  })
  


 
  #OutputMap('BedroomSale',input$S_Factors_1,'subway')
  
  #fac_s = c(S_Factors_1,S_Factors_2,S_Factors_3,S_Factors_4,S_Factors_5)
  #tol_Out(input,'BedroomSale',S_Factors_1,S_Factors_2,S_Factors_3,S_Factors_4,S_Factors_5)
  
  #fac_r1 = c(R1_Factors_1,R1_Factors_2,R1_Factors_3,R1_Factors_4,R1_Factors_5)
  #tol_Out(input,rental1bed,R1_Factors_1,R1_Factors_2,R1_Factors_3,R1_Factors_4,R1_Factors_5)
  
  #fac_r2 = c(R2_Factors_1,R2_Factors_2,R2_Factors_3,R2_Factors_4,R2_Factors_5)
  #tol_Out(input,rental2bed,R2_Factors_1,R2_Factors_2,R2_Factors_3,R2_Factors_4,R2_Factors_5)
  
  #fac_r3 = c(R3_Factors_1,R3_Factors_2,R3_Factors_3,R3_Factors_4,R3_Factors_5)
  #tol_Out(input,rental3bed,R3_Factors_1,R3_Factors_2,R3_Factors_3,R3_Factors_4,R3_Factors_5)
  
  #fac_r4 = c(R4_Factors_1,R4_Factors_2,R4_Factors_3,R4_Factors_4,R4_Factors_5)
  #tol_Out(input,rental4bed,R4_Factors_1,R4_Factors_2,R4_Factors_3,R4_Factors_4,R4_Factors_5)
  
  #fac_r5 = c(R5_Factors_1,R5_Factors_2,R5_Factors_3,R5_Factors_4,R5_Factors_5)
  #tol_Out(input,rental5bed,R5_Factors_1,R5_Factors_2,R5_Factors_3,R5_Factors_4,R5_Factors_5)

  }

