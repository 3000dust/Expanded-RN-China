# Expanded-RN-China

2022-10-10, 0.03 ver.

This small tool is an extension to the Renewables Ninja api for quickly generating China's provincial wind or solar profiles.

`ninja_automator.r` is the scripts created by [Renewables Ninja](https://github.com/renewables-ninja/ninja_automator), which gives some basic functions for requesting the api from Renewables Ninja. In their repo, there are also simple samples, please take an explore to make sure you understand how RN's api works.

`Renewables_Ninja_China.R` are the functions created by me to quickly generate the renewable energy profile in China's provincial-level. There are mainly 3 functions that I think help best:

1. `ninja_get_china_capacity_factor(province = 'Province', from ='from date', to ='to date', technology = 'wind or solar', innovation_rate= 'technology innovation rate')`
2. `ninja_plot_china_capacity_factor(province = 'Province', from ='from date', to ='to date', technology = 'wind or solar', innovation_rate= 'technology innovation rate')`
3. `ninja_aggregate_china(fgenerator_list = 'generators', from = 'from date', to = 'to date, technology = 'wind or solar', innovation_rate= 'technology innovation rate)')`

Note that due to the request limit of the API, the 3rd function is currently only capable of small-scale data scraping, and I still recommend using the first 2 functions for quick profile simulations.

Explore more detailed renewable energy profiles and other data? Please explore [Geodata](https://github.com/GeodataTools/geodata).
