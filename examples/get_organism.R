library(restez)
set_restez_path(filepath = tempdir())
create_demo_database()
org <- get_organism(id = 'demo_1')
orgs <- get_organism(id = c('demo_1', 'demo_2'))

# delete demo after example
delete_database()
