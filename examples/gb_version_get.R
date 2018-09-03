library(restez)
restez_path_set(filepath = tempdir())
restez_connect()
demo_db_create()
(ver <- gb_version_get(id = 'demo_1'))
(vers <- gb_version_get(id = c('demo_1', 'demo_2')))


# delete demo after example
restez_disconnect()
db_delete()
