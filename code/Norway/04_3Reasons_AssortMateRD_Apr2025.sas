DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\02_3Reasons_AssortMate_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: 3-Reasons - Assortative Mating
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\02_3Reasons_AssortMate_Dec2024.sas;
* Modification Hx:	10-Oct-2024 Prevalence & OR's for Primary Partners
*
***************************************************************************************************;

libname rawdat	"N:\durable\Data22\processed_data\ForRenate";
libname thr_asm	"M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating";

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
		1 = "Alive & full-time resident of Norway, 2006-19"
		2 = "Full-time resident who died between 2006-19"
		3 = "Deceased < 2006"
		4 = "Deceased >= 2006, but not fully resident 2006-19"
		5 = "Non-resident or missing at some point between 2006-19";
	value MHDX
		-1 = "MHDX: P-code with no number"
		 1 = "Acute stress reaction"
		 2 = "ADHD"
		 3 = "Anxiety" 
		 4 = "Dementia/Memory problems"
		 5 = "Depression"
		 6 = "Developmental delay/Learning problems"
		 7 = "Eating disorder"
		 8 = "Phobia/Compulsive disorder"
		 9 = "Psychosis"
		10 = "PTSD"
		11 = "Sexual concern"
		12 = "Sleep disturbance"		
		13 = "Somatization"
		14 = "Substance abuse"
		15 = "Suicide/Suicide attempt"
		16 = "Child/Adolescent behavior symptom/complaint"
		17 = "Continence issues"
		18 = "Personality disorder"
		19 = "Neuresthenia/surmenage (chronic fatigue)"
		20 = "Phase of life problem adult"
		21 = "Stammering/stuttering/tic"
		22 = "Fear of mental disorder"
		23 = "Feeling/behaving irritable/angry"
		24 = "Other psychological symptom/disease";
	value EDTRUNC
		0 = "No education and pre-school education (under school age)"
		1 = "Compulsary education (1-10y of ed)"
		2 = "Intermediate education (11-14y ed)"
		3 = "Higher education (14-20+y of ed)"
		9 = "Unspecified";
	value MARSTAT
		1 = "Never married"
		2 = "Married"
		3 = "Widowed"
		4 = "Divorced"
		5 = "Separated"
		6 = "Registered partner"
		7 = "Separated partner"
		8 = "Divorced partner"
		9 = "Surviving partner";
run;

data assortmate_all;
	set thr_asm.focal_primary_MH_Dec2024;

	if YEAR(DOD) >= 2006 and YEAR(DOD) < 2020 then dead0619 = 1;
		else dead0619 = 0;

	if no_partner = 1 then have_partner = 0;
		else if no_partner = 0 then have_partner = 1;

	dx_variety    = SUM(any_sub, any_adhd, any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, any_psy, any_oth, any_slp, any_sex, any_per, any_sui);
	pp_dx_variety = SUM(pp_any_sub, pp_any_adhd, pp_any_dep, pp_any_str, pp_any_anx, pp_any_phb, pp_any_ptsd, pp_any_som, pp_any_psy, 
						pp_any_oth, pp_any_slp, pp_any_sex, pp_any_per, pp_any_sui);
run;

proc contents data = assortmate_all varnum; run;


* Bring down to those with primary partners;
data assortmate;
	set assortmate_all;

	if have_partner = 1;
run;


* Flip to male vs female rather than focal vs primary;
data assortmate1;
	set assortmate;

	array focal [18] age_start n_partner dx_variety
					 any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  			 any_oth any_slp any_sex any_per any_sui;
	array prime [18] pp_age_start p_n_partner pp_dx_variety
					 pp_any_MH  pp_any_sub pp_any_adhd pp_any_dep pp_any_str pp_any_anx pp_any_phb pp_any_ptsd pp_any_som pp_any_psy
		  			 pp_any_oth pp_any_slp pp_any_sex  pp_any_per pp_any_sui;

	array m [18] m_age_start m_n_partner m_dx_variety
				 m_any_MH  m_any_sub m_any_adhd m_any_dep m_any_str m_any_anx m_any_phb m_any_ptsd m_any_som m_any_psy
		  		 m_any_oth m_any_slp m_any_sex  m_any_per m_any_sui;
	array f [18] f_age_start f_n_partner f_dx_variety
				 f_any_MH  f_any_sub f_any_adhd f_any_dep f_any_str f_any_anx f_any_phb f_any_ptsd f_any_som f_any_psy
		  		 f_any_oth f_any_slp f_any_sex  f_any_per f_any_sui;

	do i = 1 to 18;
		if male = 1 then do;
			male_id   = w19_1011_lnr_k2_;
			female_id = primary_id;
			m[i] = focal[i];
			f[i] = prime[i];
		end;
		if male = 0 then do;
			male_id   = primary_id;
			female_id = w19_1011_lnr_k2_;
			m[i] = prime[i];
			f[i] = focal[i];
		end;
	end;

	drop i;
run;

* Delete duplicate partnerships;
proc sort data = assortmate1; by male_id female_id; run;

data assortmate2;
	set assortmate1;
	by male_id;

	retain couple_no 0 last_f "          ";

	if first.male_id then do;
		couple_no = couple_no + 1;
		last_f    = female_id;
	end;
	if last_f ne female_id then do;
		couple_no = couple_no + 1;
		last_f    = female_id;
	end;
run;

proc sort data = assortmate2 nodupkey; by couple_no; run;

* Risk differences ... M -> F ;
%macro getRDs (MH = , pMH = );
	proc freq data = assortmate2; 
		table m_any_&MH*f_any_&pMH / RISKDIFF;
		ods output RiskDiffCol2 = &MH._RD;
	run;

	data RD; 
		set RD &MH._RD;
	run;
%mend getRDs;

%macro RD_risk(MH = );

	proc freq data = assortmate2; 
		table m_any_&MH*f_any_adhd / RISKDIFF; 
		ods output RiskDiffCol2 = &MH._RD;
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

* M -> F;
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
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\F_Rsk_when_M_hasDx_RiskDiff_17Apr2025.csv"
	dbms = csv
	replace;
run;

* Risk differences ... F -> M ;
%macro getRDs (MH = , pMH = );
	proc freq data = assortmate2; 
		table f_any_&MH*m_any_&pMH / RISKDIFF;
		ods output RiskDiffCol2 = &MH._RD;
	run;

	data RD; 
		set RD &MH._RD;
	run;
%mend getRDs;

%macro RD_risk(MH = );

	proc freq data = assortmate2; 
		table f_any_&MH*m_any_adhd / RISKDIFF; 
		ods output RiskDiffCol2 = &MH._RD;
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

* F -> M;
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
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\M_Rsk_when_F_hasDx_RiskDiff_17Apr2025.csv"
	dbms = csv
	replace;
run;

proc freq data = assortmate2; 
	table m_any_MH*f_any_MH / RISKDIFF; 
run;
proc freq data = assortmate2; 
	table f_any_MH*m_any_MH / RISKDIFF; 
run;


