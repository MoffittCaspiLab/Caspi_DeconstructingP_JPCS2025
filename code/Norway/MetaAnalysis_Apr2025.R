###############################################################################
# For:        Norway & Denmark
# Paper:      Three Reasons Paper
# Programmer: Renate Houts
# File:       ThreeReasons_SEM_Oct2024.R
# Date:       23-Jul-2024
#
# Purpose:    Meta Analyze OR's for diagonal vs off diagonal, etc.
#             Check for differences in diagonal, within spectra, cross spectra
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
setwd("M:/p1074-renateh/2024_ThreeReasons/Assortative_Mating")

# Function to read in OR tables
family   <- c("All", "Ext", "Ext", "Ext",
              "Int", "Int", "Int", "Int", "Int", "Int", "Int",
              "ThD", 
              "O1", "O2", "O3", "O4", "O5")
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

LogOR <- read_csv("LogORs_Comorbid_14Apr2025.csv") %>%
  mutate(MHDx_f = ifelse(str_sub(Variable, 1, 6) == "any_MH", "any_MH",
                  ifelse(str_sub(Variable, 1, 8) %in% dx3f, str_sub(Variable, 1, 8), 
                  ifelse(str_sub(Variable, 1, 9) %in% dx4, str_sub(Variable,  1, 9),
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
         cros_fam = ifelse(f_fam == m_fam, 0, 1),
         dx_type = ifelse(diag == 1, "diag", ifelse(cros_fam == 0, "within", "between"))) %>%
         filter(dx_type != "diag") %>%
         mutate(dup = ifelse(fmh == "adhd" & mmh %in% c("sub"), 1,
                      ifelse(fmh == "dep"  & mmh %in% c("sub", "adhd"), 1,
                      ifelse(fmh == "str"  & mmh %in% c("sub", "adhd", "dep"), 1,
                      ifelse(fmh == "anx"  & mmh %in% c("sub", "adhd", "dep", "str"), 1,
                      ifelse(fmh == "phb"  & mmh %in% c("sub", "adhd", "dep", "str", "anx"), 1,
                      ifelse(fmh == "ptsd" & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb"), 1,
                      ifelse(fmh == "som"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd"), 1,
                      ifelse(fmh == "psy"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd", "som"), 1,
                      ifelse(fmh == "oth"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd", "som", "psy"), 1,
                      ifelse(fmh == "slp"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd", "som", "psy", "oth"), 1,
                      ifelse(fmh == "sex"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd", "som", "psy", "oth", "slp"), 1,
                      ifelse(fmh == "per"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd", "som", "psy", "oth", "slp", "sex"), 1, 
                      ifelse(fmh == "sui"  & mmh %in% c("sub", "adhd", "dep", "str", "anx", "phb", "ptsd", "som", "psy", "oth", "slp", "sex", "per"), 1, 
                             0)))))))))))))) %>%
        filter(dup == 0) %>%
        filter(f_fam != "Other" & m_fam != "Other")

within_ORs  <- LogOR |> filter(dx_type == "within")
between_ORs <- LogOR |> filter(dx_type == "between")

ext_nodiag_ORs <- within_ORs |> filter(f_fam == "Ext")
int_nodiag_ORs <- within_ORs |> filter(f_fam == "Int")
thd_nodiag_ORs <- within_ORs |> filter(f_fam == "ThD")

median(within_ORs$Estimate, na.rm = TRUE)
median(between_ORs$Estimate, na.rm = TRUE)
median(ext_nodiag_ORs$Estimate, na.rm = TRUE)
median(int_nodiag_ORs$Estimate, na.rm = TRUE)
median(thd_nodiag_ORs$Estimate, na.rm = TRUE)

within.meta  <- metagen(TE  = Estimate,
                        seTE   = StdErr,
                        data   = within_ORs,
                        sm     = "OR",
                        fixed  = FALSE,
                        random = TRUE,
                        method.tau = "REML",
                        method.random.ci = "HK",
                        title = "Within ORs")
summary(within.meta)

between.meta  <- metagen(TE  = Estimate,
                         seTE   = StdErr,
                         data   = between_ORs,
                         sm     = "OR",
                         fixed  = FALSE,
                         random = TRUE,
                         method.tau = "REML",
                         method.random.ci = "HK",
                         title = "Between ORs")
summary(between.meta)

int.meta  <- metagen(TE  = Estimate,
                     seTE   = StdErr,
                     data   = int_nodiag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Internalizing ORs")
summary(int.meta)

ext.meta  <- metagen(TE  = Estimate,
                     seTE   = StdErr,
                     data   = ext_nodiag_ORs,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Externalizing ORs")
summary(ext.meta)

all.meta  <- metagen(TE     = Estimate,
                     seTE   = StdErr,
                     data   = LogOR,
                     sm     = "OR",
                     fixed  = FALSE,
                     random = TRUE,
                     method.tau = "REML",
                     method.random.ci = "HK",
                     title = "Diagonal ORs")
summary(all.meta)

update(all.meta,
       subgroup   = dx_type,
       tau.common = FALSE)