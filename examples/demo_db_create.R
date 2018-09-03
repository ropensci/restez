library(restez)
# set the restez path to a temporary dir
restez_path_set(filepath = tempdir())
restez_connect()
# create demo database
demo_db_create(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
(gb_sequence_get(id = 'demo_1'))

# Delete a demo database after an example
restez_disconnect()
db_delete()
