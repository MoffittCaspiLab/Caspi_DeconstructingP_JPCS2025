###############################################################################
# For:        Norway
# Paper:      Three Reasons Paper
# Programmer: Renate Houts
# File:       ThreeReasons_SEM_Read_Nov2024.R
# Date:       18-Nov-2024
#
# Purpose:    Read in final model parameters & create square matrix
###############################################################################

library(tidyverse)
library(haven)
library(plotly)
library(viridis)

setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/SEMModel")

params <- read_csv("ModelParams_Dec2024_NoMisc.csv") %>% 
            filter(!is.na(z) & op == "~~") %>%
            select(lhs, rhs, est) %>%
            mutate(lhs1 = rhs,
                   rhs1 = lhs,
                   est1 = est)

params1 <- params %>% select(lhs1, rhs1, est1) %>%
              rename(lhs = lhs1, rhs = rhs1, est = est1)
params  <- params %>% select(lhs, rhs, est)

params_NoMisc <- bind_rows(params, params1) %>%
                  pivot_wider(names_from = rhs, values_from = est) %>%
                  select(lhs, dd_ext, dd_int, dd_thd, dm_ext, dm_int, dm_thd,
                              md_ext, md_int, md_thd, mm_ext, mm_int, mm_thd,
                              d_ext,  d_int,  d_thd,  m_ext,  m_int,  m_thd,
                              c_ext,  c_int,  c_thd)

params_NoMisc <- params_NoMisc[c(13,14,21,11,12,17,9,10,20,7,8,16,5,6,18,3,4,15,1,2,19),]

write_csv(params_NoMisc, "NoMisc_Table.csv") 

params <- read_csv("ModelParams_Dec2024_Misc.csv") %>% 
            filter(!is.na(z) & op == "~~") %>%
            select(lhs, rhs, est) %>%
            mutate(lhs1 = rhs,
                   rhs1 = lhs,
                   est1 = est)

params1 <- params %>% select(lhs1, rhs1, est1) %>%
              rename(lhs = lhs1, rhs = rhs1, est = est1)
params  <- params %>% select(lhs, rhs, est)

params_Misc <- bind_rows(params, params1) %>%
                pivot_wider(names_from = rhs, values_from = est) %>%
                select(lhs, dd_ext, dd_int, dd_thd, dm_ext, dm_int, dm_thd,
                            md_ext, md_int, md_thd, mm_ext, mm_int, mm_thd,
                            d_ext,  d_int,  d_thd,  m_ext,  m_int,  m_thd,
                            c_ext,  c_int,  c_thd)

params_Misc <- params_Misc[c(17,18,21,15,16,19,1,2,3,4,5,6,13,14,20,7,8,9,10,11,12),]
write_csv(params_Misc, "Misc_Table.csv") 

params <- read_csv("ModelParams_Dec2024_OneKidNoMisc.csv") %>% 
            filter(!is.na(z) & op == "~~") %>%
            select(lhs, rhs, est) %>%
            mutate(lhs1 = rhs,
                   rhs1 = lhs,
                   est1 = est)

params1 <- params %>% select(lhs1, rhs1, est1) %>%
              rename(lhs = lhs1, rhs = rhs1, est = est1)
params  <- params %>% select(lhs, rhs, est)

params_NoMisc1 <- bind_rows(params, params1) %>%
                    pivot_wider(names_from = rhs, values_from = est) %>%
                    select(lhs, dd_ext, dd_int, dd_thd, dm_ext, dm_int, dm_thd,
                                md_ext, md_int, md_thd, mm_ext, mm_int, mm_thd,
                                d_ext,  d_int,  d_thd,  m_ext,  m_int,  m_thd,
                                c_ext,  c_int,  c_thd)

params_NoMisc1 <- params_NoMisc1[c(13,14,21,11,12,17,9,10,20,7,8,16,5,6,18,3,4,15,1,2,19),]
write_csv(params_NoMisc1, "NoMisc_1Kid_Table.csv") 

params <- read_csv("ModelParams_Dec2024_OneKidMisc.csv") %>% 
            filter(!is.na(z) & op == "~~") %>%
            select(lhs, rhs, est) %>%
            mutate(lhs1 = rhs,
                   rhs1 = lhs,
                   est1 = est)

params1 <- params %>% select(lhs1, rhs1, est1) %>%
              rename(lhs = lhs1, rhs = rhs1, est = est1)
params  <- params %>% select(lhs, rhs, est)

params_Misc1 <- bind_rows(params, params1) %>%
                  pivot_wider(names_from = rhs, values_from = est) %>%
                  select(lhs, dd_ext, dd_int, dd_thd, dm_ext, dm_int, dm_thd,
                              md_ext, md_int, md_thd, mm_ext, mm_int, mm_thd,
                              d_ext,  d_int,  d_thd,  m_ext,  m_int,  m_thd,
                              c_ext,  c_int,  c_thd)

params_Misc1 <- params_Misc1[c(17,18,21,15,16,19,1,2,3,4,5,6,13,14,20,7,8,9,10,11,12),]
write_csv(params_Misc1, "Misc_1Kid_Table.csv")   


params <- read_csv("ModelParams_Dec2024_OneKidMisc.csv") %>% 
            filter(!is.na(z) & op == "~~") %>%
            select(lhs, rhs, est, pvalue) %>%
            mutate(lhs1 = rhs,
                   rhs1 = lhs,
                   est1 = est,
                   pvalue1 = pvalue)

params1 <- params %>% select(lhs1, rhs1, est1, pvalue1) %>%
              rename(lhs = lhs1, rhs = rhs1, est = est1, pvalue = pvalue1)
params  <- params %>% select(lhs, rhs, est, pvalue)

params_Misc <- bind_rows(params, params1) %>%
                pivot_wider(names_from = rhs, values_from = c(est, pvalue)) %>%
                select(lhs, est_dd_ext, est_dd_int, est_dd_thd, est_dm_ext, est_dm_int, est_dm_thd,
                            est_md_ext, est_md_int, est_md_thd, est_mm_ext, est_mm_int, est_mm_thd,
                            est_d_ext,  est_d_int,  est_d_thd,  est_m_ext,  est_m_int,  est_m_thd,
                            est_c_ext,  est_c_int,  est_c_thd,
                       pvalue_dd_ext, pvalue_dd_int, pvalue_dd_thd, pvalue_dm_ext, pvalue_dm_int, pvalue_dm_thd,
                       pvalue_md_ext, pvalue_md_int, pvalue_md_thd, pvalue_mm_ext, pvalue_mm_int, pvalue_mm_thd,
                       pvalue_d_ext,  pvalue_d_int,  pvalue_d_thd,  pvalue_m_ext,  pvalue_m_int,  pvalue_m_thd,
                       pvalue_c_ext,  pvalue_c_int,  pvalue_c_thd)

params_Misc <- params_Misc[c(17,18,21,15,16,19,1,2,3,4,5,6,13,14,20,7,8,9,10,11,12),]
write_csv(params_Misc, "Misc1_pvalues_.csv")