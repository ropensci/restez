# TODO: record user's selection.
# LOG TOOLS
#' @name dwnld_rcrd_log
#' @title Log a downloaded file in the restez path
#' @description This function is called whenever a file is successfully
#' downloaded. A row entry is added to the 'download_log.tsv' in the user's
#' restez path containing the file name, the GB release number and the time of
#' successfuly download. The log is to help users keep track of when they
#' downloaded files and to determine if the downloaded files are out of date.
#' @param fl file name, character
#' @return NULL
#' @family private
dwnld_rcrd_log <- function(fl) {
  fp <- file.path(restez_path_get(), 'download_log.tsv')
  row_entry <- data.frame('File' = fl, 'GB.release' = gbrelease_get(),
                          'Time' = as.character(Sys.time()))
  write.table(x = row_entry, file = fp, append = file.exists(fp), sep = '\t',
              col.names = !file.exists(fp), row.names = FALSE, quote = FALSE)
}

#' @name add_rcrd_log
#' @title Log sequences added to the SQL database in the restez path
#' @description This function is called whenever sequences have been
#' successfully added to the nucleotide SQL database. Row entries are added to
#' 'add_lot.tsv' in the user's restez path containing the sequence accession,
#' version and GB release numbers as well as the time of successfuly adding.
#' The log is to help users keep track of when sequences have been added.
#' @param df sequence records, data.frame
#' @return NULL
#' @family private
add_rcrd_log <- function(df) {
  fp <- file.path(restez_path_get(), 'add_log.tsv')
  rows_entry <- data.frame('Accession' = df[['accession']],
                           'Version' = df[['version']],
                           'GB.release' = gbrelease_get(),
                           'Time' = as.character(Sys.time()))
  write.table(x = rows_entry, file = fp, append = file.exists(fp), sep = '\t',
              col.names = !file.exists(fp), row.names = FALSE, quote = FALSE)
}

#' @name gbrelease_log
#' @title Log the GenBank release number in the restez path
#' @description This function is called whenever db_download is run. It logs the
#' GB release number in the 'gb_release.txt' in the user's restez path.
#' The log is to help users keep track of whether their database if out of date.
#' @param release GenBank release number, character
#' @return NULL
#' @family private
gbrelease_log <- function(release) {
  # release number can be in the form 'gb.release####'
  fp <- file.path(restez_path_get(), 'gb_release.txt')
  write(x = gsub(pattern = '[^0-9]', replacement = '', x = release), file = fp)
}

# GET TOOLS
#' @name gbrelease_log
#' @title Log the GenBank release number in the restez path
#' @description This function is called whenever db_download is run. It logs the
#' GB release number in the 'gb_release.txt' in the user's restez path.
#' The log is to help users keep track of whether their database if out of date.
#' @param release GenBank release number, character
#' @return NULL
#' @family private
gbrelease_get <- function() {
  fp <- file.path(restez_path_get(), 'gb_release.txt')
  if (file.exists(fp)) {
    res <- read.table(file = fp, header = FALSE)[[1]]
  } else {
    res <- ''
  }
  res
}

#' @name last_entry_get
#' @title Return the last entry
#' @description Return the last entry from a tab-delimited log file.
#' @param fp Filepath, character
#' @return vector
#' @family private
last_entry_get <- function(fp) {
  last_entry <- readLines(con = fp)
  last_entry <- last_entry[[length(last_entry)]]
  strsplit(x = last_entry, split = '\\t')[[1]]
}

#' @name last_dwnld_get
#' @title Return date and time of the last download
#' @description Return the date and time of the last download as determined
#' using the 'download_log.tsv'.
#' @return character
#' @family private
last_dwnld_get <- function() {
  fp <- file.path(restez_path_get(), 'download_log.tsv')
  last_entry_get(fp = fp)[[3]]
}

#' @name last_add_get
#' @title Return date and time of the last added sequence
#' @description Return the date and time of the last added sequence as
#' determined using the 'add_log.tsv'.
#' @return character
#' @family private
last_add_get <- function() {
  fp <- file.path(restez_path_get(), 'add_log.tsv')
  last_entry_get(fp = fp)[[4]]
}

#' @name db_nrows_get
#' @title Return the number of rows in a db
#' @description Return the number of rows in the SQL database in the user's
#' restez_path.
#' @details Requires an open connection.
#' @return integer
#' @family private
db_nrows_get <- function() {
  qry <- "SELECT count(*) FROM nucleotide"
  connection <- connection_get()
  qry_res <- DBI::dbSendQuery(conn = connection, statement = qry)
  on.exit(expr = {
    DBI::dbClearResult(res = qry_res)
  })
  res <- DBI::dbFetch(res = qry_res)
  res[[1]]
}

#' @name dir_size
#' @title Calculate the size of a directory
#' @description Returns the size of directory in GB
#' @return numberic
#' @family private
dir_size <- function(fp) {
  fls <- list.files(fp, all.files = TRUE, recursive = TRUE)
  fls <- file.path(fp, fls)
  totsz <- sum(vapply(X = fls, FUN = file.size, FUN.VALUE = double(1)),
                 na.rm = TRUE)
  round(x = totsz / 1E9, digits = 2)
}

# SPECIAL
#' @name gbrelease_check
#' @title Check if the last GenBank release number is the latest
#' @description Returns TRUE if the GenBank release number is the most recent
#' GenBank release available.
#' @return logical
#' @family private
gbrelease_check <- function() {
  cat_line('... Looking up latest GenBank release number')
  latest_release <- identify_latest_genbank_release_notes()
  latest_release <- as.integer(gsub(pattern = '[^0-9]', replacement = '',
                                    x = latest_release))
  current_release <- gbrelease_get()
  if (latest_release > current_release) {
    cat_line('... ... Your database is out-of-date.')
    cat_line('... ... The latest GenBank release is ', stat(latest_release))
    cat_line('... ... Consider re-running `db_download()` with overwrite=TRUE.')
    res <- FALSE
  } else {
    cat_line('... ... Your database is up-to-date')
    res <- TRUE
  }
  res
}
