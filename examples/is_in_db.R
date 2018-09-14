library(restez)
# set the restez path to a temporary dir
restez_path_set(filepath = tempdir())
restez_connect()
# create demo database
demo_db_create(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
ids <- c('thisisnotanid', 'demo_1', 'demo_2')
(is_in_db(id = ids))


# delete demo after example
db_delete(everything = TRUE)
