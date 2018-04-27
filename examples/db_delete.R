library(restez)
fp <- tempdir()
restez_path_set(filepath = fp)
demo_db_create(n = 10)
db_delete(everything = FALSE)
# Will not run: gb_sequence_get(id = 'demo_1')
# only the SQL database is deleted
db_delete(everything = TRUE)
# Now returns NULL
(restez_path_get())
