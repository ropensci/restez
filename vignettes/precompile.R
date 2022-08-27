# Load package in working state
# not with library()
library(devtools)
library(knitr)
load_all()

# First five vignettes require downloaded rodent db, must be precompiled:

# gen rodent db
if (!dir.exists(file.path('rodents'))) {
  source(file.path('other', 'rodent_db.R'))
}

# precompile
vgnts <- c('1_rodents.Rmd', '2_search_and_fetch.Rmd', '3_parsing.Rmd',
           '4_phylotaR.Rmd', '5_tips_and_tricks.Rmd')
for (vgnt in vgnts) {
  knit(paste0("vignettes/", vgnt, ".orig"), paste0("vignettes/", vgnt))
}

build_vignettes()
