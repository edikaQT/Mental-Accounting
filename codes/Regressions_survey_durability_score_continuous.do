
 
 
 
/////////////////////////////////////////////////////////////////////////////////////////
//
//                                 REGRESSIONS
//                                 ===========
/////////////////////////////////////////////////////////////////////////////////////////

//_____________________________________________
//
//  SINGLE CATEGORY - NEW ACCOUNTS - FIRST TRANSACTION
// Table G-7. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
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
replace normal_score=. if purchase_category==23 // excluding utilities
replace normal_score_ND=. if purchase_category==23 // excluding utilities

label var normal_score_ND  "Non-durability Score (0 to 1)"
// COLUMN 1
// --------
 
reg $dep_variable  ///
normal_score_ND  ///
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
normal_score_ND  ///
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
normal_score_ND  ///
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




// COLUMN 4
// --------

reg $dep_variable  ///
normal_score_ND  ///
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
normal_score_ND  ///
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
normal_score_ND  ///
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
normal_score_ND  ///
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




