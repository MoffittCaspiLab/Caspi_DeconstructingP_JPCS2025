DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Parent_Child\01_3Reasons_Response_Jan2026.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: 3 Reasons -- Response to reviewers 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Parent_Child\01_3Reasons_Response_Jan2026.sas;
* Modification Hx:	
*
***************************************************************************************************;

libname rawdat	"N:\durable\Data22\processed_data";
libname thr_par	"M:\p1074-renateh\2024_ThreeReasons\Parent_Child";

proc format;
	value SEX
		1 = "Male"
		2 = "Female";
	value NOYES
		0 = "No"
		1 = "Yes";
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
run;

* Find child records;
* Read in medical records and bring down to ages [5-20) at end;
* Keep only mental health codes (Chapter P);

data medrec;
	set rawdat.MedRec_pcodes_26Sept2025;

	if age_dx >= 5 and age_dx <= 15;

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
			rawdat.Demog_25Sept2025 (keep = w19_1011_lnr_k2_ DOB);
	by w19_1011_lnr_k2_;		

	if inmedr;

	age_start_fl = FLOOR(age_start);
	age_dx_fl    = FLOOR(age_dx);
	yr_dx        = YEAR(DATO);

	* Code mental health into diagnoses;
	if DIAG in ("P02")                                      then MHdx = 1;
		else if DIAG in ("P81")                             then MHdx = 2;
		else if DIAG in ("P01", "P74")                      then MHdx = 3;
		else if DIAG in ("P20")                             then MHdx = 4;
		else if DIAG in ("P03", "P76")                      then MHdx = 5;		
		else if DIAG in ("P24", "P28", "P85")               then MHdx = 6;
		else if DIAG in ("P11", "P86")                      then MHdx = 7;
		else if DIAG in ("P79")                      		then MHdx = 8;
		else if DIAG in ("P71", "P72", "P73", "P98")		then MHdx = 9;
		else if DIAG in ("P82")							    then MHdx = 10;		
		else if DIAG in ("P07", "P08", "P09")				then MHdx = 11;
		else if DIAG in ("P06")							    then MHdx = 12;
		else if DIAG in ("P75")							    then MHdx = 13;
		else if DIAG in ("P15", "P16", "P17", "P18", "P19") then MHdx = 14;
		else if DIAG in ("P77")							    then MHdx = 15;
		else if DIAG in ("P22", "P23")                      then MHdx = 16;
		else if DIAG in ("P12", "P13")                      then MHdx = 17;
		else if DIAG in ("P80")                             then MHdx = 18;
		else if DIAG in ("P78")                             then MHdx = 19;
		else if DIAG in ("P25")                             then MHdx = 20;
		else if DIAG in ("P10")                             then MHdx = 21;
		else if DIAG in ("P27")                             then MHdx = 22;
		else if DIAG in ("P04")                             then MHdx = 23;
		else if DIAG in ("P29", "P99")                      then MHdx = 24;

	if MHdx ne . then anyMH = 1;
		else anyMH = 0;

	* Keep only codes we're using;
	if anyMH = 1;

	drop anyMH;

	format MHdx MHDX.;
run;

* Bring analysis sample down to ages [5-20) at end;;
data demog;
	merge rawdat.Demog_25Sept2025;
	by w19_1011_lnr_k2_;

	cohort = YEAR(DOB);

	* Create age on 01/01/2006 (can be negative for those born > 2006;
	* Create age at death;
	* Create age on 12/31/2024 or age at death, whichever is earliest;
	if DOB ne . then age_start = YRDIF(DOB, MDY(01,01,2006), 'AGE');
	if DOB ne . then age_end   = YRDIF(DOB, MDY(12,31,2024), 'AGE');
	if DOB ne . and DOD ne . then age_death = YRDIF(DOB, DOD, 'AGE');
	
	if age_death ne . and (age_death < age_end) then age_end = age_death;

	age_start_fl = FLOOR(age_start);
	age_end_fl   = FLOOR(age_end);

	yr_span = age_end_fl - age_start_fl;

	if age_end_fl >= 15 and cohort > 1995;

	if sex = 1 then male = 1;
		else if sex = 2 then male = 0;

	if yr_span >= 10 and age_start_fl <= 5;
run;

* Find year of first and last dx;
proc sort data = medrec1; by w19_1011_lnr_k2_ yr_dx; run;
proc sort data = medrec1 out = mindxyr nodupkey; by w19_1011_lnr_k2_; run;
data mindxyr; set mindxyr; mindxyr = yr_dx; keep w19_1011_lnr_k2_ mindxyr; run;
proc sort data = medrec1; by w19_1011_lnr_k2_ descending yr_dx; run;
proc sort data = medrec1 out = maxdxyr nodupkey; by w19_1011_lnr_k2_; run;
data maxdxyr; set maxdxyr; maxdxyr = yr_dx; keep w19_1011_lnr_k2_ maxdxyr; run;

data minmaxdxyr;
	merge mindxyr maxdxyr;
	by w19_1011_lnr_k2_;
run;

* Create wide file with indicator variables for ever having dx;
proc sort data = medrec1; by w19_1011_lnr_k2_ MHdx age_dx_fl; run;
proc sort data = medrec1 out = uniqdx nodupkey; by w19_1011_lnr_k2_ MHdx; run;

data medrec_wide;
	array dx [24]	any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
					any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth;
	array fst [24]	fst_str fst_adhd fst_anx fst_dem  fst_dep fst_dev fst_eat fst_phb fst_psy fst_ptsd fst_sex fst_slp 
					fst_som fst_sub  fst_sui fst_chad fst_con fst_per fst_crf fst_pha fst_stm fst_fmh  fst_irr fst_oth;

	do i = 1 to 25 until (last.w19_1011_lnr_k2_);
		set uniqdx;
		by w19_1011_lnr_k2_;
	
		if MHdx =  1 then do; any_str  = 1; fst_str  = age_dx_fl; end;
		if MHdx =  2 then do; any_adhd = 1; fst_adhd = age_dx_fl; end;
		if MHdx =  3 then do; any_anx  = 1; fst_anx  = age_dx_fl; end;
		if MHdx =  4 then do; any_dem  = 1; fst_dem  = age_dx_fl; end;
		if MHdx =  5 then do; any_dep  = 1; fst_dep  = age_dx_fl; end;
		if MHdx =  6 then do; any_dev  = 1; fst_dev  = age_dx_fl; end;
		if MHdx =  7 then do; any_eat  = 1; fst_eat  = age_dx_fl; end;
		if MHdx =  8 then do; any_phb  = 1; fst_phb  = age_dx_fl; end;
		if MHdx =  9 then do; any_psy  = 1; fst_psy  = age_dx_fl; end;
		if MHdx = 10 then do; any_ptsd = 1; fst_ptsd = age_dx_fl; end;
		if MHdx = 11 then do; any_sex  = 1; fst_sex  = age_dx_fl; end;
		if MHdx = 12 then do; any_slp  = 1; fst_slp  = age_dx_fl; end;
		if MHdx = 13 then do; any_som  = 1; fst_som  = age_dx_fl; end;
		if MHdx = 14 then do; any_sub  = 1; fst_sub  = age_dx_fl; end;
		if MHdx = 15 then do; any_sui  = 1; fst_sui  = age_dx_fl; end;
		if MHdx = 16 then do; any_chad = 1; fst_chad = age_dx_fl; end;
		if MHdx = 17 then do; any_con  = 1; fst_con  = age_dx_fl; end;
		if MHdx = 18 then do; any_per  = 1; fst_per  = age_dx_fl; end;
		if MHdx = 19 then do; any_crf  = 1; fst_crf  = age_dx_fl; end;
		if MHdx = 20 then do; any_pha  = 1; fst_pha  = age_dx_fl; end;
		if MHdx = 21 then do; any_stm  = 1; fst_stm  = age_dx_fl; end;
		if MHdx = 22 then do; any_fmh  = 1; fst_fmh  = age_dx_fl; end;
		if MHdx = 23 then do; any_irr  = 1; fst_irr  = age_dx_fl; end;
		if MHdx = 24 then do; any_oth  = 1; fst_oth  = age_dx_fl; end;
	end;

	keep w19_1011_lnr_k2_
		 any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
		 any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth
		 fst_str fst_adhd fst_anx fst_dem  fst_dep fst_dev fst_eat fst_phb fst_psy fst_ptsd fst_sex fst_slp 
		 fst_som fst_sub  fst_sui fst_chad fst_con fst_per fst_crf fst_pha fst_stm fst_fmh  fst_irr fst_oth;
run;

data medrec_wide_c;
	merge demog (in = indem) medrec_wide;
	by w19_1011_lnr_k2_;

	if indem;

	array dx [24]	any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
		 			any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth;
	array ag [24]	fst_str fst_adhd fst_anx fst_dem  fst_dep fst_dev fst_eat fst_phb fst_psy fst_ptsd fst_sex fst_slp 
		 			fst_som fst_sub  fst_sui fst_chad fst_con fst_per fst_crf fst_pha fst_stm fst_fmh  fst_irr fst_oth;

	do i = 1 to 24;
		if dx[i] = . then dx[i] = 0;
		if ag[i] = . then ag[i] = 99999999;
	end;

	* Any MH using only codes we're using;
	if SUM(any_sub, any_ADHD, any_chad, 
		   any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, 
		   any_psy, 
		   any_oth, any_slp, any_sex, any_per, any_sui, any_con, any_dev, any_stm) > 0 then any_MH = 1;
		else any_MH = 0;

	* Variety of MH dx;
	var_MH = SUM(any_sub, any_ADHD, any_chad, 
		   		 any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, 
		   		 any_psy, 
		   		 any_oth, any_slp, any_sex, any_per, any_sui, any_con, any_dev, any_stm);

	* Age First MH;
	fst_MH = MIN(fst_sub, fst_ADHD, fst_chad, 
		   		 fst_dep, fst_str, fst_anx, fst_phb, fst_ptsd, fst_som, 
		   		 fst_psy, 
		   		 fst_oth, fst_slp, fst_sex, fst_per, fst_sui, fst_con, fst_dev, fst_stm);
	if fst_MH = 99999999 then fst_MH = .;
	
	do i = 1 to 24;
		if ag[i] = 99999999 then ag[i] = .;
	end;
	drop i;
run;

* Persistence;
data medrec2;
	set medrec1;

	dx_year = YEAR(DATO);
run;
proc freq data = medrec2 noprint; table w19_1011_lnr_k2_*dx_year*MHdx / out = N_dx_year; run;
proc sort data = N_dx_year; by w19_1011_lnr_k2_; run;
data N_dx_year; set N_dx_year; drop percent; run;

data PV;

	do i = 1 to 100 until (last.w19_1011_lnr_k2_);
		set N_dx_year;
		by w19_1011_lnr_k2_;
	
		if dx_year = 2006 then do; 
			if MHdx =  1 then an06_str = COUNT; if MHdx =  2 then an06_adhd = COUNT; if MHdx =  3 then an06_anx = COUNT; if MHdx = 16 then an06_chad = COUNT; 
			if MHdx =  5 then an06_dep = COUNT; if MHdx =  6 then an06_dev  = COUNT; if MHdx = 11 then an06_sex = COUNT; if MHdx =  8 then an06_phb  = COUNT; 
			if MHdx =  9 then an06_psy = COUNT; if MHdx = 10 then an06_ptsd = COUNT; if MHdx = 12 then an06_slp = COUNT; if MHdx = 13 then an06_som  = COUNT;
			if MHdx = 14 then an06_sub = COUNT; if MHdx = 15 then an06_sui  = COUNT; if MHdx = 24 then an06_oth = COUNT; if MHdx = 18 then an06_per  = COUNT;
			if MHdx = 17 then an06_con = COUNT; if MHdx = 21 then an06_stm  = COUNT;
		end;
		if dx_year = 2007 then do; 
			if MHdx =  1 then an07_str = COUNT; if MHdx =  2 then an07_adhd = COUNT; if MHdx =  3 then an07_anx = COUNT; if MHdx = 16 then an07_chad = COUNT; 
			if MHdx =  5 then an07_dep = COUNT; if MHdx =  6 then an07_dev  = COUNT; if MHdx = 11 then an07_sex = COUNT; if MHdx =  8 then an07_phb  = COUNT; 
			if MHdx =  9 then an07_psy = COUNT; if MHdx = 10 then an07_ptsd = COUNT; if MHdx = 12 then an07_slp = COUNT; if MHdx = 13 then an07_som  = COUNT;
			if MHdx = 14 then an07_sub = COUNT; if MHdx = 15 then an07_sui  = COUNT; if MHdx = 24 then an07_oth = COUNT; if MHdx = 18 then an07_per  = COUNT;
			if MHdx = 17 then an07_con = COUNT; if MHdx = 21 then an07_stm  = COUNT;
		end;
		if dx_year = 2008 then do; 
			if MHdx =  1 then an08_str = COUNT; if MHdx =  2 then an08_adhd = COUNT; if MHdx =  3 then an08_anx = COUNT; if MHdx = 16 then an08_chad = COUNT; 
			if MHdx =  5 then an08_dep = COUNT; if MHdx =  6 then an08_dev  = COUNT; if MHdx = 11 then an08_sex = COUNT; if MHdx =  8 then an08_phb  = COUNT; 
			if MHdx =  9 then an08_psy = COUNT; if MHdx = 10 then an08_ptsd = COUNT; if MHdx = 12 then an08_slp = COUNT; if MHdx = 13 then an08_som  = COUNT;
			if MHdx = 14 then an08_sub = COUNT; if MHdx = 15 then an08_sui  = COUNT; if MHdx = 24 then an08_oth = COUNT; if MHdx = 18 then an08_per  = COUNT;
			if MHdx = 17 then an08_con = COUNT; if MHdx = 21 then an08_stm  = COUNT;
		end;
		if dx_year = 2009 then do; 
			if MHdx =  1 then an09_str = COUNT; if MHdx =  2 then an09_adhd = COUNT; if MHdx =  3 then an09_anx = COUNT; if MHdx = 16 then an09_chad = COUNT; 
			if MHdx =  5 then an09_dep = COUNT; if MHdx =  6 then an09_dev  = COUNT; if MHdx = 11 then an09_sex = COUNT; if MHdx =  8 then an09_phb  = COUNT; 
			if MHdx =  9 then an09_psy = COUNT; if MHdx = 10 then an09_ptsd = COUNT; if MHdx = 12 then an09_slp = COUNT; if MHdx = 13 then an09_som  = COUNT;
			if MHdx = 14 then an09_sub = COUNT; if MHdx = 15 then an09_sui  = COUNT; if MHdx = 24 then an09_oth = COUNT; if MHdx = 18 then an09_per  = COUNT;
			if MHdx = 17 then an09_con = COUNT; if MHdx = 21 then an09_stm  = COUNT;
		end;
		if dx_year = 2010 then do; 
			if MHdx =  1 then an10_str = COUNT; if MHdx =  2 then an10_adhd = COUNT; if MHdx =  3 then an10_anx = COUNT; if MHdx = 16 then an10_chad = COUNT; 
			if MHdx =  5 then an10_dep = COUNT; if MHdx =  6 then an10_dev  = COUNT; if MHdx = 11 then an10_sex = COUNT; if MHdx =  8 then an10_phb  = COUNT; 
			if MHdx =  9 then an10_psy = COUNT; if MHdx = 10 then an10_ptsd = COUNT; if MHdx = 12 then an10_slp = COUNT; if MHdx = 13 then an10_som  = COUNT;
			if MHdx = 14 then an10_sub = COUNT; if MHdx = 15 then an10_sui  = COUNT; if MHdx = 24 then an10_oth = COUNT; if MHdx = 18 then an10_per  = COUNT;
			if MHdx = 17 then an10_con = COUNT; if MHdx = 21 then an10_stm  = COUNT;
		end;
		if dx_year = 2011 then do; 
			if MHdx =  1 then an11_str = COUNT; if MHdx =  2 then an11_adhd = COUNT; if MHdx =  3 then an11_anx = COUNT; if MHdx = 16 then an11_chad = COUNT; 
			if MHdx =  5 then an11_dep = COUNT; if MHdx =  6 then an11_dev  = COUNT; if MHdx = 11 then an11_sex = COUNT; if MHdx =  8 then an11_phb  = COUNT; 
			if MHdx =  9 then an11_psy = COUNT; if MHdx = 10 then an11_ptsd = COUNT; if MHdx = 12 then an11_slp = COUNT; if MHdx = 13 then an11_som  = COUNT;
			if MHdx = 14 then an11_sub = COUNT; if MHdx = 15 then an11_sui  = COUNT; if MHdx = 24 then an11_oth = COUNT; if MHdx = 18 then an11_per  = COUNT;
			if MHdx = 17 then an11_con = COUNT; if MHdx = 21 then an11_stm  = COUNT;
		end;
		if dx_year = 2012 then do; 
			if MHdx =  1 then an12_str = COUNT; if MHdx =  2 then an12_adhd = COUNT; if MHdx =  3 then an12_anx = COUNT; if MHdx = 16 then an12_chad = COUNT; 
			if MHdx =  5 then an12_dep = COUNT; if MHdx =  6 then an12_dev  = COUNT; if MHdx = 11 then an12_sex = COUNT; if MHdx =  8 then an12_phb  = COUNT; 
			if MHdx =  9 then an12_psy = COUNT; if MHdx = 10 then an12_ptsd = COUNT; if MHdx = 12 then an12_slp = COUNT; if MHdx = 13 then an12_som  = COUNT;
			if MHdx = 14 then an12_sub = COUNT; if MHdx = 15 then an12_sui  = COUNT; if MHdx = 24 then an12_oth = COUNT; if MHdx = 18 then an12_per  = COUNT;
			if MHdx = 17 then an12_con = COUNT; if MHdx = 21 then an12_stm  = COUNT;
		end;
		if dx_year = 2013 then do; 
			if MHdx =  1 then an13_str = COUNT; if MHdx =  2 then an13_adhd = COUNT; if MHdx =  3 then an13_anx = COUNT; if MHdx = 16 then an13_chad = COUNT; 
			if MHdx =  5 then an13_dep = COUNT; if MHdx =  6 then an13_dev  = COUNT; if MHdx = 11 then an13_sex = COUNT; if MHdx =  8 then an13_phb  = COUNT; 
			if MHdx =  9 then an13_psy = COUNT; if MHdx = 10 then an13_ptsd = COUNT; if MHdx = 12 then an13_slp = COUNT; if MHdx = 13 then an13_som  = COUNT;
			if MHdx = 14 then an13_sub = COUNT; if MHdx = 15 then an13_sui  = COUNT; if MHdx = 24 then an13_oth = COUNT; if MHdx = 18 then an13_per  = COUNT;
			if MHdx = 17 then an13_con = COUNT; if MHdx = 21 then an13_stm  = COUNT;
		end;
		if dx_year = 2014 then do; 
			if MHdx =  1 then an14_str = COUNT; if MHdx =  2 then an14_adhd = COUNT; if MHdx =  3 then an14_anx = COUNT; if MHdx = 16 then an14_chad = COUNT; 
			if MHdx =  5 then an14_dep = COUNT; if MHdx =  6 then an14_dev  = COUNT; if MHdx = 11 then an14_sex = COUNT; if MHdx =  8 then an14_phb  = COUNT; 
			if MHdx =  9 then an14_psy = COUNT; if MHdx = 10 then an14_ptsd = COUNT; if MHdx = 12 then an14_slp = COUNT; if MHdx = 13 then an14_som  = COUNT;
			if MHdx = 14 then an14_sub = COUNT; if MHdx = 15 then an14_sui  = COUNT; if MHdx = 24 then an14_oth = COUNT; if MHdx = 18 then an14_per  = COUNT;
			if MHdx = 17 then an14_con = COUNT; if MHdx = 21 then an14_stm  = COUNT;
		end;
		if dx_year = 2015 then do; 
			if MHdx =  1 then an15_str = COUNT; if MHdx =  2 then an15_adhd = COUNT; if MHdx =  3 then an15_anx = COUNT; if MHdx = 16 then an15_chad = COUNT; 
			if MHdx =  5 then an15_dep = COUNT; if MHdx =  6 then an15_dev  = COUNT; if MHdx = 11 then an15_sex = COUNT; if MHdx =  8 then an15_phb  = COUNT; 
			if MHdx =  9 then an15_psy = COUNT; if MHdx = 10 then an15_ptsd = COUNT; if MHdx = 12 then an15_slp = COUNT; if MHdx = 13 then an15_som  = COUNT;
			if MHdx = 14 then an15_sub = COUNT; if MHdx = 15 then an15_sui  = COUNT; if MHdx = 24 then an15_oth = COUNT; if MHdx = 18 then an15_per  = COUNT;
			if MHdx = 17 then an15_con = COUNT; if MHdx = 21 then an15_stm  = COUNT;
		end;
		if dx_year = 2016 then do; 
			if MHdx =  1 then an16_str = COUNT; if MHdx =  2 then an16_adhd = COUNT; if MHdx =  3 then an16_anx = COUNT; if MHdx = 16 then an16_chad = COUNT; 
			if MHdx =  5 then an16_dep = COUNT; if MHdx =  6 then an16_dev  = COUNT; if MHdx = 11 then an16_sex = COUNT; if MHdx =  8 then an16_phb  = COUNT; 
			if MHdx =  9 then an16_psy = COUNT; if MHdx = 10 then an16_ptsd = COUNT; if MHdx = 12 then an16_slp = COUNT; if MHdx = 13 then an16_som  = COUNT;
			if MHdx = 14 then an16_sub = COUNT; if MHdx = 15 then an16_sui  = COUNT; if MHdx = 24 then an16_oth = COUNT; if MHdx = 18 then an16_per  = COUNT;
			if MHdx = 17 then an16_con = COUNT; if MHdx = 21 then an16_stm  = COUNT;
		end;
		if dx_year = 2017 then do; 
			if MHdx =  1 then an17_str = COUNT; if MHdx =  2 then an17_adhd = COUNT; if MHdx =  3 then an17_anx = COUNT; if MHdx = 16 then an17_chad = COUNT; 
			if MHdx =  5 then an17_dep = COUNT; if MHdx =  6 then an17_dev  = COUNT; if MHdx = 11 then an17_sex = COUNT; if MHdx =  8 then an17_phb  = COUNT; 
			if MHdx =  9 then an17_psy = COUNT; if MHdx = 10 then an17_ptsd = COUNT; if MHdx = 12 then an17_slp = COUNT; if MHdx = 13 then an17_som  = COUNT;
			if MHdx = 14 then an17_sub = COUNT; if MHdx = 15 then an17_sui  = COUNT; if MHdx = 24 then an17_oth = COUNT; if MHdx = 18 then an17_per  = COUNT;
			if MHdx = 17 then an17_con = COUNT; if MHdx = 21 then an17_stm  = COUNT;
		end;
		if dx_year = 2018 then do; 
			if MHdx =  1 then an18_str = COUNT; if MHdx =  2 then an18_adhd = COUNT; if MHdx =  3 then an18_anx = COUNT; if MHdx = 16 then an18_chad = COUNT; 
			if MHdx =  5 then an18_dep = COUNT; if MHdx =  6 then an18_dev  = COUNT; if MHdx = 11 then an18_sex = COUNT; if MHdx =  8 then an18_phb  = COUNT; 
			if MHdx =  9 then an18_psy = COUNT; if MHdx = 10 then an18_ptsd = COUNT; if MHdx = 12 then an18_slp = COUNT; if MHdx = 13 then an18_som  = COUNT;
			if MHdx = 14 then an18_sub = COUNT; if MHdx = 15 then an18_sui  = COUNT; if MHdx = 24 then an18_oth = COUNT; if MHdx = 18 then an18_per  = COUNT;
			if MHdx = 17 then an18_con = COUNT; if MHdx = 21 then an18_stm  = COUNT;
		end;
		if dx_year = 2019 then do; 
			if MHdx =  1 then an19_str = COUNT; if MHdx =  2 then an19_adhd = COUNT; if MHdx =  3 then an19_anx = COUNT; if MHdx = 16 then an19_chad = COUNT; 
			if MHdx =  5 then an19_dep = COUNT; if MHdx =  6 then an19_dev  = COUNT; if MHdx = 11 then an19_sex = COUNT; if MHdx =  8 then an19_phb  = COUNT; 
			if MHdx =  9 then an19_psy = COUNT; if MHdx = 10 then an19_ptsd = COUNT; if MHdx = 12 then an19_slp = COUNT; if MHdx = 13 then an19_som  = COUNT;
			if MHdx = 14 then an19_sub = COUNT; if MHdx = 15 then an19_sui  = COUNT; if MHdx = 24 then an19_oth = COUNT; if MHdx = 18 then an19_per  = COUNT;
			if MHdx = 17 then an19_con = COUNT; if MHdx = 21 then an19_stm  = COUNT;
		end;
		if dx_year = 2020 then do; 
			if MHdx =  1 then an20_str = COUNT; if MHdx =  2 then an20_adhd = COUNT; if MHdx =  3 then an20_anx = COUNT; if MHdx = 16 then an20_chad = COUNT; 
			if MHdx =  5 then an20_dep = COUNT; if MHdx =  6 then an20_dev  = COUNT; if MHdx = 11 then an20_sex = COUNT; if MHdx =  8 then an20_phb  = COUNT; 
			if MHdx =  9 then an20_psy = COUNT; if MHdx = 10 then an20_ptsd = COUNT; if MHdx = 12 then an20_slp = COUNT; if MHdx = 13 then an20_som  = COUNT;
			if MHdx = 14 then an20_sub = COUNT; if MHdx = 15 then an20_sui  = COUNT; if MHdx = 24 then an20_oth = COUNT; if MHdx = 18 then an20_per  = COUNT;
			if MHdx = 17 then an20_con = COUNT; if MHdx = 21 then an20_stm  = COUNT;
		end;
		if dx_year = 2021 then do; 
			if MHdx =  1 then an21_str = COUNT; if MHdx =  2 then an21_adhd = COUNT; if MHdx =  3 then an21_anx = COUNT; if MHdx = 16 then an21_chad = COUNT; 
			if MHdx =  5 then an21_dep = COUNT; if MHdx =  6 then an21_dev  = COUNT; if MHdx = 11 then an21_sex = COUNT; if MHdx =  8 then an21_phb  = COUNT; 
			if MHdx =  9 then an21_psy = COUNT; if MHdx = 10 then an21_ptsd = COUNT; if MHdx = 12 then an21_slp = COUNT; if MHdx = 13 then an21_som  = COUNT;
			if MHdx = 14 then an21_sub = COUNT; if MHdx = 15 then an21_sui  = COUNT; if MHdx = 24 then an21_oth = COUNT; if MHdx = 18 then an21_per  = COUNT;
			if MHdx = 17 then an21_con = COUNT; if MHdx = 21 then an21_stm  = COUNT;
		end;
		if dx_year = 2022 then do; 
			if MHdx =  1 then an22_str = COUNT; if MHdx =  2 then an22_adhd = COUNT; if MHdx =  3 then an22_anx = COUNT; if MHdx = 16 then an22_chad = COUNT; 
			if MHdx =  5 then an22_dep = COUNT; if MHdx =  6 then an22_dev  = COUNT; if MHdx = 11 then an22_sex = COUNT; if MHdx =  8 then an22_phb  = COUNT; 
			if MHdx =  9 then an22_psy = COUNT; if MHdx = 10 then an22_ptsd = COUNT; if MHdx = 12 then an22_slp = COUNT; if MHdx = 13 then an22_som  = COUNT;
			if MHdx = 14 then an22_sub = COUNT; if MHdx = 15 then an22_sui  = COUNT; if MHdx = 24 then an22_oth = COUNT; if MHdx = 18 then an22_per  = COUNT;
			if MHdx = 17 then an22_con = COUNT; if MHdx = 21 then an22_stm  = COUNT;
		end;
		if dx_year = 2023 then do; 
			if MHdx =  1 then an23_str = COUNT; if MHdx =  2 then an23_adhd = COUNT; if MHdx =  3 then an23_anx = COUNT; if MHdx = 16 then an23_chad = COUNT; 
			if MHdx =  5 then an23_dep = COUNT; if MHdx =  6 then an23_dev  = COUNT; if MHdx = 11 then an23_sex = COUNT; if MHdx =  8 then an23_phb  = COUNT; 
			if MHdx =  9 then an23_psy = COUNT; if MHdx = 10 then an23_ptsd = COUNT; if MHdx = 12 then an23_slp = COUNT; if MHdx = 13 then an23_som  = COUNT;
			if MHdx = 14 then an23_sub = COUNT; if MHdx = 15 then an23_sui  = COUNT; if MHdx = 24 then an23_oth = COUNT; if MHdx = 18 then an23_per  = COUNT;
			if MHdx = 17 then an23_con = COUNT; if MHdx = 21 then an23_stm  = COUNT;
		end;
		if dx_year = 2024 then do; 
			if MHdx =  1 then an24_str = COUNT; if MHdx =  2 then an24_adhd = COUNT; if MHdx =  3 then an24_anx = COUNT; if MHdx = 16 then an24_chad = COUNT; 
			if MHdx =  5 then an24_dep = COUNT; if MHdx =  6 then an24_dev  = COUNT; if MHdx = 11 then an24_sex = COUNT; if MHdx =  8 then an24_phb  = COUNT; 
			if MHdx =  9 then an24_psy = COUNT; if MHdx = 10 then an24_ptsd = COUNT; if MHdx = 12 then an24_slp = COUNT; if MHdx = 13 then an24_som  = COUNT;
			if MHdx = 14 then an24_sub = COUNT; if MHdx = 15 then an24_sui  = COUNT; if MHdx = 24 then an24_oth = COUNT; if MHdx = 18 then an24_per  = COUNT;
			if MHdx = 17 then an24_con = COUNT; if MHdx = 21 then an24_stm  = COUNT;
		end;
	end;

	if SUM(an06_str, an06_adhd, an06_anx, an06_chad, an06_dep, an06_dev, an06_sex, an06_phb, an06_psy, an06_ptsd, an06_som, an06_sub, an06_sui, an06_oth, an06_slp, an06_per, an06_con, an06_stm) > 0 then adx06 = 1;
	if SUM(an07_str, an07_adhd, an07_anx, an07_chad, an07_dep, an07_dev, an07_sex, an07_phb, an07_psy, an07_ptsd, an07_som, an07_sub, an07_sui, an07_oth, an07_slp, an07_per, an07_con, an07_stm) > 0 then adx07 = 1;
	if SUM(an08_str, an08_adhd, an08_anx, an08_chad, an08_dep, an08_dev, an08_sex, an08_phb, an08_psy, an08_ptsd, an08_som, an08_sub, an08_sui, an08_oth, an08_slp, an08_per, an08_con, an08_stm) > 0 then adx08 = 1;
	if SUM(an09_str, an09_adhd, an09_anx, an09_chad, an09_dep, an09_dev, an09_sex, an09_phb, an09_psy, an09_ptsd, an09_som, an09_sub, an09_sui, an09_oth, an09_slp, an09_per, an09_con, an09_stm) > 0 then adx09 = 1;
	if SUM(an10_str, an10_adhd, an10_anx, an10_chad, an10_dep, an10_dev, an10_sex, an10_phb, an10_psy, an10_ptsd, an10_som, an10_sub, an10_sui, an10_oth, an10_slp, an10_per, an10_con, an10_stm) > 0 then adx10 = 1;
	if SUM(an11_str, an11_adhd, an11_anx, an11_chad, an11_dep, an11_dev, an11_sex, an11_phb, an11_psy, an11_ptsd, an11_som, an11_sub, an11_sui, an11_oth, an11_slp, an11_per, an11_con, an11_stm) > 0 then adx11 = 1;
	if SUM(an12_str, an12_adhd, an12_anx, an12_chad, an12_dep, an12_dev, an12_sex, an12_phb, an12_psy, an12_ptsd, an12_som, an12_sub, an12_sui, an12_oth, an12_slp, an12_per, an12_con, an12_stm) > 0 then adx12 = 1;
	if SUM(an13_str, an13_adhd, an13_anx, an13_chad, an13_dep, an13_dev, an13_sex, an13_phb, an13_psy, an13_ptsd, an13_som, an13_sub, an13_sui, an13_oth, an13_slp, an13_per, an13_con, an13_stm) > 0 then adx13 = 1;
	if SUM(an14_str, an14_adhd, an14_anx, an14_chad, an14_dep, an14_dev, an14_sex, an14_phb, an14_psy, an14_ptsd, an14_som, an14_sub, an14_sui, an14_oth, an14_slp, an14_per, an14_con, an14_stm) > 0 then adx14 = 1;
	if SUM(an15_str, an15_adhd, an15_anx, an15_chad, an15_dep, an15_dev, an15_sex, an15_phb, an15_psy, an15_ptsd, an15_som, an15_sub, an15_sui, an15_oth, an15_slp, an15_per, an15_con, an15_stm) > 0 then adx15 = 1;
	if SUM(an16_str, an16_adhd, an16_anx, an16_chad, an16_dep, an16_dev, an16_sex, an16_phb, an16_psy, an16_ptsd, an16_som, an16_sub, an16_sui, an16_oth, an16_slp, an16_per, an16_con, an16_stm) > 0 then adx16 = 1;
	if SUM(an17_str, an17_adhd, an17_anx, an17_chad, an17_dep, an17_dev, an17_sex, an17_phb, an17_psy, an17_ptsd, an17_som, an17_sub, an17_sui, an17_oth, an17_slp, an17_per, an17_con, an17_stm) > 0 then adx17 = 1;
	if SUM(an18_str, an18_adhd, an18_anx, an18_chad, an18_dep, an18_dev, an18_sex, an18_phb, an18_psy, an18_ptsd, an18_som, an18_sub, an18_sui, an18_oth, an18_slp, an18_per, an18_con, an18_stm) > 0 then adx18 = 1;
	if SUM(an19_str, an19_adhd, an19_anx, an19_chad, an19_dep, an19_dev, an19_sex, an19_phb, an19_psy, an19_ptsd, an19_som, an19_sub, an19_sui, an19_oth, an19_slp, an19_per, an19_con, an19_stm) > 0 then adx19 = 1;
	if SUM(an20_str, an20_adhd, an20_anx, an20_chad, an20_dep, an20_dev, an20_sex, an20_phb, an20_psy, an20_ptsd, an20_som, an20_sub, an20_sui, an20_oth, an20_slp, an20_per, an20_con, an20_stm) > 0 then adx20 = 1;
	if SUM(an21_str, an21_adhd, an21_anx, an21_chad, an21_dep, an21_dev, an21_sex, an21_phb, an21_psy, an21_ptsd, an21_som, an21_sub, an21_sui, an21_oth, an21_slp, an21_per, an21_con, an21_stm) > 0 then adx21 = 1;
	if SUM(an22_str, an22_adhd, an22_anx, an22_chad, an22_dep, an22_dev, an22_sex, an22_phb, an22_psy, an22_ptsd, an22_som, an22_sub, an22_sui, an22_oth, an22_slp, an22_per, an22_con, an22_stm) > 0 then adx22 = 1;
	if SUM(an23_str, an23_adhd, an23_anx, an23_chad, an23_dep, an23_dev, an23_sex, an23_phb, an23_psy, an23_ptsd, an23_som, an23_sub, an23_sui, an23_oth, an23_slp, an23_per, an23_con, an23_stm) > 0 then adx23 = 1;
	if SUM(an24_str, an24_adhd, an24_anx, an24_chad, an24_dep, an24_dev, an24_sex, an24_phb, an24_psy, an24_ptsd, an24_som, an24_sub, an24_sui, an24_oth, an24_slp, an24_per, an24_con, an24_stm) > 0 then adx24 = 1;

	apersist      = SUM(adx06, adx07, adx08, adx09, adx10, adx11, adx12, adx13, adx14, adx15, adx16, adx17, adx18, adx19, adx20, adx21, adx22, adx23, adx24);
	apersist_str  = N(an06_str, an07_str, an08_str, an09_str, an10_str, an11_str, an12_str, an13_str, an14_str, an15_str, 
				 	  an16_str, an17_str, an18_str, an19_str, an20_str, an21_str, an22_str, an23_str, an24_str);
	apersist_adhd = N(an06_adhd, an07_adhd, an08_adhd, an09_adhd, an10_adhd, an11_adhd, an12_adhd, an13_adhd, an14_adhd, an15_adhd, 
				 	  an16_adhd, an17_adhd, an18_adhd, an19_adhd, an20_adhd, an21_adhd, an22_adhd, an23_adhd, an24_adhd);
	apersist_anx  = N(an06_anx, an07_anx, an08_anx, an09_anx, an10_anx, an11_anx, an12_anx, an13_anx, an14_anx, an15_anx, 
					  an16_anx, an17_anx, an18_anx, an19_anx, an20_anx, an21_anx, an22_anx, an23_anx, an24_anx);
	apersist_chad = N(an06_chad, an07_chad, an08_chad, an09_chad, an10_chad, an11_chad, an12_chad, an13_chad, an14_chad, an15_chad, 
				 	  an16_chad, an17_chad, an18_chad, an19_chad, an20_chad, an21_chad, an22_chad, an23_chad, an24_chad);
	apersist_dep  = N(an06_dep, an07_dep, an08_dep, an09_dep, an10_dep, an11_dep, an12_dep, an13_dep, an14_dep, an15_dep, 
					  an16_dep, an17_dep, an18_dep, an19_dep, an20_dep, an21_dep, an22_dep, an23_dep, an24_dep);
	apersist_dev  = N(an06_dev, an07_dev, an08_dev, an09_dev, an10_dev, an11_dev, an12_dev, an13_dev, an14_dev, an15_dev, 
					  an16_dev, an17_dev, an18_dev, an19_dev, an20_dev, an21_dev, an22_dev, an23_dev, an24_dev);
	apersist_sex  = N(an06_sex, an07_sex, an08_sex, an09_sex, an10_sex, an11_sex, an12_sex, an13_sex, an14_sex, an15_sex, 
					  an16_sex, an17_sex, an18_sex, an19_sex, an20_sex, an21_sex, an22_sex, an23_sex, an24_sex);
	apersist_phb  = N(an06_phb, an07_phb, an08_phb, an09_phb, an10_phb, an11_phb, an12_phb, an13_phb, an14_phb, an15_phb, 
					  an16_phb, an17_phb, an18_phb, an19_phb, an20_phb, an21_phb, an22_phb, an23_phb, an24_phb);
	apersist_psy  = N(an06_psy, an07_psy, an08_psy, an09_psy, an10_psy, an11_psy, an12_psy, an13_psy, an14_psy, an15_psy, 
					  an16_psy, an17_psy, an18_psy, an19_psy, an20_psy, an21_psy, an22_psy, an23_psy, an24_psy);
	apersist_ptsd = N(an06_ptsd, an07_ptsd, an08_ptsd, an09_ptsd, an10_ptsd, an11_ptsd, an12_ptsd, an13_ptsd, an14_ptsd, an15_ptsd, 
					  an16_ptsd, an17_ptsd, an18_ptsd, an19_ptsd, an20_ptsd, an21_ptsd, an22_ptsd, an23_ptsd, an24_ptsd);
	apersist_som  = N(an06_som, an07_som, an08_som, an09_som, an10_som, an11_som, an12_som, an13_som, an14_som, an15_som, 
					  an16_som, an17_som, an18_som, an19_som, an20_som, an21_som, an22_som, an23_som, an24_som);
	apersist_slp  = N(an06_slp, an07_slp, an08_slp, an09_slp, an10_slp, an11_slp, an12_slp, an13_slp, an14_slp, an15_slp, 
				      an16_slp, an17_slp, an18_slp, an19_slp, an20_slp, an21_slp, an22_slp, an23_slp, an24_slp);
	apersist_sub  = N(an06_sub, an07_sub, an08_sub, an09_sub, an10_sub, an11_sub, an12_sub, an13_sub, an14_sub, an15_sub, 
				 	  an16_sub, an17_sub, an18_sub, an19_sub, an20_sub, an21_sub, an22_sub, an23_sub, an24_sub);
	apersist_slp  = N(an06_slp, an07_slp, an08_slp, an09_slp, an10_slp, an11_slp, an12_slp, an13_slp, an14_slp, an15_slp, 
					  an16_slp, an17_slp, an18_slp, an19_slp, an20_slp, an21_slp, an22_slp, an23_slp, an24_slp);
	apersist_per  = N(an06_per, an07_per, an08_per, an09_per, an10_per, an11_per, an12_per, an13_per, an14_per, an15_per, 
					  an16_per, an17_per, an18_per, an19_per, an20_per, an21_per, an22_per, an23_per, an24_per);
	apersist_con  = N(an06_con, an07_con, an08_con, an09_con, an10_con, an11_con, an12_con, an13_con, an14_con, an15_con, 
					  an16_con, an17_con, an18_con, an19_con, an20_con, an21_con, an22_con, an23_con, an24_con);
	apersist_stm  = N(an06_stm, an07_stm, an08_stm, an09_stm, an10_stm, an11_stm, an12_stm, an13_stm, an14_stm, an15_stm, 
					  an16_stm, an17_stm, an18_stm, an19_stm, an20_stm, an21_stm, an22_stm, an23_stm, an24_stm);
	apersist_sui  = N(an06_sui, an07_sui, an08_sui, an09_sui, an10_sui, an11_sui, an12_sui, an13_sui, an14_sui, an15_sui, 
					  an16_sui, an17_sui, an18_sui, an19_sui, an20_sui, an21_sui, an22_sui, an23_sui, an24_sui);
	apersist_oth  = N(an06_oth, an07_oth, an08_oth, an09_oth, an10_oth, an11_oth, an12_oth, an13_oth, an14_oth, an15_oth, 
					  an16_oth, an17_oth, an18_oth, an19_oth, an20_oth, an21_oth, an22_oth, an23_oth, an24_oth);

	keep w19_1011_lnr_k2_ 
		 an06_str an06_adhd an06_anx an06_chad an06_dep an06_dev an06_sex an06_phb an06_psy an06_ptsd an06_slp an06_som an06_sub an06_sui an06_oth
		 an07_str an07_adhd an07_anx an07_chad an07_dep an07_dev an07_sex an07_phb an07_psy an07_ptsd an07_slp an07_som an07_sub an07_sui an07_oth
		 an08_str an08_adhd an08_anx an08_chad an08_dep an08_dev an08_sex an08_phb an08_psy an08_ptsd an08_slp an08_som an08_sub an08_sui an08_oth
		 an09_str an09_adhd an09_anx an09_chad an09_dep an09_dev an09_sex an09_phb an09_psy an09_ptsd an09_slp an09_som an09_sub an09_sui an09_oth
		 an10_str an10_adhd an10_anx an10_chad an10_dep an10_dev an10_sex an10_phb an10_psy an10_ptsd an10_slp an10_som an10_sub an10_sui an10_oth
		 an11_str an11_adhd an11_anx an11_chad an11_dep an11_dev an11_sex an11_phb an11_psy an11_ptsd an11_slp an11_som an11_sub an11_sui an11_oth
		 an12_str an12_adhd an12_anx an12_chad an12_dep an12_dev an12_sex an12_phb an12_psy an12_ptsd an12_slp an12_som an12_sub an12_sui an12_oth
		 an13_str an13_adhd an13_anx an13_chad an13_dep an13_dev an13_sex an13_phb an13_psy an13_ptsd an13_slp an13_som an13_sub an13_sui an13_oth
		 an14_str an14_adhd an14_anx an14_chad an14_dep an14_dev an14_sex an14_phb an14_psy an14_ptsd an14_slp an14_som an14_sub an14_sui an14_oth
		 an15_str an15_adhd an15_anx an15_chad an15_dep an15_dev an15_sex an15_phb an15_psy an15_ptsd an15_slp an15_som an15_sub an15_sui an15_oth
		 an16_str an16_adhd an16_anx an16_chad an16_dep an16_dev an16_sex an16_phb an16_psy an16_ptsd an16_slp an16_som an16_sub an16_sui an16_oth
		 an17_str an17_adhd an17_anx an17_chad an17_dep an17_dev an17_sex an17_phb an17_psy an17_ptsd an17_slp an17_som an17_sub an17_sui an17_oth
		 an18_str an18_adhd an18_anx an18_chad an18_dep an18_dev an18_sex an18_phb an18_psy an18_ptsd an18_slp an18_som an18_sub an18_sui an18_oth
		 an19_str an19_adhd an19_anx an19_chad an19_dep an19_dev an19_sex an19_phb an19_psy an19_ptsd an19_slp an19_som an19_sub an19_sui an19_oth
		 an20_str an20_adhd an20_anx an20_chad an20_dep an20_dev an20_sex an20_phb an20_psy an20_ptsd an20_slp an20_som an20_sub an20_sui an20_oth
		 an21_str an21_adhd an21_anx an21_chad an21_dep an21_dev an21_sex an21_phb an21_psy an21_ptsd an21_slp an21_som an21_sub an21_sui an21_oth
		 an22_str an22_adhd an22_anx an22_chad an22_dep an22_dev an22_sex an22_phb an22_psy an22_ptsd an22_slp an22_som an22_sub an22_sui an22_oth
		 an23_str an23_adhd an23_anx an23_chad an23_dep an23_dev an23_sex an23_phb an23_psy an23_ptsd an23_slp an23_som an23_sub an23_sui an23_oth
		 an24_str an24_adhd an24_anx an24_chad an24_dep an24_dev an24_sex an24_phb an24_psy an24_ptsd an24_slp an24_som an24_sub an24_sui an24_oth
		 adx06 adx07 adx08 adx09 adx10 adx11 adx12 adx13 adx14 adx15 adx16 adx17 adx18 adx19 adx20 adx21 adx22 adx23 adx24
		 apersist 
		 apersist_str apersist_adhd apersist_anx apersist_chad apersist_dep apersist_dev apersist_sex apersist_phb apersist_psy apersist_ptsd
		 apersist_slp apersist_som apersist_sub apersist_sui apersist_oth apersist_per apersist_con apersist_stm;
run;

proc sort data = medrec_wide_c; by w19_1011_lnr_k2_; run;
data OPV;
	merge medrec_wide_c (in = b) PV minmaxdxyr;
	by w19_1011_lnr_k2_;

	if b; 

	* Fill in needed zeros for persistence variables;
	array a [19] apersist 
		 		 apersist_str apersist_adhd apersist_anx apersist_chad apersist_dep apersist_dev apersist_sex apersist_phb apersist_psy apersist_ptsd
		 		 apersist_slp apersist_som  apersist_sub apersist_sui  apersist_oth apersist_per apersist_con apersit_stm;

	do i = 1 to 19;
		if var_MH ne . and a[i]  = . then a[i] = 0;
	end;
	drop i;

	cohort_a = cohort - 2000;

	if cohort < 2001 then delete;
run;

proc freq data = OPV;
	table cohort;
run;

proc freq data = OPV;
	table cohort*mindxyr*maxdxyr / list missing;
run;

* Which single dx's to plot;
proc freq data = OPV;
	table any_sub any_ADHD any_chad 
		   any_dep any_str any_anx any_phb any_ptsd any_som 
		   any_psy 
		   any_oth any_slp any_sex any_per any_sui any_con any_dev any_stm;
run;

proc freq data = OPV;
	table cohort*(any_MH apersist var_MH fst_MH any_dep any_anx any_adhd any_chad);
run;

proc means data = OPV n mean min p10 Q1 median Q3 p90 max clm;
	class cohort;
	var   any_MH apersist var_MH fst_MH any_dep any_anx any_adhd any_chad;
run;


proc means data = OPV n mean min p10 Q1 median Q3 p90 max clm;
	var   any_MH apersist var_MH fst_MH any_dep any_anx any_adhd any_chad;
run;

proc glm data = OPV;
	class cohort;
	model any_MH apersist var_MH fst_MH any_dep any_anx any_adhd any_chad = cohort / ss3 solution;
	lsmeans cohort / pdiff;
run;
quit;

proc glm data = OPV;
	model any_MH apersist var_MH fst_MH any_dep any_anx any_adhd any_chad = cohort_a / ss3 solution;
run;
quit;

proc corr data = OPV;
	var any_MH fst_MH apersist var_MH;
run;

* Do infections also increase by cohort;
data infection;
	set rawdat.MedRec_phcodes_26Sept2025;

	if age_dx >= 5 and age_dx <= 15;

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

	if codetype = "inf";

	drop FAGOMRAADE_KODE KONTAKTTYPE /*doctor contact14 good_code*/;
run;

data infection;
	set infection;

	if codetype = "inf";

	any_inf = 1;
run;
proc sort data = infection out = infection1 nodupkey; by w19_1011_lnr_k2_; run;

data infection1;
	merge demog (in = indem) infection1 (keep = w19_1011_lnr_k2_ any_inf);
	by w19_1011_lnr_k2_;

	if indem;

	if any_inf = . then any_inf = 0;

	if cohort < 2001 then delete;
run;

proc freq data = infection1;
	table cohort*any_inf;
run;

proc means data = infection1 n mean min p10 Q1 median Q3 p90 max clm;
	var any_inf;
run;
proc means data = infection1 n mean min p10 Q1 median Q3 p90 max clm;
	class cohort;
	var any_inf;
run;

proc glm data = infection1;
	class cohort;
	model any_inf = cohort / ss3 solution;
	lsmeans cohort / pdiff;
run;
quit;

* Do injuries also increase by cohort;
data injuries;
	set rawdat.MedRec_phcodes_26Sept2025;

	if age_dx >= 5 and age_dx <= 15;

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

	if codetype = "inj";

	any_inj = 1;

	drop FAGOMRAADE_KODE KONTAKTTYPE /*doctor contact14 good_code*/;
run;

proc sort data = injuries out = injuries1 nodupkey; by w19_1011_lnr_k2_; run;

data injuries1;
	merge demog (in = indem) injuries1 (keep = w19_1011_lnr_k2_ any_inj);
	by w19_1011_lnr_k2_;

	if indem;

	if any_inj = . then any_inj = 0;

	cohort_a = cohort - 2001;

	if cohort < 2001 then delete;
run;

proc freq data = injuries1;
	table any_inj;
	table cohort*any_inj;
run;

proc means data = injuries1 n mean min p10 Q1 median Q3 p90 max clm;
	var any_inj;
run;
proc means data = injuries1 n mean min p10 Q1 median Q3 p90 max clm;
	class cohort;
	var any_inj;
run;


proc glm data = injuries1;
	class cohort;
	model any_inj = cohort / ss3 solution;
	lsmeans cohort / pdiff;
run;
quit;

proc glm data = injuries1;
	model any_inj = cohort_a / ss3 solution;
run;
quit;
