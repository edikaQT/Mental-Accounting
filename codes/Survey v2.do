
///////////////////////
///  SURVEY ANALYSIS
///////////////////////

///We have a list of 27 merchant categories with 500 subcategories. We want to identify the degree of durability of items from each of the 27 merchant
///codes. The survey contains a list with examples of products belonging to each subcategory. 
///Subcategories whose consumption is extremely rare are not
///included (with a weight of less than 1 in 1,000 in the CPI index).
///The specific objective of this survey is to estimate the durability of items from each merchant category. 
///The survey is being run in response to a reviewer’s
///comments. 

/// Participants were asked to decide on a 1–7 scale how durable each of a series of items (products or services) is.
/// For each item we will construct the mean score over participants. 
/// For each category, we will construct a category mean durability, weighting each item mean by spend frequency
/// for that item. Weights are taken from the 2014 UK Consumer Price Inflation indices and they reflect the levels
/// of spending on different goods and services. The key dependent variable in our study is the weighted mean 
/// durability score for each category.


///We will median split the 27 merchant codes into low and high durability and repeat the analysis described at
///Quispe-Torreblanca, E., Stewart, N., Gathergood, J., & Loewenstein, G. (2017). The red, the black, and the plastic: Paying down credit card debt for hotels
///not sofas. Available at SSRN: https://ssrn.com/abstract=3037416 (19 September 2017 version)
///We will also use category durability scores (normalized between 0 and 1) in place of the 0/1 dummy for low/high
/// durability and repeat the analysis.

/// _____________
///
/// READING DATA
/// _____________


///We will identify: 
///(1) participants who rate an airline ticket as more durable than a car, 
///(2) the 5% fastest and 5% slowest participants, 
///(3) participants with duplicated IP, 
///(4) participants whose autocorrelation over successive responses are in the top 2.5% of bottom 2.5% of 
///the distribution, 
///(5) participants whose responses scale entropy is in the lowest 5%, and
///(6) the 5% of participants with the lowest correlation between their ratings and the average of
///everyone else’s ratings. To spot people who are not consistent. 
///Participants identified through this (non-sequential) procedure will be dropped from the sample.




clear
cd "$location_survey"

///
/// Importing demographics
///

import delimited "demographics.csv", clear  //we have masked the real ip and useragent


keep subid exptduration ip time
bysort subid ip: gen an_ip=_n==1
bysort subid (ip): egen  many_ip=sum(an_ip)

keep subid exp many time
sort sub

tempfile file1 file2 file3
save `file1'

///
/// Importing people's ratings to different merchant codes' items 
///

import delimited "ratings.csv", clear 
gen order=_n
keep subid item rating order
sort subid


merge subid using `file1'

drop _merge
sort item
save `file2'

///
/// Importing files with CPI weights
///

/// For each merchant code, we have a list of items (goods or services).  
/// Consumers spend more on some goods and services than others. 
/// To proxy the general frequency of consumption of each item,
/// we mapped each item to the closses (sub) category used in the CONSUMER PRICE INFLATION (CPI) basked for 2014.
/// CPIs are constructed by weighting together the price movements of items according to their relative importance 
/// to the overall expenditure level of households. We used these CPI weights in our analysis.



import delimited "items_2.csv", clear 
list if missing(cpi_weight)
des, full
tab group_id group_des //merchant codes
codebook category_id category_des plain
rename plain item

keep group_des item cpi*




///	Computing RELATIVE WEIGHTS for item within each merchant code. 
/// - We have weights for each CPI subcategory, however, a subcategory can be matched to many items,
///  e.g., the items "An Item of Men's or Boy's Clothing", "An Item of Women's Clothing", 
/// "An Item of Children’s Clothing", are related to the CPI subcategory "03.1 Clothing". 
/// Or the items "A Visit to the Osteopath", "A Visit to the Chiropractor", "A Visit to the Opticians",
/// are related to the CPI subcategory "06.2.1/3 Medical services & paramedical services". 
/// So, to prevent double counting or multiple counting weights, for each merchant code, 
/// we adjusted the item’s weight to account for the number of items within CPI subcategories.

bysort group_des cpi_subcategory: gen a_subcategory=_n==1
bysort group_des (cpi_subcategory): egen total_weight_MC0=sum(cpi_weight) if a_subcategory==1 
bysort group_des (cpi_subcategory): egen total_weight_MC=mean(total_weight_MC0) 

bysort group_des cpi_subcategory: gen count_items_in_subcat_MC=_N 
gen cpi_weight_update=cpi_weight/count_items_in_subcat

//check
//bysort group_des (cpi_subcategory): egen total_weight_MC_check=sum(cpi_weight_update) 
//list total_weight_MC* if total_weight_MC_check!=total_weight_MC

gen item_weight_in_MC_0_to_1= cpi_weight_update/total_weight_MC

//check
//bysort group_des: egen sum_weights_in_MC=sum(item_weight_in_MC_0_to_1)


keep item item_weight_in_MC_0_to_1  group cpi_subcategory cpi_weight
sort group item
sort item
merge item using `file2'


sort order

/// _____________
///
/// DATA CLEANING
/// _____________

rename group_description MC
rename rating score
rename exptduration speed

///(1) participants who rate an airline ticket as more durable than a car, 

gen car=score if item=="A Car" & MC=="Vehicles" //car
gen airline=score if item=="An Airline Ticket" & MC=="Airlines" //airline

bysort subid: egen car_score=mean(car)
bysort subid: egen airline_score=mean(airline)

gen drop=0
replace drop=1 if car_score< airline_score

codebook subid if drop==1 //6

/// (2) the 5% fastest and 5% slowest participants, 
bysort subid: gen a_person=_n==1

egen speed_rank0 = xtile(speed) if a_person==1, nq(100)
bysort subid: egen speed_rank=mean(speed_rank0)
replace drop=1 if speed_rank<=5 | speed_rank>=95

codebook subid if drop==1 //60

///(3) participants with duplicated IP, 

replace drop=1 if many_ip>1

///(4) participants whose autocorrelation over successive responses are in the top 2.5% of bottom 2.5% of 
///the distribution, 

tsset subid order
gen lag_score=L.score
bysort subid: egen autocorr0 = corr(score lag_score) 
bysort subid: egen autocorr1 = mean(autocorr0)

egen autocorr_rank0 = xtile(autocorr1) if a_person==1, nq(100)

bysort subid: egen autocorr_rank=mean(autocorr_rank0)
replace drop=1 if autocorr_rank<=2.5 | autocorr_rank>=97.5

codebook subid if drop==1 //80

///(5) participants whose responses scale entropy is in the lowest 5%, and

///We include a measure of entropy for card holder durability scores. 
///For each person, we computed a measure of Shannon entropy (H) defined as follows:
///H=-∑pi log2(pi)      	
///Where pi is the probability for score i. Note that the sum is across all 7 scale scores.
 
///For example, for the score 1:
///Total_score_1: Total number of items with score 1
///Total_all: Total number of items responded in the survey
///p1= (Total_score_1 +1 ) /  ( Total_all + 7)
///To prevent taking logs of 0 counts, we added 1 to the numerator and 7 to the denominator (Laplacian Smoothing).

bysort subid: egen t_number_intems=count(score)

 levelsof score, local(levels) 
 foreach l of local levels {
 
 display `l'
bysort subid: egen t_score_`l'=count(score) if score==`l'
bysort subid: egen max=max(t_score_`l') 
replace  t_score_`l'=0 if missing(max)

bysort subid: gen prob_score_`l'_=(t_score_`l'+1)/(t_number_intems+7)
bysort subid: egen prob_score_`l'=mean(prob_score_`l'_)
gen log2_prob_score_`l' = ln(prob_score_`l')/ln(2)
drop max
drop prob_score_`l'_ t_score_`l'
}

gen H=-(prob_score_1*log2_prob_score_1 + ///
prob_score_2*log2_prob_score_2 + ///
prob_score_3*log2_prob_score_3 + ///
prob_score_4*log2_prob_score_4 + ///
prob_score_5*log2_prob_score_5 + ///
prob_score_6*log2_prob_score_6 + ///
prob_score_7*log2_prob_score_7) //



egen entropy_rank0 = xtile(H) if a_person==1, nq(100)

bysort subid: egen entropy_rank=mean(entropy_rank0)
replace drop=1 if entropy_rank<=5

codebook subid if drop==1 //98

///(6) the 5% of participants with the lowest correlation between their ratings and the average of
///everyone else’s ratings. To spot people who are not consistent. 

bysort MC item: egen average_rating=mean(score)


//ssc install egenmore

sort subid
egen corr_with_average = corr(score average_rating) , by(subid)

//corr (score average_rating) if subid==1
egen corr_with_average_rank0 = xtile(corr_with_average) if a_person==1, nq(100)

bysort subid: egen corr_with_average_rank=mean(corr_with_average_rank0)
replace drop=1 if corr_with_average_rank<=5

///Participants identified through this (non-sequential) procedure will be dropped from the sample.
tab drop
codebook subid if drop==1 //112 people

drop if drop==1

/// droping unnecesary variabels

drop speed_rank0  ///
  car airline ///
 autocorr0 autocorr_rank0 ///
 prob_score* log2* ///
 entropy_rank0 corr_with_average_rank0

///____________________________________________________
///
/// COMPUTING WEIGHTED SCORES FOR EACH MERCHANT CODE
///____________________________________________________

/// We have participants' scores on a 1–7 scale about how durable each of a series of items (products or services) is.
/// (1) For each item we will construct the mean score over participants. 
/// (2) For each merchant code, we will construct a category mean durability, weighting each item mean by spend frequency
/// for that item. Weights are taken from the 2014 UK Consumer Price Inflation indices and they reflect the levels
/// of spending on different goods and services. The key dependent variable in our study is the weighted mean 
/// durability score for each category.


sort MC item

/// (1) For each item we will construct the mean score over participants. 

bysort  item: egen score_item=mean(score)
bysort MC item: gen an_item=_n==1



/// (2) For each merchant code, we will construct a category mean durability,

/// checking that the relative weights for items add to one for each merchant code
/// bysort MC: egen check_weights=sum(item_weight_in_MC_0_to_1) if an_item==1 //all 1


gen score_weighted=item_weight_in_MC_0_to_1*score_item if an_item==1

bysort MC: egen mean_score_MC=sum(score_weighted)

///____________________________________________________
///
/// COMPUTING UNWEIGHTED SCORES FOR EACH MERCHANT CODE
///____________________________________________________

bysort MC: egen unweighted_mean_score_MC0=mean(score_item) if an_item==1
bysort MC: egen unweighted_mean_score_MC=mean(unweighted_mean_score_MC0) 

///We will also use category durability scores (normalized between 0 and 1) in place of the 0/1 dummy for low/high durability and repeat the analysis.
su mean_score_MC //, meanonly

gen normal_score_MC = (mean_score_MC - r(min)) / (r(max) - r(min)) 
gen normal_score_MC_ND = 1-normal_score_MC


su unweighted_mean_score_MC //, meanonly
gen normal_unweighted_score_MC = (unweighted_mean_score_MC - r(min)) / (r(max) - r(min)) 
gen normal_unweighted_score_MC_ND = 1-normal_unweighted_score_MC




save `file3'

///__________________________________________________________________________________________
///
/// NEW DURABILITY CLASSIFICATION - PLOTTING DURABILITY SCORES WITHOUT CONFIDENCE INTERVALS
///__________________________________________________________________________________________

use `file3', clear

/// We will median split the merchant codes into low and high durability 
collapse (first) normal* mean_score_MC  unweighted_mean_score_MC  ,by(MC)

egen median_scores=median(mean_score_MC)
egen median_normalized_scores=median(normal_score_MC)




gen durable_survey_median=0
replace durable=1 if mean_score_MC>=median_scores

egen median_unweigthed_scores=median(unweighted_mean_score_MC)

gen durable_survey_unweighted_median=0
replace durable_survey_u=1 if unweighted_mean_score_MC>=median_unweigthed_scores

tab MC, gen(MC_)


global original_no_durable MC_1            ///                  Airlines
MC_2            ///                  Auto Rental
MC_13           ///                  Hotel/Motel
MC_22           ///                  Restaurants/Bars
MC_24           ///                  Travel Agencies
MC_6            ///                  Drug Stores
MC_10           ///                  Gas Stations
MC_15           ///                  Mail Orders
MC_9            ///                  Food Stores
MC_16           ///                  Other Retail
MC_20           ///                 Recreation
MC_18           //                  Other Transportation


global original_durable ///
MC_3            ///                  Clothing Stores
MC_4            ///                  Department Stores
MC_5            ///                  Discount Stores
MC_7            ///                  Education
MC_8            ///                  Electric Appliance Stores
MC_11           ///                  Hardware Stores
MC_12           ///                  Health Care
MC_14           ///                  Interior Furnishing Stores
MC_17           ///                  Other Services
MC_19           ///                  Professional Services
MC_21           ///                  Repair Shops
MC_23           ///                  Sporting Goods/Toy Stores
///MC_25           ///                  Utilities
MC_26           //                  Vehicles



reg normal_score_MC_ND $original_durable, nocons
estimates store weighted_MC_durable

reg normal_score_MC_ND $original_no_durable, nocons
estimates store weighted_MC_no_durable

reg normal_unweighted_score_MC_ND $original_durable, nocons
estimates store unweighted_MC_durable

reg normal_unweighted_score_MC_ND $original_no_durable, nocons
estimates store unweighted_MC_no_durable


foreach i of varlist MC_* {
local a : variable label `i'
local a: subinstr local a "MC==" ""
label var `i' "`a'"
}

sort normal_score_MC
gen order_normal_score_MC=_n

///_______________________________
///
/// PLOT WITH NORMALIZED SCORES ///
///_______________________________

reg normal_score_MC_ND $original_durable, nocons
estimates store weighted_MC_durable

matrix plotD = r(table)'
matsort plotD 1 "down"
matrix plotD = plotD'


reg normal_score_MC_ND $original_no_durable, nocons
estimates store weighted_MC_no_durable

matrix plotND = r(table)'
matsort plotND 1 "down"
matrix plotND = plotND'

//matrix combined = plotD , plotND
matrix combined = plotND , plotD




      coefplot  matrix(combined[1,]) ///  
	  ///
  (unweighted_MC_no_durable unweighted_MC_durable ) ///\ ///
 || ///
 ,    headings(   ///
MC_1= "{bf: Original Classification - Non-durable}"  ///
MC_17= "{bf: Original Classification - Durable}"  ///
) ///
 title("Normalized Merchant Codes' Non-durability Scores" ) ///
   xtitle(Normalized Non-durability Scores)  ///sort ///sort(3) ///
   omitted noci ///
      p1(label(Weighted Scores) )       ///
    p2(label(Unweighted Scores)  ) ///
	scheme(plotplain) ///
 xlabel(.0 (.2) 1) plotregion(margin(zero)) 

cd "$location_cleaned_data"
graph export "Figure G_4 Normalized non-durability scores for each merchant code.pdf",as(pdf) replace



///_______________________________
///
/// PLOT WITH MEAN SCORES (NON NORMALIZED) ///
///_______________________________



reg mean_score_MC $original_durable, nocons
estimates store weighted_MC_durable

reg mean_score_MC $original_no_durable, nocons
estimates store weighted_MC_no_durable

reg unweighted_mean_score_MC  $original_durable, nocons
estimates store unweighted_MC_durable

reg unweighted_mean_score_MC  $original_no_durable, nocons
estimates store unweighted_MC_no_durable



sort normal_score_MC
capture gen order_normal_score_MC=_n



reg mean_score_MC  $original_durable, nocons
estimates store weighted_MC_durable

matrix plotD = r(table)'
matsort plotD 1 "down"
matrix plotD = plotD'


reg mean_score_MC $original_no_durable, nocons
estimates store weighted_MC_no_durable

matrix plotND = r(table)'
matsort plotND 1 "down"
matrix plotND = plotND'

matrix combined = plotD , plotND

sum median_scores  



      coefplot  matrix(combined[1,]) ///  
	  ///
  (unweighted_MC_no_durable unweighted_MC_durable ) ///\ ///
 || ///
 ,    headings(   ///
MC_15= "{bf: Original Classification - Non-durable}"  ///
MC_8= "{bf: Original Classification - Durable}"  ///
) ///
 title("Merchant Codes' Durability Scores" ) ///
   xtitle(Durability Scores)  ///sort ///sort(3) ///
   omitted noci ///
      p1(label(Weighted Scores) )       ///
    p2(label(Unweighted Scores)  ) ///
	scheme(plotplain) ///
 xlabel(1 (1) 7) plotregion(margin(zero)) ///name(MP${name_table}, replace) 
xline(`r(mean)', lcolor(red) )

cd "$location_cleaned_data"
graph export "Figure G_2 Average durability scores for each merchant code.pdf",as(pdf) replace



 keep MC ///                 
durable_survey_median ///dummy
durable_survey_unweighted_median ///dummy
normal_score_MC ///
normal_score_MC_ND ///
normal_unweighted_score_MC ///
normal_unweighted_score_MC_ND ///
median_normalized_scores ///for plot
mean_score_MC   ///
unweighted_mean_score_MC ///
median_scores   ///                
median_unweigthed_scores

 
 
sort  normal_score_MC


gen purchase_category=.
replace purchase_category=0 if MC=="N/A"
replace purchase_category=           1 if MC==  "Airlines"
replace purchase_category=           2 if MC==  "Auto Rental"
replace purchase_category=           3  if MC== "Hotel/Motel"
replace purchase_category=           4 if MC==  "Restaurants/Bars"
replace purchase_category=           5 if MC==  "Travel Agencies"
replace purchase_category=           6 if MC==  "Other Transportation"
replace purchase_category=           7 if MC==  "Department Stores"
replace purchase_category=           8 if MC==  "Discount Stores"
replace purchase_category=           9 if MC==  "Clothing Stores"
replace purchase_category=          10 if MC==  "Hardware Stores"
replace purchase_category=          11 if MC==  "Drug Stores"
replace purchase_category=          12 if MC==  "Gas Stations"
replace purchase_category=          13 if MC==  "Mail Orders"
replace purchase_category=          14 if MC==  "Food Stores"
replace purchase_category=          15 if MC==  "Vehicles"
replace purchase_category=          16 if MC==  "Interior Furnishing Stores"
replace purchase_category=          17 if MC==  "Electric Appliance Stores"
replace purchase_category=          18 if MC==  "Sporting Goods/Toy Stores"
replace purchase_category=          19 if MC==  "Other Retail"
replace purchase_category=          20 if MC==  "Health Care"
replace purchase_category=          21 if MC==  "Recreation"
replace purchase_category=          22 if MC==  "Education"
replace purchase_category=          23 if MC==  "Utilities"
replace purchase_category=          24 if MC==  "Professional Services"
replace purchase_category=          25 if MC==  "Repair Shops"
replace purchase_category=          26 if MC==  "Other Services"
replace purchase_category=          27 if MC==  "Quasi Cash"
replace purchase_category=         100 if MC== "Multiple purchase categories"
replace purchase_category=         200 if MC== "No purchase"

tab purchase, missing

bysort durable_survey_median: tab purchase

//non normalized scores (prefix NN)
//------------------------------

rename mean_score_MC  NN_mean_score_MC
rename median_scores NN_median_scores
rename unweighted_mean_score_MC NN_unweighted_mean_score_MC 


//normalized scores
//----------------------
rename normal_score_MC  normal_score
rename normal_score_MC_ND  normal_score_ND

rename durable_survey_median dummy_durable_survey
rename median_normalized_scores median_score


keep purchase* normal_score* ///
median_score ///
 dummy ///
 MC NN*

order MC purchase* normal_score* ///
median_score ///
 dummy ///
  NN*





sort purchase


cd "$location_cleaned_data"

save survey_data.dta,replace




use `file3', clear



///__________________________________________________________________________________________
///
/// NEW DURABILITY CLASSIFICATION - PLOTTING DURABILITY SCORES WITH CONFIDENCE INTERVALS
///__________________________________________________________________________________________



///___________________________________________________________________________
///
/// COMPUTING WEIGHTED SCORES FOR EACH MERCHANT CODE AND FOR EACH PARTICIPANT (SO [PARTICPANTS X MERCHANT CODES] SCORES)
///___________________________________________________________________________

/// We have participants' scores on a 1–7 scale about how durable each of a series of items (products or services) is.
/// (1) For each participant, for each merchant code, we will construct a category mean durability, weighting each item by spend frequency
/// for that item. Weights are taken from the 2014 UK Consumer Price Inflation indices and they reflect the levels
/// of spending on different goods and services. The key dependent variable in our study is the weighted mean 
/// durability score for each category.


sort MC item

/// (1) For each subject, for each merchant code, for each item, we will construct a weighted score



bysort subid MC cpi_subcategory : gen a_cpi_subcategory_subject=_n==1
bysort subid MC: egen total_weight_MC_subject0=sum(cpi_weight) if a_cpi_subcategory_subject==1 
bysort subid MC: egen total_weight_MC_subject=mean(total_weight_MC_subject0) 
bysort subid MC cpi_subcategory: gen count_items_in_subcat_MC_sub=_N 
gen cpi_weight_update_subject=cpi_weight/count_items_in_subcat_MC_sub
gen item_weight_in_MC_0_to_1_subject= cpi_weight_update_subject/total_weight_MC_subject


/// checking that the relative weights for CPI subcategories add to one for each merchant code
bysort subid MC: egen sum_weights_in_MC_subject=sum(item_weight_in_MC_0_to_1_subject)
tab sum_weights_in_MC_subject
drop sum_weights_in_MC_subject
//


/// (1) For each subject, for each merchant code, we will construct a category mean durability


gen score_weighted_subject=item_weight_in_MC_0_to_1_subject * score
bysort subid MC: egen mean_score_MC_subject=sum(score_weighted_subject)

///____________________________________________________
///
/// COMPUTING UNWEIGHTED SCORES FOR EACH MERCHANT CODE
///____________________________________________________

bysort subid MC: egen unw_mean_score_subject_MC0=mean(score) 
bysort subid MC: egen unw_mean_score_subject_MC=mean(unw_mean_score_subject_MC0) 


su mean_score_MC_subject //, meanonly
su unw_mean_score_subject_MC //, meanonly




///__________________________________________________________________________________________
///
/// NEW DURABILITY CLASSIFICATION - PLOTTING DURABILITY SCORES WITHOUT CONFIDENCE INTERVALS
///__________________________________________________________________________________________

/// We will median split the merchant codes into low and high durability 
collapse (first) mean_score_MC_subject  unw_mean_score_subject_MC  ,by(subid MC)


tab MC, gen(MC_)


global original_no_durable MC_1            ///                  Airlines
MC_2            ///                  Auto Rental
MC_13           ///                  Hotel/Motel
MC_22           ///                  Restaurants/Bars
MC_24           ///                  Travel Agencies
MC_6            ///                  Drug Stores
MC_10           ///                  Gas Stations
MC_18           ///                  Other Transportation
MC_15           ///                  Mail Orders
MC_9            ///                  Food Stores
MC_16           ///                  Other Retail
MC_20           //                 Recreation

global original_durable ///
MC_3            ///                  Clothing Stores
MC_4            ///                  Department Stores
MC_5            ///                  Discount Stores
MC_7            ///                  Education
MC_8            ///                  Electric Appliance Stores
MC_11           ///                  Hardware Stores
MC_12           ///                  Health Care
MC_14           ///                  Interior Furnishing Stores
MC_17           ///                  Other Services
MC_19           ///                  Professional Services
MC_21           ///                  Repair Shops
MC_23           ///                  Sporting Goods/Toy Stores
///MC_25           ///                  Utilities
MC_26           //                  Vehicles





foreach i of varlist MC_* {
local a : variable label `i'
local a: subinstr local a "MC==" ""
label var `i' "`a'"
}




///_______________________________
///
/// PLOT WITH MEAN SCORES (NON NORMALIZED) ///
///_______________________________



reg unw_mean_score_subject_MC MC_*, nocons
estimates store unweighted_MC




reg mean_score_MC_subject $original_no_durable $original_durable, nocons
estimates store weighted_MC

matrix plot = r(table)'
matrix list plot
matrix plotD=plot[1..12,1..9]
matrix plotND=plot[13..25,1..9]

matsort plotD 1 "down"
matrix plotD = plotD'

matsort plotND 1 "down"
matrix plotND = plotND'

matrix combined = plotND , plotD




      coefplot  (matrix(combined[1,]),  ci(  (combined[5,] combined[6,])  ))    ///  
	  ///
  (unweighted_MC ) ///\ ///
 || ///
 ,    ///
 headings(   ///
MC_15= "{bf: Original Classification - Non-durable}"  ///
MC_8= "{bf: Original Classification - Durable}"  ///
) ///
 title("Merchant Codes' Durability Scores" ) ///
   xtitle(Durability Scores)  ///sort ///sort(3) ///
      p1(label(Weighted Scores) )       ///
    p2(label(Unweighted Scores)  ) ///
	scheme(plotplain) ///
 xlabel(1 (1) 7) plotregion(margin(zero)) /// 
xline(3.109477, lcolor(red) ) drop(MC_25)  // line for median from average scores

cd "$location_cleaned_data"
graph export "Figure G_3 Average durability scores for each merchant code computed within subject.pdf",as(pdf) replace

