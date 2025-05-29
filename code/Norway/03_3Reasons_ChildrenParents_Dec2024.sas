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

proc freq data = parent_child;
	table male DOB no_mom no_dad kid_no;
run;

proc means data = parent_child;
	var kid_no age_start age_start1 age_end;
run;

proc means data = parent_child;
	var m_age_start m_age_end d_age_start d_age_end;
run;

data thr_par.included;
	set parent_child;

	keep w19_1011_lnr_k2_ mom_id dad_id family_no kid_no;
run;

* Person-level prevalence of dx's;
ods output OneWayFreqs = MHdx;
proc freq data = parent_child; 
	table any_MH  any_sub any_adhd any_chad any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui any_con any_dev any_stm
		  m_any_MH  m_any_sub m_any_adhd m_any_dep m_any_str m_any_anx m_any_phb m_any_ptsd m_any_som m_any_psy
		  m_any_oth m_any_slp m_any_sex  m_any_per m_any_sui
		  d_any_MH  d_any_sub d_any_adhd d_any_dep d_any_str d_any_anx d_any_phb d_any_ptsd d_any_som d_any_psy
		  d_any_oth d_any_slp d_any_sex  d_any_per d_any_sui
		  e_any_MH  e_any_sub e_any_adhd e_any_dep e_any_str e_any_anx e_any_phb e_any_ptsd e_any_som e_any_psy
		  e_any_oth e_any_slp e_any_sex  e_any_per e_any_sui; 
run;
ods output close;

data MHdx1; 
	set MHdx; 

	length who $6;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "child"; code = "Any Mental Health Disorder"; 					 end;
		else if code = "any_sub"  then do; who = "child"; code = "Substance abuse";            					 end;
		else if code = "any_adhd" then do; who = "child"; code = "ADHD";					 					 end;
		else if code = "any_chad" then do; who = "child"; code = "Child/Adolescent behavior symptom/complaint";  end;
		else if code = "any_dep"  then do; who = "child"; code = "Depression";									 end;
		else if code = "any_str"  then do; who = "child"; code = "Acute stress reaction";       				 end;
		else if code = "any_anx"  then do; who = "child"; code = "Anxiety disorder";							 end;
		else if code = "any_phb"  then do; who = "child"; code = "Phobia/Compulsive disorder";					 end;
		else if code = "any_ptsd" then do; who = "child"; code = "PTSD";										 end;
		else if code = "any_som"  then do; who = "child"; code = "Somatization";								 end;
		else if code = "any_psy"  then do; who = "child"; code = "Psychosis";									 end;
		else if code = "any_oth"  then do; who = "child"; code = "Psychological disorders, NOS";				 end;
		else if code = "any_slp"  then do; who = "child"; code = "Sleep disturbance";							 end;
		else if code = "any_sex"  then do; who = "child"; code = "Sexual concern";								 end;
		else if code = "any_per"  then do; who = "child"; code = "Personality disorder";						 end;
		else if code = "any_sui"  then do; who = "child"; code = "Suicide/Suicide attempt";						 end;
		else if code = "any_con"  then do; who = "child"; code = "Continence issue";							 end;
		else if code = "any_dev"  then do; who = "child"; code = "Developmental delay/Learning problems";        end;
		else if code = "any_stm"  then do; who = "child"; code = "Stammering/stuttering/tic";					 end;

		else if code = "m_any_MH"   then do; who = "mom"; code = "Any Mental Health Disorder"; 					 end;
		else if code = "m_any_sub"  then do; who = "mom"; code = "Substance abuse";            					 end;
		else if code = "m_any_adhd" then do; who = "mom"; code = "ADHD";					 					 end;
		else if code = "m_any_dep"  then do; who = "mom"; code = "Depression";									 end;
		else if code = "m_any_str"  then do; who = "mom"; code = "Acute stress reaction";       				 end;
		else if code = "m_any_anx"  then do; who = "mom"; code = "Anxiety disorder";							 end;
		else if code = "m_any_phb"  then do; who = "mom"; code = "Phobia/Compulsive disorder";					 end;
		else if code = "m_any_ptsd" then do; who = "mom"; code = "PTSD";										 end;
		else if code = "m_any_som"  then do; who = "mom"; code = "Somatization";								 end;
		else if code = "m_any_psy"  then do; who = "mom"; code = "Psychosis";									 end;
		else if code = "m_any_oth"  then do; who = "mom"; code = "Psychological disorders, NOS";				 end;
		else if code = "m_any_slp"  then do; who = "mom"; code = "Sleep disturbance";							 end;
		else if code = "m_any_sex"  then do; who = "mom"; code = "Sexual concern";								 end;
		else if code = "m_any_per"  then do; who = "mom"; code = "Personality disorder";						 end;
		else if code = "m_any_sui"  then do; who = "mom"; code = "Suicide/Suicide attempt";						 end;

		else if code = "d_any_MH"   then do; who = "dad"; code = "Any Mental Health Disorder"; 					 end;
		else if code = "d_any_sub"  then do; who = "dad"; code = "Substance abuse";            					 end;
		else if code = "d_any_adhd" then do; who = "dad"; code = "ADHD";					 					 end;
		else if code = "d_any_dep"  then do; who = "dad"; code = "Depression";									 end;
		else if code = "d_any_str"  then do; who = "dad"; code = "Acute stress reaction";       				 end;
		else if code = "d_any_anx"  then do; who = "dad"; code = "Anxiety disorder";							 end;
		else if code = "d_any_phb"  then do; who = "dad"; code = "Phobia/Compulsive disorder";					 end;
		else if code = "d_any_ptsd" then do; who = "dad"; code = "PTSD";										 end;
		else if code = "d_any_som"  then do; who = "dad"; code = "Somatization";								 end;
		else if code = "d_any_psy"  then do; who = "dad"; code = "Psychosis";									 end;
		else if code = "d_any_oth"  then do; who = "dad"; code = "Psychological disorders, NOS";				 end;
		else if code = "d_any_slp"  then do; who = "dad"; code = "Sleep disturbance";							 end;
		else if code = "d_any_sex"  then do; who = "dad"; code = "Sexual concern";								 end;
		else if code = "d_any_per"  then do; who = "dad"; code = "Personality disorder";						 end;
		else if code = "d_any_sui"  then do; who = "dad"; code = "Suicide/Suicide attempt";						 end;

		else if code = "e_any_MH"   then do; who = "either"; code = "Any Mental Health Disorder"; 				 end;
		else if code = "e_any_sub"  then do; who = "either"; code = "Substance abuse";            				 end;
		else if code = "e_any_adhd" then do; who = "either"; code = "ADHD";					 					 end;
		else if code = "e_any_dep"  then do; who = "either"; code = "Depression";								 end;
		else if code = "e_any_str"  then do; who = "either"; code = "Acute stress reaction";       				 end;
		else if code = "e_any_anx"  then do; who = "either"; code = "Anxiety disorder";							 end;
		else if code = "e_any_phb"  then do; who = "either"; code = "Phobia/Compulsive disorder";				 end;
		else if code = "e_any_ptsd" then do; who = "either"; code = "PTSD";										 end;
		else if code = "e_any_som"  then do; who = "either"; code = "Somatization";								 end;
		else if code = "e_any_psy"  then do; who = "either"; code = "Psychosis";								 end;
		else if code = "e_any_oth"  then do; who = "either"; code = "Psychological disorders, NOS";				 end;
		else if code = "e_any_slp"  then do; who = "either"; code = "Sleep disturbance";						 end;
		else if code = "e_any_sex"  then do; who = "either"; code = "Sexual concern";							 end;
		else if code = "e_any_per"  then do; who = "either"; code = "Personality disorder";						 end;
		else if code = "e_any_sui"  then do; who = "either"; code = "Suicide/Suicide attempt";					 end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

proc export data = MHdx
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ParentChild_Prevalence_Dec2024.csv"
	dbms = csv
	replace;
run;

/*	*	What does clustering within mom_id do to the estimates?; 
	*	NOT MUCH, but run it with clustering anyway;

proc freq data = parent_child;
	table any_mh*e_any_MH / RELRISK;
run;
proc surveyfreq data = parent_child;
	table any_dep*e_any_phb / OR;
run;
proc surveyfreq data = parent_child;
	cluster mom_id;
	table any_dep*e_any_phb / OR;
	ods output OddsRatio = OR_test;
run;
*/

%macro getORS (MH = , par = , pMH = , cl = );
	proc surveyfreq data = parent_child1; 
		cluster &cl;
		table any_&MH*&par._any_&pMH / OR; 
		ods output OddsRatio = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;
%mend getORs;

%macro OR_risk(MH = , par = , cl = );

	proc surveyfreq data = parent_child1;
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
data parent_child1; set parent_child; run;

%OR_risk(MH = MH,   par = e, cl = family_no);

%OR_risk(MH = sub,  par = e, cl = family_no);
%OR_risk(MH = adhd, par = e, cl = family_no);
%OR_risk(MH = chad, par = e, cl = family_no);

%OR_risk(MH = dep,  par = e, cl = family_no);
%OR_risk(MH = str,  par = e, cl = family_no);
%OR_risk(MH = anx,  par = e, cl = family_no);
%OR_risk(MH = phb,  par = e, cl = family_no);
%OR_risk(MH = ptsd, par = e, cl = family_no);
%OR_risk(MH = som,  par = e, cl = family_no);

%OR_risk(MH = psy,  par = e, cl = family_no);

%OR_risk(MH = oth,  par = e, cl = family_no);
%OR_risk(MH = slp,  par = e, cl = family_no);
%OR_risk(MH = sex,  par = e, cl = family_no);
%OR_risk(MH = per,  par = e, cl = family_no);
%OR_risk(MH = sui,  par = e, cl = family_no);
%OR_risk(MH = con,  par = e, cl = family_no);
%OR_risk(MH = dev,  par = e, cl = family_no);
%OR_risk(MH = stm,  par = e, cl = family_no);

data OR_all_e;
	set OR_eMH  OR_esub OR_eadhd OR_echad 
		OR_edep OR_estr OR_eanx  OR_ephb  OR_eptsd OR_esom 
		OR_epsy  
		OR_eoth OR_eslp OR_esex  OR_eper  OR_esui  OR_econ OR_edev OR_estm;
data OR_all_e;
	set OR_all_e;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_eMH  OR_echad OR_eadhd OR_esub
			OR_edep OR_eanx  OR_estr  OR_ephb OR_esom OR_eptsd   
			OR_epsy  
			OR_eslp OR_econ  OR_edev  OR_eoth OR_estm  OR_esui OR_esex OR_eper
		   	eMH_OR  eCHAD_OR eADHD_OR eSUB_OR
			eDEP_OR eANX_OR  eSTR_OR ePHB_OR eSOM_OR ePTSD_OR  
		   	ePSY_OR
			eSLP_OR eCON_OR  eDEV_OR eOTH_OR eSTM_OR eSUI_OR eSEX_OR ePER_OR;
run;
quit;

proc export data = OR_all_e
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_EitherParent_Dec2024.csv"
	dbms = csv
	replace;
run;

* Get Log OR's for meta analysis;
%macro getLogORS (MH = , par = , pMH = , cl = );
	proc surveylogistic data = parent_child1; 
		cluster &cl;
		model any_&MH (event = '1') = &par._any_&pMH;
		ods output ParameterEstimates = &par.MH_OR; 
	run;
	data OR; 
		set OR &par.MH_OR;
	run;
%mend getLogORs;

%macro LogOR_risk(MH = , par = , cl = );

	proc surveylogistic data = parent_child1;
		cluster &cl;
		model any_&MH (event = '1') = &par._any_adhd; 
		ods output ParameterEstimates = &par.adhd_OR;
	data OR; 
		set &par.adhd_OR; 
	run;
	
	%getLogORs(MH = &MH, par = &par, pMH = MH, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = sub, cl = &cl);

	%getLogORs(MH = &MH, par = &par, pMH = dep, cl = &cl);	
	%getLogORs(MH = &MH, par = &par, pMH = str, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = anx, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = phb, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = ptsd, cl = &cl);	
	%getLogORs(MH = &MH, par = &par, pMH = som, cl = &cl);
	
	%getLogORs(MH = &MH, par = &par, pMH = psy, cl = &cl);

	%getLogORs(MH = &MH, par = &par, pMH = oth, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = slp, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = sex, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = sui, cl = &cl);	
	%getLogORs(MH = &MH, par = &par, pMH = per, cl = &cl);

	data OR_&par&MH; 
		set OR; 
		Outcome = "any_&MH";
		if Variable NE "Intercept"; 
	run;
%mend LogOR_risk;

* Either parent;
data parent_child1; set parent_child; run;

%LogOR_risk(MH = MH,   par = e, cl = family_no);

%LogOR_risk(MH = sub,  par = e, cl = family_no);
%LogOR_risk(MH = adhd, par = e, cl = family_no);
%LogOR_risk(MH = chad, par = e, cl = family_no);

%LogOR_risk(MH = dep,  par = e, cl = family_no);
%LogOR_risk(MH = str,  par = e, cl = family_no);
%LogOR_risk(MH = anx,  par = e, cl = family_no);
%LogOR_risk(MH = phb,  par = e, cl = family_no);
%LogOR_risk(MH = ptsd, par = e, cl = family_no);
%LogOR_risk(MH = som,  par = e, cl = family_no);

%LogOR_risk(MH = psy,  par = e, cl = family_no);

%LogOR_risk(MH = oth,  par = e, cl = family_no);
%LogOR_risk(MH = slp,  par = e, cl = family_no);
%LogOR_risk(MH = sex,  par = e, cl = family_no);
%LogOR_risk(MH = per,  par = e, cl = family_no);
%LogOR_risk(MH = sui,  par = e, cl = family_no);
%LogOR_risk(MH = con,  par = e, cl = family_no);
%LogOR_risk(MH = dev,  par = e, cl = family_no);
%LogOR_risk(MH = stm,  par = e, cl = family_no);

data OR_all_e;
	set OR_eadhd OR_eMH  OR_esub OR_echad 
		OR_edep OR_estr OR_eanx  OR_ephb  OR_eptsd OR_esom 
		OR_epsy  
		OR_eoth OR_eslp OR_esex  OR_eper  OR_esui  OR_econ OR_edev OR_estm;
run;
proc datasets;
	delete 	OR OR_eMH  OR_echad OR_eadhd OR_esub
			OR_edep OR_eanx  OR_estr  OR_ephb OR_esom OR_eptsd   
			OR_epsy  
			OR_eslp OR_econ  OR_edev  OR_eoth OR_estm  OR_esui OR_esex OR_eper
		   	eMH_OR  eCHAD_OR eADHD_OR eSUB_OR
			eDEP_OR eANX_OR  eSTR_OR ePHB_OR eSOM_OR ePTSD_OR  
		   	ePSY_OR
			eSLP_OR eCON_OR  eDEV_OR eOTH_OR eSTM_OR eSUI_OR eSEX_OR ePER_OR;
run;
quit;

proc export data = OR_all_e
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\LogORs_EitherParent_Dec2024.csv"
	dbms = csv
	replace;
run;


* Mothers;
data parent_child1; set parent_child; where m_any_MH NE .; run;

%OR_risk(MH = MH,   par = m, cl = mom_id);

%OR_risk(MH = sub,  par = m, cl = mom_id);
%OR_risk(MH = adhd, par = m, cl = mom_id);
%OR_risk(MH = chad, par = m, cl = mom_id);

%OR_risk(MH = dep,  par = m, cl = mom_id);
%OR_risk(MH = str,  par = m, cl = mom_id);
%OR_risk(MH = anx,  par = m, cl = mom_id);
%OR_risk(MH = phb,  par = m, cl = mom_id);
%OR_risk(MH = ptsd, par = m, cl = mom_id);
%OR_risk(MH = som,  par = m, cl = mom_id);

%OR_risk(MH = psy,  par = m, cl = mom_id);

%OR_risk(MH = oth,  par = m, cl = mom_id);
%OR_risk(MH = slp,  par = m, cl = mom_id);
%OR_risk(MH = sex,  par = m, cl = mom_id);
%OR_risk(MH = per,  par = m, cl = mom_id);
%OR_risk(MH = sui,  par = m, cl = mom_id);
%OR_risk(MH = con,  par = m, cl = mom_id);
%OR_risk(MH = dev,  par = m, cl = mom_id);
%OR_risk(MH = stm,  par = m, cl = mom_id);


data OR_all_m;
	set OR_mMH  OR_msub OR_madhd OR_mchad 
		OR_mdep OR_mstr OR_manx  OR_mphb  OR_mptsd OR_msom 
		OR_mpsy  
		OR_moth OR_mslp OR_msex  OR_mper  OR_msui  OR_mcon OR_mdev OR_mstm;
data OR_all_m;
	set OR_all_m;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_mMH  OR_mchad OR_madhd OR_msub
			OR_mdep OR_manx  OR_mstr  OR_mphb OR_msom OR_mptsd   
			OR_mpsy  
			OR_mslp OR_mcon  OR_mdev  OR_moth OR_mstm  OR_msui OR_msex OR_mper

		   	mMH_OR  mCHAD_OR mADHD_OR mSUB_OR
			mDEP_OR mANX_OR  mSTR_OR mPHB_OR mSOM_OR mPTSD_OR  
		   	mPSY_OR
			mSLP_OR mCON_OR  mDEV_OR mOTH_OR mSTM_OR mSUI_OR mSEX_OR mPER_OR;
run;
quit;

proc export data = OR_all_m
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_Mother_Dec2024.csv"
	dbms = csv
	replace;
run;

* Fathers;
data parent_child1; set parent_child; where d_any_MH NE .; run;

%OR_risk(MH = MH,   par = d, cl = dad_id);

%OR_risk(MH = sub,  par = d, cl = dad_id);
%OR_risk(MH = adhd, par = d, cl = dad_id);
%OR_risk(MH = chad, par = d, cl = dad_id);

%OR_risk(MH = dep,  par = d, cl = dad_id);
%OR_risk(MH = str,  par = d, cl = dad_id);
%OR_risk(MH = anx,  par = d, cl = dad_id);
%OR_risk(MH = phb,  par = d, cl = dad_id);
%OR_risk(MH = ptsd, par = d, cl = dad_id);
%OR_risk(MH = som,  par = d, cl = dad_id);

%OR_risk(MH = psy,  par = d, cl = dad_id);

%OR_risk(MH = oth,  par = d, cl = dad_id);
%OR_risk(MH = slp,  par = d, cl = dad_id);
%OR_risk(MH = sex,  par = d, cl = dad_id);
%OR_risk(MH = per,  par = d, cl = dad_id);
%OR_risk(MH = sui,  par = d, cl = dad_id);
%OR_risk(MH = con,  par = d, cl = dad_id);
%OR_risk(MH = dev,  par = d, cl = dad_id);
%OR_risk(MH = stm,  par = d, cl = dad_id);

data OR_all_d;
	set OR_dMH  OR_dsub OR_dadhd OR_dchad  
		OR_ddep OR_dstr OR_danx  OR_dphb  OR_dptsd OR_dsom
		OR_dpsy  
		OR_doth OR_dslp OR_dsex  OR_dper  OR_dsui  OR_dcon OR_ddev OR_dstm;
data OR_all_d;
	set OR_all_d;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_dMH  OR_dchad OR_dadhd OR_dsub
			OR_ddep OR_danx  OR_dstr  OR_dphb OR_dsom OR_dptsd   
			OR_dpsy  
			OR_dslp OR_dcon  OR_ddev  OR_doth OR_dstm  OR_dsui OR_dsex OR_dper

		   	dMH_OR  dCHAD_OR dADHD_OR dSUB_OR
			dDEP_OR dANX_OR  dSTR_OR dPHB_OR dSOM_OR dPTSD_OR  
		   	dPSY_OR
			dSLP_OR dCON_OR  dDEV_OR dOTH_OR dSTM_OR dSUI_OR dSEX_OR dPER_OR;
run;
quit;

proc export data = OR_all_d
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_Father_Dec2024.csv"
	dbms = csv
	replace;
run;

* "No Parental Co-morbidity" ORs;
%macro getORS (MH = , par = , pMH = , cl = );
	proc surveyfreq data = parent_child1; 
		cluster &cl;
		table any_&MH*&par._any_&pMH / OR;
		where &par._any_&MH = 0;
		ods output OddsRatio = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;
	proc datasets; delete &par&MH._OR; run; quit;
%mend getORs;

%macro OR_risk(MH = , par = , cl = );

	proc surveyfreq data = parent_child1; 
		cluster &cl;
		table any_&MH*&par._any_adhd / OR;
		where &par._any_&MH = 0; 
		ods output OddsRatio = &par.ADHD_OR; 
	run;
	data OR; 
		set &par.ADHD_OR; 
	run;
	proc datasets; delete &par&MH._OR; run; quit;

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
data parent_child1; set parent_child; run;

%OR_risk(MH = sub,  par = e, cl = family_no);
%OR_risk(MH = adhd, par = e, cl = family_no);

%OR_risk(MH = dep,  par = e, cl = family_no);
%OR_risk(MH = str,  par = e, cl = family_no);
%OR_risk(MH = anx,  par = e, cl = family_no);
%OR_risk(MH = phb,  par = e, cl = family_no);
%OR_risk(MH = ptsd, par = e, cl = family_no);
%OR_risk(MH = som,  par = e, cl = family_no);

%OR_risk(MH = psy,  par = e, cl = family_no);

%OR_risk(MH = oth,  par = e, cl = family_no);
%OR_risk(MH = slp,  par = e, cl = family_no);
%OR_risk(MH = sex,  par = e, cl = family_no);
%OR_risk(MH = per,  par = e, cl = family_no);
%OR_risk(MH = sui,  par = e, cl = family_no);

data OR_all_e;
	set OR_esub OR_eadhd 
		OR_edep OR_estr  OR_eanx OR_ephb OR_eptsd OR_esom 
		OR_epsy  
		OR_eoth OR_eslp  OR_esex OR_eper OR_esui;
data OR_all_e;
	set OR_all_e;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_eadhd OR_esub
			OR_edep OR_eanx  OR_estr  OR_ephb OR_esom OR_eptsd   
			OR_epsy  
			OR_eslp OR_eoth OR_esui OR_esex OR_eper;
run;
quit;

proc export data = OR_all_e
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_EitherNoPCom_Dec2024.csv"
	dbms = csv
	replace;
run;

* Get Log OR for meta analysis;
%macro getLogORS (MH = , par = , pMH = , cl = );
	proc surveylogistic data = parent_child1; 
		cluster &cl;
		model any_&MH (event = '1') = &par._any_&pMH;
		where &par._any_&MH = 0;
		ods output ParameterEstimates = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;
	proc datasets; delete &par&MH._OR; run; quit;
%mend getLogORs;

%macro LogOR_risk(MH = , par = , cl = );

	proc surveylogistic data = parent_child1; 
		cluster &cl;
		model any_&MH (event = '1') = &par._any_adhd;
		where &par._any_&MH = 0; 
		ods output ParameterEstimates = &par.ADHD_OR; 
	run;
	data OR; 
		set &par.ADHD_OR; 
	run;
	proc datasets; delete &par&MH._OR; run; quit;

	%getLogORs(MH = &MH, par = &par, pMH = sub, cl = &cl);

	%getLogORs(MH = &MH, par = &par, pMH = dep, cl = &cl);	
	%getLogORs(MH = &MH, par = &par, pMH = str, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = anx, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = phb, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = ptsd, cl = &cl);	
	%getLogORs(MH = &MH, par = &par, pMH = som, cl = &cl);
	
	%getLogORs(MH = &MH, par = &par, pMH = psy, cl = &cl);

	%getLogORs(MH = &MH, par = &par, pMH = oth, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = slp, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = sex, cl = &cl);
	%getLogORs(MH = &MH, par = &par, pMH = sui, cl = &cl);	
	%getLogORs(MH = &MH, par = &par, pMH = per, cl = &cl);

	data OR_&par&MH; 
		set OR; 
		Outcome = "any_&MH";
		if Variable NE "Intercept"; 
	run;

%mend LogOR_risk;

* Either parent;
data parent_child1; set parent_child; run;

%LogOR_risk(MH = sub,  par = e, cl = family_no);
%LogOR_risk(MH = adhd, par = e, cl = family_no);

%LogOR_risk(MH = dep,  par = e, cl = family_no);
%LogOR_risk(MH = str,  par = e, cl = family_no);
%LogOR_risk(MH = anx,  par = e, cl = family_no);
%LogOR_risk(MH = phb,  par = e, cl = family_no);
%LogOR_risk(MH = ptsd, par = e, cl = family_no);
%LogOR_risk(MH = som,  par = e, cl = family_no);

%LogOR_risk(MH = psy,  par = e, cl = family_no);

%LogOR_risk(MH = oth,  par = e, cl = family_no);
%LogOR_risk(MH = slp,  par = e, cl = family_no);
%LogOR_risk(MH = sex,  par = e, cl = family_no);
%LogOR_risk(MH = per,  par = e, cl = family_no);
%LogOR_risk(MH = sui,  par = e, cl = family_no);

data OR_all_e;
	set OR_eadhd OR_esub  
		OR_edep OR_estr  OR_eanx OR_ephb OR_eptsd OR_esom 
		OR_epsy  
		OR_eoth OR_eslp  OR_esex OR_eper OR_esui;
proc datasets;
	delete 	OR OR_eadhd OR_esub
			OR_edep OR_eanx  OR_estr  OR_ephb OR_esom OR_eptsd   
			OR_epsy  
			OR_eslp OR_eoth OR_esui OR_esex OR_eper;
run;
quit;

proc export data = OR_all_e
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\LogORs_EitherNoPCom_Dec2024.csv"
	dbms = csv
	replace;
run;

/*
* Mothers;
data parent_child1; set parent_child; where m_any_MH NE .; run;

%OR_risk(MH = sub,  par = m, cl = mom_id);
%OR_risk(MH = adhd, par = m, cl = mom_id);

%OR_risk(MH = dep,  par = m, cl = mom_id);
%OR_risk(MH = str,  par = m, cl = mom_id);
%OR_risk(MH = anx,  par = m, cl = mom_id);
%OR_risk(MH = phb,  par = m, cl = mom_id);
%OR_risk(MH = ptsd, par = m, cl = mom_id);
%OR_risk(MH = som,  par = m, cl = mom_id);

%OR_risk(MH = psy,  par = m, cl = mom_id);

%OR_risk(MH = oth,  par = m, cl = mom_id);
%OR_risk(MH = slp,  par = m, cl = mom_id);
%OR_risk(MH = sex,  par = m, cl = mom_id);
%OR_risk(MH = per,  par = m, cl = mom_id);
%OR_risk(MH = sui,  par = m, cl = mom_id);

data OR_all_m;
	set OR_msub OR_madhd 
		OR_mdep OR_mstr  OR_manx OR_mphb OR_mptsd OR_msom 
		OR_mpsy  
		OR_moth OR_mslp  OR_msex OR_mper OR_msui;
data OR_all_m;
	set OR_all_m;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_madhd OR_msub
			OR_mdep OR_manx  OR_mstr  OR_mphb OR_msom OR_mptsd   
			OR_mpsy  
			OR_mslp OR_moth OR_msui OR_msex OR_mper;
run;
quit;

proc export data = OR_all_m
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_MotherNoPCom_Dec2024.csv"
	dbms = csv
	replace;
run;

* Fathers;
data parent_child1; set parent_child; where d_any_MH NE .; run;

%OR_risk(MH = sub,  par = d, cl = dad_id);
%OR_risk(MH = adhd, par = d, cl = dad_id);

%OR_risk(MH = dep,  par = d, cl = dad_id);
%OR_risk(MH = str,  par = d, cl = dad_id);
%OR_risk(MH = anx,  par = d, cl = dad_id);
%OR_risk(MH = phb,  par = d, cl = dad_id);
%OR_risk(MH = ptsd, par = d, cl = dad_id);
%OR_risk(MH = som,  par = d, cl = dad_id);

%OR_risk(MH = psy,  par = d, cl = dad_id);

%OR_risk(MH = oth,  par = d, cl = dad_id);
%OR_risk(MH = slp,  par = d, cl = dad_id);
%OR_risk(MH = sex,  par = d, cl = dad_id);
%OR_risk(MH = per,  par = d, cl = dad_id);
%OR_risk(MH = sui,  par = d, cl = dad_id);

data OR_all_d;
	set OR_dsub OR_dadhd 
		OR_ddep OR_dstr  OR_danx OR_dphb OR_dptsd OR_dsom 
		OR_dpsy  
		OR_doth OR_dslp  OR_dsex OR_dper OR_dsui;
data OR_all_d;
	set OR_all_d;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_dadhd OR_dsub
			OR_ddep OR_danx  OR_dstr OR_dphb OR_dsom OR_dptsd   
			OR_dpsy  
			OR_dslp OR_doth OR_dsui OR_dsex OR_dper;
run;
quit;

proc export data = OR_all_d
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_FatherNoPCom_Dec2024.csv"
	dbms = csv
	replace;
run;

* "No Child Co-morbidity" ORs;
%macro getORS (MH = , par = , pMH = , cl = );
	proc surveyfreq data = parent_child1; 
		cluster &cl;
		table any_&MH*&par._any_&pMH / OR;
		where any_&pMH = 0;
		ods output OddsRatio = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;
	proc datasets; delete &MH._OR; run; quit;
%mend getORs;

%macro OR_risk(MH = , par = , cl = );

	proc surveyfreq data = parent_child1; 
		cluster &cl;
		table any_&MH*&par._any_sub / OR;
		where any_sub = 0; 
		ods output OddsRatio = &MH._OR; 
	run;
	data OR; 
		set &MH._OR; 
	run;
	proc datasets; delete &MH._OR; run; quit;

	%getORS(MH = &MH, par = &par, pMH = adhd, cl = &cl);

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
data parent_child1; set parent_child; run;

%OR_risk(MH = sub,  par = e, cl = family_no);
%OR_risk(MH = adhd, par = e, cl = family_no);
%OR_risk(MH = chad, par = e, cl = family_no);

%OR_risk(MH = dep,  par = e, cl = family_no);
%OR_risk(MH = str,  par = e, cl = family_no);
%OR_risk(MH = anx,  par = e, cl = family_no);
%OR_risk(MH = phb,  par = e, cl = family_no);
%OR_risk(MH = ptsd, par = e, cl = family_no);
%OR_risk(MH = som,  par = e, cl = family_no);

%OR_risk(MH = psy,  par = e, cl = family_no);

%OR_risk(MH = oth,  par = e, cl = family_no);
%OR_risk(MH = slp,  par = e, cl = family_no);
%OR_risk(MH = sex,  par = e, cl = family_no);
%OR_risk(MH = per,  par = e, cl = family_no);
%OR_risk(MH = sui,  par = e, cl = family_no);
%OR_risk(MH = con,  par = e, cl = family_no);
%OR_risk(MH = dev,  par = e, cl = family_no);
%OR_risk(MH = stm,  par = e, cl = family_no);

data OR_all_e;
	set OR_esub OR_eadhd OR_echad 
		OR_edep OR_estr  OR_eanx  OR_ephb OR_eptsd OR_esom 
		OR_epsy  
		OR_eoth OR_eslp  OR_esex  OR_eper OR_esui OR_econ OR_edev OR_estm;
data OR_all_e;
	set OR_all_e;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_echad OR_eadhd OR_esub
			OR_edep OR_eanx  OR_estr  OR_ephb OR_esom OR_eptsd   
			OR_epsy  
			OR_eslp OR_econ OR_edev OR_eoth OR_estm OR_esui OR_esex OR_eper;
run;
quit;

proc export data = OR_all_e
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_EitherNoCCom_Dec2024.csv"
	dbms = csv
	replace;
run;

* Mothers;
data parent_child1; set parent_child; where m_any_MH NE .; run;

%OR_risk(MH = sub,  par = m, cl = mom_id);
%OR_risk(MH = adhd, par = m, cl = mom_id);
%OR_risk(MH = chad, par = m, cl = mom_id);

%OR_risk(MH = dep,  par = m, cl = mom_id);
%OR_risk(MH = str,  par = m, cl = mom_id);
%OR_risk(MH = anx,  par = m, cl = mom_id);
%OR_risk(MH = phb,  par = m, cl = mom_id);
%OR_risk(MH = ptsd, par = m, cl = mom_id);
%OR_risk(MH = som,  par = m, cl = mom_id);

%OR_risk(MH = psy,  par = m, cl = mom_id);

%OR_risk(MH = oth,  par = m, cl = mom_id);
%OR_risk(MH = slp,  par = m, cl = mom_id);
%OR_risk(MH = sex,  par = m, cl = mom_id);
%OR_risk(MH = per,  par = m, cl = mom_id);
%OR_risk(MH = sui,  par = m, cl = mom_id);
%OR_risk(MH = con,  par = m, cl = mom_id);
%OR_risk(MH = dev,  par = m, cl = mom_id);
%OR_risk(MH = stm,  par = m, cl = mom_id);


data OR_all_m;
	set OR_msub OR_madhd OR_mchad
		OR_mdep OR_mstr  OR_manx  OR_mphb OR_mptsd OR_msom
		OR_mpsy  
		OR_moth OR_mslp  OR_msex  OR_mper OR_msui  OR_mcon OR_mdev OR_mstm;
data OR_all_m;
	set OR_all_m;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_mchad OR_madhd OR_msub
		OR_mdep OR_manx  OR_mstr  OR_mphb OR_msom OR_mptsd   
		OR_mpsy  
		OR_mslp OR_mcon OR_mdev OR_moth OR_mstm OR_msui OR_msex OR_mper;
run;
quit;

proc export data = OR_all_m
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_MotherNoCCom_Dec2024.csv"
	dbms = csv
	replace;
run;

* Fathers;
data parent_child1; set parent_child; where d_any_MH NE .; run;

%OR_risk(MH = sub,  par = d, cl = dad_id);
%OR_risk(MH = adhd, par = d, cl = dad_id);
%OR_risk(MH = chad, par = d, cl = dad_id);

%OR_risk(MH = dep,  par = d, cl = dad_id);
%OR_risk(MH = str,  par = d, cl = dad_id);
%OR_risk(MH = anx,  par = d, cl = dad_id);
%OR_risk(MH = phb,  par = d, cl = dad_id);
%OR_risk(MH = ptsd, par = d, cl = dad_id);
%OR_risk(MH = som,  par = d, cl = dad_id);

%OR_risk(MH = psy,  par = d, cl = dad_id);

%OR_risk(MH = oth,  par = d, cl = dad_id);
%OR_risk(MH = slp,  par = d, cl = dad_id);
%OR_risk(MH = sex,  par = d, cl = dad_id);
%OR_risk(MH = per,  par = d, cl = dad_id);
%OR_risk(MH = sui,  par = d, cl = dad_id);
%OR_risk(MH = con,  par = d, cl = dad_id);
%OR_risk(MH = dev,  par = d, cl = dad_id);
%OR_risk(MH = stm,  par = d, cl = dad_id);

data OR_all_d;
	set OR_dsub OR_dadhd OR_dchad
		OR_ddep OR_dstr  OR_danx  OR_dphb OR_dptsd OR_dsom
		OR_dpsy  
		OR_doth OR_dslp  OR_dsex  OR_dper OR_dsui  OR_dcon OR_ddev OR_dstm;
data OR_all_d;
	set OR_all_d;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete 	OR OR_dchad OR_dadhd OR_dsub
			OR_ddep OR_danx  OR_dstr  OR_dphb OR_dsom OR_dptsd   
			OR_dpsy  
			OR_dslp OR_dcon OR_ddev OR_doth OR_dstm OR_dsui OR_dsex OR_dper;
run;
quit;

proc export data = OR_all_d
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Parent_Child\ORs_FatherNoCCom_Dec2024.csv"
	dbms = csv
	replace;
run;
*/

* Calculate OR for # parents with MH dx;
proc freq data = parent_child;
	table e_any_MHn e_any_MHn1;
run;

proc logistic data = parent_child;
	class e_any_MHn (ref = first);
	model any_MH (event = "1") = e_any_MHn;
run;
proc logistic data = parent_child;
	class e_any_MHn1 (ref = first);
	model any_MH (event = "1") = e_any_MHn1;
run;

* IRR's for number of dx-types;
data variety;
	set parent_child;

	ndx_c = SUM(any_sub, any_adhd, any_chad,
				any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, any_psy,
		  		any_oth, any_slp, any_sex, any_per, any_sui, any_con, any_dev, any_stm);
	ndx_e = SUM(e_any_sub, e_any_adhd, e_any_dep, e_any_str, e_any_anx, e_any_phb, e_any_ptsd, e_any_som, e_any_psy,
		  		e_any_oth, e_any_slp, e_any_sex, e_any_per, e_any_sui);
	ndx_m = SUM(m_any_sub, m_any_adhd, m_any_dep, m_any_str, m_any_anx, m_any_phb, m_any_ptsd, m_any_som, m_any_psy,
		  		m_any_oth, m_any_slp, m_any_sex, m_any_per, m_any_sui);
	ndx_d = SUM(d_any_sub, d_any_adhd, d_any_dep, d_any_str, d_any_anx, d_any_phb, d_any_ptsd, d_any_som, d_any_psy,
		  		d_any_oth, d_any_slp, d_any_sex, d_any_per, d_any_sui);
run;

proc freq data = variety;
	table  ndx_c ndx_e ndx_m ndx_d;
proc corr data = variety;
	var ndx_c ndx_e ndx_m ndx_d;
proc genmod data = variety;
	class family_no;
	model ndx_c = ndx_e / dist = negbin;
	repeated subject = family_no;
run;
proc genmod data = variety;
	class family_no;
	model ndx_c = ndx_m / dist = negbin;
	repeated subject = family_no;
run;
proc genmod data = variety;
	class family_no;
	model ndx_c = ndx_d / dist = negbin;
	repeated subject = family_no;
run;
