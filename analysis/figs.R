############ Creates figures for Kaiser Paper ##############


library(tidyverse)
library(here)

d1 <- read_csv(here("/data_processing/raw_data/DMEdatasets20200929172326/dme_anydisease_A_09282020.csv"))

d1 <- d1 %>%
  filter((is.na(zcta) == FALSE) & (is.na(getty) == FALSE)) %>% # attempt to filter out rows outside the study area
  mutate(date = as.Date(date, format='%d%b%Y'), admitdate = as.Date(date, format='%d%b%Y')) #standardize dates into date class

d1 %>% 
  filter(county == "Los Angeles County" | county == "Ventura County") %>%
  group_by(county, date) %>%
  summarise_at(
    .funs = c(mean),
    .vars = c("wf_pm25", "getty", "woolsey"),
    na.rm = TRUE
  ) %>%
  mutate(fire_on = getty + woolsey) %>%
  ggplot() +
  geom_line(aes(x = date, y = wf_pm25, colour = fire_on)) +
  facet_wrap(facets = "county") +
  theme(legend.position = "none") 
  
d1 %>% 
  filter(county == "Los Angeles County" | county == "Ventura County") %>%
  group_by(county, date) %>%
  summarise_at(
    .funs = c(mean),
    .vars = c("non_wf_pm", "getty", "woolsey"),
    na.rm = TRUE
  ) %>%
  mutate(fire_on = getty + woolsey) %>%
  ggplot() +
  geom_line(aes(x = date, y = non_wf_pm, colour = fire_on)) +
  facet_wrap(facets = "county") +
  theme(legend.position = "none") 

d1 %>% 
  mutate(all_pm = wf_pm25 + non_wf_pm) %>% 
  filter(county == "Los Angeles County" | county == "Ventura County") %>%
  group_by(county, date) %>%
  summarise_at(
    .funs = c(mean),
    .vars = c("all_pm", "getty", "woolsey"),
    na.rm = TRUE
  ) %>%
  mutate(fire_on = getty + woolsey) %>%
  ggplot() +
  geom_hline(yintercept = 35, color = "red", linetype = "dashed", size = 0.3) +
  geom_line(aes(x = date, y = all_pm, colour = fire_on)) +
  facet_wrap(facets = "county") +
  labs(title = "Ground level? PM 2.5 concentrations in micrograms per cubic meter in the Kaiser study area") +
  xlab("Year") + 
  ylab("PM 2.5 Concentration") + theme_light()
  
  

d1 %>%
  mutate(all_pm = wf_pm25 + non_wf_pm) %>% 
  filter(county == "Los Angeles County" | county == "Ventura County") %>%
  group_by(date) %>%
  summarise_at(
    .funs = c(mean),
    .vars = c("all_pm", "getty", "woolsey"),
    na.rm = TRUE
  ) %>%
  mutate(fire_on = getty + woolsey) %>%
  ggplot() +
  geom_line(aes(x = date, y = all_pm, colour = fire_on)) +
  theme(legend.position = "none")

d1 %>% 
  filter(county == "Los Angeles County" | county == "Ventura County") %>%
  group_by(date) %>%
  summarise_at(
    .funs = c(mean),
    .vars = c("wf_pm25", "getty", "woolsey"),
    na.rm = TRUE
  ) %>%
  mutate(fire_on = getty + woolsey) %>%
  ggplot() +
  geom_line(aes(x = date, y = wf_pm25, colour = fire_on)) +
  theme(legend.position = "none")


