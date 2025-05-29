library(tidyverse)
library(readxl)
library(plotly)
library(readr)
library(kableExtra)
library(viridis)
library(formatR)

setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Dunedin") 
sessionInfo()

RRs <- read_xlsx('DunedinSeqComorbidity.xlsx',
                 sheet = "Sheet1",
                 skip = 1) %>%
            mutate(sig = ifelse(LCL <  1 & UCL >  1, 0,
                         ifelse(LCL >= 1 | UCL <= 1, 1, NA))) %>%
            select(From, To, RR, sig) %>%
            pivot_wider(., names_from = c(To), values_from = c(RR, sig))


heat_dat <- RRs %>%
              mutate(From = ifelse(From == "CD",           "Conduct Disorder",    From)) %>%
              mutate(From = ifelse(From == "Alcohol Dep",  "Alcohol Dependence",  From)) %>%
              mutate(From = ifelse(From == "Tobacco Dep",  "Tobacco Dependence",  From)) %>%
              mutate(From = ifelse(From == "Cannabis Dep", "Cannabis Dependence", From)) %>%
              mutate(From = ifelse(From == "Drug Dep",    "Drug Dependence",     From)) %>%
      mutate(space1 = NA,
             space2 = NA) %>%
      relocate(space1, .after = `RR_Drug Dep`) %>%
      relocate(space2, .after = RR_PTSD) %>%
      add_row() 

  heat_dat <- heat_dat[c(1,2,3,4,5,6,15,7,8,9,10,11,12,13,14),] %>% add_row()
  heat_dat <- heat_dat[c(1,2,3,4,5,6,7,8,9,10,11,12,16,13,14,15),]

  # Set how to display NA in table
  opts <- options(knitr.kable.NA = " ")

  heat_table <- kable(heat_dat, escape = F, align = "rcccccccccccccccccccccccccccccc", digits = 1, booktabs = T,
  
      # Set up column names
      col.names = c("From Earlier Diagnosis", 
                    "ADHD", "CD", "Alcohol Dependence ", "Tobacco Dependence", "Cannabis Dependence", 
                    "Drug Dependence", "", 
                    "Anxiety", "Depression", "Fears", "Eating Disorder", "PTSD", "",
                    "OCD", "Mania", "Schizophrenia", 
                    " ", " ", " ", " ", " ", " ", 
                    " ", " ", " ", " ", " ", 
                    " ", " ", " ")) %>%
  
      kable_paper(c("basic", "condensed"), full_width = T) %>%
  
      add_header_above(c(" " = 1, "To Subsequent Diagnosis" = 30)) %>%
  
      column_spec(1, 
                  width = '1.25in', 
                  bold  = T) %>%
  
      column_spec(2, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$RR_ADHD) & heat_dat$RR_ADHD > 5, "white", 
                               ifelse(!is.na(heat_dat$RR_ADHD) & heat_dat$RR_ADHD < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$sig_ADHD), "gray",
                               ifelse(heat_dat$sig_ADHD == 0, "gray90",
                               ifelse(heat_dat$RR_ADHD > 10, "red", 
                                      spec_color(heat_dat$RR_ADHD[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(3, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$RR_CD) & heat_dat$RR_CD > 5, "white", 
                               ifelse(!is.na(heat_dat$RR_CD) & heat_dat$RR_CD < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$sig_CD), "gray",
                               ifelse(heat_dat$sig_CD == 0, "gray90",
                               ifelse(heat_dat$RR_CD > 10, "red", 
                                      spec_color(heat_dat$RR_CD[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(4, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Alcohol Dep`) & heat_dat$`RR_Alcohol Dep` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Alcohol Dep`) & heat_dat$`RR_Alcohol Dep` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Alcohol Dep`), "gray",
                               ifelse(heat_dat$`sig_Alcohol Dep` == 0, "gray90",
                               ifelse(heat_dat$`RR_Alcohol Dep` > 10, "red", 
                                      spec_color(heat_dat$`RR_Alcohol Dep`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(5, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Tobacco Dep`) & heat_dat$`RR_Tobacco Dep` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Tobacco Dep`) & heat_dat$`RR_Tobacco Dep` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Tobacco Dep`), "gray",
                               ifelse(heat_dat$`sig_Tobacco Dep` == 0, "gray90",
                               ifelse(heat_dat$`RR_Tobacco Dep` > 10, "red", 
                                      spec_color(heat_dat$`RR_Tobacco Dep`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(6, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Cannabis Dep`) & heat_dat$`RR_Cannabis Dep` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Cannabis Dep`) & heat_dat$`RR_Cannabis Dep` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Cannabis Dep`), "gray",
                               ifelse(heat_dat$`sig_Cannabis Dep` == 0, "gray90",
                               ifelse(heat_dat$`RR_Cannabis Dep` > 10, "red", 
                                      spec_color(heat_dat$`RR_Cannabis Dep`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(7, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Drug Dep`) & heat_dat$`RR_Drug Dep` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Drug Dep`) & heat_dat$`RR_Drug Dep` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Drug Dep`), "gray",
                               ifelse(heat_dat$`sig_Drug Dep` == 0, "gray90",
                               ifelse(heat_dat$`RR_Drug Dep` > 10, "red", 
                                      spec_color(heat_dat$`RR_Drug Dep`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(9, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Anxiety`) & heat_dat$`RR_Anxiety` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Anxiety`) & heat_dat$`RR_Anxiety` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Anxiety`), "gray",
                               ifelse(heat_dat$`sig_Anxiety` == 0, "gray90",
                               ifelse(heat_dat$`RR_Anxiety` > 10, "red", 
                                      spec_color(heat_dat$`RR_Anxiety`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(10, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Depression`) & heat_dat$`RR_Depression` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Depression`) & heat_dat$`RR_Depression` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Depression`), "gray",
                               ifelse(heat_dat$`sig_Depression` == 0, "gray90",
                               ifelse(heat_dat$`RR_Depression` > 10, "red", 
                                      spec_color(heat_dat$`RR_Depression`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(11, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Fears`) & heat_dat$`RR_Fears` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Fears`) & heat_dat$`RR_Fears` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Fears`), "gray",
                               ifelse(heat_dat$`sig_Fears` == 0, "gray90",
                               ifelse(heat_dat$`RR_Fears` > 10, "red", 
                                      spec_color(heat_dat$`RR_Fears`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(12, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Eating Disorder`) & heat_dat$`RR_Eating Disorder` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Eating Disorder`) & heat_dat$`RR_Eating Disorder` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Eating Disorder`), "gray",
                               ifelse(heat_dat$`sig_Eating Disorder` == 0, "gray90",
                               ifelse(heat_dat$`RR_Eating Disorder` > 10, "red", 
                                      spec_color(heat_dat$`RR_Eating Disorder`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(13, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_PTSD`) & heat_dat$`RR_PTSD` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_PTSD`) & heat_dat$`RR_PTSD` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_PTSD`), "gray",
                               ifelse(heat_dat$`sig_PTSD` == 0, "gray90",
                               ifelse(heat_dat$`RR_PTSD` > 10, "red", 
                                      spec_color(heat_dat$`RR_PTSD`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(15, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_OCD`) & heat_dat$`RR_OCD` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_OCD`) & heat_dat$`RR_OCD` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_OCD`), "gray",
                               ifelse(heat_dat$`sig_OCD` == 0, "gray90",
                               ifelse(heat_dat$`RR_OCD` > 10, "red", 
                                      spec_color(heat_dat$`RR_OCD`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(16, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Mania`) & heat_dat$`RR_Mania` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Mania`) & heat_dat$`RR_Mania` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Mania`), "gray",
                               ifelse(heat_dat$`sig_Mania` == 0, "gray90",
                               ifelse(heat_dat$`RR_Mania` > 10, "red", 
                                      spec_color(heat_dat$`RR_Mania`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
      column_spec(17, 
                  width      = '0.75in',
                  bold       = T,
                  color      = ifelse(!is.na(heat_dat$`RR_Schizophrenia`) & heat_dat$`RR_Schizophrenia` > 5, "white", 
                               ifelse(!is.na(heat_dat$`RR_Schizophrenia`) & heat_dat$`RR_Schizophrenia` < 1, "royalblue","black")),
                  background = ifelse(is.na(heat_dat$`sig_Schizophrenia`), "gray",
                               ifelse(heat_dat$`sig_Schizophrenia` == 0, "gray90",
                               ifelse(heat_dat$`RR_Schizophrenia` > 10, "red", 
                                      spec_color(heat_dat$`RR_Schizophrenia`[1:16], 
                                                 end = 1, direction = -1, option = "magma",
                                                 scale_from = c(0.6, 10)))))) %>%
  
      row_spec(7,  background = "white") %>%
      row_spec(13, background = "white") %>%

      remove_column(18:31)


heat_table

readr::write_file(heat_table, "SeqComorb_Jan2025.html")

