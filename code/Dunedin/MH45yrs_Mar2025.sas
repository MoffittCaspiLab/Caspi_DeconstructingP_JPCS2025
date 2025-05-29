DM   		'LOG; CLEAR; OUT; CLEAR; ';
%LET 		program = C:\Users\renate\Box Sync\SENSITIVE Folder hlh14\Renate2015\MentalHealth45Yrs\MH45yrs_July2019.sas;
FOOTNOTE	"&program on &sysdate.";

*********************************************************************************************;
*  For:          	Dunedin
*  Paper:			45 years of mental health
*  Programmer:		Renate Houts
*  FILE: 	     	"C:\Users\renate\Box Sync\SENSITIVE Folder hlh14\Renate2015\MentalHealth45Yrs\MH45yrs_July2019.sas"
*
*  Last modified:	
*
*********************************************************************************************;

libname MH		'C:\Users\rh93\Box\Duke_DPPPlab\Renate2015\MentalHealth45Yrs\DataFiles_FromHL';
libname MH1		'C:\Users\rh93\Box\Duke_DPPPlab\Renate2015\MentalHealth45Yrs\DataFiles_FromHL\OLD';
libname Attr	'C:\Users\rh93\Box\Duke_DPPPlab\P45 Incoming\Attrition';
libname P		'C:\Users\rh93\Box\Duke_DPPPlab\Renate2015\2018_LittleP_Expanded\Data';

proc format;
	value INSLT5XC
		 1 = 'probable'  
		 2 = 'severe' ;
	value SEX
		 1 = 'female'  
		 2 = 'male' ;
	value HEIGHT38F
		-9 = 'Missing'  
		-1 = 'Not seen' ;
	value WEIGHT38F
		-9 = 'Missing'  
		-8 = 'Pregnant'  
		-1 = 'Not seen' ;
	value TOTKIDS
		-9 = 'not seen at 38' ;
	value $SEEN38CD
		'D' = 'Deceased'  
		'M' = 'Missing'  
		'R' = 'Refused previously'  
		'S' = 'Seen'  
		'SD' = 'Seen, subsequently died'  
		'SF' = 'Field, Full'  
		'SJ' = 'seen in Jail & at Unit'  
		'NS' = 'Not seen'  
		'R38' = 'Refused at 38'  
		'SFD' = 'Seen field, died later'  
		'SFH' = 'Field, intellectual handicap'  
		'SRQ' = 'Self-report Q'  
		'SFS' = 'Field, short' ;
	value SEENP38F
		1 = 'seen at Unit'  
		2 = 'Field full'  
		3 = 'Questionnaire'  
		4 = 'IHC'  
		5 = 'prison'  
		6 = 'Field, short'  
		8 = 'Dead'  
		9 = 'Not seen' ;
	value BENEFIT
		1 = 'Consent given + found'  
		2 = 'Consent given but not found'  
		3 = 'Consent not given' ;
	value ACC_STAT
		1 = 'Consent given + found'  
		2 = 'Consent given but not found'  
		3 = 'Consent not given' ;
	value CREDIT_S
		1 = 'consented & found'  
		2 = 'not found/no credit score'  
		3 = 'refused consent' ;
	value BLOODSTA
		1 = 'blood drawn'  
		9 = 'declined/field' ;
	value CONVSEAR
		0 = 'not seen at 38'  
		1 = 'search assumed'  
		38 = 'search record found'  
		88 = 'deceased'  
		99 = 'refused' ;
	value NOYES
		0 = 'no disorder'
		1 = 'had disorder';
	value ANOREX
		0 = 'No anorx Dx'
		1 = 'Anorexia Dx';
	value BULLIM
		0 = 'No bullimia Dx'
		1 = 'Bullimia Dx';
	value ADD
		0 = 'No ADD Dx'
		1 = 'ADD Dx';
	value DX
		1 = 'Dx';
	value NODX
		0 = 'No Dx'
		1 = 'Dx present';
	value DXMISS
		1 = 'Dx'
		9 = 'Missing';
	value DXANX
		1 = 'Dx'
		2 = 'crit a,b,c met & on pill';
	value DXDRG
		0 = 'no dx'
		1 = 'drug dep';
	value DXTOB
		1 = 'tob dx';
	value DXNOCOMP
		1 = 'Dx'
		9 = 'did not complete';
	value DXTIME
		1 = 'Dx'
		9 = 'out of time';
	value NOCOMP
		9 = 'did not complete';
	value OOT
		99 = 'out of time';
	value INTVR
		1 = 'Richie'
		2 = 'Sandhya'
		3 = 'Sean'
		4 = 'Liz G'
		5 = 'Elena'
		6 = 'Liz B'
		7 = 'Danielle'
		8 = 'Charmaine'
		9 = 'Lynda'
		10 = 'Kate'
		11 = 'Kirsten'
		12 = 'Barbara'
		13 = 'Jason'
		14 = 'Nikki'
		15 = 'Ness'
		16 = 'Denise'
		17 = 'Melissa'
		18 = 'Fiona'
		19 = 'Dave'
		20 = 'Hanne'
		21 = 'Jane';
	value DXB
		 0 = 'Deceased'
		 1 = 'Thd+Int+Ext'
		 2 = 'Thd+Int'
		 3 = 'Thd+Ext'
		 4 = 'Int+Ext'
		 5 = 'Thd'
		 6 = 'Int'
		 7 = 'Ext'
		 8 = 'Remitted'
		 9 = 'Never'
		10 = 'Missing';
	value DXTY
		 0 = 'Never'
		 1 = 'Remitted'
		 2 = 'Ext'
		 3 = 'Int'
		 4 = 'Thd'		 
		 5 = 'Int+Ext'
		 6 = 'Thd+Ext'
		 7 = 'Thd+Int'
		 8 = 'Thd+Int+Ext'
		 9 = 'Missing'
		10 = 'Deceased';
run;

data MH;
	merge	MH.Childhood_to38_May2019 (drop = BioAgeKD38 PaceOfAging WFSIQ38 wfsiq38STD ZCHBR3 inslt5xc RetroACEs_trunc ProACEs_trunc SESchildhd 
											  sesHi38 sesHiHmk38 ParetoTotHi ParetoHi0to3 infMem38Oct infAtt38Oct hrsearch NHS_antipsychotic38 NHS_antidep38 
											  NHS_anxiolytic38 NHS_adhd38 NHS_AlcDrugTx38 NHS_SmkCess38 NHSany_wsmk NHSany_nosmk ChildhdIQ)
			MH.AllDx45_18June2019 (drop = CogDiffSc45 CogDiffSc45expd Any6anx45d5)
			MH.Phenotypes_June2019 (drop = vci45a pri45a wmi45a psi45a)
			Attr.Seen45wScan
			P.Pfactor_June2019
			MH1.AllDx45_10Aug (keep = snum status15 status18 status21 status26 status32 status38 deaths2018 AgeatDeath2018);
	by snum;

	* Consistently name vars across ages (avoid problems with var name changes in the future);
	adhd15 = addliftm; adhd18 = dxadd18;																adhd38 = dxadhd38;    adhd45 = dxadhd45d5;
	cd15   = cd1115;   cd18   = dxCD_18;   cd21   = dxCD_21;    cd26   = dxCD_26;   cd32   = dxCD_32;   cd38   = dxCD_38;     cd45   = dxCD_45T; 
	                   alc18  = dxALC18u;  alc21  = dxAL21d4;   alc26  = dxal26d4;  alc32  = dxal32d4;  alc38  = dxAL38d4;    alc45  = dxAL45D4;
					   tob18  = dxtob18;   tob21  = dxtob21;    tob26  = dxtob26;   tob32  = dxtob32;   tob38  = dxTob38Dsm4; tob45  = dxTob45dsm4;
					   mar18  = dxMAR18u;  mar21  = dxMAR21;    mar26  = dxmar26;   mar32  = dxmar32;   mar38  = dxmar38;     mar45  = dxmar45;
															    drg26  = dxdrug26;  drg32  = dxdrg32m;  drg38  = dxdrg38m;    drg45  = dxdrg45m;
	anx15 = anx1115;   gad18  = dxGAD18u;  gad21  = dxgad21;    gad26  = dxgad26;   gad32  = dxgad32;   gad38  = dxgad38;     gad45  = dxgad45;
					   pad18  = dxPAD18u;  pad21  = dxpad21;    pad26  = dxpad26;   pad32  = dxpad32;   pad38  = dxpad38;     pad45  = dxpad45;
					   agph18 = dxAGPH18u; agph21 = dxagph21;   agph26 = dx2ag26;   agph32 = dxagph32;  agph38 = dxagph38;    agph45 = dxagph45d5;
					   sop18  = dxSOP18u;  sop21  = dxsop21;    sop26  = dxsop26;   sop32  = dxsop32;   sop38  = dxsop38;     sop45  = dxsop45d5;
					   sip18  = dxSIP18u;  sip21  = dxsip21;    sip26  = dxsip26;   sip32  = dxsip32;   sip38  = dxsip38;     sip45  = dxsip45d5;
	dep15 = dep1115;   mde18  = dxMDE18u;  mde21  = dxmde21;    mde26  = dxmde26;   mde32  = dxmde32;   mde38  = dxmde38;     mde45  = dxmde45;
															    ptsd26 = dxptsd26;  ptsd32 = dxptsd32;  ptsd38 = dxptsd38;    ptsd45 = dxptsd45d5;
					   anr18  = dxanrx18;  anr21  = dxanrx21;   anr26  = dxanrx26;
					   bul18  = dxbul18;   bul21  = dxbul21;    bul26  = dxbul26;
					   ocd18  = dxOBCM18u; ocd21  = dxobcm21;   ocd26  = dxobcm26;   ocd32 = dxobcm32;   ocd38 = dxobcm38;    ocd45 = dxocd45d5;
					                       man21  = dxmania_21; man26  = dxmania_26; man32 = dxMania_32; man38 = dxmania_38;  man45 = DxMania45;
										   scz21  = dxSchiz_21; scz26  = dxSchiz_26; scz32 = dxSchiz_32; scz38 = dxSchiz_38;  scz45 = dxschiz45;

	* Recode 2 into 1 for Anorexia @ 26;
	if anr26 = 2 then anr26 = 1;

	* Create dead/alive;
	array st[6] status15 status18 status21 status26 status32 status38;
	array dd[6] dead15   dead18   dead21   dead26   dead32   dead38;
	do i = 1 to 6;
		dd[i]    = 0;
		if st[i] = 8 then dd[i] = 1;
	end;
	dead45 = 0;
	if AgeatDeath2018 ne 88 then dead45 = 1;
	if snum = 516 then dead45 = 0; 							* Died after being seen for P45;

	drop 
		i oanx1115 sep1115 mde1115 phob1115 dxdys21
		addliftm dxadd18							         dxadhd38    dxadhd45d5
		cd1115   dxCD_18    dxCD_21    dxCD_26    dxCD_32    dxCD_38     dxCD_45T
		         dxALC18u   dxAL21d4   dxal26d4   dxal32d4   dxAL38d4    dxAL45D4
				 dxtob18    dxtob21    dxtob26    dxtob32    dxTob38Dsm4 dxTob45dsm4
				 dxMAR18u   dxMAR21    dxmar26    dxmar32    dxmar38     dxmar45
									   dxdrug26   dxdrg32m   dxdrg38m    dxdrg45m
		anx1115  dxGAD18u   dxgad21    dxgad26    dxgad32    dxgad38     dxgad45
				 dxPAD18u   dxpad21    dxpad26    dxpad32    dxpad38     dxpad45
				 dxAGPH18u  dxagph21   dx2ag26    dxagph32   dxagph38    dxagph45d5
				 dxSOP18u   dxsop21    dxsop26    dxsop32    dxsop38     dxsop45d5
				 dxSIP18u   dxsip21    dxsip26    dxsip32    dxsip38     dxsip45d5
		dep1115  dxMDE18u   dxmde21    dxmde26    dxmde32    dxmde38     dxmde45
									   dxptsd26   dxptsd32   dxptsd38    dxptsd45d5
				 dxanrx18   dxanrx21   dxanrx26
				 dxbul18    dxbul21    dxbul26
				 dxOBCM18u  dxobcm21   dxobcm26   dxobcm32   dxobcm38    dxocd45d5
						    dxmania_21 dxmania_26 dxMania_32 dxmania_38  dxmania45
							dxSchiz_21 dxSchiz_26 dxSchiz_32 dxSchiz_38  dxSchiz45
		status15 status18   status21   status26   status32   status38

		EverAttSuic38 cd21dsm4 cd26dsm4 CogDiffSc38 MHRXCT2038 NewPsyHos2038 NHS_EvPsyHsp38 

		Seen45t Codemeaning Seen45 SeenNot45 IntDate45 ScanDate Scanned45 EXT_BF45 INT_BF45 
		EXT_CF45 INT_CF45 THD_CF45 deaths2018;

run;

proc contents data = MH varnum; run;

* Check that all are coded 0/1;
proc freq data = MH;
	table anx15  gad18  gad21  gad26  gad32  gad38  gad45;
	table dep15  mde18  mde21  mde26  mde32  mde38  mde45;
	table        pad18  pad21  pad26  pad32  pad38  pad45;
	table        agph18 agph21 agph26 agph32 agph38 agph45;
	table        sop18  sop21  sop26  sop32  sop38  sop45;
	table        sip18  sip21  sip26  sip32  sip38  sip45;
	table        anr18  anr21  anr26;
	table        bul18  bul21  bul26;
	table                      ptsd26 ptsd32 ptsd38 ptsd45;

	table adhd15 adhd18                      adhd38 adhd45;
	table cd15   cd18   cd21   cd26   cd32   cd38   cd45;    
	table        alc18  alc21  alc26  alc32  alc38  alc45;
	table        tob18  tob21  tob26  tob32  tob38  tob45;
	table        mar18  mar21  mar26  mar32  mar38  mar45;
	table                      drg26  drg32  drg38  drg45;
	
	table        ocd18  ocd21  ocd26  ocd32  ocd38  ocd45;
	table               man21  man26  man32  man38  man45;
	table				scz21  scz26  scz32  scz38  scz45;

	table dead15 dead18 dead21 dead26 dead32 dead38 dead45;

run;

data MH_1;
	set	MH;
	by snum;

	null = .;

	* Arrays of dx across phases;
	array dead[7] dead15 dead18 dead21 dead26 dead32 dead38 dead45;

	array gad [7] anx15  gad18  gad21  gad26  gad32  gad38  gad45;
	array mde [7] dep15  mde18  mde21  mde26  mde32  mde38  mde45;
	array pad [7] null   pad18  pad21  pad26  pad32  pad38  pad45;
	array agph[7] null   agph18 agph21 agph26 agph32 agph38 agph45;
	array sop [7] null   sop18  sop21  sop26  sop32  sop38  sop45;
	array sip [7] null   sip18  sip21  sip26  sip32  sip38  sip45;
	array anr [7] null   anr18  anr21  anr26  null   null   null;
	array bul [7] null   bul18  bul21  bul26  null   null   null;
	array ptsd[7] null   null   null   ptsd26 ptsd32 ptsd38 ptsd45;

	array adhd[7] adhd15 adhd18 null   null   null   adhd38 adhd45;
	array cd  [7] cd15   cd18   cd21   cd26   cd32   cd38   cd45;    
	array alc [7] null   alc18  alc21  alc26  alc32  alc38  alc45;
	array tob [7] null   tob18  tob21  tob26  tob32  tob38  tob45;
	array mar [7] null   mar18  mar21  mar26  mar32  mar38  mar45;
	array drg [7] null   null   null   drg26  drg32  drg38  drg45;
	
	array ocd [7] null   ocd18  ocd21  ocd26  ocd32  ocd38  ocd45;
	array man [7] null   null   man21  man26  man32  man38  man45;
	array scz [7] null   null   scz21  scz26  scz32  scz38  scz45;

	* Created variables;
	array fear[7] null      fear18    fear21    fear26    fear32    fear38    fear45;
	array eat [7] null      eat18     eat21     eat26     null      null      null;
	array aanx[7] null		anyanx18  anyanx21  anyanx26  anyanx32  anyanx38 anyanx45;

	array aint[7] anyint15  anyint18  anyint21  anyint26  anyint32  anyint38  anyint45;
	array intn[7] Nint15    Nint18    Nint21    Nint26    Nint32    Nint38    Nint45;

	array aext[7] anyext15  anyext18  anyext21  anyext26  anyext32  anyext38  anyext45;
	array extn[7] Next15    Next18    Next21    Next26    Next32    Next38    Next45;

	array athd[7] anythd15  anythd18  anythd21  anythd26  anythd32  anythd38  anythd45;
	array thdn[7] Nthd15    Nthd18    Nthd21    Nthd26    Nthd32    Nthd38    Nthd45;

	array adx [7] anydx15   anydx18   anydx21   anydx26   anydx32   anydx38   anydx45;
	array dxn [7] Ndx15     Ndx18     Ndx21     Ndx26     Ndx32     Ndx38     Ndx45;
	array dxty[7] dxtype15  dxtype18  dxtype21  dxtype26  dxtype32  dxtype38  dxtype45;
	array dxtp[7] dxtype15a dxtype18a dxtype21a dxtype26a dxtype32a dxtype38a dxtype45a;

	* Arrays of phases across dx;
	array ph15a [18] anx15    dep15    null      null     null      adhd15    cd15    null     null     null     null     null     null     null
				  	 anyint15 anyext15 anythd15  anydx15;
	array ph18a [18] gad18    mde18    fear18    eat18    null      adhd18    cd18    alc18    tob18    mar18    null     ocd18    null     null
					 anyint18 anyext18 anythd18  anydx18;
	array ph21a [18] gad21    mde21    fear21    eat21    null      null      cd21    alc21    tob21    mar21    null     ocd21    man21    scz21
					 anyint21 anyext21 anythd21  anydx21;
	array ph26a [18] gad26    mde26    fear26    eat26    ptsd26    null      cd26    alc26    tob26    mar26    drg26    ocd26    man26    scz26
					 anyint26 anyext26 anythd26  anydx26;
	array ph32a [18] gad32    mde32    fear32    null     ptsd32    null      cd32    alc32    tob32    mar32    drg32    ocd32    man32    scz32
					 anyint32 anyext32 anythd32  anydx32;
	array ph38a [18] gad38    mde38    fear38    null     ptsd38    adhd38    cd38    alc38    tob38    mar38    drg38    ocd38    man38    scz38
					 anyint38 anyext38 anythd38  anydx38;
	array ph45a [18] gad45    mde45    fear45    null     ptsd45    adhd45    cd45    alc45    tob45    mar45    drg45    ocd45    man45    scz45
					 anyint45 anyext45 anythd45  anydx45;
	array ph_any[18] anygad   anymde   anyfear   anyeat   anyptsd   anyadhd   anycd   anyalc   anytob   anymar   anydrg   anyocd   anyman   anyscz
					 anyint   anyext   anythd    anydx;
	array ph_ph [18] Ngad     Nmde     Nfear     Neat     Nptsd     Nadhd     Ncd     Nalc     Ntob     Nmar     Ndrg     Nocd     Nman     Nscz
					 NPhint   NPhext   NPhthd    NPhdx;

	array ph_ag1[18] gadph1     mdeph1     fearph1     eatph1     ptsdph1     adhdph1     cdph1     alcph1     tobph1     marph1     drgph1     ocdph1     manph1     sczph1
					 intph1     extph1     thdph1      dxph1;
	array ph_ag2[18] gadph2     mdeph2     fearph2     eatph2     ptsdph2     adhdph2     cdph2     alcph2     tobph2     marph2     drgph2     ocdph2     manph2     sczph2
					 intph2     extph2     thdph2      dxph2;
	array ph_lag[18] gadlag     mdelag     fearlag     eatlag     ptsdlag     adhdlag     cdlag     alclag     toblag     marlag     drglag     ocdlag     manlag     sczlag
					 intlag     extlag     thdlag      dxlag;
	array ph15f [18] firstanx15 firstdep15 firstfear15 firsteat15 firstptsd15 firstadhd15 firstcd15 firstalc15 firsttob15 firstmar15 firstdrg15 firstocd15 firstman15 firstscz15
				  	 firstint15 firstext15 firstthd15  firstdx15;
	array ph18f [18] firstgad18 firstmde18 firstfear18 firsteat18 firstptsd18 firstadhd18 firstcd18 firstalc18 firsttob18 firstmar18 firstdrg18 firstocd18 firstman18 firstscz18
					 firstint18 firstext18 firstthd18  firstdx18;
	array ph21f [18] firstgad21 firstmde21 firstfear21 firsteat21 firstptsd21 firstadhd21 firstcd21 firstalc21 firsttob21 firstmar21 firstdrg21 firstocd21 firstman21 firstscz21
					 firstint21 firstext21 firstthd21  firstdx21;
	array ph26f [18] firstgad26 firstmde26 firstfear26 firsteat26 firstptsd26 firstadhd26 firstcd26 firstalc26 firsttob26 firstmar26 firstdrg26 firstocd26 firstman26 firstscz26
					 firstint26 firstext26 firstthd26  firstdx26;
	array ph32f [18] firstgad32 firstmde32 firstfear32 firsteat32 firstptsd32 firstadhd32 firstcd32 firstalc32 firsttob32 firstmar32 firstdrg32 firstocd32 firstman32 firstscz32
					 firstint32 firstext32 firstthd32  firstdx32;
	array ph38f [18] firstgad38 firstmde38 firstfear38 firsteat38 firstptsd38 firstadhd38 firstcd38 firstalc38 firsttob38 firstmar38 firstdrg38 firstocd38 firstman38 firstscz38
					 firstint38 firstext38 firstthd38  firstdx38;
	array ph45f [18] firstgad45 firstmde45 firstfear45 firsteat45 firstptsd45 firstadhd45 firstcd45 firstalc45 firsttob45 firstmar45 firstdrg45 firstocd45 firstman45 firstscz45
					 firstint45 firstext45 firstthd45  firstdx45;

	do i = 1 to 7;
		* Collapse fears (Panic, agoraphobia, social, simple);
		if i > 1 and SUM(pad[i], agph[i], sop[i], sip[i])        > 0 then fear[i] = 1;
			else if i > 1 and N(pad[i], agph[i], sop[i], sip[i]) > 0 then fear[i] = 0;
		* Collapse eating disorders (anorexia/bulimia);
		if i in (2, 3, 4) and SUM(anr[i], bul[i])        > 0 then eat[i] = 1;
			else if i in (2, 3, 4) and N(anr[i], bul[i]) > 0 then eat[i] = 0;

		* Any anxiety (GAD + Fears);
		if i > 1 and SUM(gad[i], fear[i]) > 0 then aanx[i] = 1;
			else if i > 1 and N(gad[i], fear[i]) > 0 then aanx[i] = 0;

		* Internalizing;
		if SUM(gad[i], mde[i], fear[i], eat[i], ptsd[i])        > 0 then aint[i] = 1;
			else if N(gad[i], mde[i], fear[i], eat[i], ptsd[i]) > 0 then aint[i] = 0;

		intn[i] = SUM(gad[i], mde[i], fear[i], eat[i], ptsd[i]); 
		if N(gad[i], mde[i], fear[i], eat[i], ptsd[i]) = 0 then intn[i] = .;
		
		* Externalizing;
		if SUM(adhd[i], cd[i], alc[i], tob[i], mar[i], drg[i])        > 0 then aext[i] = 1;
			else if N(adhd[i], cd[i], alc[i], tob[i], mar[i], drg[i]) > 0 then aext[i] = 0;

		extn[i] = SUM(adhd[i], cd[i], alc[i], tob[i], mar[i], drg[i]); 
		if N(adhd[i], cd[i], alc[i], tob[i], mar[i], drg[i]) = 0 then extn[i] = .;

		* Thought Disorder;
		if SUM(ocd[i], man[i], scz[i])        > 0 then athd[i] = 1;
			else if N(ocd[i], man[i], scz[i]) > 0 then athd[i] = 0;

		thdn[i] = SUM(ocd[i], man[i], scz[i]); 
		if N(ocd[i], man[i], scz[i]) = 0 then thdn[i] = .;

		* Any dx;
		if SUM(aint[i], aext[i], athd[i])        > 0 then adx[i] = 1;
			else if N(aint[i], aext[i], athd[i]) > 0 then adx[i] = 0;

		dxn[i] = SUM(intn[i], extn[i], thdn[i]); 
		if N(intn[i], extn[i], thdn[i]) = 0 then dxn[i] = .;

		* Dx Type for Sankey Chart;
		if dead[i] = 1                            then dxty[i] = 0;		* Deceased;
			else if athd[i] =  1                  then dxty[i] = 1;		* Any thought disorder;
			else if aint[i] =  1 and aext[i] NE 1 then dxty[i] = 2;		* Internalizing only;
			else if aint[i] =  1 and aext[i] =  1 then dxty[i] = 3;		* Internalizing & Externalizing;
			else if aint[i] NE 1 and aext[i] =  1 then dxty[i] = 4;		* Externalizing only;
			else if adx[i]  =  0                  then dxty[i] = 5;		* No DX;
			else if dxty[i] = .                   then dxty[i] = 6;		* Missing;

		* Expanded Dx Type for Sankey Chart;
		if dead[i] = 1                                             then dxtp[i] =  0;	* Deceased;
			else if athd[i] =  1 and aint[i] =  1 and aext[i] =  1 then dxtp[i] =  1;	* Thought disorder w/ INT & EXT;
			else if athd[i] =  1 and aint[i] =  1 and aext[i] NE 1 then dxtp[i] =  2;	* Thought disorder w/ INT;
			else if athd[i] =  1 and aint[i] NE 1 and aext[i] =  1 then dxtp[i] =  3;	* Thought disorder w/ EXT;
			else if athd[i] NE 1 and aint[i] =  1 and aext[i] =  1 then dxtp[i] =  4;	* Internalizing & Externalizing;
			else if athd[i] =  1 and aint[i] NE 1 and aext[i] NE 1 then dxtp[i] =  5;	* Thought disorder only;
			else if athd[i] NE 1 and aint[i] =  1 and aext[i] NE 1 then dxtp[i] =  6;	* Internalizing only;
			else if athd[i] NE 1 and aint[i] NE 1 and aext[i] =  1 then dxtp[i] =  7;	* Externalizing only;
			else if adx[i]  =  0                                   then dxtp[i] =  9;	* No DX;			
			else if dxtp[i] = .                                    then dxtp[i] = 10;	* Missing;

		if dxtp[i] = 9 and i > 1 then do;
			if adx[i - 1] = 1 or dxtp[i - 1] = 8 then dxtp[i] = 8;  * Remitted DX;
		end;
	end;

	* "Fix" 2 SM's who died < 15, but have data from 12;
	if dxtype15 = 0 and anyint15 = 1 and anyext15 = 0 then dxtype15 = 2;
	if dxtype15 = 0 and anyint15 = 0 and anyext15 = 0 then dxtype15 = 5;

	if dxtype15a = 0 and anyint15 = 1 and anyext15 = 0 then dxtype15a = 6;
	if dxtype15a = 0 and anyint15 = 0 and anyext15 = 0 then dxtype15a = 9;

	do i = 1 to 18;

		* Create "Any" vars, collapsed across phases;
		if SUM(ph15a[i], ph18a[i], ph21a[i], ph26a[i], ph32a[i], ph38a[i], ph45a[i])        > 0 then ph_any[i] = 1;
			else if N(ph15a[i], ph18a[i], ph21a[i], ph26a[i], ph32a[i], ph38a[i], ph45a[i]) > 0 then ph_any[i] = 0;

		* Create "Sum" vars, collapsed across phases;
		ph_ph[i] = SUM(ph15a[i], ph18a[i], ph21a[i], ph26a[i], ph32a[i], ph38a[i], ph45a[i]);

		if 1 <= i >= 14 and N(ph15a[i], ph18a[i], ph21a[i], ph26a[i], ph32a[i], ph38a[i], ph45a[i]) = 0 then ph_ph[i] = .;
			else if i > 14 and ph_any[i] = 0 and N(ph15a[i], ph18a[i], ph21a[i], ph26a[i], ph32a[i], ph38a[i], ph45a[i]) = 0 then ph_ph[i] = .;

		* Find first dx age;
		if ph_any[i] ne . then do;
			if ph15a[i] = 1 then ph_ag1[i] = 1;
				else if ph_ag1[i] = . and ph18a[i] = 1 then ph_ag1[i] = 2;
				else if ph_ag1[i] = . and ph21a[i] = 1 then ph_ag1[i] = 3;
				else if ph_ag1[i] = . and ph26a[i] = 1 then ph_ag1[i] = 4;
				else if ph_ag1[i] = . and ph32a[i] = 1 then ph_ag1[i] = 5;
				else if ph_ag1[i] = . and ph38a[i] = 1 then ph_ag1[i] = 6;
				else if ph_ag1[i] = . and ph45a[i] = 1 then ph_ag1[i] = 7;

			if ph_ag1[i] = 1 then do;
				ph15f[i] = 1; ph18f[i] = 0; ph21f[i] = 0; ph26f[i] = 0; ph32f[i] = 0; ph38f[i] = 0; ph45f[i] = 0;
			end;
			if ph_ag1[i] = 2 then do;
				ph15f[i] = 0; ph18f[i] = 1; ph21f[i] = 0; ph26f[i] = 0; ph32f[i] = 0; ph38f[i] = 0; ph45f[i] = 0;
			end;
			if ph_ag1[i] = 3 then do;
				ph15f[i] = 0; ph18f[i] = 0; ph21f[i] = 1; ph26f[i] = 0; ph32f[i] = 0; ph38f[i] = 0; ph45f[i] = 0;
			end;
			if ph_ag1[i] = 4 then do;
				ph15f[i] = 0; ph18f[i] = 0; ph21f[i] = 0; ph26f[i] = 1; ph32f[i] = 0; ph38f[i] = 0; ph45f[i] = 0;
			end;
			if ph_ag1[i] = 5 then do;
				ph15f[i] = 0; ph18f[i] = 0; ph21f[i] = 0; ph26f[i] = 0; ph32f[i] = 1; ph38f[i] = 0; ph45f[i] = 0;
			end;
			if ph_ag1[i] = 6 then do;
				ph15f[i] = 0; ph18f[i] = 0; ph21f[i] = 0; ph26f[i] = 0; ph32f[i] = 0; ph38f[i] = 1; ph45f[i] = 0;
			end;
			if ph_ag1[i] = 7 then do;
				ph15f[i] = 0; ph18f[i] = 0; ph21f[i] = 0; ph26f[i] = 0; ph32f[i] = 0; ph38f[i] = 1; ph45f[i] = 0;
			end;
			if ph_any[i] = 0 then do;
				ph_ag1[i] = 0;
				ph15f[i]  = 0;
				ph18f[i]  = 0;
				ph21f[i]  = 0;
				ph26f[i]  = 0;
				ph32f[i]  = 0;
				ph38f[i]  = 0;
				ph45f[i]  = 0;
			end;
		end;

		* Determine lag from one dx to the next;
		if ph_ag1[i] = 1 then do;
			if ph18a[i] = 1 then ph_ag2[i] = 2;
				else if ph_ag2[i] = . and ph21a[i] = 1 then ph_ag2[i] = 3;
				else if ph_ag2[i] = . and ph26a[i] = 1 then ph_ag2[i] = 4;
				else if ph_ag2[i] = . and ph32a[i] = 1 then ph_ag2[i] = 5;
				else if ph_ag2[i] = . and ph38a[i] = 1 then ph_ag2[i] = 6;
				else if ph_ag2[i] = . and ph45a[i] = 1 then ph_ag2[i] = 7;
		end;
		else if ph_ag1[i] = 2 then do;
			if ph21a[i] = 1 then ph_ag2[i] = 3;
				else if ph_ag2[i] = . and ph26a[i] = 1 then ph_ag2[i] = 4;
				else if ph_ag2[i] = . and ph32a[i] = 1 then ph_ag2[i] = 5;
				else if ph_ag2[i] = . and ph38a[i] = 1 then ph_ag2[i] = 6;
				else if ph_ag2[i] = . and ph45a[i] = 1 then ph_ag2[i] = 7;
		end;
		else if ph_ag1[i] = 3 then do;
			if ph26a[i] = 1 then ph_ag2[i] = 4;
				else if ph_ag2[i] = . and ph32a[i] = 1 then ph_ag2[i] = 5;
				else if ph_ag2[i] = . and ph38a[i] = 1 then ph_ag2[i] = 6;
				else if ph_ag2[i] = . and ph45a[i] = 1 then ph_ag2[i] = 7;
		end;
		else if ph_ag1[i] = 4 then do;
			if ph32a[i] = 1 then ph_ag2[i] = 5;
				else if ph_ag2[i] = . and ph38a[i] = 1 then ph_ag2[i] = 6;
				else if ph_ag2[i] = . and ph45a[i] = 1 then ph_ag2[i] = 7;
		end;
		else if ph_ag1[i] = 5 then do;
			if ph38a[i] = 1 then ph_ag2[i] = 6;
				else if ph_ag2[i] = . and ph45a[i] = 1 then ph_ag2[i] = 7;
		end;
		else if ph_ag1[i] = 6 and ph45a[i] = 1 then ph_ag2[i] = 7;

		if ph_ag2[i] = . and N(ph15a[i], ph18a[i], ph21a[i], ph26a[i], ph32a[i], ph38a[i], ph45a[i]) > 0 then ph_ag2[i] = 0;

		ph_lag[i] = ph_ag2[i] - ph_ag1[i];
	end;

	* AnyAnx - Lifetime;
	if SUM(anyanx18, anyanx21, anyanx26, anyanx32, anyanx38, anyanx45)        > 0 then anyanx = 1;
		else if N(anyanx18, anyanx21, anyanx26, anyanx32, anyanx38, anyanx45) > 0 then anyanx = 0;

	* # Dx by phases;
	Ndx1518 = SUM(Ndx15, Ndx18);
	Ndx1521 = SUM(Ndx15, Ndx18, Ndx21);
	Ndx1526 = SUM(Ndx15, Ndx18, Ndx21, Ndx26);
	Ndx1532 = SUM(Ndx15, Ndx18, Ndx21, Ndx26, Ndx32);
	Ndx1538 = SUM(Ndx15, Ndx18, Ndx21, Ndx26, Ndx32, Ndx38);
	Ndx1545 = SUM(Ndx15, Ndx18, Ndx21, Ndx26, Ndx32, Ndx38, Ndx45);

	Ndx1545_trim = Ndx1545;
	if Ndx1545_trim > 25 then Ndx1545_trim = 25;

	Ndx1845 = SUM(Ndx18, Ndx21, Ndx26, Ndx32, Ndx38, Ndx45);
	Ndx2145 = SUM(       Ndx21, Ndx26, Ndx32, Ndx38, Ndx45);
	Ndx2645 = SUM(              Ndx26, Ndx32, Ndx38, Ndx45);
	Ndx3245 = SUM(                     Ndx32, Ndx38, Ndx45);
	Ndx3845 = SUM(                            Ndx38, Ndx45);

	* Dx-families over time;
	Nint1518 = SUM(anyint15, anyint18);
	Nint1521 = SUM(anyint15, anyint18, anyint21);
	Nint1526 = SUM(anyint15, anyint18, anyint21, anyint26);
	Nint1532 = SUM(anyint15, anyint18, anyint21, anyint26, anyint32);
	Nint1538 = SUM(anyint15, anyint18, anyint21, anyint26, anyint32, anyint38);
	Nint1545 = SUM(anyint15, anyint18, anyint21, anyint26, anyint32, anyint38, anyint45);

	Next1518 = SUM(anyext15, anyext18);
	Next1521 = SUM(anyext15, anyext18, anyext21);
	Next1526 = SUM(anyext15, anyext18, anyext21, anyext26);
	Next1532 = SUM(anyext15, anyext18, anyext21, anyext26, anyext32);
	Next1538 = SUM(anyext15, anyext18, anyext21, anyext26, anyext32, anyext38);
	Next1545 = SUM(anyext15, anyext18, anyext21, anyext26, anyext32, anyext38, anyext45);

	Nthd1821 = SUM(anythd18, anythd21);
	Nthd1826 = SUM(anythd18, anythd21, anythd26);
	Nthd1832 = SUM(anythd18, anythd21, anythd26, anythd32);
	Nthd1838 = SUM(anythd18, anythd21, anythd26, anythd32, anythd38);
	Nthd1845 = SUM(anythd18, anythd21, anythd26, anythd32, anythd38, anythd45);

	Nfam15 = 0; Nfam1518 = 0; Nfam1521 = 0; Nfam1526 = 0; Nfam1532 = 0; Nfam1538 = 0; Nfam1545 = 0;

	array ints [7] anyint15 Nint1518 Nint1521 Nint1526 Nint1532 Nint1538 Nint1545;
	array exts [7] anyext15 Next1518 Next1521 Next1526 Next1532 Next1538 Next1545;
	array thds [7] null     anythd18 Nthd1821 Nthd1826 Nthd1832 Nthd1838 Nthd1845;
	array Nfam [7] Nfam15   Nfam1518 Nfam1521 Nfam1526 Nfam1532 Nfam1538 Nfam1545;

	do i = 1 to 7;
		if ints[i] > 0 then Nfam[i] = Nfam[i] + 1;
		if exts[i] > 0 then Nfam[i] = Nfam[i] + 1;
		if thds[i] > 0 then Nfam[i] = Nfam[i] + 1;
		if N(ints[i], exts[i], thds[i]) = 0 then Nfam[i] = .;
	end;

	* Unique Dx over time;
	Ngad1518 = SUM(anx15, gad18);
	Ngad1521 = SUM(anx15, gad18, gad21);
	Ngad1526 = SUM(anx15, gad18, gad21, gad26);
	Ngad1532 = SUM(anx15, gad18, gad21, gad26, gad32);
	Ngad1538 = SUM(anx15, gad18, gad21, gad26, gad32, gad38);
	Ngad1545 = SUM(anx15, gad18, gad21, gad26, gad32, gad38, gad45);

	Nmde1518 = SUM(dep15, mde18);
	Nmde1521 = SUM(dep15, mde18, mde21);
	Nmde1526 = SUM(dep15, mde18, mde21, mde26);
	Nmde1532 = SUM(dep15, mde18, mde21, mde26, mde32);
	Nmde1538 = SUM(dep15, mde18, mde21, mde26, mde32, mde38);
	Nmde1545 = SUM(dep15, mde18, mde21, mde26, mde32, mde38, mde45);

	Nfear1821 = SUM(fear18, fear21);
	Nfear1826 = SUM(fear18, fear21, fear26);
	Nfear1832 = SUM(fear18, fear21, fear26, fear32);
	Nfear1838 = SUM(fear18, fear21, fear26, fear32, fear38);
	Nfear1845 = SUM(fear18, fear21, fear26, fear32, fear38, fear45);

	Neat1821 = SUM(eat18, eat21);
	Neat1826 = SUM(eat18, eat21, eat26);

	Nptsd2632 = SUM(ptsd26, ptsd32);
	Nptsd2638 = SUM(ptsd26, ptsd32, ptsd38);
	Nptsd2645 = SUM(ptsd26, ptsd32, ptsd38, ptsd45);


	Nadhd1518 = SUM(adhd15, adhd18);
	Nadhd1538 = SUM(adhd15, adhd18, adhd38);
	Nadhd1545 = SUM(adhd15, adhd18, adhd38, adhd45);

	Ncd1518 = SUM(cd15, cd18);
	Ncd1521 = SUM(cd15, cd18, cd21);
	Ncd1526 = SUM(cd15, cd18, cd21, cd26);
	Ncd1532 = SUM(cd15, cd18, cd21, cd26, cd32);
	Ncd1538 = SUM(cd15, cd18, cd21, cd26, cd32, cd38);
	Ncd1545 = SUM(cd15, cd18, cd21, cd26, cd32, cd38, cd45);

	Nalc1821 = SUM(alc18, alc21);
	Nalc1826 = SUM(alc18, alc21, alc26);
	Nalc1832 = SUM(alc18, alc21, alc26, alc32);
	Nalc1838 = SUM(alc18, alc21, alc26, alc32, alc38);
	Nalc1845 = SUM(alc18, alc21, alc26, alc32, alc38, alc45);

	Ntob1821 = SUM(tob18, tob21);
	Ntob1826 = SUM(tob18, tob21, tob26);
	Ntob1832 = SUM(tob18, tob21, tob26, tob32);
	Ntob1838 = SUM(tob18, tob21, tob26, tob32, tob38);
	Ntob1845 = SUM(tob18, tob21, tob26, tob32, tob38, tob45);

	Nmar1821 = SUM(mar18, mar21);
	Nmar1826 = SUM(mar18, mar21, mar26);
	Nmar1832 = SUM(mar18, mar21, mar26, mar32);
	Nmar1838 = SUM(mar18, mar21, mar26, mar32, mar38);
	Nmar1845 = SUM(mar18, mar21, mar26, mar32, mar38, mar45);

	Ndrg2632 = SUM(drg26, drg32);
	Ndrg2638 = SUM(drg26, drg32, drg38);
	Ndrg2645 = SUM(drg26, drg32, drg38, drg45);


	Nocd1821 = SUM(ocd18, ocd21);
	Nocd1826 = SUM(ocd18, ocd21, ocd26);
	Nocd1832 = SUM(ocd18, ocd21, ocd26, ocd32);
	Nocd1838 = SUM(ocd18, ocd21, ocd26, ocd32, ocd38);
	Nocd1845 = SUM(ocd18, ocd21, ocd26, ocd32, ocd38, ocd45);

	Nman2126 = SUM(man21, man26);
	Nman2132 = SUM(man21, man26, man32);
	Nman2138 = SUM(man21, man26, man32, man38);
	Nman2145 = SUM(man21, man26, man32, man38, man45);

	Nscz2126 = SUM(scz21, scz26);
	Nscz2132 = SUM(scz21, scz26, scz32);
	Nscz2138 = SUM(scz21, scz26, scz32, scz38);
	Nscz2145 = SUM(scz21, scz26, scz32, scz38, scz45);

	NUnDx15 = 0; NUnDx1518 = 0; NUnDx1521 = 0; NUnDx1526 = 0; NUnDx1532 = 0; NUnDx1538 = 0; NUnDx1545 = 0;

	array gads  [7] anx15  Ngad1518  Ngad1521  Ngad1526  Ngad1532  Ngad1538  Ngad1545;
	array mdes  [7] dep15  Nmde1518  Nmde1521  Nmde1526  Nmde1532  Nmde1538  Nmde1545;
	array fears [7] null   fear18    Nfear1821 Nfear1826 Nfear1832 Nfear1838 Nfear1845;
	array eats  [7] null   eat18     Neat1821  Neat1826  Neat1826  Neat1826  Neat1826;
	array ptsds [7] null   null      null      ptsd26    Nptsd2632 Nptsd2638 Nptsd2645;

	array adhds [7] adhd15 Nadhd1518 null      null      null      Nadhd1538 Nadhd1545;
	array cds   [7] cd15   Ncd1518   Ncd1521   Ncd1526   Ncd1532   Ncd1538   Ncd1545;
	array alcs  [7] null   alc18     Nalc1821  Nalc1826  Nalc1832  Nalc1838  Nalc1845;
	array tobs  [7] null   tob18     Ntob1821  Ntob1826  Ntob1832  Ntob1838  Ntob1845;
	array mars  [7] null   mar18     Nmar1821  Nmar1826  Nmar1832  Nmar1838  Nmar1845;
	array drgs  [7] null   null      null      drg26     Ndrg2632  Ndrg2638  Ndrg2645;

	array ocds  [7] null   ocd18     Nocd1821  Nocd1826  Nocd1832  Nocd1838  Nocd1845;
	array mans  [7] null   null      man21     Nman2126  Nman2132  Nman2138  Nman2145;
	array sczs  [7] null   null      scz21     Nscz2126  Nscz2132  Nscz2138  Nscz2145;

	array NUndx [7] NUnDx15  NUnDx1518 NUnDx1521 NUnDx1526 NUnDx1532 NUnDx1538 NUnDx1545;

	do i = 1 to 7;
		if gads  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if mdes  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if fears [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if eats  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if ptsds [i] > 0 then NUnDx[i] = NUnDx[i] + 1;

		if adhds [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if cds   [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if alcs  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if tobs  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if mars  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if drgs  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;

		if ocds  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if mans  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;
		if sczs  [i] > 0 then NUnDx[i] = NUnDx[i] + 1;

		if N(gads[i],  mdes[i], fears[i], eats[i], ptsds[i],
			 adhds[i], cds[i],  alcs[i],  tobs[i], mars[i], drgs[i],
			 ocds[i],  mans[i], sczs[i]) = 0 then NUnDx[i] = .;
	end;

	* # different types of dx (at diagnosis level);
	Ndxtypes1545 = SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz);
	*if Ndxtypes1545 > 5 then Ndxtypes1545 = 5;

	* # phases w/ dx;
	Ndxphases1545 = SUM(anydx15, anydx18, anydx21, anydx26, anydx32, anydx38, anydx45);

	* First dx type;
	if dxph1 = 1          then dxtype1 = dxtype15;
		else if dxph1 = 2 then dxtype1 = dxtype18;
		else if dxph1 = 3 then dxtype1 = dxtype21;
		else if dxph1 = 4 then dxtype1 = dxtype26;
		else if dxph1 = 5 then dxtype1 = dxtype32;
		else if dxph1 = 6 then dxtype1 = dxtype38;
		else if dxph1 = 7 then dxtype1 = dxtype45;
	* Ever dx type;
	if anythd =  1                              then everdxtype = 1;		* Any thought disorder;
		else if anyint     =  1 and anyext NE 1 then everdxtype = 2;		* Internalizing only;
		else if anyint     =  1 and anyext =  1 then everdxtype = 3;		* Internalizing & Externalizing;
		else if anyint     NE 1 and anyext =  1 then everdxtype = 4;		* Externalizing only;
		else if anydx      =  0                 then everdxtype = 5;		* No DX;
		else if everdxtype = .                  then everdxtype = 6;		* Missing;

	* Pure dx;
	if 			anygad  = 1 and SUM(        anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then puregad  = 1;
		else if anygad  = 1 and SUM(        anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then puregad  = 0;
	if 			anymde  = 1 and SUM(anygad,         anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then puremde  = 1;
		else if anymde  = 1 and SUM(anygad, 		anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then puremde  = 0;
	if 			anyfear = 1 and SUM(anygad, anymde,          anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then purefear = 1;
		else if anyfear = 1 and SUM(anygad, anymde,          anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then purefear = 0;
	if 			anyeat  = 1 and SUM(anygad, anymde, anyfear,         anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then pureeat  = 1;
		else if anyeat  = 1 and SUM(anygad, anymde, anyfear,         anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then pureeat  = 0;
	if 			anyptsd = 1 and SUM(anygad, anymde, anyfear, anyeat,          anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then pureptsd = 1;
		else if anyptsd = 1 and SUM(anygad, anymde, anyfear, anyeat,          anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then pureptsd = 0;
	if 			anyadhd = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd,          anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then pureadhd = 1;
		else if anyadhd = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd,          anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then pureadhd = 0;
	if 			anycd   = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd,        anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then purecd   = 1;
		else if anycd   = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd,        anyalc, anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then purecd   = 0;
	if 			anyalc  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd,         anytob, anymar, anydrg, anyocd, anyman, anyscz) = 0 then purealc  = 1;
		else if anyalc  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd,         anytob, anymar, anydrg, anyocd, anyman, anyscz) > 0 then purealc  = 0;
	if 			anytob  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc,         anymar, anydrg, anyocd, anyman, anyscz) = 0 then puretob  = 1;
		else if anytob  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc,         anymar, anydrg, anyocd, anyman, anyscz) > 0 then puretob  = 0;
	if 			anymar  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob,         anydrg, anyocd, anyman, anyscz) = 0 then puremar  = 1;
		else if anymar  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob,         anydrg, anyocd, anyman, anyscz) > 0 then puremar  = 0;
	if 			anydrg  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar,         anyocd, anyman, anyscz) = 0 then puredrg  = 1;
		else if anydrg  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar,         anyocd, anyman, anyscz) > 0 then puredrg  = 0;
	if 			anyocd  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg,         anyman, anyscz) = 0 then pureocd  = 1;
		else if anyocd  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg,         anyman, anyscz) > 0 then pureocd  = 0;
	if 			anyman  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd,         anyscz) = 0 then pureman  = 1;
		else if anyman  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd,         anyscz) > 0 then pureman  = 0;
	if 			anyscz  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman)         = 0 then purescz  = 1;
		else if anyscz  = 1 and SUM(anygad, anymde, anyfear, anyeat, anyptsd, anyadhd, anycd, anyalc, anytob, anymar, anydrg, anyocd, anyman)         > 0 then purescz  = 0;

	if anyint = 1 and SUM(anythd, anyext) = 0 then pureint = 1;
		else if anyint = 1 and SUM(anythd, anyext) > 0 then pureint = 0;
	if anyext = 1 and SUM(anyint, anythd) = 0 then pureext = 1;
		else if anyext = 1 and SUM(anyint, anythd) > 0 then pureext = 0;
	if anythd = 1 and SUM(anyint, anyext) = 0 then purethd = 1;
		else if anythd = 1 and SUM(anyint, anyext) > 0 then purethd = 0;

	* Remission?;
	if Ndx1545 = 0 then remit1 = -1;		
		else if anydx15 = 1 and SUM(anydx18, anydx21, anydx26, anydx32, anydx38, anydx45) > 0 then remit1 = 0;
		else if anydx18 = 1 and SUM(         anydx21, anydx26, anydx32, anydx38, anydx45) > 0 then remit1 = 0;
		else if anydx21 = 1 and SUM(                  anydx26, anydx32, anydx38, anydx45) > 0 then remit1 = 0;
		else if anydx26 = 1 and SUM(                           anydx32, anydx38, anydx45) > 0 then remit1 = 0;
		else if anydx32 = 1 and SUM(                                    anydx38, anydx45) > 0 then remit1 = 0;
		else if anydx38 = 1 and SUM(                                             anydx45) > 0 then remit1 = 0;
		else if Ndx1545 > 0 then remit1 = 1;

		* First dx at 45;
		if remit1 = 1 and anydx45 = 1 then remit1 = 2;

		* No more data after dx;
		if remit1 = 1 and anydx15 = 1 and N(anydx18, anydx21, anydx26, anydx32, anydx38, anydx45) = 0 then remit1 = 3;
		if remit1 = 1 and anydx18 = 1 and N(         anydx21, anydx26, anydx32, anydx38, anydx45) = 0 then remit1 = 3;
		if remit1 = 1 and anydx21 = 1 and N(                  anydx26, anydx32, anydx38, anydx45) = 0 then remit1 = 3;
		if remit1 = 1 and anydx26 = 1 and N(                           anydx32, anydx38, anydx45) = 0 then remit1 = 3;
		if remit1 = 1 and anydx32 = 1 and N(                                    anydx38, anydx45) = 0 then remit1 = 3;
		if remit1 = 1 and anydx38 = 1 and N(                                             anydx45) = 0 then remit1 = 3;

	* # Phases between Int/Ext/Thd and next Int/Ext/Thd;
	array tyty  [9] intintph2 intextph2 intthdph2 extintph2 extextph2 extthdph2 thdintph2 thdextph2 thdthdph2;
	array ty    [3] intph1   extph1   thdph1;
	array ph18b [3] anyint18 anyext18 anythd18; 
	array ph21b [3] anyint21 anyext21 anythd21;
	array ph26b [3] anyint26 anyext26 anythd26;
	array ph32b [3] anyint32 anyext32 anythd32;
	array ph38b [3] anyint38 anyext38 anythd38;
	array ph45b [3] anyint45 anyext45 anythd45;
	
	do i = 1 to 3;
		do j = 1 to 3;
			if i = 1 and j = 1 then k = 1;
				else k = k + 1;

			if ty[i] = 1 then do;
				if ph18b[j] = 1 then tyty[k] = 2;
					else if tyty[k] = . and ph21b[j] = 1 then tyty[k] = 3;
					else if tyty[k] = . and ph26b[j] = 1 then tyty[k] = 4;
					else if tyty[k] = . and ph32b[j] = 1 then tyty[k] = 5;
					else if tyty[k] = . and ph38b[j] = 1 then tyty[k] = 6;
					else if tyty[k] = . and ph45b[j] = 1 then tyty[k] = 7;
			end;
			else if ty[i] = 2 then do;
				if ph21b[j] = 1 then tyty[k] = 3;
					else if tyty[k] = . and ph26b[j] = 1 then tyty[k] = 4;
					else if tyty[k] = . and ph32b[j] = 1 then tyty[k] = 5;
					else if tyty[k] = . and ph38b[j] = 1 then tyty[k] = 6;
					else if tyty[k] = . and ph45b[j] = 1 then tyty[k] = 7;
			end;
			else if ty[i] = 3 then do;
				if ph26b[j] = 1 then tyty[k] = 4;
					else if tyty[k] = . and ph32b[j] = 1 then tyty[k] = 5;
					else if tyty[k] = . and ph38b[j] = 1 then tyty[k] = 6;
					else if tyty[k] = . and ph45b[j] = 1 then tyty[k] = 7;
			end;
			else if ty[i] = 4 then do;
				if ph32b[j] = 1 then tyty[k] = 5;
					else if tyty[k] = . and ph38b[j] = 1 then tyty[k] = 6;
					else if tyty[k] = . and ph45b[j] = 1 then tyty[k] = 7;
			end;
			else if ty[i] = 5 then do;
				if ph38b[j] = 1 then tyty[k] = 6;
				else if tyty[k] = . and ph45b[j] = 1 then tyty[k] = 7;
			end;
			else if ty[i] = 6 and ph45b[j] = 1 then tyty[k] = 7;
		end;
	end;

	* Lag between phases;
	intintlag = intintph2 - intph1;
	intextlag = intextph2 - intph1;
	intthdlag = intthdph2 - intph1;
	extintlag = extintph2 - extph1;
	extextlag = extextph2 - extph1;
	extthdlag = extthdph2 - extph1;
	thdintlag = thdintph2 - thdph1;
	thdextlag = thdextph2 - thdph1;
	thdthdlag = thdthdph2 - thdph1;

	* Yes/No transitions;
	if anyint = 1 then do;
		intint = 0; intext = 0; intthd = 0;
		if intintph2 > 0 then intint = 1;
		if intextph2 > 0 then intext = 1;
		if intthdph2 > 0 then intthd = 1;
	end;
	if anyext = 1 then do;
		extint = 0; extext = 0; extthd = 0;
		if extintph2 > 0 then extint = 1;
		if extextph2 > 0 then extext = 1;
		if extthdph2 > 0 then extthd = 1;
	end;
	if anythd = 1 then do;
		thdint = 0; thdext = 0; thdthd = 0;
		if thdintph2 > 0 then thdint = 1;
		if thdextph2 > 0 then thdext = 1;
		if thdthdph2 > 0 then thdthd = 1;
	end;

	* Subsequent Phases w/ INT;
	if SUM(anyint18, anyint21, anyint26, anyint32, anyint38, anyint45) > 1 then anyint1845 = 1; else anyint1845 = 0;
	if SUM(          anyint21, anyint26, anyint32, anyint38, anyint45) > 1 then anyint2145 = 1; else anyint2145 = 0;
	if SUM(                    anyint26, anyint32, anyint38, anyint45) > 1 then anyint2645 = 1; else anyint2645 = 0;
	if SUM(                              anyint32, anyint38, anyint45) > 1 then anyint3245 = 1; else anyint3245 = 0;
	if SUM(                                        anyint38, anyint45) > 1 then anyint3845 = 1; else anyint3845 = 0;

	* Subsequent Phases w/ EXT;
	if SUM(anyext18, anyext21, anyext26, anyext32, anyext38, anyext45) > 1 then anyext1845 = 1; else anyext1845 = 0;
	if SUM(          anyext21, anyext26, anyext32, anyext38, anyext45) > 1 then anyext2145 = 1; else anyext2145 = 0;
	if SUM(                    anyext26, anyext32, anyext38, anyext45) > 1 then anyext2645 = 1; else anyext2645 = 0;
	if SUM(                              anyext32, anyext38, anyext45) > 1 then anyext3245 = 1; else anyext3245 = 0;
	if SUM(                                        anyext38, anyext45) > 1 then anyext3845 = 1; else anyext3845 = 0;

	* Subsequent Phases w/ THD;
	if SUM(anythd18, anythd21, anythd26, anythd32, anythd38, anythd45) > 1 then anythd1845 = 1; else anythd1845 = 0;
	if SUM(          anythd21, anythd26, anythd32, anythd38, anythd45) > 1 then anythd2145 = 1; else anythd2145 = 0;
	if SUM(                    anythd26, anythd32, anythd38, anythd45) > 1 then anythd2645 = 1; else anythd2645 = 0;
	if SUM(                              anythd32, anythd38, anythd45) > 1 then anythd3245 = 1; else anythd3245 = 0;
	if SUM(                                        anythd38, anythd45) > 1 then anythd3845 = 1; else anythd3845 = 0;


	* Prep for correlations;
	* ... "No dx" moves to "high" end of first-dx-age;
	* ... "No dx" set to missing for N-dx, N-dx-types;
	ao = dxph1;
	if ao = 0 then ao = 8;

	Ndxphases1545_no0 = Ndxphases1545;
	if Ndxphases1545_no0 = 0 then Ndxphases1545_no0 = .;

	Ndxtypes1545_no0 = Ndxtypes1545;
	if Ndxtypes1545_no0 = 0 then Ndxtypes1545_no0 = .;

	* Drop vars that are not possible given available data;
	drop	i j k
			anythd15    Nthd15      firstthd15
			firstfear15 firsteat15  firstptsd15 firstalc15 firsttob15 firstmar15 firstdrg15 firstocd15 firstman15 firstscz15
			firstptsd18 firstdrg18  firstman18  firstscz18
			firstptsd21 firstadhd21 firstdrg21
			firstadhd26
			firsteat32  firstadhd32
			firsteat38
			firsteat45;
run;

* Sankey freqs;
* Flip data for R Sankey, v2;
data dxtype_phase;
	set MH_1;

	null = .;
	age15 = 1; age18 = 2; age21 = 3; age26 = 4; age32 = 5; age38 = 6; age45 = 7;

	array ph   [7] age15     age18     age21     age26     age32     age38     age45;
	array dxt  [7] dxtype15a dxtype18a dxtype21a dxtype26a dxtype32a dxtype38a dxtype45a;
	array dxt1 [7] dxtype18a dxtype21a dxtype26a dxtype32a dxtype38a dxtype45a null;

	do i = 1 to 7;
		phase    = ph[i];
		dxtype_1 = dxt[i];
		dxtype_2 = dxt1[i];

		output;
	end;

	keep snum phase dxtype_1 dxtype_2 EHC_NHSPsyHos2045;
run;

* Recode dxtype;
data dxtype_phase;
	set dxtype_phase;

	if dxtype_1 = 0 then dxtype1 = 10;				* Deceased;
		else if dxtype_1 =  1 then dxtype1 = 8;		* THD & INT & EXT;
		else if dxtype_1 =  2 then dxtype1 = 7;		* THD & INT;
		else if dxtype_1 =  3 then dxtype1 = 6;		* THD & EXT;
		else if dxtype_1 =  4 then dxtype1 = 5;		* INT & EXT;
		else if dxtype_1 =  5 then dxtype1 = 4;		* THD;
		else if dxtype_1 =  6 then dxtype1 = 3;		* INT;
		else if dxtype_1 =  7 then dxtype1 = 2;		* EXT;
		else if dxtype_1 =  8 then dxtype1 = 1;		* Remitted;
		else if dxtype_1 =  9 then dxtype1 = 0;		* No Dx;
		else if dxtype_1 = 10 then dxtype1 = 9;		* Missing;

	if dxtype_2 = 0 then dxtype2 = 10;
		else if dxtype_2 =  1 then dxtype2 = 8;
		else if dxtype_2 =  2 then dxtype2 = 7;
		else if dxtype_2 =  3 then dxtype2 = 6;
		else if dxtype_2 =  4 then dxtype2 = 5;
		else if dxtype_2 =  5 then dxtype2 = 4;
		else if dxtype_2 =  6 then dxtype2 = 3;
		else if dxtype_2 =  7 then dxtype2 = 2;
		else if dxtype_2 =  8 then dxtype2 = 1;
		else if dxtype_2 =  9 then dxtype2 = 0;
		else if dxtype_2 = 10 then dxtype2 = 9;
run;

proc freq data = dxtype_phase;
	table phase*dxtype1*dxtype2;
	format dxtype1 dxtype2 DXTY.;
	ods output CrossTabFreqs = backward_all;
run;

data backward_allA;
	set backward_all;

	length dxty1 dxty2 $15;

	if dxtype1 = 0 then dxty1 = 'Undiagnosed';
		else if dxtype1 =  1 then dxty1 = 'Remitted';
		else if dxtype1 =  2 then dxty1 = 'Ext';
		else if dxtype1 =  3 then dxty1 = 'Int';
		else if dxtype1 =  4 then dxty1 = 'Thd';
		else if dxtype1 =  5 then dxty1 = 'Int+Ext';
		else if dxtype1 =  6 then dxty1 = 'Thd+Ext';
		else if dxtype1 =  7 then dxty1 = 'Thd+Int';
		else if dxtype1 =  8 then dxty1 = 'Thd+Int+Ext';
		else if dxtype1 =  9 then dxty1 = 'Missing';
		else if dxtype1 = 10 then dxty1 = 'Deceased';
	if dxtype2 = 0 then dxty2 = 'Undiagnosed';
		else if dxtype2 =  1 then dxty2 = 'Remitted';
		else if dxtype2 =  2 then dxty2 = 'Ext';
		else if dxtype2 =  3 then dxty2 = 'Int';
		else if dxtype2 =  4 then dxty2 = 'Thd';
		else if dxtype2 =  5 then dxty2 = 'Int+Ext';
		else if dxtype2 =  6 then dxty2 = 'Thd+Ext';
		else if dxtype2 =  7 then dxty2 = 'Thd+Int';
		else if dxtype2 =  8 then dxty2 = 'Thd+Int+Ext';
		else if dxtype2 =  9 then dxty2 = 'Missing';
		else if dxtype2 = 10 then dxty2 = 'Deceased';

	if frequency = 0 then delete;
	if dxtype1   = . then delete;
	if dxtype2   = . then delete;

	if phase = 1 then do;								* Age 15 to Age 18;
		if dxtype1 = 0 then dxtype1 = 0;
			else if dxtype1 =  2 then dxtype1 = 1;
			else if dxtype1 =  3 then dxtype1 = 2;
			else if dxtype1 =  5 then dxtype1 = 3;
			else if dxtype1 =  9 then dxtype1 = 4;
			else if dxtype1 = 10 then dxtype1 = 5;
		if dxtype2 = 0 then dxtype2 = 6;
			else if dxtype2 =  1 then dxtype2 =  7;
			else if dxtype2 =  2 then dxtype2 =  8;
			else if dxtype2 =  3 then dxtype2 =  9;
			else if dxtype2 =  4 then dxtype2 = 10;
			else if dxtype2 =  5 then dxtype2 = 11;
			else if dxtype2 =  6 then dxtype2 = 12;
			else if dxtype2 =  7 then dxtype2 = 13;
			else if dxtype2 =  8 then dxtype2 = 14;
			else if dxtype2 =  9 then dxtype2 = 15;
			else if dxtype2 = 10 then dxtype2 = 16;
	end;
	if phase = 2 then do;								* Age 18 to Age 21;
		if dxtype1 = 0 then dxtype1 = 6;
			else if dxtype1 =  1 then dxtype1 =  7;
			else if dxtype1 =  2 then dxtype1 =  8;
			else if dxtype1 =  3 then dxtype1 =  9;
			else if dxtype1 =  4 then dxtype1 = 10;
			else if dxtype1 =  5 then dxtype1 = 11;
			else if dxtype1 =  6 then dxtype1 = 12;
			else if dxtype1 =  7 then dxtype1 = 13;
			else if dxtype1 =  8 then dxtype1 = 14;
			else if dxtype1 =  9 then dxtype1 = 15;
			else if dxtype1 = 10 then dxtype1 = 16;
		if dxtype2 = 0 then dxtype2 = 17;
			else if dxtype2 =  1 then dxtype2 = 18;
			else if dxtype2 =  2 then dxtype2 = 19;
			else if dxtype2 =  3 then dxtype2 = 20;
			else if dxtype2 =  4 then dxtype2 = 21;
			else if dxtype2 =  5 then dxtype2 = 22;
			else if dxtype2 =  6 then dxtype2 = 23;
			else if dxtype2 =  7 then dxtype2 = 24;
			else if dxtype2 =  8 then dxtype2 = 25;
			else if dxtype2 =  9 then dxtype2 = 26;
			else if dxtype2 = 10 then dxtype2 = 27;
	end;
	if phase = 3 then do;								* Age 21 to Age 26;
		if dxtype1 = 0 then dxtype1 = 17;
			else if dxtype1 =  1 then dxtype1 = 18;
			else if dxtype1 =  2 then dxtype1 = 19;
			else if dxtype1 =  3 then dxtype1 = 20;
			else if dxtype1 =  4 then dxtype1 = 21;
			else if dxtype1 =  5 then dxtype1 = 22;
			else if dxtype1 =  6 then dxtype1 = 23;
			else if dxtype1 =  7 then dxtype1 = 24;
			else if dxtype1 =  8 then dxtype1 = 25;
			else if dxtype1 =  9 then dxtype1 = 26;
			else if dxtype1 = 10 then dxtype1 = 27;
		if dxtype2 = 0 then dxtype2 = 28;
			else if dxtype2 =  1 then dxtype2 = 29;
			else if dxtype2 =  2 then dxtype2 = 30;
			else if dxtype2 =  3 then dxtype2 = 31;
			else if dxtype2 =  4 then dxtype2 = 32;
			else if dxtype2 =  5 then dxtype2 = 33;
			else if dxtype2 =  6 then dxtype2 = 34;
			else if dxtype2 =  7 then dxtype2 = 35;
			else if dxtype2 =  8 then dxtype2 = 36;
			else if dxtype2 =  9 then dxtype2 = 37;
			else if dxtype2 = 10 then dxtype2 = 38;
	end;
	if phase = 4 then do;								* Age 26 to Age 32;
		if dxtype1 = 0 then dxtype1 = 28;
			else if dxtype1 =  1 then dxtype1 = 29;
			else if dxtype1 =  2 then dxtype1 = 30;
			else if dxtype1 =  3 then dxtype1 = 31;
			else if dxtype1 =  4 then dxtype1 = 32;
			else if dxtype1 =  5 then dxtype1 = 33;
			else if dxtype1 =  6 then dxtype1 = 34;
			else if dxtype1 =  7 then dxtype1 = 35;
			else if dxtype1 =  8 then dxtype1 = 36;
			else if dxtype1 =  9 then dxtype1 = 37;
			else if dxtype1 = 10 then dxtype1 = 38;
		if dxtype2 = 0 then dxtype2 = 39;
			else if dxtype2 =  1 then dxtype2 = 40;
			else if dxtype2 =  2 then dxtype2 = 41;
			else if dxtype2 =  3 then dxtype2 = 42;
			else if dxtype2 =  4 then dxtype2 = 43;
			else if dxtype2 =  5 then dxtype2 = 44;
			else if dxtype2 =  6 then dxtype2 = 45;
			else if dxtype2 =  7 then dxtype2 = 46;
			else if dxtype2 =  8 then dxtype2 = 47;
			else if dxtype2 =  9 then dxtype2 = 48;
			else if dxtype2 = 10 then dxtype2 = 49;
	end;
	if phase = 5 then do;								* Age 32 to Age 38;
		if dxtype1 = 0 then dxtype1 = 39;
			else if dxtype1 =  1 then dxtype1 = 40;
			else if dxtype1 =  2 then dxtype1 = 41;
			else if dxtype1 =  3 then dxtype1 = 42;
			else if dxtype1 =  4 then dxtype1 = 43;
			else if dxtype1 =  5 then dxtype1 = 44;
			else if dxtype1 =  6 then dxtype1 = 45;
			else if dxtype1 =  7 then dxtype1 = 46;
			else if dxtype1 =  8 then dxtype1 = 47;
			else if dxtype1 =  9 then dxtype1 = 48;
			else if dxtype1 = 10 then dxtype1 = 49;
		if dxtype2 = 0 then dxtype2 = 50;
			else if dxtype2 =  1 then dxtype2 = 51;
			else if dxtype2 =  2 then dxtype2 = 52;
			else if dxtype2 =  3 then dxtype2 = 53;
			else if dxtype2 =  4 then dxtype2 = 54;
			else if dxtype2 =  5 then dxtype2 = 55;
			else if dxtype2 =  6 then dxtype2 = 56;
			else if dxtype2 =  7 then dxtype2 = 57;
			else if dxtype2 =  8 then dxtype2 = 58;
			else if dxtype2 =  9 then dxtype2 = 59;
			else if dxtype2 = 10 then dxtype2 = 60;
	end;
	if phase = 6 then do;								* Age 32 to Age 38;
		if dxtype1 = 0 then dxtype1 = 50;
			else if dxtype1 =  1 then dxtype1 = 51;
			else if dxtype1 =  2 then dxtype1 = 52;
			else if dxtype1 =  3 then dxtype1 = 53;
			else if dxtype1 =  4 then dxtype1 = 54;
			else if dxtype1 =  5 then dxtype1 = 55;
			else if dxtype1 =  6 then dxtype1 = 56;
			else if dxtype1 =  7 then dxtype1 = 57;
			else if dxtype1 =  8 then dxtype1 = 58;
			else if dxtype1 =  9 then dxtype1 = 59;
			else if dxtype1 = 10 then dxtype1 = 60;
		if dxtype2 = 0 then dxtype2 = 61;
			else if dxtype2 =  1 then dxtype2 = 62;
			else if dxtype2 =  2 then dxtype2 = 63;
			else if dxtype2 =  3 then dxtype2 = 64;
			else if dxtype2 =  4 then dxtype2 = 65;
			else if dxtype2 =  5 then dxtype2 = 66;
			else if dxtype2 =  6 then dxtype2 = 67;
			else if dxtype2 =  7 then dxtype2 = 68;
			else if dxtype2 =  8 then dxtype2 = 69;
			else if dxtype2 =  9 then dxtype2 = 70;
			else if dxtype2 = 10 then dxtype2 = 71;
	end;

	format dxtype1 dxtype2;

	keep phase dxtype1 dxtype2 dxty1 dxty2 frequency;
run;

proc sort data = backward_allA out = backwardA1_sortd; by dxtype1; run;
proc sort data = backward_allA out = backwardA2_sortd; by dxtype2; run;
data backward1_names;
	set backwardA1_sortd (rename = (dxty1 = dxty));
	by dxtype1;
	if first.dxtype1;

	dxtype = dxtype1;
	keep dxtype dxty;
run;
data backward2_names;
	set backwardA2_sortd (rename = (dxty2 = dxty));
	by dxtype2;
	if first.dxtype2;
	dxtype = dxtype2;
	keep dxtype dxty;
run;
data backward_names;
	set backward1_names backward2_names;
run;
proc sort data = backward_names NODUPKEY; by dxtype; run;


proc export data = backward_allA
	outfile = 'C:\Users\rh93\Box\Duke_DPPPlab\Renate2015\2024_ThreeReasons\Dunedin\Dunedin_Output_Mar25\backwardAll_June2019.csv'
	dbms = csv replace;
run;
proc export data = backward_names
	outfile = 'C:\Users\rh93\Box\Duke_DPPPlab\Renate2015\2024_ThreeReasons\Dunedin\Dunedin_Output_Mar25\backwardNames_June2019.csv'
	dbms = csv replace;
run;


* Figure S7 ... Venn Diagrams/concurrent comorbidity;
proc freq data = MH_1;
	table anyint15*anyext15 / list missing;
proc freq data = MH_1;
	table anyint18*anyext18*anythd18 / list missing;
proc freq data = MH_1;
	table anyint21*anyext21*anythd21 / list missing;
proc freq data = MH_1;
	table anyint26*anyext26*anythd26 / list missing;
proc freq data = MH_1;
	table anyint32*anyext32*anythd32 / list missing;
proc freq data = MH_1;
	table anyint38*anyext38*anythd38 / list missing;
proc freq data = MH_1;
	table anyint45*anyext45*anythd45 / list missing;
run;

* Table S1 ... OR's for concurrent comorbidity;
* Age 15;
proc logistic data = MH_1 descending;
	model anyint15 = anyext15;
run;
* Age 18;
proc logistic data = MH_1 descending;
	model anyint18 = anyext18;
proc logistic data = MH_1 descending;
	model anyint18 = anythd18;
proc logistic data = MH_1 descending;
	model anyext18 = anythd18;
run;
* Age 21;
proc logistic data = MH_1 descending;
	model anyint21 = anyext21;
proc logistic data = MH_1 descending;
	model anyint21 = anythd21;
proc logistic data = MH_1 descending;
	model anyext21 = anythd21;
run;
* Age 26;
proc logistic data = MH_1 descending;
	model anyint26 = anyext26;
proc logistic data = MH_1 descending;
	model anyint26 = anythd26;
proc logistic data = MH_1 descending;
	model anyext26 = anythd26;
run;
* Age 32;
proc logistic data = MH_1 descending;
	model anyint32 = anyext32;
proc logistic data = MH_1 descending;
	model anyint32 = anythd32;
proc logistic data = MH_1 descending;
	model anyext32 = anythd32;
run;
* Age 38;
proc logistic data = MH_1 descending;
	model anyint38 = anyext38;
proc logistic data = MH_1 descending;
	model anyint38 = anythd38;
proc logistic data = MH_1 descending;
	model anyext38 = anythd38;
run;
* Age 45;
proc logistic data = MH_1 descending;
	model anyint45 = anyext45;
proc logistic data = MH_1 descending;
	model anyint45 = anythd45;
proc logistic data = MH_1 descending;
	model anyext45 = anythd45;
run;

* Figure S8 ... Sequential Comorbidity;
* Flip data to allow cross time estimates;
data crosstime;
	set MH_1;

	age15 = 1; age18 = 2; age21 = 3; age26 = 4; age32 = 5; age38 = 6;
	null  = .;

	array ph   [6] age15      age18      age21      age26      age32      age38;
	array in1  [6] anyint15   anyint18   anyint21   anyint26   anyint32   anyint38;
	array in2  [6] firstint15 firstint18 firstint21 firstint26 firstint32 firstint38;
	array in3  [6] anyext15   anyext18   anyext21   anyext26   anyext32   anyext38;
	array in4  [6] firstext15 firstext18 firstext21 firstext26 firstext32 firstext38;
	array in5  [6] null       anythd18   anythd21   anythd26   anythd32   anythd38;
	array in6  [6] null       firstthd18 firstthd21 firstthd26 firstthd32 firstthd38;
	
	array out1 [6] anyint1845 anyint2145 anyint2645 anyint3245 anyint3845 anyint45;
	array out2 [6] anyext1845 anyext2145 anyext2645 anyext3245 anyext3845 anyext45;
	array out3 [6] anythd1845 anythd2145 anythd2645 anythd3245 anythd3845 anythd45;

	do i = 1 to 6;
		phase    = ph[i];

		anyint   = in1[i];
		firstint = in2[i];
		anyext   = in3[i];
		firstext = in4[i];
		anythd   = in5[i];
		firstthd = in6[i];
		
		laterint = out1[i];
		laterext = out2[i];
		laterthd = out3[i];
		output;
	end;

	keep snum phase anyint firstint anyext firstext anythd firstthd laterint laterext laterthd;
run;

proc freq data = crosstime;
	table phase*laterint*anyint / list missing;
	table phase*laterext*anyint / list missing;
	table phase*laterthd*anyint / list missing;

	table phase*laterint*anyext / list missing;
	table phase*laterext*anyext / list missing;
	table phase*laterthd*anyext / list missing;

	table phase*laterint*anythd / list missing;
	table phase*laterext*anythd / list missing;
	table phase*laterthd*anythd / list missing;
run;

proc genmod data = crosstime;
	class snum phase;
	model laterint = anyint phase anyint*phase / dist = poisson link = log;
	estimate 'RR' anyint 1 / exp;
	repeated subject = snum(phase) / type = unstr;
proc genmod data = crosstime;
	class snum phase;
	model laterext = anyint phase anyint*phase / dist = poisson link = log;
	estimate 'RR' anyint 1 / exp;
	repeated subject = snum(phase) / type = unstr;
proc genmod data = crosstime;
	class snum phase;
	model laterthd = anyint phase anyint*phase / dist = poisson link = log;
	estimate 'RR' anyint 1 / exp;
	repeated subject = snum(phase) / type = unstr;
run;

proc genmod data = crosstime;
	class snum phase;
	model laterint = anyext phase anyext*phase / dist = poisson link = log;
	estimate 'RR' anyext 1 / exp;
	repeated subject = snum(phase) / type = unstr;
proc genmod data = crosstime;
	class snum phase;
	model laterext = anyext phase anyext*phase / dist = poisson link = log;
	estimate 'RR' anyext 1 / exp;
	repeated subject = snum(phase) / type = unstr;
proc genmod data = crosstime;
	class snum phase;
	model laterthd = anyext phase anyext*phase / dist = poisson link = log;
	estimate 'RR' anyext 1 / exp;
	repeated subject = snum(phase) / type = unstr;
run;

proc genmod data = crosstime;
	class snum phase;
	model laterint = anythd phase anythd*phase / dist = poisson link = log;
	estimate 'RR' anythd 1 / exp;
	repeated subject = snum(phase) / type = unstr;
proc genmod data = crosstime;
	class snum phase;
	model laterext = anythd phase anythd*phase / dist = poisson link = log;
	estimate 'RR' anythd 1 / exp;
	repeated subject = snum(phase) / type = unstr;
proc genmod data = crosstime;
	class snum phase;
	model laterthd = anythd phase anythd*phase / dist = poisson link = log;
	estimate 'RR' anythd 1 / exp;
	repeated subject = snum(phase) / type = unstr;
run;

* Figure S5;
data MH_2;
	set MH_1;

	* Create depression/alcohol, vs other, vs none @ 18, 21, 26, 32;
	if mde18 = 1 then dep_grp18 = 2;
		else if mde18 = 0 and SUM(gad18, fear18, eat18, adhd18, cd18, alc18, tob18, mar18, ocd18) > 0 then dep_grp18 = 1;
		else if mde18 = 0 and SUM(gad18, fear18, eat18, adhd18, cd18, alc18, tob18, mar18, ocd18) = 0 then dep_grp18 = 0;

	if mde21 = 1 then dep_grp21 = 2;
		else if mde21 = 0 and SUM(gad21, fear21, eat21, cd21, alc21, tob21, mar21, ocd21, man21, scz21) > 0 then dep_grp21 = 1;
		else if mde21 = 0 and SUM(gad21, fear21, eat21, cd21, alc21, tob21, mar21, ocd21, man21, scz21) = 0 then dep_grp21 = 0;

	if mde26 = 1 then dep_grp26 = 2;
		else if mde26 = 0 and SUM(gad26, fear26, eat26, ptsd26, cd26, alc26, tob26, mar26, drg26, ocd26, man26, scz26) > 0 then dep_grp26 = 1;
		else if mde26 = 0 and SUM(gad26, fear26, eat26, ptsd26, cd26, alc26, tob26, mar26, drg26, ocd26, man26, scz26) = 0 then dep_grp26 = 0;

	if mde32 = 1 then dep_grp32 = 2;
		else if mde32 = 0 and SUM(gad32, fear32, ptsd32, cd32, alc32, tob32, mar32, drg32, ocd32, man32, scz32) > 0 then dep_grp32 = 1;
		else if mde32 = 0 and SUM(gad32, fear32, ptsd32, cd32, alc32, tob32, mar32, drg32, ocd32, man32, scz32) = 0 then dep_grp32 = 0;


	if alc18 = 1 then alc_grp18 = 2;
		else if alc18 = 0 and SUM(gad18, mde18, fear18, eat18, adhd18, cd18, tob18, mar18, ocd18) > 0 then alc_grp18 = 1;
		else if alc18 = 0 and SUM(gad18, mde18, fear18, eat18, adhd18, cd18, tob18, mar18, ocd18) = 0 then alc_grp18 = 0;

	if alc21 = 1 then alc_grp21 = 2;
		else if alc21 = 0 and SUM(gad21, mde21, fear21, eat21, cd21, tob21, mar21, ocd21, man21, scz21) > 0 then alc_grp21 = 1;
		else if alc21 = 0 and SUM(gad21, mde21, fear21, eat21, cd21, tob21, mar21, ocd21, man21, scz21) = 0 then alc_grp21 = 0;

	if alc26 = 1 then alc_grp26 = 2;
		else if alc26 = 0 and SUM(gad26, mde26, fear26, eat26, ptsd26, cd26, tob26, mar26, drg26, ocd26, man26, scz26) > 0 then alc_grp26 = 1;
		else if alc26 = 0 and SUM(gad26, mde26, fear26, eat26, ptsd26, cd26, tob26, mar26, drg26, ocd26, man26, scz26) = 0 then alc_grp26 = 0;

	if alc32 = 1 then alc_grp32 = 2;
		else if alc32 = 0 and SUM(gad32, mde32, fear32, ptsd32, cd32, tob32, mar32, drg32, ocd32, man32, scz32) > 0 then alc_grp32 = 1;
		else if alc32 = 0 and SUM(gad32, mde32, fear32, ptsd32, cd32, tob32, mar32, drg32, ocd32, man32, scz32) = 0 then alc_grp32 = 0;
run;

proc freq data = MH_2;
	table dep_grp21 dep_grp26 dep_grp32;
	where mde18 = 1;
proc freq data = MH_2;
	table dep_grp26 dep_grp32;
	where mde21 = 1;
proc freq data = MH_2;
	table dep_grp32;
	where mde26 = 1;
run;

proc freq data = MH_2;
	table alc_grp21 alc_grp26 alc_grp32;
	where alc18 = 1;
proc freq data = MH_2;
	table alc_grp26 alc_grp32;
	where alc21 = 1;
proc freq data = MH_2;
	table alc_grp32;
	where alc26 = 1;
run;

proc freq data = MH_1;
	* No pure drug, mania, schizophrenia;
	*table puregad puremde purefear pureeat pureptsd pureadhd purecd purealc puretob puremar puredrg pureocd pureman purescz;
	table (puregad puremde purefear pureeat pureptsd pureadhd purecd purealc puretob puremar pureocd)*Ndxphases1545 / list missing;
run;
