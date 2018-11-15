library(restez)
restez_path_set(filepath = tempdir())
demo_db_create()
restez_connect()
(fasta <- gb_fasta_get(id = 'demo_1'))
(fastas <- gb_fasta_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)
