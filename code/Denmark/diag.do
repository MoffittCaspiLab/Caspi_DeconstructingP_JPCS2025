
*************** PREPARING HOSPITAL DATA ON PSYCHIATRIC DIAGNOSIS *********************

* --------------------------- FROM PCR (ICD 8) ---------------------------------------*
* FROM 1969-  (actually 1970 by the look of out-date)
* ONLY INPATIENT TREATMENT

use $data_E\patient_icd8.dta, clear

gen y_in=year(indldato)
gen y_out=year(udskdato)

gen psyk_pcr=1


** TYPE OF DIAGNOSIS 
* ICD8 
* Use ICD10 classifications + conversion table linking IC10 and ICD8
* Multiple ICD-10 diagnosis possible for one ICD8, based on conversion
* No priority given to which diagnosis (i.e. coded as both)
* primary and secondary diagnosis

gen sub_diag3=substr(hoveddiag,1,3)
gen sub_diag4=substr(hoveddiag,1,4)
gen sub_diag5=substr(hoveddiag,1,5)
gen sub_b1diag3=substr(B1DIAG,1,3)
gen sub_b1diag4=substr(B1DIAG,1,4)
gen sub_b1diag5=substr(B1DIAG,1,5)
gen sub_b2diag3=substr(B2DIAG,1,3)
gen sub_b2diag4=substr(B2DIAG,1,4)
gen sub_b2diag5=substr(B2DIAG,1,5)
gen sub_b3diag3=substr(B3DIAG,1,3)
gen sub_b3diag4=substr(B3DIAG,1,4)
gen sub_b3diag5=substr(B3DIAG,1,5)




local c=0
foreach v in sub_diag sub_b1diag sub_b2diag sub_b3diag {
local c=`c'+1	

/*
** Organic (incl. dementia) (F0)
if `c'==1 gen org=0
replace org=1 if inlist(`v'5,"29009","29010","29011","29018","29019")
replace org=1 if inlist(`v'5,"29209","29219","29229","29239","29299")
replace org=1 if inlist(`v'5,"29309","29319","29329","29339","29349","29359","29399") 
replace org=1 if inlist(`v'5,"29409","29419","29429","29439","29449","29489","29499") 
replace org=1 if inlist(`v'5,"30909","30919","30929","30939","30949","30959","30969")
replace org=1 if inlist(`v'5,"30979","30989","30999")
*/

** Substance abuse (F1)
if `c'==1 gen abuse=0
replace abuse=1 if 	inlist(`v'5,"29109","29119","29129","29139","29199") 
replace abuse=1 if inlist(`v'5,"29439") 
replace abuse=1 if inlist(`v'5,"30309","30319","30329","30399","30320","30328","30390")
replace abuse=1 if inlist(`v'5,"30409","30419","30429","30439","30449","30459","30469")
replace abuse=1 if inlist(`v'5,"30479","30489","30499") 


** Schizofrenia (F2)
if `c'==1 gen skiz=0
replace skiz=1 if	inlist(`v'5,"29509","29519","29529","29539","29549","29559")
replace skiz=1 if	inlist(`v'5,"29569","29579","29589","29599") 
replace skiz=1 if inlist(`v'5,"29689")
replace skiz=1 if inlist(`v'5,"29709","29719","29799") 
replace skiz=1 if inlist(`v'5,"29829","29839","29889","29899") 
replace skiz=1 if inlist(`v'5,"29904","29905","29909") 
replace skiz=1 if inlist(`v'5,"30183")


** bipolar (F30-31)
if `c'==1 gen bipolar=0
replace bipolar=1 if inlist(`v'5,"29619","29639","29819") 

** Other mood disorder (F32-39)
if `c'==1 gen omood=0
replace omood=1 if	inlist(`v'5,"29609","29619","29629","29639","29699") & bipolar==0
replace omood=1 if inlist(`v'5,"29809","29819") & bipolar==0
replace omood=1 if inlist(`v'5,"30049","30119") & bipolar==0


** OCD (F42)
if `c'==1 gen ocd=0
replace ocd=1 if inlist(`v'5,"30039")


** Neurotic, stress-related and somatoform disorders (F40-49) - minus OCD
if `c'==1 gen neuro=0
replace neuro=1 if inlist(`v'5,"30009","30019","30029","30059","30069")
replace neuro=1 if inlist(`v'5,"30079","30089","30099") 
replace neuro=1 if inlist(`v'5,"30509","30519","30529","30539","30549","30559","30569")
replace neuro=1 if inlist(`v'5,"30579","30589","30599","30568") 
replace neuro=1 if inlist(`v'5,"30799") 


** Eating disorder (F50)
if `c'==1 gen eat=0
replace eat=1 if inlist(`v'5,"30560","30650","30658","30659")

** Personality (F60)
if `c'==1 gen per=0
replace per=1 if inlist(`v'5,"30109","30129","30139","30149","30159","30169","30179")
replace per=1 if inlist(`v'5,"30189","30199") 
replace per=1 if inlist(`v'5,"30180","30181","30182","30184")

/*
** Mental retardering (F7)
if `c'==1 gen men=0
replace men=1 if inlist(`v'3,"311","312","313","314","315")
*/


** Pervasive developmental disorders (F84)
if `c'==1 gen dev=0
replace dev=1 if inlist(`v'5,"29900","29901","29902","29903")

** Childhood onset behavioral/emotional disorders - externalizing (F90-92)
if `c'==1 gen ext=0
replace ext=1 if inlist(`v'5,"30801","30802","30803")

}

global diag abuse skiz bipolar omood neuro ocd eat per dev ext

sum $diag


egen tjek=rowtotal(abuse-ext)
drop if tjek==0


*** RETAINING ONE OBSERVATION PER YEAR (KEEP THE ONE WITH THE LONGEST SPELL)

foreach v in $diag {
	bysort pnr y_in: egen h=max(`v')
	replace `v'=h
	drop h
}

keep pnr y_in $diag 

duplicates drop

**** CLEAN UP

drop if y_in>=1994

gen icd=8

save $asa/data/pcr_icd8.dta, replace




* --------------------------- FROM PCR (ICD 10) ---------------------------------------*
* FROM 1994-  
* ONLY INPATIENT TREATMENT
* Different structure. Each diagnosis has its own record - one admittance will count multiple times if multiple diagnosis
* Dart marks whether it is a primary og bidaginosis 


use $data_E\patient_icd10.dta, clear
merge 1:m PAT_SEQ using $data_E\diag_icd10.dta, nogen 


gen y_in=year(indldato)
gen y_out=year(udskdato)

gen psyk_pcr=1


** Keeping only psykiatric contacts 
gen sub_diag=substr(diag,1,2)
keep if sub_diag=="DF" 

** TYPE OF DIAGNOSIS 
* ICD10 
* Hoveddiag and first bidaginosis

gen hoveddiag=diag if dart=="A"
gen B1DIAG=diag if dart=="B"

gen sub_diag3=substr(hoveddiag,1,3)
gen sub_diag4=substr(hoveddiag,1,4)
gen sub_b1diag3=substr(B1DIAG,1,3)
gen sub_b1diag4=substr(B1DIAG,1,4)

local c=0
foreach v in sub_diag sub_b1diag {
local c=`c'+1	

/*
** Organic (incl. dementia) (F0)
if `c'==1 gen org=0
replace org=1 if inlist(`v'3,"DF0") 
*/

** Substance abuse (F1)
if `c'==1 gen abuse=0
replace abuse=1 if 	inlist(`v'3,"DF1") 

** Schizofrenia (F2)
if `c'==1 gen skiz=0
replace skiz=1 if	inlist(`v'3,"DF2")

** Bipolar (F30-31)
if `c'==1 gen bipolar=0
replace bipolar=1 if 	inlist(`v'4,"DF30","DF31")

** Mood (F32-39)
if `c'==1 gen omood=0
replace omood=1 if 	inlist(`v'3,"DF3") & bipolar!=1

** Neurotic, stress-related, and somatoform disorders
if `c'==1 gen neuro=0
replace neuro=1 if inlist(`v'4,"DF40","DF41","DF43","DF44","DF45","DF46","DF47","DF48")

** Neurotic, stress-related, and somatoform disorders
if `c'==1 gen ocd=0
replace ocd=1 if inlist(`v'4,"DF42")

** Eating disorder (F50)
if `c'==1 gen eat=0
replace eat=1 if inlist(`v'4,"DF50")

** Personality (F60)
if `c'==1 gen per=0
replace per=1 if inlist(`v'4,"DF60") 

/*
** Mental retardering (F7)
if `c'==1 gen men=0
replace men=1 if inlist(`v'3,"DF7")
*/

** Developmental disorders 
if `c'==1 gen dev=0
replace dev=1 if inlist(`v'4,"DF84")

** Externalizing 
if `c'==1 gen ext=0
replace ext=1 if inlist(`v'4,"DF90","DF91","DF92")


}

global diag abuse skiz bipolar omood neuro ocd eat per dev ext

sum $diag


egen tjek=rowtotal(abuse-ext)
keep if tjek==1


*** RETAINING ONE OBSERVATION PER YEAR (KEEP THE ONE WITH THE LONGEST SPELL)

foreach v in $diag {
	bysort pnr y_in: egen h=max(`v')
	replace `v'=h
	drop h
}

keep pnr y_in $diag 

duplicates drop

**** CLEAN UP

drop if y_in>1994

gen icd=10

save $asa/data/pcr_icd10.dta, replace


** FROM LPS/PSYK
* From 1995
* cumulative - runs to 2018
*------------------------------------------------------------------------------

use $dd100/psyk_diag2018.dta, clear
merge m:1 recnum using $dd100/psyk_adm2018.dta, nogen

** Keeping only psykiatric contacts
gen sub_diag=substr(c_diag,1,2)
keep if sub_diag=="DF" 

* Keeping aktions + bidiagnoser
* Aktionsdiagnose: diagnosis that lead to contact and is primary cause of udredning/treatment
* Bidiagnose: other diagnosis relevant for the contact (not all other diagnosis)
keep if c_diagtype=="A"|c_diagtype=="B"



*** TYPE OF DIAGNOSIS


	gen psyk=1

	gen sub_diag3=substr(c_diag,1,3)
	gen sub_diag4=substr(c_diag,1,4)

/*
** Organic (incl. dementia) (F0)
gen org=0
replace org=1 if inlist(sub_diag3,"DF0") 
*/

** Substance abuse (F1)
gen abuse=0
replace abuse=1 if 	inlist(sub_diag3,"DF1") 

** Schizofrenia (F2)
gen skiz=0
replace skiz=1 if	inlist(sub_diag3,"DF2")

** Bipolar (F30-31)
gen bipolar=0
replace bipolar=1 if 	inlist(sub_diag4,"DF30","DF31") 

** Other Mood (F32-39)
gen omood=0
replace omood=1 if 	inlist(sub_diag3,"DF3") & bipolar==0

** OCD (F42)
gen ocd=0
replace ocd=1 if inlist(sub_diag4,"DF42")

** Neurotic, stress-related, and somatoform disorders
gen neuro=0
replace neuro=1 if inlist(sub_diag4,"DF40","DF41","DF43","DF44","DF45","DF46","DF47","DF48")

** Eating disorder (F50)
gen eat=0
replace eat=1 if inlist(sub_diag4,"DF50")

** Personality (F60)
gen per=0
replace per=1 if inlist(sub_diag4,"DF60") 

/*
** Mental retardering (F7)
gen men=0
replace men=1 if inlist(sub_diag3,"DF7")
*/

** Developmental disorders 
gen dev=0
replace dev=1 if inlist(sub_diag4,"DF84")

** Developmental disorders 
gen ext=0
replace ext=1 if inlist(sub_diag4,"DF90","DF91","DF92")




global diag abuse skiz bipolar omood neuro ocd eat per dev ext

sum $diag


egen tjek=rowtotal(abuse-ext)
keep if tjek==1

	gen ind_year=year(d_inddto)

	

*** RETAINING ONE OBSERVATION PER ind-year (KEEP THE ONE WITH THE LONGEST SPELL)

	foreach v in $diag {
	bysort pnr ind_year: egen h=max(`v')
	replace `v'=h
	drop h
	}	


	keep if pnr!=.

	keep pnr ind_year $diag ///
	
	duplicates drop
	
	*drop if ind_year<1995
	drop if ind_year>2018
	
	save $asa/data/lps_diagnosis.dta, replace
	
		

clear