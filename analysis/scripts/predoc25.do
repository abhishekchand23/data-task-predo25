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

use ../data/dfmerged, clear

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
quietly levelsof county_name if gap > 1 & !missing(gap), local(counties_with_gap)

unique county_name if gap > 1 & !missing(gap)


foreach county of local counties_with_gap{
	display "----`county'----"
}

******************************************************
* Section 2
******************************************************

* 1. Produce a plot showing the distributions of ozone and PM 2.5. The distributions should be separate lines, sets of dots, bars, etc, but on the same set of axis. Choose an appropriate type of graph to complete this task and make your graph easy to digest. Hint: Pay attention to the scale of the variables. Can we preserve the distribution while standardizing the scales?
summarize ozone_value
gen ozone_z = (ozone_value - r(mean)) / r(sd)

summarize pm25_value 
gen pm25_z = (pm25_value - r(mean)) / r(sd)

graph twoway (kdensity ozone_z) (kdensity pm25_z), title(Distribution of Ozone and PM2.5) legend(order(1 "Ozone" 2 "PM2.5")) xtitle(Value) ytitle(Density)
graph export ../results/figures/sec2_1_kernel.pdf, as(pdf) replace 

// Yes we can preserve the distribution while standarzing the scales

* 2. Produce a time series plot of ozone for Los Angeles county (Code: 037) in the month of February. Do you suspect autocorrelation? 1 How might you test for it (you do not need to test it)?

xtset county_code date
tsline ozone_value if county_code == 37 & month(date) == 2
graph export ../results/figures/sec2_2_ozone_la_feb.pdf, as(pdf) replace

******************************************************
* Section 3: POLLUTION AND MORTALITY
******************************************************

* 1. Estimate the association between pollution and mortality by running the following regression: Mortalityit = β0 + β1AQIit + αi + αt (1) where αi and αt are fixed effects for county i and time t. Report and interpret β1. Why do we include fixed effects?

xtreg mortality aqi i.date, fe
// a unit increase in the aqi on average increases by 0.5277
// county fixed effects absorb the heterogenity between the countries
// time fixed effects control for events that affected all the counties on a specific day
// As we are interested in understanding how aqi affects the mortality, we need to include fixed effects to absord the heterogenity across time and county.

* 2. I am concerned that yesterday's pollution affects mortality too. Include one lag of AQI and rerun the regression. Report and interpret the coefficients on AQI and yesterday's AQI.

xtreg mortality aqi L.aqi i.date, fe
//  The lag of aqi affects mortality more than aqi on the current day. 0.06 unit difference. The coefficients are statistically significant

* 3. I am curious if the relationship differs by whether a county is in a CBSA. Rerun the original regression from Section 3, Question 1, but add an interaction between an indicator for whether a county is in a CBSA and AQI (i..e, AQIit × 1i∈CBSA). Interpret the coefficients.

gen cbsaind = 1 if !missing(cbsacode)
replace cbsaind = 0 if missing(cbsaind)
gen aqi_cbsa_ind = aqi*cbsaind
xtreg mortality aqi aqi_cbsa_ind i.date, fe

// aqi impact is lower on average on mortality if county is in a CBSA

* 4. I did not ask you to include a separate variable for whether a county is in a CBSA but just the interaction. If you were to include it, it would be omitted as collinear. What is it collinear with?

// chatgpt it is collinear with county fixed effects 



log close
