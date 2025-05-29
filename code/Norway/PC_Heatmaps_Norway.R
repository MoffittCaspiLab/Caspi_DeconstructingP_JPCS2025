###############################################################################
# For:        Norway
# Paper:      Three Reasons Paper
# Programmer: Renate Houts
# File:       PCHeatmaps_Norway.r
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

sessionInfo()

# Parent-Child Directory
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/ParentChild/Output from Norway")


# Vectors to help map variables names
family   <- c("All", "Ext", "Ext", "Ext", 
              "Int", "Int", "Int", "Int", "Int", "Int",
              "ThD",
              "Other", "Other", "Other", "Other", "Other", "Other", "Other", "Other")
short_dx <- c("any_MH",  "any_sub", "any_adhd", "any_chad", 
              "any_dep", "any_str", "any_anx", "any_phb", "any_ptsd", "any_som", 
              "any_psy", 
              "any_oth", "any_slp", "any_sex", "any_per", "any_sui", "any_con", "any_dev", "any_stm")
long_dx <- c("Any Mental Health Disorder",
             "Substance Abuse",
             "ADHD",
             "Child / Adolescent behavior symptom / complaint",
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
             "Suicide / Suicide Attempt", 
             "Continence issues",
             "Developmental delay / Learning problem",
             "Stammering / Stuttering / Tic")

dx3 <- c("any_sub", 
         "any_dep", "any_str", "any_anx", "any_phb", "any_som", 
         "any_psy", 
         "any_oth", "any_slp", "any_sex", "any_per", "any_sui", "any_con", "any_dev", "any_stm")
dx4 <- c("any_adhd", "any_chad", "any_ptsd")

read_dat <- function (OR_file){
  
  OR <- read_csv(OR_file) %>%
          mutate(MHDx_c = ifelse(str_sub(Table, 7, 12) == "any_MH", "any_MH",
                          ifelse(str_sub(Table, 7, 13) %in% dx3, str_sub(Table, 7, 13), 
                          ifelse(str_sub(Table, 7, 14) %in% dx4, str_sub(Table, 7, 14),
                              NA))),
                 MHDx_p = ifelse(str_sub(Table, 20, 25) == "any_MH", "any_MH",
                          ifelse(str_sub(Table, 20, 26) %in% dx3, str_sub(Table, 20, 26), 
                          ifelse(str_sub(Table, 20, 27) %in% dx4, str_sub(Table, 20, 27),
                          ifelse(str_sub(Table, 19, 24) == "any_MH", "any_MH",
                          ifelse(str_sub(Table, 19, 25) %in% dx3, str_sub(Table, 19, 25), 
                          ifelse(str_sub(Table, 19, 26) %in% dx4, str_sub(Table, 19, 26),
                          ifelse(str_sub(Table, 18, 23) == "any_MH", "any_MH",
                          ifelse(str_sub(Table, 18, 24) %in% dx3, str_sub(Table, 18, 24), 
                          ifelse(str_sub(Table, 18, 25) %in% dx4, str_sub(Table, 18, 25),
                              NA))))))))),
                MHDx_c_long = mapvalues(MHDx_c, from = short_dx, to = long_dx),
                MHDX_p_long = mapvalues(MHDx_p, from = short_dx, to = long_dx),
                cfamily     = mapvalues(MHDx_c, from = short_dx, to = family),
                pfamily     = mapvalues(MHDx_p, from = short_dx, to = family),
                cmh = str_replace(MHDx_c, "any_", ""),
                pmh = str_replace(MHDx_p, "any_", "")) 
  return(OR)
}

Either <- read_dat(OR_file = "ORs_EitherParent_14Oct2024.csv") %>% rename(Value = Estimate)
Mother <- read_dat(OR_file = "ORs_Mother_14Oct2024.csv") %>% rename(Value = Estimate)
Father <- read_dat(OR_file = "ORs_Father_14Oct2024.csv") %>% rename(Value = Estimate)
Random <- read_dat(OR_file = "ORs_RandomParent_15Oct2024.csv")

NoCCom <- read_dat(OR_file = "ORs_EitherNoCCom_28Oct2024.csv") %>% rename(Value = Estimate) %>% distinct(.keep_all = TRUE)
NoPCom <- read_dat(OR_file = "ORs_EitherNoPCom_14Oct2024.csv") %>% rename(Value = Estimate) %>% distinct(.keep_all = TRUE)


flip_dat <- function (OR) {
  
  OR_Frq <- OR %>% 
            select(-Table, -Statistic, -MHDx_c, -MHDx_p, -cfamily, -pfamily, -MHDX_p_long) %>%
            pivot_wider(names_from = pmh, values_from = c(Value, LowerCL, UpperCL, sig)) %>%
            mutate(adhd_CI = paste0("(", sprintf("%.1f", round(LowerCL_adhd, 2)), ", ",
                             sprintf("%.1f", round(UpperCL_adhd, 2)), ")"),
                   sub_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sub,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sub,  2)), ")"),
                   dep_CI  = paste0("(", sprintf("%.1f", round(LowerCL_dep,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_dep,  2)), ")"),
                   str_CI  = paste0("(", sprintf("%.1f", round(LowerCL_str,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_str,  2)), ")"),
                   anx_CI  = paste0("(", sprintf("%.1f", round(LowerCL_anx,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_anx,  2)), ")"),
                   phb_CI  = paste0("(", sprintf("%.1f", round(LowerCL_phb,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_phb,  2)), ")"),
                   ptsd_CI = paste0("(", sprintf("%.1f", round(LowerCL_ptsd, 2)), ", ", 
                             sprintf("%.1f", round(UpperCL_ptsd, 2)), ")"),
                   som_CI  = paste0("(", sprintf("%.1f", round(LowerCL_som,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_som,  2)), ")"),
                   psy_CI  = paste0("(", sprintf("%.1f", round(LowerCL_psy,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_psy,  2)), ")"),
                   oth_CI  = paste0("(", sprintf("%.1f", round(LowerCL_oth,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_oth,  2)), ")"),
                   slp_CI  = paste0("(", sprintf("%.1f", round(LowerCL_slp,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_slp,  2)), ")"),
                   sex_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sex,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sex,  2)), ")"),
                   per_CI  = paste0("(", sprintf("%.1f", round(LowerCL_per,  2)), ", ", 
                             sprintf("%.1f", round(UpperCL_per,  2)), ")",
                   sui_CI  = paste0("(", sprintf("%.1f", round(LowerCL_sui,  2)), ", ",
                             sprintf("%.1f", round(UpperCL_sui,  2)), ")")))
  return(OR_Frq)
}

Either_flip <- flip_dat(Either) %>% filter(cmh != "MH")
Mother_flip <- flip_dat(Mother) %>% filter(cmh != "MH")
Father_flip <- flip_dat(Father) %>% filter(cmh != "MH")
Random_flip <- flip_dat(Random) %>% filter(cmh != "MH")
Random_flip <- Random_flip[c(3,2,1,4,6,5,7,9,8,10,14,11,17,18,16,12,13,15),]

NoCCom_flip <- flip_dat(NoCCom)
NoPCom_flip <- flip_dat(NoPCom)

## Function to Create OR Heat map
make_heatmap <- function(df) {
  
  heat_dat <- df %>%
                select(MHDx_c_long,
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
                       sig_dep,
                       sig_anx,
                       sig_str,
                       sig_phb,
                       sig_som,
                       sig_ptsd,
                       sig_psy,
                       sig_slp,
                       sig_oth,
                       sig_sui,
                       sig_sex,
                       sig_per) %>%
                mutate(space1 = NA,
                       space2 = NA,
                       space3 = NA ) %>%
                relocate(space1, .after = Value_adhd) %>%
                relocate(space2, .after = Value_som) %>%
                relocate(space3, .after = Value_psy) %>%
                add_row() 
  
  heat_dat <- heat_dat[c(1,2,3,19,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,10,20,11,12,13,14,15,16,17,18,19),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,10,11,12,21,13,14,15,16,17,18,19,20),]
  
  # Set how to display NA in table
  opts <- options(knitr.kable.NA = " ")
  
  heat_table <- kable(heat_dat, escape = F, 
                      align = "rcccccccccccccccccccccccccccccccc", 
                      digits = 1, 
                      booktabs = T,
                      
                      # Set up column names
                      col.names = c("Child Diagnosis",
                                    "Substance Abuse", "ADHD", " ", 
                                    "Depression", "Acute Stress Reaction", "Anxiety", "Phobia / Compulsive disorder",
                                    "PTSD", "Somatization",  " ",
                                    "Psychosis", " ",
                                    "NOS", "Sleep Disturbance", "Sexual concern", "Personality Disorder", 
                                    "Suicide / Suicide Attempt", 
                                    " ", " ",
                                    " ", " ", " "," ", " ", " ",
                                    " ",
                                    " ", " ", " ", " ", " ")) %>%
    
    kable_paper(c("basic", "condensed"), full_width = T) %>%
    
    add_header_above(c(" " = 1, "Parent Diagnosis" = 31)) %>%
    
    column_spec(2, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sub) & heat_dat$Value_sub > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sub) & heat_dat$Value_sub < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sub), "grey",
                                    ifelse(heat_dat$sig_sub == 0, "grey90", 
                                           spec_color(heat_dat$Value_sub[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(3, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_adhd) & heat_dat$Value_adhd > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_adhd) & heat_dat$Value_adhd < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_adhd), "grey",
                                    ifelse(heat_dat$sig_adhd == 0, "grey90", 
                                           spec_color(heat_dat$Value_adhd[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(5, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_dep) & heat_dat$Value_dep > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_dep) & heat_dat$Value_dep < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_dep), "grey",
                                    ifelse(heat_dat$sig_dep == 0, "grey90", 
                                           spec_color(heat_dat$Value_dep[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(6, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_str) & heat_dat$Value_str > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_str) & heat_dat$Value_str < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_str), "grey",
                                    ifelse(heat_dat$sig_str == 0, "grey90", 
                                           spec_color(heat_dat$Value_str[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(7, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_anx) & heat_dat$Value_anx > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_anx) & heat_dat$Value_anx < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_anx), "grey",
                                    ifelse(heat_dat$sig_anx == 0, "grey90", 
                                           spec_color(heat_dat$Value_anx[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(8, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_phb) & heat_dat$Value_phb > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_phb) & heat_dat$Value_phb < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_phb), "grey",
                                    ifelse(heat_dat$sig_phb == 0, "grey90", 
                                           spec_color(heat_dat$Value_phb[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(9, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_ptsd) & heat_dat$Value_ptsd > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_ptsd) & heat_dat$Value_ptsd < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_ptsd), "grey",
                                    ifelse(heat_dat$sig_ptsd == 0, "grey90", 
                                           spec_color(heat_dat$Value_ptsd[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(10, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_som) & heat_dat$Value_som > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_som) & heat_dat$Value_som < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_som), "grey",
                                    ifelse(heat_dat$sig_som == 0, "grey90", 
                                           spec_color(heat_dat$Value_som[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(12, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_psy) & heat_dat$Value_psy > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_psy) & heat_dat$Value_psy < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_psy), "grey",
                                    ifelse(heat_dat$sig_psy == 0, "grey90", 
                                           spec_color(heat_dat$Value_psy[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    
    column_spec(14, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_oth) & heat_dat$Value_oth > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_oth) & heat_dat$Value_oth < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_oth), "grey",
                                    ifelse(heat_dat$sig_oth == 0, "grey90", 
                                           spec_color(heat_dat$Value_oth[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(15, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_slp) & heat_dat$Value_slp > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_slp) & heat_dat$Value_slp < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_slp), "grey",
                                    ifelse(heat_dat$sig_slp == 0, "grey90", 
                                           spec_color(heat_dat$Value_slp[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(16, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sex) & heat_dat$Value_sex > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sex) & heat_dat$Value_sex < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sex), "grey",
                                    ifelse(heat_dat$sig_sex == 0, "grey90", 
                                           spec_color(heat_dat$Value_sex[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(17,
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_per) & heat_dat$Value_per > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_per) & heat_dat$Value_per < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_per), "grey",
                                    ifelse(heat_dat$sig_per == 0, "grey90", 
                                           spec_color(heat_dat$Value_per[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(18, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sui) & heat_dat$Value_sui > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sui) & heat_dat$Value_sui < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sui), "grey",
                                    ifelse(heat_dat$sig_sui == 0, "grey90", 
                                           spec_color(heat_dat$Value_sui[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    
    row_spec(4,  background = "white") %>%
    row_spec(11, background = "white") %>%
    row_spec(13, background = "white") %>%
    
    remove_column(19:32)
  
  return(heat_table)
}


Either_HM <- make_heatmap(Either_flip)
Mother_HM <- make_heatmap(Mother_flip)
Father_HM <- make_heatmap(Father_flip)
Random_HM <- make_heatmap(Random_flip)
NoCCom_HM <- make_heatmap(NoCCom_flip)

Either_HM
Mother_HM
Father_HM
Random_HM
NoCCom_HM

## Function to Create OR Heat map
make_heatmap1 <- function(df) {
  
  heat_dat <- df %>%
              select(MHDx_c_long,
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
                     sig_dep,
                     sig_anx,
                     sig_str,
                     sig_phb,
                     sig_som,
                     sig_ptsd,
                     sig_psy,
                     sig_slp,
                     sig_oth,
                     sig_sui,
                     sig_sex,
                     sig_per) %>%
              mutate(space1 = NA,
                     space2 = NA,
                     space3 = NA ) %>%
              relocate(space1, .after = Value_adhd) %>%
              relocate(space2, .after = Value_som) %>%
              relocate(space3, .after = Value_psy) %>%
              add_row() 
  
  heat_dat <- heat_dat[c(1,2,15,3,4,5,6,7,8,9,10,11,12,13,14),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,16,10,11,12,13,14,15),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,10,11,17,12,13,14,15,16),]
  
  # Set how to display NA in table
  opts <- options(knitr.kable.NA = " ")
  
  heat_table <- kable(heat_dat, escape = F, 
                      align = "rcccccccccccccccccccccccccccccccc", 
                      digits = 1, 
                      booktabs = T,
                      
                      # Set up column names
                      col.names = c("Child Diagnosis",
                                    "Substance Abuse", "ADHD", " ", 
                                    "Depression", "Acute Stress Reaction", "Anxiety", "Phobia / Compulsive disorder",
                                    "PTSD", "Somatization",  " ",
                                    "Psychosis", " ",
                                    "NOS", "Sleep Disturbance", "Sexual concern", "Personality Disorder", 
                                    "Suicide / Suicide Attempt", 
                                    " ", " ",
                                    " ", " ", " "," ", " ", " ",
                                    " ",
                                    " ", " ", " ", " ", " ")) %>%
    
    kable_paper(c("basic", "condensed"), full_width = T) %>%
    
    add_header_above(c(" " = 1, "Parent Diagnosis" = 31)) %>%
    
    column_spec(2, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sub) & heat_dat$Value_sub > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sub) & heat_dat$Value_sub < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sub), "grey",
                                    ifelse(heat_dat$sig_sub == 0, "grey90", 
                                           spec_color(heat_dat$Value_sub[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(3, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_adhd) & heat_dat$Value_adhd > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_adhd) & heat_dat$Value_adhd < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_adhd), "grey",
                                    ifelse(heat_dat$sig_adhd == 0, "grey90", 
                                           spec_color(heat_dat$Value_adhd[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(5, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_dep) & heat_dat$Value_dep > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_dep) & heat_dat$Value_dep < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_dep), "grey",
                                    ifelse(heat_dat$sig_dep == 0, "grey90", 
                                           spec_color(heat_dat$Value_dep[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(6, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_str) & heat_dat$Value_str > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_str) & heat_dat$Value_str < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_str), "grey",
                                    ifelse(heat_dat$sig_str == 0, "grey90", 
                                           spec_color(heat_dat$Value_str[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(7, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_anx) & heat_dat$Value_anx > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_anx) & heat_dat$Value_anx < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_anx), "grey",
                                    ifelse(heat_dat$sig_anx == 0, "grey90", 
                                           spec_color(heat_dat$Value_anx[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(8, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_phb) & heat_dat$Value_phb > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_phb) & heat_dat$Value_phb < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_phb), "grey",
                                    ifelse(heat_dat$sig_phb == 0, "grey90", 
                                           spec_color(heat_dat$Value_phb[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(9, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_ptsd) & heat_dat$Value_ptsd > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_ptsd) & heat_dat$Value_ptsd < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_ptsd), "grey",
                                    ifelse(heat_dat$sig_ptsd == 0, "grey90", 
                                           spec_color(heat_dat$Value_ptsd[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(10, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_som) & heat_dat$Value_som > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_som) & heat_dat$Value_som < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_som), "grey",
                                    ifelse(heat_dat$sig_som == 0, "grey90", 
                                           spec_color(heat_dat$Value_som[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(12, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_psy) & heat_dat$Value_psy > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_psy) & heat_dat$Value_psy < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_psy), "grey",
                                    ifelse(heat_dat$sig_psy == 0, "grey90", 
                                           spec_color(heat_dat$Value_psy[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    
    column_spec(14, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_oth) & heat_dat$Value_oth > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_oth) & heat_dat$Value_oth < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_oth), "grey",
                                    ifelse(heat_dat$sig_oth == 0, "grey90", 
                                           spec_color(heat_dat$Value_oth[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(15, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_slp) & heat_dat$Value_slp > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_slp) & heat_dat$Value_slp < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_slp), "grey",
                                    ifelse(heat_dat$sig_slp == 0, "grey90", 
                                           spec_color(heat_dat$Value_slp[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(16, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sex) & heat_dat$Value_sex > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sex) & heat_dat$Value_sex < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sex), "grey",
                                    ifelse(heat_dat$sig_sex == 0, "grey90", 
                                           spec_color(heat_dat$Value_sex[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(17,
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_per) & heat_dat$Value_per > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_per) & heat_dat$Value_per < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_per), "grey",
                                    ifelse(heat_dat$sig_per == 0, "grey90", 
                                           spec_color(heat_dat$Value_per[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    column_spec(18, 
                width      = '0.75in',
                bold       = T,
                color      = ifelse(!is.na(heat_dat$Value_sui) & heat_dat$Value_sui > 5, "white", 
                                    ifelse(!is.na(heat_dat$Value_sui) & heat_dat$Value_sui < 1, "royalblue","black")),
                background = ifelse(is.na(heat_dat$sig_sui), "grey",
                                    ifelse(heat_dat$sig_sui == 0, "grey90", 
                                           spec_color(heat_dat$Value_sui[1:21], 
                                                      end = 1, direction = -1, option = "magma",
                                                      scale_from = c(0.6, 10))))) %>%
    
    row_spec(3,  background = "white") %>%
    row_spec(10, background = "white") %>%
    row_spec(12, background = "white") %>%
    
    remove_column(19:32)
  
  return(heat_table)
}

NoPCom_HM <- make_heatmap1(NoPCom_flip)
NoPCom_HM

## Descriptive table
descriptive <- read.csv("ParentChild_Prevalence_14Oct2024.csv") %>%
                select(Table, Frequency, Percent, CumFrequency, CumPercent) %>%
                mutate(who  = ifelse(str_sub(Table, 7, 9) == "any", "Child",
                              ifelse(str_sub(Table, 7, 9) == "m_a", "Mother", 
                              ifelse(str_sub(Table, 7, 9) == "d_a", "Father",
                              ifelse(str_sub(Table, 7, 9) == "e_a", "Either", NA)))),
                       withdx = ifelse(CumPercent == 100, 1, 0),
                       what   =  ifelse(str_sub(Table, 7, 12) == "any_MH", "any_MH",
                                 ifelse(str_sub(Table, 7, 13) %in% dx3, str_sub(Table, 7, 13), 
                                 ifelse(str_sub(Table, 7, 14) %in% dx4, str_sub(Table, 7, 14),
                                 ifelse(str_sub(Table, 9, 14) == "any_MH", "any_MH",
                                 ifelse(str_sub(Table, 9, 15) %in% dx3, str_sub(Table, 9, 15), 
                                 ifelse(str_sub(Table, 9, 16) %in% dx4, str_sub(Table, 9, 16),
                                    NA)))))),
                      what_long = mapvalues(what, from = short_dx, to = long_dx)) %>%
                filter(withdx == 1) %>%
                select(-Table, -withdx, -CumPercent, -CumFrequency, -what) %>%
                pivot_wider(names_from = who, values_from = c(Frequency, Percent)) %>%
                relocate(Percent_Child,    .after = Frequency_Child) %>%
                relocate(Frequency_Either, .after = Percent_Child) %>%
                relocate(Percent_Either,   .after = Frequency_Either) %>%
                relocate(Percent_Mother,   .after = Frequency_Mother)
                
write_csv(descriptive, "Descriptive_Table.csv")         
 