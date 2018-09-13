# Vars



# TODO:



devtools::load_all('.')
restez_path_set('.')
db_delete(everything = TRUE)
restez_path_set('.')
db_download(preselection = 'demo')

restez_connect()

restez_disconnect()
