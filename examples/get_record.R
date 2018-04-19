library(restez)
set_restez_path(filepath = tempdir())
create_demo_database()
rec <- get_record(id = 'demo_1')
recs <- get_record(id = c('demo_1', 'demo_2'))

# delete demo after example
delete_database()
