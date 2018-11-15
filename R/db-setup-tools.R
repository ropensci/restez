#' @name db_download
#' @family database
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
  release <- latest_genbank_release()
  cat_line('... release number ', stat(release))
  latest_genbank_release_notes()
  downloadable_table <- identify_downloadable_files()
  cat_line('... found ', stat(nrow(downloadable_table)), ' sequence files')
  types <- sort(table(downloadable_table[['descripts']]), decreasing = TRUE)
  typesizes <- sort(tapply(as.numeric(downloadable_table[['filesizes']]),
                           downloadable_table[['descripts']], sum),
                    decreasing = TRUE)
  typesizes <- typesizes / 1E9
  cat(cli::rule())
  cat_line('\nWhich sequence file types would you like to download?')
  cat_line('Choose from those listed below:')
  for (i in seq_along(types)) {
    typ_nm <- names(types)[[i]]
    ngbs <- signif(typesizes[[typ_nm]], digits = 3)
    spacer <- paste0(i, paste0(rep(' ', 3 - nchar(i)), collapse = ''), '- ')
    lowerspacer <- paste0(rep('  ', nchar(spacer) - 1), collapse = '')
    gbdomain <- sub(pattern = ',$', replacement = '', x = names(types)[[i]])
    cli::cat_bullet(spacer, char(gbdomain), '\n', lowerspacer, stat(types[[i]]),
                    ' files and ', stat(ngbs, 'GB'))
  }
  cat_line('Provide one or more numbers separated by spaces.')
  mammal_indexs <- which(grepl(pattern = '(rodent|primate|mammal)',
                               x = names(types), ignore.case = TRUE))
  cat_line('e.g. to download all Mammalian sequences, type: ',
           '"', paste0(mammal_indexs, collapse = ' '), '" followed by Enter')
  cat_line('\nWhich files would you like to download?')
  if (is.null(preselection)) {
    response <- restez_rl(prompt = '(Press Esc to quit) ')
  } else {
    response <- as.character(preselection)
  }
  tryCatch(expr = {
    selected_types <- as.numeric(strsplit(x = response,
                                          split = '\\s')[[1]])
    if (length(selected_types) == 0) stop()
    }, error = function(e) {
      stop('User provided invalid number or argument', call. = FALSE)
      })
  cat_line(cli::rule())
  nfiles <- sum(types[selected_types])
  ngbs <- signif(sum(typesizes[selected_types]), digits = 3)
  cat_line("You've selected a total of ", stat(nfiles), " file(s) and ",
           stat(ngbs, 'GB'), " of uncompressed data.", "\nThese represent: ")
  for (ech in names(types)[selected_types]) {
    cli::cat_bullet(char(ech))
  }
  predict_datasizes(uncompressed_filesize = ngbs)
  cat_line('Is this OK?')
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
    stat_i <- paste0(i, '/', length(files_to_download))
    cat_line('... ', char(fl), ' (', stat(stat_i), ')')
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
  invisible(!any_fails)
}

#' @name db_create
#' @title Create new NCBI database
#' @family database
#' @description Create a new local SQL database from downloaded files.
#' Currently only GenBank/nucleotide/nuccore database is supported.
#' @details
#' All .seq.gz files are added to the database. A user can specify sequence
#' limit sizes for those sequences to be added to the database -- smaller
#' databases are faster to search.
#'
#' Alternatively, a user can use the \code{alt_restez_path} to add the files
#' from an alternative restez file path. For example, you may wish to have a
#' database of all environmental sequences but then an additional smaller one of
#' just the sequences with lengths below 100 bp. Instead of having to download
#' all environmental sequences twice, you can generate multiple restez databases
#' using the same downloaded files from a single restez path.
#'
#' This function will not overwrite a pre-existing database. Old databases must
#' be deleted before a new one can be created. Use \code{\link{db_delete}} with
#' everything=FALSE to delete an SQL database.
#' 
#' Connections/disconnections to the database are made automatically.
#'
#' @param db_type character, database type
#' @param min_length Minimum sequence length, default 0.
#' @param max_length Maximum sequence length, default NULL.
#' @param alt_restez_path Alternative restez path if you would like to use the
#' downloads from a different restez path.
#' @return NULL
#' @export
#' @examples
#' \dontrun{
#' library(restez)
#' restez_path_set(filepath = 'path/for/downloads/and/database')
#' db_download()
#' db_create()
#' }
# db_type: a nod to the future,
db_create <- function(db_type='nucleotide', min_length=0, max_length=NULL,
                      alt_restez_path = NULL) {
  # LT548182 did not appear in rodent database with size limits, why?
  if (db_type != 'nucleotide') {
    stop('Database types, other than nucleotide, not yet supported.')
  }
  # checks
  restez_path_check()
  quiet_connect()
  with_data <- has_data()
  restez_disconnect()
  if (with_data) {
    stop('Database already exists. Use `db_delete()`.')
  }
  # alternative downloads
  if (!is.null(alt_restez_path)) {
    dpth <- file.path(alt_restez_path, 'downloads')
    if (!dir.exists(dpth)) {
      stop(paste0('[', dpth, '] could not be found.'))
    }
  } else {
    dpth <- dwnld_path_get()
  }
  # add
  seq_files <- list.files(path = dpth, pattern = '.seq.gz$')
  cat_line('Adding ', stat(length(seq_files)), ' file(s) to the database ...')
  # log min and max
  db_sqlngths_log(min_lngth = min_length, max_lngth = max_length)
  # Note, avoid callr with gb_build()
  read_errors <- gb_build2(dpth = dpth, seq_files = seq_files,
                           max_length = max_length, min_length = min_length)
  cat_line('Done.')
  if (read_errors) {
    message('Some files failed to be read. Try running db_download() again.')
  }
}

#' @name demo_db_create
#' @title Create demo database
#' @family database
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
  quiet_connect()
  on.exit(restez_disconnect())
  # create
  df <- mock_gb_df_generate(n = n)
  gb_sql_add(df = df)
}

#' @name db_delete
#' @title Delete database
#' @family database
#' @description Delete the local SQL database and/or restez folder.
#' @param everything T/F, delete the whole restez folder as well?
#' @details Any connected database will be automatically disconnected.
#' @return NULL
#' @export
#' @example examples/db_delete.R
db_delete <- function(everything = FALSE) {
  restez_disconnect()
  if (length(sql_path_get()) > 0 && dir.exists(sql_path_get())) {
    unlink(sql_path_get(), recursive = TRUE)
  }
  if (everything) {
    if (length(restez_path_get()) > 0 && dir.exists(restez_path_get())) {
      unlink(restez_path_get(), recursive = TRUE)
      restez_path_unset()
    }
  }
  invisible(NULL)
}
