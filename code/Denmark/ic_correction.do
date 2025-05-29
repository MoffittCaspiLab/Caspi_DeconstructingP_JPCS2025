
************************************************
** CORRECTION ESTIMATES
* Missed parenta diagnosis due to censoring
*************************************************


use $asa/data/ic_step02.dta, clear

sum cohort_dad if cohort_dad<1970, det
sum cohort_mom if cohort_mom<1970, det


*------------------- WORKING OF ASSORTATIVE MATING DATA -----------------------*
* BIRTH COHORT 1970 (OBSERVED ENTIRE LIFE-TIME)


local c=0
foreach g in male female {
	local c=`c'+1
	
	if `c'==1 local p far
	if `c'==2 local p mor	

	if `c'==1 local pp dad
	if `c'==2 local pp mom


	use $temp/am_step01_`g'.dta, clear


	** Only cohort observed all life
	keep if cohort==1970


	** Identify parents
	rename pnr `p'_id
	gen is_`pp'=0
	forvalues y=1986/2018 {
		merge 1:m `p'_id using $dd100/bef`y'.dta, nogen keep(master matched) keepusing(pnr)
		replace is_`pp'=1 if pnr!=.
		drop pnr 
		duplicates drop
	}
	
	** Only parents (keeping only parents from the 1970 cohort)
	keep if is_`pp'==1
	rename `p'_id pnr

	** Merge yearly life-time diagnosis
	preserve
	use $asa/data/pcr_icd8.dta, clear
	append using $asa/data/pcr_icd10.dta
	destring pnr, replace
	rename y_in ind_year
	append using $asa/data/lps_diagnosis.dta
	tempfile diagnosis
	save `diagnosis'

	restore

	merge 1:m pnr using `diagnosis', keep(master matched)
	bysort pnr: gen m=_merge==3 if _n==1
	sum m



	** Share diagnosed only before / only after / both - age 9, 15 and age 25

	gen age=ind_year-1970
	bysort pnr (age): egen min_diag=min(age)
	bysort pnr (age): egen max_diag=max(age)

	foreach a in 9 15 25 35 {
	gen diag`a'before=min_diag<`a' & max_diag<`a'
	gen diag`a'after=min_diag>=`a' & max_diag!=.
	gen diag`a'both=min_diag<`a' & max_diag>=`a' & max_diag!=.
	gen tjek`a'=diag`a'before+diag`a'after+diag`a'both
	tab tjek`a'
	}


	foreach v in $diag {
		bysort pnr `v' (age): egen hmin`v'=min(age) if `v'==1
		bysort pnr `v' (age): egen hmax`v'=max(age) if `v'==1	
		bysort pnr (age): egen min_`v'=min(hmin`v')
		bysort pnr (age): egen max_`v'=max(hmax`v') 
		bysort pnr: egen m`v'=max(`v')
		replace `v'=m`v'
		replace `v'=0 if `v'==.

		foreach a in 9 15 25 35 {
		gen `v'`a'before=min_`v'<`a' & max_`v'<`a'
		gen `v'`a'after=min_`v'>=`a' & max_`v'!=.
		gen `v'`a'both=min_`v'<`a' & max_`v'>=`a' & max_`v'!=.

	}
		drop m`v'
		
	}

	drop ind_year icd tjek* age m _merge hmin* hmax*
	duplicates drop
	count
	codebook pnr

	bysort pnr: gen N=_N



	save $temp/ic_correction_`pp'.dta, replace

}

*-------------------------- TABLES -------------------------------------------*

foreach p in dad mom  {

use $temp/ic_correction_`p'.dta, clear


foreach d in diag $diag {
	gen tab_`d'=.
}

	label var tab_diag "Any diagnosis"
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

foreach a in 9 15 25 35 {
	foreach v in before after both {
	foreach d in diag $diag {
	replace tab_`d'=`d'`a'`v'
	}
	local tab_diag tab_abuse tab_skiz tab_bipolar tab_omood tab_neuro ///
	tab_ocd tab_eat tab_per tab_dev tab_ext
	estpost sum tab_*
	estimates store m`a'`v'
}
}

sum abuse-ext
egen diag=rowmax(abuse-ext)
replace diag=0 if diag==.
foreach d in diag $diag {
	replace tab_`d'=`d'
	replace tab_`d'=0 if `d'==.
	}
	local tab_diag tab_abuse tab_skiz tab_bipolar tab_omood tab_neuro ///
	tab_ocd tab_eat tab_per tab_dev tab_ext
	estpost sum tab_*
	estimates store m_any

esttab m9* m15* m25* m35* m_any using $asa/table/ic_correction_`p'.csv, replace cells(mean(fmt(4))) ///
mtitle("Before 9 only" "After 9 only" "Both" "Before 15 only" "After 15 only" "Both" ///
"Before 25 only" "After 25 only" "Both" "Before 35 only" "After 35 only" "Both" "Ever") label

*** Share of diagnosed

foreach a in 9 15 25 35 {
	foreach v in before after both {
	foreach d in diag $diag {
	replace tab_`d'=`d'`a'`v'
	replace tab_`d'=. if `d'==0 // conditioning on being diagnosed at some point
	}
	local tab_diag tab_abuse tab_skiz tab_bipolar tab_omood tab_neuro ///
	tab_ocd tab_eat tab_per tab_dev tab_ext
	estpost sum tab_*
	estimates store m`a'`v'
}
}


foreach d in diag $diag {
	replace tab_`d'=`d'
	replace tab_`d'=. if `d'==0
	}
	local tab_diag tab_abuse tab_skiz tab_bipolar tab_omood tab_neuro ///
	tab_ocd tab_eat tab_per tab_dev tab_ext
	estpost sum tab_*
	estimates store m_any

esttab m9* m15* m25* m35* m_any using $asa/table/ic_correction_`p'_diagnosed.csv, replace cells("mean(fmt(4)pattern(1 1 1 1 1 1 1 1 1 1 1 1 0))" "count(pattern(0 0 0 0 0 0 0 0 0 0 0 0 1))") ///
mtitle("Before 9 only" "After 9 only" "Both" "Before 15 only" "After 15 only" "Both" ///
"Before 25 only" "After 25 only" "Both" "Before 35 only" "After 35 only" "Both" "Ever") label noobs

}
