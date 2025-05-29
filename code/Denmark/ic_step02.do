

************************************************************************
** STEP02: MERGE DIAGNOSIS INFORMATION TO STUDY POPULATION
* 
************************************************************************


*------------------MERGING DIAGNOSIS TO STUDY POPULATION ----------------------*


use $temp/ic_step01.dta, clear

merge 1:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched)

** Counting number of diagnosis
gen n_diag_child=0
gen any_diag_child=0
foreach v in $diag {
	gen `v'_child=`v'
	replace `v'_child=0 if `v'==.
	replace n_diag_child=n_diag_child+1 if `v'==1
	replace any_diag_child=1 if `v'==1
}
drop $diag

sum *_child

*------------------MERGING DIAGNOSIS TO EACH PARENT ----------------------*


rename pnr focal
foreach p in mom dad mom_latest dad_latest mom_mfr dad_mfr mom_tr dad_tr  {
	
	rename `p' pnr
	
	merge m:1 pnr using $dd100/bef2018.dta, nogen keep(master matched) ///
	keepusing(foed_dag)
	
	gen cohort_`p'=.
	replace cohort_`p'=year(foed_dag) if pnr!=.
	
	sum cohort_`p'
	
	merge m:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched) ///
	keepusing($diag)
	
	** Counting number of diagnosis
	gen n_diag_`p'=0 if pnr!=.
	gen any_diag_`p'=0 if pnr!=.
	
	foreach v in $diag {
		gen `v'_`p'=`v'
		replace `v'_`p'=0 if `v'==. & pnr!=.
		replace n_diag_`p'=n_diag_`p'+1 if `v'==1
		replace any_diag_`p'=1 if `v'==1
		
	}
	rename pnr `p'
	drop $diag foed_dag
	
	sum *_`p'
}

rename focal pnr

** Joint measures for parents

foreach v in any_diag $diag {
	gen `v'_parent=`v'_mom
	replace `v'_parent=1 if `v'_dad==1
	replace `v'_parent=0 if `v'_dad==0 & `v'_parent==.
	foreach p in latest mfr tr {
	gen `v'_parent_`p'=`v'_mom_`p'
	replace `v'_parent_`p'=1 if `v'_dad_`p'==1
	replace `v'_parent_`p'=0 if `v'_dad_`p'==0 & `v'_parent_`p'==.	
	}
}

order abuse_parent skiz_parent bipolar_parent omood_parent neuro_parent ocd_parent eat_parent dev_parent ext_parent
egen n_diag_parent=rowtotal(abuse_parent-ext_parent)
tab n_diag_parent, m
replace n_diag_parent=. if mom==. & dad==.

	foreach p in latest mfr tr {
	order abuse_parent_`p' skiz_parent_`p' bipolar_parent_`p' omood_parent_`p' neuro_parent_`p' ocd_parent_`p' eat_parent_`p' dev_parent_`p' ext_parent_`p'
	egen n_diag_parent_`p'=rowtotal(abuse_parent_`p'-ext_parent_`p')
	tab n_diag_parent_`p', m
	replace n_diag_parent_`p'=. if mom_`p'==. & dad_`p'==.
	}



** Gen joint parent_id
egen parent=group(mom dad)
replace parent=mom if parent==.
replace parent=dad if parent==.

foreach p in latest mfr tr {
	egen parent_`p'=group(mom_`p' dad_`p')
	replace parent_`p'=mom_`p' if parent_`p'==.
	replace parent_`p'=dad_`p' if parent_`p'==.
}




save $asa/data/ic_step02.dta, replace

