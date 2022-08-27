library(restez)
restez_path_set(filepath = tempdir())
demo_db_create(n = 5)
(seq <- gb_sequence_get(id = 'demo_1'))
(seqs <- gb_sequence_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)

