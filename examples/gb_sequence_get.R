library(restez)
restez_path_set(filepath = tempdir())
restez_connect()
demo_db_create()
(seq <- gb_sequence_get(id = 'demo_1'))
(seqs <- gb_sequence_get(id = c('demo_1', 'demo_2')))


# delete demo after example
restez_disconnect()
db_delete()
