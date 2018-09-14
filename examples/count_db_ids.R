library(restez)
restez_path_set(filepath = tempdir())
restez_connect()
demo_db_create()
(count_db_ids())

# delete demo after example
db_delete(everything = TRUE)
