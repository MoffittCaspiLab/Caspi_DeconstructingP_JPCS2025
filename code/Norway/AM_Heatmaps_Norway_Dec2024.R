###############################################################################
# For:        Norway
# Paper:      Three Reasons Paper
# Programmer: Renate Houts
# File:       Heatmaps_Norway.r
# Date:       23-Oct-2024
#
# Purpose:    Create heatmaps and tables for Norway portion of 3 Reasons paper
###############################################################################

library(plyr)
library(tidyverse)
library(readxl)
library(plotly)
library(readr)
library(kableExtra)
library(viridis)
library(readr)

sessionInfo()

# Assortative Mating Directory
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/AssortativeMating/Output from Norway")


# Vectors to help map variables names
family   <- c("All", "Ext", "Ext", 
              "Int", "Int", "Int", "Int", "Int", "Int",
              "ThD", 
              "Other", "Other", "Other", "Other", "Other")
short_dx <- c("any_MH",  "any_sub", "any_adhd",
              "any_dep", "any_str", "any_anx",  "any_phb", "any_ptsd", "any_som", 
              "any_psy", 
              "any_oth", "any_slp", "any_sex", "any_per", "any_sui")
long_dx  <- c("Any Mental Health Disorder",
              "Substance Abuse", 
              "ADHD",
              "Depression",
              "Acute Stress Reaction",
              "Anxiety",
              "Phobia / Compulsive Disorder",
              "PTSD",
              "Somatization",
              "Psychosis",
              "NOS",
              "Sleep Disturbance",
              "Sexual Concern", 
              "Personality Disorder",
              "Suicide / Suicide Attempt")

dx3 <- c("any_sub", "any_str", "any_anx", "any_dep", "any_som", "any_phb", "any_psy", 
         "any_sex", "any_slp", "any_sui", "any_per", "any_oth")
dx4 <- c("any_adhd", "any_ptsd")

read_dat_mf <- function (OR_file){
  
  OR <- read_csv(OR_file) %>%
        mutate(MHDx_m = ifelse(str_sub(Table, 9, 14) == "any_MH", "any_MH",
                        ifelse(str_sub(Table, 9, 15) %in% dx3, str_sub(Table, 9, 15), 
                        ifelse(str_sub(Table, 9, 16) %in% dx4, str_sub(Table, 9, 16),
                        NA))),
               MHDx_f = ifelse(str_sub(Table, 22, 27) == "any_MH", "any_MH",
                        ifelse(str_sub(Table, 22, 28) %in% dx3, str_sub(Table, 22, 28), 
                        ifelse(str_sub(Table, 22, 29) %in% dx4, str_sub(Table, 22, 29),
                        ifelse(str_sub(Table, 21, 26) == "any_MH", "any_MH",
                        ifelse(str_sub(Table, 21, 27) %in% dx3, str_sub(Table, 21, 27), 
                        ifelse(str_sub(Table, 21, 28) %in% dx4, str_sub(Table, 21, 28),
                        ifelse(str_sub(Table, 20, 25) == "any_MH", "any_MH",
                        ifelse(str_sub(Table, 20, 26) %in% dx3, str_sub(Table, 20, 26), 
                        ifelse(str_sub(Table, 20, 27) %in% dx4, str_sub(Table, 20, 27),
                        NA))))))))),
               MHDx_f_long = mapvalues(MHDx_f, from = short_dx, to = long_dx),
               MHDx_m_long = mapvalues(MHDx_m, from = short_dx, to = long_dx),
               fmh = str_replace(MHDx_f, "any_", ""),
               mmh = str_replace(MHDx_m, "any_", ""))
  
  return(OR)
}

# Read in OR files from Norway
primary <- read_dat_mf(OR_file = "ORs_PrimaryPartner_09Dec2024.csv")
noMCom  <- read_dat_mf(OR_file = "NoMaleComORs_09Dec2024.csv")
noFCom  <- read_dat_mf(OR_file = "NoFemaleComORs_09Dec2024.csv")
random  <- read_dat_mf(OR_file = "ORs_RandomPartner_18Dec2024.csv")

flip_dat <- function (OR) {
  OR_Frq <- OR %>%
            select(-Table, -StudyType, -Statistic, -MHDx_f, -MHDx_m, -MHDx_m_long) %>%
            pivot_wider(names_from  = mmh, 
                        values_from = c(Value, LowerCL, UpperCL, sig)) %>%
            mutate(MH_CI   = paste0("(", sprintf("%.1f", round(LowerCL_MH,   2)), ", ",
                             sprintf("%.1f", round(UpperCL_MH,   2)), ")"),
                   adhd_CI = paste0("(", sprintf("%.1f", round(LowerCL_adhd, 2)), ", ",
                             sprintf("%.1f", round(UpperCL_adhd, 2)), ")"),
                   sub_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sub,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sub,  2)), ")"),
                   str_CI  = paste0("(", sprintf("%.1f", round(LowerCL_str,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_str,  2)), ")"),
                   anx_CI  = paste0("(", sprintf("%.1f", round(LowerCL_anx,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_anx,  2)), ")"),
                   dep_CI  = paste0("(", sprintf("%.1f", round(LowerCL_dep,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_dep,  2)), ")"),
                   ptsd_CI = paste0("(", sprintf("%.1f", round(LowerCL_ptsd, 2)), ", ", 
                             sprintf("%.1f", round(UpperCL_ptsd, 2)), ")"),
                   som_CI  = paste0("(", sprintf("%.1f", round(LowerCL_som,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_som,  2)), ")"),
                   phb_CI  = paste0("(", sprintf("%.1f", round(LowerCL_phb,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_phb,  2)), ")"),
                   psy_CI  = paste0("(", sprintf("%.1f", round(LowerCL_psy,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_psy,  2)), ")"),
                   sex_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sex,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sex,  2)), ")"),
                   slp_CI  = paste0("(", sprintf("%.1f", round(LowerCL_slp,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_slp,  2)), ")"),
                   sui_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sui,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sui,  2)), ")"),
                   per_CI  = paste0("(", sprintf("%.1f", round(LowerCL_per,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_per,  2)), ")"),
                   oth_CI  = paste0("(", sprintf("%.1f", round(LowerCL_oth,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_oth,  2)), ")"))
  return(OR_Frq)
}

flip_dat1 <- function (OR) {
  OR_Frq <- OR %>%
            select(-Table, -StudyType, -Statistic, -MHDx_f, -MHDx_m, -MHDx_m_long) %>%
            pivot_wider(names_from  = mmh, 
                        values_from = c(Value, LowerCL, UpperCL, sig)) %>%
            mutate(adhd_CI = paste0("(", sprintf("%.1f", round(LowerCL_adhd, 2)), ", ",
                             sprintf("%.1f", round(UpperCL_adhd, 2)), ")"),
                   sub_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sub,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sub,  2)), ")"),
                   str_CI  = paste0("(", sprintf("%.1f", round(LowerCL_str,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_str,  2)), ")"),
                   anx_CI  = paste0("(", sprintf("%.1f", round(LowerCL_anx,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_anx,  2)), ")"),
                   dep_CI  = paste0("(", sprintf("%.1f", round(LowerCL_dep,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_dep,  2)), ")"),
                   ptsd_CI = paste0("(", sprintf("%.1f", round(LowerCL_ptsd, 2)), ", ", 
                             sprintf("%.1f", round(UpperCL_ptsd, 2)), ")"),
                   som_CI  = paste0("(", sprintf("%.1f", round(LowerCL_som,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_som,  2)), ")"),
                   phb_CI  = paste0("(", sprintf("%.1f", round(LowerCL_phb,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_phb,  2)), ")"),
                   psy_CI  = paste0("(", sprintf("%.1f", round(LowerCL_psy,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_psy,  2)), ")"),
                   sex_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sex,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sex,  2)), ")"),
                   slp_CI  = paste0("(", sprintf("%.1f", round(LowerCL_slp,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_slp,  2)), ")"),
                   sui_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sui,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sui,  2)), ")"),
                   per_CI  = paste0("(", sprintf("%.1f", round(LowerCL_per,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_per,  2)), ")"),
                   oth_CI  = paste0("(", sprintf("%.1f", round(LowerCL_oth,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_oth,  2)), ")"))
  return(OR_Frq)
}

# Flip data into format needed for heatmap
prim_flip   <- flip_dat(primary) %>% filter(fmh != "MH")
rand_flip   <- flip_dat(random)  %>% filter(fmh != "MH")

noMCom_flip <- flip_dat1(noMCom) 
noMCom_flip <- noMCom_flip[c(14,1,2,3,4,5,6,7,8,9,10,11,12,13),]

noFCom_flip <- flip_dat1(noFCom)
noFCom_flip <- noFCom_flip[c(1,14,2,3,4,5,6,7,8,9,10,11,12,13),]


# Function to create heat map
make_heatmap <- function(df, low) {
  
  heat_dat <- df %>%
              select(MHDx_f_long,
                     Value_sub,
                     Value_adhd,
                     Value_dep,
                     Value_str,
                     Value_anx,
                     Value_phb,
                     Value_ptsd,
                     Value_som,
                     Value_psy,
                     Value_oth,
                     Value_slp,
                     Value_sex,
                     Value_per,
                     Value_sui,
                     sig_adhd,
                     sig_sub,
                     sig_str,
                     sig_anx,
                     sig_dep,
                     sig_ptsd,
                     sig_som,
                     sig_phb,
                     sig_psy,
                     sig_sex,
                     sig_slp,
                     sig_sui,
                     sig_per,
                     sig_oth) %>%
              mutate(space1 = NA,
                     space2 = NA,
                     space3 = NA) %>%
    
              relocate(space1, .after = Value_adhd) %>%
              relocate(space2, .after = Value_som) %>%
              relocate(space3, .after = Value_psy) %>%
              add_row() 
  
  heat_dat <- heat_dat[c(1,2,15,3,4,5,6,7,8,9,10,11,12,13,14),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,16,10,11,12,13,14,15),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,10,11,17,12,13,14,15,16),] 
  
  # Set how to display NA in table
  opts <- options(knitr.kable.NA = " ")
  
  heat_table <- kable(heat_dat, escape = F, align = "rcccccccccccccccc", digits = 1, format.args = list(nsmall = 1),
                      booktabs = T,
                      
                      # Set up column names
                      col.names = c("Female Diagnosis",
                                    "Substance Abuse", "ADHD", " ", 
                                    "Depression", "Acute Stress Reaction", "Anxiety", "Phobia / Compulsive disorder", 
                                    "PTSD",  "Somatization",  " ", 
                                    "Psychosis", " ",
                                    "NOS", "Sleep Disorder", "Sexual concern", "Personality Disorder", 
                                    "Suicide / Suicide Attempt", 
                                    "", "", "", "", "", "", "", "", "", "", "", "", "", "")) %>%
    
    kable_paper(c("basic", "condensed"), full_width = T) %>%
    
    column_spec(1, 
                width = '1.25in', 
                bold  = T) %>%
    
    column_spec(2, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sub) & heat_dat$Value_sub > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sub) & heat_dat$Value_sub < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sub), "grey",
                                    ifelse(heat_dat$sig_sub == 0, "grey90", 
                                           spec_color(heat_dat$Value_sub[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(3, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_adhd) & heat_dat$Value_adhd > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_adhd) & heat_dat$Value_adhd < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_adhd), "grey",
                                    ifelse(heat_dat$sig_adhd == 0, "grey90", 
                                           spec_color(heat_dat$Value_adhd[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(5, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_dep) & heat_dat$Value_dep > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_dep) & heat_dat$Value_dep < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_dep), "grey",
                                    ifelse(heat_dat$sig_dep == 0, "grey90", 
                                           spec_color(heat_dat$Value_dep[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(6, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_str) & heat_dat$Value_str > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_str) & heat_dat$Value_str < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_str), "grey",
                                    ifelse(heat_dat$sig_str == 0, "grey90", 
                                           spec_color(heat_dat$Value_str[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(7, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_anx) & heat_dat$Value_anx > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_anx) & heat_dat$Value_anx < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_anx), "grey",
                                    ifelse(heat_dat$sig_anx == 0, "grey90", 
                                           spec_color(heat_dat$Value_anx[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(8, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_phb) & heat_dat$Value_phb > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_phb) & heat_dat$Value_phb < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_phb), "grey",
                                    ifelse(heat_dat$sig_phb == 0, "grey90", 
                                           spec_color(heat_dat$Value_phb[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(9, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_ptsd) & heat_dat$Value_ptsd > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_ptsd) & heat_dat$Value_ptsd < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_ptsd), "grey",
                                    ifelse(heat_dat$sig_ptsd == 0, "grey90", 
                                           spec_color(heat_dat$Value_ptsd[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(10, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_som) & heat_dat$Value_som > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_som) & heat_dat$Value_som < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_som), "grey",
                                    ifelse(heat_dat$sig_som == 0, "grey90", 
                                           spec_color(heat_dat$Value_som[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(12, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_psy) & heat_dat$Value_psy > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_psy) & heat_dat$Value_psy < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_psy), "grey",
                                    ifelse(heat_dat$sig_psy == 0, "grey90", 
                                           spec_color(heat_dat$Value_psy[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    
    column_spec(14, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_oth) & heat_dat$Value_oth > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_oth) & heat_dat$Value_oth < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_oth), "grey",
                                    ifelse(heat_dat$sig_oth == 0, "grey90", 
                                           spec_color(heat_dat$Value_oth[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(15, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_slp) & heat_dat$Value_slp > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_slp) & heat_dat$Value_slp < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_slp), "grey",
                                    ifelse(heat_dat$sig_slp == 0, "grey90", 
                                           spec_color(heat_dat$Value_slp[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(16, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sex) & heat_dat$Value_sex > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sex) & heat_dat$Value_sex < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sex), "grey",
                                    ifelse(heat_dat$sig_sex == 0, "grey90", 
                                           spec_color(heat_dat$Value_sex[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(17,
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_per) & heat_dat$Value_per > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_per) & heat_dat$Value_per < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_per), "grey",
                                    ifelse(heat_dat$sig_per == 0, "grey90", 
                                           spec_color(heat_dat$Value_per[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%
    column_spec(18, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sui) & heat_dat$Value_sui > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sui) & heat_dat$Value_sui < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sui), "grey",
                                    ifelse(heat_dat$sig_sui == 0, "grey90", 
                                           spec_color(heat_dat$Value_sui[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(low, 10))))) %>%

        row_spec(3,  background = "white") %>%
    row_spec(10, background = "white") %>%
    row_spec(12, background = "white") %>%
    
    remove_column(19:32) %>%
    
    add_header_above(c(" " = 1, "Male Diagnosis" = 17)) %>%
    
    return(heat_table)
}

prim_HM   <- make_heatmap(prim_flip, low = 0.8)
rand_HM   <- make_heatmap(rand_flip, low = 0.4)

no_m_com <- make_heatmap(noMCom_flip, low = 0.8)
no_f_com <- make_heatmap(noFCom_flip, low = 0.8)

prim_HM
rand_HM

no_m_com
no_f_com

readr::write_file(prim_HM,  "Primary_Dec2024.html")
readr::write_file(no_m_com, "NoMCom_Dec2024.html")
readr::write_file(no_f_com, "NoFCom_Dec2024.html")
readr::write_file(rand_HM,  "Random_Dec2024.html")

#### Comorbidity 
comorbid <- read_csv("ORs_Comorbid_09Dec2024.csv") %>%
              mutate(MHDx1 = ifelse(str_sub(Table, 7, 13) %in% dx3, str_sub(Table, 7, 13), 
                             ifelse(str_sub(Table, 7, 14) %in% dx4, str_sub(Table, 7, 14),
                               NA)),
                     MHDx2 = ifelse(str_sub(Table, 17, 23) %in% dx3, str_sub(Table, 17, 23), 
                             ifelse(str_sub(Table, 17, 24) %in% dx4, str_sub(Table, 17, 24),
                             ifelse(str_sub(Table, 18, 24) %in% dx3, str_sub(Table, 18, 24), 
                             ifelse(str_sub(Table, 18, 25) %in% dx4, str_sub(Table, 18, 25),
                               NA)))),
                     MHDx_1_long = mapvalues(MHDx1, from = short_dx, to = long_dx),
                     MHDx_2_long = mapvalues(MHDx2, from = short_dx, to = long_dx),
                     mh1 = str_replace(MHDx1, "any_", ""),
                     mh2 = str_replace(MHDx2, "any_", "")) %>%
              select(-Table, -StudyType, -Statistic, -MHDx1, -MHDx2, -MHDx_1_long) %>%
              pivot_wider(names_from = mh1, values_from = c(Value, LowerCL, UpperCL, sig)) 

comorbid <- comorbid[c(14,1,2,3,4,5,6,7,8,9,10,11,12,13),]

heat_dat <- comorbid %>%
              select(MHDx_2_long,
                     Value_sub,
                     Value_adhd,
                     Value_dep,
                     Value_str,
                     Value_anx,
                     Value_phb,
                     Value_ptsd,
                     Value_som,
                     Value_psy,
                     Value_oth,
                     Value_slp,
                     Value_sex,
                     Value_per) %>%
              mutate(space1 = NA,
                     space2 = NA,
                     space3 = NA) %>%
              relocate(space1, .after = Value_adhd) %>%
              relocate(space2, .after = Value_som) %>%
              relocate(space3, .after = Value_psy) %>%
              add_row() 

heat_dat <- heat_dat[c(1,2,15,3,4,5,6,7,8,9,10,11,12,13,14),] %>% add_row()
heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,16,10,11,12,13,14,15),] %>% add_row()
heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,10,11,17,12,13,14,15,16),]

heat_dat <- heat_dat[c(2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17),] %>%
            mutate(Value_dep = ifelse(MHDx_2_long == "ADHD", NA, Value_dep),
                   Value_str = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression"), NA, Value_str),
                   Value_anx = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction"), NA, Value_anx),
                   Value_phb = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction",
                                                         "Anxiety"), NA, Value_phb),
                   Value_ptsd = ifelse(MHDx_2_long %in% c("ADHD",
                                                          "Depression",
                                                          "Acute Stress Reaction",
                                                          "Anxiety",
                                                          "Phobia / Compulsive Disorder"), NA, Value_ptsd),
                   Value_som = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction",
                                                         "Anxiety",
                                                         "Phobia / Compulsive Disorder",
                                                         "PTSD"), NA, Value_som),
                   Value_psy = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction",
                                                         "Anxiety",
                                                         "Phobia / Compulsive Disorder",
                                                         "PTSD",
                                                         "Somatization"), NA, Value_psy),
                   Value_oth = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction",
                                                         "Anxiety",
                                                         "Phobia / Compulsive Disorder",
                                                         "PTSD",
                                                         "Somatization",
                                                         "Psychosis"), NA, Value_oth),
                   Value_slp = ifelse(MHDx_2_long %in% c("ADHD",
                                                          "Depression",
                                                          "Acute Stress Reaction",
                                                          "Anxiety",
                                                          "Phobia / Compulsive Disorder",
                                                          "PTSD",
                                                          "Somatization",
                                                          "Psychosis",
                                                          "NOS"), NA, Value_slp),
                   Value_sex = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction",
                                                         "Anxiety",
                                                         "Phobia / Compulsive Disorder",
                                                         "PTSD",
                                                         "Somatization",
                                                         "Psychosis",
                                                         "NOS",
                                                         "Sleep Disturbance"), NA, Value_sex),
                   Value_per = ifelse(MHDx_2_long %in% c("ADHD",
                                                         "Depression",
                                                         "Acute Stress Reaction",
                                                         "Anxiety",
                                                         "Phobia / Compulsive Disorder",
                                                         "PTSD",
                                                         "Somatization",
                                                         "Psychosis",
                                                         "NOS",
                                                         "Sleep Disturbance",
                                                         "Sexual Concern"), NA, Value_per))

# Set how to display NA in table
opts <- options(knitr.kable.NA = " ")

com_HM <- kable(heat_dat, escape = F, 
                    align = "rcccccccccccccccc", 
                    digits = 1, 
                    booktabs = T,
                    
                    # Set up column names
                    col.names = c("Diagnosis", 
                                  "Substance Abuse", "ADHD", " ", 
                                  "Depression", "Acute Stress Reaction", "Anxiety", "Phobia / Compulsive disorder",
                                  "PTSD", "Somatization",  " ",
                                  "Psychosis", " ",
                                  "NOS", "Sleep Disturbance", "Sexual concern", "Personality Disorder")) %>%
  
  kable_paper(c("basic", "condensed"), full_width = T) %>%
  
  add_header_above(c(" " = 1, "Diagnosis" = 16)) %>%
  
  column_spec(1, 
              width = '1.25in', 
              bold  = T) %>%
  
  column_spec(2, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_sub), "black",
                                  ifelse(heat_dat$Value_sub > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_sub), "white",
                             ifelse(heat_dat$Value_sub > 10, "red",
                                  spec_color(heat_dat$Value_sub[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(3, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_adhd), "black",
                                  ifelse(heat_dat$Value_adhd > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_adhd), "white",
                             ifelse(heat_dat$Value_adhd > 10, "red",
                                  spec_color(heat_dat$Value_adhd[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(5, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_dep), "black",
                                  ifelse(heat_dat$Value_dep > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_dep), "white",
                             ifelse(heat_dat$Value_dep > 10, "red",
                                  spec_color(heat_dat$Value_dep[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(6, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_str), "black",
                                  ifelse(heat_dat$Value_str > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_str), "white",
                             ifelse(heat_dat$Value_str > 10, "red",
                                  spec_color(heat_dat$Value_str[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(7, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_anx), "black",
                                  ifelse(heat_dat$Value_anx > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_anx), "white", 
                             ifelse(heat_dat$Value_anx > 10, "red",
                                  spec_color(heat_dat$Value_anx[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10)))) )%>% 
  column_spec(8, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_phb), "black",
                                  ifelse(heat_dat$Value_phb > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_phb), "white",
                             ifelse(heat_dat$Value_phb > 10, "red",
                                  spec_color(heat_dat$Value_phb[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(9, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_ptsd), "black",
                                  ifelse(heat_dat$Value_ptsd > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_ptsd), "white",
                             ifelse(heat_dat$Value_ptsd > 10, "red",
                                  spec_color(heat_dat$Value_ptsd[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(10, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_som), "black",
                                  ifelse(heat_dat$Value_som > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_som), "white",
                             ifelse(heat_dat$Value_som > 10, "red",
                                  spec_color(heat_dat$Value_som[1:25], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(12, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_psy), "black",
                                  ifelse(heat_dat$Value_psy > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_psy), "white",
                             ifelse(heat_dat$Value_psy > 10, "red",
                                  spec_color(heat_dat$Value_psy[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(14, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_oth), "black",
                                  ifelse(heat_dat$Value_oth > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_oth), "white",
                             ifelse(heat_dat$Value_oth > 10, "red",
                                  spec_color(heat_dat$Value_oth[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(15, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_slp), "black",
                                  ifelse(heat_dat$Value_slp > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_slp), "white",
                             ifelse(heat_dat$Value_slp > 10, "red",
                                  spec_color(heat_dat$Value_slp[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(16, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_sex), "black",
                                  ifelse(heat_dat$Value_sex > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_sex), "white",
                             ifelse(heat_dat$Value_sex > 10, "red",
                                  spec_color(heat_dat$Value_sex[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  column_spec(17, 
              width      = '0.75in',
              bold       = T,
              color      = ifelse(is.na(heat_dat$Value_per), "black",
                                  ifelse(heat_dat$Value_per > 5, "white", "black")),
              background = ifelse(is.na(heat_dat$Value_per), "white",
                             ifelse(heat_dat$Value_per > 10, "red",
                                  spec_color(heat_dat$Value_per[1:16], 
                                             end = 1, direction = -1, option = "magma",
                                             scale_from = c(0.8, 10))))) %>% 
  
  row_spec(2,  background = "white") %>%
  row_spec(9,  background = "white") %>%
  row_spec(11, background = "white") 

com_HM

readr::write_file(com_HM, "Comorbidity_Dec2024.html")

## Descriptive table
everyone <- read.csv("AssortativeMating_Prevalence_09Dec2024.csv")
everyone <- everyone[1:15,] %>%
            mutate(who = "focal_mf_all")

other <- read.csv("AssortativeMating_Prevalence_09Dec2024.csv")
other <- other[16:165,]

random <- read.csv("AssortativeMating_RandomPrevalence_18Dec2024.csv")

descriptive <- bind_rows(everyone, other) %>%
               bind_rows(random) %>%
                pivot_wider(names_from = who, values_from = c(all_n, all_p)) %>%
                select(code, all_n_focal_mf_all, all_p_focal_mf_all,
                             all_n_focal_m_all,  all_p_focal_m_all, 
                             all_n_focal_f_all,  all_p_focal_f_all, 
                             all_n_focal_mf_al,  all_p_focal_mf_al,
                             all_n_focal_m,      all_p_focal_m, 
                             all_n_focal_f,      all_p_focal_f, 
                             all_n_primary_mf_,  all_p_primary_mf_,
                             all_n_primary_m,    all_p_primary_m, 
                             all_n_primary_f,    all_p_primary_f, 
                             all_n_partnered_m,  all_p_partnered_m, 
                             all_n_partnered_f,  all_p_partnered_f,
                             all_n_random_m,     all_p_random_m,
                             all_n_random_f,     all_p_random_f)

write_csv(descriptive, "Descriptive_Table.csv")    


#### **Summarize Diagonal & Off-Diagonal OR's**
primary   <- read_dat_mf(OR_file = "ORs_PrimaryPartner_22Oct2024.csv") %>%
              mutate(mfamily = mapvalues(MHDx_m, from = short_dx, to = family),
                     ffamily = mapvalues(MHDx_f, from = short_dx, to = family),
                     diag    = ifelse(fmh == mmh, 1, 0))

Mean_diag    <- primary %>% group_by(diag) %>% summarise_at(vars(Value), list(name = mean)) %>% 
                  rename(Mean = name)
Mean_fam     <- primary %>% group_by(ffamily, mfamily) %>% summarise_at(vars(Value), list(name = mean)) %>% 
                  rename(Mean = name)
Mean_famdiag <- primary %>% group_by(ffamily, mfamily, diag) %>% 
                  summarise_at(vars(Value), list(name = mean)) %>% 
                  rename(Mean = name)

SD_diag    <- primary %>% group_by(diag) %>% summarise_at(vars(Value), list(name = sd)) %>%
                rename(SD = name)
SD_fam     <- primary %>% group_by(ffamily, mfamily) %>% summarise_at(vars(Value), list(name = sd)) %>% 
                rename(SD = name)
SD_famdiag <- primary %>% group_by(ffamily, mfamily, diag) %>% 
                summarise_at(vars(Value), list(name = sd)) %>% 
                rename(SD = name)

MSd_diag    <- full_join(Mean_diag,    SD_diag,    by = "diag")
MSd_fam     <- full_join(Mean_fam,     SD_fam,     by = c("ffamily", "mfamily"))
MSd_famdiag <- full_join(Mean_famdiag, SD_famdiag, by = c("ffamily", "mfamily", "diag"))

kable(MSd_diag,    escape = F, digits = 3, booktabs = T) %>% kable_paper(c("basic", "condensed"), full_width = T) 
kable(MSd_fam,     escape = F, digits = 3, booktabs = T) %>% kable_paper(c("basic", "condensed"), full_width = T) 
kable(MSd_famdiag, escape = F, digits = 3, booktabs = T) %>% kable_paper(c("basic", "condensed"), full_width = T) 

