

********************************************************************************
** ASSORTATIVE MATING: DESCRIPTIVE STATISTICS
* --> TABLE S1
********************************************************************************


*--------------- JOINTLY FOR MALES AND FEMALES ----------------------------*

* Retaining one observation per unique male-female pair

use $asa/data/am_step02_male.dta, clear 
append using $asa/data/am_step02_female.dta

rename prim_partner primp
rename totr_p trp


foreach p in primp trp {
	preserve
	
	egen pair_`p'0=group(pnr `p')
	egen pair_`p'1=group(`p' pnr)
	
	egen mpair_`p'=rowmax(pair_`p'0 pair_`p'1)
	
	bysort mpair_`p': gen r=runiform()
	bysort mpair_`p' (r): keep if _n==1
	
	save $asa/data/am_`p'.dta, replace
	
	restore
	
}
	

* ------------------------ TABLE ----------------------------------*

local c=0

estimates clear

foreach p in primp trp {
	local c=`c'+1
	
use $asa/data/am_`p'.dta, clear


drop foed_dag

if `c'==1 {
* primary partner
	preserve 
	keep primp
	drop if primp==.
	rename primp pnr
	gen cohort_primp=.
	gen male_primp=.
	gen female_primp=.
	duplicates drop
	forvalues t=1986/2018 {
		merge 1:1 pnr using $dd100/bef`t'.dta, nogen keep(master matched) keepusing(foed_dag`t' koen`t')
		replace cohort_primp=year(foed_dag`t') if cohort_primp==.
		replace male_primp=koen`t'==1 & koen`t'!=.
		replace female_primp=koen`t'==2 & koen`t'!=.
		drop foed_dag*
	}
	rename pnr primp
	save $asa/data/cohort_primp.dta, replace
	restore
}

if `c'==2 {
* random partner
	preserve 
	keep trp
	drop if trp==.
	rename trp pnr
	gen cohort_trp=.
	gen male_trp=.
	gen female_trp=.
	duplicates drop
	forvalues t=1986/2018 {
		merge 1:1 pnr using $dd100/bef`t'.dta, nogen keep(master matched) keepusing(foed_dag`t' koen`t')
		replace cohort_trp=year(foed_dag`t') if cohort_trp==.
		replace male_trp=koen`t'==1	& koen`t'!=.
		replace female_trp=koen`t'==2	& koen`t'!=.
		drop foed_dag*
	}
	rename pnr trp
	save $asa/data/cohort_trp.dta, replace
	restore
}


if `c'==1 merge m:1 primp using $asa/data/cohort_primp.dta, nogen keep(master matched) keepusing(cohort_primp male_primp female_primp)
if `c'==2 merge m:1 trp using $asa/data/cohort_trp.dta, nogen keep(master matched) keepusing(cohort_trp male_trp female_trp)

* Age Jan 1980
gen age1980_focal=1980-cohort-1
if `c'==1 gen age1980_primp=1980-cohort_primp-1
if `c'==2 gen age1980_trp=1980-cohort_trp-1


** DIVIDED INTO MALES AND FEMALE PARTNER
* Males = focal males and partner males
* Females = focal females and partner females
* keep only opposite sex couples



drop if male==1 & female_`p'!=1
drop if female==1 & male_`p'!=1
drop if `p'==.


gen pnr_focal=pnr
gen pnr_primp=primp
gen pnr_trp=trp

gen a1020_focal=inrange(age1980_focal,10,20)
if `c'==1 gen a1020_primp=inrange(age1980_primp,10,20)
if `c'==2 gen a1020_trp=inrange(age1980_trp,10,20)

	foreach v in pnr age1980 any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev a1020 {
		gen `v'_male=.
		replace `v'_male=`v'_focal if male==1
		replace `v'_male=`v'_`p' if male_`p'==1
		gen `v'_female=.
		replace `v'_female=`v'_focal if female==1
		replace `v'_female=`v'_`p' if female_`p'==1
	}	


* Use  indicator for duplicates in pnr: c_male==1 first observation per male
bysort pnr_male (pnr_female): gen c_male=_n
bysort pnr_female (pnr_male): gen c_female=_n



	foreach v in age1980 any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev a1020 {
		gen tab_`v'=.
		replace tab_`v'=`v'_male // Starting with males
	}
	

	label var tab_n_diag "# diagnoses (1970-2018)"
	label var tab_age1980 "Age (January 1980)"
	label var tab_any_diag "Any diagnosis (1970-2018)"
	label var tab_abuse "Substance abuse"
	label var tab_skiz "Skizophrenia"
	label var tab_bipolar "Bipolar"
	label var tab_omood "Other mood"	
	label var tab_neuro "Neurotic"
	label var tab_ocd "OCD"
	label var tab_eat "Eating disorder"
	label var tab_per "Personality"
	label var tab_dev "Developmental"
	label var tab_ext "Externalizing"
	


	* MALE MEASURES
	estpost sum  tab_*, det 
	estimates store male_`p'
	* For unique males	
	estpost sum  tab_* if c_male==1, det 
	estimates store male_`p'_c1	
	


	* FEMALE MEASURES
	foreach v in age1980 any_diag n_diag $diag a1020 {
		replace tab_`v'=`v'_female
	}
	
	estpost sum tab_*, det
	estimates store female_`p'
	* For unique females
	estpost sum tab_* if c_female==1, det	
	estimates store female_`p'_c1

	
}


	*** UNIQUE PAIRS
	* 1 male and 1 female per pair
	esttab *_primp *_trp using $asa/table/am_des01_malefemale.csv, replace ///
	cells("mean(fmt(3)) sd(fmt(3))") ///
	mtitle("Males (primp)" "Females (prim)" "Males (random)" "Females (random)") ///
	keep(tab_age1980 tab_n_diag) label ///
	 nonum 
	
	esttab *_primp *_trp using $asa/table/am_des01_malefemale.csv, append ///
	cells("sum(fmt(0)) mean(fmt(3))") keep(tab_any_diag *abuse *ext *neuro *omood *eat *skiz *bipolar *ocd *per *dev) label ///
	nomtitle nonum 
	
	
	 
	*** FOR UNIQUE MALES/FEMALES ONLY
	* --> TABLE S1
	
	esttab *_primp_c1 *_trp_c1 using $asa/table/am_des01_malefemale_unique.csv, replace ///
	cells("mean(fmt(3)) sd(fmt(3))") ///
	mtitle("Males (primp)" "Females (prim)" "Males (random)" "Females (random)") ///
	keep(tab_age1980 tab_n_diag) label ///
	 nonum 
	
	esttab *_primp_c1 *_trp_c1 using $asa/table/am_des01_malefemale_unique.csv, append ///
	cells("sum(fmt(0)) mean(fmt(3))") keep(tab_any_diag *abuse *ext *neuro *omood *eat *skiz *bipolar *ocd *per *dev) label ///
	nomtitle nonum 
	
	
	 