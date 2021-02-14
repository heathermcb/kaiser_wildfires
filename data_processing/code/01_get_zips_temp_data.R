### Create csv of ZCTAs in the Kaiser Study Area for which we need temp data ###

library(here)
library(tidyverse)

# load Kaiser data - all zips are the same for all files therefore only need zipz for one
k <- read_csv(here("/raw_data/DMEdatasets20200929172326/dme_anydisease_A_09282020.csv"))

# get unique zctas and write
zctas <- as.data.frame(sort(unique(k$zcta))) %>% rename(zcta = 'sort(unique(k$zcta))')
write_csv(zctas, here("/data/zcta.csv"))

# # load crosswalk zcta to zip file, since Kaiser data only has zctas slice down to
# # only two cols
# xwalk <- read_csv("zip_zcta_xwalk.csv")
# xwalk <- xwalk %>% select(c("zip_code", "zcta"))
# 
# # load Kaiser data - all zips are the same for all files
# k <- read_csv(here("DMEdatasets20200929172326/dme_anydisease_A_09282020.csv"))
# 
# # add zip col, auto joins by zcta
# k <- k %>% left_join(xwalk)
# 
# # get unique zips:
# zips <- na.omit(unique(k$zip_code))
# zips <- as.data.frame(zips)
# write_csv(zips, here("zips.csv"))
# 
# # get unique zetas:
# 
# Zetas
