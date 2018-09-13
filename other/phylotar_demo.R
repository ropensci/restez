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
# user  system elapsed 
# 63.128   0.883 438.626 

# SET-UP RESTEZ ----
restez_path_set(filepath = restez_path)
db_download(preselection = '15')  # select 15 for rodents
restez_connect()
db_create()
restez_disconnect()
restez_status()

# RESET PHYLOTAR ----
reset(wd = wd, stage = 'download', hard = TRUE)

# SPEED TEST 2
restez_connect()
with_restez <- system.time(expr = {
  download_run(wd = wd)
})
restez_disconnect()
# user  system elapsed
#  97.205  31.017 303.477

# TAKE HOME STAT
# ~35% faster
pfaster <- round((467.001 - 303.477)*100/467.001)
cat(pfaster, '% faster with restez\n', sep = '')
