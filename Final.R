# clearing environment
rm(list=ls(all=TRUE))
# loading libraries
library(tidycensus)
library(rio)
library(data.table)
library(tidyverse)
library(WDI)
library(labelled)
library(googlesheets4)
library(varhandle)
library(ggrepel)
library(geosphere)
library(rgeos)
library(viridis)
library(mapview)
library(rnaturalearth)
library(rnaturalearthdata)
library(devtools)
library(remotes)
library(raster)
library(sp)
library(sf)
library(Imap)

# connecting api key
api_key <- "c27810c8b6634b4df374ba6ef4045a7dc16103c6"
census_api_key(api_key, install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

# importing 2010 and 2015
v10 <- load_variables(year = 2010,
                      'acs5')
# gini variable B19083_001	
v15 <- load_variables(year = 2015,
                      'acs5')
# gini variable B19083_001	



# state level data for both years 
gini15 <- get_acs(geography = 'state',
                     variables = 'B19083_001', 
                     year = 2015)

gini10 <- get_acs(geography = 'state',
                  variables = 'B19083_001', 
                  year = 2010)

inequality_panel <- bind_rows(gini10, gini15)
setnames(inequality_panel, 'estimate', 'gini')
setnames(inequality_panel, 'NAME', 'state')
head(inequality_panel)


# 3. 
inequality_wide <- inequality_panel %>%
  pivot_wider(id_cols = c(''),
              names_from = , 
              values_from = )


# 4. 
inequality_long <-inequality_wide %>%
  pivot_longer(cols = , 
               names_to = ,
               names_prefix = ,
               values_to = , 
               values_drop_na = FALSE)


# 5.  
count(inequality_panel)
count(inequality_long)



# 6. 
inequality_collapsed <- inequality_long %>%
  group_by() %>%
  summarize(across(where(is.numeric), sum)) %>%
  select(-c())

#7. 



#8.
gdp_current = WDI(country = 'all', 
                     indicator = c('NY.GDP.MKTP.CD'), 
                     start = 2006, end = 2007, extra = FALSE, cache = NULL)


#9. 
deflator_data = WDI(country = 'all', indicator = c('NY.GDP.DEFL.ZS'), 
                    start = 2006,
                    end = 2016, 
                    extra = FALSE, cache = NULL)
setnames(deflator_data, 'NY.GDP.DEFL.ZS', 'deflator')
usd_deflator = subset(deflator_data, country == 'United States')
subset(usd_deflator, deflator==100)
rm(deflator_data)
usd_deflator$country <- NULL
usd_deflator$iso2c <- NULL
gdp_deflated = left_join(gdp_current, 
                          usd_deflator,
                          by = c('year'))
gdp_deflated$deflated_amount = gdp_deflated$NY.GDP.MKTP.CD/(gdp_deflated$deflator/100)
head(gdp_deflated)

# 10. 

