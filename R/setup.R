#' @name db_download
#' @family setup
#' @title Download database
#' @description Download .seq.tar files from the latest GenBank release. The
#' user interactively selects the parts of GenBank to download (e.g. primates,
#' plants, bacteria ...)
#' @details
#' The downloaded files will appear in the restez filepath under downloads.
#' @param db Database type, only 'nucleotide' currently available.
#' @param preselection character of user input
#' @param overwrite T/F, overwrite pre-existing downloaded files?
#' @return T/F, if all files download correctly, TRUE else FALSE.
#' @export
#' @examples
#' \dontrun{
#' library(restez)
#' restez_path_set(filepath = 'path/for/downloads')
#' db_download()
#' }
db_download <- function(db='nucleotide', overwrite=FALSE, preselection=NULL) {
  # checks
  restez_path_check()
  check_connection()
  cat_line(cli::rule())
  cat_line('Looking up latest GenBank release ...')
  release <- identify_latest_genbank_release_notes()
  release_url <- paste0('ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/',
                        release)
  release_notes <- RCurl::getURL(url = release_url)
  write(x = release_notes, file = file.path(dwnld_path_get(),
                                            'latest_release_notes.txt'))
  downloadable_table <- identify_downloadable_files(release_notes)
  cat_line('Found ', stat(nrow(downloadable_table)), ' sequence files')
  types <- sort(table(downloadable_table[['descripts']]), decreasing = TRUE)
  cat(cli::rule())
  cat_line('\nWhich sequence file types would you like to download?')
  cat_line('Choose from those listed below:')
  for (i in seq_along(types)) {
    typ_nm <- names(types)[[i]]
    cli::cat_bullet(i, '  -  ', char(typ_nm), ' (', stat(types[[i]]),
                    ' files available)')
  }
  cat_line('Provide one or more numbers separated by spaces.')
  cat_line('e.g. to download all Mammal sequences type:',
           '"12 14 15" followed by Enter')
  cat_line('Which files would you like to download?')
  if (is.null(preselection)) {
    response <- restez_rl(prompt = '(Press Esc to quit) ')
  } else {
    response <- preselection
  }
  tryCatch(expr = {
    selected_types <- as.numeric(strsplit(x = response,
                                          split = '\\s')[[1]])
    }, error = function(e) {
      stop('Invalid number or argument', call. = FALSE)
      })
  nfiles <- sum(types[selected_types])
  cat_line("You've selected a total of ", stat(nfiles),
           " file type(s). These represent:")
  for (ech in names(types)[selected_types]) {
    cli::cat_bullet(char(ech))
  }
  cat_line('Each file contains about 250 MB of decompressed data.')
  ngbytes_fls <- nfiles * 250 / 1000
  cat_line(stat(nfiles), ' file(s) amounts to about ', stat(ngbytes_fls, 'GB'))
  cat_line('Additionally, the resulting SQL database takes about 50 MB',
           ' per file')
  ngbytes <- ngbytes_fls + (nfiles * 50 / 1000)
  # TODO: create option for a user to delete downloaded files after download?
  cat_line('In total the uncompressed files and SQL database should amount to ',
           stat(ngbytes, 'GB'), ' Is that OK?')
  if (is.null(preselection)) {
    msg <- 'Enter any key to continue or press Esc to quit '
    response <- restez_rl(prompt = msg)
  }
  cat_line(cli::rule())
  cat_line("Downloading ...")
  # log the release number
  gbrelease_log(release = release)
  # log selection made
  slctn_log(selection = types[selected_types])
  pull <- downloadable_table[['descripts']] %in% names(types)[selected_types]
  files_to_download <- as.character(downloadable_table[['seq_files']][pull])
  any_fails <- FALSE
  for (i in seq_along(files_to_download)) {
    fl <- files_to_download[[i]]
    cat_line('... ', char(fl), ' (', stat(i, '/', length(files_to_download)),
             ')')
    # TODO: move overwrite to here
    success <- file_download(fl, overwrite = overwrite)
    if (!success) {
      cat_line('... Hmmmm, unable to download that file.')
      any_fails <- TRUE
    }
  }
  if (any_fails) {
    cat_line('Not all the file(s) downloaded. The server may be down. ',
             'You can always try running db_download() again at a later time.')
  } else {
    cat_line('Done. Enjoy your day.')
  }
  !any_fails
}

#' @name db_create
#' @title Create new NCBI database
#' @family setup
#' @description Create a new local SQL database from downloaded files.
#' Currently only GenBank/nucleotide/nuccore database is supported.
#' @details
#' All .seq.gz files are added to the database. A user can specify sequence
#' limit sizes for those sequences to be added to the database -- smaller
#' databases are faster to  search and is best to limit the database size if
#' possible.
#'
#' This function will not overwrite a pre-exisitng database. Old databases must
#' be deleted before a new one can be created. Use \code{\link{db_delete}} with
#' everything=FALSE to delete an SQL database.
#'
#' @param db_type character, database type
#' @param min_length Minimum sequence length, default 0.
#' @param max_length Maximum sequence length, default NULL.
#' @return NULL
#' @export
#' @examples
#' \dontrun{
#' library(restez)
#' restez_path_set(filepath = 'path/for/downloads')
#' db_download()
#' restez_connect()
#' db_create()
#' restez_disconnect()
#' }
# db_type: a nod to the future,
db_create <- function(db_type='nucleotide', min_length=0, max_length=NULL) {
  if (db_type != 'nucleotide') {
    stop('Database types, other than nucleotide, not yet supported.')
  }
  # checks
  restez_path_check()
  if (restez_ready() && db_nrows_get() > 0) {
    stop('Database already exists.')
  }
  dpth <- dwnld_path_get()
  seq_files <- list.files(path = dpth, pattern = '.seq.gz$')
  cat_line('Adding ', stat(length(seq_files)), ' file(s) to the database ...')
  for (i in seq_along(seq_files)) {
    seq_file <- seq_files[[i]]
    cat_line('... ', char(seq_file), '(', stat(i, '/', length(seq_files)), ')')
    flpth <- file.path(dpth, seq_file)
    records <- flatfile_read(filepath = flpth)
    df <- gb_df_generate(records = records, min_length = min_length,
                         max_length = max_length)
    gb_sql_add(df = df)
  }
  cat_line('Done.')
}

#' @name demo_db_create
#' @title Create demo database
#' @family setup
#' @description Creates a local mock SQL database
#' from package test data for demonstration purposes.
#' No internet connection required.
#' @param db_type character, database type
#' @param n integer, number of mock sequences
#' @return NULL
#' @export
#' @example examples/demo_db_create.R
demo_db_create <- function(db_type='nucleotide', n=100) {
  if (db_type != 'nucleotide') {
    stop('Database types, other than nucleotide, not yet supported.')
  }
  if (n <= 1) {
    stop('n must be greater than 1.')
  }
  # checks
  restez_path_check()
  # create
  df <- mock_gb_df_generate(n = n)
  gb_sql_add(df = df)
}
