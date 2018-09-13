# SPEED TEST DOWNLOAD STAGE WITH AND WITHOUT RESTEZ
# LIBS ----
devtools::load_all('~/Coding/restez')
devtools::load_all('~/Coding/phylotaR')

# VARS ----
wd <- 'beavers'
restez_path <- '~/Desktop/beavers_restez'
txid <- 1963757
ncbi_dr <- '/usr/bin'

# RUN PHYLOTAR ----
if (dir.exists(wd)) {
  unlink(x = wd, recursive = TRUE)
}
dir.create(wd)
phylotaR::setup(wd = wd, txid = txid, ncbi_dr = ncbi_dr, v = TRUE, btchsz = 100)
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
restez_path_set(filepath = restez_path)
restez_connect()
with_restez <- system.time(expr = {
  download_run(wd = wd)
})
restez_disconnect()
# user  system elapsed 
# 71.983  14.783 234.640

# TAKE HOME STAT
# twice as faster
pfaster <- signif((467.001/234.640), 3)
cat(pfaster, 'x faster with restez\n', sep = '')
