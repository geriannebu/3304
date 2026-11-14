cd "/Users/shermangoh/Desktop/EC3304/2627/Project" 
log using "ec3304_log.log", replace text
use pollution_mig_data.dta

*(a, full sample OLS)
reg migrant lnpm25 female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist, vce(cluster City_ID)

*(a, high skilled OLS)
reg migrant lnpm25 female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==1,vce(cluster City_ID)

*(a, low skilled OLS)
reg migrant lnpm25 female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==0,vce(cluster City_ID)

*(b, full sample 2SLS, IV, no avtemp)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist, vce(cluster City_ID) first
estat firststage

*(b, high skilled 2SLS, IV, no avtemp)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==1, vce(cluster City_ID) first
estat firststage

*(b, low skilled 2SLS, IV, no avtemp)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist if edu_high==0, vce(cluster City_ID) first
estat firststage

*(c, first stage regression, IV, ave_temp control)
reg lnpm25 thermalnum female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp, vce(cluster City_ID) first

*(c, full sample 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp, vce(cluster City_ID) first
estat firststage

*(c, high skilled 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist avtemp if edu_high==1, vce(cluster City_ID) first
estat firststage

*(c, low skilled 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban lntj_dist lnsh_dist lnsz_dist avtemp if edu_high==0, vce(cluster City_ID) first
estat firststage

*(d, above 35 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if age>35, vce(cluster City_ID) first
estat firststage

*(d, less than or equal to 35 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if age<=35, vce(cluster City_ID) first
estat firststage

*(d, married 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if married == 1, vce(cluster City_ID) first
estat firststage

*(d, unmarried 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq urban edu_high lntj_dist lnsh_dist lnsz_dist avtemp if married == 0, vce(cluster City_ID) first
estat firststage

*(d, urban 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married edu_high lntj_dist lnsh_dist lnsz_dist avtemp if urban==1, vce(cluster City_ID) first
estat firststage

*(d, rural 2SLS, IV, ave_temp control)
ivregress 2sls migrant (lnpm25= thermalnum)female age agesq married edu_high lntj_dist lnsh_dist lnsz_dist avtemp if urban==0, vce(cluster City_ID) first
estat firststage

log close
