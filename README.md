# Expanded-RN-China

2022-10-10, 0.03 ver.

This small tool is an extension to the Renewables Ninja api for quickly generating China's provincial wind or solar profiles.

`ninja_automator.r` is the scripts created by [Renewables Ninja](https://github.com/renewables-ninja/ninja_automator), which gives some basic functions for requesting the api from Renewables Ninja. In their repo, there are also simple samples, please take an explore to make sure you understand how RN's api works.

`Renewables_Ninja_China.R` are the functions created by me to quickly generate the renewable energy profile in China's provincial-level. There are mainly 3 functions that I think help best:

1. `ninja_get_china_capacity_factor(province = 'Province', from ='from date', to ='to date', technology = 'wind or solar', innovation_rate= 'technology innovation rate')` is the function to get the data frame of provincial level capacity factors through selected from-to time. 
    
      For wind energy, the default hub height using in the function is `height = 80`, and the default turbine model is `Vestas+V90+2000`, according to the most common model from [Vestas](https://www.vestas.cn/zh-cn/turbines/2MW/V90) in China.
      
      For solar energy, the default system loss is `system_loss = 0.1` and ignore the tilt and azimuth influences, `tracking = 0`. One can adjust the tilt and azimuth by setting `tracking = 1, tilt = 'tilt_angle', azim = 'azim_angle'`.


2. `ninja_plot_china_capacity_factor(province = 'Province', from ='from date', to ='to date', technology = 'wind or solar', innovation_rate= 'technology innovation rate')` is the function to plot the capacity factors time series in selected province and from-to time.

3. `ninja_aggregate_china(generator_list = 'generators', from = 'from date', to = 'to date, technology = 'wind or solar', innovation_rate= 'technology innovation rate)')` is the function for getting a list of generators' capacity factors.

    Note that due to the request limit of the API, the 3rd function is currently only capable of small-scale data scraping, and I still recommend using the first 2 functions for quick profile simulations.

> Some other notes:

   In Renewables Ninja, data is available before 2020-12-31. To simulate profile after 2020-12-31, I used a technology innovation rate to reflect the annual technology innovation. The default rate in the function is 0.02 and can be adjusted in the function by setting `innovation_rate = 'rate'`. The profile will be generated from multiplied by `(1+rate)^(year gap)` according to its corresponding profile in 2020 date.

   The default dataset used for simulating is [MERRA-2](https://gmao.gsfc.nasa.gov/reanalysis/MERRA-2/).

   The geographic data of the Chinese provinces comes from [Distancelatlong](https://www.distancelatlong.com/distancecalculator/country/china).


Want to explore more detailed renewable energy profiles and other data? Please explore [Geodata](https://github.com/GeodataTools/geodata).
