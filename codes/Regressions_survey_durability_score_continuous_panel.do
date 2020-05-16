

//_____________________________________________
//
//  SINGLE CATEGORY - ALL ACCOUNTS - ALL TRANSACTION
// Table G-8. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 
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


replace normal_score=. if purchase_category==23 // excluding utilities
replace normal_score_ND=. if purchase_category==23 // excluding utilities

label var normal_score_ND  "Non-durability Score (0 to 1)"


// COLUMN 1 - RE
// --------

xtreg $dep_variable  ///
normal_score_ND  ///
if subset1==1 ///
 $restriction_controls 

est store table1c1


outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, replace ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label

// COLUMN 2 - RE
// --------


xtreg $dep_variable  ///
normal_score_ND  ///
x_amt_purchas* ///
if subset1==1    ///
 $restriction_controls 
est store table1c2


outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label


// COLUMN 3 - RE
// --------

xtreg $dep_variable  ///
normal_score_ND  ///
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
normal_score_ND  ///
$controls_socioeco /// 
if subset1==1    ///
 $restriction_controls 
est store so_table1c1


outreg2 using Table_All_Accounts_Single_Purch_`data_name'.doc, append ctitle(RE)  drop(i.cycleperiod_month) ///
addtext(Month FEs, NO)  label



// COLUMN 5 - RE SOCIOECO CONTROLS
// --------


xtreg $dep_variable  ///
normal_score_ND  ///
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
normal_score_ND  ///
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
normal_score_ND  ///
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
normal_score_ND  ///
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
normal_score_ND  ///
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


