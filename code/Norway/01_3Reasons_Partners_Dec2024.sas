DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\01_3Reasons_Partners_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: 3-Reasons Assortative Mating 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\01_3Reasons_Partners_Dec2024.sas
* Modification Hx:	Set up initial checks for who to include, find partners
*					09-Oct-2024 Dotting i's and crossing t's				
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

* Find adult/partner records;
* Read in medical records and bring down to ages [20-50] at start;
* Keep only mental health codes (Chapter P);

data medrec;
	set rawdat.MedRec_23Feb2024;

	if age_start >= 20 and age_start < 51;

	if diag_chapter = "P";

	/* *CODE TO REMOVE NON-DOCTOR/NON-IN-PERSON CONTACTS;
	* ID contact with doctors;
	if FAGOMRAADE_KODE = "LE" then doctor = 1;
		else doctor = 0;

	* ID contact-types 1-4;
	if KONTAKTTYPE in (1,2,3,4) then contact14 = 1;
		else contact14 = 0;

	if doctor = 1 and contact14 = 1 then good_code = 1;
		else good_code = 0;

	if good_code = 1;
	*/

	drop FAGOMRAADE_KODE KONTAKTTYPE /*doctor contact14 good_code*/;
run;

* Code diagnoses into categories we're using;
data medrec1;
	merge	medrec (in = inmedr)
			rawdat.Demog_23Feb2024 (keep = w19_1011_lnr_k2_ DOB);
	by w19_1011_lnr_k2_;		

	if inmedr;

	age_floor    = FLOOR(age_start);
	age_dx_floor = FLOOR(age_dx);

	age_start_mo = INTCK('MONTH', DOB, MDY(01,01,2006), 'D');
	age_dx_mo    = INTCK('MONTH', DOB, DATO, 'D');

	* Code mental health into diagnoses;
	if DIAG in ("P02")                                      then MHdx = 1; 	* Acute Stress Reaction;
		else if DIAG in ("P81")                             then MHdx = 2;	* ADHD;
		else if DIAG in ("P01", "P74")                      then MHdx = 3;	* Anxiety;
		else if DIAG in ("P05", "P20", "P70")               then MHdx = 4;	* Memory problems / Dementia;
		else if DIAG in ("P03", "P76")                      then MHdx = 5;	* Depression;
		else if DIAG in ("P24", "P28", "P85")               then MHdx = 6;	* Learning problem / Developmental delay;
		else if DIAG in ("P11", "P86")                      then MHdx = 7;	* Eating disorder;
		else if DIAG in ("P79")                      		then MHdx = 8;	* Phobia / Compulsive disorder;
		else if DIAG in ("P71", "P72", "P73", "P98")		then MHdx = 9;	* Psychosis;
		else if DIAG in ("P82")							  	then MHdx = 10;	* PTSD;
		else if DIAG in ("P07", "P08", "P09")				then MHdx = 11;	* Sexual concern;
		else if DIAG in ("P06")							  	then MHdx = 12;	* Sleep disturbance;
		else if DIAG in ("P75")							  	then MHdx = 13;	* Somatization disorder;
		else if DIAG in ("P15", "P16", "P17", "P18", "P19") then MHdx = 14;	* Substance abuse;
		else if DIAG in ("P77")							  	then MHdx = 15;	* Suicide / Suicide attempt;
		else if DIAG in ("P22", "P23")                      then MHdx = 16;	* Child / Adolescent behavioral symptom/complaint;
		else if DIAG in ("P12", "P13")                      then MHdx = 17;	* Continence issues;
		else if DIAG in ("P80")                             then MHdx = 18;	* Personality disorder;
		else if DIAG in ("P78")                             then MHdx = 19;	* Chronic fatigue;
		else if DIAG in ("P25")                             then MHdx = 20;	* Phase of life problem adult;
		else if DIAG in ("P10")                             then MHdx = 21;	* Stammering / Stuttering / Tic;
		else if DIAG in ("P27")                             then MHdx = 22;	* Fear of mental disorder;
		else if DIAG in ("P04")                             then MHdx = 23;	* Feeling / behaving irriatible / angry;
		else if DIAG in ("P29", "P99")                      then MHdx = 24;	* NOS;

	if MHdx ne . then anyMH = 1;
		else anyMH = 0;

	* Keep only codes we're using;
	if anyMH = 1;

	drop anyMH;

	format MHdx MHDX.;
run;

* Bring analysis sample down to ages [20-50) on 01-Jan-2006;
data demog;
	set rawdat.Demog_23Feb2024;
	by w19_1011_lnr_k2_;

	if age_start >= 20 and age_start < 51;

	if sex = 1 then male = 1;
		else if sex = 2 then male = 0;

	age_start_fl = FLOOR(age_start);

	keep w19_1011_lnr_k2_ DOB DOD male age_start age_start_fl age_end age_death;
run;

* Create wide file with indicator variables for ever having dx;
proc sort data = medrec1 out = uniqdx nodupkey; by w19_1011_lnr_k2_ MHdx; run;

data medrec_wide;
	do i = 1 to 25 until (last.w19_1011_lnr_k2_);
		set uniqdx;
		by w19_1011_lnr_k2_;
	
		if MHdx =  1 then any_str  = 1; 
		if MHdx =  2 then any_adhd = 1; 
		if MHdx =  3 then any_anx  = 1; 
		if MHdx =  4 then any_dem  = 1; 
		if MHdx =  5 then any_dep  = 1; 
		if MHdx =  6 then any_dev  = 1; 
		if MHdx =  7 then any_eat  = 1; 
		if MHdx =  8 then any_phb  = 1; 
		if MHdx =  9 then any_psy  = 1; 
		if MHdx = 10 then any_ptsd = 1; 
		if MHdx = 11 then any_sex  = 1; 
		if MHdx = 12 then any_slp  = 1; 
		if MHdx = 13 then any_som  = 1; 
		if MHdx = 14 then any_sub  = 1; 
		if MHdx = 15 then any_sui  = 1; 
		if MHdx = 16 then any_chad = 1; 
		if MHdx = 17 then any_con  = 1; 
		if MHdx = 18 then any_per  = 1; 
		if MHdx = 19 then any_crf  = 1; 
		if MHdx = 20 then any_pha  = 1; 
		if MHdx = 21 then any_stm  = 1; 
		if MHdx = 22 then any_fmh  = 1; 
		if MHdx = 23 then any_irr  = 1; 
		if MHdx = 24 then any_oth  = 1; 
	end;

	keep w19_1011_lnr_k2_
		 any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
		 any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth;
run;

data medrec_wide;
	merge demog (in = indem) medrec_wide;
	by w19_1011_lnr_k2_;

	if indem;

	array dx [24]	any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
		 			any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth;
		 
	do i = 1 to 24;
		if dx[i] = . then dx[i] = 0;
	end;

	if SUM(any_str, any_adhd, any_anx, any_dep, any_phb, any_psy, any_ptsd, any_sex, any_slp, any_som, any_sub, any_sui, any_per, any_oth) > 0 then any_MH = 1;

	if any_MH = . then any_MH = 0;
	drop i;
run;

data thr_asm.partner_wide_Dec2024;
	set medrec_wide;
run;


****
* START HERE ONCE SET UP
****;

data partners;
	set thr_asm.partner_wide_Dec2024;
	*set medrec_wide;
run;
proc contents data = partners varnum; run;

* Pull in spouse/partner numbers;
proc import file = "N:\durable\Data22\original_data\k2_-w19_1011_4e_famogsamliv_ut.txt"
	out = spouseno
	dbms = dlm
	replace;
	delimiter = ';';
	guessingrows = 10000;
run;
proc contents data = spouseno varnum; run;

* Pull in marital status;
proc import file = "N:\durable\Data22\original_data\k2_-w19_1011_4b_sivilstand_ut.txt"
	out = maritalstat
	dbms = dlm
	replace;
	delimiter = ';';
	guessingrows = 10000;
run;
proc contents data = maritalstat varnum; run;

* Only look at partnerships between 2006-2019;
data spouseno_long;
	merge partners (in = inpar) spouseno;
	by w19_1011_lnr_k2_;

	if inpar;

	array spno [14]	lnr_ektefelle_2006_k2_ lnr_ektefelle_2007_k2_ lnr_ektefelle_2008_k2_ lnr_ektefelle_2009_k2_ 
					lnr_ektefelle_2010_k2_ lnr_ektefelle_2011_k2_ lnr_ektefelle_2012_k2_ lnr_ektefelle_2013_k2_ lnr_ektefelle_2014_k2_ 
					lnr_ektefelle_2015_k2_ lnr_ektefelle_2016_k2_ lnr_ektefelle_2017_k2_ lnr_ektefelle_2018_k2_ lnr_ektefelle_2019_k2_;

	do i = 1 to 14;
		year = 2005 + i;
		sp_id   = spno[i];
		output;
	end;

	keep w19_1011_lnr_k2_ year sp_id;
run;
data cohabno_long;
	merge partners (in = inpar) spouseno;
	by w19_1011_lnr_k2_;

	if inpar;

	array chno [14]	lnr_sambo_2006_k2_ lnr_sambo_2007_k2_ lnr_sambo_2008_k2_ lnr_sambo_2009_k2_ 
					lnr_sambo_2010_k2_ lnr_sambo_2011_k2_ lnr_sambo_2012_k2_ lnr_sambo_2013_k2_ lnr_sambo_2014_k2_ 
					lnr_sambo_2015_k2_ lnr_sambo_2016_k2_ lnr_sambo_2017_k2_ lnr_sambo_2018_k2_ lnr_sambo_2019_k2_;

	do i = 1 to 14;
		year = 2005 + i;
		cohab_id   = chno[i];
		output;
	end;

	keep w19_1011_lnr_k2_ year cohab_id;
run;
data marstat_long;
	merge partners (in = inpar) maritalstat;
	by w19_1011_lnr_k2_;

	if inpar;

	array mst [14]	sivilstand_2006 sivilstand_2007 sivilstand_2008 sivilstand_2009 
					sivilstand_2010 sivilstand_2011 sivilstand_2012 sivilstand_2013 sivilstand_2014 
					sivilstand_2015 sivilstand_2016 sivilstand_2017 sivilstand_2018 sivilstand_2019;

	do i = 1 to 14;
		year    = 2005 + i;
		marstat = mst[i];
		output;
	end;

	keep w19_1011_lnr_k2_ year marstat;
run;

/*
		1 = "Never married"
		2 = "Married"
		3 = "Widowed"
		4 = "Divorced"
		5 = "Separated"
		6 = "Registered partner"
		7 = "Separated partner"
		8 = "Divorced partner"
		9 = "Surviving partner";
*/

data partnerships_long;
	merge spouseno_long cohabno_long marstat_long;
	by w19_1011_lnr_k2_ year;

	if sp_id = cohab_id then partner_id = sp_id;
		else if sp_id = ''  and cohab_id ne ''                     then partner_id = cohab_id;
		else if sp_id ne '' and cohab_id = '' and marstat in (2,6) then partner_id = sp_id;
		else if sp_id ne '' and cohab_id = '' and marstat in (3,9) then partner_id = "Widowed";
		else if sp_id ne '' and cohab_id = '' and marstat in (4,8) then partner_id = "Divorced";
		else if sp_id ne '' and cohab_id = '' and marstat in (5,7) then partner_id = "Separated";
		else if sp_id ne '' and (sp_id ne cohab_id)                then partner_id = cohab_id;

	format marstat MARSTAT.;
run;

data relinfo;
	set partnerships_long;
	by w19_1011_lnr_k2_;

	if partner_id ne '' AND partner_id ne "Widowed" AND partner_id ne "Divorced" AND partner_id ne "Separated";
run;

proc freq data = relinfo;
	table year;
run;

* Sort so that sporadic relationships are together for counting;
proc sort data = relinfo; by w19_1011_lnr_k2_ partner_id; run;

data relinfo;
	set relinfo;
	by w19_1011_lnr_k2_; 

	length last_partner $10;
	retain n_partner 0 last_partner;

	if first.w19_1011_lnr_k2_ then do;
		first_id     = partner_id;
		n_partner    = 1;
		last_partner = partner_id;
	end;
	if last_partner ne partner_id then do;
		n_partner    = n_partner + 1;
		last_partner = partner_id;
	end;
run;

proc freq data = relinfo;
	table n_partner;
run;

* Count number of partners that partners had;
proc sort data = relinfo out = parinfo; by partner_id w19_1011_lnr_k2_; run;

data parinfo;
	set parinfo;
	by partner_id;

	length last_focal $10;
	retain p_n_partner 0 last_focal;

	if first.partner_id then do;
		first_id    = w19_1011_lnr_k2_;
		p_n_partner = 1;
		last_focal  = w19_1011_lnr_k2_;
	end;
	if last_focal ne w19_1011_lnr_k2_ then do;
		p_n_partner = n_partner + 1;
		last_focal  = w19_1011_lnr_k2_;
	end;
run;

proc freq data = parinfo;
	table p_n_partner;
run;

proc freq data = relinfo noprint;
	table w19_1011_lnr_k2_*n_partner / out = npartner;
proc freq data = parinfo noprint;
	table partner_id*p_n_partner / out = p_npartner;
run;

data npartner_wide;

	array rl [9] rel_len1 rel_len2 rel_len3 rel_len4 rel_len5 rel_len6 rel_len7 rel_len8 rel_len9;

	do i = 1 to 9 until (last.w19_1011_lnr_k2_);
		set npartner;
		by w19_1011_lnr_k2_;

		rl[i] = COUNT;
	end;

	drop COUNT PERCENT i;
run;

data p_npartner_wide;

	array rl [9] prel_len1 prel_len2 prel_len3 prel_len4 prel_len5 prel_len6 prel_len7 prel_len8 prel_len9;

	do i = 1 to 9 until (last.partner_id);
		set p_npartner;
		by partner_id;

		rl[i] = COUNT;
	end;

	drop COUNT PERCENT i;
run;

data npartner_wide;
	set npartner_wide;
	by w19_1011_lnr_k2_;

	if primary_p = . then do;
		if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9)          = rel_len1  then primary_p =  1;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len2  then primary_p =  2;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len3  then primary_p =  3;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len4  then primary_p =  4;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len5  then primary_p =  5;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len6  then primary_p =  6;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len7  then primary_p =  7;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len8  then primary_p =  8;
			else if MAX(rel_len1, rel_len2, rel_len3, rel_len4, rel_len5, rel_len6, rel_len7, rel_len8, rel_len9) = rel_len9  then primary_p =  9;
	end;
run;

proc freq data = npartner_wide;
	table primary_p;
run;

data relinfo1;
	merge relinfo npartner_wide (keep = w19_1011_lnr_k2_ primary_p);
	by w19_1011_lnr_k2_;

	length primary_id $10;

	if primary_p = n_partner then primary_id = partner_id;
run;

proc freq data = relinfo1 noprint;
	table w19_1011_lnr_k2_*primary_id / out = primary_ids;
	where primary_id ne '';
run;

data partners1;
	merge partners primary_ids (keep = w19_1011_lnr_k2_ primary_id) npartner_wide (keep = w19_1011_lnr_k2_ n_partner);
	by w19_1011_lnr_k2_;

	if primary_id = '' then no_partner = 1;
		else no_partner = 0;

	if n_partner = . then n_partner = 0;
run;

proc sort data = partners1; by primary_id; run;

data partners2;
	merge partners1 (in = inpar) p_nPartner_wide (rename = (partner_id = primary_id));
	by primary_id;

	if inpar;

	if p_n_partner = . then p_n_partner = 0;

	drop prel_len1 prel_len2 prel_len3 prel_len4 prel_len5 prel_len6 prel_len7 prel_len8 prel_len9;
run;


proc freq data = partners2;
	table no_partner male*no_partner n_partner p_n_partner;
run;

data no_partners;
	set partners2;

	if no_partner = 1;
run;

* Find partner demographics;
* Pull in demographics;
proc import file = "N:\durable\Data22\original_data\k2_-w19_1011_4b_regstatus_ut.txt"
	out = resident0
	dbms = dlm
	replace;
	delimiter = ';';
	guessingrows = 10000;
run;
proc import file = "N:\durable\Data22\original_data\k2_-w19_1011_4a_faste_oppl_ut.txt"
	out = ageband0
	dbms = dlm
	replace;
	delimiter = ';';
	guessingrows = 10000;
run;
data death;
	%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
	infile 'N:\durable\Data22\original_data\updated_death.csv' delimiter = ',' MISSOVER
	DSD lrecl = 32767 firstobs = 2;
		informat VAR1 $6. w19_1011_lnr_k2_ $10. doeds_aar_mnd best32. ;
		format   VAR1 $6. w19_1011_lnr_k2_ $10. doeds_aar_mnd best12. ;
		input
			VAR1 $
			w19_1011_lnr_k2_ $
			doeds_aar_mnd
			;
		if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;

data resident1;
	set resident0;

	array reg[14] regstat_06 regstat_07 regstat_08 regstat_09 regstat_10 regstat_11 regstat_12 regstat_13 regstat_14 regstat_15 regstat_16 regstat_17 regstat_18 regstat_19;
	array res[14] res06      res07      res08      res09      res10      res11      res12      res13      res14      res15      res16      res17      res18      res19;

	do i = 1 to 14;
		if reg[i] = 1 then res[i] = 1;
			else if reg[i] ne . then res[i] = 0;
	end;

	keep 	w19_1011_lnr_k2_ 
			res06 res07 res08 res09 res10 res11 res12 res13 res14 res15 res16 res17 res18 res19;
run;
data death;
	set death;

	* Create MM/YYYY date value for Date of Death;
	if doeds_aar_mnd ne . then do;
		yr_death = INPUT(SUBSTRN(doeds_aar_mnd, 1, 4), BEST12.);
		mo_death = INPUT(SUBSTRN(doeds_aar_mnd, 5, 2), BEST12.);
	end;
	DOD = MDY(mo_death, 1, yr_death);

	* Delete N=502 with ID="NA";
	if w19_1011_lnr_k2_ = "NA" then delete;

	format DOD MMYYD.;
	keep w19_1011_lnr_k2_ DOD;
run;

proc sort data = ageband0;  by w19_1011_lnr_k2_; run;
proc sort data = resident1; by w19_1011_lnr_k2_; run;
proc sort data = death;     by w19_1011_lnr_k2_; run;

data demo1;
	merge ageband0 (rename = (foedselsaar = birth_yr kjoenn = sex))
		  resident1 death;
	by w19_1011_lnr_k2_;

	death_yr = YEAR(DOD);

	* Define born in Norway as: 
	* 	"A" = Born in Norway to Norwegian born parents
	*	"C" = Norwegian born to imigrant parents
	*	"F" = Norwegian born with 1 foreign parent;

	if invkat in ("A", "C", "F") then nor_born = 1;
		else if invkat ne "" then nor_born = 0;

	* Define "Alive and resident" status;
	* Alive and resident from 2006-2019, or born in 2006+ and resident therafter;
	if ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13, res14, res15, res16, res17, res18, res19) = 14) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13, res14, res15, res16, res17, res18, res19) = 13) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13, res14, res15, res16, res17, res18, res19) = 12) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13, res14, res15, res16, res17, res18, res19) = 11) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13, res14, res15, res16, res17, res18, res19) = 10) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13, res14, res15, res16, res17, res18, res19) =  9) OR
	    (birth_yr=2011 and SUM(                                          res12, res13, res14, res15, res16, res17, res18, res19) =  8) OR
	    (birth_yr=2012 and SUM(                                                 res13, res14, res15, res16, res17, res18, res19) =  7) OR
	    (birth_yr=2013 and SUM(                                                        res14, res15, res16, res17, res18, res19) =  6) OR
	    (birth_yr=2014 and SUM(                                                               res15, res16, res17, res18, res19) =  5) OR
	    (birth_yr=2015 and SUM(                                                                      res16, res17, res18, res19) =  4) OR
	    (birth_yr=2016 and SUM(                                                                             res17, res18, res19) =  3) OR
	    (birth_yr=2017 and SUM(                                                                                    res18, res19) =  2) OR
	    (birth_yr=2018 and                                                                                                res19  =  1)) then res_grp = 19;
	* Died in 2018, but resident from 2006-2018, or born in 2006+ and resident until death;
    if ((death_yr=2018) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13, res14, res15, res16, res17, res18) = 13) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13, res14, res15, res16, res17, res18) = 12) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13, res14, res15, res16, res17, res18) = 11) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13, res14, res15, res16, res17, res18) = 10) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13, res14, res15, res16, res17, res18) =  9) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13, res14, res15, res16, res17, res18) =  8) OR
	    (birth_yr=2011 and SUM(                                          res12, res13, res14, res15, res16, res17, res18) =  7) OR
	    (birth_yr=2012 and SUM(                                                 res13, res14, res15, res16, res17, res18) =  6) OR
	    (birth_yr=2013 and SUM(                                                        res14, res15, res16, res17, res18) =  5) OR
	    (birth_yr=2014 and SUM(                                                               res15, res16, res17, res18) =  4) OR
	    (birth_yr=2015 and SUM(                                                                      res16, res17, res18) =  3) OR
		(birth_yr=2016 and SUM(                                                                             res17, res18) =  2) OR
	    (birth_yr=2017 and                                                                                         res18  =  1) OR
		(birth_yr=2018)))                                                                                                          then res_grp = 18;
	* Died in 2017, but resident from 2006-2017, or born in 2006+ and resident until death;
    if ((death_yr=2017) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13, res14, res15, res16, res17) = 12) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13, res14, res15, res16, res17) = 11) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13, res14, res15, res16, res17) = 10) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13, res14, res15, res16, res17) =  9) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13, res14, res15, res16, res17) =  8) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13, res14, res15, res16, res17) =  7) OR
	    (birth_yr=2011 and SUM(                                          res12, res13, res14, res15, res16, res17) =  6) OR
	    (birth_yr=2012 and SUM(                                                 res13, res14, res15, res16, res17) =  5) OR
	    (birth_yr=2013 and SUM(                                                        res14, res15, res16, res17) =  4) OR
	    (birth_yr=2014 and SUM(                                                               res15, res16, res17) =  3) OR
	    (birth_yr=2015 and SUM(                                                                      res16, res17) =  2) OR
	    (birth_yr=2016 and                                                                                  res17  =  1) OR
		(birth_yr=2017)))                                                                                                   then res_grp = 17;
	* Died in 2016, but resident from 2006-2016, or born in 2006+ and resident until death;
	if ((death_yr=2016) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13, res14, res15, res16) = 11) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13, res14, res15, res16) = 10) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13, res14, res15, res16) =  9) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13, res14, res15, res16) =  8) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13, res14, res15, res16) =  7) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13, res14, res15, res16) =  6) OR
	    (birth_yr=2011 and SUM(                                          res12, res13, res14, res15, res16) =  5) OR
	    (birth_yr=2012 and SUM(                                                 res13, res14, res15, res16) =  4) OR
	    (birth_yr=2013 and SUM(                                                        res14, res15, res16) =  3) OR
	    (birth_yr=2014 and SUM(                                                               res15, res16) =  2) OR
	    (birth_yr=2015 and                                                                           res16  =  1) OR
		(birth_yr=2016)))                                                                                            then res_grp = 16;
	* Died in 2015, but resident from 2006-2015, or born in 2006+ and resident until death;
    if ((death_yr=2015) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13, res14, res15) = 10) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13, res14, res15) =  9) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13, res14, res15) =  8) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13, res14, res15) =  7) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13, res14, res15) =  6) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13, res14, res15) =  5) OR
	    (birth_yr=2011 and SUM(                                          res12, res13, res14, res15) =  4) OR
	    (birth_yr=2012 and SUM(                                                 res13, res14, res15) =  3) OR
	    (birth_yr=2013 and SUM(                                                        res14, res15) =  2) OR
	    (birth_yr=2014 and                                                                    res15  =  1) OR
		(birth_yr=2015)))                                                                                     then res_grp = 15;
	* Died in 2014, but resident from 2006-2014, or born in 2006+ and resident until death;
    if ((death_yr=2014) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13, res14) =  9) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13, res14) =  8) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13, res14) =  7) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13, res14) =  6) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13, res14) =  5) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13, res14) =  4) OR
	    (birth_yr=2011 and SUM(                                          res12, res13, res14) =  3) OR
	    (birth_yr=2012 and SUM(                                                 res13, res14) =  2) OR
	    (birth_yr=2013 and                                                             res14  =  1) OR
		(birth_yr=2014)))                                                                              then res_grp = 14;
	* Died in 2013, but resident from 2006-2013, or born in 2006+ and resident until death;
    if ((death_yr=2013) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12, res13) =  8) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12, res13) =  7) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12, res13) =  6) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12, res13) =  5) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12, res13) =  4) OR
	    (birth_yr=2010 and SUM(                                   res11, res12, res13) =  3) OR
	    (birth_yr=2011 and SUM(                                          res12, res13) =  2) OR
	    (birth_yr=2012 and                                                      res13  =  1) OR
		(birth_yr=2013)))                                                                       then res_grp = 13;
	* Died in 2012, but resident from 2006-2012, or born in 2006+ and resident until death;
	if ((death_yr=2012) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11, res12) =  7) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11, res12) =  6) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11, res12) =  5) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11, res12) =  4) OR
	    (birth_yr=2009 and SUM(                            res10, res11, res12) =  3) OR
	    (birth_yr=2010 and SUM(                                   res11, res12) =  2) OR
	    (birth_yr=2011 and                                               res12  =  1) OR
		(birth_yr=2012)))                                                                then res_grp = 12;
	* Died in 2011, but resident from 2006-2011, or born in 2006+ and resident until death;
	if ((death_yr=2011) AND
	   ((                  SUM(res06, res07, res08, res09, res10, res11) =  6) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10, res11) =  5) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10, res11) =  4) OR
	    (birth_yr=2008 and SUM(                     res09, res10, res11) =  3) OR
	    (birth_yr=2009 and SUM(                            res10, res11) =  2) OR
	    (birth_yr=2010 and                                        res11  =  1) OR
		(birth_yr=2011)))                                                         then res_grp = 11;
	* Died in 2010, but resident from 2006-2010, or born in 2006+ and resident until death;
	if ((death_yr=2010) AND
	   ((                  SUM(res06, res07, res08, res09, res10) =  5) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09, res10) =  4) OR
	    (birth_yr=2007 and SUM(              res08, res09, res10) =  3) OR
	    (birth_yr=2008 and SUM(                     res09, res10) =  2) OR
	    (birth_yr=2009 and                                 res10  =  1) OR
		(birth_yr=2010)))                                                  then res_grp = 10;
	* Died in 2009, but resident from 2006-2009, or born in 2006+ and resident until death;
  	if ((death_yr=2009) AND
	   ((                  SUM(res06, res07, res08, res09) =  4) OR
	    (birth_yr=2006 and SUM(       res07, res08, res09) =  3) OR
	    (birth_yr=2007 and SUM(              res08, res09) =  2) OR
	    (birth_yr=2008 and                          res09  =  1) OR
		(birth_yr=2009)))                                           then res_grp = 9;
	* Died in 2008, but resident from 2006-2008, or born in 2006+ and resident until death;
 	if ((death_yr=2008) AND
	   ((                  SUM(res06, res07, res08) =  3) OR
	    (birth_yr=2006 and SUM(       res07, res08) =  2) OR
	    (birth_yr=2007 and                   res08  =  1) OR
		(birth_yr=2008)))                                    then res_grp = 8;
	* Died in 2007, but resident from 2006-2007, or born in 2006+ and resident until death;
	if ((death_yr=2007) AND
	   ((                  SUM(res06, res07) =  2) OR
	    (birth_yr=2006 and            res07  =  1) OR
		(birth_yr=2007)))                            then res_grp = 7;
	* Died in 2006, but resident in 2006 or born in 2006 and resident until death;
	if ((death_yr=2006) AND 
		((res06 = 1) OR 
		(birth_yr=2006))) then res_grp = 6;

	* Alive or deceased in 2006;
	if death_yr ne . and death_yr < 2006 then dead2006 = 1;
		else if death_yr ne . then dead2006 = 0;

	* Remove those who were born and died in the same year;
	if birth_yr = death_yr then birthEQdeath = 1;

	* Why are folks not included?;	
	if res_grp ne . and dead2006 = .          then outsamp = 1;	* Alive & full-time resident of Norway, 2016-19;
		else if dead2006 = 1                  then outsamp = 3; * Deceased < 2006;
		else if birthEQdeath = 1              then outsamp = 0; * Born/died in same year;
		else if res_grp ne . and dead2006 = 0 then outsamp = 2; * Full-time resident who died between 2006-19;
		else if res_grp  = . and dead2006 = . then outsamp = 5;	* Non-resident or missing as at some point between 2006-19;
		else if dead2006 = 0                  then outsamp = 4; * Deceased >= 2006, but not fully resident 2006-19;		

	* Define those to be used as:
	* 	Born in Norway
	*	Alive and resident from 2006-19 or deceased between 2006-19, but resident until death and born between 1895-2019;
	* 	Did not die the year they were born;
	if nor_born = 1 and outsamp in (1, 2) then insample = 1;
		else insample = 0;

	* Create MM/01/YYYY date value for Date of Birth;
	birth    = put(foedsels_aar_mnd, 6.);
	yr_birth = INPUT(SUBSTRN(birth, 1, 4), BEST12.);
	mo_birth = INPUT(SUBSTRN(birth, 5, 2), BEST12.);
	DOB      = MDY(mo_birth, 1, yr_birth);

	* Create age on 01/01/2006 (can be negative for those born > 1006;
	* Create age at death;
	* Create age on 12/31/2019 or age at death, whichever is earliest;
	if DOB ne . then age_start = YRDIF(DOB, MDY(01,01,2006), 'AGE');
	if DOB ne . then age_end   = YRDIF(DOB, MDY(12,31,2019), 'AGE');
	if DOB ne . and DOD ne . then age_death = YRDIF(DOB, DOD, 'AGE');
	
	if age_death ne . and (age_death < age_end) then age_end = age_death;

	format DOB DOD MMYYD. sex SEX. nor_born dead2006 insample NOYES. res_grp RESGRP. outsamp OUTSAMP.;

	label	DOB        = "Date of Birth, MM/01/YYYY"
			DOD        = "Date of Death, MM/01/YYYY"
			sex        = "Sex, 1=M/2=F"
			nor_born   = "Born in Norway? 0/1"
			res_grp    = "Resident group based on resident status/death"
			dead2006   = "Deceased prior to 2006? 0/1"
			insample   = "Alive, resident & born between 1895-2018? 0/1"
			outsamp    = "Why are folks included vs not"
			age_start  = "Age on 01/01/2006 (can be negative for those born, 2006-19)"
			age_end    = "Age at death or on 12/31/2019"
			age_death  = "Age at death";

	keep w19_1011_lnr_k2_ mor_lnr_k2_ far_lnr_k2_ death_yr age_start age_death age_end 
		 DOB DOD sex nor_born res_grp dead2006 insample outsamp invkat;
run;

* Remove N = 7 duplicate ID #'s;
proc sort data = demo1 nodupkey; by w19_1011_lnr_k2_; run;
proc contents data = demo1 varnum; run;

* Find primary partner demographics;
proc sort data = partners1; by primary_id; run;
data primary_demo;
	merge partners1 (in = inpar)
		  demo1 (rename = (w19_1011_lnr_k2_ = primary_id));
	by primary_id;

	if sex = 1 then pp_male = 1;
		else if sex = 2 then pp_male = 0;
	pp_death_yr  = death_yr;
	pp_age_start = age_start;
	pp_age_death = age_death;
	pp_age_end   = age_end;
	pp_DOB       = DOB;
	pp_DOD       = DOD;
	pp_nor_born  = nor_born;
	pp_res_grp   = res_grp;
	pp_dead2006  = dead2006;
	pp_insample  = insample;
	pp_outsamp   = outsamp;
	pp_invkat    = invkat;

	if inpar;

	format pp_DOB pp_DOD MMYYD.;

	drop mor_lnr_k2_ far_lnr_k2_ death_yr age_start age_death age_end DOB DOD sex nor_born res_grp dead2006 insample outsamp invkat;
run;

proc sort data = primary_demo; by w19_1011_lnr_k2_; run;
proc sort data = partners2;    by w19_1011_lnr_k2_; run;
data partners3;
	merge partners2 primary_demo;
	by w19_1011_lnr_k2_;

	if male ne . AND pp_male ne . then do;
		if male = pp_male then pp_oppsex = 0;
			else pp_oppsex = 1;
	end;
run;

data kept_partners;
	set partners3;

	if pp_oppsex = 1;

	if pp_outsamp in (1,2);
run;

proc freq data = kept_partners;
	table 	/*nor_born    res_grp    dead2006    insample    outsamp    invkat
			p1_nor_born p1_res_grp p1_dead2006 p1_insample p1_outsamp p1_invkat*/
			pp_nor_born pp_res_grp pp_dead2006 pp_insample pp_outsamp pp_invkat;
run;

proc means data = kept_partners;
	var age_start age_end pp_age_start pp_age_end;
run;

data thr_asm.kept_partners_Dec2014;
	set kept_partners;
run;

data kept_partners;
	set thr_asm.kept_partners;* (keep = w19_1011_lnr_k2_ first_id primary_id);
run;

* Get partners' MH data;
* Read in Kuhr datasets;
%macro read_kuhr(in, out);
	proc import file = &in
		out = &out
		dbms = csv
		replace;
		guessingrows = 10000;
	run;
	data &out;
		set &out;

		* Only keep Chapter "P";
		if diag_chapter = "P";

		* If specific diagnosis is "P" (without # code), then delete;
		if DIAG ne "P";
	run;
%mend read_kuhr;

* NOTE: some read-in errors are noted in the log for missing data coded as "NA" from R;
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2006 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2006);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2007 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2007);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2008 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2008);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2009 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2009);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2010 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2010);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2011 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2011);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2012 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2012);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2013 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2013);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2014 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2014);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2015 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2015);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2016 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2016);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2017 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2017);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2018 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2018);
%read_kuhr(in = "N:\durable\Data22\original_data\k2_-2019 Data fra KUHR 19-6208_aug23fix.dsv", out = kuhr_2019);

data kuhr_2006; set kuhr_2006; new = INPUT(KONTAKTTYPE, 8.); drop KONTAKTTYPE; data kuhr_2006; set kuhr_2006; KONTAKTTYPE = new; drop new;
data kuhr_2007; set kuhr_2007; new = INPUT(KONTAKTTYPE, 8.); drop KONTAKTTYPE; data kuhr_2007; set kuhr_2007; KONTAKTTYPE = new; drop new;
data kuhr_2008; set kuhr_2008; new = INPUT(KONTAKTTYPE, 8.); drop KONTAKTTYPE; data kuhr_2008; set kuhr_2008; KONTAKTTYPE = new; drop new;
data kuhr_2009; set kuhr_2009; new = INPUT(KONTAKTTYPE, 8.); drop KONTAKTTYPE; data kuhr_2009; set kuhr_2009; KONTAKTTYPE = new; drop new;
data kuhr_2010; set kuhr_2010; new = INPUT(KONTAKTTYPE, 8.); drop KONTAKTTYPE; data kuhr_2010; set kuhr_2010; KONTAKTTYPE = new; drop new;
data kuhr_2011; set kuhr_2011; new = INPUT(KONTAKTTYPE, 8.); drop KONTAKTTYPE; data kuhr_2011; set kuhr_2011; KONTAKTTYPE = new; drop new; run;

* Combine and remove unnecessary variables;
data kuhr_2006_19;
	set	kuhr_2006 kuhr_2007 kuhr_2008 kuhr_2009 kuhr_2010 kuhr_2011 kuhr_2012
		kuhr_2013 kuhr_2014 kuhr_2015 kuhr_2016 kuhr_2017 kuhr_2018 kuhr_2019;

	w19_1011_lnr_k2_ = LOPENR_k2_;

	keep w19_1011_lnr_k2_ DATO DIAG diag_chapter is_diag codetype FAGOMRAADE_KODE KONTAKTTYPE;
run;

proc contents data = kuhr_2006_19 varnum; run;

proc sort data = kuhr_2006_19; by w19_1011_lnr_k2_ DATO DIAG; run;

proc datasets;
	delete	kuhr_2006 kuhr_2007 kuhr_2008 kuhr_2009 kuhr_2010 kuhr_2011 kuhr_2012
			kuhr_2013 kuhr_2014 kuhr_2015 kuhr_2016 kuhr_2017 kuhr_2018 kuhr_2019;
run;
quit;

data kuhr;
	set kuhr_2006_19;

	* ID contact with doctors;
	if FAGOMRAADE_KODE = "LE" then doctor = 1;
		else doctor = 0;

	* ID contact-types 1-4;
	if KONTAKTTYPE in (1,2,3,4) then contact14 = 1;
		else contact14 = 0;

	if doctor = 1 and contact14 = 1 then good_code = 1;
		else good_code = 0;
run;

proc freq data = kuhr;
	table good_code good_code*doctor*contact14 / list missing;
run;

/* *REMOVE NON-DOCTOR, NON-IN-PERSON CODES; 
data kuhr1;
	set kuhr;

	if good_code = 1;

	drop FAGOMRAADE_KODE KONTAKTTYPE doctor contact14 good_code;
run;
proc contents data = kuhr1; run;
*/

* Get primary partner's MH dx's;
proc sort data = kept_partners out = primaryid nodupkey; by primary_id; run;
data primary_kuhr;
	merge primaryid (in = inpar)
		  kuhr (rename = (w19_1011_lnr_k2_ = primary_id));
	by primary_id;

	pp_DATO         = DATO;
	pp_is_diag      = is_diag;
	pp_codetype     = codetype;
	pp_diag_chapter = diag_chapter;
	pp_DIAG         = DIAG;

	if inpar;

	format pp_DATO YYMMDD10.;

	drop DATO is_diag codetype diag_chapter DIAG;
run;

* Get primary partner's MH dx's;
* Code diagnoses into categories we're using;
proc sort data = kept_partners; by primary_id; run;
proc sort data = primary_kuhr; by primary_id pp_DATO; run;
data primary_kuhr1;
	merge	primary_kuhr (in = inmedr)
			kept_partners (keep = primary_id pp_DOB pp_age_start);
	by primary_id;		

	if inmedr;

	if pp_DOB ne . and pp_DATO ne . then pp_age_dx =  YRDIF(pp_DOB, pp_DATO, 'AGE');

	pp_age_floor    = FLOOR(pp_age_start);
	pp_age_dx_floor = FLOOR(pp_age_dx);

	pp_age_start_mo = INTCK('MONTH', pp_DOB, MDY(01,01,2006), 'D');
	pp_age_dx_mo    = INTCK('MONTH', pp_DOB, pp_DATO, 'D');

	* Code mental health into diagnoses;
	if pp_DIAG in ("P02")                                      then pp_MHdx = 1;
		else if pp_DIAG in ("P81")                             then pp_MHdx = 2;
		else if pp_DIAG in ("P01", "P74")                      then pp_MHdx = 3;
		else if pp_DIAG in ("P05", "P20", "P70")               then pp_MHdx = 4;
		else if pp_DIAG in ("P03", "P76")                      then pp_MHdx = 5;		
		else if pp_DIAG in ("P24", "P28", "P85")               then pp_MHdx = 6;
		else if pp_DIAG in ("P11", "P86")                      then pp_MHdx = 7;
		else if pp_DIAG in ("P79")                      	   then pp_MHdx = 8;
		else if pp_DIAG in ("P71", "P72", "P73", "P98")		   then pp_MHdx = 9;
		else if pp_DIAG in ("P82")							   then pp_MHdx = 10;		
		else if pp_DIAG in ("P07", "P08", "P09")			   then pp_MHdx = 11;
		else if pp_DIAG in ("P06")							   then pp_MHdx = 12;
		else if pp_DIAG in ("P75")							   then pp_MHdx = 13;
		else if pp_DIAG in ("P15", "P16", "P17", "P18", "P19") then pp_MHdx = 14;
		else if pp_DIAG in ("P77")							   then pp_MHdx = 15;
		else if pp_DIAG in ("P22", "P23")                      then pp_MHdx = 16;
		else if pp_DIAG in ("P12", "P13")                      then pp_MHdx = 17;
		else if pp_DIAG in ("P80")                             then pp_MHdx = 18;
		else if pp_DIAG in ("P78")                             then pp_MHdx = 19;
		else if pp_DIAG in ("P25")                             then pp_MHdx = 20;
		else if pp_DIAG in ("P10")                             then pp_MHdx = 21;
		else if pp_DIAG in ("P27")                             then pp_MHdx = 22;
		else if pp_DIAG in ("P04")                             then pp_MHdx = 23;
		else if pp_DIAG in ("P29", "P99")                      then pp_MHdx = 24;

	if pp_MHdx ne . then pp_anyMH = 1;
		else pp_anyMH = 0;

	* Keep only codes we're using;
	if pp_anyMH = 1;

	*drop pp_anyMH;

	format pp_MHdx MHDX.;
run;

proc sort data = primary_kuhr1 out = pp_uniqdx nodupkey; by primary_id pp_MHdx; run;
data pp_mhdx_wide;
	array dx [24]	pp_any_str pp_any_adhd pp_any_anx pp_any_dem  pp_any_dep pp_any_dev pp_any_eat pp_any_phb pp_any_psy pp_any_ptsd pp_any_sex pp_any_slp 
					pp_any_som pp_any_sub  pp_any_sui pp_any_chad pp_any_con pp_any_per pp_any_crf pp_any_pha pp_any_stm pp_any_fmh  pp_any_irr pp_any_oth;

	do i = 1 to 25 until (last.primary_id);
		set pp_uniqdx;
		by primary_id;
	
		if pp_MHdx =  1 then pp_any_str  = 1;
		if pp_MHdx =  2 then pp_any_adhd = 1;
		if pp_MHdx =  3 then pp_any_anx  = 1;
		if pp_MHdx =  4 then pp_any_dem  = 1;
		if pp_MHdx =  5 then pp_any_dep  = 1;
		if pp_MHdx =  6 then pp_any_dev  = 1;
		if pp_MHdx =  7 then pp_any_eat  = 1;
		if pp_MHdx =  8 then pp_any_phb  = 1;
		if pp_MHdx =  9 then pp_any_psy  = 1;
		if pp_MHdx = 10 then pp_any_ptsd = 1;
		if pp_MHdx = 11 then pp_any_sex  = 1;
		if pp_MHdx = 12 then pp_any_slp  = 1;
		if pp_MHdx = 13 then pp_any_som  = 1;
		if pp_MHdx = 14 then pp_any_sub  = 1;
		if pp_MHdx = 15 then pp_any_sui  = 1;
		if pp_MHdx = 16 then pp_any_chad = 1;
		if pp_MHdx = 17 then pp_any_con  = 1;
		if pp_MHdx = 18 then pp_any_per  = 1;
		if pp_MHdx = 19 then pp_any_crf  = 1;
		if pp_MHdx = 20 then pp_any_pha  = 1;
		if pp_MHdx = 21 then pp_any_stm  = 1;
		if pp_MHdx = 22 then pp_any_fmh  = 1;
		if pp_MHdx = 23 then pp_any_irr  = 1;
		if pp_MHdx = 24 then pp_any_oth  = 1;
	end;

	keep primary_id
		 pp_any_str pp_any_adhd pp_any_anx pp_any_dem  pp_any_dep pp_any_dev pp_any_eat pp_any_phb pp_any_psy pp_any_ptsd pp_any_sex pp_any_slp 
		 pp_any_som pp_any_sub  pp_any_sui pp_any_chad pp_any_con pp_any_per pp_any_crf pp_any_pha pp_any_stm pp_any_fmh  pp_any_irr pp_any_oth;
run;

* Combine focal/primary partner demographic info;
proc sort data = kept_partners;  by primary_id w19_1011_lnr_k2_; run;
proc sort data = pp_mhdx_wide;   by primary_id; run;

data focal_primary_MH;
	merge kept_partners (in = infam)
		  pp_mhdx_wide;
	by primary_id;
run;

proc sort data = focal_primary_MH; by w19_1011_lnr_k2_; run;

data focal_primary_MH1;
	set focal_primary_MH;

	array pp_dx [24]	pp_any_str pp_any_adhd pp_any_anx pp_any_dem  pp_any_dep pp_any_dev pp_any_eat pp_any_phb pp_any_psy pp_any_ptsd pp_any_sex pp_any_slp 
		 				pp_any_som pp_any_sub  pp_any_sui pp_any_chad pp_any_con pp_any_per pp_any_crf pp_any_pha pp_any_stm pp_any_fmh  pp_any_irr pp_any_oth;						
		 
	do i = 1 to 24;
		if pp_dx[i]   =  . then pp_dx[i] = 0;
		if primary_id = '' then pp_dx[i] = .;
	end;

	if SUM(pp_any_str, pp_any_adhd, pp_any_anx, pp_any_dep, pp_any_phb, pp_any_psy, pp_any_ptsd, pp_any_sex, pp_any_slp, 
		   pp_any_som, pp_any_sub,  pp_any_sui, pp_any_per, pp_any_oth) > 0 then pp_any_MH = 1;
		else if primary_id ne '' then pp_any_MH = 0;

	if primary_id = '' then no_primary = 1; else no_primary = 0;

	drop i;
run;

proc freq data = focal_primary_MH1;
	table no_primary;
run;

data focal_primary_MH_Dec2024;
	set no_partners
		focal_primary_MH1;
run;
	
proc sort data = focal_primary_MH_Dec2024; by w19_1011_lnr_k2_;run;
data thr_asm.focal_primary_MH_Dec2024;
	set focal_primary_MH_Dec2024;
run;





/*
data variety;
	set thr_asm.focal_first_primary_MH_Oct2024;

	ndx    = SUM(any_sub, any_adhd, any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, any_oth, any_slp, any_sex, any_per, any_sui);
	pp_ndx = SUM(pp_any_sub, pp_any_adhd, pp_any_dep, pp_any_str, pp_any_anx, pp_any_phb, pp_any_ptsd, pp_any_som, pp_any_oth, pp_any_slp, pp_any_sex, pp_any_per, pp_any_sui);
run;

proc means data = variety;
	class male;
	var ndx;
run;
proc means data = variety;
	class male;
	var ndx;
	where no_partner = 0;
run;

proc sort data = variety out = prim_variety nodupkey; by primary_id; run;
proc means data = prim_variety;
	class male;
	var pp_ndx;
run;

proc freq data = variety;
	table  ndx pp_ndx;
	where no_partner = 0;
proc corr data = variety;
	var ndx pp_ndx;
	where no_partner = 0;
proc countreg data = variety method = qn;
	model pp_Ndx = ndx / dist = negbin;
	where no_partner = 0;
run;
	





* Find # of encounters for ALL focal people;
data included;
	set thr_asm.focal_first_primary_MH_Oct2024;

	if no_partner = 1 then have_partner = 0;
		else if no_partner = 0 then have_partner = 1;

	keep w19_1011_lnr_k2_ primary_id have_partner male;
run;

proc sort data = included; by w19_1011_lnr_k2_; run;

data all;
	merge medrec1 included (in = kept);
	by w19_1011_lnr_k2_;

	if kept;

	if dato ne .;
run;

proc freq data = all;
	table w19_1011_lnr_k2_;
	ods output OneWayFreqs = dxcount_m;
	where male = 1;
run;
proc means data = dxcount_m;
	var Frequency;
run;

proc freq data = all;
	table w19_1011_lnr_k2_;
	ods output OneWayFreqs = dxcount_f;
	where male = 0;
run;
proc means data = dxcount_f;
	var Frequency;
run;

data dxcount1;
	merge dxcount_m dxcount_f included;
	by w19_1011_lnr_k2_;

	if w19_1011_lnr_k2_ ne "";

	if Frequency = . then Frequency = 0;
run;

proc means data = dxcount1;
	class male;
	var Frequency;
run;

* Only those who have partners;
proc freq data = all;
	table w19_1011_lnr_k2_;
	ods output OneWayFreqs = dxcount_m;
	where male = 1 and have_partner = 1;
run;
proc freq data = all;
	table w19_1011_lnr_k2_;
	ods output OneWayFreqs = dxcount_f;
	where male = 0 and have_partner = 1;
run;

data dxcount2;
	merge dxcount_m dxcount_f included;
	by w19_1011_lnr_k2_;

	if w19_1011_lnr_k2_ ne "";

	if Frequency = . then Frequency = 0;
run;

proc means data = dxcount_f;
	var Frequency;
run;
proc means data = dxcount_m;
	var Frequency;
run;
proc means data = dxcount2;
	class male;
	var Frequency;
	where have_partner = 1;
run;

data thr_asm.dxcount_focal;
	set dxcount2;

	Ndx = Frequency;

	drop Frequency;
run;


data thr_asm.primary_kuhr;
	set primary_kuhr1;
run;

data primary_kuhr1;
	set thr_asm.primary_kuhr;
run;

* Find # of encounters for ALL focal people;
data included;
	set thr_asm.focal_first_primary_MH_Oct2024;

	if no_partner = 1 then have_partner = 0;
		else if no_partner = 0 then have_partner = 1;

	if primary_id ne '';
	keep w19_1011_lnr_k2_ primary_id have_partner pp_male;
run;
proc sort data = included nodupkey; by primary_id; run;

data all;
	merge primary_kuhr1 included (in = kept);
	by primary_id;

	if kept;

	if pp_dato ne .;
run;

proc freq data = all;
	table primary_id;
	ods output OneWayFreqs = dxcount_m;
	where pp_male = 1;
run;
proc freq data = all;
	table primary_id;
	ods output OneWayFreqs = dxcount_f;
	where pp_male = 0;
run;

data dxcount1;
	merge dxcount_m dxcount_f included;
	by primary_id;

	if primary_id ne "";

	if Frequency = . then Frequency = 0;
run;

proc means data = dxcount_m;
	var Frequency;
proc means data = dxcount_f;
	var Frequency;
run;
proc means data = dxcount1;
	class pp_male;
	var Frequency;
run;

data thr_asm.dxcount_primary;
	set dxcount1;

	pp_Ndx = Frequency;

	drop Frequency;
run;

*/
