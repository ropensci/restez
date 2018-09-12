# Vars

devtools::load_all('~/Coding/restez')
restez_path_set('~/Desktop')
restez_connect()
restez_status(gb_check = TRUE)
restez_disconnect()
db_delete(everything = TRUE)

db_download()

# TODO:
# - update 'records' data with difficult records
# - create connected() and with_data() functions
# - breakup restez_status, output structured list, bring back restez_ready
# - update file size calulcations
