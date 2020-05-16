
//_____________________________________________________________________
//
// CREATING NEW INDEPENDENT VARIABLES FOR TYPES OF CONSUMPTION
// INDEPENDENT VARIABLES ARE NOW SINGLE MERCHANT CODES
//_____________________________________________________________________
//

//____________________________
//
// NON-DURABLE MERCHANT CODES
//____________________________

// Creating a vector containing EACH Non-durable individual merchant code + "Durable" classification

gen nature_d_manycat=purchase_category if nature=="Non-durable"
replace nature_d_manycat=1000 if nature=="Durable" //adding a classification for any Durable merchant code

capture label define category ///
1000 "Durable" , add
label values nature_d_manycat category 

tab nature_d_manycat nature, missing
label var nature_d_manycat "Non-durable merchant code"

//____________________________
//
// DURABLE MERCHANT CODES
//____________________________

// Creating a vector containing EACH Durable individual merchant code + "Non-durable" classification

gen nature_d_manycat_refND=purchase_category if nature=="Durable"
replace nature_d_manycat_ref=2000 if nature=="Non-durable" //adding a classification for any Non-durable merchant code

capture label define category ///
2000 "Non-durable", add 
label values nature_d_manycat_refND category 

tab nature_d_manycat_ nature, missing
label var nature_d_manycat_refND "Durable merchant code"


//_____________________________________________________________________
//
// CREATING NEW INDEPENDENT VARIABLES FOR TYPES OF CONSUMPTION
// INDEPENDENT VARIABLES ARE NOW PROPORTION SPENT IN EACH MERCHANT CODE
//_____________________________________________________________________
//



global prop_list_no_durables ///
 prop_x_amt_mcc1 ///
 prop_x_amt_mcc2 ///
 prop_x_amt_mcc3 ///
 prop_x_amt_mcc4 ///
 prop_x_amt_mcc5 ///
 prop_x_amt_mcc6 ///
 prop_x_amt_mcc11 ///
 prop_x_amt_mcc12 ///
 prop_x_amt_mcc13 ///
 prop_x_amt_mcc14 ///
 prop_x_amt_mcc19 ///
 prop_x_amt_mcc21 

 global prop_list_durables ///
 prop_x_amt_mcc7 ///
 prop_x_amt_mcc8 ///
 prop_x_amt_mcc9 ///
 prop_x_amt_mcc10 ///
 prop_x_amt_mcc15 ///
 prop_x_amt_mcc16 ///
 prop_x_amt_mcc17 ///
 prop_x_amt_mcc18 ///
 prop_x_amt_mcc20 ///
 prop_x_amt_mcc22 ///
 prop_x_amt_mcc24 ///
 prop_x_amt_mcc25 ///
 prop_x_amt_mcc26 

 
//_____________________________________________
//
//  DEFINING GLOBAL VARIABLES
//_____________________________________________
//

global dep_variable repay_full
global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
 
cd "$location_cleaned_data"
 
//_____________________________________________
//
//  REGRESSIONS SINGLE CATEGORY OF CONSUMPTION - TABLES E1 & E3
//_____________________________________________
//
 
// COLUMN 1 (TABLES E1, E3) - FIRST PURCHASE OF NEW ACCOUNTS


reg $dep_variable  ///
$variables_tested /// omiting DURABLES OR NON DURABLES
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if subset1==1 & order_transac_new==1 


outreg2 using Table_Single_Purch_${name_table}.doc, replace ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label


margins i.$variables_tested0 , ///
atmeans noestimcheck post

est store prob_col1

// COLUMN 2 (TABLES E1, E3) - FIRST PURCHASE OF NEW ACCOUNTS + POSTCODE CONTROLS
  
reg $dep_variable  ///
$variables_tested /// omiting DURABLES OR NON DURABLES
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 


outreg2 using Table_Single_Purch_${name_table}.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label


//  COLUMN 3 (TABLES E1, E3) - ALL ACCOUNTS - RE 


xtreg $dep_variable  ///
$variables_tested /// omiting DURABLES OR NON DURABLES
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if subset1==1    


outreg2 using Table_Single_Purch_${name_table}.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label


// COLUMN 4 (TABLES E1, E3) - ALL ACCOUNTS - RE + POSTCODE CONTROLS

xtreg $dep_variable  ///
$variables_tested /// omiting DURABLES OR NON DURABLES
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1    

outreg2 using Table_Single_Purch_${name_table}.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label


// COLUMN 5 (TABLES E1, E3) - ALL ACCOUNTS - FE


xtreg $dep_variable  ///
$variables_tested /// omiting DURABLES OR NON DURABLES
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if subset1==1    , fe



// FE estimation requieres 2 observations per account
// Observations
// Number of accounts
gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account


outreg2 using Table_Single_Purch_${name_table}.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, YES)  label 




//_____________________________________________
//
//  Figure 4, 5 - Top Panel. Fitted probabilities of full repayment based on linear probability models (see 
//  Tables E-1 to E-4, column 1), evaluated at the mean of the other covariates. Lines span 
//  95% confidence intervals.
//_____________________________________________
//

  coefplot (prob_col1 \ ///
  ) || ///
 ,  transform(* = min(max(@,.2),.7))  ///
 drop(_cons ///
mer* repay* *cycleperiod* *x_amt_p*  *cl*  *utilisa* *prop_jobless* *median_hous* *prop_free_meal* *weekly_i* *prop_level*   *age*) ///
 ///ytitle(Nature of Consumption) ///
   xtitle(Fitted Probability) ///
title("Fitted Repayment Probability for the First Purchase in a" "Single Consumption Category for New Accounts" ) ///
 headings(   1.$variables_tested0  = `""{bf: Non-durable}" "{it: (Merchant codes)}""' ///
   7.$variables_tested0  = `""{bf: Durable}" "{it: (Merchant codes)}""' ///
 1000.$variables_tested0="{bf: Durable}" ///
  2000.$variables_tested0="{bf: Non-durable}" ///
) scheme(plotplain) ///
 xlabel(.2 (.1) .7) plotregion(margin(zero)) name(SP${name_table}, replace) 




//_____________________________________________
//
//  REGRESSIONS MULTIPLE CATEGORY OF CONSUMPTION - TABLES E2 & E4
//_____________________________________________
//

// COLUMN 1 (TABLES E2, E4) - FIRST PURCHASE OF NEW ACCOUNTS


reg $dep_variable  ///
 $variables_tested_prop ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if !missing(subset1) & order_transac_new==1 
est store table_c1


outreg2 using Table_Multiple_Purch_${name_table}.doc, replace ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label

 
// COLUMN 2 (TABLES E2, E4) - FIRST PURCHASE OF NEW ACCOUNTS + POSTCODE CONTROLS
 

reg $dep_variable  ///
 $variables_tested_prop ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1) & order_transac_new==1 



outreg2 using Table_Multiple_Purch_${name_table}.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label

// COLUMN 3 (TABLES E2, E4) - ALL ACCOUNTS - RE 

  


xtreg $dep_variable  ///
 $variables_tested_prop ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if !missing(subset1)    


outreg2 using Table_Multiple_Purch_${name_table}.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label

// COLUMN 4 (TABLES E2, E4) - ALL ACCOUNTS - RE + POSTCODE CONTROLS



xtreg $dep_variable  ///
 $variables_tested_prop ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1)    


outreg2 using Table_Multiple_Purch_${name_table}.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label


// COLUMN 5 (TABLES E2, E5) - ALL ACCOUNTS - FE

 


xtreg $dep_variable  ///
 $variables_tested_prop ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if !missing(subset1)    ,fe


// FE estimation requieres 2 observations per account
// Observations
// Number of accounts
gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account


outreg2 using Table_Multiple_Purch_${name_table}.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, YES)  label 



//_____________________________________________
//
//  FITTED PROBABILITITES 
//_____________________________________________
//


if "$name_table"== "_durable_good_as_reference" {

//  FITTED PROBABILITITES FOR EACH NON-DURABLE MERCHANT CODE

est restore  table_c1

 margins 	,  at( ///
 prop_x_amt_mcc1 =1   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) /// 
 atmeans noestimcheck post
  est store margin1

  est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =1   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin2
 
   est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =1   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin3
  
    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =1   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin4
  
    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =1   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin5
  
    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =1 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin6

    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =1  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin11

  est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =1  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
  atmeans noestimcheck post
  est store margin12

    est restore  table_c1
 margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =1  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) /// 
 atmeans noestimcheck post
  est store margin13

    est restore  table_c1
 margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =1  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
 atmeans noestimcheck post
  est store margin14

  est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =1  prop_x_amt_mcc21 =0 ) ///
 atmeans noestimcheck post
  est store margin19

   est restore  table_c1
  margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =1 ) ///
 atmeans noestimcheck post
  est store margin21

   est restore  table_c1
  margins 	,  at( ///
 prop_x_amt_mcc1 =0   prop_x_amt_mcc2 =0   prop_x_amt_mcc3 =0   prop_x_amt_mcc4 =0   prop_x_amt_mcc5 =0   prop_x_amt_mcc6 =0 ///
 prop_x_amt_mcc11 =0  prop_x_amt_mcc12 =0  prop_x_amt_mcc13 =0  prop_x_amt_mcc14 =0  prop_x_amt_mcc19 =0  prop_x_amt_mcc21 =0 ) ///
 atmeans noestimcheck post
  est store margin_durable
}

if "$name_table"== "_nondurable_good_as_reference" {

  
 //  FITTED PROBABILITITES FOR EACN DURABLE MERCHANT CODE
 
 est restore  table_c1

 margins 	,  at( ///
 prop_x_amt_mcc7 =1   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
 atmeans noestimcheck post
  est store margin7

  est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =1   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin8
 
   est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =1   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin9
  
    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =1   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin10
  
    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =1   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin15
  
    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =1 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin16

    est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =1  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin17

  est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =1  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
  atmeans noestimcheck post
  est store margin18

    est restore  table_c1
 margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =1  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
 atmeans noestimcheck post
  est store margin20

    est restore  table_c1
 margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =1  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
 atmeans noestimcheck post
  est store margin22

  est restore  table_c1
   margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =1  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
 atmeans noestimcheck post
  est store margin24

   est restore  table_c1
  margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =1  prop_x_amt_mcc26 =0) /// 
 atmeans noestimcheck post
  est store margin25

   est restore  table_c1
  margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =1) /// 
 atmeans noestimcheck post
  est store margin26
  
     est restore  table_c1
  margins 	,  at( ///
 prop_x_amt_mcc7 =0   prop_x_amt_mcc8 =0   prop_x_amt_mcc9 =0   prop_x_amt_mcc10 =0   prop_x_amt_mcc15 =0   prop_x_amt_mcc16 =0 ///
 prop_x_amt_mcc17 =0  prop_x_amt_mcc18 =0  prop_x_amt_mcc20 =0  prop_x_amt_mcc22 =0  prop_x_amt_mcc24 =0  prop_x_amt_mcc25 =0  prop_x_amt_mcc26 =0) /// 
 atmeans noestimcheck post
  est store   margin_no_durable

  }

//_____________________________________________
//
//  Figure 4, 5 - Bottom Panel. Fitted probabilities of full repayment based on linear probability models (see 
//  Tables E-1 to E-4, column 1), evaluated at the mean of the other covariates. Lines span 
//  95% confidence intervals.
//_____________________________________________
//

if "$name_table"== "_nondurable_good_as_reference" {

 
      coefplot (margin7 \ ///
 margin8 \ ///
 margin9 \ ///
 margin10 \ ///
 margin15 \ ///
 margin16 \ ///
 margin17 \ ///
 margin18 \ ///
 margin20 \ ///
 margin22 \ ///
 margin24 \ ///
 margin25 \ ///
 margin26 \ ///
 margin_no_durable) || ///
 ,  transform(* = min(max(@,.2),.7))  /// 
 aseq swapnames  ///
   xtitle(Fitted Probability) ///
title("Fitted Repayment Probability for the First Purchase in a" "Multiple Consumption Category for New Accounts" ) ///
 headings(   ///
margin1= `""{bf: Non-durable}" "{it: (Merchant codes)}""' ///
margin_durable= "{bf: Durable}"  ///
margin7= `""{bf: Durable}" "{it: (Merchant codes)}""' ///
margin_no_durable= "{bf: Non-Durable}"  ///
) ///
		  coeflabels( ///
	margin1    = "Airlines" ///
margin2    = "Auto Rental" ///
margin3    = "Hotel/Motel" ///
margin4    = "Restaurants/Bars" ///
margin5    = "Travel Agencies" ///
margin6    = "Other Transportation" ///
margin11    = "Drug Stores" ///
margin12    = "Gas Stations" ///
margin13    = "Mail Orders" ///
margin14    = "Food Stores" ///
margin19    = "Other Retail" ///
margin21    = "Recreation" ///
margin_durable    = "Durable" ///
margin_no_durable = "Non-Durable" ///
///
margin7 = "Department Stores" ///
margin8 = "Discount Stores" ///
margin9 = "Clothing Stores" ///
margin10 = "Hardware Stores" ///
margin15 = "Vehicles" ///
margin16 = "Interior Furnishing Stores" ///
margin17 = "Electric Appliance Stores" ///
margin18 = "Sporting Goods/Toy Stores" ///
margin20 = "Health Care" ///
margin22 = "Education" ///
margin24 = "Professional Services" ///
margin25 = "Repair Shops" ///
margin26 = "Other Services" ///
 )	scheme(plotplain) ///
 xlabel(.2 (.1) .7) plotregion(margin(zero)) name(MP${name_table}, replace) 

 
graph combine SP${name_table} MP${name_table}, scheme(plotplain) col(1) xsize(3) ysize(4)
graph export "Figure 4. Fitted probabilities${name_table}",as(pdf) replace
 
}
 
if "$name_table"== "_durable_good_as_reference" {
  
      coefplot (margin1 \ ///
 margin2 \ ///
 margin3 \ ///
 margin4 \ ///
 margin5 \ ///
 margin6 \ ///
 margin11 \ ///
 margin12 \ ///
 margin13 \ ///
 margin14 \ ///
 margin19 \ ///
 margin21 \ ///
 margin_durable) || ///
 ,  aseq swapnames  ///
   xtitle(Fitted Probability) ///
title("Fitted Repayment Probability for the First Purchase in a" "Multiple Consumption Category for New Accounts" ) ///
 headings(   ///
margin1= `""{bf: Non-durable}" "{it: (Merchant codes)}""' ///
margin_durable= "{bf: Durable}"  ///
margin7= `""{bf: Durable}" "{it: (Merchant codes)}""' ///
margin_no_durable= "{bf: Non-Durable}"  ///
) ///
		  coeflabels( ///
	margin1    = "Airlines" ///
margin2    = "Auto Rental" ///
margin3    = "Hotel/Motel" ///
margin4    = "Restaurants/Bars" ///
margin5    = "Travel Agencies" ///
margin6    = "Other Transportation" ///
margin11    = "Drug Stores" ///
margin12    = "Gas Stations" ///
margin13    = "Mail Orders" ///
margin14    = "Food Stores" ///
margin19    = "Other Retail" ///
margin21    = "Recreation" ///
margin_durable    = "Durable" ///
margin_no_durable = "Non-Durable" ///
///
margin7 = "Department Stores" ///
margin8 = "Discount Stores" ///
margin9 = "Clothing Stores" ///
margin10 = "Hardware Stores" ///
margin15 = "Vehicles" ///
margin16 = "Interior Furnishing Stores" ///
margin17 = "Electric Appliance Stores" ///
margin18 = "Sporting Goods/Toy Stores" ///
margin20 = "Health Care" ///
margin22 = "Education" ///
margin24 = "Professional Services" ///
margin25 = "Repair Shops" ///
margin26 = "Other Services" ///
 )	scheme(plotplain) ///
 xlabel(.2 (.1) .7) plotregion(margin(zero)) name(MP${name_table}, replace) 
	
 
graph combine SP${name_table} MP${name_table}, scheme(plotplain) col(1) xsize(3) ysize(4)
graph export "Figure 5. Fitted probabilities${name_table}",as(pdf) replace

}
