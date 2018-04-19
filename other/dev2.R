library(restez)

download_genbank()
create_database(overwrite = TRUE)

restez:::get_sql_path()
