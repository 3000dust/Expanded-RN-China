### 10/10/2022 Boyu Yao   
### 0.03 ver.

#####
## ##  Using Renewables Ninja API to quickly generate less accurate renewable profile
#####
 
#### Refer its automator on github: https://github.com/renewables-ninja/ninja_automator

#### More adjustments have been made to better adapt for China provinces


# Some notes from Boyu Yao:
# 1. Before using this scripts, please firstly register a account on Renewables Ninja and get the token from your account profile
# 2. Created your working directory in a same folder, or follow the directory path below (or in the repo)
# 3. This method is to quickly generate less-accurate renewable energy profile for wind and solar
# 4. I will provide 2 methods for generate one or multiple profiles
# 5. Depends on the request limit of api, I strongly recommend only get 1 month's profile once, to avoid the http 400/429 error
# 6. All date input to the function should be in style: 'YYYY-MM-DD', other type will not be accepted
# 7. Now the functions cannot breakthrough the request limit of the RN api, 
#    please let me know if there are any methods that can grab several profiles at once.
# 8. The historical data of RN is as of 2020-12-31. For the future date, I use a technology innovation rate to reflect.
#    Say, for the date after 2020, use the data of the day in 2020 multiplied by (1+ rate) to reflect, the default in the function is 0.02.


### Good luck on your playing with RN


#####
## ##  MODEL SETUP
#####

# pre-requisite packages

library(here)

here()
Dir_path <- file.path(here())
## Source the ninja automator and my built function for China
source(file.path(Dir_path, 'Expanded-RN/R/ninja_automator.r'))
source(file.path(Dir_path, 'Expanded-RN/R/Renewables_Ninja_China.r'))

# insert your API authorization token here
token = '2a623b67d5ba8df8b78a9b97308c24e16a4c77e6'

# establish your authorization
h = new_handle()
handle_setheaders(h, 'Authorization'=paste('Token ', token))


#####
## ##  Method 1. Using one function expanded RN API to quickly generate China's provincial level profile
#####

## Note that RN can only generate the profile before 2021-01-01, please use the time 
# Function input: province, from, to, technology
ninja_get_china_capacity_factor('Jilin', '2021-10-01', '2021-11-01', 'wind', innovation_rate = 0)
# ninja_get_china_capacity_factor(province = 'Tianjin', from ='2020-01-01', to ='2020-02-01', technology = 'wind')
ninja_plot_china_capacity_factor('Jilin', '2021-10-01', '2021-11-01', 'wind', innovation_rate = 0)
# ninja_plot_china_capacity_factor(province = 'Tianjin', from ='2020-01-01', to ='2020-02-01', technology = 'solar')

z = ninja_get_china_capacity_factor('Liaoning', '2021-10-01', '2021-11-01', 'solar', innovation_rate = 0)
mean(z$electricity)###Check the average capacity factors
#####
## ##  Method 2. Using a list of information to generate profiles
#####


## Let's start with a sample csv file selected from GEM wind data
farms = read.csv(file.path(Dir_path, 'Expanded-RN/R/Sample_Data/GEM_Liaoning_sample_wind.csv'))

ninja_aggregate_china(farms, '2022-01-01', '2022-01-01', 'wind')
## This function will give a dataframe with all profiles in the selected from-to time
## Due to the api request limit, this function does not work so well on grabbing profiles from a list
## I would suggest use this small tool only quickly generate provincial profiles (method 1)


