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
restore

// (b) Is it ever the case that a single Resource Name is paired to more than one QSE in the
// data? For how many Resource Names is this true for? Why might a single Resource
// Name pair with multiple QSEs in the data? Hint: Look at how pairs change over time
