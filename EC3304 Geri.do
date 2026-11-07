*/ EC3304 Research Assignment*/

clear all
set more off
capture log close

cd "/Users/geriannebu/Library/Mobile Documents/com~apple~CloudDocs/Y4S1/EC3304/Stata"

log using "EC3304_geri_results.log"

* Table package (run once)
capture which esttab
if _rc ssc install estout, replace

use "pollution_mig_data.dta", clear

*------------------------------------------------------------------------------
* 0. Setup: control-variable globals and summary statistics
*------------------------------------------------------------------------------
* Individual demographics
global demo   "female age agesq married urban"
* Economic opportunity (distance to the three major seaports)
global ports  "lntj_dist lnsh_dist lnsz_dist"

* Baseline control set (full sample) — includes skill dummy
global X      "$demo edu_high $ports"

* Control set for skill subsamples (edu_high is constant within them)
global Xskill "$demo $ports"

gen young = (age <= 35)
label var young   "Aged 35 or younger"
label var migrant "Migrated out of origin city"
label var lnpm25  "Log PM2.5 (2014)"

summarize migrant lnpm25 thermalnum avtemp female age married urban edu_high $ports
tabstat migrant lnpm25, by(edu_high) stat(mean sd n)

*------------------------------------------------------------------------------
* (a) OLS:  migrant_ic = b0 + b1*lnpm25_c + X_ic'g + u_ic
*------------------------------------------------------------------------------
eststo clear
eststo ols_full: reg migrant lnpm25 $X      , vce(cluster City_ID)
eststo ols_high: reg migrant lnpm25 $Xskill if edu_high==1, vce(cluster City_ID)
eststo ols_low : reg migrant lnpm25 $Xskill if edu_high==0, vce(cluster City_ID)

* Formal test of skill heterogeneity (interaction model)
reg migrant c.lnpm25##i.edu_high $demo $ports, vce(cluster City_ID)
* -> coefficient on 1.edu_high#c.lnpm25 = difference (high - low)

esttab ols_full ols_high ols_low using "Table_a_OLS.rtf", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) b(4) se(4) r2 ///
    mtitles("Full" "High-skilled" "Low-skilled") ///
    title("Table 1: OLS estimates of the effect of PM2.5 on migration") ///
    note("Cluster-robust standard errors (by origin city) in parentheses.")

*------------------------------------------------------------------------------
* (b) 2SLS with thermal inversions as IV for lnpm25
*     1st stage: lnpm25_c   = p0 + p1*thermalnum_c + X_ic'd + v_ic
*     2nd stage: migrant_ic = b0 + b1*lnpm25_hat   + X_ic'g + e_ic
*------------------------------------------------------------------------------
eststo clear
* --- First stages (reported explicitly) ---
eststo fs_full: reg lnpm25 thermalnum $X      , vce(cluster City_ID)
test thermalnum
estadd scalar F_iv = r(F)
eststo fs_high: reg lnpm25 thermalnum $Xskill if edu_high==1, vce(cluster City_ID)
test thermalnum
estadd scalar F_iv = r(F)
eststo fs_low : reg lnpm25 thermalnum $Xskill if edu_high==0, vce(cluster City_ID)
test thermalnum
estadd scalar F_iv = r(F)

* --- Second stages ---
eststo iv_full: ivregress 2sls migrant $X      (lnpm25 = thermalnum), vce(cluster City_ID)
estat firststage
eststo iv_high: ivregress 2sls migrant $Xskill (lnpm25 = thermalnum) if edu_high==1, vce(cluster City_ID)
estat firststage
eststo iv_low : ivregress 2sls migrant $Xskill (lnpm25 = thermalnum) if edu_high==0, vce(cluster City_ID)
estat firststage

esttab fs_full fs_high fs_low using "Table_b_FirstStage.rtf", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) b(4) se(4) scalars("F_iv First-stage F (IV)") ///
    mtitles("Full" "High-skilled" "Low-skilled") ///
    title("Table 2a: First stage — dependent variable lnpm25")
esttab iv_full iv_high iv_low using "Table_b_2SLS.rtf", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) b(4) se(4) ///
    mtitles("Full" "High-skilled" "Low-skilled") ///
    title("Table 2b: 2SLS estimates — IV = number of thermal inversions")

*------------------------------------------------------------------------------
* (c) Exclusion concern: ground temperature may affect migration directly.
*     Fix: control for average ground-level temperature (avtemp) in BOTH stages.
*------------------------------------------------------------------------------
global Xc      "$X avtemp"
global Xcskill "$Xskill avtemp"

eststo clear
eststo fsc_full: reg lnpm25 thermalnum $Xc      , vce(cluster City_ID)
test thermalnum
estadd scalar F_iv = r(F)
eststo fsc_high: reg lnpm25 thermalnum $Xcskill if edu_high==1, vce(cluster City_ID)
test thermalnum
estadd scalar F_iv = r(F)
eststo fsc_low : reg lnpm25 thermalnum $Xcskill if edu_high==0, vce(cluster City_ID)
test thermalnum
estadd scalar F_iv = r(F)

eststo ivc_full: ivregress 2sls migrant $Xc      (lnpm25 = thermalnum), vce(cluster City_ID)
eststo ivc_high: ivregress 2sls migrant $Xcskill (lnpm25 = thermalnum) if edu_high==1, vce(cluster City_ID)
eststo ivc_low : ivregress 2sls migrant $Xcskill (lnpm25 = thermalnum) if edu_high==0, vce(cluster City_ID)

esttab fsc_full fsc_high fsc_low ivc_full ivc_high ivc_low using "Table_c_IV_temp.rtf", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) b(4) se(4) scalars("F_iv First-stage F (IV)") ///
    mgroups("First stage (lnpm25)" "2SLS (migrant)", pattern(1 0 0 1 0 0)) ///
    mtitles("Full" "High" "Low" "Full" "High" "Low") ///
    title("Table 3: IV estimates controlling for ground-level temperature")

*------------------------------------------------------------------------------
* (d) Heterogeneity: sub-sample OLS and 2SLS (using spec from (c), with avtemp)
*------------------------------------------------------------------------------
* (d1) Age: <=35 vs >35  (age, agesq still vary within groups, so kept)
* (d2) Married vs unmarried  -> drop married from controls
* (d3) Urban-born vs rural-born -> drop urban from controls
global Xmar "female age agesq urban   edu_high $ports avtemp"
global Xurb "female age agesq married edu_high $ports avtemp"

eststo clear
* OLS
eststo o_yng: reg migrant lnpm25 $Xc   if young==1  , vce(cluster City_ID)
eststo o_old: reg migrant lnpm25 $Xc   if young==0  , vce(cluster City_ID)
eststo o_mar: reg migrant lnpm25 $Xmar if married==1, vce(cluster City_ID)
eststo o_unm: reg migrant lnpm25 $Xmar if married==0, vce(cluster City_ID)
eststo o_urb: reg migrant lnpm25 $Xurb if urban==1  , vce(cluster City_ID)
eststo o_rur: reg migrant lnpm25 $Xurb if urban==0  , vce(cluster City_ID)
* 2SLS
eststo i_yng: ivregress 2sls migrant $Xc   (lnpm25 = thermalnum) if young==1  , vce(cluster City_ID)
eststo i_old: ivregress 2sls migrant $Xc   (lnpm25 = thermalnum) if young==0  , vce(cluster City_ID)
eststo i_mar: ivregress 2sls migrant $Xmar (lnpm25 = thermalnum) if married==1, vce(cluster City_ID)
eststo i_unm: ivregress 2sls migrant $Xmar (lnpm25 = thermalnum) if married==0, vce(cluster City_ID)
eststo i_urb: ivregress 2sls migrant $Xurb (lnpm25 = thermalnum) if urban==1  , vce(cluster City_ID)
eststo i_rur: ivregress 2sls migrant $Xurb (lnpm25 = thermalnum) if urban==0  , vce(cluster City_ID)

esttab o_yng o_old o_mar o_unm o_urb o_rur using "Table_d_OLS.rtf", replace ///
    keep(lnpm25) se star(* 0.10 ** 0.05 *** 0.01) b(4) se(4) ///
    mtitles("Age<=35" "Age>35" "Married" "Unmarried" "Urban-born" "Rural-born") ///
    title("Table 4a: Heterogeneity — OLS")
esttab i_yng i_old i_mar i_unm i_urb i_rur using "Table_d_2SLS.rtf", replace ///
    keep(lnpm25) se star(* 0.10 ** 0.05 *** 0.01) b(4) se(4) ///
    mtitles("Age<=35" "Age>35" "Married" "Unmarried" "Urban-born" "Rural-born") ///
    title("Table 4b: Heterogeneity — 2SLS (IV = thermal inversions, controls incl. avtemp)")

* Optional: formal tests of group differences via interactions (2SLS)
gen pm_young = lnpm25*young
gen ti_young = thermalnum*young
ivregress 2sls migrant young $Xc (lnpm25 pm_young = thermalnum ti_young), vce(cluster City_ID)
* -> coefficient on pm_young = (young effect - older effect)

log close
