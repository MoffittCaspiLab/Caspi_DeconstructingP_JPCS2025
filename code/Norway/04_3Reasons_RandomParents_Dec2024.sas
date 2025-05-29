DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Parent_Child\03_3Reasons_RandomParents_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: 3 Reasons, Intergenerational Transmission of MH 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Parent_Child\03_3Reasons_RandomParents_Dec2024.sas;
* Modification Hx:	15-Oct-2024 Check code
*
***************************************************************************************************;

libname rawdat	"N:\durable\Data22\processed_data\ForRenate";
libname thr_par	"M:\p1074-renateh\2024_ThreeReasons\Parent_Child";

proc format;
	value SEX
		1 = "Male"
		2 = "Female";
	value NOYES
		0 = "No"
		1 = "Yes";
	value RESGRP
		19 = "Alive/resident 2006-19, or born 2006+ & res therafter"
		18 = "Died 2018: resident 2006-18, or born 2006+ & res til death"
		17 = "Died 2017: resident 2006-17, or born 2006+ & res til death"
		16 = "Died 2016: resident 2006-16, or born 2006+ & res til death"
		15 = "Died 2015: resident 2006-15, or born 2006+ & res til death"
		14 = "Died 2014: resident 2006-14, or born 2006+ & res til death"
		13 = "Died 2013: resident 2006-13, or born 2006+ & res til death"
		12 = "Died 2012: resident 2006-12, or born 2006+ & res til death"
		11 = "Died 2011: resident 2006-11, or born 2006+ & res til death"
		10 = "Died 2010: resident 2006-10, or born 2006+ & res til death"
		 9 = "Died 2009: resident 2006-09, or born 2006+ & res til death"
		 8 = "Died 2008: resident 2006-08, or born 2006+ & res til death"
		 7 = "Died 2007: resident 2006-07, or born 2006+ & res til death"
		 6 = "Died 2006: resident 2006-06, or born 2006+ & res til death";
	value OUTSAMP
		1 = "Alive & full-time resident of Norway, 2016-19"
		2 = "Full-time resident who died between 2006-19"
		3 = "Deceased < 2006"
		4 = "Deceased >= 2006, but not fully resident 2006-19"
		5 = "Non-resident or missing as at some point between 2006-19";
	value MHDX
		-1 = "MHDX: P-code with no number"
		 1 = "Acute stress reaction"
		 2 = "ADHD"
		 3 = "Adolescent behavior symptom/complaint"
		 4 = "Anxiety" 
		 5 = "Child behavior symptom/complaint"
		 6 = "Continence issues"
		 7 = "Depression"
		 8 = "Developmental delay/Learning problems"
		 9 = "Eating disorder"
		10 = "Feeling/behaving irritable/angry"
		11 = "Memory problems"
		12 = "Phobia/Compulsive disorder"
		13 = "Psychosis"
		14 = "PTSD"
		15 = "Sleep disturbance"		
		16 = "Somatization"
		17 = "Stammering/stuttering/tic"
		18 = "Substance abuse"
		19 = "Suicide/Suicide attempt"
		20 = "Psychological symptom/disease, NOS";
	value EDTRUNC
		0 = "No education and pre-school education (under school age)"
		1 = "Compulsary education (1-10y of ed)"
		2 = "Intermediate education (11-14y ed)"
		3 = "Higher education (14-20+y of ed)"
		9 = "Unspecified";
run;

data child_wide;
	set thr_par.child_wide_Dec2024;
run;

data parents_wide;
	set thr_par.family_demo_parMH_Dec2024;
run;

data parent_child;
	merge child_wide parents_wide;
	by w19_1011_lnr_k2_;

	if no_mom = 0 OR no_dad = 0;

run;

proc contents data = parent_child varnum; run;

* Find family NO and kid NO;
proc sort data = parent_child; by mom_id dad_id w19_1011_lnr_k2_; run;
data parent_child;
	set parent_child;
	by mom_id;

	retain family_no 0 last_dad "          " kid_no 0;

	if first.mom_id then do;
		family_no = family_no + 1;
		kid_no    = 0;
		last_dad  = dad_id;
	end;
	if mom_id = "          " and last_dad ne dad_id then kid_no = 0;
	if last_dad = dad_id then kid_no = kid_no + 1;
	if last_dad ne dad_id then do;
		family_no = family_no + 1;		
		kid_no    = kid_no + 1;
		last_dad  = dad_id;
	end;

	age_start1 = age_start;
	if age_start < 0 then age_start1 = 0;

	drop last_dad;
run;

* Randomize (either) parents;
data children (keep = w19_1011_lnr_k2_ male any_MH any_str any_adhd any_anx any_dep any_phb any_psy any_ptsd any_sex any_slp any_som any_sub any_sui any_per any_oth
						any_chad any_con any_dev any_stm family_no)
	 rand_par (keep = rand_id mom_id dad_id r_any_MH r_any_str r_any_adhd r_any_anx r_any_dep r_any_phb r_any_psy r_any_ptsd r_any_sex r_any_slp r_any_som r_any_sub r_any_sui 
							r_any_per r_any_oth r_family_no);
	 set parent_child;

	 rand_id = rand("uniform");

	 array e [16]	e_any_MH e_any_str e_any_adhd e_any_anx e_any_dep e_any_phb e_any_psy e_any_ptsd e_any_sex e_any_slp e_any_som 
					e_any_sub e_any_sui  e_any_per e_any_oth family_no;
	 array rand [16] r_any_MH r_any_str r_any_adhd r_any_anx r_any_dep r_any_phb r_any_psy r_any_ptsd r_any_sex r_any_slp r_any_som 
					 r_any_sub r_any_sui  r_any_per r_any_oth r_family_no;

	 do i = 1 to 16;
		rand[i] = e[i];
	 end;
run;

proc sort data = rand_par; 
		by rand_id; 
	run;
data random_parent; 
	merge children rand_par; 
run;

proc sort data = random_parent; by r_family_no; run;

* ODDS RATIOS WITH RANDOM PARENTS;
%macro getORS (MH = , par = , pMH = , cl = );
	proc surveyfreq data = random_parent; 
		cluster &cl;
		table any_&MH*&par._any_&pMH / OR; 
		ods output OddsRatio = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;
%mend getORs;

%macro OR_risk(MH = , par = , cl = );

	proc surveyfreq data = random_parent;
		cluster &cl;
		table any_&MH*&par._any_MH / OR; 
		ods output OddsRatio = &par.MH_OR;
	data OR; 
		set &par.MH_OR; 
		run;
	
	%getORS(MH = &MH, par = &par, pMH = adhd, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = sub, cl = &cl);

	%getORS(MH = &MH, par = &par, pMH = dep, cl = &cl);	
	%getORS(MH = &MH, par = &par, pMH = str, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = anx, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = phb, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = ptsd, cl = &cl);	
	%getORS(MH = &MH, par = &par, pMH = som, cl = &cl);
	
	%getORS(MH = &MH, par = &par, pMH = psy, cl = &cl);

	%getORS(MH = &MH, par = &par, pMH = oth, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = slp, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = sex, cl = &cl);
	%getORS(MH = &MH, par = &par, pMH = sui, cl = &cl);	
	%getORS(MH = &MH, par = &par, pMH = per, cl = &cl);

	data OR_&par&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;
%mend OR_risk;


* Either parent;
%OR_risk(MH = MH,   par = r, cl = r_family_no);

%OR_risk(MH = sub,  par = r, cl = r_family_no);
%OR_risk(MH = adhd, par = r, cl = r_family_no);
%OR_risk(MH = chad, par = r, cl = r_family_no);

%OR_risk(MH = dep,  par = r, cl = r_family_no);
%OR_risk(MH = str,  par = r, cl = r_family_no);
%OR_risk(MH = anx,  par = r, cl = r_family_no);
%OR_risk(MH = phb,  par = r, cl = r_family_no);
%OR_risk(MH = ptsd, par = r, cl = r_family_no);
%OR_risk(MH = som,  par = r, cl = r_family_no);

%OR_risk(MH = psy,  par = r, cl = r_family_no);

%OR_risk(MH = oth,  par = r, cl = r_family_no);
%OR_risk(MH = slp,  par = r, cl = r_family_no);
%OR_risk(MH = sex,  par = r, cl = r_family_no);
%OR_risk(MH = per,  par = r, cl = r_family_no);
%OR_risk(MH = sui,  par = r, cl = r_family_no);
%OR_risk(MH = con,  par = r, cl = r_family_no);
%OR_risk(MH = dev,  par = r, cl = r_family_no);
%OR_risk(MH = stm,  par = r, cl = r_family_no);


data OR_all_r;
	set OR_rMH  OR_rchad OR_radhd OR_rsub
		OR_rdep OR_ranx  OR_rstr  OR_rphb OR_rsom OR_rptsd   
		OR_rpsy  
		OR_rslp OR_rcon  OR_rdev  OR_roth OR_rstm OR_rsui OR_rsex OR_rper;
data OR_all_r;
	set OR_all_r;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_rMH  OR_rchad OR_radhd OR_rsub
			OR_rdep OR_ranx  OR_rstr  OR_rphb OR_rsom OR_rptsd   
			OR_rpsy  
			OR_rslp OR_rcon  OR_rdev  OR_roth OR_rdem OR_rstm  OR_rsui OR_rsex OR_rper
		   	rMH_OR  rCHAD_OR rADHD_OR rSUB_OR
			rDEP_OR rANX_OR  rSTR_OR rPHB_OR rSOM_OR rPTSD_OR  
		   	rPSY_OR
			rSLP_OR rCON_OR  rDEV_OR rOTH_OR rSTM_OR rSUI_OR rSEX_OR rPER_OR;
run;
quit;

proc export data = OR_all_r
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_RandomParent_Dec2024.csv"
	dbms = csv
	replace;
run;
