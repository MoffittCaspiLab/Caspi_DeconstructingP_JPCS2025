

********************************************************
** STEP01: IDENTIFY STUDY POPULATION
* CHILDREN BORN IN DK 1985-1995
********************************************************

* Locating observations in all years

	
	forvalues y=1986/2018 {
		
		use pnr foed_dag koen ie_type mor_id far_id using $dd100/bef`y'.dta ///
		if inrange(year(foed_dag),1985,1995) & inlist(ie_type,1,3), clear
		
		foreach v in foed_dag mor_id far_id koen ie_type {
			rename `v' `v'
		}
		gen y=`y'
		gen male=1 if koen==1
		gen cohort=year(foed_dag)
		gen in_bef=1
		gen dk=ie_type==1
		gen bday=foed_dag
		drop koen ie_type foed_dag 
		
		tempfile `y'
		save ``y''
		
		
	}
	
* Appending

use `1986'
forvalues y=1987/2018 {
	append using ``y''
}

* Aligning constant information

bysort pnr: egen h=max(dk)
replace dk=h
bysort pnr: egen hh=min(bday)
replace bday=hh
drop h hh
bysort pnr: egen total_in_bef=total(in_bef)

* First parent registered in BEF
* mom / dad = earliest parent registered 
* (also latest just in case)

gen momnonmiss=mor_id!=.
bysort pnr momnonmiss (y): gen h=mor_id if _n==1 & momnonmiss==1
bysort pnr momnonmiss (y): gen hh=mor_id if _n==_N & momnonmiss==1
bysort pnr: egen mom=max(h)
bysort pnr: egen mom_latest=max(hh)

gen dadnonmiss=far_id!=.
bysort pnr dadnonmiss (y): gen hhh=far_id if _n==1 & dadnonmiss==1
bysort pnr dadnonmiss (y): gen hhhh=far_id if _n==_N & dadnonmiss==1
bysort pnr: egen dad=max(hhh)
bysort pnr: egen dad_latest=max(hhhh)


** earliest year in bef
bysort pnr in_bef (y): gen hy=y-cohort if _n==1 & in_bef==1
bysort pnr: egen age_earliest=max(hy)

*---------------------------Cleaning up --------------------------------------*

keep pnr cohort male dk bday mom mom_* dad dad_* total_in_bef age_earliest

replace male=0 if male==.

duplicates drop

sum 

*------------------ Using other data sources to identify parents --------------*


*** Making another effort to identify parents:::
* Using FAIN (yearly information on legal parents - not updated backwards as BEF)

gen mom_fain_earliest=.
gen mom_fain_latest=.
gen dad_fain_earliest=.
gen dad_fain_latest=.

forvalues y=1980/2007 {
	merge 1:1 pnr using $dd100/fain`y'.dta, nogen keep(master matched) keepusing(pnrm pnrf)
	replace mom_fain_earliest=pnrm if mom_fain_earliest==.
	replace mom_fain_latest=pnrm if pnrm!=.
	replace dad_fain_earliest=pnrf if dad_fain_earliest==.
	replace dad_fain_latest=pnrf if pnrf!=.
	drop pnrm pnrf 
}

* Correcting for potential earlier information (priority given to earliest - most likely to be birth parents)
replace mom=mom_fain_earliest if mom_fain_earliest!=.
replace dad=dad_fain_earliest if dad_fain_earliest!=.
replace mom_latest=mom_fain_latest if mom_fain_latest!=. & mom_latest==.
replace dad_latest=dad_fain_latest if dad_fain_latest!=. & dad_latest==.



*** Those w. missing mom/dad
* More likely to be descendatans of immigrants 
* A little more likely to come from earlier cohorts 
* Entering BEF later
* Only in BEF few years


*** Getting info on parents from medical registers
rename pnr pnrb
merge 1:1 pnrb using $dd100/nylfoed_2010.dta, nogen keep(master matched) keepusing(pnrm pnrf)

gen mom_mfr=pnrm
gen dad_mfr=pnrf
rename pnrb pnr


* Correcting for potential earlier information (priority given to earliest - most likely to be birth parents)
replace mom=mom_mfr if mom_mfr!=.
replace dad=dad_mfr if dad_mfr!=.
replace mom_latest=mom_mfr if mom_mfr!=. & mom_latest==.
replace dad_latest=dad_mfr if dad_mfr!=. & dad_latest==.


* ------------- Generating random parents (drawn from same cohort) ------------*
foreach v in mom dad {
	preserve
	keep  cohort `v'
	gen random=runiform()
	bysort cohort (random): gen count=_n
	drop random
	rename `v' `v'_tr
	tempfile `v'
	save ``v''
	restore
}

gen random=runiform()
bysort cohort (random): gen count=_n

merge 1:1 cohort count using `mom', nogen keepusing(*tr)
merge 1:1 cohort count using `dad', nogen keepusing(*tr)


*** SAVING

drop random count cps first_cps


save $temp/ic_step01.dta, replace


