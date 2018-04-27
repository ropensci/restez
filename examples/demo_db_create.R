library(restez)
# set the restez path to a temporary dir
restez_path_set(filepath = tempdir())
# create demo database
demo_db_create(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
(gb_sequence_get(id = 'demo_1'))

# Be careful with the database as it build cummulatively.
#  if we running demo_db_create/db_create
#  will append new entries to the preexisitng database
demo_db_create(n = 100)
# Leading to multiple entries if IDs are the same
(gb_sequence_get(id = 'demo_1'))

# To resovle this issue, always delete a demo database
#  after an example
db_delete()
