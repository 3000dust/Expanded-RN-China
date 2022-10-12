

### Created by Boyu Yao 10/07/2022
### These functions are for china time zone to get wind and solar profiles
### I have adjusted several items to match the time zone from UTC to UTC+8
### For using the functions in other time zones, more adjustments can be made accordingly
### Good luck on your use!

### Function for getting China wind profile


###prerequisite packages
requiredPackages = c('dplyr','ggplot2','scales','cowplot','here','curl','lubridate')

for(packages in requiredPackages){
  
  if(!require(packages, character.only = TRUE)) install.packages(packages)
  
  library(packages, character.only = TRUE)
  
}##Install and library utilized R packages if not in dictionary



## For wind generator, assume using hub height = 80m and turbine = Vestas+V90+2000
#### This turbine model is mostly use in china: https://www.vestas.cn/zh-cn/turbines/2MW/V90

ninja_get_china_wind = function(lat, lon, from, to, dataset='merra2', capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
{
  from = format_date(as.character(as.Date(from) - 1))
  to = format_date(to)
  
  url = ninja_build_wind_url(lat, lon, from, to, dataset, capacity, height, turbine, raw, 'csv')
  result_UTC = ninja_get_url(url)
  result_UTC = slice(result_UTC, 17:(n()-8))
  for (row in 1:nrow(result_UTC)){
    a = as.POSIXct(as.character(result_UTC[row,1]), tz = 'GMT')
    result_UTC[row,1] = format(a, tz="Asia/Shanghai",usetz=TRUE)
  }
  result_UTC
}

## Function for getting China solar profile
#### In this function we assume system loss (fraction) is 0.1 and ignore the tilt and azimuth influences

ninja_get_china_solar = function(lat, lon, from, to, dataset='merra2', capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
{
  from = format_date(as.character(as.Date(from) - 1))
  to = format_date(to)
  
  url = ninja_build_solar_url(lat, lon, from, to, dataset, capacity, system_loss, tracking, tilt, azim, raw, 'csv')
  result_UTC = ninja_get_url(url)
  result_UTC = slice(result_UTC, 17:(n()-8))
  for (row in 1:nrow(result_UTC)){
    a = as.POSIXct(as.character(result_UTC[row,1]), tz = 'GMT')
    result_UTC[row,1] = format(a, tz="Asia/Shanghai",usetz=TRUE)
  }
  result_UTC
}

### Match provinces according to its latitude and longitude
### Geodata from: https://www.distancelatlong.com/distancecalculator/country/china

province_list <- read.csv(file.path(here(), 'Expanded-RN/Provinces_LatLong.csv'))


## one function that can get the china's provincial level profile


## The following 2 functions (end with _quick) doesn't consider the future years after 2020

ninja_get_china_capacity_factor_quick = function(province, from, to, technology)
{
  if (technology == 'wind') {
    lat = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Latitude_w')])   
    lon = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Longitude_w')])
  } else if (technology == 'solar') {
    lat = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Latitude_s')])   
    lon = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Longitude_s')])
  }

  if (technology == 'wind'){
    result_UTC = ninja_get_china_wind(lat, lon, from, to, dataset='merra2',
                                      capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
  } else if (technology == 'solar'){
    result_UTC = ninja_get_china_solar(lat, lon, from, to, dataset='merra2',
                                       capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
  } else {
    print('Sorry, no such profile exists')
  }
  
  result_UTC 
  
}


ninja_plot_china_capacity_factor_quick = function(province, from, to, technology)
{
  if (technology == 'wind') {
    lat = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Latitude_w')])   
    lon = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Longitude_w')])
  } else if (technology == 'solar') {
    lat = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Latitude_s')])   
    lon = as.numeric(province_list[province_list$Provinces == province,][,colnames(province_list) == c('Longitude_s')])
  }
  
  if (technology == 'wind'){
    result_UTC = ninja_get_china_wind(lat, lon, from, to, dataset='merra2',
                                      capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
  } else if (technology == 'solar'){
    result_UTC = ninja_get_china_solar(lat, lon, from, to, dataset='merra2',
                                       capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
  } else {
    print('Sorry, no such profile exists')
  }
  
  ## Assign the time stamp to each selected hour
  result_UTC$hour <- 1:nrow(result_UTC)
  
  ggplot(data= result_UTC, aes(x= hour, y= electricity), fig(4,9)) +
    geom_line(size = 1, color="#e6005c") +
    #geom_point(size = 3, color="#39C5BB") +
    #scale_x_date(date_minor_breaks = "1 day") +
    scale_x_continuous(breaks= pretty_breaks(n = 10)) +
    scale_y_continuous(breaks= pretty_breaks(n = 5)) +##Define the scale for axises to make them clear
    labs(title = paste(case_when(technology == 'wind'~'Wind',
                                 technology == 'solar'~'Solar'),
                       "Energy Capacity Factors for", province, '(from', from, 'to', to, ')', sep = ' '),
         x="Hour", y="Capacity Factors")+
    theme(
      text                = element_text(family="sans", size = 14),
      title               = element_text(hjust=0),
      axis.title.x        = element_text(hjust=.5),
      axis.title.y        = element_text(hjust=.5),
      panel.grid.major.y  = element_line(color='gray', size = .3),
      panel.grid.minor.y  = element_blank(),
      panel.grid.major.x  = element_blank(),
      panel.grid.minor.x  = element_blank(),
      panel.border        = element_rect(colour = "gray",fill = NA),
      panel.background    = element_blank(),
      legend.position     = "right",
      strip.text = element_text(face = "bold"),
      strip.background = element_blank(),
      plot.title = element_text(hjust = 0.5),
      strip.placement = "outside"
    )##Theme for adjusting the related parameters that need to be displayed in the figure
  
}






### For year beyond 2020, use a technology innovation rate to simulate the future profile
## See the following 2 functions to generate profiles after year 2020 with an innovation rate
ninja_get_china_capacity_factor = function(province, from, to, technology, innovation_rate = 0.01)
{
  time_limit = ymd('2020-12-31')
  lat = as.numeric(province_list[province_list$Provinces == province,][,2])   
  lon = as.numeric(province_list[province_list$Provinces == province,][,3])
  if ((from <= time_limit) & (to <= time_limit)){
    if (technology == 'wind'){
      result_UTC = ninja_get_china_wind(lat, lon, from, to, dataset='merra2',
                                        capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
    } else if (technology == 'solar'){
      result_UTC = ninja_get_china_solar(lat, lon, from, to, dataset='merra2',
                                         capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
    } else {
      print('Sorry, no such profile exists')
    }
    result_UTC
    
  } else {
    ### if the time input to function is beyond 2020-12-31, use the corresponding date in 2020 to simulate the profile
    a = unlist(strsplit(from, split = '-'))
    b = unlist(strsplit(to, split = '-'))
    simulate_year = a[1]
    
    a[1] = 2020
    b[1] = 2020
    
    From = paste(a, collapse = '-')
    To = paste(b, collapse = '-')
    
    if (technology == 'wind'){
      result_UTC = ninja_get_china_wind(lat, lon, From, To, dataset='merra2',
                                        capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
    } else if (technology == 'solar'){
      result_UTC = ninja_get_china_solar(lat, lon, From, To, dataset='merra2',
                                         capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
    } else {
      print('Sorry, no such profile exists')
    }
    result_UTC[2] = result_UTC[2]*(1+innovation_rate)**(as.numeric(simulate_year) - 2020)
    ## Change the time shown in the data frame
    New_time = paste(result_UTC[,1],sep=" ", collapse=NULL)
    New_time = sub('2020', simulate_year, New_time)
    result_UTC[1] = New_time
    result_UTC
  }
}



## Also a plot function, using ggplot
ninja_plot_china_capacity_factor = function(province, from, to, technology, innovation_rate = 0.01)
{
  time_limit = ymd('2020-12-31')
  lat = as.numeric(province_list[province_list$Provinces == province,][,2])   
  lon = as.numeric(province_list[province_list$Provinces == province,][,3])
  if ((from <= time_limit) & (to <= time_limit)){
    if (technology == 'wind'){
      result_UTC = ninja_get_china_wind(lat, lon, from, to, dataset='merra2',
                                        capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
    } else if (technology == 'solar'){
      result_UTC = ninja_get_china_solar(lat, lon, from, to, dataset='merra2',
                                         capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
    } else {
      print('Sorry, no such profile exists')
    }
    #result_UTC
    
  } else {
    ### if the time input to function is beyond 2020-12-31, use the corresponding date in 2020 to simulate the profile
    a = unlist(strsplit(from, split = '-'))
    b = unlist(strsplit(to, split = '-'))
    simulate_year = a[1]
    
    a[1] = 2020
    b[1] = 2020
    
    From = paste(a, collapse = '-')
    To = paste(b, collapse = '-')
    
    if (technology == 'wind'){
      result_UTC = ninja_get_china_wind(lat, lon, From, To, dataset='merra2',
                                        capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')
    } else if (technology == 'solar'){
      result_UTC = ninja_get_china_solar(lat, lon, From, To, dataset='merra2',
                                         capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')
    } else {
      print('Sorry, no such profile exists')
    }
    result_UTC[2] = result_UTC[2]*(1+innovation_rate)**(as.numeric(simulate_year) - 2020)
    ## Change the time shown in the data frame
    New_time = paste(result_UTC[,1],sep=" ", collapse=NULL)
    New_time = sub('2020', simulate_year, New_time)
    result_UTC[1] = New_time
    #result_UTC
  }
  
  ## Assign the time stamp to each selected hour
  result_UTC$hour <- 1:nrow(result_UTC)
  
  ggplot(data= result_UTC, aes(x= hour, y= electricity), fig(4,9)) +
    geom_line(size = 1, color="#e6005c") +
    #geom_point(size = 3, color="#39C5BB") +
    #scale_x_date(date_minor_breaks = "1 day") +
    scale_x_continuous(breaks= pretty_breaks(n = 10)) +
    scale_y_continuous(breaks= pretty_breaks(n = 5)) +##Define the scale for axises to make them clear
    labs(title = paste(case_when(technology == 'wind'~'Wind',
                                 technology == 'solar'~'Solar'),
                       "Energy Capacity Factors for", province, '(from', from, 'to', to, ')', sep = ' '),
         x="Hour", y="Capacity Factors")+
    theme(
      text                = element_text(family="sans", size = 14),
      title               = element_text(hjust=0),
      axis.title.x        = element_text(hjust=.5),
      axis.title.y        = element_text(hjust=.5),
      panel.grid.major.y  = element_line(color='gray', size = .3),
      panel.grid.minor.y  = element_blank(),
      panel.grid.major.x  = element_blank(),
      panel.grid.minor.x  = element_blank(),
      panel.border        = element_rect(colour = "gray",fill = NA),
      panel.background    = element_blank(),
      legend.position     = "right",
      strip.text = element_text(face = "bold"),
      strip.background = element_blank(),
      plot.title = element_text(hjust = 0.5),
      strip.placement = "outside"
    )##Theme for adjusting the related parameters that need to be displayed in the figure
  
}



### This method is to get profiles from a list of generators
ninja_aggregate_china = function(generator_list, from, to, technology, innovation_rate = 0.02){
  
  Latitude_list = generator_list$Latitude
  Longitude_list = generator_list$Longitude
  
  time_limit = ymd('2020-12-31')
  
  date_gap = as.numeric(ymd(to) - ymd(from))
  result_UTC = data.frame(matrix(NA, nrow = 24 * (date_gap + 1), ncol = nrow(generator_list)))
  
  #lat = as.numeric(province_list[province_list$Provinces == province,][,2])   
  #lon = as.numeric(province_list[province_list$Provinces == province,][,3])
  if ((from <= time_limit) & (to <= time_limit)){
    if (technology == 'wind'){
      for (row in (1 : nrow(generator_list))){
        result_UTC[,1] = ninja_get_china_wind(lat = Latitude_list[row], lon = Longitude_list[row], from, to, dataset='merra2',
                                              capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')[,1]
        result_UTC[,(row + 1)] = ninja_get_china_wind(lat = Latitude_list[row], lon = Longitude_list[row], from, to, dataset='merra2',
                                                      capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')[,2]
      }
    } else if (technology == 'solar'){
      for (row in (1 : nrow(generator_list))){
        result_UTC[,1] = ninja_get_china_solar(lat = Latitude_list[row], lon = Longitude_list[row], from, to, dataset='merra2',
                                               capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')[,1]
        result_UTC[,(row + 1)] = ninja_get_china_solar(lat = Latitude_list[row], lon = Longitude_list[row], from, to, dataset='merra2',
                                                       capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')[,2]
      }
    } else {
      print('Sorry, no such profile exists')
    }
    
    colnames = paste('Generator', 1:nrow(generator_list), sep = '_')
    names(result_UTC[1]) = 'time'
    names(result_UTC[2:ncol(result_UTC)]) = colnames
    result_UTC
    
  } else {
    ### if the time input to function is beyond 2020-12-31, use the corresponding date in 2020 to simulate the profile
    a = unlist(strsplit(from, split = '-'))
    b = unlist(strsplit(to, split = '-'))
    simulate_year = a[1]
    
    a[1] = 2020
    b[1] = 2020
    
    From = paste(a, collapse = '-')
    To = paste(b, collapse = '-')
    if (technology == 'wind'){
      for (row in (1 : nrow(generator_list))){
        result_UTC[,1] = ninja_get_china_wind(lat = Latitude_list[row], lon = Longitude_list[row], From, To, dataset='merra2',
                                              capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')[,1]
        result_UTC[,(row + 1)] = ninja_get_china_wind(lat = Latitude_list[row], lon = Longitude_list[row], From, To, dataset='merra2',
                                                      capacity=1, height=80, turbine='Vestas+V90+2000', raw='false')[,2]
      }
      
    } else if (technology == 'solar'){
      for (row in (1 : nrow(generator_list))){
        result_UTC[,1] = ninja_get_china_solar(lat = Latitude_list[row], lon = Longitude_list[row], From, To, dataset='merra2',
                                               capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')[,1]
        result_UTC[,(row + 1)] = ninja_get_china_solar(lat = Latitude_list[row], lon = Longitude_list[row], From, To, dataset='merra2',
                                                       capacity=1, system_loss=0.1, tracking=0, tilt=35, azim=180, raw='false')[,2]
      }
    } else {
      print('Sorry, no such profile exists')
    }
    
    for (column in 2:ncol(result_UTC)){
      result_UTC[column] = result_UTC[column]*(1+innovation_rate)**(as.numeric(simulate_year) - 2020)
    }
    ## Change the time shown in the data frame
    New_time = paste(result_UTC[,1],sep=" ", collapse=NULL)
    New_time = sub('2020', simulate_year, New_time)
    result_UTC[1] = New_time
    
    colnames = paste('Generator', 1:nrow(generator_list), sep = '_')
    names(result_UTC[1]) = 'time'
    names(result_UTC[2:ncol(result_UTC)]) = colnames
    result_UTC
  }
  
}