### Create Analytic Dataset for Kaiser Regression Models to come ###

# This script will:
# - merge the 5 outcome files into one dataset containing all outcomes
# - add temperature data for all zips
# - add a variable called weekyears to help with temporal covariates
# - add updated and corrected PM 2.5 data
# That will make an analytic dataset.

# Libraries & Read ----
library(tidyverse)
library(here)

fls = list.files(path = here("raw_data", "DMEdatasets20200929172326"))
setwd(here("raw_data", "DMEdatasets20200929172326"))
dt = lapply(fls, read.csv)

# Combine Datasets ----
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

# Temperature Data ----
# read in temp data
tps = list.files(path = here("data"), pattern = '*.rds')
setwd(here("data"))
tp = lapply(tps, readRDS)

# create temp data frame
tp <- do.call("rbind", tp) %>%
  rename(zcta = zip) %>%
  select(date, zcta, tmean) %>%
  mutate(date = as.Date(as.character(date), format = "%d/%m/%Y")) # date class

# join kaiser outcomes with temp data
dat <- dat %>% mutate(zcta = as.factor(zcta)) %>% 
  left_join(tp, by = c("zcta", "date"))

# PM 2.5 Correction ----
wf <- read_csv(here("raw_data", "wf_imp_IDW_intersect_SoCal_20Apr2021.csv")) %>%
  group_by(county, date, zip) %>%
  summarise(
    wf_pm25_idw_intrsct = mean(wf_pm25_idw_intrsct, na.rm = TRUE),
    wf_pm25_imp_intrsct = mean(wf_pm25_imp_intrsct, na.rm = TRUE),
    mean_pm25 = mean(mean_pm25, na.rm = TRUE)
  ) 

# need to go by zcta bc can't match zips
zipzcta <- read_csv(here("raw_data/zip_zcta_xwalk.csv")) %>% select(zip_code, zcta)

# collapse to zcta
wf <- wf %>% left_join(zipzcta, by = c("zip" = "zip_code")) %>%
  group_by(date, county, zcta) %>%
  summarise(
    mean_pm25 = mean(mean_pm25, na.rm = TRUE),
    wf_pm25_idw_intrsct = mean(wf_pm25_idw_intrsct, na.rm = TRUE),
    wf_pm25_imp_intrsct = mean(wf_pm25_imp_intrsct, na.rm = TRUE),
  ) %>%
  mutate(zcta = as.factor(zcta))

dat <- dat %>% 
  left_join(wf, by = c("county", "date", "zcta"))

# Edit: Daily data for DLNM 
dat <- dat %>% 
  select(date, zipid, visitsA, visitsI, visitsIC, visitsR, visitsRC, county,
         zcta, getty, woolsey, getty_disaster_20km, woolsey_disaster_20km, pov_p, 
         edu_lt_hs_p, med_inc, pop_gt65_p, tot_pop, black_p, hispan_p, white_p, 
         tmean, mean_pm25, wf_pm25_idw_intrsct) 
write.csv(dat, here::here('data', 'an_dat_daily.csv'))

# Aggregation ----
library(lubridate)
# aggregate both visits (by type of visit), temperature, and PM 2.5 by week
dat <- dat %>% mutate(year = year(date), week = week(date)) %>%
  mutate(week = formatC(
    as.numeric(week),
    width = 2,
    format = "d",
    flag = "0"
  )) %>%
  mutate(week_year = paste(year, week, sep = ""),
         fire = getty + woolsey) %>%
  group_by(week_year, zipid) %>% 
  summarise(
    visitsA = sum(visitsA),
    visitsI = sum(visitsI), 
    visitsR = sum(visitsR), 
    visitsIC = sum(visitsIC), 
    visitsRC = sum(visitsRC),
    wkmntp = mean(tmean),
    n = n(),
    getty = max(getty),
    woolsey = max(woolsey),
    getty_disaster_20km = max(getty_disaster_20km), 
    woolsey_disaster_20km = max(woolsey_disaster_20km), 
    fire = max(fire),
    mean_pm25 = mean(mean_pm25, na.rm = TRUE),
    wf_pm25_idw_intrsct = mean(wf_pm25_idw_intrsct, na.rm = TRUE),
    wf_pm25_imp_intrsct = mean(wf_pm25_imp_intrsct, na.rm = TRUE)
    ) 

# Add numbering for modelling ----
# weekyears
s = sort(unique(dat$week_year))
wkyrseq <- seq(1, length(s), 1)
s <- data.frame(s, wkyrseq) %>% rename(week_year = s)
dat <- dat %>% left_join(s)


# write
write.csv(dat, here::here('/data/an_dat.csv'))

