library(restez)
restez_path_set(filepath = tempdir())
restez_connect()
demo_db_create()
(rec <- gb_record_get(id = 'demo_1'))
(recs <- gb_record_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)
