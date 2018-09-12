# Vars

devtools::load_all('~/Coding/restez')
restez_path_set('~/Desktop')
restez_connect()
restez_status(gb_check = TRUE)

connected()

restez_disconnect()
db_delete(everything = TRUE)

db_download()

# TODO:
# - update 'records' data with difficult records
# - update file size calulcations
