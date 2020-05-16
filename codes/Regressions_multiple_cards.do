

label var pro_nat_no_dur "Non-durable (proportion)"
label var accountnumber "account"
label var prop_free_meals  "Free school meals (proportion)"
global dep_variable repay_full

cd "$location_cleaned_data"

//_______________________________________
//
// APPENDIX F - TABLE F-1: Multiple Card Holders in Main Samples
//_______________________________________

//_______________________________________
//
// single purchase type new accounts, column 3 in Table 4
//_______________________________________

reg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 


outreg2 using Table_Accounts_Multiple_Cards.doc, replace ctitle(New Accounts - SP)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label  

//_______________________________________
//
// multiple purchase type new accounts, column 3 in Table 5

//_______________________________________
//
// 
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1) & order_transac_new==1 


outreg2 using Table_Accounts_Multiple_Cards.doc, append ctitle(New Accounts - MP)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label  sortvar(ib2.nature_d_2cat pro_nat_no_dur )

//_______________________________________
//
// single purchase type all accounts, column 3 in Table 6
//_______________________________________
//

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1  


outreg2 using Table_Accounts_Multiple_Cards.doc, append ctitle(All Accounts - SP)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 


//_______________________________________
//
// multiple purchase type all accounts), column 3 in Table 7
//_______________________________________
//


xtreg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1)  

outreg2 using Table_Accounts_Multiple_Cards.doc, append ctitle(All Accounts - MP)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 


//_______________________________________
//
// APPENDIX F - TABLE F-2: Multiple Card Holders - Single Purchase Type - New Accounts
//_______________________________________

//_______________________________________
//
// single purchase type new accounts, column 3 in Table 4
//_______________________________________




reg $dep_variable ///
number_cards_bal_pos ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1 & order_transac_new==1 


outreg2 using Table_Accounts_Multiple_Cards_New_Acc_Single_Purch.doc, replace ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label addnote(SP: Single Purchase; MP: Multiple Purchase)


foreach p of global control_cards {
    
	
	reg $dep_variable ///
	ib2.nature_d_2cat ///
	i.cycleperiod_month ///
	mer_apr100 ///
	cl  ///
	utilisation ///
	ac_age ///
	x_amt_purchas* ///
	$controls_socioeco /// 
	number_cards_bal_pos ///
	`p' ///
	if subset1==1 & order_transac_new==1 


outreg2 using Table_Accounts_Multiple_Cards_New_Acc_Single_Purch.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 


}



//_______________________________________
//
// APPENDIX F - TABLE F-3: Multiple Card Holders - Multiple Purchase Type - New Accounts
//_______________________________________

//_______________________________________
//
// multiple purchase type new accounts, column 3 in Table 5
//_______________________________________
//
// 
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
number_cards_bal_pos ///
if !missing(subset1) & order_transac_new==1 


outreg2 using Table_Accounts_Multiple_Cards_New_Acc_Mult_Purch.doc, replace ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 

foreach p of global control_cards {
    
reg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
number_cards_bal_pos ///
`p' ///
if !missing(subset1) & order_transac_new==1 


outreg2 using Table_Accounts_Multiple_Cards_New_Acc_Mult_Purch.doc, append ctitle(OLS)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 

}

//_______________________________________
//
// APPENDIX F - TABLE F-4: Multiple Card Holders - Single Purchase Type - All Accounts
//_______________________________________

//_______________________________________
//
// single purchase type all accounts, column 3 in Table 6
//_______________________________________
//

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
number_cards_bal_pos ///
if subset1==1  


outreg2 using Table_Accounts_Multiple_Cards_All_Acc_Single_Purch.doc, replace ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 

foreach p of global control_cards {
    
xtreg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
number_cards_bal_pos ///
`p' ///
if subset1==1  


outreg2 using Table_Accounts_Multiple_Cards_All_Acc_Single_Purch.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 


}

//_______________________________________
//
// APPENDIX F - TABLE F-5: Multiple Card Holders - Multiple Purchase Type - All Accounts
//_______________________________________

//_______________________________________
//
// multiple purchase type all accounts), column 3 in Table 7
//_______________________________________
//


xtreg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
number_cards_bal_pos ///
if !missing(subset1)  

outreg2 using Table_Accounts_Multiple_Cards_All_Acc_Mult_Purch.doc, replace ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label 

foreach p of global control_cards {
    
xtreg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
number_cards_bal_pos ///
`p' ///
if !missing(subset1)  


outreg2 using Table_Accounts_Multiple_Cards_All_Acc_Mult_Purch.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext( Month FEs, YES)  label


}



