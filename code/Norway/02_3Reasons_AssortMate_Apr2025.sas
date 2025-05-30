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

* Anyone aged 20-50 in 2006;
proc means data = assortmate_all;
	var age_start n_partner dx_variety;
proc means data = assortmate_all;
	class male;
	var age_start n_partner dx_variety;
run;

proc freq data = assortmate_all;
	table have_partner male*have_partner;
run;

* Person-level prevalence of dx's;
ods output OneWayFreqs = MHdx;
proc freq data = assortmate_all; 
	table any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui;
run;
ods output close;

data MHdx_MFfocal_all; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "focal_mf_all"; code = "Any Mental Health Disorder"; 	end;
		else if code = "any_sub"  then do; who = "focal_mf_all"; code = "Substance abuse";            	end;
		else if code = "any_adhd" then do; who = "focal_mf_all"; code = "ADHD";					 		end;
		else if code = "any_dep"  then do; who = "focal_mf_all"; code = "Depression";					end;
		else if code = "any_str"  then do; who = "focal_mf_all"; code = "Acute stress reaction";       	end;
		else if code = "any_anx"  then do; who = "focal_mf_all"; code = "Anxiety disorder";				end;
		else if code = "any_phb"  then do; who = "focal_mf_all"; code = "Phobia/Compulsive disorder";	end;
		else if code = "any_ptsd" then do; who = "focal_mf_all"; code = "PTSD";							end;
		else if code = "any_som"  then do; who = "focal_mf_all"; code = "Somatization";					end;
		else if code = "any_psy"  then do; who = "focal_mf_all"; code = "Psychosis";					end;
		else if code = "any_oth"  then do; who = "focal_mf_all"; code = "Psychological disorders, NOS";	end;
		else if code = "any_slp"  then do; who = "focal_mf_all"; code = "Sleep disturbance";			end;
		else if code = "any_sex"  then do; who = "focal_mf_all"; code = "Sexual concern";				end;
		else if code = "any_per"  then do; who = "focal_mf_all"; code = "Personality disorder";			end;
		else if code = "any_sui"  then do; who = "focal_mf_all"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

ods output OneWayFreqs = MHdx;
proc freq data = assortmate_all; 
	table any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui ;
	where male = 0;
run;
ods output close;

data MHdx_Ffocal_all; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "focal_f_all"; code = "Any Mental Health Disorder"; 	end;
		else if code = "any_sub"  then do; who = "focal_f_all"; code = "Substance abuse";            	end;
		else if code = "any_adhd" then do; who = "focal_f_all"; code = "ADHD";					 		end;
		else if code = "any_dep"  then do; who = "focal_f_all"; code = "Depression";					end;
		else if code = "any_str"  then do; who = "focal_f_all"; code = "Acute stress reaction";       	end;
		else if code = "any_anx"  then do; who = "focal_f_all"; code = "Anxiety disorder";				end;
		else if code = "any_phb"  then do; who = "focal_f_all"; code = "Phobia/Compulsive disorder";	end;
		else if code = "any_ptsd" then do; who = "focal_f_all"; code = "PTSD";							end;
		else if code = "any_som"  then do; who = "focal_f_all"; code = "Somatization";					end;
		else if code = "any_psy"  then do; who = "focal_f_all"; code = "Psychosis";						end;
		else if code = "any_oth"  then do; who = "focal_f_all"; code = "Psychological disorders, NOS";	end;
		else if code = "any_slp"  then do; who = "focal_f_all"; code = "Sleep disturbance";				end;
		else if code = "any_sex"  then do; who = "focal_f_all"; code = "Sexual concern";				end;
		else if code = "any_per"  then do; who = "focal_f_all"; code = "Personality disorder";			end;
		else if code = "any_sui"  then do; who = "focal_f_all"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

ods output OneWayFreqs = MHdx;
proc freq data = assortmate_all; 
	table any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui;
	where male = 1;
run;
ods output close;

data MHdx_Mfocal_all; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "focal_m_all"; code = "Any Mental Health Disorder"; 	end;
		else if code = "any_sub"  then do; who = "focal_m_all"; code = "Substance abuse";            	end;
		else if code = "any_adhd" then do; who = "focal_m_all"; code = "ADHD";					 		end;
		else if code = "any_dep"  then do; who = "focal_m_all"; code = "Depression";					end;
		else if code = "any_str"  then do; who = "focal_m_all"; code = "Acute stress reaction";       	end;
		else if code = "any_anx"  then do; who = "focal_m_all"; code = "Anxiety disorder";				end;
		else if code = "any_phb"  then do; who = "focal_m_all"; code = "Phobia/Compulsive disorder";	end;
		else if code = "any_ptsd" then do; who = "focal_m_all"; code = "PTSD";							end;
		else if code = "any_som"  then do; who = "focal_m_all"; code = "Somatization";					end;
		else if code = "any_psy"  then do; who = "focal_m_all"; code = "Psychosis";						end;
		else if code = "any_oth"  then do; who = "focal_m_all"; code = "Psychological disorders, NOS";	end;
		else if code = "any_slp"  then do; who = "focal_m_all"; code = "Sleep disturbance";				end;
		else if code = "any_sex"  then do; who = "focal_m_all"; code = "Sexual concern";				end;
		else if code = "any_per"  then do; who = "focal_m_all"; code = "Personality disorder";			end;
		else if code = "any_sui"  then do; who = "focal_m_all"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

* Bring down to those with primary partners;
data assortmate;
	set assortmate_all;

	if have_partner = 1;
run;

proc freq data = assortmate;
	table dead0619 male DOB;
run;

proc means data = assortmate;
	var age_start n_partner dx_variety;
proc means data = assortmate;
	class male;
	var age_start n_partner dx_variety;
run;

* Person-level prevalence of dx's;
ods output OneWayFreqs = MHdx;
proc freq data = assortmate; 
	table any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui;
run;
ods output close;

data MHdx_MFfocal; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "focal_mf_all"; code = "Any Mental Health Disorder"; 	end;
		else if code = "any_sub"  then do; who = "focal_mf_all"; code = "Substance abuse";            	end;
		else if code = "any_adhd" then do; who = "focal_mf_all"; code = "ADHD";					 		end;
		else if code = "any_dep"  then do; who = "focal_mf_all"; code = "Depression";					end;
		else if code = "any_str"  then do; who = "focal_mf_all"; code = "Acute stress reaction";       	end;
		else if code = "any_anx"  then do; who = "focal_mf_all"; code = "Anxiety disorder";				end;
		else if code = "any_phb"  then do; who = "focal_mf_all"; code = "Phobia/Compulsive disorder";	end;
		else if code = "any_ptsd" then do; who = "focal_mf_all"; code = "PTSD";							end;
		else if code = "any_som"  then do; who = "focal_mf_all"; code = "Somatization";					end;
		else if code = "any_psy"  then do; who = "focal_mf_all"; code = "Psychosis";					end;
		else if code = "any_oth"  then do; who = "focal_mf_all"; code = "Psychological disorders, NOS";	end;
		else if code = "any_slp"  then do; who = "focal_mf_all"; code = "Sleep disturbance";			end;
		else if code = "any_sex"  then do; who = "focal_mf_all"; code = "Sexual concern";				end;
		else if code = "any_per"  then do; who = "focal_mf_all"; code = "Personality disorder";			end;
		else if code = "any_sui"  then do; who = "focal_mf_all"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

ods output OneWayFreqs = MHdx;
proc sort data = assortmate nodupkey; by primary_id; run;
proc freq data = assortmate; 
	table any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui;
	where male = 0;
run;
ods output close;

data MHdx_Ffocal; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "focal_f"; code = "Any Mental Health Disorder"; 	end;
		else if code = "any_sub"  then do; who = "focal_f"; code = "Substance abuse";            	end;
		else if code = "any_adhd" then do; who = "focal_f"; code = "ADHD";					 		end;
		else if code = "any_dep"  then do; who = "focal_f"; code = "Depression";					end;
		else if code = "any_str"  then do; who = "focal_f"; code = "Acute stress reaction";       	end;
		else if code = "any_anx"  then do; who = "focal_f"; code = "Anxiety disorder";				end;
		else if code = "any_phb"  then do; who = "focal_f"; code = "Phobia/Compulsive disorder";	end;
		else if code = "any_ptsd" then do; who = "focal_f"; code = "PTSD";							end;
		else if code = "any_som"  then do; who = "focal_f"; code = "Somatization";					end;
		else if code = "any_psy"  then do; who = "focal_f"; code = "Psychosis";						end;
		else if code = "any_oth"  then do; who = "focal_f"; code = "Psychological disorders, NOS";	end;
		else if code = "any_slp"  then do; who = "focal_f"; code = "Sleep disturbance";				end;
		else if code = "any_sex"  then do; who = "focal_f"; code = "Sexual concern";				end;
		else if code = "any_per"  then do; who = "focal_f"; code = "Personality disorder";			end;
		else if code = "any_sui"  then do; who = "focal_f"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

ods output OneWayFreqs = MHdx;
proc freq data = assortmate; 
	table any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  any_oth any_slp any_sex any_per any_sui;
	where male = 1;
run;
ods output close;

data MHdx_Mfocal; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "any_MH"   then do; who = "focal_m"; code = "Any Mental Health Disorder"; 	end;
		else if code = "any_sub"  then do; who = "focal_m"; code = "Substance abuse";            	end;
		else if code = "any_adhd" then do; who = "focal_m"; code = "ADHD";					 		end;
		else if code = "any_dep"  then do; who = "focal_m"; code = "Depression";					end;
		else if code = "any_str"  then do; who = "focal_m"; code = "Acute stress reaction";       	end;
		else if code = "any_anx"  then do; who = "focal_m"; code = "Anxiety disorder";				end;
		else if code = "any_phb"  then do; who = "focal_m"; code = "Phobia/Compulsive disorder";	end;
		else if code = "any_ptsd" then do; who = "focal_m"; code = "PTSD";							end;
		else if code = "any_som"  then do; who = "focal_m"; code = "Somatization";					end;
		else if code = "any_psy"  then do; who = "focal_m"; code = "Psychosis";						end;
		else if code = "any_oth"  then do; who = "focal_m"; code = "Psychological disorders, NOS";	end;
		else if code = "any_slp"  then do; who = "focal_m"; code = "Sleep disturbance";				end;
		else if code = "any_sex"  then do; who = "focal_m"; code = "Sexual concern";				end;
		else if code = "any_per"  then do; who = "focal_m"; code = "Personality disorder";			end;
		else if code = "any_sui"  then do; who = "focal_m"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

* Primary partners;
proc sort data = assortmate out = prime nodupkey; by primary_id; run;
proc means data = prime;
	var pp_age_start p_n_partner pp_dx_variety;
proc means data = prime;
	class pp_male;
	var pp_age_start p_n_partner pp_dx_variety;
run;

* Person-level prevalence of dx's;
ods output OneWayFreqs = MHdx;
proc freq data = prime; 
	table pp_any_MH  pp_any_sub pp_any_adhd pp_any_dep pp_any_str pp_any_anx pp_any_phb pp_any_ptsd pp_any_som pp_any_psy
		  pp_any_oth pp_any_slp pp_any_sex pp_any_per pp_any_sui;
run;
ods output close;

data MHdx_MFprime; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "pp_any_MH"   then do; who = "primary_mf_all"; code = "Any Mental Health Disorder"; 	 end;
		else if code = "pp_any_sub"  then do; who = "primary_mf_all"; code = "Substance abuse";            	 end;
		else if code = "pp_any_adhd" then do; who = "primary_mf_all"; code = "ADHD";					 	 end;
		else if code = "pp_any_dep"  then do; who = "primary_mf_all"; code = "Depression";					 end;
		else if code = "pp_any_str"  then do; who = "primary_mf_all"; code = "Acute stress reaction";        end;
		else if code = "pp_any_anx"  then do; who = "primary_mf_all"; code = "Anxiety disorder";			 end;
		else if code = "pp_any_phb"  then do; who = "primary_mf_all"; code = "Phobia/Compulsive disorder";	 end;
		else if code = "pp_any_ptsd" then do; who = "primary_mf_all"; code = "PTSD";						 end;
		else if code = "pp_any_som"  then do; who = "primary_mf_all"; code = "Somatization";				 end;
		else if code = "pp_any_psy"  then do; who = "primary_mf_all"; code = "Psychosis";					 end;
		else if code = "pp_any_oth"  then do; who = "primary_mf_all"; code = "Psychological disorders, NOS"; end;
		else if code = "pp_any_slp"  then do; who = "primary_mf_all"; code = "Sleep disturbance";			 end;
		else if code = "pp_any_sex"  then do; who = "primary_mf_all"; code = "Sexual concern";				 end;
		else if code = "pp_any_per"  then do; who = "primary_mf_all"; code = "Personality disorder";		 end;
		else if code = "pp_any_sui"  then do; who = "primary_mf_all"; code = "Suicide/Suicide attempt";		 end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

ods output OneWayFreqs = MHdx;
proc sort data = prime nodupkey; by primary_id; run;
proc freq data = prime; 
	table pp_any_MH  pp_any_sub pp_any_adhd pp_any_dep pp_any_str pp_any_anx pp_any_phb pp_any_ptsd pp_any_som pp_any_psy
		  pp_any_oth pp_any_slp pp_any_sex pp_any_per pp_any_sui;
	where pp_male = 0;
run;
ods output close;

data MHdx_Fprime; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "pp_any_MH"   then do; who = "primary_f"; code = "Any Mental Health Disorder"; 	end;
		else if code = "pp_any_sub"  then do; who = "primary_f"; code = "Substance abuse";            	end;
		else if code = "pp_any_adhd" then do; who = "primary_f"; code = "ADHD";					 		end;
		else if code = "pp_any_dep"  then do; who = "primary_f"; code = "Depression";					end;
		else if code = "pp_any_str"  then do; who = "primary_f"; code = "Acute stress reaction";       	end;
		else if code = "pp_any_anx"  then do; who = "primary_f"; code = "Anxiety disorder";				end;
		else if code = "pp_any_phb"  then do; who = "primary_f"; code = "Phobia/Compulsive disorder";	end;
		else if code = "pp_any_ptsd" then do; who = "primary_f"; code = "PTSD";							end;
		else if code = "pp_any_som"  then do; who = "primary_f"; code = "Somatization";					end;
		else if code = "pp_any_psy"  then do; who = "primary_f"; code = "Psychosis";					end;
		else if code = "pp_any_oth"  then do; who = "primary_f"; code = "Psychological disorders, NOS";	end;
		else if code = "pp_any_slp"  then do; who = "primary_f"; code = "Sleep disturbance";			end;
		else if code = "pp_any_sex"  then do; who = "primary_f"; code = "Sexual concern";				end;
		else if code = "pp_any_per"  then do; who = "primary_f"; code = "Personality disorder";			end;
		else if code = "pp_any_sui"  then do; who = "primary_f"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

ods output OneWayFreqs = MHdx;
proc freq data = prime; 
	table pp_any_MH  pp_any_sub pp_any_adhd pp_any_dep pp_any_str pp_any_anx pp_any_phb pp_any_ptsd pp_any_som pp_any_psy
		  pp_any_oth pp_any_slp pp_any_sex pp_any_per pp_any_sui;
	where pp_male = 1;
run;
ods output close;

data MHdx_Mprime; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "pp_any_MH"   then do; who = "primary_m"; code = "Any Mental Health Disorder"; 	end;
		else if code = "pp_any_sub"  then do; who = "primary_m"; code = "Substance abuse";            	end;
		else if code = "pp_any_adhd" then do; who = "primary_m"; code = "ADHD";					 		end;
		else if code = "pp_any_dep"  then do; who = "primary_m"; code = "Depression";					end;
		else if code = "pp_any_str"  then do; who = "primary_m"; code = "Acute stress reaction";       	end;
		else if code = "pp_any_anx"  then do; who = "primary_m"; code = "Anxiety disorder";				end;
		else if code = "pp_any_phb"  then do; who = "primary_m"; code = "Phobia/Compulsive disorder";	end;
		else if code = "pp_any_ptsd" then do; who = "primary_m"; code = "PTSD";							end;
		else if code = "pp_any_som"  then do; who = "primary_m"; code = "Somatization";					end;
		else if code = "pp_any_psy"  then do; who = "primary_m"; code = "Psychosis";					end;
		else if code = "pp_any_oth"  then do; who = "primary_m"; code = "Psychological disorders, NOS";	end;
		else if code = "pp_any_slp"  then do; who = "primary_m"; code = "Sleep disturbance";			end;
		else if code = "pp_any_sex"  then do; who = "primary_m"; code = "Sexual concern";				end;
		else if code = "pp_any_per"  then do; who = "primary_m"; code = "Personality disorder";			end;
		else if code = "pp_any_sui"  then do; who = "primary_m"; code = "Suicide/Suicide attempt";		end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
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

proc sort data = assortmate2 out = female nodupkey; by female_id; run;
proc means data = female;
	var f_age_start f_n_partner f_dx_variety;
run;

ods output OneWayFreqs = MHdx;
proc freq data = female; 
	table f_any_MH  f_any_sub f_any_adhd f_any_dep f_any_str f_any_anx f_any_phb f_any_ptsd f_any_som f_any_psy
		  f_any_oth f_any_slp f_any_sex f_any_per f_any_sui;
run;
ods output close;

data MHdx_Fpartner; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "f_any_MH"   then do; who = "partnered_f"; code = "Any Mental Health Disorder"; 	 end;
		else if code = "f_any_sub"  then do; who = "partnered_f"; code = "Substance abuse";            	 end;
		else if code = "f_any_adhd" then do; who = "partnered_f"; code = "ADHD";					 	 end;
		else if code = "f_any_dep"  then do; who = "partnered_f"; code = "Depression";					 end;
		else if code = "f_any_str"  then do; who = "partnered_f"; code = "Acute stress reaction";        end;
		else if code = "f_any_anx"  then do; who = "partnered_f"; code = "Anxiety disorder";			 end;
		else if code = "f_any_phb"  then do; who = "partnered_f"; code = "Phobia/Compulsive disorder";	 end;
		else if code = "f_any_ptsd" then do; who = "partnered_f"; code = "PTSD";						 end;
		else if code = "f_any_som"  then do; who = "partnered_f"; code = "Somatization";				 end;
		else if code = "f_any_psy"  then do; who = "partnered_f"; code = "Psychosis";					 end;
		else if code = "f_any_oth"  then do; who = "partnered_f"; code = "Psychological disorders, NOS"; end;
		else if code = "f_any_slp"  then do; who = "partnered_f"; code = "Sleep disturbance";			 end;
		else if code = "f_any_sex"  then do; who = "partnered_f"; code = "Sexual concern";				 end;
		else if code = "f_any_per"  then do; who = "partnered_f"; code = "Personality disorder";		 end;
		else if code = "f_any_sui"  then do; who = "partnered_f"; code = "Suicide/Suicide attempt";		 end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

proc sort data = assortmate2 out = male nodupkey; by male_id; run;
proc means data = male;
	var m_age_start m_n_partner m_dx_variety;
run;

ods output OneWayFreqs = MHdx;
proc freq data = male; 
	table m_any_MH  m_any_sub m_any_adhd m_any_dep m_any_str m_any_anx m_any_phb m_any_ptsd m_any_som m_any_psy
		  m_any_oth m_any_slp m_any_sex m_any_per m_any_sui;
run;
ods output close;

data MHdx_Mpartner; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "m_any_MH"   then do; who = "partnered_m"; code = "Any Mental Health Disorder"; 	 end;
		else if code = "m_any_sub"  then do; who = "partnered_m"; code = "Substance abuse";            	 end;
		else if code = "m_any_adhd" then do; who = "partnered_m"; code = "ADHD";					 	 end;
		else if code = "m_any_dep"  then do; who = "partnered_m"; code = "Depression";					 end;
		else if code = "m_any_str"  then do; who = "partnered_m"; code = "Acute stress reaction";        end;
		else if code = "m_any_anx"  then do; who = "partnered_m"; code = "Anxiety disorder";			 end;
		else if code = "m_any_phb"  then do; who = "partnered_m"; code = "Phobia/Compulsive disorder";	 end;
		else if code = "m_any_ptsd" then do; who = "partnered_m"; code = "PTSD";						 end;
		else if code = "m_any_som"  then do; who = "partnered_m"; code = "Somatization";				 end;
		else if code = "m_any_psy"  then do; who = "partnered_m"; code = "Psychosis";					 end;
		else if code = "m_any_oth"  then do; who = "partnered_m"; code = "Psychological disorders, NOS"; end;
		else if code = "m_any_slp"  then do; who = "partnered_m"; code = "Sleep disturbance";			 end;
		else if code = "m_any_sex"  then do; who = "partnered_m"; code = "Sexual concern";				 end;
		else if code = "m_any_per"  then do; who = "partnered_m"; code = "Personality disorder";		 end;
		else if code = "m_any_sui"  then do; who = "partnered_m"; code = "Suicide/Suicide attempt";		 end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

data MHdx_MF;
	set MHdx_MFfocal_all MHdx_Ffocal_all MHdx_Mfocal_all 
		MHdx_MFfocal     MHdx_Ffocal     MHdx_Mfocal 
		MHdx_MFprime     MHdx_Fprime     MHdx_Mprime
						 MHdx_Fpartner   MHdx_Mpartner;
run;

proc export data = MHdx_MF
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\AssortativeMating_Prevalence_05May2024.csv"
	dbms = csv
	replace;
run;

* Comorbidity -- cross M/F;
%macro getORS (MH = , pMH = );
	proc freq data = assortmate; 
		table any_&MH*any_&pMH / RELRISK;
		ods output RelativeRisks = &pMH._OR; 
	run;
	data OR; 
		set OR &pMH._OR;
	run;
%mend getORs;

%macro OR_risk(MH = );

	proc freq data = assortmate; 
		table any_&MH*any_MH / RELRISK; 
		ods output RelativeRisks = &MH._OR; 
	run;
	data OR; set &MH._OR; run;
	
	%getORS(MH = &MH, pMH = sub);
	%getORS(MH = &MH, pMH = adhd);
	
	%getORS(MH = &MH, pMH = dep);
	%getORS(MH = &MH, pMH = str);
	%getORS(MH = &MH, pMH = anx);
	%getORS(MH = &MH, pMH = phb);
	%getORS(MH = &MH, pMH = ptsd);
	%getORS(MH = &MH, pMH = som);
		
	%getORS(MH = &MH, pMH = psy);
	
	%getORS(MH = &MH, pMH = oth);
	%getORS(MH = &MH, pMH = slp);
	%getORS(MH = &MH, pMH = sex);
	%getORS(MH = &MH, pMH = per);
	%getORS(MH = &MH, pMH = sui);
	
	data OR_&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Combined;
%OR_risk(MH = sub);
%OR_risk(MH = adhd);
%OR_risk(MH = dep);
%OR_risk(MH = str);
%OR_risk(MH = anx);
%OR_risk(MH = phb);
%OR_risk(MH = ptsd);
%OR_risk(MH = som);
%OR_risk(MH = psy);
%OR_risk(MH = oth);
%OR_risk(MH = slp);
%OR_risk(MH = sex);
%OR_risk(MH = per);
%OR_risk(MH = sui);

data OR_all_comorbid;
	set OR_sub OR_adhd 
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;

proc datasets;
	delete	OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_crf OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_dem OR_per OR_sui;
run;
quit;

proc export data = OR_all_comorbid
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\ORs_Comorbid_09Dec2024.csv"
	dbms = csv
	replace;
run;

* Comorbidity LogOR's;
%macro getLogORS (MH = , pMH = );
	proc logistic data = assortmate; 
		model any_&MH (event = '1') = any_&pMH;
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;
%mend getLogORs;

%macro LogOR_risk(MH = );

	proc logistic data = assortmate; 
		model any_&MH (event = '1') = any_adhd; 
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; set &MH._OR; run;
	
	%getLogORS(MH = &MH, pMH = sub);
	
	%getLogORS(MH = &MH, pMH = dep);
	%getLogORS(MH = &MH, pMH = str);
	%getLogORS(MH = &MH, pMH = anx);
	%getLogORS(MH = &MH, pMH = phb);
	%getLogORS(MH = &MH, pMH = ptsd);
	%getLogORS(MH = &MH, pMH = som);
		
	%getLogORS(MH = &MH, pMH = psy);
	
	%getLogORS(MH = &MH, pMH = oth);
	%getLogORS(MH = &MH, pMH = slp);
	%getLogORS(MH = &MH, pMH = sex);
	%getLogORS(MH = &MH, pMH = per);
	%getLogORS(MH = &MH, pMH = sui);
	
	data OR_&MH; 
		set OR; 
		Outcome = "any_&MH";
		if Variable NE "Intercept"; 
	run;

%mend LogOR_risk;

* Comorbidity;
%LogOR_risk(MH = sub);
%LogOR_risk(MH = adhd);
%LogOR_risk(MH = dep);
%LogOR_risk(MH = str);
%LogOR_risk(MH = anx);
%LogOR_risk(MH = phb);
%LogOR_risk(MH = ptsd);
%LogOR_risk(MH = som);
%LogOR_risk(MH = psy);
%LogOR_risk(MH = oth);
%LogOR_risk(MH = slp);
%LogOR_risk(MH = sex);
%LogOR_risk(MH = per);
%LogOR_risk(MH = sui);

data OR_all_pp;
	set OR_adhd OR_sub  
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;
run;

proc datasets;
	delete	OR 
			OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui

 		   	MH_OR  
			adhd_OR sub_OR 
			str_OR  anx_OR dep_OR phb_OR som_OR ptsd_OR
			psy_OR 
			sex_OR  slp_OR sui_OR per_OR oth_OR;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\LogORs_Comorbid_14Apr2025.csv"
	dbms = csv
	replace;
run;


* ODDS RATIOS -- COMBINED M/F;

* Male vs Female ORs;
%macro getORS (MH = , pMH = );
	proc freq data = assortmate2; 
		table m_any_&MH*f_any_&pMH / RELRISK;
		ods output RelativeRisks = pp&MH._OR; 
	run;
	data OR; 
		set OR pp&MH._OR;
	run;
%mend getORs;

%macro OR_risk(MH = );

	proc freq data = assortmate2; 
		table m_any_&MH*f_any_MH / RELRISK; 
		ods output RelativeRisks = pp&MH._OR; 
	run;
	data OR; set pp&MH._OR; run;
	
	%getORS(MH = &MH, pMH = sub);
	%getORS(MH = &MH, pMH = adhd);
	
	%getORS(MH = &MH, pMH = dep);
	%getORS(MH = &MH, pMH = str);
	%getORS(MH = &MH, pMH = anx);
	%getORS(MH = &MH, pMH = phb);
	%getORS(MH = &MH, pMH = ptsd);
	%getORS(MH = &MH, pMH = som);
		
	%getORS(MH = &MH, pMH = psy);
	
	%getORS(MH = &MH, pMH = oth);
	%getORS(MH = &MH, pMH = slp);
	%getORS(MH = &MH, pMH = sex);
	%getORS(MH = &MH, pMH = per);
	%getORS(MH = &MH, pMH = sui);
	
	data OR_&MH; 
		set OR; 
		*if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Primary partners (MF combined);
%OR_risk(MH = MH);
%OR_risk(MH = sub);
%OR_risk(MH = adhd);
%OR_risk(MH = dep);
%OR_risk(MH = str);
%OR_risk(MH = anx);
%OR_risk(MH = phb);
%OR_risk(MH = ptsd);
%OR_risk(MH = som);
%OR_risk(MH = psy);
%OR_risk(MH = oth);
%OR_risk(MH = slp);
%OR_risk(MH = sex);
%OR_risk(MH = per);
%OR_risk(MH = sui);

data OR_all_pp;
	set OR_MH  
		OR_sub OR_adhd 
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;

proc datasets;
	delete	OR OR_MH  
			OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui

 		   	MH_OR  
			adhd_OR sub_OR 
			str_OR  anx_OR dep_OR phb_OR som_OR ptsd_OR
			psy_OR 
			sex_OR  slp_OR sui_OR per_OR oth_OR;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\ORs_PrimaryPartner_09Dec2024.csv"
	dbms = csv
	replace;
run;

* LogOR's for Male vs Female;
%macro getLogORS (MH = , pMH = );
	proc logistic data = assortmate2; 
		model m_any_&MH (event = '1') = f_any_&pMH;
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;
%mend getLogORs;

%macro LogOR_risk(MH = );

	proc logistic data = assortmate2; 
		model m_any_&MH (event = '1') = f_any_adhd; 
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; set &MH._OR; run;
	
	%getLogORS(MH = &MH, pMH = sub);
	%getLogORS(MH = &MH, pMH = MH);
	
	%getLogORS(MH = &MH, pMH = dep);
	%getLogORS(MH = &MH, pMH = str);
	%getLogORS(MH = &MH, pMH = anx);
	%getLogORS(MH = &MH, pMH = phb);
	%getLogORS(MH = &MH, pMH = ptsd);
	%getLogORS(MH = &MH, pMH = som);
		
	%getLogORS(MH = &MH, pMH = psy);
	
	%getLogORS(MH = &MH, pMH = oth);
	%getLogORS(MH = &MH, pMH = slp);
	%getLogORS(MH = &MH, pMH = sex);
	%getLogORS(MH = &MH, pMH = per);
	%getLogORS(MH = &MH, pMH = sui);
	
	data OR_&MH; 
		set OR; 
		Outcome = "any_&MH";
		if Variable NE "Intercept"; 
	run;

%mend LogOR_risk;

* Primary partners (MF combined focal);
%LogOR_risk(MH = MH);
%LogOR_risk(MH = sub);
%LogOR_risk(MH = adhd);
%LogOR_risk(MH = dep);
%LogOR_risk(MH = str);
%LogOR_risk(MH = anx);
%LogOR_risk(MH = phb);
%LogOR_risk(MH = ptsd);
%LogOR_risk(MH = som);
%LogOR_risk(MH = psy);
%LogOR_risk(MH = oth);
%LogOR_risk(MH = slp);
%LogOR_risk(MH = sex);
%LogOR_risk(MH = per);
%LogOR_risk(MH = sui);

data OR_all_pp;
	set OR_adhd OR_MH  
		OR_sub  
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;
run;

proc datasets;
	delete	OR OR_MH  
			OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui

 		   	MH_OR  
			adhd_OR sub_OR 
			str_OR  anx_OR dep_OR phb_OR som_OR ptsd_OR
			psy_OR 
			sex_OR  slp_OR sui_OR per_OR oth_OR;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\LogORs_PrimaryPartner_09Dec2024.csv"
	dbms = csv
	replace;
run;

* No Female Comorbidity ORs (combined M/F);
%macro getORS (MH = , pMH = );
	proc freq data = assortmate2; 
		table m_any_&MH*f_any_&pMH / RELRISK; 
		where f_any_&MH = 0; 
		ods output RelativeRisks = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;

	proc datasets; delete &MH._OR; run; quit;
%mend getORs;

%macro OR_risk(MH = );

	proc freq data = assortmate2; 
		table m_any_&MH*f_any_sub / RELRISK; 
		where f_any_&MH = 0; 
		ods output RelativeRisks = sub_OR; run;
	data OR; 
		set sub_OR;
	run;
	proc datasets; delete sub_OR; run; quit;
		
	%getORS(MH = &MH, pMH = adhd);

	%getORS(MH = &MH, pMH = dep);
	%getORS(MH = &MH, pMH = str);
	%getORS(MH = &MH, pMH = anx);
	%getORS(MH = &MH, pMH = phb);
	%getORS(MH = &MH, pMH = ptsd);
	%getORS(MH = &MH, pMH = som);
	
	%getORS(MH = &MH, pMH = psy);

	%getORS(MH = &MH, pMH = oth);
	%getORS(MH = &MH, pMH = slp);
	%getORS(MH = &MH, pMH = sex);
	%getORS(MH = &MH, pMH = per);	
	%getORS(MH = &MH, pMH = sui);	

	data OR_&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Primary partners (Combined M/F);
%OR_risk(MH = sub);
%OR_risk(MH = adhd);
%OR_risk(MH = dep);
%OR_risk(MH = str);
%OR_risk(MH = anx);
%OR_risk(MH = phb);
%OR_risk(MH = ptsd);
%OR_risk(MH = som);
%OR_risk(MH = psy);
%OR_risk(MH = oth);
%OR_risk(MH = slp);
%OR_risk(MH = sex);
%OR_risk(MH = per);
%OR_risk(MH = sui);

data OR_all_pp;
	set OR_adhd OR_sub  
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete	OR 
		  	OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoFemaleComORs_09Dec2024.csv"
	dbms = csv
	replace;
run;


%macro getLogORS (MH = , pMH = );
	proc logistic data = assortmate2; 
		model m_any_&MH (event = '1') = f_any_&pMH;
		where f_any_&MH = 0;
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;
%mend getLogORs;

%macro LogOR_risk(MH = );

	proc logistic data = assortmate2; 
		model m_any_&MH (event = '1') = f_any_adhd; 
		where f_any_&MH = 0; 
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; set &MH._OR; run;

	%getLogORS(MH = &MH, pMH = sub);
	
	%getLogORS(MH = &MH, pMH = dep);
	%getLogORS(MH = &MH, pMH = str);
	%getLogORS(MH = &MH, pMH = anx);
	%getLogORS(MH = &MH, pMH = phb);
	%getLogORS(MH = &MH, pMH = ptsd);
	%getLogORS(MH = &MH, pMH = som);
		
	%getLogORS(MH = &MH, pMH = psy);
	
	%getLogORS(MH = &MH, pMH = oth);
	%getLogORS(MH = &MH, pMH = slp);
	%getLogORS(MH = &MH, pMH = sex);
	%getLogORS(MH = &MH, pMH = per);
	%getLogORS(MH = &MH, pMH = sui);
	
	data OR_&MH; 
		set OR; 
		Outcome = "any_&MH";
		if Variable NE "Intercept"; 
	run;

%mend LogOR_risk;

* Primary partners (MF combined);
%LogOR_risk(MH = sub);
%LogOR_risk(MH = adhd);
%LogOR_risk(MH = dep);
%LogOR_risk(MH = str);
%LogOR_risk(MH = anx);
%LogOR_risk(MH = phb);
%LogOR_risk(MH = ptsd);
%LogOR_risk(MH = som);
%LogOR_risk(MH = psy);
%LogOR_risk(MH = oth);
%LogOR_risk(MH = slp);
%LogOR_risk(MH = sex);
%LogOR_risk(MH = per);
%LogOR_risk(MH = sui);

data OR_all_pp;
	set OR_adhd OR_sub  
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;

	if DF ne 0 and Estimate ne 0;
run;

proc datasets;
	delete	OR OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui

 		   	MH_OR  
			adhd_OR sub_OR 
			str_OR  anx_OR dep_OR phb_OR som_OR ptsd_OR
			psy_OR 
			sex_OR  slp_OR sui_OR per_OR oth_OR;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoFemaleComLogORs_09Dec2024.csv"
	dbms = csv
	replace;
run;

* No Male Comorbidity ORs (combined M/F);
%macro getORS (MH = , pMH = );
	proc freq data = assortmate2; 
		table m_any_&MH*f_any_&pMH / RELRISK; 
		where m_any_&pMH = 0; 
		ods output RelativeRisks = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;

	proc datasets; delete &MH._OR; run; quit;
%mend getORs;

%macro OR_risk(MH = );

	proc freq data = assortmate2; 
		table m_any_&MH*f_any_sub / RELRISK; 
		where m_any_sub = 0; 
		ods output RelativeRisks = &MH._OR; run;
	data OR; 
		set &MH._OR;
	run;
	proc datasets; delete &MH._OR; run; quit;
		
	%getORS(MH = &MH, pMH = adhd);

	%getORS(MH = &MH, pMH = dep);
	%getORS(MH = &MH, pMH = str);
	%getORS(MH = &MH, pMH = anx);
	%getORS(MH = &MH, pMH = phb);
	%getORS(MH = &MH, pMH = ptsd);
	%getORS(MH = &MH, pMH = som);	
	
	%getORS(MH = &MH, pMH = psy);

	%getORS(MH = &MH, pMH = oth);
	%getORS(MH = &MH, pMH = slp);
	%getORS(MH = &MH, pMH = sex);
	%getORS(MH = &MH, pMH = per);	
	%getORS(MH = &MH, pMH = sui);	

	data OR_&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Primary partners (Combined M/F);
%OR_risk(MH = sub);
%OR_risk(MH = adhd);
%OR_risk(MH = dep);
%OR_risk(MH = str);
%OR_risk(MH = anx);
%OR_risk(MH = phb);
%OR_risk(MH = ptsd);
%OR_risk(MH = som);
%OR_risk(MH = psy);
%OR_risk(MH = oth);
%OR_risk(MH = slp);
%OR_risk(MH = sex);
%OR_risk(MH = per);
%OR_risk(MH = sui);

data OR_all_pp;
	set OR_sub OR_adhd 
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete	OR 
		  	OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoMaleComORs_09Dec2024.csv"
	dbms = csv
	replace;
run;


%macro getLogORS (MH = , pMH = );
	proc logistic data = assortmate2; 
		model m_any_&MH (event = '1') = f_any_&pMH;
		where m_any_&pMH = 0;
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;
%mend getLogORs;

%macro LogOR_risk(MH = );

	proc logistic data = assortmate2; 
		model m_any_&MH (event = '1') = f_any_adhd; 
		where m_any_adhd = 0; 
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; set &MH._OR; run;

	%getLogORS(MH = &MH, pMH = sub);
	
	%getLogORS(MH = &MH, pMH = dep);
	%getLogORS(MH = &MH, pMH = str);
	%getLogORS(MH = &MH, pMH = anx);
	%getLogORS(MH = &MH, pMH = phb);
	%getLogORS(MH = &MH, pMH = ptsd);
	%getLogORS(MH = &MH, pMH = som);
		
	%getLogORS(MH = &MH, pMH = psy);
	
	%getLogORS(MH = &MH, pMH = oth);
	%getLogORS(MH = &MH, pMH = slp);
	%getLogORS(MH = &MH, pMH = sex);
	%getLogORS(MH = &MH, pMH = per);
	%getLogORS(MH = &MH, pMH = sui);
	
	data OR_&MH; 
		set OR; 
		Outcome = "any_&MH";
		if Variable NE "Intercept"; 
	run;

%mend LogOR_risk;

* Primary partners (MF combined);
%LogOR_risk(MH = sub);
%LogOR_risk(MH = adhd);
%LogOR_risk(MH = dep);
%LogOR_risk(MH = str);
%LogOR_risk(MH = anx);
%LogOR_risk(MH = phb);
%LogOR_risk(MH = ptsd);
%LogOR_risk(MH = som);
%LogOR_risk(MH = psy);
%LogOR_risk(MH = oth);
%LogOR_risk(MH = slp);
%LogOR_risk(MH = sex);
%LogOR_risk(MH = per);
%LogOR_risk(MH = sui);

data OR_all_pp;
	set OR_adhd OR_sub  
		OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
		OR_psy
		OR_oth OR_slp OR_sex OR_per OR_sui;

	if DF ne 0 and Estimate ne 0;
run;

proc datasets;
	delete	OR OR_sub OR_adhd 
			OR_dep OR_str OR_anx OR_phb OR_ptsd OR_som 
			OR_psy
			OR_oth OR_slp OR_sex OR_per OR_sui

 		   	MH_OR  
			adhd_OR sub_OR 
			str_OR  anx_OR dep_OR phb_OR som_OR ptsd_OR
			psy_OR 
			sex_OR  slp_OR sui_OR per_OR oth_OR;
run;
quit;

proc export data = OR_all_pp
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoMaleComLogORs_09Dec2024.csv"
	dbms = csv
	replace;
run;


*IRR for # dx;
proc genmod data = assortmate2;
	class couple_no;
	model m_dx_variety = f_dx_variety / dist = negbin;
	repeated subject = couple_no;
run;
proc genmod data = assortmate2;
	class couple_no;
	model f_dx_variety = m_dx_variety / dist = negbin;
	repeated subject = couple_no;
run;

* Risk differences ... Comorbidity;
%macro getRDs (MH = , pMH = );
	proc freq data = assortmate; 
		table any_&MH*any_&pMH / RISKDIFF;
		ods output RiskDiffCol2 = &MH._RD;
	run;

	data RD; 
		set RD &MH._RD;
	run;
%mend getRDs;

%macro RD_risk(MH = );

	proc freq data = assortmate; 
		table any_&MH*any_adhd / RISKDIFF; 
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

* Comorbidity;
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
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\Comorbidity_RiskDiff_17Apr2025.csv"
	dbms = csv
	replace;
run;

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




/*

* ODDS RATIOS;
%macro getORS (MH = , par = , pMH = , m = );
	proc freq data = assortmate; 
		table any_&MH*&par._any_&pMH / RELRISK; 
		where male = &m; 
		ods output RelativeRisks = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;
%mend getORs;

%macro OR_risk(MH = , par = , m = );

	proc freq data = assortmate; 
		table any_&MH*&par._any_MH / RELRISK; 
		where male = &m; 
		ods output RelativeRisks = &par&MH._OR; 
	run;
	data OR; set &par&MH._OR; run;
	
	%getORS(MH = &MH, par = &par, pMH = sub, m = &m);
	%getORS(MH = &MH, par = &par, pMH = adhd, m = &m);
	
	%getORS(MH = &MH, par = &par, pMH = dep, m = &m);
	%getORS(MH = &MH, par = &par, pMH = str, m = &m);
	%getORS(MH = &MH, par = &par, pMH = anx, m = &m);
	%getORS(MH = &MH, par = &par, pMH = phb, m = &m);
	%getORS(MH = &MH, par = &par, pMH = ptsd, m = &m);
	%getORS(MH = &MH, par = &par, pMH = som, m = &m);
		
	%getORS(MH = &MH, par = &par, pMH = psy, m = &m);
	
	%getORS(MH = &MH, par = &par, pMH = oth, m = &m);
	%getORS(MH = &MH, par = &par, pMH = slp, m = &m);
	%getORS(MH = &MH, par = &par, pMH = sex, m = &m);
	%getORS(MH = &MH, par = &par, pMH = per, m = &m);
	%getORS(MH = &MH, par = &par, pMH = sui, m = &m);
	
	data OR_&par&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Primary partners (Male focal);
%OR_risk(MH = MH,   par = pp, m = 1);
%OR_risk(MH = sub,  par = pp, m = 1);
%OR_risk(MH = adhd, par = pp, m = 1);
%OR_risk(MH = dep,  par = pp, m = 1);
%OR_risk(MH = str,  par = pp, m = 1);
%OR_risk(MH = anx,  par = pp, m = 1);
%OR_risk(MH = phb,  par = pp, m = 1);
%OR_risk(MH = ptsd, par = pp, m = 1);
%OR_risk(MH = som,  par = pp, m = 1);
%OR_risk(MH = psy,  par = pp, m = 1);
%OR_risk(MH = oth,  par = pp, m = 1);
%OR_risk(MH = slp,  par = pp, m = 1);
%OR_risk(MH = sex,  par = pp, m = 1);
%OR_risk(MH = per,  par = pp, m = 1);
%OR_risk(MH = sui,  par = pp, m = 1);

data OR_all_pp_m;
	set OR_ppMH  
		OR_ppsub OR_ppadhd 
		OR_ppdep OR_ppstr OR_ppanx OR_ppphb OR_ppptsd OR_ppsom 
		OR_pppsy
		OR_ppoth OR_ppslp OR_ppsex OR_ppper OR_ppsui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;

* Primary partners (Female focal);
%OR_risk(MH = MH,   par = pp, m = 0);
%OR_risk(MH = sub,  par = pp, m = 0);
%OR_risk(MH = adhd, par = pp, m = 0);
%OR_risk(MH = dep,  par = pp, m = 0);
%OR_risk(MH = str,  par = pp, m = 0);
%OR_risk(MH = anx,  par = pp, m = 0);
%OR_risk(MH = phb,  par = pp, m = 0);
%OR_risk(MH = ptsd, par = pp, m = 0);
%OR_risk(MH = som,  par = pp, m = 0);
%OR_risk(MH = psy,  par = pp, m = 0);
%OR_risk(MH = oth,  par = pp, m = 0);
%OR_risk(MH = slp,  par = pp, m = 0);
%OR_risk(MH = sex,  par = pp, m = 0);
%OR_risk(MH = per,  par = pp, m = 0);
%OR_risk(MH = sui,  par = pp, m = 0);

data OR_all_pp_f;
	set OR_ppMH  
		OR_ppsub OR_ppadhd 
		OR_ppdep OR_ppstr OR_ppanx OR_ppphb OR_ppptsd OR_ppsom 
		OR_pppsy
		OR_ppoth OR_ppslp OR_ppsex OR_ppper OR_ppsui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;

proc datasets;
	delete	OR OR_ppMH 
		  	OR_ppadhd OR_ppsub 
		   	OR_ppstr  OR_ppanx OR_ppdep OR_ppptsd OR_ppsom OR_ppphb  
		   	OR_pppsy
			OR_ppsex OR_ppslp OR_ppsui OR_ppper OR_ppoth

 		   	ppMH_OR  
			ppadhd_OR ppsub_OR 
			ppstr_OR  ppanx_OR ppdep_OR ppphb_OR ppsom_OR ppptsd_OR
			pppsy_OR 
			ppsex_OR ppslp_OR ppsui_OR ppper_OR  ppoth_OR;
run;
quit;

proc export data = OR_all_pp_m
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\ORs_PrimaryPartnerM_10Oct2024.csv"
	dbms = csv
	replace;
run;
proc export data = OR_all_pp_f
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\ORs_PrimaryPartnerF_10Oct2024.csv"
	dbms = csv
	replace;
run;

* No Partner Comorbidity ORs (separately for M & F);
%macro getORS (MH = , par = , pMH = , m = );
	proc freq data = assortmate; 
		table any_&MH*&par._any_&pMH / RELRISK; 
		where male = &m and &par._any_&MH = 0; 
		ods output RelativeRisks = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;

	proc datasets; delete &par&MH._OR; run; quit;
%mend getORs;

%macro OR_risk(MH = , par = , m = );

	proc freq data = assortmate; 
		table any_&MH*&par._any_sub / RELRISK; 
		where male = &m and &par._any_&MH = 0; 
		ods output RelativeRisks = &par&MH._OR; run;
	data OR; 
		set &par&MH._OR;
	run;
	proc datasets; delete &par&MH._OR; run; quit;
		
	%getORS(MH = &MH, par = &par, pMH = adhd, m = &m);

	%getORS(MH = &MH, par = &par, pMH = dep, m = &m);
	%getORS(MH = &MH, par = &par, pMH = str, m = &m);
	%getORS(MH = &MH, par = &par, pMH = anx, m = &m);
	%getORS(MH = &MH, par = &par, pMH = phb, m = &m);
	%getORS(MH = &MH, par = &par, pMH = ptsd, m = &m);
	%getORS(MH = &MH, par = &par, pMH = som, m = &m);
	
	
	%getORS(MH = &MH, par = &par, pMH = psy, m = &m);

	%getORS(MH = &MH, par = &par, pMH = oth, m = &m);
	%getORS(MH = &MH, par = &par, pMH = slp, m = &m);
	%getORS(MH = &MH, par = &par, pMH = sex, m = &m);
	%getORS(MH = &MH, par = &par, pMH = per, m = &m);	
	%getORS(MH = &MH, par = &par, pMH = sui, m = &m);	

	data OR_&par&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Primary partners (Male focal);
%OR_risk(MH = sub,  par = pp, m = 1);
%OR_risk(MH = adhd, par = pp, m = 1);
%OR_risk(MH = dep,  par = pp, m = 1);
%OR_risk(MH = str,  par = pp, m = 1);
%OR_risk(MH = anx,  par = pp, m = 1);
%OR_risk(MH = phb,  par = pp, m = 1);
%OR_risk(MH = ptsd, par = pp, m = 1);
%OR_risk(MH = som,  par = pp, m = 1);
%OR_risk(MH = psy,  par = pp, m = 1);
%OR_risk(MH = oth,  par = pp, m = 1);
%OR_risk(MH = slp,  par = pp, m = 1);
%OR_risk(MH = sex,  par = pp, m = 1);
%OR_risk(MH = per,  par = pp, m = 1);
%OR_risk(MH = sui,  par = pp, m = 1);

data OR_all_pp_m;
	set OR_ppsub OR_ppadhd 
		OR_ppdep OR_ppstr OR_ppanx OR_ppphb OR_ppptsd OR_ppsom 
		OR_pppsy
		OR_ppoth OR_ppslp OR_ppsex OR_ppper OR_ppsui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete	OR 
		  	OR_ppadhd OR_ppsub 
		   	OR_ppstr  OR_ppanx OR_ppdep OR_ppptsd OR_ppsom OR_ppphb  
		   	OR_pppsy
			OR_ppsex OR_ppslp OR_ppsui OR_ppper OR_ppoth;
run;
quit;

* Primary partners (Female focal);
%OR_risk(MH = sub,  par = pp, m = 0);
%OR_risk(MH = adhd, par = pp, m = 0);
%OR_risk(MH = dep,  par = pp, m = 0);
%OR_risk(MH = str,  par = pp, m = 0);
%OR_risk(MH = anx,  par = pp, m = 0);
%OR_risk(MH = phb,  par = pp, m = 0);
%OR_risk(MH = ptsd, par = pp, m = 0);
%OR_risk(MH = som,  par = pp, m = 0);
%OR_risk(MH = psy,  par = pp, m = 0);
%OR_risk(MH = oth,  par = pp, m = 0);
%OR_risk(MH = slp,  par = pp, m = 0);
%OR_risk(MH = sex,  par = pp, m = 0);
%OR_risk(MH = per,  par = pp, m = 0);
%OR_risk(MH = sui,  par = pp, m = 0);

data OR_all_pp_f;
	set OR_ppsub OR_ppadhd 
		OR_ppdep OR_ppstr OR_ppanx OR_ppphb OR_ppptsd OR_ppsom 
		OR_pppsy
		OR_ppoth OR_ppslp OR_ppsex OR_ppper OR_ppsui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete	OR 
		  	OR_ppadhd OR_ppsub 
		   	OR_ppstr  OR_ppanx OR_ppdep OR_ppptsd OR_ppsom OR_ppphb  
		   	OR_pppsy
			OR_ppsex OR_ppslp OR_ppsui OR_ppper OR_ppoth;
run;
quit;

proc export data = OR_all_pp_m
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoPComORs_PPartnerM_10Oct2024.csv"
	dbms = csv
	replace;
run;
proc export data = OR_all_pp_f
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoPComORs_PPartnerF_10Oct2024.csv"
	dbms = csv
	replace;
run;

* No Focal Person Comorbidity ORs (separately for M & F);
%macro getORS (MH = , par = , pMH = , m = );
	proc freq data = assortmate; 
		table any_&MH*&par._any_&pMH / RELRISK; 
		where male = &m and any_&pMH = 0; 
		ods output RelativeRisks = &par&MH._OR; 
	run;
	data OR; 
		set OR &par&MH._OR;
	run;

	proc datasets; delete &par&MH._OR; run; quit;
%mend getORs;

%macro OR_risk(MH = , par = , m = );

	proc freq data = assortmate; 
		table any_&MH*&par._any_sub / RELRISK; 
		where male = &m and any_sub = 0; 
		ods output RelativeRisks = &par&MH._OR; run;
	data OR; 
		set &par&MH._OR;
	run;
	proc datasets; delete &par&MH._OR; run; quit;
		
	%getORS(MH = &MH, par = &par, pMH = adhd, m = &m);

	%getORS(MH = &MH, par = &par, pMH = dep, m = &m);
	%getORS(MH = &MH, par = &par, pMH = str, m = &m);
	%getORS(MH = &MH, par = &par, pMH = anx, m = &m);
	%getORS(MH = &MH, par = &par, pMH = phb, m = &m);
	%getORS(MH = &MH, par = &par, pMH = ptsd, m = &m);
	%getORS(MH = &MH, par = &par, pMH = som, m = &m);
		
	%getORS(MH = &MH, par = &par, pMH = psy, m = &m);

	%getORS(MH = &MH, par = &par, pMH = oth, m = &m);
	%getORS(MH = &MH, par = &par, pMH = slp, m = &m);
	%getORS(MH = &MH, par = &par, pMH = sex, m = &m);
	%getORS(MH = &MH, par = &par, pMH = per, m = &m);	
	%getORS(MH = &MH, par = &par, pMH = sui, m = &m);	

	data OR_&par&MH; 
		set OR; 
		if Statistic = "Odds Ratio"; 
	run;

%mend OR_risk;

* Primary partners (Male focal);
%OR_risk(MH = sub,  par = pp, m = 1);
%OR_risk(MH = adhd, par = pp, m = 1);
%OR_risk(MH = dep,  par = pp, m = 1);
%OR_risk(MH = str,  par = pp, m = 1);
%OR_risk(MH = anx,  par = pp, m = 1);
%OR_risk(MH = phb,  par = pp, m = 1);
%OR_risk(MH = ptsd, par = pp, m = 1);
%OR_risk(MH = som,  par = pp, m = 1);
%OR_risk(MH = psy,  par = pp, m = 1);
%OR_risk(MH = oth,  par = pp, m = 1);
%OR_risk(MH = slp,  par = pp, m = 1);
%OR_risk(MH = sex,  par = pp, m = 1);
%OR_risk(MH = per,  par = pp, m = 1);
%OR_risk(MH = sui,  par = pp, m = 1);

data OR_all_pp_m;
	set OR_ppsub OR_ppadhd 
		OR_ppdep OR_ppstr OR_ppanx OR_ppphb OR_ppptsd OR_ppsom 
		OR_pppsy
		OR_ppoth OR_ppslp OR_ppsex OR_ppper OR_ppsui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete	OR 
		  	OR_ppadhd OR_ppsub 
		   	OR_ppstr  OR_ppanx OR_ppdep OR_ppptsd OR_ppsom OR_ppphb  
		   	OR_pppsy
			OR_ppsex OR_ppslp OR_ppsui OR_ppper OR_ppoth;
run;
quit;

* Primary partners (Female focal);
%OR_risk(MH = sub,  par = pp, m = 0);
%OR_risk(MH = adhd, par = pp, m = 0);
%OR_risk(MH = dep,  par = pp, m = 0);
%OR_risk(MH = str,  par = pp, m = 0);
%OR_risk(MH = anx,  par = pp, m = 0);
%OR_risk(MH = phb,  par = pp, m = 0);
%OR_risk(MH = ptsd, par = pp, m = 0);
%OR_risk(MH = som,  par = pp, m = 0);
%OR_risk(MH = psy,  par = pp, m = 0);
%OR_risk(MH = oth,  par = pp, m = 0);
%OR_risk(MH = slp,  par = pp, m = 0);
%OR_risk(MH = sex,  par = pp, m = 0);
%OR_risk(MH = per,  par = pp, m = 0);
%OR_risk(MH = sui,  par = pp, m = 0);

data OR_all_pp_f;
	set OR_ppsub OR_ppadhd 
		OR_ppdep OR_ppstr OR_ppanx OR_ppphb OR_ppptsd OR_ppsom 
		OR_pppsy
		OR_ppoth OR_ppslp OR_ppsex OR_ppper OR_ppsui;

	if (LowerCL ne . and LowerCL < 1) and UpperCL > 1 then sig = 0;
		else if LowerCL > 1 and UpperCL > 1 then sig = 1;
		else if (LowerCL ne . and LowerCL < 1) and (UpperCL ne . and UpperCL < 1) then sig = -1;
run;
proc datasets;
	delete	OR 
		  	OR_ppadhd OR_ppsub 
		   	OR_ppstr  OR_ppanx OR_ppdep OR_ppptsd OR_ppsom OR_ppphb  
		   	OR_pppsy
			OR_ppsex OR_ppslp OR_ppsui OR_ppper OR_ppoth;
run;
quit;

proc export data = OR_all_pp_m
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoFComORs_PPartnerM_10Oct2024.csv"
	dbms = csv
	replace;
run;
proc export data = OR_all_pp_f
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\NoFComORs_PPartnerF_10Oct2024.csv"
	dbms = csv
	replace;
run;
 */
