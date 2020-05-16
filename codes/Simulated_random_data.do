
// The terms of our data licence with Argus specifically prohibit us from releasing the data 
// beyond our local networks. 
// Researchers access to the data used in our study for the purpose of examining and running 
// our code and replicating / interrogating  our results either via 
// i) visiting our universities and accessing data on our local networks, 
// or, ii) accessing the data via a Virtual Private Network. 

// This code creates a simulated data file to run the codes used in our study for the purpose
//  of checking our routines.

// All codes used in our stude to run all elements from raw data formatting through to final results
// are available on the journal website as suplementary materials 

//_______________________________________________________________________
//
// CREATING SIMULATED RANDOM DATASET SHOWING CREDIT CARD COMSUMPTION
// Replace for "data_for_mental_accounting_20170530.csv" created in R
//_______________________________________________________________________



// creating variables for different types of purchase categories for one person


global number_accounts=1000

clear


input accountnumber	customernumber	str30 opendate	mer_apr	cash_apr	charge_off_rate	utilisation	cl	beg	bal	min	amt_purchase	num_purchase	lag_amt_pay	purchase_category	str30 purchase_category_name	rp_ratio	cycleperiod	new_ac	amt_mcc0	amt_mcc1	amt_mcc2	amt_mcc3	amt_mcc4	amt_mcc5	amt_mcc6	amt_mcc7	amt_mcc8	amt_mcc9	amt_mcc10	amt_mcc11	amt_mcc12	amt_mcc13	amt_mcc14	amt_mcc15	amt_mcc16	amt_mcc17	amt_mcc18	amt_mcc19	amt_mcc20	amt_mcc21	amt_mcc22	amt_mcc23	amt_mcc24	amt_mcc25	amt_mcc26	amt_mcc27
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	0	"N/A"	.	201300	0	0.12	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	1	"Airlines"	.	201300	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	2	"Auto Rental"	.	201300	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	3	"Hotel/Motel"	.	201300	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	4	"Restaurants/Bars"	.	201300	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	5	"Travel Agencies"	.	201300	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	6	"Other Transportation"	.	201300	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	7	"Department Stores"	.	201300	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	8	"Discount Stores"	.	201300	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	9	"Clothing Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	10	"Hardware Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	11	"Drug Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	12	"Gas Stations"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	13	"Mail Orders"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	14	"Food Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	15	"Vehicles"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	16	"Interior Furnishing Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	17	"Electric Appliance Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	18	"Sporting Goods/Toy Stores"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	19	"Other Retail"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	20	"Health Care"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	21	"Recreation"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	22	"Education"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	23	"Utilities"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	24	"Professional Services"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	25	"Repair Shops"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	26	"Other Services"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	27	"Quasi Cash"	.	201300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1
1	1	"2001-01-01"	0.1795	0.1795	0.001	.	5000	0	.	5	1	1	.	100	"Mix"	.	201300	0	0.12	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1
end
// (Missing purchase categories are registered in "amt_mcc0" and also in purchase_category_name= "N/A".
// In the actual data, they have a mean purchase ammount of .12 pounds. We use this value in amt_mcc0)



// expanding the data to 5 people
expand $number_accounts

bysort purchase_category: gen temp_id=_n
replace accountnumber=temp_id
replace customernumber=temp_id

drop temp_id
sort accountnumber purchase_category

// creating random expenditure

set seed 77777

foreach var of varlist amt_mc* {

capture drop temp_random
capture generate temp_random = 10+(20000*invnibeta(2,100,1,uniform()))
replace `var'=temp_random if `var'==1
drop temp_random

}

sum amt_mc*, detail
// assigned consumption to months randomly for years 2013 and 2014

generate temp_random = runiform(0,1)

gen old_order=_n

bysort accountnumber (temp_random): gen new_order=_n
replace cycleperiod=cycleperiod+new_order

replace cycleperiod=cycleperiod+88 if cycleperiod>=201313
replace cycleperiod=cycleperiod+88 if cycleperiod>=201413

// create random open date

capture drop temp_month
capture drop temp_open_date
gen temp_month= round(runiform(1,12))
tostring temp_month, replace format("%02.0f")

gen temp_open_date="2001-"+temp_month+"-01"

replace opendate=temp_open_date

drop temp_open_date temp_month temp_random

// compute ammount purchase

egen amt_purchase_temp=rowtotal(amt_mcc*)
replace amt_purchase=amt_purchase_temp
replace bal=amt_purchase_temp

drop amt_purchase_temp

// create random proportion of balance that will be paid in the next monh
// (a mean of .9 ensures that we will have around half of the data with dummies of full repayment=1 later)

gen prop_paid = rnormal(0.9,0.1)
replace prop_paid=1 if prop_paid>1

sum prop_paid if prop_paid>.9
sum prop_paid if prop_paid<.9

replace lag_amt_pay=-prop_paid*amt_purchase
replace rp_ratio=(-lag_amt_pay)/amt_purchase 


capture drop prop_paid


// random merchant APR, cash APR, Charge-off rate, credit limit

foreach var of varlist mer_apr cash_apr {

generate temp_random = rnormal(0,0.001)
replace `var'=`var'+temp_random
drop temp_random
}



generate temp_random = rnormal(0,0.0001)
replace charge_off_rate=charge_off_rate+temp_random
drop temp_random 
generate temp_random = rnormal(0,500)
replace cl=cl+  temp_random //we ensure that the ramdonly generated credit limit is greater or equal than the balance
replace cl=bal if cl<bal
drop temp_random 

sum  mer_apr cash_apr cl charge_off_rate

// Utilization (ending balance/ credit limit)


replace utilisation=bal/cl


// frst half of accounts will be new accounts

replace new_ac=1 if accountnumber< ($number_accounts*4/5) 
//Some of our regressions use the first purchase of new accounts and to have enough number of observation we are setting
// 4/5 of the accounts to be new accounts. 


drop new_order old_order

cd "$location_data"

export delimited using "data_for_mental_accounting_20170530.csv", replace

//_______________________________________________________________________
//
// CREATING RANDOM VALUES FOR THE ANALYSIS OF MULTIPLE CREDIT CARD HOLDERS (APPENDIX F)
// Replace "data_cardholders_multiple_cards_20180426.csv" created in R
//_______________________________________________________________________



keep customernumber cycleperiod accountnumber 

generate temp_random = runiform(0,1)

gen has_max_bal=1 if 	temp_random>.5
gen has_min_bal=1 if temp_random<.5

drop temp_random
generate temp_random = runiform(0,1)

gen has_max_utilisation=1 if 	temp_random>.5	
gen has_min_utilisation=1 if 	temp_random<.5	
gen total_balance_other=	runiform(1000,10000)
gen number_cards_bal_pos= round(runiform(2,10))
gen number_other_cards_bal_pos=number_cards_bal_pos-1


drop temp_random

cd "$location_data"

export delimited "data_cardholders_multiple_cards_20180426.csv", replace

//_______________________________________________________________________
//
// CREATING RANDOM VALUES FOR POSTCODE CONTROLS
// Replace "070616postcode2.dta"
//_______________________________________________________________________


clear
input customernumber prop_free_meals weekly_inc_post median_house_prc	
1	.	. .  
end

label var prop_free_meals "Proportion of students on free school meals"
label var weekly_inc_post  "Weekly Household Income (£)"
label var median_house_prc  "Median house price (£)"


expand $number_accounts
gen temp_id=_n
replace customernumber=temp_id

drop temp_id


generate temp_random = rnormal(0.5,.1)
replace prop_free_meals=temp_random
drop temp_random
generate temp_random = rnormal(1000,100)
replace weekly_inc_post=temp_random
drop temp_random
generate temp_random = rnormal(1000000,10000)
replace median_house_prc=temp_random
drop temp_random

sort customernumber

cd "$location_data"

save 070616postcode2.dta, replace







