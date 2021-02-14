###### Kaiser Wildfire Regression Model, Take 2 #####

library(tidyverse)
library(here)
library(mgcv)

an_dat <- read.csv(here("/data/an_dat.csv"), row.names = 1) 

m1 <- gam(visitsA ~ getty + getty_disaster_20km + s(wkmntp) + s(wkyrseq), data = an_dat, family = nb(link = "log")) 
# nb should estimate theta parameter (dispersion parameter), whereas negbin would not and would require a specification

plot(m1)
summary(m1)

an_dat %>% filter(zipid == "0130O") %>% ggplot(aes(x = wkyrseq, y = wkmntp)) + geom_line()
an_dat %>% ggplot(aes(x = wkmntp, y = visitsA)) + geom_line()



