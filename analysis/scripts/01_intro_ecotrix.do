clear all
set more off

use ../raw_data/wage1

tabulate female
bysort female: sum wage

eststo clear
eststo: quietly reg wage educ
eststo: quietly reg wage educ female
esttab, ar2 label
// using "../results/tables/predoc_8_ar3.tex", nonotes se ar2 tex replace label varwidth(40) obslast  star(* 0.10 ** 0.05 *** 0.01)

list wage lwage in 1/10
sum wage lwage educ exper expersq tenure married female

use ../raw_data/prminwge, clear

keep year avgmin avgcov prunemp prgnp

* describe and summarize data
describe
summarize
list in 1/10

* provide frequency table
tabulate year

******************************************************
* Pooled cross section
******************************************************
use ../raw_data/hprice3, clear

keep year y81 price lprice rooms baths

describe
summarize
list in 1/10

tabulate year

summarize price if year == 1978
sum price if year == 1981

bysort year: summarize price


******************************************************
* Panel or Longitudnal data
******************************************************
use ../raw_data/wagepan, clear

keep nr year exper hours educ lwage

describe 
summarize
list in 1/10

tabulate year





