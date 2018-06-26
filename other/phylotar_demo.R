# SPEED TEST DOWNLOAD STAGE WITH AND WITHOUT RESTEZ
# LIBS ----
library(restez)
library(phylotaR)

# VARS ----
wd <- 'beavers'
restez_path <- '~/Desktop'
txid <- 1963757
ncbi_dr <- '/usr/local/ncbi/blast/bin'

# RUN PHYLOTAR ----
if (dir.exists(wd)) {
  unlink(x = wd, recursive = TRUE)
}
dir.create(wd)
setup(wd = wd, txid = txid, ncbi_dr = ncbi_dr, v = TRUE, btchsz = 100)
taxise_run(wd = wd)

# SPEED TEST 1
without_restez <- system.time(expr = {
  download_run(wd = wd)
})
# user  system elapsed 
# 121.104  32.604 467.001 

# SET-UP RESTEZ ----
restez_path_set(filepath = restez_path)
db_download()  # select 15 for rodents
db_create()
status_check()

# RESET PHYLOTAR ----
reset(wd = wd, stage = 'download', hard = TRUE)

# SPEED TEST 2
with_restez <- system.time(expr = {
  download_run(wd = wd)
})
# user  system elapsed 
#  97.205  31.017 303.477

# TAKE HOME STAT
# ~35% faster
pfaster <- round((467.001 - 303.477)*100/467.001)
cat(pfaster, '% faster with restez\n', sep = '')
