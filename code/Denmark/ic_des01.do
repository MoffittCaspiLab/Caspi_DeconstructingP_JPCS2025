

***************************************************
** INTERGEN CORRELATION  DESCRIPTIVE01
* ---> FIGURE S3
***************************************************

	use $asa/data/ic_step02.dta, clear
	
	drop cohort_mom
	drop cohort_dad
	
	drop foed_dag2018
	
	** Adding birth dates for parents
	foreach p in mom dad {
		rename pnr focal_pnr
		rename `p' pnr
		gen cohort_`p'=.
		forvalues t=1986/2018 {	
		merge m:1 pnr using $dd100/bef`t'.dta, nogen keep(master matched) keepusing(foed_dag)
		replace cohort_`p'=year(foed_dag) if cohort_`p'==.
		drop foed_dag
	}
		rename pnr `p'
		rename focal_pnr pnr
	}
	
	gen agep1986_child=1985-cohort
	gen ageu2018_child=2018-cohort
	gen agep1970_child=1969-cohort
	foreach v in mom dad {
		gen agep1986_`v'=1985-cohort_`v'
		gen ageu2018_`v'=2018-cohort_`v'
		gen agep1970_`v'=1969-cohort_`v'
	}
	

	foreach v in agep1970 agep1986 ageu2018 any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
		gen tab_`v'=.
		replace tab_`v'=`v'_child
	}

	gen has_parents=dad!=. | mom!=. 
	gen has_mom=mom!=. 
	gen has_dad=dad!=. 
	
	label var has_parent "Has parent"	
	label var has_mom "Has mom"
	label var has_dad "Has dad"
	label var tab_agep1986 "Age primo 1970"
	label var tab_agep1986 "Age primo 1986"
	label var tab_ageu2018 "Age ultimo 2018"	
	label var male "Males"
	label var tab_n_diag "# diagnoses (birth-2018)"
	label var tab_any_diag "Any diagnosis (birth-2018)"
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
	


	* FOCAL MEASURES
	estpost sum has_parent has_mom has_dad male tab_*
	estimates store focal
	

	
	* FOCAL MEASURES (Kids with parents)
	estpost sum has_parent has_mom has_dad male tab_* if has_dad==1 | has_mom==1
	estimates store focal_wparent	
	
	
	foreach v in any_diag n_diag $diag {
		replace tab_`v'=`v'_parent
	}

	* JOINT PARENT MEASURES
	estpost sum tab_* if parent!=.
	estimates store parent	


	foreach v in agep1970 agep1986 ageu2018 any_diag n_diag $diag {
		replace tab_`v'=`v'_mom
	}

	* MOM MEASURES
	estpost sum tab_* if mom!=.
	estimates store mom


	foreach v in agep1970 agep1986 ageu2018 any_diag n_diag $diag {
		replace tab_`v'=`v'_dad
	}

	* DAD MEASURES
	estpost sum tab_* if dad!=.
	estimates store dad
	
	
	foreach v in any_diag n_diag $diag {
		replace tab_`v'=`v'_parent_tr
	}

	* TOTALLY RANDOM PARENT MEASURES
	estpost sum tab_*
	estimates store random	
	
	
	** TABLE
	* ---> Table S3

	esttab focal_wparent parent mom dad using $asa/table/ic_des01_feb25.csv, replace ///
	cells("sum(fmt(0)) mean(fmt(3))") keep(has_* male tab_any_diag) label ///
	mtitle("Child" "Child w. parent" "Parent" "Mom" "Dad") nonum noobs
	
	esttab focal_wparent parent mom dad using $asa/table/ic_des01_feb25.csv, append ///
	cells("mean(fmt(3)) sd(fmt(3))") keep(tab_agep1970 tab_agep1986 tab_ageu2018 tab_n_diag) label ///
	mtitle("Child" "Child w. parent" "Parent" "Mom" "Dad") nonum noobs	
	
	esttab focal_wparent parent mom dad using $asa/table/ic_des01_feb25.csv, append ///
	cells("sum(fmt(0)) mean(fmt(3))") keep(tab_abuse tab_ext tab_neuro tab_omood tab_eat tab_skiz tab_bipolar tab_ocd tab_per tab_dev) label ///
	nonum 
	
	
	*** Number of children per family
	bysort parent: gen N=_N if _n==1 & parent!=.
	
	***
	gen before1970_mom=cohort_mom<1970 if mom!=.
	gen before1970_dad=cohort_dad<1970 if dad!=.

	save $asa/data/ic_step02_cohort.dta, replace
	

*--------------------------------------------------

	