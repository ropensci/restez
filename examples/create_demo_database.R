library(restez)
# set the restez path to a temporary dir
set_restez_path(filepath = tempdir())
# create demo database
create_demo_database(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
(get_sequence(id = 'demo_1'))

# Be careful with the database as it build cummulatively.
#  if we running create_demo_database/create_database
#  will append new entries to the preexisitng database
create_demo_database(n = 100)
# Leading to multiple entries if IDs are the same
(get_sequence(id = 'demo_1'))

# To resovle this issue, always delete a demo database
#  after an example
delete_database()
