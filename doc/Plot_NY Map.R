library(tidyverse)
library(ggmap)
library(DT)
library(knitr)

install.packages("ggmap")
library(ggmap)


setwd("/home/vassily/Desktop/Columbia/Fall 2017/Applied Data Science/Project 2/")

housing_prices = read.csv("2009_manhattan_housing.csv")
housing_prices$location <- paste0(housing_prices$ADDRESS, ", ", "New York", ", NY ", housing_prices$ZIP.CODE)

# This function geocodes a location (find latitude and longitude) using the Google Maps API
geo <- geocode(location = housing_prices$location, output="latlon", source="google")

housing_prices$lon <- geo$lon
housing_prices$lat <- geo$lat

#restricted to 2500 request per day !!
#turn around !!
library(zipcode)
data(zipcode)
housing_prices = merge(housing_prices, zipcode, by.x='ZIP.CODE', by.y='zip')

#clean data:
housing_prices <- housing_prices[housing_prices$SALE.PRICE!=0,]


# Download the base map
NY_road <- get_map(location = "New York City", maptype = "roadmap") #maptype option to explore
g <- ggmap(NY_road)

nyc <- c(lon = -74.0059, lat = 40.7128)
NY_base <- get_map(location = nyc, zoom=20)
g2 <- ggmap(NY_base)

g

# Draw the heat map

g <- g+stat_density2d( aes(x = longitude, y = latitude, fill=SALE.PRICE), data=housing_prices,geom="polygon", alpha=0.2)
g + scale_fill_gradient(low = "green", high = "red")


ggmap(NY_road, extent = "device") + geom_density2d(data = housing_prices, aes(x = longitude, y = latitude), size = 0.3) + 
  stat_density2d(data = housing_prices, 
                 aes(x = longitude, y = latitude, fill = SALE.PRICE, alpha = SALE.PRICE), size = 0.01, bins = 16, geom = "polygon") + scale_fill_gradient(low = "green", high = "red") + 
  scale_alpha(range = c(0, 0.3), guide = FALSE)
