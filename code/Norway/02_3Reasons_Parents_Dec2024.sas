DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Parent_Child\01_3Reasons_Parents_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: Three Reasons - Parent-Child 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Parent_Child\01_3Reasons_Parents_Dec2024.sas;
* Modification Hx:	17-May-2024 Borrow from Cumulative Incidence syntax to pull parents' 
*								marital status, household composition, MH dx's
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

* Pull in needed parent ID numbers;
data parents;
	set thr_par.Parents_Dec2024;
run;

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
	*	"B" = Norwegian born to imigrant parents
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

* Find mother demographics;
proc sort data = parents; by mor_lnr_k2_; run;
data mom_demo;
	merge parents (in = inpar rename = (mor_lnr_k2_ = mom_id))
		  demo1 (rename = (w19_1011_lnr_k2_ = mom_id));
	by mom_id;

	m_death_yr  = death_yr;
	m_age_start = age_start;
	m_age_death = age_death;
	m_age_end   = age_end;
	m_DOB       = DOB;
	m_DOD       = DOD;
	m_nor_born  = nor_born;
	m_res_grp   = res_grp;
	m_dead2006  = dead2006;
	m_insample  = insample;
	m_outsamp   = outsamp;
	m_invkat    = invkat;

	if inpar;

	format m_DOB m_DOD MMYYD.;

	drop mor_lnr_k2_ far_lnr_k2_ death_yr age_start age_death age_end DOB DOD sex nor_born res_grp dead2006 insample outsamp invkat;
run;

* Find father demographics;
proc sort data = parents; by far_lnr_k2_; run;
data dad_demo;
	merge parents (in = inpar rename = (far_lnr_k2_ = dad_id))
		  demo1 (rename = (w19_1011_lnr_k2_ = dad_id));
	by dad_id;

	d_death_yr  = death_yr;
	d_age_start = age_start;
	d_age_death = age_death;
	d_age_end   = age_end;
	d_DOB       = DOB;
	d_DOD       = DOD;
	d_nor_born  = nor_born;
	d_res_grp   = res_grp;
	d_dead2006  = dead2006;
	d_insample  = insample;
	d_outsamp   = outsamp;
	d_invkat    = invkat;

	if inpar;

	format d_DOB d_DOD MMYYD.;

	drop mor_lnr_k2_ far_lnr_k2_ death_yr age_start age_death age_end DOB DOD sex nor_born res_grp dead2006 insample outsamp invkat;
run;

* Combine child/mother/father demographic info;
proc sort data = demo1;    by w19_1011_lnr_k2_; run;
proc sort data = mom_demo; by w19_1011_lnr_k2_; run;
proc sort data = dad_demo; by w19_1011_lnr_k2_; run;
data family_demo;
	merge demo1 mom_demo dad_demo (in = indad);
	by w19_1011_lnr_k2_;

	if indad;
run;

data thr_par.family_demo_Dec2024;
	set family_demo;
run;

* Get parents' MH data;
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

* Get mother's MH dx's;
proc sort data = parents out = momid nodupkey; by mor_lnr_k2_; run;
data mom_kuhr;
	merge momid (in = inpar rename = (mor_lnr_k2_ = mom_id))
		  kuhr (rename = (w19_1011_lnr_k2_ = mom_id));
	by mom_id;

	m_DATO         = DATO;
	m_is_diag      = is_diag;
	m_codetype     = codetype;
	m_diag_chapter = diag_chapter;
	m_DIAG         = DIAG;

	if inpar;

	format m_DATO YYMMDD10.;

	drop DATO is_diag codetype diag_chapter DIAG;
run;

* Get father's MH dx's;
proc sort data = parents out = dadid nodupkey; by far_lnr_k2_; run;
data dad_kuhr;
	merge dadid (in = inpar rename = (far_lnr_k2_ = dad_id))
		  kuhr (rename = (w19_1011_lnr_k2_ = dad_id));
	by dad_id;

	d_DATO         = DATO;
	d_is_diag      = is_diag;
	d_codetype     = codetype;
	d_diag_chapter = diag_chapter;
	d_DIAG         = DIAG;

	if inpar;

	format d_DATO YYMMDD10.;

	drop DATO is_diag codetype diag_chapter DIAG;
run;

* Get mother's MH dx's;
* Code diagnoses into categories we're using;
proc sort data = family_demo; by mom_id; run;
proc sort data = mom_kuhr; by mom_id m_DATO; run;
data mom_kuhr1;
	merge	mom_kuhr (in = inmedr)
			family_demo (keep = mom_id m_DOB m_age_start);
	by mom_id;		

	if inmedr;

	if m_DOB ne . and m_DATO ne . then m_age_dx =  YRDIF(m_DOB, m_DATO, 'AGE');

	m_age_floor    = FLOOR(m_age_start);
	m_age_dx_floor = FLOOR(m_age_dx);

	m_age_start_mo = INTCK('MONTH', m_DOB, MDY(01,01,2006), 'D');
	m_age_dx_mo    = INTCK('MONTH', m_DOB, m_DATO, 'D');

	* Code mental health into diagnoses;
	if m_DIAG in ("P02")                                      then m_MHdx = 1;
		else if m_DIAG in ("P81")                             then m_MHdx = 2;
		else if m_DIAG in ("P01", "P74")                      then m_MHdx = 3;
		else if m_DIAG in ("P05", "P20", "P70")               then m_MHdx = 4;
		else if m_DIAG in ("P03", "P76")                      then m_MHdx = 5;		
		else if m_DIAG in ("P24", "P28", "P85")               then m_MHdx = 6;
		else if m_DIAG in ("P11", "P86")                      then m_MHdx = 7;
		else if m_DIAG in ("P79")                      		  then m_MHdx = 8;
		else if m_DIAG in ("P71", "P72", "P73", "P98")		  then m_MHdx = 9;
		else if m_DIAG in ("P82")							  then m_MHdx = 10;		
		else if m_DIAG in ("P07", "P08", "P09")				  then m_MHdx = 11;
		else if m_DIAG in ("P06")							  then m_MHdx = 12;
		else if m_DIAG in ("P75")							  then m_MHdx = 13;
		else if m_DIAG in ("P15", "P16", "P17", "P18", "P19") then m_MHdx = 14;
		else if m_DIAG in ("P77")							  then m_MHdx = 15;
		else if m_DIAG in ("P22", "P23")                      then m_MHdx = 16;
		else if m_DIAG in ("P12", "P13")                      then m_MHdx = 17;
		else if m_DIAG in ("P80")                             then m_MHdx = 18;
		else if m_DIAG in ("P78")                             then m_MHdx = 19;
		else if m_DIAG in ("P25")                             then m_MHdx = 20;
		else if m_DIAG in ("P10")                             then m_MHdx = 21;
		else if m_DIAG in ("P27")                             then m_MHdx = 22;
		else if m_DIAG in ("P04")                             then m_MHdx = 23;
		else if m_DIAG in ("P29", "P99")                      then m_MHdx = 24;

	if m_MHdx ne . then m_anyMH = 1;
		else m_anyMH = 0;

	* Keep only codes we're using;
	if m_anyMH = 1;

	*drop m_anyMH;

	format m_MHdx MHDX.;
run;

* Get father's MH dx's;
* Code diagnoses into categories we're using;
proc sort data = family_demo; by dad_id; run;
proc sort data = dad_kuhr; by dad_id d_DATO; run;
data dad_kuhr1;
	merge	dad_kuhr (in = inmedr)
			family_demo (keep = dad_id d_DOB d_age_start);
	by dad_id;		

	if inmedr;

	if d_DOB ne . and d_DATO ne . then d_age_dx =  YRDIF(d_DOB, d_DATO, 'AGE');

	d_age_floor    = FLOOR(d_age_start);
	d_age_dx_floor = FLOOR(d_age_dx);

	d_age_start_mo = INTCK('MONTH', d_DOB, MDY(01,01,2006), 'D');
	d_age_dx_mo    = INTCK('MONTH', d_DOB, d_DATO, 'D');

	* Code mental health into diagnoses;
	if d_DIAG in ("P02")                                      then d_MHdx = 1;
		else if d_DIAG in ("P81")                             then d_MHdx = 2;
		else if d_DIAG in ("P01", "P74")                      then d_MHdx = 3;
		else if d_DIAG in ("P05", "P20", "P70")               then d_MHdx = 4;
		else if d_DIAG in ("P03", "P76")                      then d_MHdx = 5;		
		else if d_DIAG in ("P24", "P28", "P85")               then d_MHdx = 6;
		else if d_DIAG in ("P11", "P86")                      then d_MHdx = 7;
		else if d_DIAG in ("P79")                      		  then d_MHdx = 8;
		else if d_DIAG in ("P71", "P72", "P73", "P98")		  then d_MHdx = 9;
		else if d_DIAG in ("P82")							  then d_MHdx = 10;		
		else if d_DIAG in ("P07", "P08", "P09")				  then d_MHdx = 11;
		else if d_DIAG in ("P06")							  then d_MHdx = 12;
		else if d_DIAG in ("P75")							  then d_MHdx = 13;
		else if d_DIAG in ("P15", "P16", "P17", "P18", "P19") then d_MHdx = 14;
		else if d_DIAG in ("P77")							  then d_MHdx = 15;
		else if d_DIAG in ("P22", "P23")                      then d_MHdx = 16;
		else if d_DIAG in ("P12", "P13")                      then d_MHdx = 17;
		else if d_DIAG in ("P80")                             then d_MHdx = 18;
		else if d_DIAG in ("P78")                             then d_MHdx = 19;
		else if d_DIAG in ("P25")                             then d_MHdx = 20;
		else if d_DIAG in ("P10")                             then d_MHdx = 21;
		else if d_DIAG in ("P27")                             then d_MHdx = 22;
		else if d_DIAG in ("P04")                             then d_MHdx = 23;
		else if d_DIAG in ("P29", "P99")                      then d_MHdx = 24;

	if d_MHdx ne . then d_anyMH = 1;
		else d_anyMH = 0;

	* Keep only codes we're using;
	if d_anyMH = 1;

	*drop d_anyMH;

	format d_MHdx MHDX.;
run;

proc sort data = mom_kuhr1 out = m_uniqdx nodupkey; by mom_id m_MHdx; run;
data m_mhdx_wide;
	array dx [24]	m_any_str m_any_adhd m_any_anx m_any_dem  m_any_dep m_any_dev m_any_eat m_any_phb m_any_psy m_any_ptsd m_any_sex m_any_slp 
					m_any_som m_any_sub  m_any_sui m_any_chad m_any_con m_any_per m_any_crf m_any_pha m_any_stm m_any_fmh  m_any_irr m_any_oth;

	do i = 1 to 25 until (last.mom_id);
		set m_uniqdx;
		by mom_id;
	
		if m_MHdx =  1 then m_any_str  = 1;
		if m_MHdx =  2 then m_any_adhd = 1;
		if m_MHdx =  3 then m_any_anx  = 1;
		if m_MHdx =  4 then m_any_dem  = 1;
		if m_MHdx =  5 then m_any_dep  = 1;
		if m_MHdx =  6 then m_any_dev  = 1;
		if m_MHdx =  7 then m_any_eat  = 1;
		if m_MHdx =  8 then m_any_phb  = 1;
		if m_MHdx =  9 then m_any_psy  = 1;
		if m_MHdx = 10 then m_any_ptsd = 1;
		if m_MHdx = 11 then m_any_sex  = 1;
		if m_MHdx = 12 then m_any_slp  = 1;
		if m_MHdx = 13 then m_any_som  = 1;
		if m_MHdx = 14 then m_any_sub  = 1;
		if m_MHdx = 15 then m_any_sui  = 1;
		if m_MHdx = 16 then m_any_chad = 1;
		if m_MHdx = 17 then m_any_con  = 1;
		if m_MHdx = 18 then m_any_per  = 1;
		if m_MHdx = 19 then m_any_crf  = 1;
		if m_MHdx = 20 then m_any_pha  = 1;
		if m_MHdx = 21 then m_any_stm  = 1;
		if m_MHdx = 22 then m_any_fmh  = 1;
		if m_MHdx = 23 then m_any_irr  = 1;
		if m_MHdx = 24 then m_any_oth  = 1;
	end;

	keep mom_id
		 m_any_str m_any_adhd m_any_anx m_any_dem  m_any_dep m_any_dev m_any_eat m_any_phb m_any_psy m_any_ptsd m_any_sex m_any_slp 
		 m_any_som m_any_sub  m_any_sui m_any_chad m_any_con m_any_per m_any_crf m_any_pha m_any_stm m_any_fmh  m_any_irr m_any_oth;
run;

proc sort data = dad_kuhr1 out = d_uniqdx nodupkey; by dad_id d_MHdx; run;
data d_mhdx_wide;
	array dx [24]	d_any_str d_any_adhd d_any_anx d_any_dem  d_any_dep d_any_dev d_any_eat d_any_phb d_any_psy d_any_ptsd d_any_sex d_any_slp 
					d_any_som d_any_sub  d_any_sui d_any_chad d_any_con d_any_per d_any_crf d_any_pha d_any_stm d_any_fmh  d_any_irr d_any_oth;

	do i = 1 to 25 until (last.dad_id);
		set d_uniqdx;
		by dad_id;
	
		if d_MHdx =  1 then d_any_str  = 1;
		if d_MHdx =  2 then d_any_adhd = 1;
		if d_MHdx =  3 then d_any_anx  = 1;
		if d_MHdx =  4 then d_any_dem  = 1;
		if d_MHdx =  5 then d_any_dep  = 1;
		if d_MHdx =  6 then d_any_dev  = 1;
		if d_MHdx =  7 then d_any_eat  = 1;
		if d_MHdx =  8 then d_any_phb  = 1;
		if d_MHdx =  9 then d_any_psy  = 1;
		if d_MHdx = 10 then d_any_ptsd = 1;
		if d_MHdx = 11 then d_any_sex  = 1;
		if d_MHdx = 12 then d_any_slp  = 1;
		if d_MHdx = 13 then d_any_som  = 1;
		if d_MHdx = 14 then d_any_sub  = 1;
		if d_MHdx = 15 then d_any_sui  = 1;
		if d_MHdx = 16 then d_any_chad = 1;
		if d_MHdx = 17 then d_any_con  = 1;
		if d_MHdx = 18 then d_any_per  = 1;
		if d_MHdx = 19 then d_any_crf  = 1;
		if d_MHdx = 20 then d_any_pha  = 1;
		if d_MHdx = 21 then d_any_stm  = 1;
		if d_MHdx = 22 then d_any_fmh  = 1;
		if d_MHdx = 23 then d_any_irr  = 1;
		if d_MHdx = 24 then d_any_oth  = 1;
	end;

	keep dad_id
		 d_any_str d_any_adhd d_any_anx d_any_dem  d_any_dep d_any_dev d_any_eat d_any_phb d_any_psy d_any_ptsd d_any_sex d_any_slp 
		 d_any_som d_any_sub  d_any_sui d_any_chad d_any_con d_any_per d_any_crf d_any_pha d_any_stm d_any_fmh  d_any_irr d_any_oth;
run;

* Combine child/mother/father demographic info;
proc sort data = family_demo; by mom_id w19_1011_lnr_k2_; run;
proc sort data = m_mhdx_wide; by mom_id; run;

data family_demo_momMH;
	merge family_demo (in = infam)
		  m_mhdx_wide;
	by mom_id;
run;

proc sort data = family_demo_momMH; by dad_id w19_1011_lnr_k2_; run;
proc sort data = d_mhdx_wide; by dad_id; run;

data family_demo_momMH_dadMH;
	merge family_demo_momMH (in = infam)
		  d_mhdx_wide;
	by dad_id;
run;

proc sort data = family_demo_momMH_dadMH; by w19_1011_lnr_k2_; run;

data family_demo_momMH_dadMH1;
	set family_demo_momMH_dadMH;

	array m_dx [24]	m_any_str m_any_adhd m_any_anx m_any_dem  m_any_dep m_any_dev m_any_eat m_any_phb m_any_psy m_any_ptsd m_any_sex m_any_slp 
		 			m_any_som m_any_sub  m_any_sui m_any_chad m_any_con m_any_per m_any_crf m_any_pha m_any_stm m_any_fmh  m_any_irr m_any_oth;
	array d_dx [24]	d_any_str d_any_adhd d_any_anx d_any_dem  d_any_dep d_any_dev d_any_eat d_any_phb d_any_psy d_any_ptsd d_any_sex d_any_slp 
		 			d_any_som d_any_sub  d_any_sui d_any_chad d_any_con d_any_per d_any_crf d_any_pha d_any_stm d_any_fmh  d_any_irr d_any_oth;
	array e_dx [24]	e_any_str e_any_adhd e_any_anx e_any_dem  e_any_dep e_any_dev e_any_eat e_any_phb e_any_psy e_any_ptsd e_any_sex e_any_slp 
		 			e_any_som e_any_sub  e_any_sui e_any_chad e_any_con e_any_per e_any_crf e_any_pha e_any_stm e_any_fmh  e_any_irr e_any_oth;					
		 
	do i = 1 to 24;
		if m_dx[i] = .  then m_dx[i] = 0;
		if mom_id  = '' then m_dx[i] = .;
		if m_outsamp in (3,4,5) then m_dx[i] = .;

		if d_dx[i] = . then d_dx[i] = 0;
		if dad_id = '' then d_dx[i] = .;
		if d_outsamp in (3,4,5) then d_dx[i] = .;
	end;

	if SUM(m_any_str, m_any_adhd, m_any_anx, m_any_dep, m_any_phb, m_any_psy, m_any_ptsd, m_any_sex, m_any_slp, 
		   m_any_som, m_any_sub,  m_any_sui, m_any_per, m_any_oth) > 0 then m_any_MH = 1;
		else if mom_id ne '' then m_any_MH = 0;
	if m_outsamp in (3,4,5) then m_any_MH = .;

	if SUM(d_any_str, d_any_adhd, d_any_anx, d_any_dep, d_any_phb, d_any_psy, d_any_ptsd, d_any_sex, d_any_slp, 
		   d_any_som, d_any_sub,  d_any_sui, d_any_per, d_any_oth) > 0 then d_any_MH = 1;
		else if dad_id ne '' then d_any_MH = 0;
	if d_outsamp in (3,4,5) then d_any_MH = .;

	do i = 1 to 24;
		if m_dx[i] = 1 OR d_dx[i] = 1 then e_dx[i] = 1;
			else if m_dx[i] = 0 OR d_dx[i] = 0 then e_dx[i] = 0;

		if mom_id = '' AND dad_id = '' then e_dx[i] = .;
		if m_outsamp in (3,4,5) AND d_outsamp in (3,4,5) then e_dx[i] = .;
	end;

	if m_any_MH = 1 OR d_any_MH = 1 then e_any_MH = 1;
		else if m_any_MH = 0 OR d_any_MH = 0 then e_any_MH = 0;

	if mom_id = '' OR m_outsamp in (3,4,5) then no_mom = 1; else no_mom = 0;
	if dad_id = '' OR d_outsamp in (3,4,5) then no_dad = 1; else no_dad = 0;

	drop i;
run;

proc freq data = family_demo_momMH_dadMH1;
	table no_mom no_dad no_mom*no_dad;
	table no_mom*m_outsamp no_dad*d_outsamp / list missing;
	table m_any_MH d_any_MH e_any_MH e_any_MH*m_any_MH*d_any_MH / list missing;
run;

data thr_par.family_demo_parMH_Dec2024;
	set family_demo_momMH_dadMH1;
run;



/*
* Find # of encounters for moms;
data included;
	set thr_par.included;
run;

proc sort data = included; by mom_id; run;

data all;
	merge mom_kuhr1 included (in = kept);
	by mom_id;

	if kept;

	if m_dato ne .;
run;

proc freq data = all;
	table mom_id;
	ods output OneWayFreqs = dxcount;
run;

proc contents data = dxcount; run;

proc means data = dxcount;
	var Frequency;
run;

data dxcount1;
	merge dxcount included;
	by mom_id;

	if mom_id ne "";

	if Frequency = . then Frequency = 0;
run;

proc means data = dxcount1;
	var Frequency;
run;


* Find # of encounters for dads;
data included;
	set thr_par.included;
run;

proc sort data = included; by dad_id; run;

data all;
	merge dad_kuhr1 included (in = kept);
	by dad_id;

	if kept;

	if d_dato ne .;
run;

proc freq data = all;
	table dad_id;
	ods output OneWayFreqs = dxcount;
run;

proc contents data = dxcount; run;

proc means data = dxcount;
	var Frequency;
run;

data dxcount1;
	merge dxcount included;
	by dad_id;

	if dad_id ne "";

	if Frequency = . then Frequency = 0;
run;

proc means data = dxcount1;
	var Frequency;
run;
*/
