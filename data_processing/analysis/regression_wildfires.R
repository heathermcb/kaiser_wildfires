######### Neg Bin Regression Model - do wildfires inc. outpatient visits?

library(tidyverse)
library(here)

# read in, add zips
xwalk <-
  read_csv("zip_zcta_xwalk.csv") %>% 
  select(c("zip_code", "zcta"))
k <-
  read_csv(here('DMEdatasets20200929172326/dme_anydisease_A_09282020.csv')) %>% 
  left_join(xwalk)

library(lubridate)

# get rid of rows of data outside study area, and standardize dates + agg by week
k <- k %>%
  filter((is.na(zcta) == FALSE) &
           (is.na(getty) == FALSE)) %>% # attempt to filter out rows outside the study area
  mutate(
    date = as.Date(date, format = '%d%b%Y'),
    admitdate = as.Date(date, format = '%d%b%Y')
  ) %>%  # standardize dates into date class
  mutate(year = year(date), week = week(date)) %>%
  mutate(week = formatC(as.numeric(week), width = 2, format = "d", flag = "0")) %>%
  mutate(week_year = paste(year, week, sep = ""), fire = getty + woolsey) %>%
  group_by(week_year, zip_code) %>%
  add_tally(wt = daily_byzip_ct_A_anydisease)

# plot aggregated data
# k %>% 
#   ggplot() + 
#   geom_point(aes(x = as.numeric(week_year), y = n, color = fire)) + 
#   facet_wrap(facets = c("county"))

# analytic data frame:
an_dat <-
  k %>% select(n, getty_disaster_20km, woolsey_disaster_20km, getty, woolsey, fire, )

# model
library(MASS)
m <- glm.nb(n ~ getty_disaster_20km * getty, data = an_dat)
summary(m)
mn <- glm.nb(n ~ woolsey_disaster_20km * woolsey, data = an_dat)
summary(mn)

mc <- glm.nb(n ~ getty_disaster_20km + getty, data = an_dat)
summary(mc)
mnc <- glm.nb(n ~ woolsey_disaster_20km + woolsey, data = an_dat)
summary(mnc)


# from second regression file
library(mgcv)

# fit actual model
m1 <- gam(visits ~ getty + getty_disaster_20km + wkmntp + s(wkyrseq), data = k, family = nb(link = "log"))
summary(m1)
summary(m1$gam)
plot(m1$gam)

m1 <- gamm(visits ~ woolsey + woolsey_disaster_20km + wkmntp + s(wkyrseq), data = k, family = nb(link = "log"))

gam(visits ~ getty + getty_disaster_20km + wkmntp + s(wkyrseq), data = k, scale =  family = nb(link = "log"))