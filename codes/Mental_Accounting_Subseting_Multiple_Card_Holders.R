
#__________________________________________________________________________________________
#
# APPENDIX F: SUBSETING THE DATA USED IN THE MAIN ANALYSIS TO THOSE CARD HOLDERS WITH MULTILE CARDS
#
#__________________________________________________________________________________________



rm(list = ls(all=TRUE))
library(data.table)
wd <- as.character("C:/credit_card/encripted")
setwd(wd)
memory.limit(size=1000000)
memory.limit()

data <- fread("complete_20160408.csv")


data[, Cyc_Xxx_PaymentMinimumDueAmount:=as.numeric(Cyc_Xxx_PaymentMinimumDueAmount)]
data[, Cyc_Xxx_BalanceBeginning:=as.numeric(Cyc_Xxx_BalanceBeginning)]
data[, Cyc_Xxx_BalanceEnding:=as.numeric(Cyc_Xxx_BalanceEnding)]
data[, Cyc_Xxx_CreditLimitTotal:=as.numeric(Cyc_Xxx_CreditLimitTotal)]
data[, Cyc_Xxx_AprMerchant:=as.numeric(Cyc_Xxx_AprMerchant)] 
data[, Cyc_Xxx_AprCash:=as.numeric(Cyc_Xxx_AprCash)]
data[, Cyc_Xxx_BalanceAdb:=as.numeric(Cyc_Xxx_BalanceAdb)]
data[, Cyc_Xxx_BalanceRevolving:=as.numeric(Cyc_Xxx_BalanceRevolving)]
data[, beg:=Cyc_Xxx_BalanceBeginning]
data[, bal:=Cyc_Xxx_BalanceEnding]
data[, min:=Cyc_Xxx_PaymentMinimumDueAmount]
data[, cl:=Cyc_Xxx_CreditLimitTotal]
data[, mer_APR:=Cyc_Xxx_AprMerchant]
data[, cash_APR:=Cyc_Xxx_AprCash]
data[, adb:=Cyc_Xxx_BalanceAdb]
data[, rev:=Cyc_Xxx_BalanceRevolving]
data[, Cyc_Xxx_PaymentMinimumDueAmount:=NULL]
data[, Cyc_Xxx_BalanceBeginning:=NULL]
data[, Cyc_Xxx_BalanceEnding:=NULL]
data[, Cyc_Xxx_CreditLimitTotal:=NULL]
data[, Cyc_Xxx_AprMerchant:=NULL] 
data[, Cyc_Xxx_AprCash:=NULL]
data[, Cyc_Xxx_BalanceAdb:=NULL]
data[, Cyc_Xxx_BalanceRevolving:=NULL]


#_______________________________________________
#
# Reading data with [Custmer x Accounts x Months] used in the main analysis of the paper 
#_______________________________________________
(customer_subset_used <- fread("acc.csv"))

inc_customer <- unique(customer_subset_used[, customernumber])
length(inc_customer)   

str(data$CustomerNumber)
data_subset_used <- data[CustomerNumber %in% inc_customer]


data<- NULL


#_______________________________________________
#
# Dates
#_______________________________________________

data_subset_used[, Cycle:=paste(as.character(CyclePeriod),"01", sep="")]
data_subset_used[, Cycle:=as.Date(Cycle, "%Y%m%d")]
data_subset_used[, year:=year(Cycle)]
data_subset_used[, .(AccountNumber, CyclePeriod, Cycle, year)]
data_subset_used[, OpenDate:=as.Date(OpenDate, "%Y-%m-%d")]


#________________________________________________
# 
# Computing the number of cards with positive balance  held by cardholder/customer,
# total balance in other cards
# dummies for each card holding the max or min balance
# dummies for each card holding the max or min utilisation
#________________________________________________


data_subset_used[, utilisation:=bal/cl]




data_subset_used[ bal>5 & is.finite(utilisation), number_cards_bal_pos:=length(unique(.SD[,AccountNumber])), by=.(CustomerNumber,  Cycle)]
data_subset_used[, number_other_cards_bal_pos:=number_cards_bal_pos-1]
data_subset_used[bal>5 & number_other_cards_bal_pos>=1 & is.finite(utilisation), dummy_multiple_cards:=1]

data_subset_used[ dummy_multiple_cards==1 ,total_balance:=sum(bal), by=.(CustomerNumber, Cycle)]
data_subset_used[ dummy_multiple_cards==1, total_balance_other:=total_balance-bal]


data_subset_used[ dummy_multiple_cards==1, max_utilisation:=max(utilisation, na.rm=T), by=.(CustomerNumber, Cycle)]
data_subset_used[ dummy_multiple_cards==1, min_utilisation:=min(utilisation, na.rm=T), by=.(CustomerNumber, Cycle)]
data_subset_used[ dummy_multiple_cards==1, max_bal:=max(bal, na.rm=T), by=.(CustomerNumber, Cycle)]
data_subset_used[ dummy_multiple_cards==1, min_bal:=min(bal, na.rm=T), by=.(CustomerNumber, Cycle)]


data_subset_used[ dummy_multiple_cards==1 & utilisation==max_utilisation, has_max_utilisation:=1]
data_subset_used[ dummy_multiple_cards==1 & utilisation==min_utilisation, has_min_utilisation:=1]
data_subset_used[ dummy_multiple_cards==1 & bal==max_bal, has_max_bal:=1]
data_subset_used[ dummy_multiple_cards==1 & bal==min_bal, has_min_bal:=1]

data_subset_multiple_cards <- data_subset_used[dummy_multiple_cards==1 ,.(dummy_multiple_cards, has_max_bal, has_min_bal, 
                                                                          has_max_utilisation, has_min_utilisation, total_balance_other, 
                                                                          number_cards_bal_pos,  number_other_cards_bal_pos, CustomerNumber, 
                                                                          AccountNumber, CyclePeriod, Cycle, bal    )]    

data_subset_multiple_cards[, master:=1]

##
customer_subset_used[, Cycle:=paste(as.character(cycleperiod),"01", sep="")]
customer_subset_used[, Cycle:=as.Date(Cycle, "%Y%m%d")]

customer_subset_used[,using:=2]
names(customer_subset_used)
names(data_subset_multiple_cards)

setnames(customer_subset_used,"accountnumber","AccountNumber")
setnames(customer_subset_used,"cycleperiod","CyclePeriod")
setnames(customer_subset_used,"customernumber","CustomerNumber")

#________________________________________________
# 
# Subseting the data of cardholders. Selecting the months used in our analysis
#________________________________________________


data_subset_multiple_cards_months_used <- merge(data_subset_multiple_cards, customer_subset_used, 
                                                by=c("CustomerNumber", "AccountNumber"   ,"CyclePeriod"), all=TRUE)


data_subset_multiple_cards_months_used[is.na(master), master:=0]
data_subset_multiple_cards_months_used[is.na(using), using:=0]
table(data_subset_multiple_cards_months_used[,merge:=master+using][,.(merge)])
#1      2      3 
#790493 230210  57183 


data_subset_multiple_cards_months_used  <- data_subset_multiple_cards_months_used[merge==3]

output_file <- file.path("C:/edika/argus20170905", "data_cardholders_multiple_cards_20180426.csv")
write.table(data_subset_multiple_cards_months_used, file=output_file, sep=',', row.names=F, col.names=T)
