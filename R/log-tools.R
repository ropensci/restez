download_record_log <- function(fl) {
  fp <- file.path(restez_path_get(), 'download_log.tsv')
  row_entry <- data.frame('File' = fl, 'GB.release' = release_get(),
                          'Time' = as.character(Sys.time()))
  write.table(x = row_entry, file = fp, append = file.exists(fp), sep = '\t',
              col.names = !file.exists(fp), row.names = FALSE)
}

add_record_log <- function() {

}

gbrelease_log <- function() {

}

release_get <- function() {
  fp <- file.path(restez_path_get(), 'gb_release.txt')
  if (file.exists(fp)) {
    res <- read.table(file = fp, header = FALSE)[[1]]
  } else {
    res <- ''
  }
  res
}

release_set <- function(release) {
  fp <- file.path(restez_path_get(), 'gb_release.txt')
  write(x = release, file = fp)
}

release_check <- function() {
  latest_release <- identify_latest_genbank_release_notes(
    just_release_number = TRUE)
  current_release <- release_get()
  cat_line('The latest GenBank release is ', stat(latest_release))
  cat_line('Current release on your system ', stat(current_release))
  if (latest_release > current_release) {
    cat_line('Your database is out-of-date.')
    cat_line('Consider re-running `db_download()` with overwrite=TRUE.')
    res <- FALSE
  } else {
    cat_line('Your database is up-to-date')
    res <- TRUE
  }
  res
}

last_download_log <- function() {

}

last_add_log <- function() {

}

db_nrows_check <- function() {

}
