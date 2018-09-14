library(restez)
restez_path_set(filepath = tempdir())
restez_connect()
demo_db_create()
(def <- gb_definition_get(id = 'demo_1'))
(defs <- gb_definition_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)
