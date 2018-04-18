#' @name download_genbank
#' @title Download GenBank
#' @description Download .seq.tar files from the latest GenBank
#' release. The user interacitvely selects the parts of
#' GenBank to download (e.g. primates, plants, bacteria ...)
#' @details
#' The downloaded files will appear in the restez filepath under
#' downloads.
#' @param overwrite T/F, overwrite pre-existing downloaded files?
#' @return NULL
#' @export
download_genbank <- function(overwrite=FALSE) {
  # checks
  check_restez_fp()
  check_connection()
  cat_line(cli::rule())
  cat_line('Looking up latest GenBank release ...')
  release <- identify_latest_genbank_release_notes()
  release_url <- paste0('ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/',
                        release)
  release_notes <- RCurl::getURL(url = release_url)
  write(x = release_notes, file = file.path(get_dwnld_path(),
                                            'latest_release_notes.txt'))
  downloadable_table <- identify_downloadable_files(release_notes)
  cat_line('Found ', stat(nrow(downloadable_table)),
           ' sequence files')
  types <- sort(table(downloadable_table[['descripts']]),
                decreasing = TRUE)
  cat(cli::rule())
  cat_line('\nWhich sequence file types would you like to download?')
  cat_line('Choose from those listed below:')
  for (i in seq_along(types)) {
    typ_nm <- names(types)[[i]]
    cli::cat_bullet(i, '  -  ', char(typ_nm),
                    ' (', stat(types[[i]]), ' files available)')
  }
  cat_line('Provide one or more numbers separated by spaces.')
  cat_line('e.g. to download all Mammal sequences type: "12 14 15" followed by Enter')
  cat_line('Which files would you like to download?')
  response <- restez_rl(prompt = '(Press Esc to quit) ')
  tryCatch(expr = {
    selected_types <- as.numeric(strsplit(x = response,
                                          split = '\\s')[[1]])
    }, error = function(e) {
      stop('Invalid number or argument', call. = FALSE)
      })
  nfiles <- sum(types[selected_types])
  cat_line("You've selected a total of ", stat(nfiles),
           " file types. These represent:")
  for (ech in names(types)[selected_types]) {
    cli::cat_bullet(char(ech))
  }
  cat_line('Each file contains about 300 MB of decompressed data.')
  ngbytes <- nfiles * 300 / 1000
  cat_line(stat(nfiles), ' files amounts to about ', stat(ngbytes, 'GB'),
           '. Is that OK?')
  response <- restez_rl(prompt = 'Enter any key to continue or press Esc to quit ')
  cat_line(cli::rule())
  cat_line("Downloading ...")
  pull <- downloadable_table[['descripts']] %in% names(types)[selected_types]
  files_to_download <- as.character(downloadable_table[['seq_files']][pull])
  for (i in seq_along(files_to_download)) {
    fl <- files_to_download[[i]]
    cat_line('... ', char(fl), ' (', stat(i, '/', length(files_to_download)), ')')
    success <- download_file(fl, overwrite = overwrite)
    if (!success) {
      cat_line('... Hmmmm, unable to download. Try again, later?')
    }
  }
  cat_line('Done. Enjoy your day.')
}

#' @name create_database
#' @title Create database
#' @description Checks for downloaded .seq.tar files,
#' decompresses and then adds the files to a local SQL
#' database.
#' @param db_type character, database type
#' @param overwrite T/F, overwrite files already in database?
#' @return NULL
#' @export
# db_type: a nod to the future,
create_database <- function(db_type='nucleotide', overwrite=FALSE) {
  if (db_type != 'nucleotide') {
    stop('Database types, other than nucleotide, not yet supported.')
  }
  # checks
  check_restez_fp()
  dpth <- restez:::get_dwnld_path()
  gz_files <- list.files(path = dpth, pattern = '.gz$')
  if (!overwrite) {
    already_added <- list.files(path = dpth, pattern = '.seq$')
    already_added <- paste0(already_added, '.gz')
    gz_files <- gz_files[!gz_files %in% already_added]
  }
  cat_line('Decompressing and adding ', stat(length(gz_files)),
           'files to database ...')
  for (gz_file in gz_files) {
    cat_line('... ', char(gz_file))
    cat_line('... ... decompressing')
    flpth <- file.path(dpth, gz_file)
    R.utils::gunzip(flpth, remove = FALSE, overwrite = TRUE)
    cat_line('... ... adding')
    seq_file <- sub(pattern = '\\.gz$', replacement = '',
                    x = gz_file)
    flpth <- file.path(dpth, seq_file)
    records <- read_records(filepath = flpth)
    df <- generate_dataframe(records = records)
    add_to_database(df = df, database = 'nucleotide')
  }
  cat_line('Done.')
}

#' @name create_demo_database
#' @title Create demo database
#' @description Creates a local mock SQL database
#' from package test data for demonstration purposes.
#' No internet connection required.
#' @param db_type character, database type
#' @param n integer, number of mock sequences
#' @return NULL
#' @export
create_demo_database <- function(db_type='nucleotide', n = 100) {
  if (db_type != 'nucleotide') {
    stop('Database types, other than nucleotide, not yet supported.')
  }
  if (n <= 1) {
    stop('n must be greater than 1.')
  }
  # checks
  check_restez_fp()
  # create
  df <- mock_nucleotide_df(n = n)
  add_to_database(df = df, database = 'nucleotide')
}
