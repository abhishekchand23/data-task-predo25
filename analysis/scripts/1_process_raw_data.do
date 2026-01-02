clear all
set more off

cd "/Users/kismet/economics/predoc_datatask25/analysis/scripts"
log using "../logs/log.txt", replace text

import delimited "../raw_data/ercot_resource_output.csv", clear
save "../int_data/ercot_res_out.dta", replace

use "../int_data/ercot_res_out", clear
describe
label data "data for electric reliability council of texas (ercot)"

* 1. How many unique values does the variable Resource Name take in the data? the variable
* QSE?
codebook resource_name

// Answer: 1,121 unique values for Resource Name

* 2. What is a QSE? Do a quick online search for this ERCOT acronym. Provide a brief (1-3
* sentences) definition for QSE as used in ERCOT's market for electricity.

// Answer: Qualified scheduling entities (QSEs) submit bids and offers on behalf 
// of resource entities (REs) or load serving entities (LSEs) such as 
// retail electric providers (REPs). QSEs are able to submit offers to sell and/or 
// bids to buy energy in the Day-Ahead Market and the Real-Time Market. The QSE is 
// also responsible for submitting a Current Operating Plan for all resources it 
// represents and offering or procuring Ancillary Services as needed to serve their 
// represented load. QSEs are responsible for settling financially with ERCOT

label variable qse "qualified scheduling entities"


// 3. Find the set of unique QSE/Resource Name pairs. Answer the following questions.

// (a) Is it ever the case that a single QSE is paired to multiple resource names? What might this indicate about the relationship between QSEs and Resource Names? What are the 10 largest QSEs in terms of the number of unique Resource Names they are paired to in the data?

gen double timestamp = clock(sced_time_stamp, "MDYhm") 
format timestamp %tc

preserve
contract qse resource_name // this changes the data instead use unique qse resource_name
bysort qse: gen n_distinct = _N
bysort qse (n_distinct): keep if _n == 1
gsort -n_distinct
list qse n_distinct in 1/11

list if n_distinct <= 1
summarize n_distinct
tab n_distinct
// histogram n_distinct
restore

// The QSE's have more than one client for which they place the bids and makes offers to.

// (b) Is it ever the case that a single Resource Name is paired to more than one QSE in the data? For how many Resource Names is this true for? Why might a single Resource
// Name pair with multiple QSEs in the data? Hint: Look at how pairs change over time
* there are 6 resources that have more than 1 qse
preserve 
contract resource_name qse
bysort resource_name: gen n_distinct = _N
order resource_name
list if n_distinct>1
restore 

// or use below but you can't see here which qses
// quietly unique qse, by(resource_name) gen(num_qse)
// tab num_qse
// browse if num_qse > 1 & !missing(num_qse)

save "../int_data/ercot_res_out.dta", replace
// 4. Now turn to resource type.csv
// (a) How many unique, non-missing values does Resource Type take? Can you find definitions for them? (No need to define all of them, just attempt a few)
import delimited "../raw_data/ercot_resource_types.csv", clear varnames(1)
codebook resource_type // levelsof also can be used but you will have to count yourself

* there are 15 unique values resource type takes. As I 
* CLLIG Controllable Load Resource (CLR): Large industrial/commercial users who agree to lower their demand when the grid needs power.


// (b) Are there any empty strings in the resource type column? Which resource names are missing their type? Can you guess what the missing values should be? Fill in the missing values with your guesses (you will carry your filled in guesses for the remainder of the data task).

*Yes there areresource_name
// browse if missing(resource_type)

/*the below resource names are missing their type
GALLOWAY_SOLAR1
ROSELAND_SOLAR3
SSPURTWO_WIND_1
SWEETWN2_WND24
*/

// browse if strpos(resource_name,"GALLOWAY"): use or operator after if instead of creating two lines of code
replace resource_type = "PVGR" if resource_name == "GALLOWAY_SOLAR1"
replace resource_type = "PVGR" if resource_name == "ROSELAND_SOLAR3"
// browse if strpos(resource_name,"WIND")
replace resource_type = "WIND" if resource_name == "SSPURTWO_WIND_1"
replace resource_type = "WIND" if resource_name == "SWEETWN2_WND24"

// 5. Based on the following definitions, use the resource type column to make a "Fuel Type" column. After doing so, merge Fuel Type and Resource Type onto ercot resource output.csv using Resource Name (you should end up with 6 unique values of Fuel Type).
// • DSL - Other
// • SCGT90 - Natural Gas
// • WIND - Wind
// • PWRSTR - Other
// • HYDRO - Other
// • CCGT90 - Natural Gas
// • PVGR - Solar
// • SCLE90 - Natural Gas
// • GSREH - Natural Gas
// • CCLE90 - Natural Gas
// • CLLIG - Coal
// • GSSUP - Natural Gas
// • NUC - Nuclear
// • GSNONR - Natural Gas
// • RENEW - Other

gen fuel_type = ""

replace fuel_type = "Other" ///
	                         if inlist(resource_type, "DSL", "PWRSTR", "HYDRO", "RENEW")
replace fuel_type = "Natural Gas" ///
	                         if inlist(resource_type, "SCGT90", "CCGT90", "SCLE90","GSREH", "GSSUP", "GSNONR", "CCLE90")
replace fuel_type = "Wind".   if resource_type == "WIND"
replace fuel_type = "Solar"   if resource_type == "PVGR"
replace fuel_type = "Coal"    if resource_type == "CLLIG"
replace fuel_type = "Nuclear" if resource_type == "NUC"
save "../int_data/ercot_res_type", replace

use ../int_data/ercot_res_out, clear
merge m:1 resource_name using ../int_data/ercot_res_type 

// 6. Plot the following:
// (a) output summed by day
// (b) output summed by hour-of-day (hours 0-23)
// (c) output summed by hour-of-day and by Fuel Type (the variable you defined in 5.)
// Discuss the patterns you see in each plot.

rename telemetered_net_output output
label variable output "Telemetered net output"

gen date = dofc(timestamp)
format date %td

preserve
collapse (sum) output, by(date)
tset date
quietly tsline output
graph export ../results/figures/daily_output.png, replace
restore

gen day = dow(date)
label define dowlbl 0 "Sunday" 1 "Monday" 2 "Tuesday" 3 "Wednesday" 4 "Thursday" 5 "Friday" 6 "Saturday"
label values day dowlbl
 
quietly graph bar (sum) output, over(day)
graph export ../results/figures/day_out.png, replace


gen hour = hh(timestamp)

quietly graph bar (sum) output, over(hour) //this is a bad graph but line also does not show the 0 value which might show that there is huge difference in the output across hours as the reference value of 0 is not present in the line graph
preserve
collapse (sum) output, by(hour)
twoway line output hour
graph export ../results/figures/hourly_output.png, replace
restore



quietly graph bar (sum) output, over(hour) over(fuel_type) // this is worst dnu

preserve 
collapse (sum) output, by(hour fuel_type)
encode fuel_type, gen(fuel_type_num)
drop fuel_type
reshape wide output, i(hour) j(fuel_type_num)
label var output1 "Coal"
label var output2 "Natural Gas"
label var output3 "Nuclear"
label var output4 "Other"
label var output5 "Solar"
label var output6 "Wind"
twoway line output1 output2 output3 output4 output5 output6 hour //but there are ways to make it look more beautiful

twoway (connected output1 hour, sort msymbol(O) msize(small)) (connected output2 hour, sort msymbol(O) msize(small)) (connected output3 hour, sort msymbol(O) msize(small)) (connected output4 hour, sort msymbol(O) msize(small)) (connected output5 hour, sort msymbol(O) msize(small)) (connected output6 hour, sort msymbol(O) msize(small)), xtitle(Hour) title(Electricity Output by Fuel Type and Time of Day) ytitle(Electricity Output)

graph export ../results/figures/hourly_output_by_type.png, replace
restore



// the day output gradually increases from sunday to wednesday and then gradually decreases from Thursday to Saturday

//the hourly output starts increasing at 4 am and then peaks at 8 am then gradually falls till 3pm and starts to increase and then peaks at 7pm and starts falling gradually till 3am.

// The hourly patterns we observe is due to fluctuations in the output of Natural gas, coal, wind, solar and others. Coal, Natural gas and other mimick the hourly output pattern.


// 7. Looking at the plot from 6.(a), does this data look stationary? Using the data summed at the daily level, test for a unit root and interpret the result. Now calculate its first difference and plot it. Does it look stationary?

preserve
collapse (sum) output, by(date)
tsset date
quietly tsline output
*No looking at the plot the series does not look stationary.
dfuller output //we fail to reject that series is non-stationary
pperron output // er fail to reject random walk
dfgls output // not sure how to interpret the results 

generate fdoutput = D.output
tsline fdoutput
graph export ../results/figures/fdoutput.png, replace
dfuller fdoutput
*no this also does not look stationary
// wrong the dfuller test rejects that the series is a random walk
restore

// 8. Now sum output at the hourly level (day-hour, not hour-of-day). Fit an AR(3) model on electricity output. Do you believe an AR model is a good fit? Why or why not?
preserve
collapse (sum) output, by(date hour)
gen double dayhour = cofd(date) +  (hour * 60 * 60 * 1000) //clock of the date and convert the hour to millisecond
format dayhour %tc
tsset dayhour, delta(1 hour) // default delta is 1 millisecond, need hour here
quietly tsline output, xtitle(Day - Hour) ytitle(Output) title(Day Hour Output) xlabel(,angle(45) labsize(small)) tmtick(##24)
graph export ../results/figures/dhoutput.png, replace
pac output
graph export ../results/figures/pac_output_daily_hour.pdf, as(pdf) name(Graph) replace

eststo clear
eststo: regress output L(1/3).output, vce(robust)
esttab using "../results/tables/predoc_8_ar3.tex", nonotes se ar2 tex replace label varwidth(40) obslast  star(* 0.10 ** 0.05 *** 0.01)

eststo clear
eststo: arima output, arima(3,0,0) sarima(1,0,0,24) vce(robust)
esttab using "../results/tables/predoc_8_sarima.tex", nonotes se ar2 tex replace label varwidth(40) obslast  star(* 0.10 ** 0.05 *** 0.01)

restore

// 9. Run the following dummy variable regressions and interpret the coefficients:
// (a) output regressed on a set of indicator variables for each Fuel Type in the data
encode fuel_type, gen(fuel)
drop fuel_type
rename fuel fuel_type
reg output i.fuel_type // base can be any
* Nuclear has the most ouput, then coal, and the least is others // coefficients give the mean of each type
// (b) output regressed on a set of indicator variables for each day of the week (Sun, Mon,
// Tues, etc.)
reg output i.day //max on thursday and least on sunday

// (c) output regressed on a set of indicator variables for each week in the data
// What factors might explain the values of the coefficients you found?
gen week = week(date)
reg output i.week


foreach var_to_ind in fuel_type day week {
	eststo clear
	eststo: regress output I.`var_to_ind', r
	esttab using "../results/tables/predoc_9_`var_to_ind'.tex", nonotes se ar2 tex replace label varwidth(40) obslast nocon star(* 0.10 ** 0.05 *** 0.01)
}

log close










