###### Kaiser Wildfire Regression Model, Take 2 #####

library(tidyverse)
library(here)
library(mgcv)

an_dat <- read.csv(here("/data/an_dat.csv"), row.names = 1) 

m1 <- gam(visitsA ~ getty + getty_disaster_20km + wkmntp + s(wkyrseq), data = an_dat, family = nb(link = "log")) 
# nb should estimate theta parameter (dispersion parameter), whereas negbin would not