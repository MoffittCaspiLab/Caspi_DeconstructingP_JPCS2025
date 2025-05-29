###############################################################################
# For:        Norway
# Paper:      Three Reasons Paper
# Programmer: Renate Houts
# File:       ThreeReasons_SEM_Dec2024.R
# Date:       23-Jul-2024
#
# Purpose:    Run SEM model to test Intergenerational Transmission & Assortative Mating in Norway
#             Add misc correlations
#             Re-run with updated sample
#             Abandon Clustering and run sensitivity analsysis on one random kid per family
###############################################################################

library(tidyverse)
library(haven)
library(plotly)
library(viridis)
library(lavaan)

sessionInfo()

MHdx <- read_sas("M:/p1074-renateh/2024_ThreeReasons/SEMModel/familymhonly_Dec2024.sas7bdat") %>%
          rename(c_ext = c_any_ext,
                 c_int = c_any_int,
                 c_thd = c_any_thd,
                 m_ext = m_any_ext,
                 m_int = m_any_int,
                 m_thd = m_any_thd,
                 d_ext = d_any_ext,
                 d_int = d_any_int,
                 d_thd = d_any_thd,
                 mm_ext = mm_any_ext,
                 mm_int = mm_any_int,
                 mm_thd = mm_any_thd,
                 md_ext = md_any_ext,
                 md_int = md_any_int,
                 md_thd = md_any_thd,
                 dm_ext = dm_any_ext,
                 dm_int = dm_any_int,
                 dm_thd = dm_any_thd,
                 dd_ext = dd_any_ext,
                 dd_int = dd_any_int,
                 dd_thd = dd_any_thd)

thrsh <-  '# Thresholds
           c_ext | ce_t*t1
           c_int | ci_t*t1
           c_thd | ct_t*t1
           m_ext | me_t*t1
           m_int | mi_t*t1
           m_thd | mt_t*t1
           d_ext | de_t*t1
           d_int | di_t*t1
           d_thd | dt_t*t1
           mm_ext | mme_t*t1
           mm_int | mmi_t*t1
           mm_thd | mmt_t*t1
           md_ext | mde_t*t1
           md_int | mdi_t*t1
           md_thd | mdt_t*t1
           dm_ext | dme_t*t1
           dm_int | dmi_t*t1
           dm_thd | dmt_t*t1
           dd_ext | dde_t*t1
           dd_int | ddi_t*t1
           dd_thd | ddt_t*t1
          '
wi_ind <- '# Within individual corelations
           # Child
           c_ext ~~ c_ei_c*c_int
           c_ext ~~ c_et_c*c_thd
           c_int ~~ c_it_c*c_thd

           # Mother
           m_ext ~~ m_ei_c*m_int
           m_ext ~~ m_et_c*m_thd
           m_int ~~ m_it_c*m_thd

           # Father
           d_ext ~~ d_ei_c*d_int
           d_ext ~~ d_et_c*d_thd
           d_int ~~ d_it_c*d_thd

           # Maternal Grandmother
           mm_ext ~~ mm_ei_c*mm_int
           mm_ext ~~ mm_et_c*mm_thd
           mm_int ~~ mm_it_c*mm_thd

           # Maternal Grandfather
           md_ext ~~ md_ei_c*md_int
           md_ext ~~ md_et_c*md_thd
           md_int ~~ md_it_c*md_thd

           # Paternal Grandmother
           dm_ext ~~ dm_ei_c*dm_int
           dm_ext ~~ dm_et_c*dm_thd
           dm_int ~~ dm_it_c*dm_thd

           # Paternal Grandfather
           dd_ext ~~ dd_ei_c*dd_int
           dd_ext ~~ dd_et_c*dd_thd
           dd_int ~~ dd_it_c*dd_thd
          '
as_mat <- '# Assortative mating correlations
           # Mother and Father
           m_ext ~~ md_ee_a*d_ext
           m_ext ~~ md_ei_a*d_int
           m_ext ~~ md_et_a*d_thd
           m_int ~~ md_ie_a*d_ext
           m_int ~~ md_ii_a*d_int
           m_int ~~ md_it_a*d_thd
           m_thd ~~ md_te_a*d_ext
           m_thd ~~ md_ti_a*d_int
           m_thd ~~ md_tt_a*d_thd

           # Maternal Grandparents
           mm_ext ~~ mmd_ee_a*md_ext
           mm_ext ~~ mmd_ei_a*md_int
           mm_ext ~~ mmd_et_a*md_thd
           mm_int ~~ mmd_ie_a*md_ext
           mm_int ~~ mmd_ii_a*md_int
           mm_int ~~ mmd_it_a*md_thd
           mm_thd ~~ mmd_te_a*md_ext
           mm_thd ~~ mmd_ti_a*md_int
           mm_thd ~~ mmd_tt_a*md_thd

           # Paternal Grandparents
           dm_ext ~~ dmd_ee_a*dd_ext
           dm_ext ~~ dmd_ei_a*dd_int
           dm_ext ~~ dmd_et_a*dd_thd
           dm_int ~~ dmd_ie_a*dd_ext
           dm_int ~~ dmd_ii_a*dd_int
           dm_int ~~ dmd_it_a*dd_thd
           dm_thd ~~ dmd_te_a*dd_ext
           dm_thd ~~ dmd_ti_a*dd_int
           dm_thd ~~ dmd_tt_a*dd_thd
          '
ig12   <- '# Intergenerational correlations (G1 to G2)
           # Mother with child
           m_ext ~~ mc_ee_i*c_ext
           m_ext ~~ mc_ei_i*c_int
           m_ext ~~ mc_et_i*c_thd
           m_int ~~ mc_ie_i*c_ext
           m_int ~~ mc_ii_i*c_int
           m_int ~~ mc_it_i*c_thd
           m_thd ~~ mc_te_i*c_ext
           m_thd ~~ mc_ti_i*c_int
           m_thd ~~ mc_tt_i*c_thd

           # Father with child
           d_ext ~~ dc_ee_i*c_ext
           d_ext ~~ dc_ei_i*c_int
           d_ext ~~ dc_et_i*c_thd
           d_int ~~ dc_ie_i*c_ext
           d_int ~~ dc_ii_i*c_int
           d_int ~~ dc_it_i*c_thd
           d_thd ~~ dc_te_i*c_ext
           d_thd ~~ dc_ti_i*c_int
           d_thd ~~ dc_tt_i*c_thd
          '
ig23m  <- '# Intergenerational correlations (G2 to G3 maternal)
           # Mother with child
           mm_ext ~~ mmm_ee_i*m_ext
           mm_ext ~~ mmm_ei_i*m_int
           mm_ext ~~ mmm_et_i*m_thd
           mm_int ~~ mmm_ie_i*m_ext
           mm_int ~~ mmm_ii_i*m_int
           mm_int ~~ mmm_it_i*m_thd
           mm_thd ~~ mmm_te_i*m_ext
           mm_thd ~~ mmm_ti_i*m_int
           mm_thd ~~ mmm_tt_i*m_thd

           # Father with child
           md_ext ~~ mdm_ee_i*m_ext
           md_ext ~~ mdm_ei_i*m_int
           md_ext ~~ mdm_et_i*m_thd
           md_int ~~ mdm_ie_i*m_ext
           md_int ~~ mdm_ii_i*m_int
           md_int ~~ mdm_it_i*m_thd
           md_thd ~~ mdm_te_i*m_ext
           md_thd ~~ mdm_ti_i*m_int
           md_thd ~~ mdm_tt_i*m_thd
          '
ig23p  <- '# Intergenerational correlations (G2 to G3 paternal)
           # Mother with child
           dm_ext ~~ dmd_ee_i*d_ext
           dm_ext ~~ dmd_ei_i*d_int
           dm_ext ~~ dmd_et_i*d_thd
           dm_int ~~ dmd_ie_i*d_ext
           dm_int ~~ dmd_ii_i*d_int
           dm_int ~~ dmd_it_i*d_thd
           dm_thd ~~ dmd_te_i*d_ext
           dm_thd ~~ dmd_ti_i*d_int
           dm_thd ~~ dmd_tt_i*d_thd

           # Father with child
           dd_ext ~~ ddd_ee_i*d_ext
           dd_ext ~~ ddd_ei_i*d_int
           dd_ext ~~ ddd_et_i*d_thd
           dd_int ~~ ddd_ie_i*d_ext
           dd_int ~~ ddd_ii_i*d_int
           dd_int ~~ ddd_it_i*d_thd
           dd_thd ~~ ddd_te_i*d_ext
           dd_thd ~~ ddd_ti_i*d_int
           dd_thd ~~ ddd_tt_i*d_thd
          '
misc <- '# Miscellaneous Correlations
         # Maternal & Paternal Grandparents
         md_ext ~~ dd_ext
         md_ext ~~ dd_int
         md_ext ~~ dd_thd
         md_int ~~ dd_ext
         md_int ~~ dd_int
         md_int ~~ dd_thd
         md_thd ~~ dd_ext
         md_thd ~~ dd_int
         md_thd ~~ dd_thd

         md_ext ~~ dm_ext
         md_ext ~~ dm_int
         md_ext ~~ dm_thd
         md_int ~~ dm_ext
         md_int ~~ dm_int
         md_int ~~ dm_thd
         md_thd ~~ dm_ext
         md_thd ~~ dm_int
         md_thd ~~ dm_thd

         mm_ext ~~ dd_ext
         mm_ext ~~ dd_int
         mm_ext ~~ dd_thd
         mm_int ~~ dd_ext
         mm_int ~~ dd_int
         mm_int ~~ dd_thd
         mm_thd ~~ dd_ext
         mm_thd ~~ dd_int
         mm_thd ~~ dd_thd

         mm_ext ~~ dm_ext
         mm_ext ~~ dm_int
         mm_ext ~~ dm_thd
         mm_int ~~ dm_ext
         mm_int ~~ dm_int
         mm_int ~~ dm_thd
         mm_thd ~~ dm_ext
         mm_thd ~~ dm_int
         mm_thd ~~ dm_thd

        #Paternal Grandparents with Mothers Children
         m_ext ~~ dd_ext
         m_ext ~~ dd_int
         m_ext ~~ dd_thd
         m_int ~~ dd_ext
         m_int ~~ dd_int
         m_int ~~ dd_thd
         m_thd ~~ dd_ext
         m_thd ~~ dd_int
         m_thd ~~ dd_thd

         m_ext ~~ dm_ext
         m_ext ~~ dm_int
         m_ext ~~ dm_thd
         m_int ~~ dm_ext
         m_int ~~ dm_int
         m_int ~~ dm_thd
         m_thd ~~ dm_ext
         m_thd ~~ dm_int
         m_thd ~~ dm_thd

         c_ext ~~ dd_ext
         c_ext ~~ dd_int
         c_ext ~~ dd_thd
         c_int ~~ dd_ext
         c_int ~~ dd_int
         c_int ~~ dd_thd
         c_thd ~~ dd_ext
         c_thd ~~ dd_int
         c_thd ~~ dd_thd

         c_ext ~~ dm_ext
         c_ext ~~ dm_int
         c_ext ~~ dm_thd
         c_int ~~ dm_ext
         c_int ~~ dm_int
         c_int ~~ dm_thd
         c_thd ~~ dm_ext
         c_thd ~~ dm_int
         c_thd ~~ dm_thd

        #Maternal Grandparents with Fathers Children
         d_ext ~~ md_ext
         d_ext ~~ md_int
         d_ext ~~ md_thd
         d_int ~~ md_ext
         d_int ~~ md_int
         d_int ~~ md_thd
         d_thd ~~ md_ext
         d_thd ~~ md_int
         d_thd ~~ md_thd

         d_ext ~~ mm_ext
         d_ext ~~ mm_int
         d_ext ~~ mm_thd
         d_int ~~ mm_ext
         d_int ~~ mm_int
         d_int ~~ mm_thd
         d_thd ~~ mm_ext
         d_thd ~~ mm_int
         d_thd ~~ mm_thd

         c_ext ~~ md_ext
         c_ext ~~ md_int
         c_ext ~~ md_thd
         c_int ~~ md_ext
         c_int ~~ md_int
         c_int ~~ md_thd
         c_thd ~~ md_ext
         c_thd ~~ md_int
         c_thd ~~ md_thd

         c_ext ~~ mm_ext
         c_ext ~~ mm_int
         c_ext ~~ mm_thd
         c_int ~~ mm_ext
         c_int ~~ mm_int
         c_int ~~ mm_thd
         c_thd ~~ mm_ext
         c_thd ~~ mm_int
         c_thd ~~ mm_thd
        '
thrsh_gm <- '# Threshold Constraints
             mme_t == dme_t
             mmi_t == dmi_t
             mmt_t == dmt_t
            '
thrsh_gf <- '# Threshold Constraints
              mde_t == dde_t
              mdi_t == ddi_t
              mdt_t == ddt_t
              '
thrsh_gm_e <- '# Threshold Constraints
               mme_t == dme_t
               '
thrsh_gm_i <- '# Threshold Constraints
               mmi_t == dmi_t
               '
thrsh_gm_t <- '# Threshold Constraints
               mmt_t == dmt_t
               '

thrsh_gf_e <- '# Threshold Constraints
               mde_t == dde_t
              '
thrsh_gf_i <- '# Threshold Constraints
              mdi_t == ddi_t
              '
thrsh_gf_t <- '# Threshold Constraints
              mdt_t == ddt_t
              '
com_mf <- '# Comoribity Constraints
           m_ei_c == d_ei_c
           m_et_c == d_et_c
           m_it_c == d_it_c
          '
com_gm <- '# Comoribity Constraints
           mm_ei_c == dm_ei_c
           mm_et_c == dm_et_c
           mm_it_c == dm_it_c
          '
com_gf <- '# Comoribity Constraints
           md_ei_c == dd_ei_c
           md_et_c == dd_et_c
           md_it_c == dd_it_c
          '
com_gp <- '# Comoribity Constraints
           mm_ei_c == dm_ei_c
           mm_et_c == dm_et_c
           mm_it_c == dm_it_c

           md_ei_c == dd_ei_c
           md_et_c == dd_et_c
           md_it_c == dd_it_c

           mm_ei_c == md_ei_c
           mm_et_c == md_et_c
           mm_it_c == md_it_c

           dm_ei_c == dd_ei_c
           dm_et_c == dd_et_c
           dm_it_c == dd_it_c
          '
com_mfgp <- '# Comoribity Constraints
             m_ei_c == d_ei_c
             m_et_c == d_et_c
             m_it_c == d_it_c

             mm_ei_c == dm_ei_c
             mm_et_c == dm_et_c
             mm_it_c == dm_it_c

             md_ei_c == dd_ei_c
             md_et_c == dd_et_c
             md_it_c == dd_it_c

             mm_ei_c == md_ei_c
             mm_et_c == md_et_c
             mm_it_c == md_it_c

             dm_ei_c == dd_ei_c
             dm_et_c == dd_et_c
             dm_it_c == dd_it_c

             m_ei_c == mm_ei_c
             m_et_c == mm_et_c
             m_it_c == mm_it_c
            '
am_mf <- '# MF Assortative Mating constraints
          md_ei_a == md_ie_a
          md_et_a == md_te_a
          md_it_a == md_ti_a
         '
am_gp <- '# GM/GF Assortative Mating constraints
          mmd_ei_a == mmd_ie_a
          mmd_et_a == mmd_te_a
          mmd_it_a == mmd_ti_a
          
          dmd_ei_a == dmd_ie_a
          dmd_et_a == dmd_te_a
          dmd_it_a == dmd_ti_a

          mmd_ei_a == dmd_ei_a
          mmd_et_a == dmd_et_a
          mmd_it_a == dmd_it_a

          mmd_ee_a == dmd_ee_a
          mmd_ii_a == dmd_ii_a
          mmd_tt_a == dmd_tt_a
         '
am_mfgp <- '# MF = GP Assortative mating
            md_ei_a == mmd_ei_a
            md_et_a == mmd_et_a
            md_it_a == mmd_it_a

            md_ee_a == mmd_ee_a
            md_ii_a == mmd_ii_a
            md_tt_a == mmd_tt_a
           '

ig_mf <- '# MF Intergenerational transmission constraints
          mc_ee_i == dc_ee_i
          mc_ei_i == dc_ei_i
          mc_et_i == dc_et_i
          mc_ie_i == dc_ie_i
          mc_ii_i == dc_ii_i
          mc_it_i == dc_it_i
          mc_te_i == dc_te_i
          mc_ti_i == dc_ti_i
          mc_tt_i == dc_tt_i
         '
ig_gp <- '# GM/GG Intergenerational transmission constraints
          mmm_ee_i == mdm_ee_i
          mmm_ei_i == mdm_ei_i
          mmm_et_i == mdm_et_i
          mmm_ie_i == mdm_ie_i
          mmm_ii_i == mdm_ii_i
          mmm_it_i == mdm_it_i
          mmm_te_i == mdm_te_i
          mmm_ti_i == mdm_ti_i
          mmm_tt_i == mdm_tt_i

          dmd_ee_i == ddd_ee_i
          dmd_ei_i == ddd_ei_i
          dmd_et_i == ddd_et_i
          dmd_ie_i == ddd_ie_i
          dmd_ii_i == ddd_ii_i
          dmd_it_i == ddd_it_i
          dmd_te_i == ddd_te_i
          dmd_ti_i == ddd_ti_i
          dmd_tt_i == ddd_tt_i

          mmm_ee_i == ddd_ee_i
          mmm_ei_i == ddd_ei_i
          mmm_et_i == ddd_et_i
          mmm_ie_i == ddd_ie_i
          mmm_ii_i == ddd_ii_i
          mmm_it_i == ddd_it_i
          mmm_te_i == ddd_te_i
          mmm_ti_i == ddd_ti_i
          mmm_tt_i == ddd_tt_i
         '

ig_mfgp <- '# MF Intergenerational transmission constraints
            mc_ee_i == mmm_ee_i
            mc_ei_i == mmm_ei_i
            mc_et_i == mmm_et_i
            mc_ie_i == mmm_ie_i
            mc_ii_i == mmm_ii_i
            mc_it_i == mmm_it_i
            mc_te_i == mmm_te_i
            mc_ti_i == mmm_ti_i
            mc_tt_i == mmm_tt_i
           '

# Polychoric correlations
polycors <- MHdx %>% select(c_ext,  c_int,  c_thd,
                            m_ext,  m_int,  m_thd,
                            d_ext,  d_int,  d_thd,
                            mm_ext, mm_int, mm_thd,
                            md_ext, md_int, md_thd,
                            dm_ext, dm_int, dm_thd,
                            dd_ext, dd_int, dd_thd) %>%
            lavCor(ordered = c("c_ext",  "c_int",  "c_thd",
                               "m_ext",  "m_int",  "m_thd",
                               "d_ext",  "d_int",  "d_thd",
                               "mm_ext", "mm_int", "mm_thd",
                               "md_ext", "md_int", "md_thd",
                               "dm_ext", "dm_int", "dm_thd",
                               "dd_ext", "dd_int", "dd_thd"),
                   missing = "pairwise",
                   estimator = "WLSMV")

write_csv(as.data.frame(polycors), "M:/p1074-renateh/2024_ThreeReasons/SEMModel/SEM_polycors_All.csv")

# Baseline model, no constraints
fit_base <- sem(model = c(#misc, 
                          thrsh, wi_ind, as_mat, ig12, ig23m, ig23p), 
                data = MHdx, 
                missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                ordered = c("c_ext",  "c_int",  "c_thd",
                            "m_ext",  "m_int",  "m_thd",
                            "d_ext",  "d_int",  "d_thd",
                            "mm_ext", "mm_int", "mm_thd",
                            "md_ext", "md_int", "md_thd",
                            "dm_ext", "dm_int", "dm_thd",
                            "dd_ext", "dd_int", "dd_thd"))

base_fit <- fitMeasures(fit_base, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")

# Threshold/incidence rates
fit_gm <- sem(model = c(#misc, 
                        thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm), 
              data = MHdx, 
              missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
              ordered = c("c_ext",  "c_int",  "c_thd",
                          "m_ext",  "m_int",  "m_thd",
                          "d_ext",  "d_int",  "d_thd",
                          "mm_ext", "mm_int", "mm_thd",
                          "md_ext", "md_int", "md_thd",
                          "dm_ext", "dm_int", "dm_thd",
                          "dd_ext", "dd_int", "dd_thd"))

fit_gf <- sem(model = c(#misc, 
                        thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gf), 
              data = MHdx, 
              missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
              ordered = c("c_ext",  "c_int",  "c_thd",
                          "m_ext",  "m_int",  "m_thd",
                          "d_ext",  "d_int",  "d_thd",
                          "mm_ext", "mm_int", "mm_thd",
                          "md_ext", "md_int", "md_thd",
                          "dm_ext", "dm_int", "dm_thd",
                          "dd_ext", "dd_int", "dd_thd"))
gm_fit <- fitMeasures(fit_gm, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gf_fit <- fitMeasures(fit_gf, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")

base_gm_test <- lavTestLRT(fit_base, fit_gm)
base_gf_test <- lavTestLRT(fit_base, fit_gf)

fit_gme <- sem(model = c(#misc, 
                         thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm_e), 
               data = MHdx, 
               missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
               ordered = c("c_ext",  "c_int",  "c_thd",
                           "m_ext",  "m_int",  "m_thd",
                           "d_ext",  "d_int",  "d_thd",
                           "mm_ext", "mm_int", "mm_thd",
                           "md_ext", "md_int", "md_thd",
                           "dm_ext", "dm_int", "dm_thd",
                           "dd_ext", "dd_int", "dd_thd"))
fit_gmi <- sem(model = c(#misc, 
                         thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm_i), 
               data = MHdx, 
               missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
               ordered = c("c_ext",  "c_int",  "c_thd",
                           "m_ext",  "m_int",  "m_thd",
                           "d_ext",  "d_int",  "d_thd",
                           "mm_ext", "mm_int", "mm_thd",
                           "md_ext", "md_int", "md_thd",
                           "dm_ext", "dm_int", "dm_thd",
                           "dd_ext", "dd_int", "dd_thd"))
fit_gmt <- sem(model = c(#misc, 
                         thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm_t), 
               data = MHdx, 
               missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
               ordered = c("c_ext",  "c_int",  "c_thd",
                           "m_ext",  "m_int",  "m_thd",
                           "d_ext",  "d_int",  "d_thd",
                           "mm_ext", "mm_int", "mm_thd",
                           "md_ext", "md_int", "md_thd",
                           "dm_ext", "dm_int", "dm_thd",
                           "dd_ext", "dd_int", "dd_thd"))

gme_fit <- fitMeasures(fit_gme, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gmi_fit <- fitMeasures(fit_gmi, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gmt_fit <- fitMeasures(fit_gmt, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
base_gme_test <- lavTestLRT(fit_base, fit_gme)
base_gmi_test <- lavTestLRT(fit_base, fit_gmi)
base_gmt_test <- lavTestLRT(fit_base, fit_gmt)

fit_gfe <- sem(model = c(#misc, 
                         thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gf_e), 
               data = MHdx, 
               missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
               ordered = c("c_ext",  "c_int",  "c_thd",
                           "m_ext",  "m_int",  "m_thd",
                           "d_ext",  "d_int",  "d_thd",
                           "mm_ext", "mm_int", "mm_thd",
                           "md_ext", "md_int", "md_thd",
                           "dm_ext", "dm_int", "dm_thd",
                           "dd_ext", "dd_int", "dd_thd"))
fit_gfi <- sem(model = c(#misc, 
                         thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gf_i), 
               data = MHdx, 
               missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
               ordered = c("c_ext",  "c_int",  "c_thd",
                           "m_ext",  "m_int",  "m_thd",
                           "d_ext",  "d_int",  "d_thd",
                           "mm_ext", "mm_int", "mm_thd",
                           "md_ext", "md_int", "md_thd",
                           "dm_ext", "dm_int", "dm_thd",
                           "dd_ext", "dd_int", "dd_thd"))
fit_gft <- sem(model = c(#misc, 
                         thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gf_t), 
               data = MHdx, 
               missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
               ordered = c("c_ext",  "c_int",  "c_thd",
                           "m_ext",  "m_int",  "m_thd",
                           "d_ext",  "d_int",  "d_thd",
                           "mm_ext", "mm_int", "mm_thd",
                           "md_ext", "md_int", "md_thd",
                           "dm_ext", "dm_int", "dm_thd",
                           "dd_ext", "dd_int", "dd_thd"))

gfe_fit <- fitMeasures(fit_gfe, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gfi_fit <- fitMeasures(fit_gfi, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gft_fit <- fitMeasures(fit_gft, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
base_gfe_test <- lavTestLRT(fit_base, fit_gfe)
base_gfi_test <- lavTestLRT(fit_base, fit_gfi)
base_gft_test <- lavTestLRT(fit_base, fit_gft)

fit_gp <- sem(model = c(#misc, 
                        thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf), 
              data = MHdx, 
              missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
              ordered = c("c_ext",  "c_int",  "c_thd",
                          "m_ext",  "m_int",  "m_thd",
                          "d_ext",  "d_int",  "d_thd",
                          "mm_ext", "mm_int", "mm_thd",
                          "md_ext", "md_int", "md_thd",
                          "dm_ext", "dm_int", "dm_thd",
                          "dd_ext", "dd_int", "dd_thd"))

gp_fit <- fitMeasures(fit_gp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
base_gp_test <- lavTestLRT(fit_base, fit_gp)

tests <- c("Baseline", "T1: GM-Ext", "T2: GM-Int", "T3: GM_Thd", 
                       "T4: GF_Ext", "T5: GF-Int", "T6: GF-Thd", 
                       "T7: GM", "T8: GF", "T9: GM-GF")

threshold_fit <- bind_rows(base_fit, gme_fit, gmi_fit, gmt_fit, gfe_fit, 
                           gfi_fit, gft_fit, gm_fit, gf_fit, gp_fit) %>%
                 bind_cols(tests) %>%
                 rename(Test = `...10`)

threshold_test <- bind_rows(base_gme_test, base_gmi_test, base_gmt_test, 
                            base_gfe_test, base_gfi_test, base_gft_test,
                            base_gm_test, base_gf_test, base_gp_test)
threshold_test <- threshold_test[c(1,2,4,6,8,10,12,14,16,18),]
threshold_test$model_test <- rownames(threshold_test)


# Comorbidity Correlations
fit_cm_mf <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

cm_mf_fit <- fitMeasures(fit_cm_mf, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gp_cm_mf_test <- lavTestLRT(fit_gp, fit_cm_mf)


fit_cm_gm <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_gm), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

cm_gm_fit <- fitMeasures(fit_cm_gm, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gp_cm_gm_test <- lavTestLRT(fit_gp, fit_cm_gm)

fit_cm_gf <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_gf), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

cm_gf_fit <- fitMeasures(fit_cm_gf, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gp_cm_gf_test <- lavTestLRT(fit_gp, fit_cm_gf)

fit_cm_gp <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_gp), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

cm_gp_fit <- fitMeasures(fit_cm_gp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gp_cm_gp_test <- lavTestLRT(fit_gp, fit_cm_gp)

fit_cm_mfgp <- sem(model = c(#misc, 
                             thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mfgp), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

cm_mfgp_fit <- fitMeasures(fit_cm_mfgp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gp_cm_mfgp_test <- lavTestLRT(fit_gp, fit_cm_mfgp)

fit_cm_mfgp1 <- sem(model = c(#misc, 
                              thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp), 
                   data = MHdx, 
                   missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                   ordered = c("c_ext",  "c_int",  "c_thd",
                               "m_ext",  "m_int",  "m_thd",
                               "d_ext",  "d_int",  "d_thd",
                               "mm_ext", "mm_int", "mm_thd",
                               "md_ext", "md_int", "md_thd",
                               "dm_ext", "dm_int", "dm_thd",
                               "dd_ext", "dd_int", "dd_thd"))

cm_mfgp1_fit <- fitMeasures(fit_cm_mfgp1, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
gp_cm_mfgp1_test <- lavTestLRT(fit_gp, fit_cm_mfgp1)

tests <- c("CM1: MF", "CM2: GM", "CM3: GF", "CM4: GP", "CM5: MFGP", "CM6: MF + GP")

comorbidity_fit <- bind_rows(cm_mf_fit, cm_gm_fit, cm_gf_fit, cm_gp_fit, 
                             cm_mfgp_fit, cm_mfgp1_fit) %>%
                   bind_cols(tests) %>%
                   rename(Test = `...10`)

comorbidity_test <- bind_rows(gp_cm_mf_test, gp_cm_gm_test, gp_cm_gf_test, gp_cm_gp_test,
                              gp_cm_mfgp_test, gp_cm_mfgp1_test)
comorbidity_test <- comorbidity_test[c(1,2,4,6,8,10,12),]
comorbidity_test$model_test <- rownames(comorbidity_test)


# Assortative Mating Constraints
fit_am_mf <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, 
                           thrsh_gm, thrsh_gf, com_mf, com_gp, am_mf), 
                    data = MHdx, 
                    missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                    ordered = c("c_ext",  "c_int",  "c_thd",
                                "m_ext",  "m_int",  "m_thd",
                                "d_ext",  "d_int",  "d_thd",
                                "mm_ext", "mm_int", "mm_thd",
                                "md_ext", "md_int", "md_thd",
                                "dm_ext", "dm_int", "dm_thd",
                                "dd_ext", "dd_int", "dd_thd"))

am_mf_fit <- fitMeasures(fit_am_mf, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
cm_am_mf_test <- lavTestLRT(fit_cm_mfgp1, fit_am_mf)

fit_am_gp <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, 
                           thrsh_gm, thrsh_gf, com_mf, com_gp, am_gp), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

am_gp_fit <- fitMeasures(fit_am_gp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
cm_am_gp_test <- lavTestLRT(fit_cm_mfgp1, fit_am_gp)

fit_am_mfgp <- sem(model = c(#misc, 
                             thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                             am_mf, am_gp), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

am_mfgp_fit <- fitMeasures(fit_am_mfgp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
cm_am_mfgp_test <- lavTestLRT(fit_cm_mfgp1, fit_am_mfgp)

tests <- c("AM1: MF", "AM2: GP", "AM3: MF + GP")

assortmate_fit <- bind_rows(am_mf_fit, am_gp_fit, am_mfgp_fit) %>%
                   bind_cols(tests) %>%
                   rename(Test = `...10`)

assortmate_test <- bind_rows(cm_am_mf_test, cm_am_gp_test, cm_am_mfgp_test)
assortmate_test <- assortmate_test[c(1,2,4,6),]
assortmate_test$model_test <- rownames(assortmate_test)

# Intergenerational Transmission
fit_ig_mf <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                           am_mf, am_gp, ig_mf), 
                   data = MHdx, 
                   missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                   ordered = c("c_ext",  "c_int",  "c_thd",
                               "m_ext",  "m_int",  "m_thd",
                               "d_ext",  "d_int",  "d_thd",
                               "mm_ext", "mm_int", "mm_thd",
                               "md_ext", "md_int", "md_thd",
                               "dm_ext", "dm_int", "dm_thd",
                               "dd_ext", "dd_int", "dd_thd"))

ig_mf_fit <- fitMeasures(fit_ig_mf, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
am_ig_mf_test <- lavTestLRT(fit_am_mfgp, fit_ig_mf)

fit_ig_gp <- sem(model = c(#misc, 
                           thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                           am_mf, am_gp, ig_gp), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

ig_gp_fit <- fitMeasures(fit_ig_gp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
am_ig_gp_test <- lavTestLRT(fit_am_mfgp, fit_ig_gp)

fit_ig_mfgp <- sem(model = c(#misc, 
                             thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                             am_mf, am_gp, ig_mf, ig_gp), 
                 data = MHdx, 
                 missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                 ordered = c("c_ext",  "c_int",  "c_thd",
                             "m_ext",  "m_int",  "m_thd",
                             "d_ext",  "d_int",  "d_thd",
                             "mm_ext", "mm_int", "mm_thd",
                             "md_ext", "md_int", "md_thd",
                             "dm_ext", "dm_int", "dm_thd",
                             "dd_ext", "dd_int", "dd_thd"))

ig_mfgp_fit <- fitMeasures(fit_ig_mfgp, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
am_ig_mfgp_test <- lavTestLRT(fit_am_mfgp, fit_ig_mfgp)

tests <- c("IG1: MF", "IG2: GP", "IG3: MF + GP")

intergen_fit <- bind_rows(ig_mf_fit, ig_gp_fit, ig_mfgp_fit) %>%
                  bind_cols(tests) %>%
                  rename(Test = `...10`)

intergen_test <- bind_rows(am_ig_mf_test, am_ig_gp_test, am_ig_mfgp_test)
intergen_test <- intergen_test[c(1,2,4,6),]
intergen_test$model_test <- rownames(intergen_test)


# Generational Differences
fit_gen1 <- sem(model = c(#misc, 
                          thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                          am_mf, am_gp, ig_mf, ig_gp, am_mfgp), 
                   data = MHdx, 
                   missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                   ordered = c("c_ext",  "c_int",  "c_thd",
                               "m_ext",  "m_int",  "m_thd",
                               "d_ext",  "d_int",  "d_thd",
                               "mm_ext", "mm_int", "mm_thd",
                               "md_ext", "md_int", "md_thd",
                               "dm_ext", "dm_int", "dm_thd",
                               "dd_ext", "dd_int", "dd_thd"))

gen1_fit <- fitMeasures(fit_gen1, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
ig_gen1_test <- lavTestLRT(fit_ig_mfgp, fit_gen1)


fit_gen2 <- sem(model = c(#misc, 
                          thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                          am_mf, am_gp, ig_mf, ig_gp, ig_mfgp), 
                data = MHdx, 
                missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                ordered = c("c_ext",  "c_int",  "c_thd",
                            "m_ext",  "m_int",  "m_thd",
                            "d_ext",  "d_int",  "d_thd",
                            "mm_ext", "mm_int", "mm_thd",
                            "md_ext", "md_int", "md_thd",
                            "dm_ext", "dm_int", "dm_thd",
                            "dd_ext", "dd_int", "dd_thd"))

gen2_fit <- fitMeasures(fit_gen2, 
            c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
            output = "vector")
ig_gen2_test <- lavTestLRT(fit_ig_mfgp, fit_gen2)

fit_gen3 <- sem(model = c(#misc, 
                          thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                          am_mf, am_gp, ig_mf, ig_gp, am_mfgp, ig_mfgp), 
                data = MHdx, 
                missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                ordered = c("c_ext",  "c_int",  "c_thd",
                            "m_ext",  "m_int",  "m_thd",
                            "d_ext",  "d_int",  "d_thd",
                            "mm_ext", "mm_int", "mm_thd",
                            "md_ext", "md_int", "md_thd",
                            "dm_ext", "dm_int", "dm_thd",
                            "dd_ext", "dd_int", "dd_thd"))

gen3_fit <- fitMeasures(fit_gen3, 
                        c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
                        output = "vector")
ig_gen3_test <- lavTestLRT(fit_ig_mfgp, fit_gen3)

tests <- c("GEN1: MF = GP AM", "GEN2: MF = GP IG", "GEN3: MFGP AM + IG")

gen_fit <- bind_rows(gen1_fit, gen2_fit, gen3_fit) %>%
                bind_cols(tests) %>%
                rename(Test = `...10`)

gen_test <- bind_rows(ig_gen1_test, ig_gen2_test, ig_gen3_test)
gen_test <- gen_test[c(1,2,4,6),]
gen_test$model_test <- rownames(gen_test)

summary(fit_gen2)

all_fit <- bind_rows(threshold_fit, comorbidity_fit, assortmate_fit, intergen_fit, gen_fit)
all_test <- bind_rows(threshold_test, comorbidity_test, assortmate_test, intergen_test, gen_test)

FinalParameters <- parameterEstimates(fit_gen2)

write_csv(all_fit, "M:/p1074-renateh/2024_ThreeReasons/SEMModel/ModelFitStats_Dec2024_NoMisc.csv")
write_csv(all_test, "M:/p1074-renateh/2024_ThreeReasons/SEMModel/ModelComparisons_Dec2024_NoMisc.csv")
write_csv(FinalParameters, "M:/p1074-renateh/2024_ThreeReasons/SEMModel/ModelParams_Dec2024_NoMisc.csv")

# Re-run final models using only one random kid from each family

OneKid <- read_sas("M:/p1074-renateh/2024_ThreeReasons/SEMModel/onerandomkid.sas7bdat") %>%
          rename(c_ext = c_any_ext,
                 c_int = c_any_int,
                 c_thd = c_any_thd,
                 m_ext = m_any_ext,
                 m_int = m_any_int,
                 m_thd = m_any_thd,
                 d_ext = d_any_ext,
                 d_int = d_any_int,
                 d_thd = d_any_thd,
                 mm_ext = mm_any_ext,
                 mm_int = mm_any_int,
                 mm_thd = mm_any_thd,
                 md_ext = md_any_ext,
                 md_int = md_any_int,
                 md_thd = md_any_thd,
                 dm_ext = dm_any_ext,
                 dm_int = dm_any_int,
                 dm_thd = dm_any_thd,
                 dd_ext = dd_any_ext,
                 dd_int = dd_any_int,
                 dd_thd = dd_any_thd)

fit_misc1 <- sem(model = c(misc, 
                          thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                          am_mf, am_gp, ig_mf, ig_gp, ig_mfgp), 
                data = OneKid, 
                missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                ordered = c("c_ext",  "c_int",  "c_thd",
                            "m_ext",  "m_int",  "m_thd",
                            "d_ext",  "d_int",  "d_thd",
                            "mm_ext", "mm_int", "mm_thd",
                            "md_ext", "md_int", "md_thd",
                            "dm_ext", "dm_int", "dm_thd",
                            "dd_ext", "dd_int", "dd_thd"))

misc1_fit <- fitMeasures(fit_misc1, 
                         c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
                         output = "vector")

Misc1_Param <- parameterEstimates(fit_misc1)

fit_nomisc1 <- sem(model = c(#misc, 
                             thrsh, wi_ind, as_mat, ig12, ig23m, ig23p, thrsh_gm, thrsh_gf, com_mf, com_gp,
                             am_mf, am_gp, ig_mf, ig_gp, ig_mfgp), 
                   data = OneKid, 
                   missing = "pairwise", estimator = "WLSMV", parameterization = "theta",
                   ordered = c("c_ext",  "c_int",  "c_thd",
                               "m_ext",  "m_int",  "m_thd",
                               "d_ext",  "d_int",  "d_thd",
                               "mm_ext", "mm_int", "mm_thd",
                               "md_ext", "md_int", "md_thd",
                               "dm_ext", "dm_int", "dm_thd",
                               "dd_ext", "dd_int", "dd_thd"))

nomisc1_fit <- fitMeasures(fit_nomisc1, 
                           c("chisq", "df", "pvalue", "cfi", "tli", "srmr", "rmsea", "rmsea.ci.lower", "rmsea.ci.upper"),
                           output = "vector")

NoMisc1_Param <- parameterEstimates(fit_nomisc1)

tests <- c("ONEKID: With MISC", "ONEKID: without MISC")

onekid_fit <- bind_rows(misc1_fit, nomisc1_fit) %>%
                bind_cols(tests) %>%
                rename(Test = `...10`)

write_csv(onekid_fit, "M:/p1074-renateh/2024_ThreeReasons/SEMModel/ModelFitStats_Dec2024_OneKid.csv")
write_csv(Misc1_Param, "M:/p1074-renateh/2024_ThreeReasons/SEMModel/ModelParams_Dec2024_OneKidMisc.csv")
write_csv(NoMisc1_Param, "M:/p1074-renateh/2024_ThreeReasons/SEMModel/ModelParams_Dec2024_OneKidNoMisc.csv")


