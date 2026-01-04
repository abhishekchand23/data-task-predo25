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

*4. .....
// t test between the mean, same variance

*5. Create a county-day dataset to proceed with the analysis. All subsequent questions will use this new dataset. The data set should contain the three pollution variables, mortality, the county name and code, the date, and the CBSA name and code (one county is always assigned the same CBSA). How did you reconcile different pollution readings for different monitors within the county?
collapse (mean) aqi ozone_value pm25_value mortality, by(date county_code county_name cbsaname cbsacode)


*6 How many counties are missing days?
sort county_code date
by county_code: gen gap = date - date[_n-1]
levelsof county_name if gap > 1 & !missing(gap), local(counties_with_gap)

unique county_name if gap > 1 & !missing(gap)

/*
foreach county of local counties_with_gap{
	display "----`county'----"
}
*/

log close
