
********************************************************************************
* MASTER DO-FILE:
* WHY PSYCHOPATHOLOGY RESEARCHERS SHOULD AVOID STUDYING ONE MENTAL DSIORDER AT A TIME
* DANISH RESULTS
* BY ANNE SOFIE TEGNER ANKER
********************************************************************************



*----------------------------- SETTINGS ----------------------------------------*


clear all

capture log close

set more off

set type double

set seed 42726878

** Figure template
set scheme lean1

*----------------------------- GLOBALS ----------------------------------------*

** Shortcuts
global dd100 "E:\Data\rawdata\705830"
global asa "Y:\Data\Workdata\705830\asa\family_diag"
global generic "Y:\Data\Workdata\705830\asa\generic"
global temp "Y:\Data\Workdata\705830\asa\family_diag\temp"
global data_E "E:\Data\workdata\705830\converted_rawdata"


global diag abuse skiz bipolar omood neuro ocd eat per dev ext


*---------------------------- DIAGNOSIS PREP -----------------------------------*

** PREPARING RELEVANT DIAGNOSIS
* YEARLY INFO
* FROM PCR (ICD8 & 10), LPR_PSYK, LPR
do $asa/submission_do/diag.do




*----------------------- ASSORTATIVE MATING ANALYSIS ----------------------------*


** STEP01: IDENTIFY STUDY POPULATION
* FOCAL INDIVIDUALS: MALES AND FEMALES BORN IN DK 1960-1970
do $asa/submission_do/am_step01.do


* STEP02: MERGE DIAGNOSIS INFORMATION TO STUDY POPULATION
* for focal and partners (alle), primary and random
do $asa/submission_do/am_step02.do


* DES01: BASIC DESCRIPTIVE STATISTICS FOR FOCAL AND PARTNER MEASURES 
* MALES AND FEMALES IN ONE SAMPLE
* --> TABLE S1
do $asa/submission_do/am_des01.do


* ASSORTAIVE MATING ANALYSIS 01: CORRELATIONS AND ORS
* --> FIGURE 1
*Including risk differences
do $asa/submission_do/am_analysis01_RD.do



*----------------------- INTERGEN CORR. ANALYSIS ----------------------------*


** STEP01: IDENTIFY STUDY POPULATION
* CHILDREN BORN IN DK 1985-1995
* IDENTIFIES PARENTS
do $asa/submission_do/ic_step01.do


** STEP02: MERGE DIAGNOSIS INFORMATION TO STUDY POPULATION
do $asa/submission_do/ic_step02.do


** DES01: BASIC DESCRIPTIVE01
*--> TABLE S3
do $asa/submission_do/ic_des01.do


** INTERGENERATIONAL ANALYSIS 01: INTERGENERATIONAL CORRELATIONS
* --> FIGURE 3 + S1, S2
* Including risk differences
do $asa/submission_do/ic_analysis01_RD.do


** IC CORRECTION (BASED ON AM-DATA)
* Estimating level of missed parental diagnosis
do $asa/submission_do/ic_correction.do



*----------------------- MULTIGENERATIONAL SEM ----------------------------*


** STEP01: ADDING INFORMATION FROM GRANDPARENTS
* working of intergenerational sample 
* adding grandparents and diagnosis info
do $asa/submission_do/3gen_step01.do


** STEP02: RESTRICTING THE SAMPLE AND COLLAPSING DIAGNOSIS
* min. two grandparents residing in DK between 1986-2018
* two parents residing in DK between 1986-2018
do $asa/submission_do/3gen_step02.do


** DES01: BASIC DESCRIPTIVES
* --> Data for TABLE S8
do $asa/submission_do/3gen_des01.do


**************************************************
* --> use data in R-studio to run SEM (lavaan)

* DATA:
* Full sample data:
* $asa/data/3gen_step02.dta

* One child per familiy data:
* $asa/data/3gen_step02_randomchild.dta


* SCRIPTS:
*--------- lavaan_3gen_full_org -----------*
* Population: Full 3 generation population
* Model: Comorbidity, assortative mating & intergenerational correlations
* Tables: 
* --> polychoric correlations in S8
* --> Modelfit in S9C 
* --> SEM correlations in Table 3

*--------- lavaan_3gen_full_misc -----------*
* Population: Full 3 generation population
* Model: + allowing for in-law and grandparent-child correlations
* Tables: 
* --> SEM correlations + Modelfit in Table S10C

*--------- lavaan_3gen_full_randomchild_org -----------*
* Population: One child per family
* Model: Comorbidity, assortative mating & intergenerational correlations
* Tables: 
* --> SEM correlations + Modelfit in Table S11B

*--------- lavaan_3gen_full_randomchild_misc -----------*
* Population: One child per family
* Model: + allowing for in-law and grandparent-child correlations
* Tables: 
* --> SEM correlations + Modelfit in Table S12B


**************************************************