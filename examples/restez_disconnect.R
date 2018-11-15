library(restez)
fp <- tempdir()
restez_path_set(filepath = fp)
demo_db_create()
restez_connect()
restez_status()
# always remember to disconnect from a database when you've finished
restez_disconnect()
db_delete(everything = TRUE)
# Errors
# restez_status()
