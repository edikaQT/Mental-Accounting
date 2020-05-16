

// USE THESE ROUTES TO WORK WITH THE REAL DATA
// ====================================================================
//____________________________________________________________________________________________________
//
//
// Location of files:
global location_data "C:\Users\edika\Desktop\key backup\Mental accounting\data for paper" 
// where we have "data_for_mental_accounting_20170530.csv" (data created by R file: Mental_Accounting_Initial_Data_Cleaning)
global location_cleaned_data "C:\Users\edika\Desktop\temporals EQ" //where the outputs will be saved
global location_codes "C:\Users\edika\Desktop\GIT2\PhD Codes 2018\mental accounting\codes" //where the do files are saved
global location_survey "C:\Users\edika\Desktop\key backup\Mental accounting\2018 survey analysis" //location of raw survey data
//
//___________________________________________________________________________________________________


// USE THESE ROUTES INSTEAD IF WE WORK WITH A SIMULATED SAMPLE 
// ====================================================================
//____________________________________________________________________________________________________
//
//
// Location of files:
global location_data ""
// where we located  simulate random data that simil the structure of "data_for_mental_accounting_20170530.csv" (data created by R file: Mental_Accounting_Initial_Data_Cleaning)
global location_cleaned_data "" //where the outputs will be saved
global location_codes "" //where the do files are saved
global location_survey "" //location of raw survey data
//
//___________________________________________________________________________________________________



/////////////////////////////////////////////////////////////////////////////////////////
//
//                                 SIMULATING RANDOM DATA TO RUN OUR CODES
//                                 ==========================================
/////////////////////////////////////////////////////////////////////////////////////////


cd "$location_codes"
run Simulated_random_data.do //   dataset_cleaned_original.dta



/////////////////////////////////////////////////////////////////////////////////////////
//
//                                 CLEANING DATA
//                                 ==============
/////////////////////////////////////////////////////////////////////////////////////////

// In the paper, we defined durables/non durables four times
//  (Four datasets can be built, each with a different classification 
//   for durable/non_durable products: 
//   dataset_cleaned_original.dta
//   dataset_cleaned_flip_categories.dta
//   dataset_cleaned_no_business_expenses.dta
//   dataset_cleaned_survey.dta )


global definition_durables "original" 
cd "$location_codes"
run Creating_datasets.do //   dataset_cleaned_original.dta


global definition_durables "flip_categories"
cd "$location_codes"
run Creating_datasets.do //   dataset_cleaned_flip_categories.dta


global definition_durables "no_business_expenses" 
cd "$location_codes"
run Creating_datasets.do //   dataset_cleaned_no_business_expenses.dta

global definition_durables "survey" 
cd "$location_codes"
run "Survey v2.do" // survey_data.dta (cleans survey data and compute merchant code scores from survey responses)
cd "$location_codes"
run Creating_datasets.do //   dataset_cleaned_survey.dta

/////////////////////////////////////////////////////////////////////////////////////////
//
//                                 REGRESSIONS
//                                 ===========
/////////////////////////////////////////////////////////////////////////////////////////
ssc install outreg2

//_____________________________________________________________________
//
//                         Main Text Regressions
//_____________________________________________________________________


// NEW ACCOUNTS
// -------------
// Table 4. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts 
// Figure 2. Fitted probabilities of full repayment based on linear probability models (see Table 4, 
// columns 3 to 7), evaluated at the mean of the other covariates. Lines span 95% confidence 
// intervals.
// Table 5. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts
// Figure 3. Fitted probabilities for full repayment based on linear probability models (see Table 5, 
// columns 3 to 7), evaluated at the mean of the other covariates. Lines span 95% confidence intervals. 

// No controls for socioeconomic differences
global controls_socioeco ""
global restriction_controls "" 
global name_table "" //name_table will be used to add "postcode_controls" in the name of the files when postcode controls are used

cd "$location_cleaned_data"
use dataset_cleaned_original.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do

// ALL ACCOUNTS
// -------------
// Table 6. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 
// Table 7. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for all accounts 

global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls "" 

cd "$location_cleaned_data"
use dataset_cleaned_original.dta, clear

cd "$location_codes"
run Regressions_all_purchases.do



//_____________________________________________________________________
//
//          Appendix B - Regressions with additional controls  
//_____________________________________________________________________

// Table B-1. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
// Table B-2. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts, additional controls 
// Controls for socioeconomic differences

global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls " & there_is_data==1" 
global name_table "_postcode_controls"

cd "$location_cleaned_data"
use dataset_cleaned_original.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do


//_____________________________________________________________________
//
//          Appendix C - Reclassification of consumption categories 
//_____________________________________________________________________

// Table C-1. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts 
// Table C-3. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts
// No controls for socioeconomic differences

global controls_socioeco ""
global restriction_controls "" 
global name_table ""

cd "$location_cleaned_data"
use dataset_cleaned_flip_categories.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do

// Table C-2. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
// Table C-4. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts, additional controls 

// Controls for socioeconomic differences

global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls " & there_is_data==1" 
global name_table "_postcode_controls"

cd "$location_cleaned_data"
use dataset_cleaned_flip_categories.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do


//_____________________________________________________________________
//
//          Appendix D - Omitting travel related categories 
//_____________________________________________________________________

// NEW ACCOUNTS
// -------------

// Table D-1. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts 
// Table D-3. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts
// No controls for socioeconomic differences

global controls_socioeco ""
global restriction_controls " & purchases_in_travel_related==0"
global name_table ""

cd "$location_cleaned_data"
use dataset_cleaned_no_business_expenses.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do

// Table D-2. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
// Table D-4. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts 
// Controls for socioeconomic differences

global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls " & purchases_in_travel_related==0 & there_is_data==1" 
global name_table "_postcode_controls"

cd "$location_cleaned_data"
use dataset_cleaned_no_business_expenses.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do

// ALL ACCOUNTS
// -------------

// Table D-5. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 
// Table D-6. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for all accounts 


global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls " & purchases_in_travel_related==0"

cd "$location_cleaned_data"
use dataset_cleaned_no_business_expenses.dta, clear

cd "$location_codes"
run Regressions_all_purchases.do


//_____________________________________________________________________
//
//          Appendix E – Estimating marginal effects for individual merchant codes 
//_____________________________________________________________________

// DURABLE GOODS AS REFERENCE CATEGORY
// -------------------------------------
//  Table E-1. Estimated likelihood of repaying full balance for Single-Purchase-Type Sample, durable goods as reference category 
//  Table E-2. Estimated likelihood of repaying full balance for Multiple-Purchase-Type Sample, proportion of the total month spending 
//  on durable goods as reference category 
//  Figure 4. Fitted probabilities of full repayment based on linear probability models 

global variables_tested  ib1000.nature_d_manycat // Merchant codes for each Non-durable good. 1000 refers to any Durable good.
global variables_tested0 nature_d_manycat 


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



global variables_tested_prop $prop_list_no_durables  // Proportion spent on each merchant code related to Non-durable goods
global name_table "_durable_good_as_reference"

cd "$location_cleaned_data"
use dataset_cleaned_original.dta, clear

cd "$location_codes"
run Regressions_single_merchant_codes.do


// NON-DURABLE GOODS AS REFERENCE CATEGORY
// -------------------------------------
//  Table E-3. Estimated likelihood of repaying full balance for Single-Purchase-Type Sample, non-durable goods as reference category 

//  Table E-4. Estimated likelihood of repaying full balance for Multiple-Purchase-Type Sample, proportion of the total month spending 
//  on non-durable goods as reference category 
//  Figure 5. Fitted probabilities for full repayment based on linear probability models 


global variables_tested ib2000.nature_d_manycat_refND //Merchant codes for each Durable good. 2000 refers to any Non-durbale good
global variables_tested0 nature_d_manycat_refND 

global variables_tested_prop $prop_list_durables  //Proportion spent on each merchant code related to Durable goods
global name_table "_nondurable_good_as_reference"


cd "$location_cleaned_data"
use dataset_cleaned_original.dta, clear

cd "$location_codes"
run Regressions_single_merchant_codes.do



//_____________________________________________________________________
//
//          Appendix F - Analysis of Multiple Credit Card Holders  
//_____________________________________________________________________

cd "$location_codes"
run Creating_multiple_card_dataset.do // creates  "data_set_multiple_card_holders.dta"



cd "$location_cleaned_data"
use "data_set_multiple_card_holders.dta", clear

// global controls_socioeco ""
global controls_socioeco median_house_prc prop_free_meals  weekly_inc    

global control_cards total_balance_other1000 ///
ratio_total_balance ///
 has_max_utilisation has_min_utilisation has_max_bal ///
has_min_bal


cd "$location_codes"
run Regressions_multiple_cards.do


//_____________________________________________________________________
//
//          Appendix G - Using Durability Classification from Survey 
//_____________________________________________________________________

// NEW ACCOUNTS
// -------------

// Table G-1. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts 
// Table G-3. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts
// No controls for socioeconomic differences

global controls_socioeco ""
global restriction_controls ""
global name_table ""

cd "$location_cleaned_data"
use dataset_cleaned_survey.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do

// Table G-2. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
// Table G-4. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for new accounts 
// Controls for socioeconomic differences

global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls "  & there_is_data==1" 
global name_table "_postcode_controls"

cd "$location_cleaned_data"
use dataset_cleaned_survey.dta, clear

cd "$location_codes"
run Regressions_first_purchase.do

// ALL ACCOUNTS
// -------------

// Table G-5. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 
// Table G-6. Estimated likelihood of repaying full balance, Multiple-Purchase-Type Sample for all accounts 


global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls ""

cd "$location_cleaned_data"
use dataset_cleaned_survey.dta, clear

cd "$location_codes"
run Regressions_all_purchases.do

//_____________________________________
//
// USING A CONTINUOUS DURABILITY SCORE
//_____________________________________

// NEW ACCOUNTS
// -------------


// Table G-7. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for new accounts, additional controls 
global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls "  & there_is_data==1" 
global name_table "_postcode_controls"

cd "$location_cleaned_data"
use dataset_cleaned_survey.dta, clear

cd "$location_codes"
run Regressions_survey_durability_score_continuous.do

// ALL ACCOUNTS
// -------------

// Table G-8. Estimated likelihood of repaying full balance, Single-Purchase-Type Sample for all accounts 


global controls_socioeco median_house_prc prop_free_meals  weekly_inc    
global restriction_controls ""

cd "$location_cleaned_data"
use dataset_cleaned_survey.dta, clear

cd "$location_codes"
run Regressions_survey_durability_score_continuous_panel.do



