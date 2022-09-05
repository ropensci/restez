#' @name db_download_intern
#' @family private
#' @title Download database (internal version)
#' @description Download .seq.tar files from the latest GenBank release. The
#' user interactively selects the parts of GenBank to download (e.g. primates,
#' plants, bacteria ...).
#' This is an internal function so the download can be wrapped in `while()` to
#' enable persistent downloading.
#' @details
#' The downloaded files will appear in the restez filepath under downloads.
#' @param db Database type, only 'nucleotide' currently available.
#' @param preselection Character vector of length 1; GenBank domains to
#'   download. If not specified (default), a menu will be provided for
#'   selection.
#'   To specify, provide either a single number or a single character string
#'   of numbers separated by spaces, e.g. "19 20" for 'Phage' (19) and
#'   'Unannotated' (20).
#' @param overwrite T/F, overwrite pre-existing downloaded files?
#' @return T/F, if all files download correctly, TRUE else FALSE.
#'
db_download_intern <- function(
  db='nucleotide', overwrite=FALSE, preselection=NULL
  ) {
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
    cli::cat_bullet(
      spacer, char(gbdomain), '\n', lowerspacer, stat(types[[i]]),
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
    cat_line(
      'Not all the file(s) downloaded. The server may be down. ',
      'You can always try running db_download() again at a later time.')
  } else {
    cat_line('Done. Enjoy your day.')
  }
  invisible(!any_fails)
}

#' @name db_download
#' @family database
#' @title Download database
#' @description Download .seq.tar files from the latest GenBank release.
#' @details
#' In default mode, the user interactively selects the parts (i.e., "domains")
#' of GenBank to download (e.g. primates, plants, bacteria ...). Alternatively,
#' the selected domains can be provided as a character string to `preselection`.
#'
#' The `max_tries` argument is useful for large databases that may otherwise
#' fail due to periodic lapses in internet connectivity. This value can be set
#' to `Inf` to continuously try until the database download succeeds (not
#' recommended if you do not have an internet connection!).
#' @inherit db_download_intern
#' @param max_tries Numeric vector of length 1; maximum number of times to
#'   attempt downloading database (default 1).
#' @seealso [ncbi_acc_get()]
#' @export
#' @examples
#' \dontrun{
#' library(restez)
#' restez_path_set(filepath = 'path/for/downloads')
#' db_download()
#' }
db_download <- function(
  db='nucleotide', overwrite=FALSE, preselection=NULL, max_tries = 1
  ) {

  # Check max_tries
  max_tries <- as.numeric(max_tries)
  assertthat::assert_that(assertthat::is.number(max_tries))
  assertthat::assert_that(
    max_tries > 0,
    msg = "'max_tries' must be greater than 0")

  # Issue warning if needed
  if (max_tries > 1 && overwrite == TRUE) {
    warning(
      "Setting 'overwrite' to FALSE is suggested with 'max_tries' > 1. Otherwise, each download attempt will start from scratch and the complete download may never finish" # nolint
    )
  }

  # Run in a while() loop to enable persistant downloads
  tries <- 0
  while (tries < max_tries) {
    dl_res <- try(
      db_download_intern(
        db = db, overwrite = overwrite, preselection = preselection
      )
    )
    if (inherits(dl_res, "try-error")) {
      # Report error before trying again
      cat("ERROR: ", dl_res, "\n")
      tries <- tries + 1
      message(paste("Trying again, attempt number", tries))
      # Wait 10 secs before next attempt
      Sys.sleep(10)
     } else {
      return(invisible(dl_res))
     }
}

}

#' @name db_create
#' @title Create new NCBI database
#' @family database
#' @description Create a new local SQL database from downloaded files.
#' Currently only GenBank/nucleotide/nuccore database is supported.
#' @details
#' All .seq.gz files are added to the database by default. A user can specify
#' minimum/maximum sequence lengths or accession numbers to limit the sequences
#' to be added to the database -- smaller databases are faster to search. The
#' final selection of sequences is the result of applying all filters
#' (`acc_filter`, `min_length`, `max_length`) in combination.
#' 
#' The `scan` option can decrease the time needed to build a database if only a
#' small number of sequences should be written to the database compared to the
#' number of the sequences downloaded from GenBank; i.e., if many of the files
#' downloaded from GenBank do not contain any sequences that should be written
#' to the database. When set to TRUE, if a file does not contain any of the
#' accessions in `acc_filter`, further processing of that file will be skipped
#' and none of the sequences it contains will be added to the database.
#'
#' Alternatively, a user can use the `alt_restez_path` to add the files
#' from an alternative restez file path. For example, you may wish to have a
#' database of all environmental sequences but then an additional smaller one of
#' just the sequences with lengths below 100 bp. Instead of having to download
#' all environmental sequences twice, you can generate multiple restez databases
#' using the same downloaded files from a single restez path.
#'
#' This function will not overwrite a pre-existing database. Old databases must
#' be deleted before a new one can be created. Use [db_delete()] with
#' everything=FALSE to delete an SQL database.
#'
#' Connections/disconnections to the database are made automatically.
#'
#' @inheritParams gb_df_generate
#' @inheritParams gb_build
#' @param db_type character, database type
#' @param alt_restez_path Alternative restez path if you would like to use the
#' downloads from a different restez path.
#' @return NULL
#' @export
#' @examples
#' \dontrun{
#' # Example of general usage
#' library(restez)
#' restez_path_set(filepath = 'path/for/downloads/and/database')
#' db_download()
#' db_create()
#'
#' # Example of using `acc_filter`
#' #
#' # Download files to temporary directory
#' temp_dir <- paste0(tempdir(), "/restez", collapse = "")
#' dir.create(temp_dir)
#' restez_path_set(filepath = temp_dir)
#' # Choose GenBank domain 20 ('unannotated'), the smallest
#' db_download(preselection = 20)
#' # Only include three accessions in database
#' db_create(
#'   acc_filter = c("AF000122", "AF000123", "AF000124")
#' )
#' list_db_ids()
#' db_delete()
#' unlink(temp_dir)
#' }
# db_type: a nod to the future
db_create <- function(
  db_type = 'nucleotide', min_length = 0, max_length = NULL,
  acc_filter = NULL, invert = FALSE, alt_restez_path = NULL,
  scan = FALSE) {
  on.exit(restez_disconnect())
  # LT548182 did not appear in rodent database with size limits, why?
  if (db_type != 'nucleotide') {
    stop('Database types, other than nucleotide, not yet supported.')
  }
  # checks
  restez_path_check()
  # first close any connection if one exists
  restez_disconnect()
  # check if db exists with data
  restez_connect(read_only = FALSE)
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
  cat_line('Inspecting ', stat(length(seq_files)), ' file(s) to add to the database ...')
  # log min and max
  db_sqlngths_log(min_lngth = min_length, max_lngth = max_length)
  read_errors <- gb_build(dpth = dpth, seq_files = seq_files,
                           max_length = max_length, min_length = min_length,
                           acc_filter = acc_filter, invert = invert,
                           scan = scan)
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
  on.exit(restez_disconnect())
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
  if (length(sql_path_get()) > 0 && file.exists(sql_path_get())) {
    unlink(sql_path_get())
  }
  if (everything) {
    if (length(restez_path_get()) > 0 && dir.exists(restez_path_get())) {
      unlink(restez_path_get(), recursive = TRUE)
      restez_path_unset()
    }
  }
  invisible(NULL)
}

#' Get accession numbers by querying NCBI GenBank
#'
#' The query string can be formatted using
#' [GenBank advanced query terms](https://www.ncbi.nlm.nih.gov/nuccore/advanced)
#' to obtain accession numbers corresponding to a specific set of criteria.
#'
#' Note this queries NCBI GenBank, not the local database generated with restez.
#'
#' It can be used either to restrict the accessions used to construct the local
#' database (`acc_filter` argument of [db_create()]) or to specify accessions
#' to read from the local database (`id` argument of [gb_fasta_get()] and other
#' gb_*_get() functions).
#'
#' @param query Character vector of length 1; query string to search GenBank.
#' @param strict Logical vector of length 1; should an error be issued if
#' the number of unique accessions retrieved does not match the number of hits
#' from GenBank? Default TRUE.
#' @param drop_ver Logical vector of length 1; should the version part of the
#' accession number (e.g., '.1' in 'AB001538.1') be dropped? Default TRUE.
#' @return Character vector; accession numbers resulting from query.
#' @seealso [db_create()], [gb_fasta_get()]
#' @examples
#' \dontrun{
#'   # requires an internet connection
#'   cmin_accs <- ncbi_acc_get("Crepidomanes minutum")
#'   length(cmin_accs)
#'   head(cmin_accs)
#' }
#' @export
ncbi_acc_get <- function(query, strict = TRUE, drop_ver = TRUE) {

  assertthat::assert_that(assertthat::is.string(query))
  assertthat::assert_that(assertthat::is.flag(strict))
  assertthat::assert_that(assertthat::is.flag(drop_ver))

  # Conduct search and keep results on server,
  # don't download anything yet
  search_res <- rentrez::entrez_search(
    db = "nuccore",
    term = query,
    use_history = TRUE,
    retmax = 0
  )

  # Make sure something is in there
  if (search_res$count < 1) {
    warning("Query resulted in no hits")
    return(NA_character_)
  }

  # Number of hits NCBI allows us to download at once.
  # This should not need to be changed
  max_hits <- 9999

  # NCBI won't return more than 10,000 results at a time.
  # So download in chunks to account for this
  if (search_res$count > max_hits) {

    # Determine number of chunks
    n_chunks <- search_res$count %/% max_hits

    # Set vector of start values: each chunk
    # will be downloaded starting from that point
    # Note NCBI indexing is zero-based
    start_vals <- c(0, seq_len(n_chunks) * max_hits)

    # Loop over start values and download up to max_hits for each,
    # then combine
    accessions <- lapply(
      start_vals,
      function(x) {
        rentrez::entrez_fetch(
        db = "nuccore",
        web_history = search_res$web_history,
        rettype = "acc",
        retstart = x,
        retmax = max_hits
      )
      }
    )
    accessions <- paste(accessions, collapse = "")
  } else {
    accessions <- rentrez::entrez_fetch(
      db = "nuccore",
      web_history = search_res$web_history,
      rettype = "acc"
    )
  }

  # NCBI returns accessions as single string, so split into vector
  accessions <- strsplit(x = accessions, split = "\\n")[[1]]

  # Remove accession version number
  if (drop_ver) {
    accessions <- sub(pattern = "\\.[0-9]+$", replacement = "", x = accessions)
  }

  if (strict) {
    n_accs <- length(accessions)
    assertthat::assert_that(
      search_res$count == n_accs,
      msg = paste0(
        "Number of accessions (", n_accs, ") not equal to number of GenBank hits (", search_res$count, ")" # nolint
      )
    )
    n_uniq <- length(unique(accessions))
    assertthat::assert_that(
      search_res$count == n_uniq,
      msg = paste0(
         "Number of unique accessions (", n_uniq, ") not equal to number of GenBank hits (", search_res$count, ")" # nolint
      )
    )
  }
  accessions
}
