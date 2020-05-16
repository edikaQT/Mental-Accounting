

//_____________________________________________
//
//  SINGLE CATEGORY - ALL ACCOUNTS - ALL TRANSACTION
//  Table 6. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 
//  Table D-5. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 
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


// COLUMN 1 - RE
// --------

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
if subset1==1 ///
 $restriction_controls 

est store table1c1


outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, replace ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label

// COLUMN 2 - RE
// --------


xtreg $dep_variable  ///
ib2.nature_d_2cat ///
x_amt_purchas* ///
if subset1==1    ///
 $restriction_controls 
est store table1c2


outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label


// COLUMN 3 - RE
// --------

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if subset1==1  ///
 $restriction_controls   
est store table1c3



outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label




// COLUMN 4 - RE SOCIOECO CONTROLS
// --------
 
 
xtreg $dep_variable  ///
ib2.nature_d_2cat ///
$controls_socioeco /// 
if subset1==1    ///
 $restriction_controls 
est store so_table1c1


outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label



// COLUMN 5 - RE SOCIOECO CONTROLS
// --------


xtreg $dep_variable  ///
ib2.nature_d_2cat ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1   ///
 $restriction_controls  
est store so_table1c2

outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label


// COLUMN 6 - RE SOCIOECO CONTROLS
// --------

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if subset1==1    ///
 $restriction_controls 
est store so_table1c3




outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label


// COLUMN 7 - FE
// --------

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
if subset1==1 ///
 $restriction_controls ///
 , fe

est store fe_table1c1

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

outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, NO)  label 


// COLUMN 8 - FE
// --------



xtreg $dep_variable  ///
ib2.nature_d_2cat ///
x_amt_purchas* ///
if subset1==1 ///
 $restriction_controls ///
 , fe    
est store fe_table1c2

gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account

outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, NO)  label 


// COLUMN 9 - FE
// --------

xtreg $dep_variable  ///
ib2.nature_d_2cat ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if subset1==1  ///
 $restriction_controls ///
 , fe
est store fe_table1c3

gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account

outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, YES)  label 




//_____________________________________________
//
//  MULTIPLE CATEGORY - ALL ACCOUNTS - ALL TRANSACTIONS
//  Table 7. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for all accounts 
//  Table D-6. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for all accounts 
//_____________________________________________
//

// COLUMN 1 - RE
// --------
 
xtreg $dep_variable  ///
pro_nat_no_dur ///
if !missing(subset1) ///
 $restriction_controls

est store table1c1_m




outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, replace ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label 




// COLUMN 2 - RE
// --------


xtreg $dep_variable  ///
pro_nat_no_dur ///
x_amt_purchas* ///
if !missing(subset1)   ///
  $restriction_controls
est store table1c2_m



outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label 


// COLUMN 3 - RE
// --------


xtreg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if !missing(subset1)   ///
 $restriction_controls 
est store table1c3_m





outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label


// COLUMN 4 - RE SOCIO CONTROLS
// --------


xtreg $dep_variable  ///
pro_nat_no_dur ///
$controls_socioeco /// 
if !missing(subset1)   ///
 $restriction_controls 
est store so_table1c1_m



outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label 



// COLUMN 5 - RE SOCIO CONTROLS
// --------



xtreg $dep_variable  ///
pro_nat_no_dur ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1)   ///
 $restriction_controls 
est store so_table1c2_m



outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label 



// COLUMN 6 - RE SOCIO CONTROLS
// --------

xtreg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
$controls_socioeco /// 
if !missing(subset1)   ///
 $restriction_controls 
est store so_table1c3_m







outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, YES)  label






// COLUMN 7 - FE
// --------


 
 
xtreg $dep_variable  ///
pro_nat_no_dur ///
if !missing(subset1)  ///
 $restriction_controls ///
 ,fe  
est store fe_table1c1_m


gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account


outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, NO)  label 



// COLUMN 8 - FE
// --------



xtreg $dep_variable  ///
pro_nat_no_dur ///
x_amt_purchas* ///
if !missing(subset1) ///
 $restriction_controls ///
 ,fe  
est store fe_table1c2_m

gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account


outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, NO)  label 


// COLUMN 9 - FE
// --------


xtreg $dep_variable  ///
pro_nat_no_dur ///
i.cycleperiod_month ///
mer_apr100 ///
cl  ///
utilisation ///
ac_age ///
x_amt_purchas* ///
if !missing(subset1)  ///
 $restriction_controls ///
, fe
est store fe_table1c3_m


gen insample=1 if e(sample)==1
bysort account: egen total_obs=sum(insample) //total obs
gen insample2=insample if total_obs>1 & !missing(total_obs) & insample==1
bysort account (insample2): gen an_account=_n==1  

tab insample2 if insample2==1
local Total_Observations= r(N) 

tab an_account if an_account==1 & insample2==1
local Total_Accounts= r(N) 

drop insample insample2 total_obs an_account




outreg2 using Table_All_Accounts_Multiple_Purch_`data_name'.doc, append ctitle(FE)  drop(i.cycleperiod_month) ///
addstat ("Adjusted Observations",`Total_Observations', "Adjusted Number of Accounts", `Total_Accounts') ///
addtext(Month FEs, YES)  label


