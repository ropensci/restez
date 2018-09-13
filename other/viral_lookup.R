# How long does it take to get the definition of a single ID from viral sequences?
# setup
devtools::load_all('~/Coding/restez')
restez_path_set('~/Desktop/viral')
db_delete(everything = TRUE)
restez_path_set('~/Desktop/viral')
db_download(preselection = '13')
restez_connect()
db_create()
restez_disconnect()

# get def
devtools::load_all('~/Coding/restez')
restez_path_set('~/Desktop/viral')
restez_connect()
id <- sample(list_db_ids(), 1)
system.time(gb_definition_get(id))