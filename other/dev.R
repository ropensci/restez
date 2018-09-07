# TODO: loop through lots of random sequence files

devtools::load_all('~/Coding/restez')
restez_path_set('~/Desktop')
db_download(preselection = '15')
restez_connect()
db_create()


ids <- list_db_ids(n = NULL)
length(ids)
cat(gb_fasta_get(sample(ids, 2)))
gb_organism_get(sample(ids, 2))
cat(gb_record_get(sample(ids, 2)))
