

********************************************************
** STEP01: IDENTIFY STUDY POPULATION
* FOCAL INDIVIDUALS: MALES AND FEMALES BORN IN DK 1960-1970
********************************************************

* ------------------------ FOCAL INDIVIDUALS ----------------------------------*
* Locating focal individual in all years (1980-2018)
* Born in DK (ietype = 1 / 3)
* And their partners (cfalle/efalle)
* Population registers: FAIN + BEF


local c=0
foreach g in male female {
	local c=`c'+1
	
	
	forvalues y=1980/1985 {
		
		use pnr sfoddato koen cfalle ietype using $dd100/fain`y'.dta ///
		if inrange(year(sfoddato),1960,1970) & koen==`c' & inlist(ietype,1,3), clear
		
		foreach v in sfoddato cfalle koen ietype {
			rename `v' `v'
		}
		gen y=`y'
		gen `g'=1
		gen cohort=year(sfoddato)
		gen in_bef=1
		gen dk=ietype==1
		gen partner=cfalle
		gen bday=sfoddato
		drop koen ietype cfalle sfoddato
		
		tempfile `y'
		save ``y''
		
		
	}	
	
	forvalues y=1986/2018 {
		
		use pnr foed_dag koen efalle ie_type using $dd100/bef`y'.dta ///
		if inrange(year(foed_dag),1960,1970) & koen==`c' & inlist(ie_type,1,3), clear
		
		foreach v in foed_dag efalle koen ie_type {
			rename `v' `v'
		}
		gen y=`y'
		gen `g'=1
		gen cohort=year(foed_dag)
		gen in_bef=1
		gen dk=ie_type==1
		gen partner=efalle 
		gen bday=foed_dag
		drop koen ie_type efalle foed_dag
		
		tempfile `y'
		save ``y''
		
		
	}
	
* Appending

use `1980'
forvalues y=1981/2018 {
	append using ``y''
}

* Aligning constant information

bysort pnr: egen h=max(dk)
replace dk=h
bysort pnr: egen hh=min(bday)
replace bday=hh
drop h hh
bysort pnr: egen total_in_bef=total(in_bef)

save $temp/check.dta, replace


*------------------------ SELECTION OF PARTNERS -------------------------------*

use $temp/check.dta, clear

* Reshaping partner information

preserve

	keep pnr y partner
	drop if partner==.
	
	* primary partner (most years, randomly selecting among those with same amount of years)
	
	bysort pnr partner (y): gen y_partner=_N
	bysort pnr: egen my=max(y_partner)
	gen h=partner if my==y_partner
	gen random=runiform() if h!=.
	bysort pnr: egen mrandom=max(random)
	gen hh=h if random==mrandom
	bysort pnr: egen prim_partner=max(hh)
	
	* All partners (numbered)
	bysort pnr partner (y): gen n=1 if _n==1
	bysort pnr (y): gen no=sum(n) if n==1
	bysort pnr: egen n_partners=max(no)
	
	* randomly selected partner (from focal individuals actual partners)
	gen random1=runiform() if n==1
	bysort pnr: egen mrandom1=max(random1)
	gen hhh=partner if random1==mrandom1
	bysort pnr: egen r_partner=max(hhh)
		
		
	keep pnr no partner n_partners prim_partner r_partner
	duplicates drop
	drop if no==.
	
	reshape wide partner, i(pnr) j(no)
	
	tempfile partners
		
	save `partners'
	
restore	

* Condensed data w. partner id

preserve

	keep partner
	duplicates drop
	save $temp/am_partners_id_`g'.dta, replace

restore

* Pool of random partners (totally random)

preserve

	keep cohort partner
	duplicates drop
	gen num=runiform()
	bysort cohort (num): gen number=_n // random number for partner by (focal) cohort
	rename partner totr_p
	save $temp/am_partners_id_`g'_random.dta, replace

restore


** Adding wide partner information

drop partner

reshape wide in_bef, i(pnr) j(y)

merge 1:1 pnr using `partners', nogen keep(master matched) keepusing(*partner*)

replace n_partner=0 if n_partner==.


** Adding the totally random partner
* Sampled from partners of those within the same birth cohort
* Only for those who has a partner
gen num=runiform() 
bysort cohort (num): gen number=_n // random number for focal individual by cohort
merge 1:1 cohort number using  $temp/am_partners_id_`g'_random.dta, nogen keep(master matched) keepusing(totr_p)

gen h=totr_p if n_partner==0
bysort cohort: egen h_min=min(h)
bysort cohort: egen h_max=max(h)

replace totr_p=h_min if totr_p==.

replace totr_p=. if n_partner==0



save $temp/am_step01_`g'.dta, replace

	
}


erase $temp/check.dta