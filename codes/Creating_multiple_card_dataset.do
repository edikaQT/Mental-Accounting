
// PREPARING DATASET WITH MULTIPLE CREDIT CARD HOLDERS
cd "$location_cleaned_data"
use dataset_cleaned_original.dta, clear

keep customernumber cycleperiod accountnumber

export delimited using "acc.csv", replace

// The subset of cardholders used in our analysis is merged with the complete data
// of cardholders in R (R file: Mental_Accounting_subseting_Multiple_Card_holders)
// in order to identify the number of cards with positive balance  held by cardholder/customer,
// the ratio: balance in card/ total balance in other cards,
// dummies for each card holding the max or min balance,
// dummies for each card holding the max or min utilisation
// R output: "data_cardholders_multiple_cards_20180426.csv"

cd "$location_data"

import delimited "data_cardholders_multiple_cards_20180426.csv", clear

des, fullnames 

keep ///
customernumber  ///
accountnumber   ///
cycleperiod     ///
has_max_bal    ///                  
has_min_bal    ///                  
has_max_utilisation ///                               
has_min_utilisation ///
total_balance_other ///
number_cards_bal_pos ///
number_other_cards_bal_pos //umber_other_cards_bal_pos=number_cards_bal_pos-1

destring has_*, replace ignore(NA)
foreach var of varlist has_* {
replace `var'=0 if missing(`var')
}

sort customernumber  ///
accountnumber   ///
cycleperiod     


cd "$location_cleaned_data"

save "data_cardholders_multiple_cards_20180426.dta", replace

use dataset_cleaned_original.dta, clear

destring cycleperiod, replace
capture drop _merge
sort customernumber  ///
accountnumber   ///
cycleperiod  

merge customernumber accountnumber cycleperiod using ///
"data_cardholders_multiple_cards_20180426"

tab _merge // Only   57,183  account x months observations correspond to cardholders with multiple cards (20.33% of our original data)

keep if _merge==3
gen ratio_total_balance=bal/(total_balance_other + bal)
sum ratio_total_balance

gen total_balance_other1000=total_balance_other/1000

label var number_cards_bal_pos "Number of Cards w/ Positive Balance"
label var total_balance_other "Balance in other cards (£)"
label var total_balance_other1000 "Balance in other cards (£1000)"
label var ratio_total_balance "Ratio balance of card to total balance on all cards"
label var has_max_utilisation "Card has the highest utilization = 1"
label var has_min_utilisation "Card has the lowest utilization = 1"
label var has_max_bal "Card has the highest balance = 1"
label var has_min_bal "Card has the lowest balance =1"                   



save "data_set_multiple_card_holders.dta", replace

