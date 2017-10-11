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
library(plotly)
library(ggplot2)
library(zoo)
library(sf)
# Preparation
#nycounties <- geojson_read("./data/nyczip.geojson", what = "sp")

#nycounties <- readOGR(dsn="./data/mygeodata/", layer="nyczip.shp")
nycounties <- readOGR("./data/mygeodata/nyczip.shp")


sales <- read.csv("./data/Sale_Data.csv", header=TRUE, stringsAsFactors = FALSE)
nycounties$postalCode <- as.numeric(as.character(nycounties$postalCode))
dat <- nycounties@data
salesPrice <- NULL
for(i in 1:nrow(dat)){
  zip <- dat$postalCode[i]
  salesPrice <- c(salesPrice, sales$Price_Predict[sales$RegionName == zip])
}
nycounties@data$sales <- salesPrice

# Load data

#School
school <- read.csv("./data/School_Data.csv", header=TRUE, stringsAsFactors = FALSE)
school <- school %>% na.omit() 
school$longitude <- school$long
school$latitude <- school$lat

rental <- read.csv("./data/Rental_Data.csv", header=TRUE, stringsAsFactors = FALSE)
dat <- nycounties@data
l <- list()
for (i in 1:5){
  s<-read.csv(paste("./data/rental_bed",i,".csv", sep=""), header=TRUE, stringsAsFactors = FALSE)
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

hospital <- read.csv("./data/Hospital_Data.csv", header=TRUE, stringsAsFactors = FALSE)
hospital$longitude <- hospital$Longitude
hospital$latitude <- hospital$Latitude
#art
art <- read.csv("./data/Art_Gallery_Data.csv", header=TRUE, stringsAsFactors = FALSE)
art$longitude <- art$long
art$latitude <- art$lat
#theatre
theatre <- read.csv("./data/Theatre_Data.csv", header=TRUE, stringsAsFactors = FALSE)

theatre$longitude <- theatre$long
theatre$latitude <- theatre$lat
#subway
subway <- read.csv("./data/Subway_Data.csv", header=TRUE, stringsAsFactors = FALSE)
subway$longitude <- subway$Long
subway$latitude <- subway$Lat
#crime
crime <- read.csv("./data/Crime_Data.csv", header=TRUE, stringsAsFactors = FALSE)
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

iconS$hospital <- IconMaker("./fig/Hospital.png")

iconS$art <- IconMaker("./fig/Gallery.png")

iconS$theatre <- IconMaker("./fig/Theatre.png")

iconS$subway <- IconMaker("./fig/Subway.png")

iconS$crime <- IconMaker("./fig/Crime.png")

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
labels_bed2 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed2
) %>% lapply(htmltools::HTML)
labels_bed3 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed3
) %>% lapply(htmltools::HTML)
labels_bed4 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed4
) %>% lapply(htmltools::HTML)
labels_bed5 <- sprintf(
  "Zip Code: <strong>%s</strong><br/>Median Price: <strong>$%g</strong>",
  as.character(nycounties$postalCode), nycounties$rental_Bed5
) %>% lapply(htmltools::HTML)

data_rental <- rental
data_sale <- sales
x<- as.yearmon("2011-09") + 0:71/12

# TimeSeries for Rental
TimeSeriesPlot_rent <- function(x,y) {
  zip<- data_rental[data_rental$RegionName == x, ]
  zip_room <- zip[zip$Bedroom == y, -c(1,2,3,4)]
  time <- as.yearmon("2011-09") + 0:71/12
  y <- unlist(zip_room)
  df <- data.frame(timeperiod=time, price=y)
  plot_ly(data = df, x=~timeperiod, y=~price, mode = 'lines', opacity=0.8,
          type="scatter", text = paste("Room Price is",y))
  
}
TimeSeriesPlot_rent(10025,1)
TimeSeriesPlot_rent(10001,1)

# TimeSeries for Sale
TimeSeriesPlot_sale <- function(Zipcode) {
  time <- as.yearmon("2011-09") + 0:71/12
  zip <- data_sale[data_sale$RegionName == Zipcode, -c(1,2,3)]
  y <- unlist(zip)
  df <- data.frame(timeperiod=time, price=y)
  plot_ly(data = df, x=~timeperiod, y=~price, mode = 'lines', type="scatter", text = paste("Room Price is",y))
}

info_zip <- read.csv("./data/Zipcode_General_Info.csv", header=TRUE, stringsAsFactors = FALSE)
gallery <- art

crime_n <- as.matrix(unique(crime $ BORO_NM))
n1 <- function(x){
  sum(crime $ BORO_NM == x)
}
num_crime <- mapply(crime_n, FUN = n1)
# sort(num_crime,decreasing = TRUE)
df <- data.frame(place = crime_n, num = num_crime)
top_5_crime <- ggplot(df, aes(x = reorder(place, -num), y = num, fill=place)) + geom_bar(stat = "identity", width = 0.7) + labs(x = "places")



#hospital
hospital_n <- as.matrix(unique(hospital $ Borough))
n2 <- function(x){
  sum(hospital $ Borough == x)
}
num_hospital <- mapply(hospital_n, FUN = n2)
df <- data.frame(place = hospital_n, num = num_hospital)
top_5_hospital <- ggplot(df, aes(x = reorder(place, -num), y = num, fill=place)) + geom_bar(stat = "identity", width = 0.7) + labs(x = "places")



#gallery
gallery_n <- as.matrix(unique(gallery $ CITY ))
n3 <- function(x){
  sum(gallery $ CITY == x)
}
num_gallery1 <- mapply(gallery_n, FUN = n3)
num_gallery <- tail(sort(num_gallery1),5)
df <- data.frame(place = gallery_n, num = num_gallery1)
top5 <- df[which(df$num %in% num_gallery),]
place <- factor(top5 $ place)
num <- factor(top5 $ num)
top_5_gallery <- ggplot(top5, aes(x = reorder(place, -num), y = num, fill=place)) + geom_bar(stat = "identity", width = 0.7) + labs(x = "places")

# Define server logic required to draw a histogram
server <- function(input, output) {
  data_of_click <- reactiveValues(clicked_zone=NULL)
  output$BedroomSale <- renderLeaflet({
    sales <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        layerId = nycounties$postalCode,
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
      addMarkers(lng = school$long, lat = school$lat,clusterOptions = markerClusterOptions() , popup = pops[['school']], icon=iconS[['school']], group="school") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime", "school"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime","school"))
    
  })
  output$Bedroom1 <- renderLeaflet({
    rental1bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        layerId = nycounties$postalCode,
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
      addMarkers(lng = school$long, lat = school$lat,clusterOptions = markerClusterOptions() , popup = pops[['school']], icon=iconS[['school']], group="school") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime", "school"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime", "school"))
  })
  output$Bedroom2 <- renderLeaflet({
    rental2bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        layerId = nycounties$postalCode,
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
      addMarkers(lng = school$long, lat = school$lat,clusterOptions = markerClusterOptions() , popup = pops[['school']], icon=iconS[['school']], group="school") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime", "school"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime", "school"))
  })
  output$Bedroom3 <- renderLeaflet({
    rental3bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        layerId = nycounties$postalCode,
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
      addMarkers(lng = school$long, lat = school$lat,clusterOptions = markerClusterOptions() , popup = pops[['school']], icon=iconS[['school']], group="school") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime", "school"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime", "school"))
  })
  output$Bedroom4 <- renderLeaflet({
    rental4bed  <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        layerId = nycounties$postalCode,
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
      addMarkers(lng = school$long, lat = school$lat,clusterOptions = markerClusterOptions() , popup = pops[['school']], icon=iconS[['school']], group="school") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime", "school"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime", "school"))
  })
  output$Bedroom5 <- renderLeaflet({
    rental5bed <- leaflet(nycounties) %>% 
      setView(lat=40.7128, lng=-74.0059, zoom=10) %>% addPolygons( color = "#BFA",weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5, highlightOptions = highlightOptions(color = "red", weight = 2, bringToFront = TRUE)) %>% 
      addTiles()%>%
      
      #addTiles(group = "BaseMap") %>% 
      #addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
      addPolygons(
        layerId = nycounties$postalCode,
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
      addMarkers(lng = school$long, lat = school$lat,clusterOptions = markerClusterOptions() , popup = pops[['school']], icon=iconS[['school']], group="school") %>%
      addLayersControl(
        #baseGroups = c("BaseMap", "Toner"),
        overlayGroups = c("hospital", "gallery", "theatre", "subway", "crime", "school"),
        options = layersControlOptions(collapsed = FALSE))%>% hideGroup(c("hospital", "gallery", "theatre", "subway", "crime", "school"))
  })
  
  
  
  output$ranks <- renderPlot({
    if(input$rankfact == 'Crime'){
      top_5_crime
    }
    else if(input$rankfact == 'Hospital'){
      top_5_hospital}
    else if(input$rankfact == 'Gallery'){
      top_5_gallery
      }
  })
  #output$instruction <- renderText({
    
  #})
  observeEvent(input$BedroomSale_shape_click, { # update the even object when clicking on a geojson shape
    data_of_click$clicked_zone <- input$BedroomSale_shape_click     
  })
  observeEvent(input$Bedroom1_shape_click, { # update the even object when clicking on a geojson shape
    data_of_click$clicked_zone <- input$Bedroom1_shape_click     
  })
  observeEvent(input$Bedroom2_shape_click, { # update the even object when clicking on a geojson shape
    data_of_click$clicked_zone <- input$Bedroom2_shape_click  
    #browser()
    #print('hello')
  })
  observeEvent(input$Bedroom3_shape_click, { # update the even object when clicking on a geojson shape
    data_of_click$clicked_zone <- input$Bedroom3_shape_click     
  })
  observeEvent(input$Bedroom4_shape_click, { # update the even object when clicking on a geojson shape
    data_of_click$clicked_zone <- input$Bedroom4_shape_click     
  })  
  
  observeEvent(input$Bedroom5_shape_click, { # update the even object when clicking on a geojson shape
    data_of_click$clicked_zone <- input$Bedroom5_shape_click     
  })  
  
  
  # Make a barplot or scatterplot depending of the selected point
  output$text01 <- renderUI({
    str1 <- paste0("<b>",info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood,"</b>")
    
    HTML(str1)})
  output$text02 <- renderUI({
    str1 <- paste0("<b>",info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood,"</b>")
    
    HTML(str1)})
  output$text03 <- renderUI({
    str1 <- paste0("<b>",info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood,"</b>")
    
    HTML(str1)})
  output$text04 <- renderUI({
    str1 <- paste0("<b>",info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood,"</b>")
    
    HTML(str1)})
  output$text05 <- renderUI({
    str1 <- paste0("<b>",info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood,"</b>")
    
    HTML(str1)})
  output$text06 <- renderUI({
    str1 <- paste0("<b>",info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood,"</b>")
    
    HTML(str1)})
  
  
  output$text1 <- renderUI({
    if(!is.null(data_of_click$clicked_zone$id)){
      str1 <- paste0("<b>","Demograhics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :",'</b>')
      str2 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Demographics,'</br>')
      str3 <- paste0("<b>","Real Estate Characteristics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :","</b>")
      str4 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Real.Estate,'</br>')
      str5 <- paste0("<b>","Median salary in the neighborhood:","</b>")
      str6 <- paste(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Earnings)  
      HTML(paste(str1, str2, str3, str4, str5, str6, sep = '<br/>'))}
    else{
      HTML(' ')
    }
  })
  output$text2 <- renderUI({
    if(!is.null(data_of_click$clicked_zone$id)){
      str1 <- paste0("<b>","Demograhics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :",'</b>')
      str2 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Demographics,'</br>')
      str3 <- paste0("<b>","Real Estate Characteristics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :","</b>")
      str4 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Real.Estate,'</br>')
      str5 <- paste0("<b>","Median salary in the neighborhood:","</b>")
      str6 <- paste(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Earnings)  
      HTML(paste(str1, str2, str3, str4, str5, str6, sep = '<br/>'))}
    else{
      HTML(' ')
    }
  })
  output$text3 <- renderUI({
    if(!is.null(data_of_click$clicked_zone$id)){
      str1 <- paste0("<b>","Demograhics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :",'</b>')
      str2 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Demographics,'</br>')
      str3 <- paste0("<b>","Real Estate Characteristics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :","</b>")
      str4 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Real.Estate,'</br>')
      str5 <- paste0("<b>","Median salary in the neighborhood:","</b>")
      str6 <- paste(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Earnings)  
      HTML(paste(str1, str2, str3, str4, str5, str6, sep = '<br/>'))}
    else{
      HTML(' ')
    }
  })
  output$text4 <- renderUI({
    if(!is.null(data_of_click$clicked_zone$id)){
      str1 <- paste0("<b>","Demograhics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :",'</b>')
      str2 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Demographics,'</br>')
      str3 <- paste0("<b>","Real Estate Characteristics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :","</b>")
      str4 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Real.Estate,'</br>')
      str5 <- paste0("<b>","Median salary in the neighborhood:","</b>")
      str6 <- paste(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Earnings)  
      HTML(paste(str1, str2, str3, str4, str5, str6, sep = '<br/>'))}
    else{
      HTML(' ')
    }
  })
  output$text5 <- renderUI({
    if(!is.null(data_of_click$clicked_zone$id)){
      str1 <- paste0("<b>","Demograhics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :",'</b>')
      str2 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Demographics,'</br>')
      str3 <- paste0("<b>","Real Estate Characteristics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :","</b>")
      str4 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Real.Estate,'</br>')
      str5 <- paste0("<b>","Median salary in the neighborhood:","</b>")
      str6 <- paste(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Earnings)  
      HTML(paste(str1, str2, str3, str4, str5, str6, sep = '<br/>'))}
    else{
      HTML(' ')
    }
  })
  output$text6 <- renderUI({
    if(!is.null(data_of_click$clicked_zone$id)){
      str1 <- paste0("<b>","Demograhics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :",'</b>')
      str2 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Demographics,'</br>')
      str3 <- paste0("<b>","Real Estate Characteristics of ", info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Neighborhood, " :","</b>")
      str4 <- paste0(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Real.Estate,'</br>')
      str5 <- paste0("<b>","Median salary in the neighborhood:","</b>")
      str6 <- paste(info_zip[info_zip$Zip.Code==data_of_click$clicked_zone$id,]$Earnings)  
      HTML(paste(str1, str2, str3, str4, str5, str6, sep = '<br/>'))}
    else{
      HTML(' ')
    }
  })
  
  output$plot=renderPlotly({
    zip_code=data_of_click$clicked_zone$id
  
    if(is.null(zip_code)){
      p = plotly_empty()}
    else{
 
      p = TimeSeriesPlot_sale(zip_code)}
    p
  })
  
  output$plot1=renderPlotly({
    zip_code=data_of_click$clicked_zone$id
    
    if(is.null(zip_code)){
      p = plotly_empty()}
    else{
      print(zip_code)
      p = TimeSeriesPlot_rent(zip_code,1)}
    p
  })
  
  output$plot2=renderPlotly({
    zip_code=data_of_click$clicked_zone$id
    
    if(is.null(zip_code)){
      p = plotly_empty()}
    else{
    
      p = TimeSeriesPlot_rent(zip_code,2)
      }
    p
    
  })
  
  output$plot3=renderPlotly({
    zip_code=data_of_click$clicked_zone$id
    
    if(is.null(zip_code)){
      p = plotly_empty()}
    else{
      print(zip_code)
      p = TimeSeriesPlot_rent(zip_code,3)}
    p
  })
  
  output$plot4=renderPlotly({
    zip_code=data_of_click$clicked_zone$id
    
    if(is.null(zip_code)){
      p = plotly_empty()}
    else{
      print(zip_code)
      p = TimeSeriesPlot_rent(zip_code,4)}
    p
  })
  
  output$plot5=renderPlotly({
    zip_code=data_of_click$clicked_zone$id
    
    if(is.null(zip_code)){
      p = plotly_empty()}
    else{
      print(zip_code)
      p = TimeSeriesPlot_rent(zip_code,5)}
    p
  })
  output$dot_plot_sale <- renderPlotly({
    year = as.numeric(format(as.Date(input$obs),"%Y"))
    month = as.numeric(format(as.Date(input$obs),"%m"))
    year_gap = year -2011
    month_gap = month - 8
    index = year_gap*12 + month_gap
    price = sales[-1,index+3]
    zipcode <- sales$RegionName[-1]
    df <- data.frame(price=price, zipcode=zipcode)
    a <- list(range = c(9900, 11800), title = "Zip Code", zeroline = FALSE, showline = FALSE, 
              showgrid =FALSE, exponentformat="none", tickformat="{}")
    b <- list(range = c(-100, 3100), title = "PPSF (Price Per Square Feet)", zeroline = FALSE, showline = FALSE)
    
    plot_ly(
      df, x = ~zipcode, y = ~price, color = ~price, 
      mode = "markers", type="scatter", marker=list(size = 20, opacity=0.5), 
      width = 800, height = 600) %>% layout(autosize = F, xaxis = a, yaxis = b)
    
  })
  
  }

