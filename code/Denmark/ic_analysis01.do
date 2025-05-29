
***************************************************
** INTERGEN CORRELATIONS ANALYSIS 01
***************************************************

use $asa/data/ic_step02.dta, clear

* ------------------------ ODDS RATIOS ----------------------------------*
* --> FIGURE 3A / 3C
* --> FIGURE S1/S2

local c=0
foreach p in parent mom dad parent_tr {
	
	local c=`c'+1
	if `c'==1 local parent "Parent"
	if `c'==2 local parent "Mother"
	if `c'==3 local parent "Father"
	if `c'==4 local parent "Parent"
	


foreach d in any_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
	gen `d'_reg=`d'_`p'		
}

foreach f in any_diag abuse ext neuro omood eat skiz bipolar ocd per dev {
	foreach d in any_diag $diag {		
		logit `f'_child `d'_reg if `p'!=., or vce(cluster `p')
		estimates store `f'_`d'
		estpost sum `f'_child if `d'_reg==1
		capture estimates store N_`f'_`d'
	}
}	


	label var any_diag_reg "Any diagnosis"
	label var abuse_reg "Substance abuse"
	label var skiz_reg "Skizophrenia"
	label var bipolar_reg "Bipolar"
	label var omood_reg "Other mood"	
	label var neuro_reg "Neurotic"
	label var ocd_reg "OCD"
	label var eat_reg "Eating disorder"
	label var per_reg "Personality"
	label var dev_reg "Developmental"
	label var ext_reg "Externalizing"
	label var n_diag_reg "# diagnosis"

	
* TABLE. OBS: Child diagnoses as dependent (column)
* Transpose to match figures

esttab *_any_diag using $asa/table/ic_or_`p'.csv, replace delimiter(:) eform cells("b(fmt(3))" "ci(par fmt(3))") ///
mtitle("Any diagnosis" "Substance abuse" "Externalizing" "Skizofrenia" "Bipolar" "Other mood" "Neurotic" "OCD" "Eating disorder" "Personality" "Developmental") eqlabel("" "" "" "" "" "" "" "" "" "" "" "") ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in abuse ext neuro omood eat skiz bipolar ocd per dev {
	esttab *_`v'  using $asa/table/ic_or_`p'.csv, append delimiter(:) ///
	eform cells(b(fmt(3)) ci(par fmt(3))) eqlabel("" "" "" "" "" "" "" "" "" "" "" "") ///
	label nomtitle noobs nonum nonotes nogaps compress
}

** N (tjekking overlap N)
esttab N_abuse_* using $asa/table/ic_N_`p'.csv, replace delimiter(:) cells("sum(fmt(0))") ///
mtitle("Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  nocons ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev {
	esttab N_`v'_* using $asa/table/ic_N_`p'.csv, append delimiter(:) ///
	 cells(sum(fmt(0)))  nocons ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
}	
	drop *_reg	

}	


* -------------------------- NO COMOBIDITY ----------------------------------*
* ORs
** NO COMORBIDITY (if the parent does not have the childs diagnosis)
* --> FIGURE 3B

use $asa/data/ic_step02.dta, clear


local c=0
foreach p in parent mom dad parent_tr {
	
	local c=`c'+1
	if `c'==1 local parent "Parent"
	if `c'==2 local parent "Mother"
	if `c'==3 local parent "Father"
	if `c'==4 local parent "Parent"
	


foreach d in abuse ext neuro omood eat skiz bipolar ocd per dev  {
	gen `d'_reg=`d'_`p'		
}

estimates clear

foreach f in abuse ext neuro omood eat skiz bipolar ocd per dev   {
	foreach d in abuse ext neuro omood eat skiz bipolar ocd per dev {		
		capture noisily logit `d'_reg `f'_child if `p'!=. & `f'_`p'==0, or vce(cluster `p')
		capture estimates store `f'_`d'
		capture noisily estpost sum `f'_child if `d'_reg==1 & `f'_`p'==0
		capture estimates store N_`f'_`d'		
	}
}	

	label var abuse_reg "Substance abuse"
	label var skiz_reg "Skizophrenia"
	label var bipolar_reg "Bipolar"
	label var omood_reg "Other mood"	
	label var neuro_reg "Neurotic"
	label var ocd_reg "OCD"
	label var eat_reg "Eating disorder"
	label var per_reg "Personality"
	label var dev_reg "Developmental"
	label var ext_reg "Externalizing"
	label var n_diag_reg "# diagnosis"

** TABLE
** OBS - diagnonals have no estimates, move manually right from diagnoal to get the right estimates

esttab abuse_* using $asa/table/ic_or_nocomor_`p'.csv, replace delimiter(:) eform cells("b(fmt(3))" "se(fmt(3))") ///
mtitle("Substance abuse" "Externalizing" "Skizofrenia" "Bipolar" "Other mood" "Neurotic" "OCD" "Eating disorder" "Personality" "Developmental") eqlabel("" "" "" "" "" "" "" "" "" "" "" "") ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev  {
 	esttab `v'_*  using $asa/table/ic_or_nocomor_`p'.csv, append delimiter(:) ///
	eform cells("b(fmt(3))" "se(fmt(3))") eqlabel("" "" "" "" "" "" "" "" "" "" "" "") ///
	label nomtitle noobs nonum nonotes nogaps compress
}

** N 
esttab N_abuse_* using $asa/table/ic_N_nocomor_`p'.csv, replace delimiter(:) cells("sum(fmt(0))") ///
mtitle("Substance abuse" "Externalizing" "Neurotic" "Mood" "Eating disorder" "Skizophrenia" "Bipolar"  ///
 "OCD" "Personality" "Developmental")  nocons ///
label nonum noobs nonotes nogaps nodepvar noeqlines compress

foreach v in ext neuro omood eat skiz bipolar ocd per dev {
	esttab N_`v'_* using $asa/table/ic_N_nocomor_`p'.csv, append delimiter(:) ///
	 cells(sum(fmt(0)))  nocons ///
	label nomtitle noobs nonum nonotes nogaps nodepvar noeqlines compress
}	
	drop *_reg
	
	
}


* ------------------------- IRRs ----------------------------------------------*


/*
* Table with ANY, SAME, CROSS, IRRs
*/

label var n_diag_child "# of diagnoses (child)"
label var n_diag_parent "# of diagnoses (parents)"
label var n_diag_mom "# of diagnoses (mother)"
label var n_diag_dad "# of diagnoses (father)"
label var n_diag_parent_tr "# of diagnoses (totally random parents)"

foreach p in parent mom dad parent_tr {


poisson n_diag_child n_diag_`p' , irr vce(cluster `p')
estimates store `p'

}

esttab parent mom dad parent_tr using $asa/table/ic_irr_ndiag.csv, replace eform delimiter(:) cells("b(fmt(3))" "se(fmt(3))") ///
nocons ///
label nonumber noobs nonotes nogaps nodepvar noeqlines


