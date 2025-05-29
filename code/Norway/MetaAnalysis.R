###############################################################################
# For:        Norway & Denmark
# Paper:      Three Reasons Paper
# Programmer: Renate Houts
# File:       ThreeReasons_SEM_Oct2024.R
# Date:       23-Jul-2024
#
# Purpose:    Meta Analyze OR's for diagonal vs off diagonal, etc.
###############################################################################

library(plyr)
library(tidyverse)
library(readxl)
library(plotly)
library(readr)
library(kableExtra)
library(viridis)
library(metafor)
library(meta)

# Norway
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/AssortativeMating/Output from Norway")

# M -> F and F -> M IRR's
irr <- tibble(irr = c(0.2057, 0.1684), se = c(0.0008, 0.0006))

irr.meta <- metagen(TE      = irr,
                     seTE   = se,
                     data   = irr,
                     sm     = "IRR",
                     fixed  = TRUE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "classic",
                     title = "MF IRRs")
summary(irr.meta)

# Function to read in OR tables
family   <- c("All", "Ext", "Ext", "Ext",
              "Int", "Int", "Int", "Int", "Int", "Int", "Int",
              "ThD", 
              "Other", "Other", "Other", "Other", "Other")
short_dx <- c("any_MH",  "any_sub", "any_adhd", "any_adh",
              "any_dep", "any_str", "any_anx",  "any_phb", "any_ptsd", "any_pts", "any_som", 
              "any_psy", 
              "any_oth", "any_slp", "any_sex", "any_per", "any_sui")
long_dx  <- c("Any Mental Health Disorder",
              "Substance Abuse", 
              "ADHD",
              "ADHD",
              "Depression",
              "Acute Stress Reaction",
              "Anxiety",
              "Phobia / Compulsive Disorder",
              "PTSD",
              "PTSD",
              "Somatization",
              "Psychosis",
              "NOS",
              "Sleep Disturbance",
              "Sexual Concern", 
              "Personality Disorder",
              "Suicide / Suicide Attempt")

dx3f <- c("any_sub", "any_str", "any_anx", "any_dep", "any_som", "any_phb", "any_psy", 
         "any_sex", "any_slp", "any_sui", "any_per", "any_oth", "any_adh", "any_pts")

dx3  <- c("any_sub", "any_str", "any_anx", "any_dep", "any_som", "any_phb", "any_psy", 
         "any_sex", "any_slp", "any_sui", "any_per", "any_oth")
dx4  <- c("any_adhd", "any_ptsd")

LogOR <- read_csv("LogORs_PrimaryPartner_09Dec2024.csv") %>%
            mutate(MHDx_f = ifelse(str_sub(Variable, 3,  8) == "any_MH", "any_MH",
                            ifelse(str_sub(Variable, 3,  9) %in% dx3f, str_sub(Variable, 3,  9), 
                            ifelse(str_sub(Variable, 3, 10) %in% dx4, str_sub(Variable, 3, 10),
                              NA))),
                   MHDx_m = ifelse(str_sub(Outcome, 1, 6) == "any_MH", "any_MH",
                            ifelse(str_sub(Outcome, 1, 8) %in% dx3, str_sub(Outcome, 1, 8), 
                            ifelse(str_sub(Outcome, 1, 9) %in% dx4, str_sub(Outcome, 1, 9),
                              NA))),
                  MHDx_f_long = mapvalues(MHDx_f, from = short_dx, to = long_dx),
                  MHDx_m_long = mapvalues(MHDx_m, from = short_dx, to = long_dx),
                  fmh  = str_replace(MHDx_f, "any_", ""),
                  mmh  = str_replace(MHDx_m, "any_", ""),
                  diag = ifelse(MHDx_f_long ==  MHDx_m_long, 1, 0),
                  wght = 1/(StdErr*StdErr),
                  fm_MH = paste0(fmh, "_", mmh),
                  f_fam = mapvalues(MHDx_f, from = short_dx, to = family),
                  m_fam = mapvalues(MHDx_m, from = short_dx, to = family),
                  cros_fam = ifelse(f_fam == m_fam, 0, 1))

diag_ORs    <- LogOR %>% filter(diag == 1)
diag_ORs    <- diag_ORs[(3:16),]
nondiag_ORs <- LogOR %>% filter(diag == 0) %>% 
                         filter(fmh != "MH" & mmh != "MH") %>%
                         filter(f_fam != m_fam)
nondiag_ORs <- nondiag_ORs[(13:142),]

cross_famORs <- LogOR %>% filter(cros_fam == 1) %>% filter(f_fam != "All" & m_fam != "All")

ext_nodiag_ORs <- LogOR %>% filter(f_fam == "Ext" & m_fam == "Ext") %>% filter(diag == 0)
ext_nodiag_ORs <- ext_nodiag_ORs[(2:3),]

int_nodiag_ORs <- LogOR %>% filter(f_fam == "Int" & m_fam == "Int") %>% filter(diag == 0)

oth_nodiag_ORs <- LogOR %>% filter(f_fam == "Other" & m_fam == "Other") %>% filter(diag == 0)

diag.meta <- metagen(TE     = Estimate,
                     seTE   = StdErr,
                     data   = diag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Diagonal ORs")
summary(diag.meta)

crossfam.meta <- metagen(TE     = Estimate,
                         seTE   = StdErr,
                         data   = cross_famORs,
                         sm     = "OR",
                         fixed  = FALSE,
                         random = TRUE,
                         method.tau = "REML",
                         method.random.ci = "HK",
                         title = "Cross Family ORs")
summary(crossfam.meta)

nondiag.meta <- metagen(TE     = Estimate,
                     seTE   = StdErr,
                     data   = nondiag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Off Diagonal ORs")
summary(nondiag.meta)

ext.meta <- metagen(TE     = Estimate,
                    seTE   = StdErr,
                    data   = ext_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing Off Diagonal ORs")
summary(ext.meta)

int.meta <- metagen(TE     = Estimate,
                    seTE   = StdErr,
                    data   = int_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing Off Diagonal ORs")
summary(int.meta)

oth.meta <- metagen(TE     = Estimate,
                    seTE   = StdErr,
                    data   = oth_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing Off Diagonal ORs")
summary(oth.meta)


LogOR_noM <- read_csv("NoMaleComLogORs_09Dec2024.csv") %>%
              mutate(MHDx_f = ifelse(str_sub(Outcome, 3,  8) == "any_MH", "any_MH",
                              ifelse(str_sub(Outcome, 3,  9) %in% dx3, str_sub(Outcome, 3,  9), 
                              ifelse(str_sub(Outcome, 3, 10) %in% dx4, str_sub(Outcome, 3, 10),
                                       NA))),
                    MHDx_m = ifelse(str_sub(Variable, 3,  8) == "any_MH", "any_MH",
                             ifelse(str_sub(Variable, 3,  9) %in% dx3, str_sub(Variable, 3,  9), 
                             ifelse(str_sub(Variable, 3, 10) %in% dx4, str_sub(Variable, 3, 10),
                                       NA))),
                    MHDx_f_long = mapvalues(MHDx_f, from = short_dx, to = long_dx),
                    MHDx_m_long = mapvalues(MHDx_m, from = short_dx, to = long_dx),
                    fmh  = str_replace(MHDx_f, "any_", ""),
                    mmh  = str_replace(MHDx_m, "any_", ""),
                    diag = ifelse(MHDx_f_long ==  MHDx_m_long, 1, 0),
                    wght = 1/(StdErr*StdErr),
                    fm_MH = paste0(fmh, "_", mmh),
                    f_fam = mapvalues(MHDx_f, from = short_dx, to = family),
                    m_fam = mapvalues(MHDx_m, from = short_dx, to = family))

MnoCom.meta <- metagen(TE     = Estimate,
                       seTE   = StdErr,
                       data   = LogOR_noM,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "No Male Comorbidity ORs")
summary(MnoCom.meta)

LogOR_noF <- read_csv("NoFemaleComLogORs_09Dec2024.csv") %>%
              mutate(MHDx_f = ifelse(str_sub(Outcome, 3,  8) == "any_MH", "any_MH",
                              ifelse(str_sub(Outcome, 3,  9) %in% dx3, str_sub(Outcome, 3,  9), 
                              ifelse(str_sub(Outcome, 3, 10) %in% dx4, str_sub(Outcome, 3, 10),
                                       NA))),
                     MHDx_m = ifelse(str_sub(Variable, 3,  8) == "any_MH", "any_MH",
                              ifelse(str_sub(Variable, 3,  9) %in% dx3, str_sub(Variable, 3,  9), 
                              ifelse(str_sub(Variable, 3, 10) %in% dx4, str_sub(Variable, 3, 10),
                                       NA))),
                    MHDx_f_long = mapvalues(MHDx_f, from = short_dx, to = long_dx),
                    MHDx_m_long = mapvalues(MHDx_m, from = short_dx, to = long_dx),
                    fmh  = str_replace(MHDx_f, "any_", ""),
                    mmh  = str_replace(MHDx_m, "any_", ""),
                    diag = ifelse(MHDx_f_long ==  MHDx_m_long, 1, 0),
                    wght = 1/(StdErr*StdErr),
                    fm_MH = paste0(fmh, "_", mmh),
                    f_fam = mapvalues(MHDx_f, from = short_dx, to = family),
                    m_fam = mapvalues(MHDx_m, from = short_dx, to = family))

FnoCom.meta <- metagen(TE     = Estimate,
                       seTE   = StdErr,
                       data   = LogOR_noF,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "No Female Comorbidity ORs")
summary(FnoCom.meta)

LogOR_rand <- read_csv("LogORs_RandomPartner_18Dec2024.csv") %>%
  mutate(MHDx_f = ifelse(str_sub(Outcome, 3,  8) == "any_MH", "any_MH",
                         ifelse(str_sub(Outcome, 3,  9) %in% dx3, str_sub(Outcome, 3,  9), 
                                ifelse(str_sub(Outcome, 3, 10) %in% dx4, str_sub(Outcome, 3, 10),
                                       NA))),
         MHDx_m = ifelse(str_sub(Variable, 3,  8) == "any_MH", "any_MH",
                         ifelse(str_sub(Variable, 3,  9) %in% dx3, str_sub(Variable, 3,  9), 
                                ifelse(str_sub(Variable, 3, 10) %in% dx4, str_sub(Variable, 3, 10),
                                       NA))),
         MHDx_f_long = mapvalues(MHDx_f, from = short_dx, to = long_dx),
         MHDx_m_long = mapvalues(MHDx_m, from = short_dx, to = long_dx),
         fmh  = str_replace(MHDx_f, "any_", ""),
         mmh  = str_replace(MHDx_m, "any_", ""),
         diag = ifelse(MHDx_f_long ==  MHDx_m_long, 1, 0),
         wght = 1/(StdErr*StdErr),
         fm_MH = paste0(fmh, "_", mmh),
         f_fam = mapvalues(MHDx_f, from = short_dx, to = family),
         m_fam = mapvalues(MHDx_m, from = short_dx, to = family))

rand.meta <- metagen(TE     = Estimate,
                     seTE   = StdErr,
                     data   = LogOR_rand,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Random ORs")
summary(rand.meta)

# Parent-Child
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/ParentChild/Output from Norway")

# Function to read in OR tables
family   <- c("All", "Ext", "Ext", "Ext", "Ext",
              "Int", "Int", "Int", "Int", "Int", "Int", "Int",
              "ThD", 
              "Other", "Other", "Other", "Other", "Other", "Other", "Other", "Other")
short_dx <- c("any_MH",  "any_sub", "any_adhd", "any_adh", "any_chad",
              "any_dep", "any_str", "any_anx",  "any_phb", "any_ptsd", "any_pts", "any_som", 
              "any_psy", 
              "any_oth", "any_slp", "any_sex", "any_per", "any_sui", "any_con", "any_dev", "any_stm")
long_dx  <- c("Any Mental Health Disorder",
              "Substance Abuse", 
              "ADHD",
              "ADHD",
              "Child/Adolescent Behavior Symptom/Complaint",
              "Depression",
              "Acute Stress Reaction",
              "Anxiety",
              "Phobia / Compulsive Disorder",
              "PTSD",
              "PTSD",
              "Somatization",
              "Psychosis",
              "NOS",
              "Sleep Disturbance",
              "Sexual Concern", 
              "Personality Disorder",
              "Suicide / Suicide Attempt",
              "Continence Issues",
              "Developmental Delay/Learning Problem",
              "Stammering/Stuttering/Tic")

dx3f <- c("any_sub", "any_str", "any_anx", "any_dep", "any_som", "any_phb", "any_psy", 
          "any_sex", "any_slp", "any_sui", "any_per", "any_oth", "any_adh", "any_pts")

dx3  <- c("any_sub", "any_str", "any_anx", "any_dep", "any_som", "any_phb", "any_psy", 
          "any_sex", "any_slp", "any_sui", "any_per", "any_oth", "any_con", "any_dev", "any_stm")
dx4  <- c("any_adhd", "any_ptsd", "any_chad")

LogOR <- read_csv("LogORs_EitherParent_Dec2024.csv") %>%
  mutate(MHDx_p = ifelse(str_sub(Variable, 3,  8) == "any_MH", "any_MH",
                  ifelse(str_sub(Variable, 3,  9) %in% dx3, str_sub(Variable, 3,  9), 
                  ifelse(str_sub(Variable, 3, 10) %in% dx4, str_sub(Variable, 3, 10),
                     NA))),
         MHDx_c = Outcome,
         MHDx_c_long = mapvalues(MHDx_c, from = short_dx, to = long_dx),
         MHDx_p_long = mapvalues(MHDx_p, from = short_dx, to = long_dx),
         cmh  = str_replace(MHDx_c, "any_", ""),
         pmh  = str_replace(MHDx_p, "any_", ""),
         diag = ifelse(MHDx_c_long ==  MHDx_p_long, 1, 0),
         wght = 1/(StdErr*StdErr),
         pc_MH = paste0(pmh, "_", cmh),
         c_fam = mapvalues(MHDx_c, from = short_dx, to = family),
         p_fam = mapvalues(MHDx_p, from = short_dx, to = family),
         cros_fam = ifelse(c_fam == p_fam, 0, 1))

diag_ORs    <- LogOR %>% filter(diag == 1)
diag_ORs    <- diag_ORs[c(1,3:15),]
nondiag_ORs <- LogOR %>% filter(diag == 0) %>% 
                  filter(pmh != "MH" & cmh != "MH") %>%
                  filter(p_fam != c_fam)

ext_nodiag_ORs <- LogOR %>% filter(p_fam == "Ext" & c_fam == "Ext") %>% filter(diag == 0)
int_nodiag_ORs <- LogOR %>% filter(p_fam == "Int" & c_fam == "Int") %>% filter(diag == 0)
oth_nodiag_ORs <- LogOR %>% filter(p_fam == "Other" & c_fam == "Other") %>% filter(diag == 0)

cross_famORs <- LogOR %>% filter(cros_fam == 1) %>% filter(p_fam != "All" & c_fam != "All")

diag.meta <- metagen(TE     = Estimate,
                     seTE   = StdErr,
                     data   = diag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Diagonal ORs")
summary(diag.meta)

crossfam.meta <- metagen(TE     = Estimate,
                         seTE   = StdErr,
                         data   = cross_famORs,
                         sm     = "OR",
                         fixed  = FALSE,
                         random = TRUE,
                         method.tau = "REML",
                         method.random.ci = "HK",
                         title = "Cross Family ORs")
summary(crossfam.meta)

nondiag.meta <- metagen(TE     = Estimate,
                        seTE   = StdErr,
                        data   = nondiag_ORs,
                        sm     = "OR",
                        fixed  = FALSE,
                        random = TRUE,
                        method.tau = "REML",
                        method.random.ci = "HK",
                        title = "Off Diagonal ORs")
summary(nondiag.meta)

ext.meta <- metagen(TE     = Estimate,
                    seTE   = StdErr,
                    data   = ext_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing Off Diagonal ORs")
summary(ext.meta)

int.meta <- metagen(TE     = Estimate,
                    seTE   = StdErr,
                    data   = int_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing Off Diagonal ORs")
summary(int.meta)

oth.meta <- metagen(TE     = Estimate,
                    seTE   = StdErr,
                    data   = oth_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing Off Diagonal ORs")
summary(oth.meta)


LogOR_noP <- read_csv("LogORs_EitherNoPCom_Dec2024.csv") %>%
                mutate(MHDx_p = ifelse(str_sub(Variable, 3,  8) == "any_MH", "any_MH",
                                ifelse(str_sub(Variable, 3,  9) %in% dx3, str_sub(Variable, 3,  9), 
                                ifelse(str_sub(Variable, 3, 10) %in% dx4, str_sub(Variable, 3, 10),
                                       NA))),
                       MHDx_c = Outcome,
                       MHDx_c_long = mapvalues(MHDx_c, from = short_dx, to = long_dx),
                       MHDx_p_long = mapvalues(MHDx_p, from = short_dx, to = long_dx),
                       cmh  = str_replace(MHDx_c, "any_", ""),
                       pmh  = str_replace(MHDx_p, "any_", ""),
                       diag = ifelse(MHDx_c_long ==  MHDx_p_long, 1, 0),
                       wght = 1/(StdErr*StdErr),
                       pc_MH = paste0(pmh, "_", cmh),
                       c_fam = mapvalues(MHDx_c, from = short_dx, to = family),
                       p_fam = mapvalues(MHDx_p, from = short_dx, to = family)) %>%
                filter(diag == 0)

PnoCom.meta <- metagen(TE     = Estimate,
                       seTE   = StdErr,
                       data   = LogOR_noP,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "No Parent Comorbidity ORs")
summary(PnoCom.meta)

LogOR_rand <- read_csv("ORs_RandomParent_Dec2024.csv") %>%
  mutate(OR_b   = log(Estimate),
         SE_lcl = (log(LowerCL) - OR_b)/(-1*qnorm(.975)),
         SE_ucl = (log(UpperCL) - OR_b)/qnorm(.975))

rand1.meta <- metagen(TE      = OR_b,
                       seTE   = SE_lcl,
                       data   = LogOR_rand,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "Random ORs")
summary(rand1.meta)

rand2.meta <- metagen(TE     = OR_b,
                      seTE   = SE_ucl,
                      data   = LogOR_rand,
                      sm     = "OR",
                      fixed  = FALSE,
                      random = TRUE,
                      method.tau = "REML",
                      method.random.ci = "HK",
                      title = "random ORs")
summary(rand2.meta)

# Denmark
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Denmark/AssortativeMating")

family_d   <- c("Ext", "Ext", 
              "Int", "Int", "Int", 
              "ThD", "ThD", "ThD",
              "Other", "Other")
short_dx_d <- c("Substance abuse",  "Externalizing", 
              "Neurotic", "Mood", "Eating disorder", 
              "Schizophrenia", "Bipolar", "OCD", 
              "Personality", "Developmental")

## Primary Partner ORs
primary <- read_xlsx('AM_09Dec2024.xlsx',
                     sheet = 'Fig 1A OR primary',
                     skip = 2) %>%
            filter(!is.na(what)) %>%
            pivot_longer(cols = 3:12, names_to = "Diagnosis1", values_to = "Estimate") %>%
            mutate(what = ifelse(what == "SE", "OR_SE", what)) %>%
            pivot_wider(names_from = what, values_from = Estimate) %>%
            mutate(Diagnosis  = ifelse(`Female diagnosis` == "Skizophrenia", "Schizophrenia", 
                                       `Female diagnosis`),
                   Diagnosis  = ifelse(`Female diagnosis` == "Other mood", "Mood", 
                                       `Female diagnosis`),
                   Diagnosis1 = ifelse(Diagnosis1 == "Skizophrenia", "Schizophrenia", 
                                       Diagnosis1),
                   OR_b = log(OR), 
                   SE   = OR_SE/OR,
                   LCL  = exp(OR_b - qnorm(.975)*SE),
                   UCL  = exp(OR_b + qnorm(.975)*SE),
                   sig  = ifelse(LCL <  1 & UCL >  1, 0, 
                         ifelse(LCL >= 1 | UCL <= 1, 1, NA)),
                   CI   = paste0("(", sprintf("%.1f", round(LCL, 2)), ", ", sprintf("%.1f", round(UCL, 2)), ")"),
                   f_fam = mapvalues(Diagnosis,  from = short_dx_d, to = family_d),
                   m_fam = mapvalues(Diagnosis1, from = short_dx_d, to = family_d),
                   diag  = ifelse(Diagnosis == Diagnosis1, 1, 0),
                   cros_fam = ifelse(f_fam == m_fam, 0, 1)) 

diag_ORs     <- primary %>% filter(diag == 1)
nondiag_ORs  <- primary %>% filter(diag == 0)
cross_famORs <- primary %>% filter(cros_fam == 1)

ext_nodiag_ORs <- primary %>% filter(m_fam == "Ext" & f_fam == "Ext") %>% filter(diag == 0)
int_nodiag_ORs <- primary %>% filter(m_fam == "Int" & f_fam == "Int") %>% filter(diag == 0)
thd_nodiag_ORs <- primary %>% filter(m_fam == "ThD" & f_fam == "ThD") %>% filter(diag == 0)
oth_nodiag_ORs <- primary %>% filter(m_fam == "Other" & f_fam == "Other") %>% filter(diag == 0)

diag.meta <- metagen(TE     = OR_b,
                     seTE   = SE,
                     data   = diag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Diagonal ORs")
summary(diag.meta)

ext.meta <- metagen(TE     = OR_b,
                    seTE   = SE,
                    data   = ext_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Externalizing ORs")
summary(ext.meta)

int.meta <- metagen(TE     = OR_b,
                    seTE   = SE,
                    data   = int_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Internalizing ORs")
summary(int.meta)

thd.meta <- metagen(TE     = OR_b,
                    seTE   = SE,
                    data   = thd_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Thought Disorder ORs")
summary(thd.meta)

oth.meta <- metagen(TE     = OR_b,
                    seTE   = SE,
                    data   = oth_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Other ORs")
summary(oth.meta)

cross.meta <- metagen(TE     = OR_b,
                      seTE   = SE,
                      data   = cross_famORs,
                      sm     = "OR",
                      fixed  = FALSE,
                      random = TRUE,
                      method.tau = "REML",
                      method.random.ci = "HK",
                      title = "Cross-family ORs")
summary(cross.meta)

## No Male Comorbidity ORs
NoMCom <- read_xlsx('AM_09Dec2024.xlsx',
                     sheet = 'nocormorbidity_males',
                     skip = 2) %>%
            filter(!is.na(what)) %>%
            pivot_longer(cols = 3:12, names_to = "Diagnosis1", values_to = "Estimate") %>%
            mutate(what = ifelse(what == "SE", "OR_SE", what)) %>%
            pivot_wider(names_from = what, values_from = Estimate) %>%
            mutate(Diagnosis  = ifelse(`Female diagnosis` == "Skizophrenia", "Schizophrenia", 
                                       `Female diagnosis`),
                   Diagnosis  = ifelse(`Female diagnosis` == "Other mood", "Mood", 
                                       `Female diagnosis`),
                   Diagnosis1 = ifelse(Diagnosis1 == "Skizophrenia", "Schizophrenia", 
                                       Diagnosis1),
                   OR_b = log(OR), 
                   SE_b = OR_SE/OR) %>%
            filter(!is.na(OR_b))

NoMCom.meta <- metagen(TE    = OR_b,
                      seTE   = SE_b,
                      data   = NoMCom,
                      sm     = "OR",
                      fixed  = FALSE,
                      random = TRUE,
                      method.tau = "REML",
                      method.random.ci = "HK",
                      title = "Cross-family ORs")
summary(NoMCom.meta)

NoFCom <- read_xlsx('AM_09Dec2024.xlsx',
                    sheet = 'nocormbidity_females',
                    skip = 2) %>%
  filter(!is.na(what)) %>%
  pivot_longer(cols = 3:12, names_to = "Diagnosis1", values_to = "Estimate") %>%
  mutate(what = ifelse(what == "SE", "OR_SE", what)) %>%
  pivot_wider(names_from = what, values_from = Estimate) %>%
  mutate(Diagnosis  = ifelse(`Female diagnosis` == "Skizophrenia", "Schizophrenia", 
                             `Female diagnosis`),
         Diagnosis  = ifelse(`Female diagnosis` == "Other mood", "Mood", 
                             `Female diagnosis`),
         Diagnosis1 = ifelse(Diagnosis1 == "Skizophrenia", "Schizophrenia", 
                             Diagnosis1),
         OR_b = log(OR), 
         SE_b = OR_SE/OR) %>%
  filter(!is.na(OR_b))

NoFCom.meta <- metagen(TE    = OR_b,
                       seTE   = SE_b,
                       data   = NoFCom,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "Cross-family ORs")
summary(NoFCom.meta)


Random <- read_xlsx('AM_09Dec2024.xlsx',
                    sheet = 'Fig 1B OR random',
                    skip = 2) %>%
  filter(!is.na(what)) %>%
  pivot_longer(cols = 3:12, names_to = "Diagnosis1", values_to = "Estimate") %>%
  mutate(what = ifelse(what == "SE", "OR_SE", what)) %>%
  pivot_wider(names_from = what, values_from = Estimate) %>%
  mutate(Diagnosis  = ifelse(`Female diagnosis` == "Skizophrenia", "Schizophrenia", 
                             `Female diagnosis`),
         Diagnosis  = ifelse(`Female diagnosis` == "Other mood", "Mood", 
                             `Female diagnosis`),
         Diagnosis1 = ifelse(Diagnosis1 == "Skizophrenia", "Schizophrenia", 
                             Diagnosis1),
         OR_b = log(OR), 
         SE_b = OR_SE/OR) %>%
  filter(!is.na(OR_b))

Random.meta <- metagen(TE    = OR_b,
                       seTE   = SE_b,
                       data   = Random,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "Cross-family ORs")
summary(Random.meta)

# Parent child
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Denmark/ParentOffspring")

family_d   <- c("All",
                "Ext", "Ext", 
                "Int", "Int", "Int", 
                "ThD", "ThD", "ThD",
                "Other", "Other")
short_dx_d <- c("AnyDiagnosis", 
                "SubstanceAbuse",  "Externalizing", 
                "Neurotic", "OtherMood", "EatingDisorder", 
                "Schizophrenia", "Bipolar", "OCD", 
                "Personality", "Developmental")

read_sheet <- function (xl_file, xl_sheet){
  
  df <- read_xlsx(xl_file,
                  sheet = xl_sheet,
                  skip = 2) %>%
          filter(!is.na(`Parent diagnosis`)) %>%
          filter(`Parent diagnosis` != "Observations") %>% 
          pivot_longer(cols = 3:13, names_to = "Child diagnosis", values_to = "Estimate") %>%
          pivot_wider(names_from = Value, values_from = Estimate) %>%
    
          mutate(`Parent diagnosis` = ifelse(`Parent diagnosis` == "Any diagnosis",   "AnyDiagnosis", 
                                      ifelse(`Parent diagnosis` == "Substance abuse", "SubstanceAbuse",
                                      ifelse(`Parent diagnosis` == "Skizofrenia",     "Schizophrenia",
                                      ifelse(`Parent diagnosis` == "Skizophrenia",    "Schizophrenia",
                                      ifelse(`Parent diagnosis` == "Other mood",      "OtherMood",
                                      ifelse(`Parent diagnosis` == "Eating disorder", "EatingDisorder", 
                                                                          `Parent diagnosis`))))))) %>%
          mutate(`Child diagnosis` = ifelse(`Child diagnosis` == "Any diagnosis",   "AnyDiagnosis", 
                                     ifelse(`Child diagnosis` == "Substance abuse", "SubstanceAbuse",
                                     ifelse(`Child diagnosis` == "Skizophrenia",    "Schizophrenia",
                                     ifelse(`Child diagnosis` == "Skizofrenia",     "Schizophrenia",
                                     ifelse(`Child diagnosis` == "Other mood",      "OtherMood",
                                     ifelse(`Child diagnosis` == "Eating disorder", "EatingDisorder", 
                                                                         `Child diagnosis`))))))) %>%
          mutate(p_diagnosis = `Parent diagnosis`,
                 c_diagnosis = `Child diagnosis`) %>%
          separate(CI, c("LCL", "UCL"), sep = ",") %>%
          mutate(OR  = parse_number(OR),
                 LCL = parse_number(LCL),
                 UCL = parse_number(UCL),
                 sig = ifelse(LCL <  1 & UCL >  1, 0, 
                       ifelse(LCL >= 1 | UCL <= 1, 1, NA)),
                 CI  = paste0("(", sprintf("%.1f", round(LCL, 2)), ", ", sprintf("%.1f", round(UCL, 2)), ")"),
                 OR_b   = log(OR),
                 SE_lcl = (log(LCL) - OR_b)/(-1*qnorm(.975)),
                 SE_ucl = (log(UCL) - OR_b)/qnorm(.975),
                 c_fam = mapvalues(c_diagnosis,  from = short_dx_d, to = family_d),
                 p_fam = mapvalues(p_diagnosis, from = short_dx_d, to = family_d),
                 diag  = ifelse(c_diagnosis == p_diagnosis, 1, 0),
                 cros_fam = ifelse(c_fam == p_fam, 0, 1)) %>%
          select(p_diagnosis, c_diagnosis, OR, LCL, UCL, CI, sig, OR_b, SE_lcl, SE_ucl, 
                 c_fam, p_fam, diag, cros_fam) %>%
          filter(p_fam != "All" & c_fam != "All")
  
  return(df)
}

# Either parent
either <- read_sheet(xl_file  = 'PO_All.xlsx', xl_sheet = "Main")

diag_ORs     <- either %>% filter(diag == 1)
nondiag_ORs  <- either %>% filter(diag == 0)
cross_famORs <- either %>% filter(cros_fam == 1)

ext_nodiag_ORs <- either %>% filter(c_fam == "Ext" & p_fam == "Ext") %>% filter(diag == 0)
int_nodiag_ORs <- either %>% filter(c_fam == "Int" & p_fam == "Int") %>% filter(diag == 0)
thd_nodiag_ORs <- either %>% filter(c_fam == "ThD" & p_fam == "ThD") %>% filter(diag == 0)
oth_nodiag_ORs <- either %>% filter(c_fam == "Other" & p_fam == "Other") %>% filter(diag == 0)

diag.meta <- metagen(TE     = OR_b,
                     seTE   = SE_lcl,
                     data   = diag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Diagonal ORs")
summary(diag.meta)

ext.meta <- metagen(TE     = OR_b,
                    seTE   = SE_lcl,
                    data   = ext_nodiag_ORs,
                    sm     = "OR",
                    fixed  = TRUE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "classic",
                    title = "Externalizing ORs")
summary(ext.meta)

int.meta <- metagen(TE     = OR_b,
                    seTE   = SE_lcl,
                    data   = int_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Internalizing ORs")
summary(int.meta)

thd.meta <- metagen(TE     = OR_b,
                    seTE   = SE_lcl,
                    data   = thd_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Thought Disorder ORs")
summary(thd.meta)

oth.meta <- metagen(TE     = OR_b,
                    seTE   = SE_lcl,
                    data   = oth_nodiag_ORs,
                    sm     = "OR",
                    fixed  = FALSE,
                    random = TRUE,
                    method.tau = "REML",
                    method.random.ci = "HK",
                    title = "Other ORs")
summary(oth.meta)

cross.meta <- metagen(TE     = OR_b,
                      seTE   = SE_lcl,
                      data   = cross_famORs,
                      sm     = "OR",
                      fixed  = FALSE,
                      random = TRUE,
                      method.tau = "REML",
                      method.random.ci = "HK",
                      title = "Cross-family ORs")
summary(cross.meta)

# No parent Comorbidity
NoPCom <- read_xlsx('PO_All.xlsx',
                    sheet = 'Fig 1B no comorbidity',
                    skip = 2) %>%
            filter(!is.na(what)) %>%
            pivot_longer(cols = 3:12, names_to = "Diagnosis1", values_to = "Estimate") %>%
            pivot_wider(names_from = what, values_from = Estimate) %>%
            mutate(c_diagnosis  = ifelse(`Child diagnosis` == "Skizophrenia", "Schizophrenia", 
                                         `Child diagnosis`),
                   Diagnosis1 = ifelse(Diagnosis1 == "Skizophrenia", "Schizophrenia", 
                                       Diagnosis1),
                   OR_b = log(OR), 
                   SE_b = SE/OR,
                   LCL  = exp(OR_b - qnorm(.975)*SE_b),
                   UCL  = exp(OR_b + qnorm(.975)*SE_b),
                   sig = ifelse(LCL <  1 & UCL >  1, 0, 
                           ifelse(LCL >= 1 | UCL <= 1, 1, NA)),
                   CI  = paste0("(", sprintf("%.1f", round(LCL, 2)), ", ", sprintf("%.1f", round(UCL, 2)), ")")) %>%
            mutate(Diagnosis1 = ifelse(Diagnosis1 == "Substance abuse", "SubstanceAbuse",
                                ifelse(Diagnosis1 == "Eating disorder", "EatingDisorder", 
                                ifelse(Diagnosis1 == "Mood", "OtherMood", Diagnosis1)))) %>%
            select(-`Child diagnosis`) %>%
            filter(!is.na(OR_b))

NoPcom.meta <- metagen(TE     = OR_b,
                       seTE   = SE_b,
                       data   = NoPCom,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "No Parent Comorbidity ORs")
summary(NoPcom.meta)

# Random parent
randp <- read_sheet(xl_file  = 'PO_All.xlsx', xl_sheet = "C) Random")

randp.meta <- metagen(TE     = OR_b,
                       seTE   = SE_lcl,
                       data   = randp,
                       sm     = "OR",
                       fixed  = FALSE,
                       random = TRUE,
                       method.tau = "REML",
                       method.random.ci = "HK",
                       title = "Random parent ORs")
summary(randp.meta)

