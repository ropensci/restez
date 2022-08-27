library(restez)
fp <- tempdir()
restez_path_set(filepath = fp)
demo_db_create(n = 5)
restez_status()
db_delete(everything = TRUE)
# Errors:
# restez_status()
