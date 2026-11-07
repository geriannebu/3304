* EC3304 Research Assignment 

clear all
capture log close
cd "/Users/geriannebu/Library/Mobile Documents/com~apple~CloudDocs/Y4S1/EC3304/Stata"
log using "EC3304_results.log", replace text
use pollution_mig_data.dta, clear

* Defining controls
global X     "female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist"
global Xskill "female age agesq married urban lntj_dist lnsh_dist lnsz_dist"

summarize


* (a) OLS 
eststo clear
eststo: reg migrant lnpm25 $X, r
eststo: reg migrant lnpm25 $Xskill if edu_high==1, r
eststo: reg migrant lnpm25 $Xskill if edu_high==0, r
esttab using "Table_a.rtf", replace se b(4) r2 mtitles("Full" "High-skilled" "Low-skilled")


* (b) 2SLS, IV (thermal inversions) 
eststo clear
eststo: ivregress 2sls migrant $X (lnpm25 = thermalnum), r first
estat firststage
eststo: ivregress 2sls migrant $Xskill (lnpm25 = thermalnum) if edu_high==1, r first
estat firststage
eststo: ivregress 2sls migrant $Xskill (lnpm25 = thermalnum) if edu_high==0, r first
estat firststage
esttab using "Table_b.rtf", replace se b(4) mtitles("Full" "High-skilled" "Low-skilled")


* (c) 2SLS, controlling for ave_temp
eststo clear
eststo: ivregress 2sls migrant $X avtemp (lnpm25 = thermalnum), r first
estat firststage
eststo: ivregress 2sls migrant $Xskill avtemp (lnpm25 = thermalnum) if edu_high==1, r first
estat firststage
eststo: ivregress 2sls migrant $Xskill avtemp (lnpm25 = thermalnum) if edu_high==0, r first
estat firststage
esttab using "Table_c.rtf", replace se b(4) mtitles("Full" "High-skilled" "Low-skilled")


* (d) Heterogeneity, 2SLS with ave_temp 
eststo clear
* (d1) age
eststo: ivregress 2sls migrant $X avtemp (lnpm25 = thermalnum) if age<=35, r first
eststo: ivregress 2sls migrant $X avtemp (lnpm25 = thermalnum) if age>35, r first
* (d2) marital status (married dropped from controls)
eststo: ivregress 2sls migrant female age agesq urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp (lnpm25 = thermalnum) if married==1, r first
eststo: ivregress 2sls migrant female age agesq urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp (lnpm25 = thermalnum) if married==0, r first
* (d3) urban vs rural born (urban dropped from controls)
eststo: ivregress 2sls migrant female age agesq married edu_high lntj_dist lnsh_dist lnsz_dist avtemp (lnpm25 = thermalnum) if urban==1, r first
eststo: ivregress 2sls migrant female age agesq married edu_high lntj_dist lnsh_dist lnsz_dist avtemp (lnpm25 = thermalnum) if urban==0, r first
esttab using "Table_d.rtf", replace se b(4) keep(lnpm25) ///
    mtitles("Age<=35" "Age>35" "Married" "Unmarried" "Urban" "Rural")

log close
