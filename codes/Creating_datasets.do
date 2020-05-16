
set more off

//_____________________________________________
//
//  DEFINING GLOBAL VARIABLES USED TO BUILD THE DATA
//  (Four datasets can be built, each with a different classification 
//   for durable/non_durable products: 
//   dataset_cleaned_original.dta
//   dataset_cleaned_flip_categories.dta
//   dataset_cleaned_no_business_expenses.dta
//   dataset_cleaned_survey.dta )
//_____________________________________________


//_____________________________________________
//
//  IMPORTING DATA PRELIMINARY CLEANED IN R
//_____________________________________________

cd "$location_data" 

import delimited "data_for_mental_accounting_20170530.csv", clear

des, fullnames 
 
keep accountnumber		///
customernumber		///
opendate		///
mer_apr		///
cash_apr		///
charge_off_rate		///
utilisation		///
cl		///
beg		///
bal		///
min		///
amt_purchase		///
num_purchase		///
lag_amt_pay		///
purchase_category		///
purchase_category_name		///
rp_ratio		///
cycleperiod		///
new_ac		///
amt_mcc*		

//_____________________________________________
//
//  FORMATTING DATES
//_____________________________________________

//   CURRENT DATE
list cycleperiod in 1/5
tostring(cycleperiod), replace
gen cycleperiod_year=substr(cycleperiod,1,4)
destring cycleperiod_year, replace
gen cycleperiod_month=substr(cycleperiod,5,8)
destring cycleperiod_month, replace

set more off 
tab cycleperiod_year //2013, 2014
tab cycleperiod_month //1 to 12

gen cycleperiod_date=ym(( cycleperiod_year), ///
(cycleperiod_month))

format cycleperiod_date %tm

//   OPEN DATE
gen opendate_year=substr(opendate,1,4)
destring opendate_year, replace
gen opendate_month=substr(opendate,6,2)
destring opendate_month, replace

gen opendate_date=ym(( opendate_year), ///
(opendate_month))

format opendate_date %tm

//_____________________________________________
//
//  ACCOUNT AGE
//_____________________________________________

gen ac_age=cycleperiod_date-opendate_date 
replace ac_age=ac_age/12
label var ac_age "Distance from open date (years)"

//_____________________________________________
//
//  NUMBER OF ACCOUNTS FOR EACH CARD HOLDER
//_____________________________________________

bysort customernumber accountnumber: gen num_accounts=_n==1
bysort customernumber: egen total_num_accounts=sum(num_accounts)
drop num_accounts

tab total_n, missing //93% have only 1 account
label var total_num_accounts "number of accounts by person"

//_____________________________________________
//
//  LABELLING VARIABLES
//_____________________________________________


label var beg	"Beginning balance"
label var bal	"Ending Balance"
label var min	"Required minimum"
label var ac_age	"Account age from open date (years)"
label var charge_off_rate "Charge-off rate"
replace utilisation=utilisation*100
label var utilisation	"Utilization (ending balance/ credit limit) (%)"
replace cl= cl/1000
label var cl	"Credit limit (£1000)"
label var mer_apr	"Merchant APR"
label var cash_apr	"Cash APR"
label var amt_purchase	"Purchase amount in the month"
label var num_purchase "Total number of purchases in the month"
label var purchase_category	"Purchase category (Corresponding to mcc0-27. 100: Multiple purchase categories)."
label var purchase_category_name	"Purchase category name"
label var rp_ratio	"Repayment-Purchase Ratio = -Repayment (t+1)/Purchase (t)."

codebook amt_purchase //always positive
codebook lag_amt_pay  //always negative
codebook rp_ratio //always positive
codebook amt_purchase //all more than 5 pounds
codebook *apr //mer_apr cash_apr

gen repayment= lag_amt_pay
label var repayment	"Repayment (t+1), negative means repayment"

gen mer_apr100=mer_apr*100
label var mer_apr100 "Merchant APR (%)"

tab purchase_category purchase_category_name, missing
tab purchase_category, missing
tab  purchase_category_name, missing



label define category ///
0 " N/A" ///
1 " Airlines" ///
2 " Auto Rental" ///
3 " Hotel/Motel" ///
4 " Restaurants/Bars" ///
5 " Travel Agencies" ///
6 " Other Transportation" ///
7 " Department Stores" ///
8 " Discount Stores" ///
9 " Clothing Stores" ///
10 " Hardware Stores" ///
11 " Drug Stores" ///
12 " Gas Stations" ///
13 " Mail Orders" ///
14 " Food Stores" ///
15 " Vehicles" ///
16 " Interior Furnishing Stores" ///
17 " Electric Appliance Stores" ///
18 " Sporting Goods/Toy Stores" ///
19 " Other Retail" ///
20 " Health Care" ///
21 " Recreation" ///
22 " Education" ///
23 " Utilities" ///
24 " Professional Services" ///
25 " Repair Shops" ///
26 " Other Services" ///
27 " Quasi Cash" ///
200 "No purchase" ///
100  "Multiple purchase categories", replace

label values purchase_category category

replace purchase_category=. if purchase_category==0
//all people puchase at least something


xtset accountnumber cycleperiod_date

//_____________________________________________
//
//  SUBSET 1 OF DATA: SINGLE-CONSUMPTION-CATEGORY
//_____________________________________________

gen subset1=0
replace subset1=1 if !missing(purchase_category) & purchase_category<90 
replace subset1=. if missing(purchase_category)
//recall: we exclude amt_purchase<=5 


label var subset1 "Observations w/ no multiple categories, no missing categories, purchase>5, beg_balance=0, no cash transfers"
tab purchase_category subset1 , missing


//_____________________________________________
//
//  DEPENDENT VARIABLE: REPAY FULL
//_____________________________________________

gen repay_full = 0
replace repay_full =1 if rp_ratio>=.9 & ///
!missing(rp_ratio)
replace repay_full=. if missing(rp_ratio)

label var repay_full "repay ratio>.9"


//_____________________________________________
//
//  CONTROLS FOR AMOUNT PAID
//_____________________________________________

gen x_amt_purchase=amt_purchase/1000
gen x_amt_purchase2 = x_amt_purchase^2
 gen x_amt_purchase3 = x_amt_purchase^3
 gen x_amt_purchase4 = x_amt_purchase^4
 gen x_amt_purchase5 = x_amt_purchase^5


label var x_amt_purchase "Amount purchase (£1000)"
label var x_amt_purchase2 "Amount purchase (£1000)^2"
label var x_amt_purchase3 "Amount purchase (£1000)^3"
label var x_amt_purchase4 "Amount purchase (£1000)^4"
label var x_amt_purchase5 "Amount purchase (£1000)^5"
  
  
//_____________________________________________
//
//  MERGING WITH POSTCODE DATA TO GET CONTROLS FOR SOCIOEOCNOMIC STATUS
//_____________________________________________

 
sort customernumber


merge customernumber using ///
070616postcode2.dta
tab _merge //all are 3

gen there_is_data=1
foreach var of varlist ///
median_house_prc ///
prop_free_meals ///
weekly_inc {

replace there_is_data=0 if missing(`var')
 }
 
tab there_is_data
label var there_is_data "Account has postcode controls (0-1)" //all

codebook account //160,463  accounts
codebook account if there_is_data==1 //108999  accounts


global controls_socioeco median_house_prc ///
prop_free_meals    ///            
weekly_inc    


//_____________________________________________
//
//  CREATING VARIABLES FOR MULTIPLE CONSUMPTION
//_____________________________________________
//


// OMITING NEGATIVE AMOUNTS FROM THE COMPUTATION OF PROPORTIONS

 rename amt_mcc0 amount_missing

// We consider only durables and no durables and ommit utilities and quasi cash
global categories_used ///
 amt_mcc1   ///
 amt_mcc2   ///
 amt_mcc3   ///
 amt_mcc4   ///
 amt_mcc5   ///
 amt_mcc6   ///
 amt_mcc7   ///
 amt_mcc8   ///
 amt_mcc9   ///
 amt_mcc10   ///
 amt_mcc11   ///
 amt_mcc12   ///
 amt_mcc13   ///
 amt_mcc14   ///
 amt_mcc15   ///
 amt_mcc16   ///
 amt_mcc17   ///
 amt_mcc18   ///
 amt_mcc19   ///
 amt_mcc20   ///
 amt_mcc21   ///
 amt_mcc22   ///
/// amt_mcc23  /// utilities
 amt_mcc24   ///
 amt_mcc25   ///
 amt_mcc26   ///
/// amt_mcc27    ///quasi cash  

des $categories_used
 
 foreach v of varlist $categories_used {
  gen x_`v'= `v'
  replace  x_`v'=0 if `v'<0
}
 
 des x_amt*
 egen amt_total=rowtotal(x_amt_mcc*)
 codebook amt_total
 
  foreach v of varlist x_amt_mcc* {
  gen prop_`v'= `v'/amt_total
}
 
label var prop_x_amt_mcc1 "Proportion Airlines "
label var prop_x_amt_mcc2 "Proportion Auto Rental "
label var prop_x_amt_mcc3 "Proportion Hotel/Motel "
label var prop_x_amt_mcc4 "Proportion Restaurants/Bars "
label var prop_x_amt_mcc5 "Proportion Travel Agencies "
label var prop_x_amt_mcc6 "Proportion Other Transportation "
label var prop_x_amt_mcc7 "Proportion Department Stores "
label var prop_x_amt_mcc8 "Proportion Discount Stores "
label var prop_x_amt_mcc9 "Proportion Clothing Stores "
label var prop_x_amt_mcc10 "Proportion Hardware Stores "
label var prop_x_amt_mcc11 "Proportion Drug Stores "
label var prop_x_amt_mcc12 "Proportion Gas Stations "
label var prop_x_amt_mcc13 "Proportion Mail Orders "
label var prop_x_amt_mcc14 "Proportion Food Stores "
label var prop_x_amt_mcc15 "Proportion Vehicles "
label var prop_x_amt_mcc16 "Proportion Interior Furnishing Stores "
label var prop_x_amt_mcc17 "Proportion Electric Appliance Stores "
label var prop_x_amt_mcc18 "Proportion Sporting Goods/Toy Stores "
label var prop_x_amt_mcc19 "Proportion Other Retail "
label var prop_x_amt_mcc20 "Proportion Health Care "
label var prop_x_amt_mcc21 "Proportion Recreation "
label var prop_x_amt_mcc22 "Proportion Education "
//label var prop_x_amt_mcc23 "Proportion Utilities "
label var prop_x_amt_mcc24 "Proportion Professional Services "
label var prop_x_amt_mcc25 "Proportion Repair Shops "
label var prop_x_amt_mcc26 "Proportion Other Services "
//label var prop_x_amt_mcc27 "Proportion Quasi Cash "

//_____________________________________________
//
//         CLASSIFICATION OF CATEGORIES - DEFINING DURABLE AND NON DURABLE GROUPS
// (selecting the list of classifications in the global variables)
//_____________________________________________
//

//
//         CLASSIFICATION FOR SINGLE-CONSUMPTION-CATEGORY
//
if "$definition_durables" == "original" {
// ORIGINAL CLASSIFICATION (listing the numeric values in purchase_category)

global list_no_durables 1, 2, 3,4,5,6, 11,12,13,14,19, 21
global list_durables 7,8,9,10,15,16,17,18,20,22,24,25,26
}

if "$definition_durables" == "flip_categories" {

// ROBUSTNESS CHECK 1: Flip the classification of categories. 
//
// - From non-durable to durable: other retail. 
// - From durable to non-durable: professional services, other services, discount stores. 
// Results are not sensitive to classifications.

// 19  Other Retail
// 24  Professional Services
// 26  Other Services
//  8  Discount Stores

global list_no_durables 1, 2, 3,4,5,6, 11,12,13,14, 21, 24, 26, 8
global list_durables 7,9,10,15,16,17,18,20,22,25,19
}
// ROBUSTNESS CHECK 2: No bussiness related categories.

if "$definition_durables" == "no_business_expenses" {

global list_no_durables  2, 4, 11,12,13,14,19, 21
global list_durables 7,8,9,10,15,16,17,18,20,22,24,25,26

// 3, 5, 1, 6: no hotel, travel agencies, airlines, other transportation
}
// ROBUSTNESS CHECK 3: survey classification of categories.

if "$definition_durables" == "survey" {


sort purchase_category
drop _merge

cd "$location_cleaned_data"

merge purchase_category using survey_data.dta

replace dummy_durable_survey=. if purchase_category==23 // utilities are excluded

levelsof purchase_category if dummy_durable_survey==0, local(levels_nd)
display `levels_nd'
global list_no_durables  `levels_nd'
display "$list_no_durables"
global list_no_durables =subinstr("$list_no_durables", " ", ",",.) 
display "$list_no_durables"


levelsof purchase_category if dummy_durable_survey==1, local(levels_d)
display `levels_d'
global list_durables  `levels_d'
display "$list_durables"
global list_durables =subinstr("$list_durables", " ", ",",.) 
display "$list_durables"



}







//         CLASSIFICATION FOR MULTIPLE-CONSUMPTION-CATEGORY
// (selecting the list of classifications in the global variables)

if "$definition_durables" == "original" {

// ORIGINAL

global amount_list_no_durables ///
 x_amt_mcc1 ///
 x_amt_mcc2 ///
 x_amt_mcc3 ///
 x_amt_mcc4 ///
 x_amt_mcc5 ///
 x_amt_mcc6 ///
 x_amt_mcc11 ///
 x_amt_mcc12 ///
 x_amt_mcc13 ///
 x_amt_mcc14 ///
 x_amt_mcc19 ///
 x_amt_mcc21 

 global amount_list_durables ///
 x_amt_mcc7 ///
 x_amt_mcc8 ///
 x_amt_mcc9 ///
 x_amt_mcc10 ///
 x_amt_mcc15 ///
 x_amt_mcc16 ///
 x_amt_mcc17 ///
 x_amt_mcc18 ///
 x_amt_mcc20 ///
 x_amt_mcc22 ///
 x_amt_mcc24 ///
 x_amt_mcc25 ///
 x_amt_mcc26 

 }
 

if "$definition_durables" == "flip_categories" {

// ROBUSTNESS CHECK 1: Flip the classification of categories. 

 global amount_list_no_durables ///
 x_amt_mcc1 ///
 x_amt_mcc2 ///
 x_amt_mcc3 ///
 x_amt_mcc4 ///
 x_amt_mcc5 ///
 x_amt_mcc6 ///
 x_amt_mcc11 ///
 x_amt_mcc12 ///
 x_amt_mcc13 ///
 x_amt_mcc14 ///
 x_amt_mcc21 ///
 x_amt_mcc24 ///
 x_amt_mcc26 ///
 x_amt_mcc8 

 global amount_list_durables ///
 x_amt_mcc7 ///
 x_amt_mcc9 ///
 x_amt_mcc10 ///
 x_amt_mcc15 ///
 x_amt_mcc16 ///
 x_amt_mcc17 ///
 x_amt_mcc18 ///
 x_amt_mcc20 ///
 x_amt_mcc22 ///
 x_amt_mcc25 ///
 x_amt_mcc19 

} 
 
if "$definition_durables" == "no_business_expenses" {
 
// ROBUSTNESS CHECK 2: No bussiness related categories.


global amount_list_no_durables ///
 x_amt_mcc2 ///
 x_amt_mcc4 ///
 x_amt_mcc11 ///
 x_amt_mcc12 ///
 x_amt_mcc13 ///
 x_amt_mcc14 ///
 x_amt_mcc19 ///
 x_amt_mcc21 

 global amount_list_durables ///
 x_amt_mcc7 ///
 x_amt_mcc8 ///
 x_amt_mcc9 ///
 x_amt_mcc10 ///
 x_amt_mcc15 ///
 x_amt_mcc16 ///
 x_amt_mcc17 ///
 x_amt_mcc18 ///
 x_amt_mcc20 ///
 x_amt_mcc22 ///
 x_amt_mcc24 ///
 x_amt_mcc25 ///
 x_amt_mcc26 
}


if "$definition_durables" == "survey" {
 
// ROBUSTNESS CHECK 3: Survey categories.


levelsof purchase_category if dummy_durable_survey==0, local(levels_nd)
display `levels_nd'

 foreach w of local levels_nd {
 ///display"`w'"
 local amount_list_no_durables  x_amt_mcc`w' `amount_list_no_durables'
 }
display "`amount_list_no_durables'"
///des `amount_list_no_durables'
global amount_list_no_durables `amount_list_no_durables'

des $amount_list_no_durables





levelsof purchase_category if dummy_durable_survey==1, local(levels_d)
display `levels_d'

 foreach w of local levels_d {
 display"`w'"
 local amount_list_durables  x_amt_mcc`w' `amount_list_durables'
 }
display "`amount_list_durables'"
///des `amount_list_no_durables'
global amount_list_durables `amount_list_durables'

des $amount_list_durables



}



//_____________________________________________
//
//         CLASSIFICATION OF CATEGORIES - COMPUTING DURABLE AND NON DURABLE GROUPS
// (based in the selection made above using the list of classifications in the global variables)
//_____________________________________________
//
//         CLASSIFICATION FOR SINGLE-CONSUMPTION-CATEGORY
//
gen nature="Non-durable" if ///
inlist(purchase_category,$list_no_durables)

replace nature="Durable" if ///
inlist(purchase_category, $list_durables)

tab purchase_category nature, missing // 00 utilities, quasi cash and multiple categories

// assign numeric classification to nature
gen nature_d=1 if nature=="Non-durable"
replace nature_d=2 if nature== "Durable"

label define natured ///
1 "Non-durable" ///
2 "Durable" , replace

label values nature_d natured

tab nature_d nature, missing


//
//         CLASSIFICATION FOR MULTIPLE-CONSUMPTION-CATEGORY
//

 egen nat_group1=rowtotal( $amount_list_no_durables)

 egen nat_group2=rowtotal( $amount_list_durables)

 egen nat_amt_total=rowtotal(nat_group*)
 codebook nat_amt_total
 
  foreach v of varlist nat_group* {
  gen prop_`v'= `v'/nat_amt_total
}
 
 
label var prop_nat_group1 "Proportion Non-durable" 
label var prop_nat_group2 "Proportion Durable" 


 des ac_age
 gen ac_age_months=ac_age*12

//_____________________________________________
//
//   ORDER OF PURCHASES 
//_____________________________________________
//
// NOTE THAT THE ORDER IS INDEPENDENT OF SUBSET1, 
// SO IT INCLUDES MULTIPLE CATEGORIES OF CONSUMPTION

sum rp_ratio, detail
bysort account (cycleperiod_date): gen order_transac=_n if    ///
   !missing(purchase_category)
gen order_transac_new=order_transac if new_ac==1
gen order_transac_old=order_transac if new_ac!=1
drop order_transac


label var order_transac_new "Order of transactions for NEW accounts including 0 repayment"
label var order_transac_old "Order of transactions for OLD accounts including 0 repayment"


codebook accountnumber if !missing(subset) & rp_ratio!=0 //
codebook accountnumber if !missing(subset) & there_is_data==1 &  rp_ratio!=0 //
codebook accountnumber if !missing(subset) & there_is_data==1 &  rp_ratio!=0 & subset==1 //


codebook accountnumber if !missing(subset)  // 
codebook accountnumber if !missing(subset) & there_is_data==1 //
codebook accountnumber if !missing(subset) & there_is_data==1 & subset==1 //


gen purchase_category_no_multip=purchase_category if purchase_category!=100


codebook account if there_is_data==1 //108999  accounts

//_____________________________________________
//
// DEFINING QUARTILES OF PURCHASE AMOUNT
// (1) New Accounts - Single Consumption Category - First Purchase Analysis. 
// (This is the cleanest setting in our data, 
// in which the individual opens a new account and makes a purchase in a single category)
//_____________________________________________
//

tab nature_d //1: non-durable; 2: durable

gen spenditure_durables= amt_purchase if subset==1 & nature_d==2 & order_transac_new==1 


gen spenditure_no_durables= amt_purchase if subset==1 & ///
 (nature_d==1) ///
 & order_transac_new==1 
codebook spenditure_dur if !missing(spenditure_dur) 
codebook spenditure_no_durables if !missing(spenditure_no_durables) 


xtile quartile_spend_dur=spenditure_durables, n(4)
	
tab quartile_spend, missing
tab quartile, gen(quartile_)
	replace quartile_1 =0 if missing(quartile_1)
	replace quartile_2 =0 if missing(quartile_2)
	replace quartile_3 =0 if missing(quartile_3)
	replace quartile_4 =0 if missing(quartile_4)

foreach var of varlist quartile_1 quartile_2 quartile_3 quartile_4 {
sum amt_purchase if `var'==1
local min_`var'=r(min)
local max_`var'=r(max)

display round(`min_`var'',0.01)
display round(`max_`var'',0.01)

}

drop quartile_1 quartile_2 quartile_3 quartile_4

gen quartile_1v2=0
gen quartile_2v2=0
gen quartile_3v2=0
gen quartile_4v2=0

replace quartile_1v2=1 if amt_purchase<=round(`max_quartile_1',0.01)
replace quartile_2v2=1 if amt_purchase<=round(`max_quartile_2',0.01) & amt_purchase>round(`max_quartile_1',0.01)
replace quartile_3v2=1 if amt_purchase<=round(`max_quartile_3',0.01) & amt_purchase>round(`max_quartile_2',0.01)
replace quartile_4v2=1 if amt_purchase>round(`max_quartile_3',0.01)
	
// subset1 is a dummy for single category of consumption

replace quartile_1v2=0 if subset!=1 | order_transac_new!=1 
replace quartile_2v2=0 if subset!=1 | order_transac_new!=1 
replace quartile_3v2=0 if subset!=1 | order_transac_new!=1 
replace quartile_4v2=0 if subset!=1 | order_transac_new!=1 


codebook amt_purchase if quartile_1v2==1 
codebook amt_purchase if quartile_2v2==1
codebook amt_purchase if quartile_3v2==1
codebook amt_purchase if quartile_4v2==1
		
	
label var quartile_1v2 "Quartile 1 (purchase amount), new accounts, one consumption category, first transaction"
label var quartile_2v2 "Quartile 2 (purchase amount), new accounts, one category, first transaction"
label var quartile_3v2 "Quartile 3 (purchase amount), new accounts, one category, first transaction"
label var quartile_4v2 "Quartile 4 (purchase amount), new accounts, one category, first transaction"

//_____________________________________________
//
// DEFINING QUARTILES OF PURCHASE AMOUNT
// (1) New Accounts - Multiple Consumption - First Purchase Analysis. 
// (Multiple Consumption Sample includes Single Consumption Sample)
//_____________________________________________
//

gen quartile_1v2_m=0
gen quartile_2v2_m=0
gen quartile_3v2_m=0
gen quartile_4v2_m=0

replace quartile_1v2_m=1 if amt_purchase<=round(`max_quartile_1',0.01)
replace quartile_2v2_m=1 if amt_purchase<=round(`max_quartile_2',0.01) & amt_purchase>round(`max_quartile_1',0.01)
replace quartile_3v2_m=1 if amt_purchase<=round(`max_quartile_3',0.01) & amt_purchase>round(`max_quartile_2',0.01)
replace quartile_4v2_m=1 if amt_purchase>round(`max_quartile_3',0.01)
	
replace quartile_1v2_m=0 if missing(subset) | order_transac_new!=1 
replace quartile_2v2_m=0 if missing(subset) | order_transac_new!=1 
replace quartile_3v2_m=0 if missing(subset) | order_transac_new!=1 
replace quartile_4v2_m=0 if missing(subset) | order_transac_new!=1 

codebook amt_purchase if quartile_1v2_m==1 
codebook amt_purchase if quartile_2v2_m==1
codebook amt_purchase if quartile_3v2_m==1
codebook amt_purchase if quartile_4v2_m==1
		
label var quartile_1v2_m "Quartile 1 (purchase amt) of new accounts, at least one category, first transaction"
label var quartile_2v2_m "Quartile 2 (purchase amt) of new accounts, at least one category, first transaction"
label var quartile_3v2_m "Quartile 3 (purchase amt) of new accounts, at least one category, first transaction"
label var quartile_4v2_m "Quartile 4 (purchase amt) of new accounts, at least one category, first transaction"



rename nature_d nature_d_2cat
label var nature_d_2cat "Nature of Consumption"
rename prop_nat_group1 pro_nat_no_dur
rename prop_nat_group2 pro_nat_dur

label var pro_nat_no_dur "Proportion No-durable (excluding utilities and cash)"
label var pro_nat_dur "Proportion Durable (excluding utilities and cash)"

//_____________________________________________
//
// DUMMY FOR BUSSINESS RELATED CATEGORIES
//_____________________________________________
//

gen purchases_in_travel_related=0
 replace purchases_in_travel_related=1 if ///
 x_amt_mcc1>0 | ///
 x_amt_mcc3>0 | ///
 x_amt_mcc5>0 | ///
 x_amt_mcc6 
 
 tab purchases_in_travel_related, missing

 cd "$location_cleaned_data"
 save dataset_cleaned_$definition_durables, replace
 
 
 
 
 

 
 