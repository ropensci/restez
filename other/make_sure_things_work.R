library(restez)
# On my linux computer and I specify my desktop
fp <- '~/Desktop'
restez_path_set(filepath = fp)

db_download(preselection = '15')
db_create(db_type = 'nucleotide', min_length = 250, max_length = 2000)
