library(restez)
fp <- tempdir()
set_restez_path(filepath = fp)
create_demo_database(n = 10)
delete_database(everything = FALSE)
# Will not run: get_sequence(id = 'demo_1')
# only the SQL database is deleted
delete_database(everything = TRUE)
# Now returns NULL
(get_restez_path())
