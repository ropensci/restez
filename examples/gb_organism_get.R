library(restez)
restez_path_set(filepath = tempdir())
demo_db_create(n = 5)
(org <- gb_organism_get(id = 'demo_1'))
(orgs <- gb_organism_get(id = c('demo_1', 'demo_2')))


# delete demo after example
db_delete(everything = TRUE)
