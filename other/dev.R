# Vars



# TODO:
# - update 'records' data with difficult records
# - update file size calulcations


devtools::load_all('.')
restez_path_set('.')
db_delete(everything = TRUE)
restez_path_set('.')
restez_connect()

restez_disconnect()
