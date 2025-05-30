
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
	
* ----------------------- RISK DIFFERENCES (parent measures) -------------*

use $asa/data/ic_step02.dta, clear


	*** ANY: PARENT TO CHILD
	* empty cells (9999) if <=5 in overlap
	sum any_diag_child if any_diag_parent==1
	local h=r(sum)
	if `h' > 5 {	
		logit any_diag_child any_diag_parent, or
		adjrr any_diag_parent
		
		matrix any_P_any_C_0=r(R0)
		matrix any_P_any_C_0ll=(r(R0)-(1.96*r(R0_se)))
		matrix any_P_any_C_0ul=(r(R0)+(1.96*r(R0_se)))
		matrix any_P_any_C_1=r(R1)
		matrix any_P_any_C_1ll=(r(R1)-(1.96*r(R1_se)))
		matrix any_P_any_C_1ul=(r(R1)+(1.96*r(R1_se)))
		matrix any_P_any_C_RD=r(ARD)
		matrix any_P_any_C_RDll=(r(ARD)-(1.96*r(ARD_se)))
		matrix any_P_any_C_RDul=(r(ARD)+(1.96*r(ARD_se)))	
		
		matrix any_P_any_C=(9999,9999,9999\any_P_any_C_0,any_P_any_C_0ll,any_P_any_C_0ul\ ///
		any_P_any_C_1,any_P_any_C_1ll,any_P_any_C_1ul\ ///
		any_P_any_C_RD,any_P_any_C_RDll,any_P_any_C_RDul)
		matrix colnames any_P_any_C = Risk LL UL
		matrix rownames any_P_any_C = "Parent Any MH --> Child Any MH" No Yes "Risk Difference"
		mat list any_P_any_C
	}
	
	if `h'<=5 {
		matrix any_P_any_C=(9999,9999,9999\9999,9999,9999\ ///
		9999,9999,9999\ ///
		9999,9999,9999)
		matrix colnames any_P_any_C = Risk LL UL
		matrix rownames any_P_any_C = "Parent Any MH --> Child Any MH" No Yes "Risk Difference"
		mat list any_P_any_C
	}
	
	*** DIAGNOSIS * DIAGNOSIS: PARENT TO CHILD
	* empty cells (9999) if <=5 in overlap	
	foreach p in abuse ext neuro omood eat skiz bipolar ocd per dev {
		foreach c in abuse ext neuro omood eat skiz bipolar ocd per dev {		
			sum `c'_child if `p'_parent==1
			local h=r(sum)
			if `h' >= 5 {	
				logit `c'_child `p'_parent, or
				adjrr `p'_parent
				
				matrix F_C_0=r(R0)
				matrix F_C_0ll=(r(R0)-(1.96*r(R0_se)))
				matrix F_C_0ul=(r(R0)+(1.96*r(R0_se)))
				matrix F_C_1=r(R1)
				matrix F_C_1ll=(r(R1)-(1.96*r(R1_se)))
				matrix F_C_1ul=(r(R1)+(1.96*r(R1_se)))
				matrix F_C_RD=r(ARD)
				matrix F_C_RDll=(r(ARD)-(1.96*r(ARD_se)))
				matrix F_C_RDul=(r(ARD)+(1.96*r(ARD_se)))	
				
				matrix `p'_P_`c'_C=(9999,9999,9999\F_C_0,F_C_0ll,F_C_0ul\ ///
				F_C_1,F_C_1ll,F_C_1ul\ ///
				F_C_RD,F_C_RDll,F_C_RDul)
				matrix colnames `p'_P_`c'_C = Risk LL UL
				matrix rownames `p'_P_`c'_C = "Parent `p' --> Child `c'" No Yes "Risk Difference"
				mat list `p'_P_`c'_C 
			}
			
			if `h'<5 {
				matrix `p'_P_`c'_C =(9999,9999,9999\9999,9999,9999\ ///
				9999,9999,9999\ ///
				9999,9999,9999)
				matrix colnames `p'_P_`c'_C  = Risk LL UL
				matrix rownames `p'_P_`c'_C  = "Parent `p' --> Child `c'" No Yes "Risk Difference"
				mat list `p'_P_`c'_C 
			}	
		}
		
		matrix `p'_P_C=(`p'_P_abuse_C\ `p'_P_ext_C\ `p'_P_neuro_C\ `p'_P_omood_C\ `p'_P_eat_C\ `p'_P_skiz_C\ `p'_P_bipolar_C\ `p'_P_ocd_C\ `p'_P_per_C\ `p'_P_dev_C)
		
	}
	matrix P_C=(any_P_any_C\abuse_P_C\ext_P_C\neuro_P_C\omood_P_C\eat_P_C\skiz_P_C\bipolar_P_C\ocd_P_C\per_P_C\dev_P_C)
	mat list P_C
	
	esttab matrix(P_C) using $asa/table/RD_parent_predicting_child.csv, replace nomtitle
	
	
	*** ANY: CHILD TO PARENT	
	sum any_diag_parent if any_diag_child==1
	local h=r(sum)
	if `h' > 5 {	
	logit any_diag_parent any_diag_child, or
	adjrr any_diag_child
	matrix any_C_any_P_0=r(R0)
	matrix any_C_any_P_0ll=(r(R0)-(1.96*r(R0_se)))
	matrix any_C_any_P_0ul=(r(R0)+(1.96*r(R0_se)))
	matrix any_C_any_P_1=r(R1)
	matrix any_C_any_P_1ll=(r(R1)-(1.96*r(R1_se)))
	matrix any_C_any_P_1ul=(r(R1)+(1.96*r(R1_se)))
	matrix any_C_any_P_RD=r(ARD)
	matrix any_C_any_P_RDll=(r(ARD)-(1.96*r(ARD_se)))
	matrix any_C_any_P_RDul=(r(ARD)+(1.96*r(ARD_se)))	
	
	matrix any_C_any_P=(9999,9999,9999\any_C_any_P_0,any_C_any_P_0ll,any_C_any_P_0ul\ ///
	any_C_any_P_1,any_C_any_P_1ll,any_C_any_P_1ul\ ///
	any_C_any_P_RD,any_C_any_P_RDll,any_C_any_P_RDul)
	matrix colnames any_C_any_P = Risk LL UL
	matrix rownames any_C_any_P = "Child Any MH --> Parent Any MH" No Yes "Risk Difference"
	mat list any_C_any_P
	
	}
	
	if `h'<=5 {
		matrix any_C_any_P=(9999,9999,9999\9999,9999,9999\ ///
		9999,9999,9999\ ///
		9999,9999,9999)	
	matrix colnames any_C_any_P = Risk LL UL
	matrix rownames any_C_any_P = "Child Any MH --> Parent Any MH" No Yes "Risk Difference"
	mat list any_C_any_P
	}
	
	*** DIAGNOSIS * DIAGNOSIS: CHILD TO PARENT
	foreach c in abuse ext neuro omood eat skiz bipolar ocd per dev {
		foreach p in abuse ext neuro omood eat skiz bipolar ocd per dev {		
			sum `p'_parent if `c'_child==1
			local h=r(sum)
			if `h' >= 5 {	
				logit `p'_parent `c'_child, or
				adjrr `c'_child
				
				matrix C_P_0=r(R0)
				matrix C_P_0ll=(r(R0)-(1.96*r(R0_se)))
				matrix C_P_0ul=(r(R0)+(1.96*r(R0_se)))
				matrix C_P_1=r(R1)
				matrix C_P_1ll=(r(R1)-(1.96*r(R1_se)))
				matrix C_P_1ul=(r(R1)+(1.96*r(R1_se)))
				matrix C_P_RD=r(ARD)
				matrix C_P_RDll=(r(ARD)-(1.96*r(ARD_se)))
				matrix C_P_RDul=(r(ARD)+(1.96*r(ARD_se)))	
				
				matrix `c'_C_`p'_P=(9999,9999,9999\C_P_0,C_P_0ll,C_P_0ul\ ///
				C_P_1,C_P_1ll,C_P_1ul\ ///
				C_P_RD,C_P_RDll,C_P_RDul)
				matrix colnames `c'_C_`p'_P = Risk LL UL
				matrix rownames `c'_C_`p'_P = "Child `c' --> Parent `p'" No Yes "Risk Difference"
				mat list `c'_C_`p'_P
			}
			
			if `h'<5 {
				matrix `c'_C_`p'_P =(9999,9999,9999\9999,9999,9999\ ///
				9999,9999,9999\ ///
				9999,9999,9999)
				matrix colnames `c'_C_`p'_P  = Risk LL UL
				matrix rownames `c'_C_`p'_P  = "Child `c' --> Parent `p'" No Yes "Risk Difference"
				mat list `c'_C_`p'_P 
			}	
		}
		
		matrix `c'_C_P=(`c'_C_abuse_P\ `c'_C_ext_P\ `c'_C_neuro_P\ `c'_C_omood_P\ `c'_C_eat_P\ `c'_C_skiz_P\ `c'_C_bipolar_P\ `c'_C_ocd_P\ `c'_C_per_P\ `c'_C_dev_P)
		
	}
	matrix C_P=(any_C_any_P\abuse_C_P\ext_C_P\neuro_C_P\omood_C_P\eat_C_P\skiz_C_P\bipolar_C_P\ocd_C_P\per_C_P\dev_C_P)
	mat list C_P
	
	esttab matrix(C_P) using $asa/table/RD_child_predicting_parent.csv, replace nomtitle
	







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


