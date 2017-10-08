# Project: NYC Open Data
### Data folder

The data directory contains data used in the analysis. This is treated as read only; in paricular the R/python files are never allowed to write to the files in here. Depending on the project, these might be csv files, a database, and the directory itself may have subdirectories.


## Art_Gallery_Data.csv

This csv file includes all art and gallery information (Name, Longitude and Latitude) of New York City.
It comes from NYC Open Data.

## Crime_Data.csv

This csv file includes all crime data (Type of crime, Longitude and Latitude) from 01/2017 to 06/30/2017.
It comes from data.gov.

## Hospital_Data.csv

This csv file includes all hospital information (Name, Longitude and Latitude) of New York City.
It comes from NYC Open Data.

## nyczip.geojson

This geojson file is used to create a New York City map in R.

## Rental_Data.csv

This csv file includes rental data in New York City from 09/2011 to 08/2017.
It includes zip code, type, the number of bedrooms, and time series median rental price for each kind of apartment in New York City.
It comes from Zillow.

## Sale_Data.csv

This csv file includes sale data in New York City from 09/2011 to 08/2017.
It includes zip code, type, and time series median Price Per Square Feet (PPSF) in a specific area of New York City.
It comes from Zillow.

## School_Data.csv

This csv file includes all schools information (Name, Longitude and Latitude) of New York City.
It comes from NYC Open Data.

## Subway_Data.csv

This csv file includes all subway station information (Name, Longitude and Latitude) of New York City.
It comes from NYC Open Data.

## Theatre_Data.csv

This csv file includes all theatres information (Name, Longitude and Latitude) of New York City.
It comes from NYC Open Data.

## Zip_Dataset.csv

This csv file includes all zip codes in New York City. 
It is extracted from nyczip.geojson file.

## Zipcode_General_Info.csv

This csv file includes some basic and general information about different zipcodes, like neighborhood, demographics, earnings, public transporation and real estate. 

It is scraped by Python on the website: https://www.unitedstateszipcodes.org/
