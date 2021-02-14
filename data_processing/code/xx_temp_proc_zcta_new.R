# This script will:

# load raster file for particular year
# load shapefile
# isolate each zip/zcta code's data in raster via shapefile and then find area-weighted mean
# output result

# from Robbie M Parks 2020 GitHub; modified for our purposes

rm(list=ls())

library(maptools)
library(mapproj)
library(rgeos)
library(rgdal)
library(RColorBrewer)
library(ggplot2)
library(raster)
library(sp)
library(plyr)
library(graticule)
library(zoo)

# arguments from Rscript
args = commandArgs(trailingOnly=TRUE)

# year of interest
year = as.numeric(args[1])
dname = as.character(args[2])
time.res = as.character(args[3])
space.res = as.character(args[4])
state = as.character(args[5])

print('running grid_county_intersection_raster_prism.R')
print(args)

# output directory:
dir.output = "/Users/heathermcbrien/Documents/GitHub.nosync/kaiser_wildfires/data_processing/data"

# load shapefile (just one state at a time) - add state col even though it's fake. just makes it so i don't have to change the script more
us.national = readOGR(dsn= "/Users/heathermcbrien/Documents/GitHub.nosync/kaiser_wildfires/data_processing/raw_data/zcta_shapefile/tl_2019_us_zcta510.shp")
zips = sort(unique((read.csv("/Users/heathermcbrien/Documents/GitHub.nosync/kaiser_wildfires/data_processing/raw_data/zip_zcta_xwalk.csv"))$x))
us.national = us.national[us.national$ZCTA5CE10 %in% c(zips),]
us.national$STATEFP = rep("06", length(us.national$ZCTA5CE10))

us.main = us.national

# get projection of shapefile
original.proj = proj4string(us.national)

###############################################################################
# function to perform analysis for entire state
state.analysis = function(state.arg='01',output=0) {
  
  # isolate state
  state.fips  = as.character(state.arg)
  us.state = us.main[us.main$STATEFP %in% state.fips,]
  
  # plot state with highlighted county and grids that overlap
  if(output==1){
    pdf(paste0(dir.output,'county_graticule_highlighted_unproj_',state.fips,'.pdf'))}
  
  if(space.res=='zip'){
    # obtain a list of zip codes in a particular state
    zips = sort(unique(as.character(us.state$ZCTA5CE10)))
    # print(zips)
  }
  if(space.res=='fips'){
    # obtain a list of fips codes in a particular state
    zips = sort(unique(as.character(us.state$GEOID)))
    # print(zips)
  }
  
  # create empty dataframe to fill with zip code summary information
  weighted.area = data.frame()
  
  for(zip in zips) {
    
    # process zip preamble
    zip = as.character(zip)
    # print(paste('current status:',zip))
    
    # isolate zip to highlight
    if(space.res=='zip'){us.zip = us.state[us.state$ZCTA5CE10 %in% zip,]}
    if(space.res=='fips'){us.zip = us.state[us.state$GEOID %in% zip,]}
    
    # crop raster by current zip code
    # raster.crop = crop(x=raster.full,y=us.zip)
    ## raster.crop = crop(x=raster.full,y=us.zip) TO PUT BACK IN IF USING BELOW
    
    # to plot if want to check that raster and shapefile overlap using manhattan
    # plot(manhattan) ; plot(raster.manhattan,add=TRUE) ; plot(manhattan,add=TRUE)
    # plot(raster.crop,add=TRUE, col='grey') ;  plot(us.zip,col='red',add=TRUE)
    
    # create polygon from cropped polygon
    ## raster.crop[raster.crop[]<0] = NA TO PUT BACK IN IF USING BELOW
    
    # create weighted average of values from raster polygon
    # from https://gis.stackexchange.com/questions/213493/area-weighted-average-raster-values-within-each-spatialpolygonsdataframe-polygon/213503#213503
    
    # CURRENTLY SEVERAL OPTIONS BELOW WHICH NEED TO BE DECIDED UPON. ONE WITH RASTER.FULL IS CURRENTLY MY FAVOURITE
    # current.value = extract(x=raster.crop,weights = TRUE, normalizeWeights=TRUE,y=us.zip,fun=mean,df=TRUE,na.rm=TRUE)
    # current.value = extract(x=raster.full,y=us.zip,fun=mean,df=TRUE,na.rm=TRUE)
    current.value = extract(x=raster.full,weights = TRUE, normalizeWeights=TRUE,y=us.zip,fun=mean,df=TRUE,na.rm=TRUE)
    
    to.add = data.frame(zip,value=current.value[1,2])
    weighted.area = rbind(weighted.area,to.add)
    
    # print(to.add)
  }
  
  names(weighted.area) = c('zip',dname)
  
  return(weighted.area)
  
}

###############################################################################

# record of every state in the current shapefile
states = sort(unique(as.character(us.main$STATEFP)))

if(time.res=='daily'){
  # loop through each raster file for each day and summarise
  dates <- seq(as.Date(paste0('0101',year),format="%d%m%Y"), as.Date(paste0('3112',year),format="%d%m%Y"), by=1)
  
  # empty dataframe to load summarised national daily values into
  weighted.area.national.total = data.frame()
  
  # loop through each day of the year and perform analysis
  print(paste0('Processing dates in ',year))
  for(date in dates){
    
    print(format(as.Date(date), "%d/%m/%Y"))
    
    day = format(as.Date(date), "%d")
    month = format(as.Date(date), "%m")
    day.month = paste0(month,day)
    
    print(day.month)
    
    # load raster for relevant date
    raster.full = raster(paste0("/Users/heathermcbrien/Documents/GitHub.nosync/kaiser_wildfires/data_processing/raw_data", '/PRISM', year, '/PRISM_',dname,'_stable_4kmD2_',year,day.month,'_bil.bil'))
    raster.full = projectRaster(raster.full, crs=original.proj)
    
    # create empty dataframe to fill with zip code summary information
    weighted.area.national = data.frame()
    
    # perform loop across all states
    system.time(
      for(i in states){
        analysis.dummy = state.analysis(i)
        analysis.dummy$date = format(as.Date(date), "%d/%m/%Y")
        analysis.dummy$day = day
        analysis.dummy$month = month
        analysis.dummy$year = year
        
        weighted.area.national = rbind(weighted.area.national,analysis.dummy)
      }
    )
    
    # weighted.area.national = weighted.area.national[,c(3,1,2)]
    weighted.area.national.total = rbind(weighted.area.national.total,weighted.area.national)
  }
}

if(space.res=='zip'){
  saveRDS(weighted.area.national.total,paste0(dir.output,'/weighted_area_raster_zip','_',dname,'_',time.res,'_',as.character(year),'.rds'))
}
