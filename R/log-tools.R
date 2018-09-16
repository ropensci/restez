# LOG TOOLS ----
#' @name readme_log
#' @title Create README in restez_path
#' @description Write notes for the curious sorts who peruse the restez_path.
#' @return NULL
#' @family private
readme_log <- function() {
  flpth <- file.path(restez_path_get(), 'README.txt')
  v <- utils::packageVersion("restez")
  readme <- paste0('Hello! This is restez v', v, '\n\n',
                   'This file was created: ', Sys.time(), '\n\n',
                   'This is the restez database folder. ',
                   'It contains all downloaded files ',
                   'from GenBank plus the SQL database.\n\n',
                   'Additionally, it contains useful log information ',
                   'indicating when the database was created, what files were',
                   ' added etc. Please provide this logged information if you ',
                   'raise a bug.',
                   ' It is best to raise any bug via GitHub issues:\n',
                   'https://github.com/AntonelliLab/restez/issues')
  write(x = readme, file = flpth)
}

#' @name seshinfo_log
#' @title Log the system session information in restez path
#' @description Records the session and system information to file.
#' @return NULL
#' @family private
seshinfo_log <- function() {
  flpth <- file.path(restez_path_get(), 'session_info.txt')
  session_info <- devtools::session_info()
  write(x = 'SYSTEM\n', file = flpth)
  utils::capture.output(session_info[[1]], file = flpth, append = TRUE)
  write(x = '\nPACKAGES\n', file = flpth, append = TRUE)
  utils::capture.output(session_info[[2]], file = flpth, append = TRUE)
}


#' @name db_sqlngths_log
#' @title Log the min and max sequence lengths
#' @description Log the min and maximum sequence length used in the created db.
#' @param min_lngth Minimum length
#' @param max_lngth Maximum length
#' @return NULL
#' @family private
db_sqlngths_log <- function(min_lngth, max_lngth) {
  fp <- file.path(restez_path_get(), 'seqlengths.tsv')
  if (is.null(max_lngth)) {
    max_lngth <- 'Inf'
  }
  row_entry <- data.frame('min' = min_lngth, 'max' = max_lngth)
  utils::write.table(x = row_entry, file = fp, sep = '\t')
}

#' @name slctn_log
#' @title Log the GenBank selection made by a user
#' @description This function is called whenever a user makes a selection with
#' the \code{\link{db_download}}. It records GenBank numbers selections.
#' @param selection selected GenBank sequences, named vector
#' @return NULL
#' @family private
slctn_log <- function(selection) {
  fp <- file.path(restez_path_get(), 'selection_log.tsv')
  row_entry <- data.frame('Selection' = names(selection),
                          'N.files' = as.numeric(selection),
                          'Time' = as.character(Sys.time()))
  utils::write.table(x = row_entry, file = fp, append = file.exists(fp),
                     sep = '\t', col.names = !file.exists(fp),
                     row.names = FALSE, quote = FALSE)
}

#' @name filename_log
#' @title Write filenames to log files
#' @description Record a filename in a log file along with GB release and time.
#' @param fl file name, character
#' @param fp filepath to log file, character
#' @return NULL
#' @family private
filename_log <- function(fl, fp) {
  row_entry <- data.frame('File' = fl, 'GB.release' = gbrelease_get(),
                          'Time' = as.character(Sys.time()))
  utils::write.table(x = row_entry, file = fp, append = file.exists(fp),
                     sep = '\t', col.names = !file.exists(fp),
                     row.names = FALSE, quote = FALSE)
}

#' @name dwnld_rcrd_log
#' @title Log a downloaded file in the restez path
#' @description This function is called whenever a file is successfully
#' downloaded. A row entry is added to the 'download_log.tsv' in the user's
#' restez path containing the file name, the GB release number and the time of
#' successfully download. The log is to help users keep track of when they
#' downloaded files and to determine if the downloaded files are out of date.
#' @param fl file name, character
#' @return NULL
#' @family private
dwnld_rcrd_log <- function(fl) {
  fp <- file.path(restez_path_get(), 'download_log.tsv')
  filename_log(fl = fl, fp = fp)
}

#' @name add_rcrd_log
#' @title Log files added to the SQL database in the restez path
#' @description This function is called whenever sequence files have been
#' successfully added to the nucleotide SQL database. Row entries are added to
#' 'add_lot.tsv' in the user's restez path containing the filename, GB release
#' numbers and the time of successful adding.
#' The log is to help users keep track of when sequences have been added.
#' @param fl filename, character
#' @return NULL
#' @family private
add_rcrd_log <- function(fl) {
  fp <- file.path(restez_path_get(), 'add_log.tsv')
  filename_log(fl = fl, fp = fp)
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

# GET TOOLS ----
#' @name slctn_get
#' @title Retrieve GenBank selections made by user
#' @description Returns the selections made by the user.
#' @details If no file found, returns empty character vector.
#' @return character vector
#' @family private
slctn_get <- function() {
  fp <- file.path(restez_path_get(), 'selection_log.tsv')
  if (!file.exists(fp)) {
    return('')
  }
  sort(unique(utils::read.table(file = fp, header = TRUE, sep = '\t',
                                stringsAsFactors = FALSE)[['Selection']]))
}

#' @name gbrelease_get
#' @title Get the GenBank release number in the restez path
#' @description Returns the GenBank release number. Returns empty character
#' if none found.
#' @return character
#' @details If no file found, returns empty character vector.
#' @family private
gbrelease_get <- function() {
  fp <- file.path(restez_path_get(), 'gb_release.txt')
  if (file.exists(fp)) {
    res <- utils::read.table(file = fp, header = FALSE)[[1]]
  } else {
    res <- '0'
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
  con <- file(fp, 'rb')
  on.exit(close(con))
  # count lines
  #https://stackoverflow.com/questions/23456170
  nlines <- 0L
  while (length(chunk <- readBin(con = con, what = "raw", n = 65536)) > 0) {
    nlines <- nlines + sum(chunk == as.raw(10L))
  }
  # close and open again
  close(con)
  con <- file(fp, 'rb')
  last_entry <- scan(file = con, what = '', nlines = 1,
                     skip = nlines - 1, sep = '\t', quiet = TRUE)
  last_entry
}

#' @name last_dwnld_get
#' @title Return date and time of the last download
#' @description Return the date and time of the last download as determined
#' using the 'download_log.tsv'.
#' @return character
#' @details If no file found, returns empty character vector.
#' @family private
last_dwnld_get <- function() {
  fp <- file.path(restez_path_get(), 'download_log.tsv')
  if (!file.exists(fp)) {
    return('')
  }
  last_entry_get(fp = fp)[[3]]
}

#' @name last_add_get
#' @title Return date and time of the last added sequence
#' @description Return the date and time of the last added sequence as
#' determined using the 'add_log.tsv'.
#' @return character
#' @details If no file found, returns empty character vector.
#' @family private
last_add_get <- function() {
  fp <- file.path(restez_path_get(), 'add_log.tsv')
  if (!file.exists(fp)) {
    return('')
  }
  last_entry_get(fp = fp)[[3]]
}

#' @name db_sqlngths_get
#' @title Return the minimum and maximum sequence lengths in db
#' @description Returns the maximum and minimum sequence lengths as set by the
#' user upon db creation.
#' @return vector of integers
#' @details If no file found, returns empty character vector.
#' @family private
db_sqlngths_get <- function() {
  fp <- file.path(restez_path_get(), 'seqlengths.tsv')
  if (!file.exists(fp)) {
    return(c('min' = '0', 'max' = 'Inf'))
  }
  res <- utils::read.table(file = fp, header = TRUE, sep = '\t',
                           stringsAsFactors = FALSE)[1, ]
  res
}

# SPECIAL ----
#' @name dir_size
#' @title Calculate the size of a directory
#' @description Returns the size of directory in GB
#' @param fp File path, character
#' @return numeric
#' @family private
dir_size <- function(fp) {
  fls <- list.files(fp, all.files = TRUE, recursive = TRUE)
  fls <- file.path(fp, fls)
  totsz <- sum(vapply(X = fls, FUN = file.size, FUN.VALUE = double(1)),
                 na.rm = TRUE)
  round(x = totsz / 1E9, digits = 2)
}

#' @name gbrelease_check
#' @title Check if the last GenBank release number is the latest
#' @description Returns TRUE if the GenBank release number is the most recent
#' GenBank release available.
#' @return logical
#' @family private
gbrelease_check <- function() {
  latest_release <- as.integer(latest_genbank_release())
  current_release <- as.integer(gbrelease_get())
  if (latest_release > current_release) {
    cat_line('... ... Your database is out-of-date. Latest release is ',
             stat(latest_release))
    res <- FALSE
  } else {
    cat_line('... ... Your database is up-to-date')
    res <- TRUE
  }
  res
}
