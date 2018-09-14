library(restez)
restez_path_set(filepath = tempdir())
restez_connect()
demo_db_create()
(fasta <- gb_fasta_get(id = 'demo_1'))
(fastas <- gb_fasta_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)
