clear all
set more off


******************************************************
* Multicollinearity using VIF
******************************************************

* multicollinearity is when regressors are highly correlated with each other

* test score example
use ../raw_data/elemapi2, clear

keep api00 avg_ed grad_sch col_grad
describe 
summarize

* multicollinearity parent average education is collinear with whether they completed school or college

* correlation table
correlate avg_ed grad_sch col_grad

* run regression, find VIF. If VIF >10 then drop the variable
reg api00 avg_ed grad_sch col_grad
vif

* run regression without variable that has high vif
reg api00 grad_sch col_grad
vif

* as you add more regressors the model beomes more complex, hence the variance mostly increases
* run regression without the other variable
reg api00 grad_sch
vif // vif is 1 for simple regression.
