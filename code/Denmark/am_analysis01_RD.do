
***************************************************
** ASSORTATIVE MATING ANALYSIS 01
* OR's (from pairwise logistic regressions)
* Only male-female couples
*--> FIGURE 1 
***************************************************

*---------------------- JOINTLY FOR MALES AND FEMALES TOGTHER ---------------*

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
	

* ------------------------ ODDS RATIOS ----------------------------------*


local c=0

foreach p in primp trp {
	
local c=`c'+ 1
	
use $asa/data/am_`p'.dta, clear

merge m:1 `p' using $asa/data/cohort_`p'.dta, nogen keep(master matched) keepusing(cohort_`p' male_`p' female_`p')



** DIVIDED INTO MALES AND FEMALE PARTNER
* Males = focal males and partner males
* Females = focal females and partner females
* keep only opposite sex couples


drop if male==1 & female_`p'!=1
drop if female==1 & male_`p'!=1
drop if `p'==.


	foreach v in any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
		gen `v'_male=.
		replace `v'_male=`v'_focal if male==1
		replace `v'_male=`v'_`p' if male_`p'==1
		gen `v'_female=.
		replace `v'_female=`v'_focal if female==1
		replace `v'_female=`v'_`p' if female_`p'==1
	}	


estimates clear


local c=0
foreach f in any_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
	foreach d in any_diag abuse ext neuro omood eat skiz bipolar ocd per dev {		
		logit `f'_male `d'_female, or
		estimates store `f'_`d'
		estpost sum `f'_male if `d'_female==1
		estimates store `f'_`d'_N		
	}
}

	label var any_diag_`p' "Any diagnosis"
	label var abuse_`p' "Substance abuse"
	label var skiz_`p' "Skizophrenia"
	label var bipolar_`p' "Bipolar"
	label var omood_`p' "Other mood"	
	label var neuro_`p' "Neurotic"
	label var ocd_`p' "OCD"
	label var eat_`p' "Eating disorder"
	label var per_`p' "Personality"
	label var dev_`p' "Developmental"
	label var ext_`p' "Externalizing"
	label var n_diag_`p' "# diagnosis"


	
*------- ODDS-RATIO --> FIGURE 1.C  (+ FIGURE 1E)

* With CI
esttab *_any_diag using $asa/table/am_or_`p'_malefemale_ci.csv, replace eform delimiter(:) cells("b(fmt(3))" "ci(fmt(3))") ///
mtitle("Any diagnosis" "Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar" "OCD" "Personality" "Developmental") nocons ///
label nonumber noobs nonotes nogaps nodepvar noeqlines


foreach v in abuse ext neuro omood eat skiz bipolar ocd per dev {
	esttab *_`v'  using $asa/table/am_or_`p'_malefemale_ci.csv, append eform delimiter(:) ///
	cells(b(fmt(3)) ci(fmt(3))) nocons ///
	label nomtitle noobs nonumber nonotes nogaps nodepvar noeqlines
}
** With SE
esttab *_any_diag using $asa/table/am_or_`p'_malefemale.csv, replace eform delimiter(:) cells("b(fmt(3))" "se(fmt(3))") ///
mtitle("Any diagnosis" "Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar" "OCD" "Personality" "Developmental") nocons ///
label nonumber noobs nonotes nogaps nodepvar noeqlines


foreach v in abuse ext neuro omood eat skiz bipolar ocd per dev {
	esttab *_`v'  using $asa/table/am_or_`p'_malefemale.csv, append eform delimiter(:) ///
	cells(b(fmt(3)) se(fmt(3))) nocons ///
	label nomtitle noobs nonumber nonotes nogaps nodepvar noeqlines
}


** N (--> transpose)
* Checking if too few observations in overlap
esttab any_*_N using $asa/table/am_N_`p'_malefemale.csv, replace delimiter(:) cells("sum(fmt(0))") ///
mtitle("Any disorder" "Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  nocons ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in abuse ext neuro omood eat skiz bipolar ocd per dev {
	esttab `v'_*_N  using $asa/table/am_N_`p'_malefemale.csv, append delimiter(:) ///
	 cells(sum(fmt(0)))  nocons ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
	
}


* ----------------------- RISK DIFFERENCES (primary partner only) -------------*

if `c'==1 {

	*** ANY: FEMALE TO MALE 
	* empty cells (9999) if <=5 in overlap	
	sum any_diag_male if any_diag_female==1
	local h=r(sum)
	if `h' > 5 {	
		logit any_diag_male any_diag_female, or
		adjrr any_diag_female
		
		matrix any_F_any_M_0=r(R0)
		matrix any_F_any_M_0ll=(r(R0)-(1.96*r(R0_se)))
		matrix any_F_any_M_0ul=(r(R0)+(1.96*r(R0_se)))
		matrix any_F_any_M_1=r(R1)
		matrix any_F_any_M_1ll=(r(R1)-(1.96*r(R1_se)))
		matrix any_F_any_M_1ul=(r(R1)+(1.96*r(R1_se)))
		matrix any_F_any_M_RD=r(ARD)
		matrix any_F_any_M_RDll=(r(ARD)-(1.96*r(ARD_se)))
		matrix any_F_any_M_RDul=(r(ARD)+(1.96*r(ARD_se)))	
		
		matrix any_F_any_M=(9999,9999,9999\any_F_any_M_0,any_F_any_M_0ll,any_F_any_M_0ul\ ///
		any_F_any_M_1,any_F_any_M_1ll,any_F_any_M_1ul\ ///
		any_F_any_M_RD,any_F_any_M_RDll,any_F_any_M_RDul)
		matrix colnames any_F_any_M = Risk LL UL
		matrix rownames any_F_any_M = "Female Any MH --> Male Any MH" No Yes "Risk Difference"
		mat list any_F_any_M
	}
	
	if `h'<=5 {
		matrix any_F_any_M=(9999,9999,9999\9999,9999,9999\ ///
		9999,9999,9999\ ///
		9999,9999,9999)
		matrix colnames any_F_any_M = Risk LL UL
		matrix rownames any_F_any_M = "Female Any MH --> Male Any MH" No Yes "Risk Difference"
		mat list any_F_any_M
	}
	
	*** DIAGNOSIS * DIAGNOSIS: FEMALE TO MALE
	* empty cells (9999) if <=5 in overlap	
	foreach f in abuse ext neuro omood eat skiz bipolar ocd per dev {
		foreach m in abuse ext neuro omood eat skiz bipolar ocd per dev {		
			sum `m'_male if `f'_female==1
			local h=r(sum)
			if `h' >= 5 {	
				logit `m'_male `f'_female, or
				adjrr `f'_female
				
				matrix F_M_0=r(R0)
				matrix F_M_0ll=(r(R0)-(1.96*r(R0_se)))
				matrix F_M_0ul=(r(R0)+(1.96*r(R0_se)))
				matrix F_M_1=r(R1)
				matrix F_M_1ll=(r(R1)-(1.96*r(R1_se)))
				matrix F_M_1ul=(r(R1)+(1.96*r(R1_se)))
				matrix F_M_RD=r(ARD)
				matrix F_M_RDll=(r(ARD)-(1.96*r(ARD_se)))
				matrix F_M_RDul=(r(ARD)+(1.96*r(ARD_se)))	
				
				matrix `f'_F_`m'_M=(9999,9999,9999\F_M_0,F_M_0ll,F_M_0ul\ ///
				F_M_1,F_M_1ll,F_M_1ul\ ///
				F_M_RD,F_M_RDll,F_M_RDul)
				matrix colnames `f'_F_`m'_M = Risk LL UL
				matrix rownames `f'_F_`m'_M = "Female `f' --> Male `m'" No Yes "Risk Difference"
				mat list `f'_F_`m'_M 
			}
			
			if `h'<5 {
				matrix `f'_F_`m'_M =(9999,9999,9999\9999,9999,9999\ ///
				9999,9999,9999\ ///
				9999,9999,9999)
				matrix colnames `f'_F_`m'_M  = Risk LL UL
				matrix rownames `f'_F_`m'_M  = "Female `f' --> Male `m'" No Yes "Risk Difference"
				mat list `f'_F_`m'_M 
			}	
		}
		
		matrix `f'_F_M=(`f'_F_abuse_M\ `f'_F_ext_M\ `f'_F_neuro_M\ `f'_F_omood_M\ `f'_F_eat_M\ `f'_F_skiz_M\ `f'_F_bipolar_M\ `f'_F_ocd_M\ `f'_F_per_M\ `f'_F_dev_M)
		
	}
	matrix F_M=(any_F_any_M\abuse_F_M\ext_F_M\neuro_F_M\omood_F_M\eat_F_M\skiz_F_M\bipolar_F_M\ocd_F_M\per_F_M\dev_F_M)
	mat list F_M
	
	esttab matrix(F_M) using $asa/table/RD_female_predicting_male.csv, replace nomtitle
	
	
	*** ANY: MALE TO FEMALE	
	sum any_diag_female if any_diag_male==1
	local h=r(sum)
	if `h' > 5 {	
	logit any_diag_female any_diag_male, or
	adjrr any_diag_male
	matrix any_M_any_F_0=r(R0)
	matrix any_M_any_F_0ll=(r(R0)-(1.96*r(R0_se)))
	matrix any_M_any_F_0ul=(r(R0)+(1.96*r(R0_se)))
	matrix any_M_any_F_1=r(R1)
	matrix any_M_any_F_1ll=(r(R1)-(1.96*r(R1_se)))
	matrix any_M_any_F_1ul=(r(R1)+(1.96*r(R1_se)))
	matrix any_M_any_F_RD=r(ARD)
	matrix any_M_any_F_RDll=(r(ARD)-(1.96*r(ARD_se)))
	matrix any_M_any_F_RDul=(r(ARD)+(1.96*r(ARD_se)))	
	
	matrix any_M_any_F=(9999,9999,9999\any_M_any_F_0,any_M_any_F_0ll,any_M_any_F_0ul\ ///
	any_M_any_F_1,any_M_any_F_1ll,any_M_any_F_1ul\ ///
	any_M_any_F_RD,any_M_any_F_RDll,any_M_any_F_RDul)
	matrix colnames any_M_any_F = Risk LL UL
	matrix rownames any_M_any_F = "Male Any MH --> Female Any MH" No Yes "Risk Difference"
	mat list any_M_any_F
	
	}
	
	if `h'<=5 {
		matrix any_M_any_F=(9999,9999,9999\9999,9999,9999\ ///
		9999,9999,9999\ ///
		9999,9999,9999)	
	matrix colnames any_M_any_F = Risk LL UL
	matrix rownames any_M_any_F = "Male Any MH --> Female Any MH" No Yes "Risk Difference"
	mat list any_M_any_F
	}
	
	*** DIAGNOSIS * DIAGNOSIS: MALE TO FEMALE
	foreach m in abuse ext neuro omood eat skiz bipolar ocd per dev {
		foreach f in abuse ext neuro omood eat skiz bipolar ocd per dev {		
			sum `f'_female if `m'_male==1
			local h=r(sum)
			if `h' >= 5 {	
				logit `f'_female `m'_male, or
				adjrr `m'_male
				
				matrix M_F_0=r(R0)
				matrix M_F_0ll=(r(R0)-(1.96*r(R0_se)))
				matrix M_F_0ul=(r(R0)+(1.96*r(R0_se)))
				matrix M_F_1=r(R1)
				matrix M_F_1ll=(r(R1)-(1.96*r(R1_se)))
				matrix M_F_1ul=(r(R1)+(1.96*r(R1_se)))
				matrix M_F_RD=r(ARD)
				matrix M_F_RDll=(r(ARD)-(1.96*r(ARD_se)))
				matrix M_F_RDul=(r(ARD)+(1.96*r(ARD_se)))	
				
				matrix `m'_M_`f'_F=(9999,9999,9999\M_F_0,M_F_0ll,M_F_0ul\ ///
				M_F_1,M_F_1ll,M_F_1ul\ ///
				M_F_RD,M_F_RDll,M_F_RDul)
				matrix colnames `m'_M_`f'_F = Risk LL UL
				matrix rownames `m'_M_`f'_F = "Male `m' --> Female `f'" No Yes "Risk Difference"
				mat list `m'_M_`f'_F
			}
			
			if `h'<5 {
				matrix `m'_M_`f'_F =(9999,9999,9999\9999,9999,9999\ ///
				9999,9999,9999\ ///
				9999,9999,9999)
				matrix colnames `m'_M_`f'_F  = Risk LL UL
				matrix rownames `m'_M_`f'_F  = "Male `m' --> Female `f'" No Yes "Risk Difference"
				mat list `m'_M_`f'_F 
			}	
		}
		
		matrix `m'_M_F=(`m'_M_abuse_F\ `m'_M_ext_F\ `m'_M_neuro_F\ `m'_M_omood_F\ `m'_M_eat_F\ `m'_M_skiz_F\ `m'_M_bipolar_F\ `m'_M_ocd_F\ `m'_M_per_F\ `m'_M_dev_F)
		
	}
	matrix M_F=(any_M_any_F\abuse_M_F\ext_M_F\neuro_M_F\omood_M_F\eat_M_F\skiz_M_F\bipolar_M_F\ocd_M_F\per_M_F\dev_M_F)
	mat list M_F
	
	esttab matrix(M_F) using $asa/table/RD_male_predicting_female.csv, replace nomtitle
	

}
}


* ------------------------- ANY DIAGOSIS + # OF DIAGNOSES--------------------------*

* OR for any
* IRR for number of diagnosis



local c=0

foreach p in primp trp {
	
local c=`c'+ 1
	
use $asa/data/am_`p'.dta, clear

merge m:1 `p' using $asa/data/cohort_`p'.dta, nogen keep(master matched) keepusing(cohort_`p' male_`p' female_`p')


** DIVIDED INTO MALES AND FEMALE PARTNER
* Males = focal males and partner males
* Females = focal females and partner females
* keep only opposite sex couples


drop if male==1 & female_`p'!=1
drop if female==1 & male_`p'!=1
drop if `p'==.

	foreach v in any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
		gen `v'_male=.
		replace `v'_male=`v'_focal if male==1
		replace `v'_male=`v'_`p' if male_`p'==1
		gen `v'_female=.
		replace `v'_female=`v'_focal if female==1
		replace `v'_female=`v'_`p' if female_`p'==1
	}	

label var n_diag_male "# of diagnoses (male)"
label var n_diag_female "# of diagnoses (female)"

* Females predicting males
poisson n_diag_male n_diag_female, irr
estimates store `p'

* Males predicting females
poisson n_diag_female n_diag_male , irr
estimates store `p'1

* Any diagnoses (order does not matter)
logit any_diag_male any_diag_female, or
estimates store `p'_any


}


esttab primp* trp* using $asa/table/am_irr_ndiag_malefemale.csv, replace eform delimiter(:) cells("b(fmt(3))" "se(fmt(3))" "ci(fmt(3))") ///
nocons ///
label nonumber noobs nonotes nogaps nodepvar noeqlines


* ------------------------ADJUSTING FOR COMORBIDITY ---------------------------*
*---> FIGURE 1C/D

local c=0

foreach p in primp  {
	
local c=`c'+ 1
	
use $asa/data/am_`p'.dta, clear

merge m:1 `p' using $asa/data/cohort_`p'.dta, nogen keep(master matched) keepusing(cohort_`p' male_`p' female_`p')


** DIVIDED INTO MALES AND FEMALE PARTNER
* Males = focal males and partner males
* Females = focal females and partner females
* keep only opposite sex couples


drop if male==1 & female_`p'!=1
drop if female==1 & male_`p'!=1
drop if `p'==.

	foreach v in any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
		gen `v'_male=.
		replace `v'_male=`v'_focal if male==1
		replace `v'_male=`v'_`p' if male_`p'==1
		gen `v'_female=.
		replace `v'_female=`v'_focal if female==1
		replace `v'_female=`v'_`p' if female_`p'==1
	}	


estimates clear

local cc=0

foreach g in female male {
	local cc=`cc'+1

foreach f in abuse ext neuro omood eat skiz bipolar ocd per dev {
	foreach d in abuse ext neuro omood eat skiz bipolar ocd per dev {	
		** Male/female has no comorbidity
		if `cc'==1 capture noisily logit `f'_male `d'_female if `f'_female==0, or
		if `cc'==2 capture noisily logit `f'_male `d'_female if `d'_male==0, or
		capture estimates store `g'_`f'_`d'
		if `cc'==1 capture noisily estpost sum `f'_male if `d'_female==1 & `f'_female==0
		if `cc'==2 capture noisily estpost sum `f'_male if `d'_female==1 & `d'_male==0
		capture estimates store `g'_`f'_`d'_N
	
	}
}


	label var abuse_`p' "Substance abuse"
	label var skiz_`p' "Skizophrenia"
	label var bipolar_`p' "Bipolar"
	label var omood_`p' "Other mood"	
	label var neuro_`p' "Neurotic"
	label var ocd_`p' "OCD"
	label var eat_`p' "Eating disorder"
	label var per_`p' "Personality"
	label var dev_`p' "Developmental"
	label var ext_`p' "Externalizing"
	label var n_diag_`p' "# diagnosis"

** OBS - diagnonals have no estimates, move manually right from diagnoal to get the right estimates
** OR
*---> FIGURE 1C/D

esttab `g'*_abuse using $asa/table/am_or_nocomor_`p'_malefemale_`g'.csv, replace delimiter(:) eform cells("b(fmt(3))" "se(fmt(3))") ///
mtitle("Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  keep(abuse_*)  ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev {
	esttab `g'*_`v'  using $asa/table/am_or_nocomor_`p'_malefemale_`g'.csv, append delimiter(:) ///
	eform cells(b(fmt(3)) se(fmt(3)))  keep(`v'_*)  ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
}

** N (--> transpose)
esttab `g'_abuse_*_N using $asa/table/am_N_nocomor_`p'_malefemale_`g'.csv, replace delimiter(:) cells("sum(fmt(0))") ///
mtitle("Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  nocons ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev {
	esttab `g'_`v'_*_N  using $asa/table/am_N_nocomor_`p'_malefemale_`g'.csv, append delimiter(:) ///
	 cells(sum(fmt(0)))  nocons ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
}
}
}	


* ------------------------- Individual co-morbidity ---------------------------------*
*---> FIGURE 1A

local c=0

foreach p in primp  {
	
local c=`c'+ 1
	
use $asa/data/am_`p'.dta, clear

merge m:1 `p' using $asa/data/cohort_`p'.dta, nogen keep(master matched) keepusing(cohort_`p' male_`p' female_`p')



** DIVIDED INTO MALES AND FEMALE PARTNER
* Males = focal males and partner males
* Females = focal females and partner females
* keep only opposite sex couples


drop if male==1 & female_`p'!=1
drop if female==1 & male_`p'!=1
drop if `p'==.


	foreach v in any_diag n_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
		gen `v'_male=.
		replace `v'_male=`v'_focal if male==1
		replace `v'_male=`v'_`p' if male_`p'==1
		gen `v'_female=.
		replace `v'_female=`v'_focal if female==1
		replace `v'_female=`v'_`p' if female_`p'==1
	}	
	gen pnr_male=.
	replace pnr_male=pnr if male==1
	replace pnr_male=`p' if male_`p'==1
	gen pnr_female=.
	replace pnr_female=pnr if female==1
	replace pnr_female=`p' if female_`p'==1
	
	
* Keep just one observation per individual (regardless of entering multiple times as focal/primary partner in couples)	
foreach g in male female {
	preserve
	keep *_`g'
	duplicates drop
	gen `g'=1
	tempfile `g'
	save ``g''
	restore
}

use `male', clear
append using `female'


foreach f in abuse ext neuro omood eat skiz bipolar ocd per dev {
	gen `f'=.
	foreach g in male female {
		replace `f'=`f'_`g' if `f'_`g'!=.
	}	
}


estimates clear


foreach f in abuse ext neuro omood eat skiz bipolar ocd per dev {
	foreach d in abuse ext neuro omood eat skiz bipolar ocd per dev {	
		capture noisily logit `f' `d', or
		capture noisily estimates store `f'_`d'
		capture noisily estpost sum `f' if `d'==1
		capture estimates store `f'_`d'_N
	}
}

** OR ---> FIGURE 1A
esttab *_abuse using $asa/table/am_or_ind_`p'_malesfemales_noduplicates.csv, replace delimiter(:) eform cells("b(fmt(3))" "se(fmt(3))" ci(fmt(3))) ///
mtitle("Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  drop(_cons)  ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev {
	esttab *_`v'  using $asa/table/am_or_ind_`p'_malesfemales_noduplicates.csv, append delimiter(:) ///
	eform cells(b(fmt(3)) se(fmt(3)) ci(fmt(3)))  drop(_cons)  ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
}


** N checking for overlap
esttab abuse_*_N using $asa/table/am_N_ind_`p'_malesfemales_noduplicates.csv, replace delimiter(:) cells("sum(fmt(0))") ///
mtitle("Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  nocons ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev {
	esttab `v'_*_N  using $asa/table/am_N_ind_`p'_malesfemales_noduplicates.csv, append delimiter(:) ///
	 cells(sum(fmt(0)))  nocons ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
}
}



