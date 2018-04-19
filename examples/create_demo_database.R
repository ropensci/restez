library(restez)
# set the restez path to a temporary dir
set_restez_path(filepath = tempdir())
# create demo database
create_demo_database(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
(get_sequence(id = 'demo_1'))
