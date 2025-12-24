clear all
set more off

cd "/Users/kismet/economics/predoc_datatask25/analysis/scripts"

// import delimited "../raw_data/ercot_resource_output.csv", clear
// save "../int_data/ercot_res_out.dta", replace

use "../int_data/ercot_res_out"
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
contract qse resource_name
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

// 4. Now turn to resource type.csv
// (a) How many unique, non-missing values does Resource Type take? Can you find definitions for them? (No need to define all of them, just attempt a few)
import delimited "../raw_data/ercot_resource_types.csv", clear varnames(1)
codebook resource_type // levelsof also can be used but you will have to count yourself

* there are 15 unique values resource type takes. As I 
* CLLIG Controllable Load Resource (CLR): Large industrial/commercial users who agree to lower their demand when the grid needs power.


// (b) Are there any empty strings in the resource type column? Which resource names are missing their type? Can you guess what the missing values should be? Fill in the missing values with your guesses (you will carry your filled in guesses for the remainder of the data task).

*Yes there areresource_name
browse if missing(resource_type)

/*the below resource names are missing their type
GALLOWAY_SOLAR1
ROSELAND_SOLAR3
SSPURTWO_WIND_1
SWEETWN2_WND24
*/

browse if strpos(resource_name,"GALLOWAY")
replace resource_type = "PVGR" if resource_name == "GALLOWAY_SOLAR1"
replace resource_type = "PVGR" if resource_name == "ROSELAND_SOLAR3"
browse if strpos(resource_name,"WIND")
replace resource_type = "WIND" if resource_name == "SSPURTWO_WIND_1"
replace resource_type = "WIND" if resource_name == "SWEETWN2_WND24"




