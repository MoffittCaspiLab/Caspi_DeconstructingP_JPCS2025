library(readr)

install.packages('reticulate')
reticulate::install_miniconda(force = TRUE)
reticulate::conda_install('r-reticulate', 'python-kaleido')
reticulate::conda_install('r-reticulate', 'plotly', channel = 'plotly')
reticulate::use_miniconda('r-reticulate')

# Example Plotly-plot
#save_image(MH_OR, 
#           file = "C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2022_Norway/2023_Matt/Revision/Exported Figures/MH_OR_19Mar24.png",
#           format = png,
#           width = 4*300, height = 2.5*300)


# To export Kable Tables into SVG file for Adobe Illustrator:
#   1. Save as HTML file
#   2. Open Adobe Acrobat
#   3. Press "+ Create" Button
#   4. Select file and convert to PDF
#   4. Open file in Adobe Illustrator and edit as needed

# OR Heatmaps

# Assortative Mating
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/AssortativeMating")

readr::write_file(com_HM,    "Comorbid_29Oct.html")
readr::write_file(prim_HM,   "AM_Primary_29Oct.html")
readr::write_file(rand_HM,   "AM_Random_29Oct.html")
readr::write_file(f_prim_HM, "AM_Female_Primary_29Oct.html")
readr::write_file(f_rand_HM, "AM_Female_Random_29Oct.html")
readr::write_file(m_prim_HM, "AM_Male_Primary_29Oct.html")
readr::write_file(m_rand_HM, "AM_Male_Random_29Oct.html")
readr::write_file(no_f_com,  "AM_NoFemaleComorbidity_29Oct.html")
readr::write_file(no_m_com,  "AM_NoMaleComorbidity_29Oct.html")

# Parent-Child
setwd("C:/Users/rh93/Box/Duke_DPPPlab/Renate2015/2024_ThreeReasons/Graphics/Norway/ParentChild")

readr::write_file(Either_HM, "PC_Either_29Oct.html")
readr::write_file(Random_HM, "PC_Either_Random_29Oct.html")
readr::write_file(Mother_HM, "PC_Mother_29Oct.html")
readr::write_file(Father_HM, "PC_Father_29Oct.html")
readr::write_file(NoCCom_HM, "PC_NoChildComorbidity_29Oct.html")
readr::write_file(NoPCom_HM, "PC_NoParentComorbidity_29Oct.html")
