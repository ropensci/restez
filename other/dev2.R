library(restez)

set_restez_path(filepath = tempdir())
# create demo database
create_demo_database(n = 100)
# in the demo, IDs are 'demo_1', 'demo_2' ...
(get_sequence(id = 'demo_1'))

id <- c('demo_1', 'demo_2')


res <- restez:::query_sql(nm = 'organism', id = id)
ors <- res[['organism']]
names(ors) <- res[['accession']]
ors
