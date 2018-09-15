rodents_path <- file.path(getwd(), 'rodents')
if (!dir.exists(rodents_path)) {
  dir.create(rodents_path)
}
library(restez)
# set the restez path to a memorable location
restez_path_set(rodents_path)
# download for domain 15
dwntm <- system.time(db_download(preselection = '15'))
restez_connect()
crttm <- system.time(db_create())
# always disconnect
restez_disconnect()

dpth <- restez:::dwnld_path_get()
seq_files <- list.files(path = dpth, pattern = '.seq.gz$')
indexes <- which(seq_files == 'gbrod30.seq.gz'):length(seq_files)
restez_connect()
for (i in indexes) {
  seq_file <- seq_files[[i]]
  restez:::cat_line('... ', restez:::char(seq_file), '(',
                    restez:::stat(i, '/', length(seq_files)), ')')
  flpth <- file.path(dpth, seq_file)
  records <- restez:::flatfile_read(flpth = flpth)
  if (length(records) > 0) {
    df <- restez:::gb_df_generate(records = records)
    restez:::gb_sql_add(df = df)
  } else {
    read_errors <- TRUE
    restez:::cat_line('... ... Hmmmm... no records found in that file.')
  }
  restez:::add_rcrd_log(fl = seq_file)
}
