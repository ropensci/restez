library(restez)
restez_path_set(filepath = tempdir())
demo_db_create(n = 5)
(ver <- gb_version_get(id = 'demo_1'))
(vers <- gb_version_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)


