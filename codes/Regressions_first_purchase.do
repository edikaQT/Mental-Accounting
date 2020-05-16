
 
 
 
/////////////////////////////////////////////////////////////////////////////////////////
//
//                                 REGRESSIONS
//                                 ===========
/////////////////////////////////////////////////////////////////////////////////////////

//_____________________________________________
//
//  SINGLE CATEGORY - NEW ACCOUNTS - FIRST TRANSACTION
//  Table 4. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts
//  Table B-1. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
//  Table C-1. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts
//  Table C-2. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
//_____________________________________________
//


//_____________________________________________
//
//  DEFINING GLOBAL VARIABLES
//_____________________________________________
//

global dep_variable repay_full
local data_name = c(filename)
local extension .dta
local data_name= substr("`data_name'",1,length("`data_name'")-4)
di "`data_name'"
cd "$location_cleaned_data"

// 
// 
 
// COLUMN 1
// --------
 
reg $dep_variable  ///
ib2.nature_d_2cat ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 $restriction_controls
est store table1c1

tab subset1 if  subset1==1 & order_transac_new==1 & nature_d==1 $restriction_controls
local no_durables= r(N) 
display `no_durables'

outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, replace ctitle(OLS)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext(Month FEs, NO)  label

// COLUMN 2
// --------

reg $dep_variable  ///
ib2.nature_d_2cat ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 $restriction_controls
est store table1c2

outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext(Month FEs, NO)  label

// COLUMN 3
// --------

reg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 $restriction_controls
est store table1c3


outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext( Month FEs, YES)  label


margins i.nature_d_2cat , ///
atmeans noestimcheck post

//atmeans noestimcheck specifies that margins not check for estimability.  Nonestimability is usually caused
//by empty cells. If atmeans noestimcheck is specified, estimates are computed and reported in the usual way.


est store prob_col3


// COLUMN 4
// --------

reg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 & quartile_1v2==1 $restriction_controls

tab subset1 if  subset1==1 & order_transac_new==1 & nature_d==1 & quartile_1v2==1 $restriction_controls
local no_durables= r(N) 



est store table1c4
outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 1st quartile)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext( Month FEs, YES)  label


// COLUMN 5
// --------


reg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 &  quartile_2v2==1  $restriction_controls
est store table1c5

tab subset1 if  subset1==1 & order_transac_new==1 & nature_d==1 & quartile_2v2==1 $restriction_controls
local no_durables =r(N) 


outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 2nd quartile)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext( Month FEs, YES)  label


// COLUMN 6
// --------

reg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 &  quartile_3v2==1 $restriction_controls
est store table1c6

tab subset1 if  subset1==1 & order_transac_new==1 & nature_d==1 & quartile_3v2==1 $restriction_controls
local no_durables= r(N) 


outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 3rd quartile)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext( Month FEs, YES)  label


// COLUMN 7
// --------

reg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 &  quartile_4v2==1 $restriction_controls
est store table1c7

tab subset1 if  subset1==1 & order_transac_new==1 & nature_d==1 & quartile_4v2==1 $restriction_controls
local no_durables= r(N) 

outreg2 using Table_New_Accounts_Single_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 4th quartile)  drop(i.cycleperiod_month) ///
addstat ("Observations - Non durable purchases",`no_durables') ///
addtext(Month FEs, YES)  label




//_____________________________________________
//
//   Figure 2. Fitted probabilities of full repayment based on linear probability models (see Table 4, 
//   columns 3 to 7), evaluated at the mean of the other covariates. Lines span 95% confidence 
//   intervals.  
//_____________________________________________
//

// Quartile cutoffs in the figure correspond to the dataset: dataset_cleaned_original.dta


if "`data_name'" == "dataset_cleaned_original" {

// In coumns 4 to 7 we wok with quartiles. To prevent overlapping of lines 
// in the plots showing the likelihood of repayment by quartile, because of variables
// with identical names, we will clon the variables
// storing the nature of consumption

capture clonevar nature_d =nature_d_2cat 
capture clonevar nature_d_2cat_t4 =nature_d_2cat 
capture clonevar nature_d_2cat_t5 =nature_d_2cat 
capture clonevar nature_d_2cat_t6 =nature_d_2cat 
capture clonevar nature_d_2cat_t7 =nature_d_2cat 

// COLUMN 4
// --------

reg $dep_variable  ///
ib2.nature_d_2cat_t4 ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 & quartile_1v2==1 $restriction_controls


margins i.nature_d_*4 , ///
atmeans noestimcheck post
est store prob_col4

// COLUMN 5
// --------


reg $dep_variable  ///
ib2.nature_d_2cat_t5 ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 &  quartile_2v2==1  $restriction_controls
est store table1c5

margins i.nature_d_*5  , ///
atmeans noestimcheck post
est store prob_col5

// COLUMN 6
// --------

reg $dep_variable  ///
ib2.nature_d_2cat_t6 ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 &  quartile_3v2==1 $restriction_controls
est store table1c6

margins i.nature_d_*6  , ///
atmeans noestimcheck post
est store prob_col6

// COLUMN 7
// --------

reg $dep_variable  ///
ib2.nature_d_2cat_t7 ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 &  quartile_4v2==1 $restriction_controls
est store table1c7


margins i.nature_d_*7  , ///
atmeans noestimcheck post

est store prob_col7


coefplot (prob_col3 \ ///
prob_col4 \ ///
prob_col5 \ ///
prob_col6 \ ///
prob_col7) || ///
,  drop(_cons 3.nature_d* 5.nature_d* ///
prop_nat_group3 ///
prop_nat_group5 ///
mer* repay* *cycleperiod* *x_amt_p*  *cl*  *utilisa* *prop_jobless* *median_hous* *prop_free_meal* *weekly_i* *prop_level*   *age*) ///
xtitle(Fitted Probability) ///
title("Fitted Repayment Probability for the First Purchase in a" "Single Consumption Category for New Accounts" ) ///
headings(   1.nature_d_2cat  = "{bf: Whole sample}" ///
1.nature_d_2cat_t4  = `""{bf:     }""{bf:   }""{bf:     }""{bf:   }""{bf:     }""{bf:   }""{bf:     }""{bf:   }" "{bf: Sample split by purchase amount}"" {it: Purchase value: £5.02 - £81.41}" "{bf:}   "      "    {bf: }     "" {bf: }  ""   {bf:}""   {bf: }  "" {bf:} " "  {bf: } " "{bf: }"' ///
1.nature_d_2cat_t5="{it:Purchase value: £81.42 - £290.64}" ///
1.nature_d_2cat_t6="{it:Purchase value:  £290.65 - £931.25}" ///
1.nature_d_2cat_t7="{it:Purchase value:  £931.26 - £17000}") scheme(plotplain)  xlabel(0 (.2) 1)


graph export "Figure 2. Fitted probabilities${name_table}.pdf",as(pdf) replace

// We use a five degree polynomial to control for the purchase ammount, which is
// very likely inducing multicollinearity among its terms. 
// We observe that in the small simulated data, it is possible that some confidence intervals for the predictions (at the means 
// of the covariates) are ommited because of problems of collinearity. 
// Collinearity is less problematic with our actual big data.
 }
 
 
 
 
//_____________________________________________
//
//  MULTIPLE CATEGORY - NEW ACCOUNTS - FIRST TRANSACTION
//  Table 5. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts 
//  Table B-2. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts, additional controls 
//  Table C-3. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts
//  Table C-4. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts, additional controls 
//_____________________________________________
//

// COLUMN 1
// 
 
reg $dep_variable  ///
pro_nat_no_dur ///
$controls_socioeco /// 
if !missing(subset1) & order_transac_new==1 $restriction_controls
est store table1c1

outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, replace ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label

// COLUMN 2
// 
reg $dep_variable  ///
pro_nat_no_dur ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1) & order_transac_new==1 $restriction_controls
est store table1c2

outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label

// COLUMN 3
// 
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
$controls_socioeco /// 
ac_age ///
x_amt_purchas* ///
if !missing(subset1) & order_transac_new==1 $restriction_controls
est store table1c3


outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label

// COLUMN 4
// 

reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
$controls_socioeco /// 
ac_age ///
x_amt_purchas* ///
if !missing(subset1) & order_transac_new==1 & quartile_1v2_m==1 $restriction_controls


est store table1c4
outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 1st quartile)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label


// COLUMN 5
// 
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
$controls_socioeco /// 
ac_age ///
x_amt_purchas* ///
if !missing(subset1) & order_transac_new==1 &  quartile_2v2_m==1 $restriction_controls
est store table1c5


outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 2nd quartile)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label

// COLUMN 6
// 
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
$controls_socioeco /// 
ac_age ///
x_amt_purchas* ///
if !missing(subset1) & order_transac_new==1 &  quartile_3v2_m==1 $restriction_controls
est store table1c6


outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 3rd quartile)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label

// COLUMN 7
// 
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
$controls_socioeco /// 
ac_age ///
x_amt_purchas* ///
if !missing(subset1) & order_transac_new==1 &  quartile_4v2_m==1 $restriction_controls
est store table1c7


outreg2 using Table_New_Accounts_Multiple_Purch_`data_name'${name_table}.doc, append ctitle(OLS - 4th quartile)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label
 
	
  
//_____________________________________________
//
//   Figure 3. Fitted probabilities for full repayment based on linear probability models (see Table 5, 
//   columns 3 to 7), evaluated at the mean of the other covariates. Lines span 95% confidence intervals. .  
//_____________________________________________
//

if "`data_name'" == "dataset_cleaned_original" {


// Figure 3 has 10 points. To prevent overlapping between extimates of Durables and Non-durables in the figure,
// due to the use of an identicalin variable name, we will work with 10 constant terms with different names
gen dummy1=1
gen dummy2=1
gen dummy3=1
gen dummy4=1
gen dummy5=1
gen dummy6=1
gen dummy7=1
gen dummy8=1
gen dummy9=1
gen dummy10=1

label define nodurable ///
1 "Non-durable"

label define durable ///
1 "Durable"

label values dummy1 dummy3 dummy5 dummy7 dummy9 nodurable
label values dummy2 dummy4 dummy6 dummy8 dummy10 durable



// BASELINE REGRESSION

local  regression_basic  ///
pro_nat_no_dur ///
pro_nat_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
$controls_socioeco /// 
ac_age ///
x_amt_purchas* ///

// RESTRICTIONS
local restriction1 ///
if !missing(subset1) & order_transac_new==1 

local restriction_quartile1 ///
if !missing(subset1) & order_transac_new==1 & quartile_1v2_m==1 

local restriction_quartile2 ///
if !missing(subset1) & order_transac_new==1 &  quartile_2v2_m==1 

local restriction_quartile3 ///
if !missing(subset1) & order_transac_new==1 &  quartile_3v2_m==1

local restriction_quartile4 /// 
if !missing(subset1) & order_transac_new==1 &  quartile_4v2_m==1 

// WHOLE SAMPLE (DURABLE / NON-DURABLE) - FITTED REPAYMENT PROBABILITY

reg $dep_variable  `regression_basic' i.dummy1 `restriction1' 
margins 	dummy1  ,  at(pro_nat_no_dur=1 pro_nat_dur=0) atmeans noestimcheck post
est store margin1

reg $dep_variable  `regression_basic' i.dummy2 `restriction1' 
margins  dummy2	  ,  at(pro_nat_no_dur=0 pro_nat_dur=1) atmeans noestimcheck post
est store margin2

// SAMPLE SPLIT BY QUARTILE (DURABLE / NON-DURABLE) - FITTED REPAYMENT PROBABILITY
// QUARTILE 1  
reg $dep_variable  `regression_basic' i.dummy3 `restriction_quartile1' 
margins 	dummy3  ,  at(pro_nat_no_dur=1 pro_nat_dur=0) atmeans noestimcheck post
est store margin3

reg $dep_variable  `regression_basic' i.dummy4 `restriction_quartile1' 
margins  dummy4  ,  at(pro_nat_no_dur=0 pro_nat_dur=1)  atmeans noestimcheck post
est store margin4

// QUARTILE 2
reg $dep_variable  `regression_basic' i.dummy5 `restriction_quartile2' 
margins 	dummy5  ,  at(pro_nat_no_dur=1 pro_nat_dur=0) atmeans noestimcheck post
est store margin5

reg $dep_variable  `regression_basic' i.dummy6 `restriction_quartile2' 
margins  dummy6  ,  at(pro_nat_no_dur=0 pro_nat_dur=1) atmeans noestimcheck post
est store margin6

// QUARTILE 3
reg $dep_variable  `regression_basic' i.dummy7 `restriction_quartile3' 
margins 	dummy7  ,  at(pro_nat_no_dur=1 pro_nat_dur=0) atmeans noestimcheck post
est store margin7

reg $dep_variable  `regression_basic' i.dummy8 `restriction_quartile3' 
margins  dummy8  ,  at(pro_nat_no_dur=0 pro_nat_dur=1) atmeans noestimcheck post
est store margin8
// QUARTILE 4  
  
reg $dep_variable  `regression_basic' i.dummy9 `restriction_quartile4' 
margins 	dummy9  ,  at(pro_nat_no_dur=1 pro_nat_dur=0) atmeans noestimcheck post
est store margin9

reg $dep_variable  `regression_basic' i.dummy10 `restriction_quartile4' 
margins  dummy10  ,  at(pro_nat_no_dur=0 pro_nat_dur=1) atmeans noestimcheck post
est store margin10

// Quartile cutoffs in the figure correspond to the dataset: dataset_cleaned_original.dta

 coefplot (margin1 \ margin2 \ margin3 \ ///
 margin4 \ margin5 \ margin6 \ margin7 \ ///
 margin8 \ margin9 \ margin10) || ///
 ,  drop(_cons 3.nature_d* 5.nature_d* ///
 prop_nat_group3 ///
prop_nat_group5 ///
mer* repay* *cycleperiod* *x_amt_p*  *cl*  *utilisa* *prop_jobless* *median_hous* *prop_free_meal* *weekly_i* *prop_level*   *age*) ///
   xtitle(Fitted Probability) ///
title("Fitted Repayment Probability for the First Purchase in a" "Multiple Consumption Category for New Accounts" ) ///
 headings(   1.dummy1  = "{bf: Whole sample}" ///
 1.dummy3  = `""{bf:     }""{bf:   }""{bf:     }""{bf:   }""{bf:     }""{bf:   }""{bf:     }""{bf:   }" "{bf: Sample split by purchase amount}"" {it: Purchase value: £5.02 - £81.41}" "{bf:}   "      "    {bf: }     "" {bf: }  ""   {bf:}""   {bf: }  "" {bf:} " "  {bf: } " "{bf: }"' ///
1.dummy5="{it:Purchase value: £81.42 - £290.64}" ///
1.dummy7="{it:Purchase value:  £290.65 - £931.25}" ///
1.dummy9="{it:Purchase value:  £931.26 - £17000}")  xlabel(0 (.2) 1) scheme(plotplain)

graph export "Figure 3. Fitted probabilities${name_table}.pdf",as(pdf) replace

 } 
