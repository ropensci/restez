library(restez)
restez_path_set(filepath = tempdir())
demo_db_create(n = 5)
(count_db_ids())

# delete demo after example
db_delete(everything = TRUE)
