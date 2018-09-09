# Vars
n <- 2
wd <- '.'
restez_lib_path <- '~/Coding/restez'

# restez setup
devtools::load_all(restez_lib_path)
restez_path_set(wd)
db_delete(everything = TRUE)
restez_path_set(wd)

# Identify random seq files
seq_files <- c('gbcon106.seq', 'gbsyn7.seq', 'gbvrl23.seq')

# Download them
for (i in seq_along(seq_files)) {
  fl <- seq_files[[i]]
  stat_i <- paste0(i, '/', length(seq_files))
  cat_line('... ', char(fl), ' (', stat(stat_i), ')')
  # TODO: move overwrite to here
  success <- file_download(fl, overwrite = FALSE)
  if (!success) {
    cat_line('... Hmmmm, unable to download that file.')
    any_fails <- TRUE
  }
}

# Create db
restez_connect()
dpth <- dwnld_path_get()
seq_files <- list.files(path = dpth, pattern = '.seq.gz$')
cat_line('Adding ', stat(length(seq_files)), ' file(s) to the database ...')
for (i in seq_along(seq_files)) {
  seq_file <- seq_files[[i]]
  cat_line('... ', char(seq_file), '(', stat(i, '/', length(seq_files)), ')')
  flpth <- file.path(dpth, seq_file)
  records <- flatfile_read(flpth = flpth)
  if (length(records) > 0) {
    df <- gb_df_generate(records = records, min_length = 0,
                         max_length = NULL)
    gb_sql_add(df = df)
  } else {
    read_errors <- TRUE
    cat_line('... ... Hmmmm... no records found in that file.')
  }
  add_rcrd_log(fl = seq_file)
}
cat('Done!\n')


# TODO:
# - update 'records' data with difficult records
# - create a download_path for db_create
# - create connected() and with_data() functions
# - breakup restez_status, output structured list, bring back restez_ready
#
