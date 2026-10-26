cd "/Users/shermangoh/Desktop/EC3304/2627/Project" 
log using "ec3304_log.log", replace text
use pollution_mig_data.dta

*(a, full sample OLS)
reg migrant lnpm25 female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist, r

*(a, high skilled OLS)
reg migrant lnpm25 female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==1,r

*(a, low skilled OLS)
reg migrant lnpm25 female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==0,r

*(b, full sample 2SLS, IV, no controls)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist, r first
estat firststage

*(b, high skilled 2SLS, IV, no controls)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==1, r first
estat firststage

*(b, low skilled 2SLS, IV, no controls)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==1, r first
estat firststage

*(c, first stage regression, IV, ave_temp control)
reg lnpm25 thermalnum female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp, r

*(c, full sample 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp, r first
estat firststage

*(c, high skilled 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist avtemp if edu_high==1, r first
estat firststage

*(c, low skilled 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist avtemp if edu_high==0, r first
estat firststage

*(d, above 35 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if age>35, r first
estat firststage

*(d, less than or equal to 35 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if age<=35, r first
estat firststage

*(d, married 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if married == 1, r first
estat firststage

*(d, unmarried 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if married == 1, r first
estat firststage

*(d, urban 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married edu_high lntj_dist lnsh_dist lnsz_dist avtemp if urban==1, r first
estat firststage

*(d, rural 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married edu_high lntj_dist lnsh_dist lnsz_dist avtemp if urban==1, r first
estat firststage

log close
