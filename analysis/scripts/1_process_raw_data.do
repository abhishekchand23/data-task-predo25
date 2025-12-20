clear all
set more off

cd "/Users/kismet/economics/predoc_datatask25/analysis/scripts"

// import delimited "../raw_data/ercot_resource_output.csv", clear
// save "../int_data/ercot_res_out.dta", replace

use "../int_data/ercot_res_out"
describe
label data "electric reliability council of texas (ercot)"

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
