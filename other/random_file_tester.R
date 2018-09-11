# Test download, building and querying random seq.files from GenBank
# Vars
n <- 2  # n per genbank type
wd <- '.'
restez_lib_path <- '~/Coding/restez'
to_download <- TRUE
to_build <- TRUE

# restez setup
devtools::load_all(restez_lib_path)
restez_path_set(wd)

if (to_download) {
  # delete any old files
  db_delete(everything = TRUE)
  restez_path_set(wd)

  # Identify random seq files
  identify_latest_genbank_release_notes()
  downloadable_table <- identify_downloadable_files()
  colnames(downloadable_table)
  cats <- as.character(unique(downloadable_table[['descripts']]))
  seq_files <- unlist(lapply(X = cats, FUN = function(x) {
    indxs <- which(x == downloadable_table[['descripts']])
    rand_indxs <- sample(indxs, n)
    as.character(downloadable_table[rand_indxs, 'seq_files'])
  }))

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
}

# Create db
if (to_build) {
  restez_connect()
  on.exit(restez_disconnect())
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
}

# Query
restez_connect()
on.exit(restez_disconnect())
ids <- list_db_ids(n = NULL)
ids <- sample(ids, round(length(ids) * .1))
for (id in ids) {
  definition <- gb_definition_get(id)
  fasta <- gb_fasta_get(id)
  organism <- gb_organism_get(id)
  rcrd <- gb_record_get(id)
  vrsn <- gb_version_get(id)
}
cat('Completed.\n')
