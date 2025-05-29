DM			'LOG; CLEAR; ;OUT; CLEAR; ';
%LET		program = M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\03_3Reasons_RandomPartner_Dec2024.sas;
FOOTNOTE	"&program on &sysdate";

***************************************************************************************************;
* For:				Norway
* Paper:			Norway: MH Cummulative Incidence 
* Programmer:		Renate Houts
* File:				M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\03_3Reasons_RandomPartner_Dec2024.sas;
* Modification Hx:	10-Oct-2024 Select random opposite sex partners and re-run OR's
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

* Get focal partner info;
*   Matching on age, sex;
data asm;
	set thr_asm.Focal_primary_MH_Dec2024;

	if no_partner = 0;

	dx_variety    = SUM(any_sub, any_adhd, any_dep, any_str, any_anx, any_phb, any_ptsd, any_som, any_psy, any_oth, any_slp, any_sex, any_per, any_sui);
	pp_dx_variety = SUM(pp_any_sub, pp_any_adhd, pp_any_dep, pp_any_str, pp_any_anx, pp_any_phb, pp_any_ptsd, pp_any_som, pp_any_psy, 
						pp_any_oth, pp_any_slp, pp_any_sex, pp_any_per, pp_any_sui);

run;

proc contents data = asm varnum; run;

* Split file by participant age/sex, create random partners, remerge;
%macro randomize (mf = , fm = , male = , age = );
	data age&age._&mf  (keep = w19_1011_lnr_k2_ male age_start n_partner dx_variety 
							   any_MH any_str any_adhd any_anx any_dep any_phb any_psy any_ptsd any_sex any_slp any_som any_sub any_sui any_per any_oth)
		 age&age._r&fm (keep = rand_id r_id rr_age_start r_n_partner rr_dx_variety 
							   rr_any_MH rr_any_str rr_any_adhd rr_any_anx rr_any_dep rr_any_phb rr_any_psy rr_any_ptsd rr_any_sex rr_any_slp rr_any_som 
							   rr_any_sub rr_any_sui rr_any_per rr_any_oth);
		 set asm;

		 if age_start_fl = &age and male = &male;

		 rand_id = rand("uniform");

		 array pp [18]	pp_age_start p_n_partner pp_dx_variety
						pp_any_MH pp_any_str pp_any_adhd pp_any_anx pp_any_dep pp_any_phb pp_any_psy pp_any_ptsd pp_any_sex pp_any_slp pp_any_som 
						pp_any_sub pp_any_sui  pp_any_per pp_any_oth;
		 array rand [18} rr_age_start r_n_partner rr_dx_variety
						 rr_any_MH rr_any_str rr_any_adhd rr_any_anx rr_any_dep rr_any_phb rr_any_psy rr_any_ptsd rr_any_sex rr_any_slp rr_any_som 
						 rr_any_sub rr_any_sui  rr_any_per rr_any_oth;

		 do i = 1 to 18;
		 	r_id    = primary_id;
			rand[i] = pp[i];
		  end;
	run;

	proc sort data = age&age._r&fm; 
		by rand_id; 
	run;
	data age&age._&mf; 
		merge age&age._&mf age&age._r&fm; 
	run;
%mend randomize;
/*
%randomize(mf = m, fm = f, male = 1, age = 20);
%randomize(mf = m, fm = f, male = 1, age = 21);
%randomize(mf = m, fm = f, male = 1, age = 22);
%randomize(mf = m, fm = f, male = 1, age = 23);
%randomize(mf = m, fm = f, male = 1, age = 24);
%randomize(mf = m, fm = f, male = 1, age = 25);
%randomize(mf = m, fm = f, male = 1, age = 26);
%randomize(mf = m, fm = f, male = 1, age = 27);
%randomize(mf = m, fm = f, male = 1, age = 28);
%randomize(mf = m, fm = f, male = 1, age = 29);
%randomize(mf = m, fm = f, male = 1, age = 30);
%randomize(mf = m, fm = f, male = 1, age = 31);
%randomize(mf = m, fm = f, male = 1, age = 32);
%randomize(mf = m, fm = f, male = 1, age = 33);
%randomize(mf = m, fm = f, male = 1, age = 34);
%randomize(mf = m, fm = f, male = 1, age = 35);
%randomize(mf = m, fm = f, male = 1, age = 36);
%randomize(mf = m, fm = f, male = 1, age = 37);
%randomize(mf = m, fm = f, male = 1, age = 38);
%randomize(mf = m, fm = f, male = 1, age = 39);
%randomize(mf = m, fm = f, male = 1, age = 40);
%randomize(mf = m, fm = f, male = 1, age = 41);
%randomize(mf = m, fm = f, male = 1, age = 42);
%randomize(mf = m, fm = f, male = 1, age = 43);
%randomize(mf = m, fm = f, male = 1, age = 44);
%randomize(mf = m, fm = f, male = 1, age = 45);
%randomize(mf = m, fm = f, male = 1, age = 46);
%randomize(mf = m, fm = f, male = 1, age = 47);
%randomize(mf = m, fm = f, male = 1, age = 48);
%randomize(mf = m, fm = f, male = 1, age = 49);
%randomize(mf = m, fm = f, male = 1, age = 50);
*/

%randomize(mf = f, fm = m, male = 0, age = 20);
%randomize(mf = f, fm = m, male = 0, age = 21);
%randomize(mf = f, fm = m, male = 0, age = 22);
%randomize(mf = f, fm = m, male = 0, age = 23);
%randomize(mf = f, fm = m, male = 0, age = 24);
%randomize(mf = f, fm = m, male = 0, age = 25);
%randomize(mf = f, fm = m, male = 0, age = 26);
%randomize(mf = f, fm = m, male = 0, age = 27);
%randomize(mf = f, fm = m, male = 0, age = 28);
%randomize(mf = f, fm = m, male = 0, age = 29);
%randomize(mf = f, fm = m, male = 0, age = 30);
%randomize(mf = f, fm = m, male = 0, age = 31);
%randomize(mf = f, fm = m, male = 0, age = 32);
%randomize(mf = f, fm = m, male = 0, age = 33);
%randomize(mf = f, fm = m, male = 0, age = 34);
%randomize(mf = f, fm = m, male = 0, age = 35);
%randomize(mf = f, fm = m, male = 0, age = 36);
%randomize(mf = f, fm = m, male = 0, age = 37);
%randomize(mf = f, fm = m, male = 0, age = 38);
%randomize(mf = f, fm = m, male = 0, age = 39);
%randomize(mf = f, fm = m, male = 0, age = 40);
%randomize(mf = f, fm = m, male = 0, age = 41);
%randomize(mf = f, fm = m, male = 0, age = 42);
%randomize(mf = f, fm = m, male = 0, age = 43);
%randomize(mf = f, fm = m, male = 0, age = 44);
%randomize(mf = f, fm = m, male = 0, age = 45);
%randomize(mf = f, fm = m, male = 0, age = 46);
%randomize(mf = f, fm = m, male = 0, age = 47);
%randomize(mf = f, fm = m, male = 0, age = 48);
%randomize(mf = f, fm = m, male = 0, age = 49);
%randomize(mf = f, fm = m, male = 0, age = 50);

data random_partners;
	set /*age20_m age21_m age22_m age23_m age24_m age25_m age26_m age27_m age28_m age29_m age30_m
		        age31_m age32_m age33_m age34_m age35_m age36_m age37_m age38_m age39_m age40_m
		        age41_m age42_m age43_m age44_m age45_m age46_m age47_m age48_m age49_m age50_m */
		age20_f age21_f age22_f age23_f age24_f age25_f age26_f age27_f age28_f age29_f age30_f
		        age31_f age32_f age33_f age34_f age35_f age36_f age37_f age38_f age39_f age40_f
		        age41_f age42_f age43_f age44_f age45_f age46_f age47_f age48_f age49_f age50_f;
run;

proc datasets; 
	delete 	/*age20_m age21_m age22_m age23_m age24_m age25_m age26_m age27_m age28_m age29_m age30_m
		            age31_m age32_m age33_m age34_m age35_m age36_m age37_m age38_m age39_m age40_m
		            age41_m age42_m age43_m age44_m age45_m age46_m age47_m age48_m age49_m age50_m */
			age20_f age21_f age22_f age23_f age24_f age25_f age26_f age27_f age28_f age29_f age30_f
		            age31_f age32_f age33_f age34_f age35_f age36_f age37_f age38_f age39_f age40_f
		            age41_f age42_f age43_f age44_f age45_f age46_f age47_f age48_f age49_f age50_f
			age20_rm age21_rm age22_rm age23_rm age24_rm age25_rm age26_rm age27_rm age28_rm age29_rm age30_rm
		             age31_rm age32_rm age33_rm age34_rm age35_rm age36_rm age37_rm age38_rm age39_rm age40_rm
		             age41_rm age42_rm age43_rm age44_rm age45_rm age46_rm age47_rm age48_rm age49_rm age50_rm
			/*age20_rf age21_rf age22_rf age23_rf age24_rf age25_rf age26_rf age27_rf age28_rf age29_rf age30_rf
		             age31_rf age32_rf age33_rf age34_rf age35_rf age36_rf age37_rf age38_rf age39_rf age40_rf
		             age41_rf age42_rf age43_rf age44_rf age45_rf age46_rf age47_rf age48_rf age49_rf age50_rf*/;
run;
quit;

* Flip to male vs female rather than focal vs primary;
data random_partners1;
	set random_partners;

	array focal [18] age_start n_partner dx_variety
					 any_MH  any_sub any_adhd any_dep any_str any_anx any_phb any_ptsd any_som any_psy
		  			 any_oth any_slp any_sex any_per any_sui;
	array prime [18] rr_age_start r_n_partner rr_dx_variety
					 rr_any_MH  rr_any_sub rr_any_adhd rr_any_dep rr_any_str rr_any_anx rr_any_phb rr_any_ptsd rr_any_som rr_any_psy
		  			 rr_any_oth rr_any_slp rr_any_sex  rr_any_per rr_any_sui;

	array m [18] m_age_start m_n_partner m_dx_variety
				 m_any_MH  m_any_sub m_any_adhd m_any_dep m_any_str m_any_anx m_any_phb m_any_ptsd m_any_som m_any_psy
		  		 m_any_oth m_any_slp m_any_sex  m_any_per m_any_sui;
	array f [18] f_age_start f_n_partner f_dx_variety
				 f_any_MH  f_any_sub f_any_adhd f_any_dep f_any_str f_any_anx f_any_phb f_any_ptsd f_any_som f_any_psy
		  		 f_any_oth f_any_slp f_any_sex  f_any_per f_any_sui;

	do i = 1 to 18;
		if male = 1 then do;
			male_id   = w19_1011_lnr_k2_;
			female_id = r_id;
			m[i] = focal[i];
			f[i] = prime[i];
		end;
		if male = 0 then do;
			male_id   = r_id;
			female_id = w19_1011_lnr_k2_;
			m[i] = prime[i];
			f[i] = focal[i];
		end;
	end;

	drop i;
run;

* Delete duplicate partnerships;
proc sort data = random_partners1; by male_id female_id; run;

data random_partners2;
	set random_partners1;
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

proc sort data = random_partners2 nodupkey; by couple_no; run;

proc sort data = random_partners2 out = female nodupkey; by female_id; run;
proc means data = female;
	var f_age_start f_n_partner f_dx_variety;
run;

ods output OneWayFreqs = MHdx;
proc freq data = female; 
	table f_any_MH  f_any_sub f_any_adhd f_any_dep f_any_str f_any_anx f_any_phb f_any_ptsd f_any_som f_any_psy
		  f_any_oth f_any_slp f_any_sex f_any_per f_any_sui;
	where male = 0;
run;
ods output close;

data MHdx_Fpartner; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "f_any_MH"   then do; who = "random_f"; code = "Any Mental Health Disorder";   end;
		else if code = "f_any_sub"  then do; who = "random_f"; code = "Substance abuse";              end;
		else if code = "f_any_adhd" then do; who = "random_f"; code = "ADHD";					 	  end;
		else if code = "f_any_dep"  then do; who = "random_f"; code = "Depression";					  end;
		else if code = "f_any_str"  then do; who = "random_f"; code = "Acute stress reaction";        end;
		else if code = "f_any_anx"  then do; who = "random_f"; code = "Anxiety disorder";			  end;
		else if code = "f_any_phb"  then do; who = "random_f"; code = "Phobia/Compulsive disorder";	  end;
		else if code = "f_any_ptsd" then do; who = "random_f"; code = "PTSD";						  end;
		else if code = "f_any_som"  then do; who = "random_f"; code = "Somatization";				  end;
		else if code = "f_any_psy"  then do; who = "random_f"; code = "Psychosis";					  end;
		else if code = "f_any_oth"  then do; who = "random_f"; code = "Psychological disorders, NOS"; end;
		else if code = "f_any_slp"  then do; who = "random_f"; code = "Sleep disturbance";			  end;
		else if code = "f_any_sex"  then do; who = "random_f"; code = "Sexual concern";				  end;
		else if code = "f_any_per"  then do; who = "random_f"; code = "Personality disorder";		  end;
		else if code = "f_any_sui"  then do; who = "random_f"; code = "Suicide/Suicide attempt";	  end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

proc sort data = random_partners2 out = male nodupkey; by male_id; run;
proc means data = male;
	var m_age_start m_n_partner m_dx_variety;
run;

ods output OneWayFreqs = MHdx;
proc freq data = male; 
	table m_any_MH  m_any_sub m_any_adhd m_any_dep m_any_str m_any_anx m_any_phb m_any_ptsd m_any_som m_any_psy
		  m_any_oth m_any_slp m_any_sex m_any_per m_any_sui;
	where male = 0;
run;
ods output close;

data MHdx_Mpartner; 
	set MHdx; 

	length who $11;

	if MOD(_N_,2) = 0 then value = 1; else value = 0; 
	if value = 1;

	code  = SUBSTR(Table, 7);
	
	if          code = "m_any_MH"   then do; who = "random_m"; code = "Any Mental Health Disorder";   end;
		else if code = "m_any_sub"  then do; who = "random_m"; code = "Substance abuse";              end;
		else if code = "m_any_adhd" then do; who = "random_m"; code = "ADHD";					 	  end;
		else if code = "m_any_dep"  then do; who = "random_m"; code = "Depression";					  end;
		else if code = "m_any_str"  then do; who = "random_m"; code = "Acute stress reaction";        end;
		else if code = "m_any_anx"  then do; who = "random_m"; code = "Anxiety disorder";			  end;
		else if code = "m_any_phb"  then do; who = "random_m"; code = "Phobia/Compulsive disorder";	  end;
		else if code = "m_any_ptsd" then do; who = "random_m"; code = "PTSD";						  end;
		else if code = "m_any_som"  then do; who = "random_m"; code = "Somatization";				  end;
		else if code = "m_any_psy"  then do; who = "random_m"; code = "Psychosis";					  end;
		else if code = "m_any_oth"  then do; who = "random_m"; code = "Psychological disorders, NOS"; end;
		else if code = "m_any_slp"  then do; who = "random_m"; code = "Sleep disturbance";			  end;
		else if code = "m_any_sex"  then do; who = "random_m"; code = "Sexual concern";				  end;
		else if code = "m_any_per"  then do; who = "random_m"; code = "Personality disorder";		  end;
		else if code = "m_any_sui"  then do; who = "random_m"; code = "Suicide/Suicide attempt";	  end;

	all_n = frequency;
	all_p = percent/100;
	keep code who all_n all_p; 
run;

data MHdx_MF;
	set MHdx_Fpartner   MHdx_Mpartner;
run;

proc export data = MHdx_MF
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\AssortativeMating_RandomPrevalence_18Dec2024.csv"
	dbms = csv
	replace;
run;

data thr_asm.random_partners_17Dec2024;
	set random_partners2;
run;

* ODDS RATIOS -- COMBINED M/F;

* Male vs Female ORs;
%macro getORS (MH = , pMH = );
	proc freq data = random_partners2; 
		table m_any_&MH*f_any_&pMH / RELRISK;
		ods output RelativeRisks = pp&MH._OR; 
	run;
	data OR; 
		set OR pp&MH._OR;
	run;
%mend getORs;

%macro OR_risk(MH = );

	proc freq data = random_partners2; 
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
		if Statistic = "Odds Ratio"; 
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
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\ORs_RandomPartner_09Dec2024.csv"
	dbms = csv
	replace;
run;

* LogOR's for Male vs Female;
%macro getLogORS (MH = , pMH = );
	proc logistic data = random_partners2; 
		model m_any_&MH (event = '1') = f_any_&pMH;
		ods output ParameterEstimates = &MH._OR; 
	run;
	data OR; 
		set OR &MH._OR;
	run;
%mend getLogORs;

%macro LogOR_risk(MH = );

	proc logistic data = random_partners2; 
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
	outfile = "M:\p1074-renateh\2024_ThreeReasons\Assortative_Mating\LogORs_RandomPartner_18Dec2024.csv"
	dbms = csv
	replace;
run;
