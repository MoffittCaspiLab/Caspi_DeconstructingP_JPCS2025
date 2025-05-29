
*******************************************************************************
* STEP02: MERGE DIAGNOSIS INFORMATION TO STUDY POPULATION
*******************************************************************************


** CONDENSING DIAGNOSIS DATA FURTHER

use $asa/data/pcr_icd8.dta, clear
append using $asa/data/pcr_icd10.dta
destring pnr, replace
rename y_in ind_year
append using $asa/data/lps_diagnosis.dta

* Binary measures=1 if ever diagnosed with that type of diagnosis
foreach v in $diag {
	bysort pnr: egen h=max(`v')
	replace `v'=h
	drop h
}
drop icd ind_year
duplicates drop

drop if pnr==.

save $asa/data/diagnosis.dta, replace

*------------------MERGING DIAGNOSIS TO STUDY POPULATION ----------------------*

foreach g in male female {

use $temp/am_step01_`g'.dta, clear

merge 1:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched)

** Counting number of diagnoses-types
gen n_diag_focal=0
gen any_diag_focal=0
foreach v in $diag {
	gen `v'_focal=`v'
	replace `v'_focal=0 if `v'==.
	replace n_diag_focal=n_diag_focal+1 if `v'==1
	replace any_diag_focal=1 if `v'==1
}
drop $diag

sum *_focal

*------------------MERGING DIAGNOSIS TO EACH PARTNER ----------------------*

sum n_partners
local max=r(max)

rename pnr focal
forvalues n=1/`max' {
	
	rename partner`n' pnr
	
	* Adding cohort info
	merge m:1 pnr using $dd100/bef2018.dta, nogen keep(master matched) ///
	keepusing(foed_dag)
	
	gen cohort_p`n'=.
	replace cohort_p`n'=year(foed_dag) if pnr!=.
	
	* Adding diagnosis info
	merge m:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched) ///
	keepusing($diag)
	
	** Counting number of diagnosis
	gen n_diag_p`n'=0 if pnr!=.
	gen any_diag_p`n'=0 if pnr!=.
	
	foreach v in $diag {
		gen `v'_p`n'=`v'
		replace `v'_p`n'=0 if `v'==. & pnr!=.
		replace n_diag_p`n'=n_diag_p`n'+1 if `v'==1
		replace any_diag_p`n'=1 if `v'==1
		
	}
	rename pnr partner`n'
	
	drop $diag
	
	sum *_p`n'
}
 
** Primary partner
 
rename prim_partner pnr

	merge m:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched)
	** Counting number of diagnosis
	gen n_diag_primp=0 if pnr!=.
	gen any_diag_primp=0 if pnr!=.
	
	foreach v in $diag {
		gen `v'_primp=`v'
		replace `v'_primp=0 if `v'==. & pnr!=.
		replace n_diag_primp=n_diag_primp+1 if `v'==1
		replace any_diag_primp=1 if `v'==1
		
	}
	rename pnr prim_partner
	
	drop $diag

** Randomly chosen partner (among focal individuals actual partners)

rename r_partner pnr

	merge m:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched)
	** Counting number of diagnosis
	gen n_diag_rp=0 if pnr!=.
	gen any_diag_rp=0 if pnr!=.
	
	foreach v in $diag {
		gen `v'_rp=`v'
		replace `v'_rp=0 if `v'==. & pnr!=.
		replace n_diag_rp=n_diag_rp+1 if `v'==1
		replace any_diag_rp=1 if `v'==1
		
	}
	rename pnr r_partner
	
	drop $diag


** Totally random partner
* (among those partners of those from the same cohort)

rename totr_p pnr

	merge m:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched)
	** Counting number of diagnosis
	gen n_diag_trp=0 if pnr!=.
	gen any_diag_trp=0 if pnr!=.
	
	foreach v in $diag {
		gen `v'_trp=`v'
		replace `v'_trp=0 if `v'==. & pnr!=.
		replace n_diag_trp=n_diag_trp+1 if `v'==1
		replace any_diag_trp=1 if `v'==1
		
	}
	rename pnr totr_p
	
	drop $diag
	
	
rename focal pnr


save $asa/data/am_step02_`g'.dta, replace


* ------------------------ LONG FORMAT -------------------------------------*


reshape long partner n_diag_p any_diag_p abuse_p skiz_p bipolar_p omood_p neuro_p ///
ocd_p eat_p per_p dev_p ext_p, i(pnr) j(n)

drop if partner==. & n>1

save $asa/data/am_step02_long_`g'.dta, replace


}
