
******************************************
* DESCRIPTIVE TABLE
* --> Data for TABLE S8
******************************************

use $asa/data/3gen_step02.dta, clear


foreach fam in child mom dad mgrandm mgrandf pgrandm pgrandf { 
	gen tab_`fam'=.	
}
label var tab_child "Children"
label var tab_mom "Mothers"
label var tab_dad "Fathers"
label var tab_mgrandm "Maternal grandmothers"
label var tab_mgrandf "Maternal grandfathers"
label var tab_pgrandm "Paternal grandmothers"
label var tab_pgrandf "Paternal grandfathers"

order tab_pgrandf tab_pgrandm tab_mgrandf tab_mgrandm tab_dad tab_mom tab_child 

** Cohort 
* age at baseline (1986)

foreach fam in mom dad mgrandm mgrandf pgrandm pgrandf { 
	gen age_`fam'=1986-cohort_`fam'
	replace tab_`fam'=.	
	replace tab_`fam'=age_`fam'
	sum tab_`fam', det
	tab age_`fam' if tab_`fam'==r(p1)
	sum tab_`fam', det	
	tab age_`fam' if tab_`fam'==r(p99)
	
}	
	estpost sum tab_*, det
	estimates store age
	
esttab age using $asa/table/3gen_des01_age.csv, replace cells("count(fmt(0)) mean(fmt(1)) sd(fmt(1)) p1(fmt(0)) p99(fmt(0))") label ///
	mtitle("Age at baseline (1986)") nonum noobs		

** Internalizing

gen yinbef_child=cohort+1 // artificial

foreach fam in child mom dad mgrandm mgrandf pgrandm pgrandf { 
	replace tab_`fam'=.
	replace tab_`fam'=gen3int_`fam' if yinbef_`fam'!=.
}
	estpost sum tab_*
	estimates store inter
	
** Externalizing

foreach fam in child mom dad mgrandm mgrandf pgrandm pgrandf { 
	replace tab_`fam'=.
	replace tab_`fam'=gen3ext_`fam' if yinbef_`fam'!=.
}
	estpost sum tab_*
	estimates store ext
	
** Thought

foreach fam in child mom dad mgrandm mgrandf pgrandm pgrandf { 
	replace tab_`fam'=.
	replace tab_`fam'=gen3thought_`fam' if yinbef_`fam'!=.
}
	estpost sum tab_*
	estimates store thought


	
esttab ext inter thought using $asa/table/3gen_des01_diagnosis.csv, replace cells("sum(fmt(0)) mean(fmt(5))") label ///
	mtitle("Externalizing" "Internalizing" "Thought disorder") nonum noobs	