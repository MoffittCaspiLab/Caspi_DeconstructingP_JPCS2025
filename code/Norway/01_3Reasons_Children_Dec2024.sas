DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Parent_Child\01_3Reasons_Children_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: 3 Reasons -- Intergenerational Transmission 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Parent_Child\01_3Reasons_Children_Dec2024.sas;
* Modification Hx:	10-Oct-2024 Select children aged 0-5 in Jan 2006 and their parents
*					20-Nov-2024 Change inclusion criteria to age [5-20) in Jan 2019
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
	set rawdat.MedRec_23Feb2024;

	if age_end >= 5 and age_end < 20;

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

	age_start_fl = FLOOR(age_start);

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
	merge rawdat.Demog_23Feb2024;
	by w19_1011_lnr_k2_;

	if age_end >= 5 and age_end < 20;

	if sex = 1 then male = 1;
		else if sex = 2 then male = 0;
run;

* Create wide file with indicator variables for ever having dx;
proc sort data = medrec1 out = uniqdx nodupkey; by w19_1011_lnr_k2_ MHdx; run;

data medrec_wide;
	array dx [24]	any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
					any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth;

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

data medrec_wide_c;
	merge demog (in = indem) medrec_wide;
	by w19_1011_lnr_k2_;

	if indem;

	array dx [24]	any_str any_adhd any_anx any_dem  any_dep any_dev any_eat any_phb any_psy any_ptsd any_sex any_slp 
		 			any_som any_sub  any_sui any_chad any_con any_per any_crf any_pha any_stm any_fmh  any_irr any_oth;

	do i = 1 to 24;
		if dx[i] = . then dx[i] = 0;
	end;

	* Any MH using only codes we're using;
	if SUM(any_sub, any_ADHD, any_chad, 
		   any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, 
		   any_psy, 
		   any_oth, any_slp, any_sex, any_per, any_sui, any_con, any_dev, any_stm) > 0 then any_MH = 1;
		else any_MH = 0;

	drop i;
run;

* Save file with mother and father IDs of children in sample;
data thr_par.Parents_Dec2024;
	set demog;

	keep w19_1011_lnr_k2_ mor_lnr_k2_ far_lnr_k2_;
run;

data thr_par.Child_wide_Dec2024;
	set medrec_wide_c;
run;

data thr_par.Child_long_Dec2024;
	set medrec1;
run;


/*
* Find number of encounters per child;
data included;
	set thr_par.included;
run;

proc sort data = included; by w19_1011_lnr_k2_; run;

data all;
	merge medrec1 included (in = kept);
	by w19_1011_lnr_k2_;

	if kept;
	if dato ne .;
	if MHdx in (1, 2, 3, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 21, 24);
run;

proc freq data = all;
	table w19_1011_lnr_k2_;
	ods output OneWayFreqs = dxcount;
run;

proc contents data = dxcount; run;

proc means data = dxcount;
	var Frequency;
run;

data dxcount1;
	merge dxcount included;
	by w19_1011_lnr_k2_;

	if Frequency = . then Frequency = 0;
run;

proc means data = dxcount1;
	var Frequency;
run;
*/
