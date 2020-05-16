
rm(list = ls(all=TRUE))
library(data.table)
wd <- as.character("C:/credit_card/")
setwd(wd)
memory.limit(size=10000)
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
# Dates
#_______________________________________________

data[, Cycle:=paste(as.character(CyclePeriod),"01", sep="")]
data[, Cycle:=as.Date(Cycle, "%Y%m%d")]
data[, year:=year(Cycle)]
data[, .(AccountNumber, CyclePeriod, Cycle, year)]
data[, OpenDate:=as.Date(OpenDate, "%Y-%m-%d")]

#_______________________________________________
#
# Exclude accounts with multiple opendata
#_______________________________________________

data[,num_opendate:=length(unique(.SD[,OpenDate])), by=AccountNumber]
ex.ac <- unique(data[num_opendate>1, AccountNumber])
data <- data[!which(AccountNumber %in% ex.ac)]

#_______________________________________________
#
# Amount pay
#_______________________________________________

data[, amt_pay:=amt_pay_non_DD + amt_pay_DD]
data[, lag_amt_pay_non_DD:=c(.SD[2:nrow(.SD) ,amt_pay_non_DD], "NA"), by=AccountNumber] 
data[, lag_amt_pay_DD:=c(.SD[2:nrow(.SD) ,amt_pay_DD], "NA"), by=AccountNumber] 
data[, lag_amt_pay_non_DD:=as.numeric(lag_amt_pay_non_DD)]
data[, lag_amt_pay_DD:=as.numeric(lag_amt_pay_DD)]
data[, lag_amt_pay:=lag_amt_pay_non_DD + lag_amt_pay_DD]

#_______________________________________________
#
# Exclude the repetition problem (some accounts have repeated rows with repeated end dates)
#_______________________________________________

data[, num_end_days:=length(unique(Cyc_Xxx_CycleEndDate)), by=AccountNumber]
data[, num_cycles:=nrow(.SD), by=AccountNumber]
inc_ac <- unique(data[num_end_days==num_cycles, AccountNumber])
length(inc_ac)   #313948

data <- data[AccountNumber %in% inc_ac]

#_______________________________________________
#
# Exclude missing minimum account
#_______________________________________________

ex.ac <- unique(data[bal>0 & min<=0, AccountNumber])
data <- data[!which(AccountNumber %in% ex.ac)]

#_______________________________________________
#
# Exclude accounts who ever had min greater than balance with positive balance
#_______________________________________________

ex.ac <- unique(data[bal>0 & bal<min, AccountNumber])
data <- data[!which(AccountNumber %in% ex.ac)]

#_______________________________________________
#
# Exclude accounts closed or charged-off	 
#_______________________________________________

ex.ac <- unique(data[Status=="Closed" |  Status=="Charged-off" | cl==0, AccountNumber])
data <- data[!AccountNumber %in% ex.ac]

#_______________________________________________
#
# Exclude accounts with trancated transaction data without Closed status
# (so we exclude accounts with empty repayment on a day different than 2014M12, 
# i.e, those accounts that do not have data until the last month in the data period)
#_______________________________________________

dd <- data[is.na(lag_amt_pay), .(AccountNumber, Cycle, bal)]
ex.ac <- unique(dd[Cycle!="2014-12-01", AccountNumber])
data <- data[!which(AccountNumber %in% ex.ac)]

#_______________________________________________
#
# new_ac dummy
#----------------------
data[,new_ac:=ifelse(OpenDate>="2013-01-01", 1, 0)]
nrow(data[new_ac==1])

#_______________________________________________
#
# Total purchase
#_______________________________________________

data[,amt_purchase:=
  amt_mcc0+amt_mcc1+amt_mcc2+amt_mcc3+amt_mcc4+amt_mcc5+amt_mcc6+amt_mcc7+amt_mcc8+amt_mcc9+
  amt_mcc10+amt_mcc11+amt_mcc12+amt_mcc13+amt_mcc14+amt_mcc15+amt_mcc16+amt_mcc17+amt_mcc18+amt_mcc19+
  amt_mcc20+amt_mcc21+amt_mcc22+amt_mcc23+amt_mcc24+amt_mcc25+amt_mcc26+amt_mcc27]

#_______________________________________________
#
# Exclude accounts with balance transfer 
#_______________________________________________

data[,theo_bal:=beg + amt_purchase+
              amt_fc_purchase + amt_blank + amt_fee_overlim + 
              amt_fee_late + amt_fee_forecur + 
              amt_fc_ca + amt_ca + amt_fee_ca + amt_fc_btcc + amt_fee_btcc + 
              amt_fee_NFS + amt_fee_others + amt_fee_ma + amt_pay]

ex.ac1 <- unique(data[abs(bal-theo_bal)>=10, AccountNumber])

# Accounts with blank transactions 
ex.ac2 <- unique(data[amt_blank!=0, AccountNumber])

ex.ac <- unique(c(ex.ac1, ex.ac2))

data[,BT_ac:=ifelse(AccountNumber %in% ex.ac, 1, 0)]
data[,theo_bal:=NULL]
data <- data[BT_ac==0]


#_______________________________________________
#
# Accounts who ever had zero mer_APR
#_______________________________________________
zero.apr <- unique(data[mer_APR==0, AccountNumber])
data[,zero_APR_ac:=ifelse(AccountNumber %in% zero.apr, 1, 0)]

length(unique(data[new_ac==1 & zero_APR_ac==1, AccountNumber])) #186819


#_______________________________________________
#
# Cycle month number 
#_______________________________________________

data <- data[order(AccountNumber, CyclePeriod)]
data[, month:=seq(1, nrow(.SD), by=1), by=AccountNumber]

#_______________________________________________
#
# Exclude last month for each account
#_______________________________________________

unique(data[num_cycles==month, lag_amt_pay])   
nrow(data[num_cycles!=month & is.na(amt_pay)]) 
data <- data[!is.na(lag_amt_pay)]

#_______________________________________________
#
# Exclude new accounts with (1st cycle-OpenDate)>30
# (i.e., excluding accounts for which we do not observe the first months of transactions)
#_______________________________________________

data[,OpenDate:=as.Date(OpenDate, "%Y-%m-%d")]
data[,Cycle:=as.Date(Cycle, "%Y-%m-%d")]
dat <- data[month==1]
dat[,diff_open_cycle:=Cycle-OpenDate]
ex.ac <- dat[new_ac==1 & diff_open_cycle>30, AccountNumber] 
data <- data[!AccountNumber %in% ex.ac]


#_______________________________________________
#
# Purchase category
#_______________________________________________

data[,num_purchase:=num_mcc0 + num_mcc1 + num_mcc2 + num_mcc3 + num_mcc4 + num_mcc5 + num_mcc6 + num_mcc7 + num_mcc8 + num_mcc9 + num_mcc10 +
num_mcc11 + num_mcc12 + num_mcc13 + num_mcc14 + num_mcc15 + num_mcc16 + num_mcc17 + num_mcc18 + num_mcc19 + num_mcc20 + 
num_mcc21 + num_mcc22 + num_mcc23 + num_mcc24 + num_mcc25 + num_mcc26 + num_mcc27]
data[,purchase_category:=ifelse(amt_purchase<=0, 200, 
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc0, 0, 
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc1, 1,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc2, 2,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc3, 3,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc4, 4,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc5, 5,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc6, 6,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc7, 7,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc8, 8,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc9, 9,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc10, 10,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc11, 11,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc12, 12,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc13, 13,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc14, 14,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc15, 15,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc16, 16,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc17, 17,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc18, 18,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc19, 19,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc20, 20, 
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc21, 21,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc22, 22,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc23, 23,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc24, 24,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc25, 25,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc26, 26,
                         ifelse(amt_purchase>0 & amt_purchase==amt_mcc27, 27, 100)))))))))))))))))))))))))))))]
data <- data[purchase_category!=200] #200 is no purchase
data[,num_cate:=ifelse(purchase_category==0, num_mcc0,
                ifelse(purchase_category==1, num_mcc1, 
                ifelse(purchase_category==2, num_mcc2, 
                ifelse(purchase_category==3, num_mcc3, 
                ifelse(purchase_category==4, num_mcc4, 
                ifelse(purchase_category==5, num_mcc5, 
                ifelse(purchase_category==6, num_mcc6, 
                ifelse(purchase_category==7, num_mcc7, 
                ifelse(purchase_category==8, num_mcc8, 
                ifelse(purchase_category==9, num_mcc9, 
                ifelse(purchase_category==10, num_mcc10, 
                ifelse(purchase_category==11, num_mcc11, 
                ifelse(purchase_category==12, num_mcc12, 
                ifelse(purchase_category==13, num_mcc13, 
                ifelse(purchase_category==14, num_mcc14, 
                ifelse(purchase_category==15, num_mcc15, 
                ifelse(purchase_category==16, num_mcc16, 
                ifelse(purchase_category==17, num_mcc17, 
                ifelse(purchase_category==18, num_mcc18, 
                ifelse(purchase_category==19, num_mcc19, 
                ifelse(purchase_category==20, num_mcc20, 
                ifelse(purchase_category==21, num_mcc21, 
                ifelse(purchase_category==22, num_mcc22, 
                ifelse(purchase_category==23, num_mcc23, 
                ifelse(purchase_category==24, num_mcc24, 
                ifelse(purchase_category==25, num_mcc25, 
                ifelse(purchase_category==26, num_mcc26, 
                ifelse(purchase_category==27, num_mcc27, 
                ifelse(purchase_category==100, num_purchase, NA)))))))))))))))))))))))))))))]
data <- data[num_cate==num_purchase]


#_______________________________________________
#
# Purchase category
#_______________________________________________

data[, cate:=
ifelse(purchase_category==0, "N/A",
ifelse(purchase_category==1, "Airlines",
ifelse(purchase_category==2, "Auto Rental",
ifelse(purchase_category==3, "Hotel/Motel",
ifelse(purchase_category==4,  "Restaurants/Bars",
ifelse(purchase_category==5, "Travel Agencies",
ifelse(purchase_category==6, "Other Transportation",
ifelse(purchase_category==7, "Department Stores",
ifelse(purchase_category==8, "Discount Stores",
ifelse(purchase_category==9, "Clothing Stores",
ifelse(purchase_category==10, "Hardware Stores",
ifelse(purchase_category==11, "Drug Stores",
ifelse(purchase_category==12, "Gas Stations",
ifelse(purchase_category==13, "Mail Orders",
ifelse(purchase_category==14, "Food Stores",
ifelse(purchase_category==15, "Vehicles",
ifelse(purchase_category==16, "Interior Furnishing Stores",
ifelse(purchase_category==17, "Electric Appliance Stores",
ifelse(purchase_category==18, "Sporting Goods/Toy Stores",
ifelse(purchase_category==19, "Other Retail",
ifelse(purchase_category==20, "Health Care",
ifelse(purchase_category==21, "Recreation",
ifelse(purchase_category==22, "Education",
ifelse(purchase_category==23, "Utilities",
ifelse(purchase_category==24, "Professional Services",
ifelse(purchase_category==25, "Repair Shops",
ifelse(purchase_category==26, "Other Services", 
ifelse(purchase_category==27, "Quasi Cash", 
ifelse(purchase_category==100,"Mix", 
NA)))))))))) )))))))))) )))))))))]
data[,purchase_category_name:=as.factor(cate)]
data[,purchase_category_name:=relevel(purchase_category_name, ref="Airlines")]


#_______________________________________________
#
# Non-DD observations
#_______________________________________________

data[,DD_flag:=ifelse(lag_amt_pay_DD<0, 1, 0)]
data <- data[DD_flag==0]

#_______________________________________________
#
# Beginning balance 0, purchase amount>5, and positive balance
#_______________________________________________

data <- data[beg==0 & amt_ca==0 & lag_amt_pay<=0 & amt_purchase>5 & bal>0 & min>0]

#_______________________________________________
#
# Utilisation
#_______________________________________________

data[, utilisation:=bal/cl]

#_______________________________________________
#
# Repayment_purchase ratio
#_______________________________________________

data[,RP_ratio:=(-lag_amt_pay)/amt_purchase] 

#_______________________________________________
#
# Charge-off rate
#_______________________________________________

data[,charge_off_rate:=Cyc_Xxx_UnitChargeOffRate]

#_______________________________________________
#
# Preliminary data cleaned
#_______________________________________________

data <- data[abs(bal-amt_purchase)<.001] 
data[,obs_month:=month]

d <- data[,.(AccountNumber, CustomerNumber, obs_month, OpenDate, mer_APR, cash_APR, charge_off_rate, utilisation, cl, beg, bal, min, amt_purchase, num_purchase, 
                lag_amt_pay, purchase_category, purchase_category_name, 
                RP_ratio, CyclePeriod, new_ac, zero_APR_ac, 
                amt_mcc0, amt_mcc1, amt_mcc2, amt_mcc3, amt_mcc4, amt_mcc5, amt_mcc6, amt_mcc7, amt_mcc8, amt_mcc9,    
                amt_mcc10, amt_mcc11, amt_mcc12, amt_mcc13, amt_mcc14, amt_mcc15, amt_mcc16, amt_mcc17, amt_mcc18, amt_mcc19,    
                amt_mcc20, amt_mcc21, amt_mcc22, amt_mcc23, amt_mcc24, amt_mcc25, amt_mcc26, amt_mcc27,    
                num_mcc0, num_mcc1, num_mcc2, num_mcc3, num_mcc4, num_mcc5, num_mcc6, num_mcc7, num_mcc8, num_mcc9,    
                num_mcc10, num_mcc11, num_mcc12, num_mcc13, num_mcc14, num_mcc15, num_mcc16, num_mcc17, num_mcc18, num_mcc19,    
                num_mcc20, num_mcc21, num_mcc22, num_mcc23, num_mcc24, num_mcc25, num_mcc26, num_mcc27)]    



output_file <- file.path(wd, "data_for_mental_accounting_20170530.csv")
write.table(d, file=output_file, sep=',', row.names=F, col.names=T)




