library(restez)
set_restez_path(filepath = tempdir())
create_demo_database()
ver <- get_version(id = 'demo_1')
vers <- get_version(id = c('demo_1', 'demo_2'))

# delete demo after example
delete_database()
