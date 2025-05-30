DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Parent_Child\03_3Reasons_ChildrenParents_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: 3 Reasons, Intergenerational Transmission of MH 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Parent_Child\03_3Reasons_ChildrenParents_Dec2024.sas;
* Modification Hx:	14-Oct-2024	Check code and add clustering to OR CI calcualtions
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

	if N(m_any_MH, d_any_MH) = 2 then e_any_MHn = SUM(m_any_MH, d_any_MH);

	if e_any_MHn = 1 then e_any_MHn1 = 0;
		else if e_any_MHn = 0 then e_any_MHn1 = 1;
		else if e_any_MHn = 2 then e_any_MHn1 = 2;

	if DOB ne . and DOB < MDY(01,01,2000) then delete;

	dx_variety   = SUM(any_sub, any_adhd, any_chad, 
					   any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, any_psy, 
					   any_oth, any_slp, any_sex, any_per, any_sui, any_con, any_dev, any_stm);
	m_dx_variety = SUM(m_any_sub, m_any_adhd, m_any_dep, m_any_str, m_any_anx, m_any_phb, m_any_ptsd, m_any_som, m_any_psy, 
					   m_any_oth, m_any_slp, m_any_sex, m_any_per, m_any_sui);
	d_dx_variety = SUM(d_any_sub, d_any_adhd, d_any_dep, d_any_str, d_any_anx, d_any_phb, d_any_ptsd, d_any_som, d_any_psy, 
					   d_any_oth, d_any_slp, d_any_sex, d_any_per, d_any_sui);
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

	if m_DOB ne . then mage_birth = YRDIF(m_DOB, DOB, 'AGE');
	if d_DOB ne . then dage_birth = YRDIF(d_DOB, DOB, 'AGE');

	if N(m_any_MH, d_any_MH) = 2 then e_sub_n  = SUM(m_any_sub,  d_any_sub);
	if N(m_any_MH, d_any_MH) = 2 then e_adhd_n = SUM(m_any_adhd, d_any_adhd); 
	if N(m_any_MH, d_any_MH) = 2 then e_dep_n  = SUM(m_any_dep,  d_any_dep);
	if N(m_any_MH, d_any_MH) = 2 then e_str_n  = SUM(m_any_str,  d_any_str);
	if N(m_any_MH, d_any_MH) = 2 then e_anx_n  = SUM(m_any_anx,  d_any_anx);
	if N(m_any_MH, d_any_MH) = 2 then e_phb_n  = SUM(m_any_phb,  d_any_phb);
	if N(m_any_MH, d_any_MH) = 2 then e_ptsd_n = SUM(m_any_ptsd, d_any_ptsd);
	if N(m_any_MH, d_any_MH) = 2 then e_som_n  = SUM(m_any_som,  d_any_som);
	if N(m_any_MH, d_any_MH) = 2 then e_psy_n  = SUM(m_any_psy,  d_any_psy);
	if N(m_any_MH, d_any_MH) = 2 then e_oth_n  = SUM(m_any_oth,  d_any_oth);
	if N(m_any_MH, d_any_MH) = 2 then e_slp_n  = SUM(m_any_slp,  d_any_slp);
	if N(m_any_MH, d_any_MH) = 2 then e_sex_n  = SUM(m_any_sex,  d_any_sex);
	if N(m_any_MH, d_any_MH) = 2 then e_per_n  = SUM(m_any_per,  d_any_per);
	if N(m_any_MH, d_any_MH) = 2 then e_sui_n  = SUM(m_any_sui,  d_any_sui);

	array dx[14]	e_sub_n e_adhd_n e_dep_n e_str_n e_anx_n e_phb_n e_ptsd_n e_som_n e_psy_n e_oth_n e_slp_n e_sex_n e_per_n e_sui_n;

	do i = 1 to 14;
		if dx[i] = 0 and e_any_MH = 1 then dx[i] = 3;
	end;

	drop last_dad;
run;

proc means data = parent_child;
	var mage_birth dage_birth;
run;

proc freq data = parent_child;
	table male DOB no_mom no_dad kid_no;
run;

proc means data = parent_child;
	var kid_no age_start age_start1 age_end dx_variety;
run;

proc means data = parent_child;
	var kid_no family_no;
run;

proc means data = parent_child;
	var m_age_start m_age_end m_dx_variety;
	where m_dx_variety ne .;
proc means data = parent_child;
	var d_age_start d_age_end d_dx_variety;
	where d_dx_variety ne .;
run;

data thr_par.included;
	set parent_child;

	keep w19_1011_lnr_k2_ mom_id dad_id family_no kid_no;
run;

* Risk Differences;
proc freq data = parent_child; 
	table e_any_sub*any_sub  / RISKDIFF;
	table e_any_sub*any_adhd / RISKDIFF;
	table e_any_sub*any_dep  / RISKDIFF;
	table e_any_sub*any_psy  / RISKDIFF;

	table any_sub*e_any_sub  / RISKDIFF;
	table any_sub*e_any_adhd / RISKDIFF;
	table any_sub*e_any_dep  / RISKDIFF;
	table any_sub*e_any_psy  / RISKDIFF;

	table e_any_dep*any_dep  / RISKDIFF;
	table e_any_dep*any_anx  / RISKDIFF;
	table e_any_dep*any_sub  / RISKDIFF;
	table e_any_dep*any_psy  / RISKDIFF;

	table any_dep*e_any_dep  / RISKDIFF;
	table any_dep*e_any_anx  / RISKDIFF;
	table any_dep*e_any_sub  / RISKDIFF;
	table any_dep*e_any_psy  / RISKDIFF;
run;


* Risk differences ... P -> C ;
%macro getRDs (MH = , pMH = );

	proc surveyfreq data = parent_child; 
		cluster family_no;
		table e_any_&MH*any_&pMH / RISKDIFF;
		ods output Risk2 = &MH._RD;
	run;

	data RD; 
		set RD &MH._RD;
	run;
%mend getRDs;

%macro RD_risk(MH = );

	proc surveyfreq data = parent_child; 
		cluster family_no;
		table e_any_&MH*any_adhd / RISKDIFF; 
		ods output Risk2 = &MH._RD;
	run;
	data RD; set &MH._RD; run;

	%getRDs(MH = &MH, pMH = sub);
	%getRDs(MH = &MH, pMH = chad);
	
	%getRDs(MH = &MH, pMH = dep);
	%getRDs(MH = &MH, pMH = str);
	%getRDs(MH = &MH, pMH = anx);
	%getRDs(MH = &MH, pMH = phb);
	%getRDs(MH = &MH, pMH = ptsd);
	%getRDs(MH = &MH, pMH = som);
		
	%getRDs(MH = &MH, pMH = psy);
	
	%getRDs(MH = &MH, pMH = oth);
	%getRDs(MH = &MH, pMH = slp);
	%getRDs(MH = &MH, pMH = sex);
	%getRDs(MH = &MH, pMH = per);
	%getRDs(MH = &MH, pMH = sui);
	%getRDs(MH = &MH, pMH = con);
	%getRDs(MH = &MH, pMH = dev);
	%getRDs(MH = &MH, pMH = stm);
	
	data RD_&MH; 
		set RD;
	run;

%mend RD_risk;

* P -> C;
%RD_risk(MH = sub);
%RD_risk(MH = adhd);
%RD_risk(MH = dep);
%RD_risk(MH = str);
%RD_risk(MH = anx);
%RD_risk(MH = phb);
%RD_risk(MH = ptsd);
%RD_risk(MH = som);
%RD_risk(MH = psy);
%RD_risk(MH = oth);
%RD_risk(MH = slp);
%RD_risk(MH = sex);
%RD_risk(MH = per);
%RD_risk(MH = sui);

data RD_all_pp;
	set RD_adhd RD_sub  
		RD_dep RD_str RD_anx RD_phb RD_ptsd RD_som 
		RD_psy
		RD_oth RD_slp RD_sex RD_per RD_sui;
run;

proc datasets;
	delete	RD RD_sub RD_adhd 
			RD_dep RD_str RD_anx RD_phb RD_ptsd RD_som 
			RD_psy
			RD_oth RD_slp RD_sex RD_per RD_sui

 		   	MH_RD  
			adhd_RD sub_RD 
			str_RD  anx_RD dep_RD phb_RD som_RD ptsd_RD
			psy_RD 
			sex_RD  slp_RD sui_RD per_RD oth_RD;
run;
quit;

proc export data = RD_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\C_Rsk_when_P_hasDx_RiskDiff_17Apr2025.csv"
	dbms = csv
	replace;
run;

* Risk differences ... C -> P ;
%macro getRDs (MH = , pMH = );
	proc surveyfreq data = parent_child; 
		cluster family_no;
		table any_&MH*e_any_&pMH / RISKDIFF;
		ods output Risk2 = &MH._RD;
	run;
	data RD; 
		set RD &MH._RD;
	run;
%mend getRDs;

%macro RD_risk(MH = );

	proc surveyfreq data = parent_child; 
		cluster family_no;
		table any_&MH*e_any_adhd / RISKDIFF;
		ods output Risk2 = &MH._RD;
	run;
	data RD; set &MH._RD; run;

	%getRDs(MH = &MH, pMH = sub);
	
	%getRDs(MH = &MH, pMH = dep);
	%getRDs(MH = &MH, pMH = str);
	%getRDs(MH = &MH, pMH = anx);
	%getRDs(MH = &MH, pMH = phb);
	%getRDs(MH = &MH, pMH = ptsd);
	%getRDs(MH = &MH, pMH = som);
		
	%getRDs(MH = &MH, pMH = psy);
	
	%getRDs(MH = &MH, pMH = oth);
	%getRDs(MH = &MH, pMH = slp);
	%getRDs(MH = &MH, pMH = sex);
	%getRDs(MH = &MH, pMH = per);
	%getRDs(MH = &MH, pMH = sui);
	
	data RD_&MH; 
		set RD;
	run;

%mend RD_risk;

* C -> P;
%RD_risk(MH = sub);
%RD_risk(MH = adhd);
%RD_risk(MH = chad);
%RD_risk(MH = dep);
%RD_risk(MH = str);
%RD_risk(MH = anx);
%RD_risk(MH = phb);
%RD_risk(MH = ptsd);
%RD_risk(MH = som);
%RD_risk(MH = psy);
%RD_risk(MH = oth);
%RD_risk(MH = slp);
%RD_risk(MH = sex);
%RD_risk(MH = per);
%RD_risk(MH = sui);
%RD_risk(MH = con);
%RD_risk(MH = dev);
%RD_risk(MH = stm);


data RD_all_pp;
	set RD_adhd RD_sub RD_chad 
		RD_dep RD_str RD_anx RD_phb RD_ptsd RD_som 
		RD_psy
		RD_oth RD_slp RD_sex RD_per RD_sui RD_con RD_dev RD_stm;
run;

proc datasets;
	delete	RD RD_sub RD_adhd RD_chad
			RD_dep RD_str RD_anx RD_phb RD_ptsd RD_som 
			RD_psy
			RD_oth RD_slp RD_sex RD_per RD_sui RD_con RD_dev RD_stm

 		   	MH_RD  
			adhd_RD sub_RD chad_RD
			str_RD  anx_RD dep_RD phb_RD som_RD ptsd_RD
			psy_RD 
			sex_RD  slp_RD sui_RD per_RD oth_RD con_RD dev_RD stm_RD;
run;
quit;

proc export data = RD_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\P_Rsk_when_C_hasDx_RiskDiff_17Apr2025.csv"
	dbms = csv
	replace;
run;



* Follow-up analyses;
data parent_child1;
	set parent_child;

	if e_any_adhd = 1 OR e_any_sub = 1 then e_any_ext = 1;
		else if N(e_any_adhd, e_any_sub) = 2 then e_any_ext = 0;

	if e_any_dep = 1 OR e_any_str = 1 OR e_any_anx = 1 OR e_any_phb = 1 OR e_any_ptsd = 1 OR e_any_som = 1 then e_any_int = 1;
		else if N(e_any_dep, e_any_str, e_any_anx, e_any_phb, e_any_ptsd, e_any_som) = 6 then e_any_int = 0;

	if e_any_str = 1 OR e_any_anx = 1 OR e_any_phb = 1 OR e_any_ptsd = 1 OR e_any_som = 1 then e_int_nodep = 1;
		else if N(e_any_str, e_any_anx, e_any_phb, e_any_ptsd, e_any_som) = 5 then e_int_nodep = 0;
	if e_any_dep = 1 OR e_any_anx = 1 OR e_any_phb = 1 OR e_any_ptsd = 1 OR e_any_som = 1 then e_int_nostr = 1;
		else if N(e_any_dep, e_any_anx, e_any_phb, e_any_ptsd, e_any_som) = 5 then e_int_nostr = 0;
	if e_any_dep = 1 OR e_any_str = 1 OR e_any_phb = 1 OR e_any_ptsd = 1 OR e_any_som = 1 then e_int_noanx = 1;
		else if N(e_any_dep, e_any_str, e_any_phb, e_any_ptsd, e_any_som) = 5 then e_int_noanx = 0;
	if e_any_dep = 1 OR e_any_str = 1 OR e_any_anx = 1 OR e_any_ptsd = 1 OR e_any_som = 1 then e_int_nophb = 1;
		else if N(e_any_dep, e_any_str, e_any_anx, e_any_ptsd, e_any_som) = 5 then e_int_nophb = 0;
	if e_any_dep = 1 OR e_any_str = 1 OR e_any_anx = 1 OR e_any_phb = 1 OR e_any_som = 1 then e_int_noptsd = 1;
		else if N(e_any_dep, e_any_str, e_any_anx, e_any_phb, e_any_som) = 5 then e_int_noptsd = 0;
	if e_any_dep = 1 OR e_any_str = 1 OR e_any_anx = 1 OR e_any_phb = 1 OR e_any_ptsd = 1 then e_int_nosom = 1;
		else if N(e_any_dep, e_any_str, e_any_anx, e_any_phb, e_any_ptsd) = 5 then e_int_nosom = 0;

	if e_any_oth = 1 OR e_any_slp = 1 OR e_any_sex = 1 OR e_any_per = 1 OR e_any_sui = 1 then e_any_other = 1;
		else if N(e_any_oth, e_any_slp, e_any_sex, e_any_per, e_any_sui) = 5 then e_any_other = 0;
	if e_any_slp = 1 OR e_any_sex = 1 OR e_any_per = 1 OR e_any_sui = 1 then e_oth_nooth = 1;
		else if N(e_any_slp, e_any_sex, e_any_per, e_any_sui) = 4 then e_oth_nooth = 0;
	if e_any_oth = 1 OR e_any_sex = 1 OR e_any_per = 1 OR e_any_sui = 1 then e_oth_noslp = 1;
		else if N(e_any_oth, e_any_sex, e_any_per, e_any_sui) = 4 then e_oth_noslp = 0;
	if e_any_oth = 1 OR e_any_slp = 1 OR e_any_per = 1 OR e_any_sui = 1 then e_oth_nosex = 1;
		else if N(e_any_oth, e_any_slp, e_any_per, e_any_sui) = 4 then e_oth_nosex = 0;
	if e_any_oth = 1 OR e_any_slp = 1 OR e_any_sex = 1 OR e_any_sui = 1 then e_oth_noper = 1;
		else if N(e_any_oth, e_any_slp, e_any_sex, e_any_sui) = 4 then e_oth_noper = 0;
	if e_any_oth = 1 OR e_any_slp = 1 OR e_any_sex = 1 OR e_any_per = 1 then e_oth_nosui = 1;
		else if N(e_any_oth, e_any_slp, e_any_sex, e_any_per) = 4 then e_oth_nosui = 0;
run;


proc surveyfreq data = parent_child; 
	cluster family_no;
	table e_any_MH*any_MH / RISKDIFF;
run;
proc surveyfreq data = parent_child; 
	cluster family_no;
	table any_MH*e_any_MH / RISKDIFF;
run;


* Number of parents with dx;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_MH*e_any_MHn;
run;

proc surveyfreq data = parent_child;
	cluster family_no;
	table any_adhd*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_adhd*e_adhd_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_sub*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_sub*e_sub_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_chad*e_any_MHn;
run;

proc surveyfreq data = parent_child;
	cluster family_no;
	table any_dep*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_dep*e_dep_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_str*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_str*e_str_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_anx*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_anx*e_anx_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_phb*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_phb*e_phb_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_ptsd*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_ptsd*e_ptsd_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_som*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_som*e_som_n;
run;

proc surveyfreq data = parent_child;
	cluster family_no;
	table any_psy*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_psy*e_psy_n;
run;

proc surveyfreq data = parent_child;
	cluster family_no;
	table any_oth*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_oth*e_oth_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_slp*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_slp*e_slp_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_sex*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_sex*e_sex_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_per*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_per*e_per_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_sui*e_any_MHn;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_sui*e_sui_n;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_con*e_any_MHn;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_dev*e_any_MHn;
run;
proc surveyfreq data = parent_child;
	cluster family_no;
	table any_stm*e_any_MHn;
run;

* Additional probes;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_adhd*e_any_sub;
	where e_adhd_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_adhd*e_any_int;
	where e_adhd_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_adhd*e_any_psy;
	where e_adhd_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_adhd*e_any_other;
	where e_adhd_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sub*e_any_adhd;
	where e_sub_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sub*e_any_int;
	where e_sub_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sub*e_any_psy;
	where e_sub_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sub*e_any_other;
	where e_sub_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_dep*e_any_ext;
	where e_dep_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_dep*e_int_nodep;
	where e_dep_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_dep*e_any_psy;
	where e_dep_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_dep*e_any_other;
	where e_dep_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_str*e_any_ext;
	where e_str_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_str*e_int_nostr;
	where e_str_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_str*e_any_psy;
	where e_str_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_str*e_any_other;
	where e_str_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_anx*e_any_ext;
	where e_anx_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_anx*e_int_noanx;
	where e_anx_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_anx*e_any_psy;
	where e_anx_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_anx*e_any_other;
	where e_anx_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_phb*e_any_ext;
	where e_phb_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_phb*e_int_nophb;
	where e_phb_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_phb*e_any_psy;
	where e_phb_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_phb*e_any_other;
	where e_phb_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_ptsd*e_any_ext;
	where e_ptsd_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_ptsd*e_int_noptsd;
	where e_ptsd_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_ptsd*e_any_psy;
	where e_ptsd_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_ptsd*e_any_other;
	where e_ptsd_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_som*e_any_ext;
	where e_som_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_som*e_int_nosom;
	where e_som_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_som*e_any_psy;
	where e_som_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_som*e_any_other;
	where e_som_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_psy*e_any_ext;
	where e_psy_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_psy*e_any_int;
	where e_psy_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_psy*e_any_other;
	where e_psy_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_oth*e_any_ext;
	where e_oth_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_oth*e_any_int;
	where e_oth_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_oth*e_any_psy;
	where e_oth_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_oth*e_oth_nooth;
	where e_oth_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_slp*e_any_ext;
	where e_slp_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_slp*e_any_int;
	where e_slp_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_slp*e_any_psy;
	where e_slp_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_slp*e_oth_noslp;
	where e_slp_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sex*e_any_ext;
	where e_sex_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sex*e_any_int;
	where e_sex_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sex*e_any_psy;
	where e_sex_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sex*e_oth_nosex;
	where e_sex_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_per*e_any_ext;
	where e_per_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_per*e_any_int;
	where e_per_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_per*e_any_psy;
	where e_per_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_per*e_oth_noper;
	where e_per_n = 3;
run;

proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sui*e_any_ext;
	where e_sui_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sui*e_any_int;
	where e_sui_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sui*e_any_psy;
	where e_sui_n = 3;
proc surveyfreq data = parent_child1;
	cluster family_no;
	table any_sui*e_oth_nosui;
	where e_sui_n = 3;
run;
