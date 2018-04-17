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
  cat('Looking up latest GenBank release ...\n')
  release <- identify_latest_genbank_release_notes()
  release_url <- paste0('ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/',
                        release)
  release_notes <- RCurl::getURL(url = release_url)
  write(x = release_notes, file = file.path(get_dwnld_path(),
                                            'latest_release_notes.txt'))
  downloadable_table <- identify_downloadable_files(release_notes)
  cat('... Found [', nrow(downloadable_table), '] sequence files\n',
      sep = '')
  types <- sort(table(downloadable_table[['descripts']]),
                decreasing = TRUE)
  cat('\nWhich sequence file types would you like to download?\n')
  cat('Choose from those listed below:')
  for (i in seq_along(types)) {
    typ_nm <- names(types)[[i]]
    cat(i, '  -  ', typ_nm, ' [', types[[i]],
        ' sequence files]\n', sep = '')
  }
  cat('Provide one or more numbers separated by spaces.\n')
  cat('e.g. "1 4 7"\n')
  cat('Which files would you like to download?\n')
  response <- readline(prompt = '(Press Esc to quit) ')
  selected_types <- as.numeric(strsplit(x = response,
                                        split = '\\s')[[1]])
  cat('Downloading [', sum(types[selected_types]),
      '] files for:\n', paste0(names(types)[selected_types],
                               collapse = ', '), ' ...\n', sep = '')
  pull <- downloadable_table[['descripts']] %in% names(types)[selected_types]
  files_to_download <- as.character(downloadable_table[['seq_files']][pull])
  for (i in seq_along(files_to_download)) {
    fl <- files_to_download[[i]]
    cat('... ', fl, ' (', i, '/', length(files_to_download),
        ')\n', sep = '')
    success <- download_file(fl, overwrite = overwrite)
    if (!success) {
      cat('... unable to download. You can run download_genbank() again.')
    }
  }
}

#' @name create_database
#' @title Create database
#' @description Searches
#' @return NULL
#' @export
create_database <- function() {
  # checks
  check_restez_fp()
  dpth <- get_dwnld_path()
  gz_files <- list.files(path = dpth, pattern = '.gz$')
  cat('... Decompressing downloaded files\n')
  for (gz_file in gz_files) {
    flpth <- file.path(dpth, gz_file)
    R.utils::gunzip(flpth, remove = FALSE)
  }
  seq_files <- list.files(path = get_dwnld_path(), pattern = '.seq$')
  cat('... Adding files to database\n')
  for (seq_file in seq_files) {
    flpth <- file.path(dpth, seq_file)
    records <- read_records(filepath = flpth)
    df <- generate_dataframe(records = records)
    add_to_database(df = df, database = 'nucleotide')
  }
}
