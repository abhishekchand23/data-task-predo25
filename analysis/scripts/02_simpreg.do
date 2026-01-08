**************************************************
* Project: SLR
* Author: Abhishek Chand
* Date: 08 Jan 2024

* OUTLINE
* 1. SLR
* 2. prediciton after reg
* 3. goodness of fit measure (r-sq)
* 4. log form: log-log and log-linear form
**************************************************

clear all
set more off

* load the dataset
use ../raw_data/ceosal1, clear

keep salary roe
describe
summarize
list in 1/10

* exploring dataset
corr salary roe 
egen avg_sal = mean(salary)
label variable avg_sal "average salary"

* run simple reg
regress salary roe

* plit the obs with a fitted line
graph twoway (scatter salary roe ) (lfit salary roe)
graph export ../results/figures/simplereg1.pdf, as(pdf) replace

******************************************************
* Using wage data
******************************************************
use ../raw_data/wage1, clear
keep wage educ
describe
summarize
list in 1/10

reg wage educ

******************************************************
* 2. Prediction After Regression
******************************************************
* load the dataset
use ../raw_data/ceosal1, clear

reg salary roe

* predicted value for the dependent variable (salaryhat)
predict salaryhat, xb
summarize salary salaryhat
graph twoway (scatter salary roe) (scatter salaryhat roe)

* residuals
predict uhat, residuals
summarize salary uhat
graph twoway (scatter salary roe) (scatter uhat roe)

list roe salary salaryhat uhat in 1/10

* graph actual and  predicted values and residuals
graph twoway (scatter salary roe, msymbol(smcircle) mcolor(red)) ///
				(scatter salaryhat roe, msymbol(smcircle) mcolor(black)) ///
				(scatter uhat roe, msymbol(smcircle_hollow) mcolor(green)) ///
				(lfit salary roe), ///
				legend(order(1 "True Value" 2 "Fitted Value" 3 "Residuals" 4 "Fiited Line"))				

******************************************************
* 3. Goodness-of-fit
******************************************************

use ../raw_data/ceosal1, clear
reg salary roe

* use "ereturn" command to show results that stata saves automatically
ereturn list
* e(.) has to be used right after the regression
display e(r2) // give goodness of fit
display e(N) // gives number of observation

******************************************************
* 4. Log form - log-log and log-linear form 
******************************************************

use ../raw_data/ceosal1, clear
list salary lsalary sales lsales in 1/10

* linear form 
reg salary sales
graph twoway (scatter salary sales) (lfit salary sales)

* log-log form
reg lsalary lsales
graph twoway (scatter lsalary lsales) (lfit lsalary lsales)

* linear-log form
reg salary lsales
graph twoway (scatter salary lsales) (lfit salary lsales)

* wage example
use ../raw_data/wage1, clear
reg wage educ
graph twoway (scatter wage educ) (lfit wage educ)

* wage log-linear form
reg lwage educ
graph twoway (scatter lwage educ) (lfit lwage educ)
