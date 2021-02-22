##### Create Analytic Dataset for PM 2.5 Models #####

# This script will:
# - merge the 5 outcome files into one dataset containing all outcomes
# - add temperature data for all zips
# - pull out vars relevant to PM 2.5 models and save them to an_dat_pm25.csv


library(tidyverse)
library(here)

fls = list.files(path = here("/raw_data/DMEdatasets20200929172326"))
setwd(here("/raw_data/DMEdatasets20200929172326"))
dt = lapply(fls, read.csv)

# we know that each file is identical save the patient visits column
# therefore, just add subsequent columns to the first dataframe
dat <-
  cbind(
    dt[[1]],
    dt[[2]]$daily_byzip_ct_I_anydisease,
    dt[[3]]$daily_byzip_ct_R_anydisease,
    dt[[4]]$daily_byzip_ct_I_circulatory,
    dt[[5]]$daily_byzip_ct_R_circulatory
  ) %>% rename(
    visitsA = daily_byzip_ct_A_anydisease,
    visitsI = `dt[[2]]$daily_byzip_ct_I_anydisease`,
    visitsR = `dt[[3]]$daily_byzip_ct_R_anydisease`,
    visitsIC = `dt[[4]]$daily_byzip_ct_I_circulatory`, 
    visitsRC = `dt[[5]]$daily_byzip_ct_R_circulatory`
  ) %>% # remove empty rows (outside study area)
  filter((is.na(zcta) == FALSE) &
           (is.na(getty) == FALSE)) %>% # dates to date class
  mutate(
    date = as.Date(date, format = '%d%b%Y'),
    admitdate = as.Date(date, format = '%d%b%Y'))

# read in temp data
tps = list.files(path = here("/data"), pattern = '*.rds')
setwd(here("/data"))
tp = lapply(tps, readRDS)

# create temp data frame
tp <- do.call("rbind", tp) %>%
  rename(zcta = zip) %>%
  select(date, zcta, tmean) %>%
  mutate(date = as.Date(as.character(date), format = "%d/%m/%Y")) # date class

# join kaiser outcomes with temp data
dat <- dat %>% mutate(zcta = as.factor(zcta)) %>%
  left_join(tp, by = c("zcta", "date")) %>%
  select(
    zipid,
    zcta,
    date,
    visitsA,
    visitsI,
    visitsR,
    visitsIC,
    visitsRC,
    county,
    po_name,
    non_wf_pm,
    wf_pm25,
    tmean
  )

# add numbered days
l <- sort(unique(dat$date))
day <- seq(1, length(l), 1)
l <- data.frame(l, day) %>% rename(date = l)
dat <- dat %>% left_join(l)


write.csv(dat, here("/data/an_dat_pm25.csv"))  
  
  
  
