
********************************************************************************
* THREE-GENERATION STUDY
* Adding grandparent information
********************************************************************************

* ----------------- ADD GRANDPARENTS ---------------------*
* TO CHILD AND PARENT SAMPLE FROM INTERGERATIONAL ANALYSIS


** Identify grandparents
local c=0
foreach p in m p {
	local c=`c'+1
	if `c'==1 local parent mom
	if `c'==2 local parent dad

	use $asa/data/ic_step02.dta, clear


	keep `parent'
	duplicates drop
	rename `parent' pnr
	drop if pnr==.

	gen `p'grandm=.
	gen `p'grandf=.
	gen cohort_`parent'=.
	gen yinbef_`parent'=.

	forvalues y=1986/2018 {
		
		merge 1:1 pnr using $dd100/bef`y'.dta, keep(master matched) keepusing(mor_id far_id foed_dag*)
		
		replace `p'grandm=mor_id if `p'grandm==.
		replace `p'grandf=far_id if `p'grandf==.	
		
		replace cohort_`parent'=year(foed_dag) if cohort_`parent'==.
		replace yinbef_`parent'=`y' if yinbef_`parent'==. & _merge==3
		
		drop mor_id far_id foed_dag _merge
	}
	
	rename pnr `parent'
	
	tempfile `p'aternal_gp
	save ``p'aternal_gp'
	
	** Information on Grandparents (mainly cohort)
	
	foreach gp in `p'grandm `p'grandf {
	
		preserve
		
		keep `gp'
		duplicates drop
		rename `gp' pnr
		drop if pnr==. 
		
		gen cohort_`gp'=.
		gen yinbef_`gp'=.
		
		** Adding cohort information
		
		forvalues y=1986/2018 {
			
			merge 1:1 pnr using $dd100/bef`y'.dta, keep(master matched) keepusing(foed_dag*)
			
			replace yinbef_`gp'=`y' if _merge==3
			replace cohort_`gp'=year(foed_dag) if cohort_`gp'==. & foed_dag!=.
			
			drop foed_dag _merge
			
		}
		
		** Adding death information:
		merge 1:1 pnr using $dd100/dod2021.dta, nogen keep(master matched) ///
		keepusing(doddato)
		
		gen dead_`gp'=year(doddato)
		drop doddato
		
		** Adding diagnosis information:
		merge 1:1 pnr using $asa/data/diagnosis.dta, nogen keep(master matched) ///
		keepusing($diag)
		
		** Counting number of diagnosis
		gen n_diag_`gp'=0 if pnr!=.
		gen any_diag_`gp'=0 if pnr!=.
		
		foreach v in $diag {
			gen `v'_`gp'=`v'
			replace `v'_`gp'=0 if `v'==. & pnr!=.
			replace n_diag_`gp'=n_diag_`gp'+1 if `v'==1
			replace any_diag_`gp'=1 if `v'==1
			
		}
		rename pnr `gp'
		drop $diag
			
		tempfile `gp'
		save ``gp''
		
		restore
	
	}
	
}
	
	
*------------ Putting it all together ----------------------------------------*	


use $asa/data/ic_step02.dta, clear

drop cohort_mom cohort_dad

	* Maternal gp id
	merge m:1 mom using `maternal_gp', nogen keep(master matched)
	* Maternal gp info
	merge m:1 mgrandm using `mgrandm', nogen keep(master matched)
	merge m:1 mgrandf using `mgrandf', nogen keep(master matched)
	* Paternal gp id
	merge m:1 dad using `paternal_gp', nogen keep(master matched)
	* Paternal gp info
	merge m:1 pgrandm using `pgrandm', nogen keep(master matched)
	merge m:1 pgrandf using `pgrandf', nogen keep(master matched)
	
	
save $asa/data/3gen_step01.dta, replace	



	
