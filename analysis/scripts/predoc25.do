**************************************************
* Project: Predoc Practice
* Author: Abhishek Chand
* Date: 05 Jan 2024
**************************************************

* Setup
clear all
set more off

* change the directory to where the script is
cd /Users/kismet/economics/predoc_datatask25/analysis/scripts

* start log
capture log close
log using ../logs/predoc25exc_log.txt, text replace

* import raw data
use ../raw_data/data-task-2025-ozone.dta, clear


* change variables that 
gen date1 = date(date, "MDY")
format date1 %td
drop date
rename date1 date 

save ../data/ozone, replace

use ../raw_data/data-task-2025-pm, clear

destring county_code, replace

save ../data/pm, replace

use ../data/ozone

* 1. 
merge 1:1 siteid date county_code using ../data/pm

drop _merge

save ../data/dfmerged.dta, replace

use ../data/dfmerged

* 2. Produce a table with the mean, median, minimum, maximum, and standard deviation for ozone, PM 2.5, and AQI for the entire sample.

tabstat ozone_value pm25_value aqi, ///
    statistics(mean median min max sd) ///
    columns(statistics) format(%9.3f)
	
* 3. Produce a table with the same statistics for just ozone, but split the sample by the source variable(AQS vs. AirNow). In other words, your table should report the mean, min, etc., for the portion of the data that comes for AQS and those same numbers for the data coming from AirNow. Also include the number of observations for each group.

tabstat ozone_value, by(ozone_source) ///
    statistics(n mean median min max sd) ///
    columns(statistics) 


log close
