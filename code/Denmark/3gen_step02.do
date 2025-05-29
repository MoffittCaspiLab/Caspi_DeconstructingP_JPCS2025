
*****************************************************************************
** RESTRICTING THE SAMPLE
* CATEGORIZING DIAGNOSIS
*****************************************************************************


use $asa/data/3gen_step01.dta, clear

drop *_mfr *_tr *_latest


** At least two grandparents + both parents!
* Does it need to be on either side?
egen nmiss_gp=rowmiss(mgrandm mgrandf pgrandm pgrandf)
egen nmiss_gp_bef=rowmiss(yinbef_mgrandm yinbef_mgrandf yinbef_pgrandm yinbef_pgrandf)

** Min. two grandparents with residence at any point between 1986-2018
* Dropping roughly 15 %
keep if nmiss_gp_bef<=3 & mom!=. & dad!=.
* Residence of two parents also!
drop if cohort_mom==. | cohort_dad==.



** CATEGORIZING DIAGNOSIS
gen child=pnr

foreach fam in child mom dad mgrandm mgrandf pgrandm pgrandf { 

gen gen3int_`fam'=omood_`fam'==1 | neuro_`fam'==1 | eat_`fam'==1 if `fam'!=.
gen gen3ext_`fam'=abuse_`fam'==1 | ext_`fam'==1 if `fam'!=.
gen gen3thought_`fam'=skiz_`fam'==1 | bipolar_`fam'==1 | ocd_`fam'==1 if `fam'!=.

}

keep pnr cohort* parent mom dad mgrand* pgrand* gen3* yinbef*

save $asa/data/3gen_step02.dta, replace

* ---------------------- SUBSAMPLES ----------------------------*

** 10 % sample

sample 10


save $asa/data/3gen_step02_sample10.dta, replace



** Randomly selected child (by parent ID)

use $asa/data/3gen_step02.dta, clear

bysort parent: gen number=runiform()
bysort parent (number): keep if _n==1


save $asa/data/3gen_step02_randomchild.dta, replace

