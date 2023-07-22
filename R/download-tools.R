#' @name predict_datasizes
#' @title Print file size predictions to screen
#' @description Predicts the file sizes of the downloads and the database
#' from the GenBank filesize information. Conversion factors are based on
#' previous restez downloads.
#' @param uncompressed_filesize GBs of the stated filesize, numeric
#' @return NULL
#' @family private
predict_datasizes <- function(uncompressed_filesize) {
  cnvfctr1 <- 0.2 # more likely to overestimate
  cnvfctr2 <- 6.1
  compressed_filesize <- uncompressed_filesize * cnvfctr1
  database_size <- compressed_filesize * cnvfctr2
  total_size <- compressed_filesize + database_size
  cat_line("\nBased on stated GenBank files sizes, we estimate ... ")
  cat_line('... ', stat(signif(x = compressed_filesize, digits = 3), 'GB'),
           ' for  compressed, downloaded files')
  cat_line('... ', stat(signif(x = database_size, digits = 3), 'GB'),
           ' for the SQL database')
  cat_line('Leading to a total of ',
           stat(signif(x = total_size, digits = 3), 'GB'))
  caveat <- paste0('\nPlease note, the real sizes of the database and its ',
                   'downloads cannot be\naccurately predicted beforehand.\n',
                   'These are just estimates, actual sizes may differ by up ',
                   'to a factor of two.\n')
  cat_line(crayon::italic(caveat))
}

#' @name latest_genbank_release_notes
#' @title Download the latest GenBank Release Notes
#' @description Downloads the latest GenBank release notes to a user's restez
#' download path.
#' @return NULL
#' @family private
latest_genbank_release_notes <- function() {
  url <- 'https://ftp.ncbi.nlm.nih.gov/genbank/gbrel.txt'
  flpth <- file.path(dwnld_path_get(), 'latest_release_notes.txt')
  curl::curl_download(url = url, destfile = flpth)
}

#' @name latest_genbank_release
#' @title Retrieve latest GenBank release number
#' @description Downloads the latest GenBank release number and returns it.
#' @return character
#' @family private
latest_genbank_release <- function() {
  url <- 'https://ftp.ncbi.nlm.nih.gov/genbank/GB_Release_Number'
  flpth <- file.path(tempdir(), 'gb_release_number.txt')
  curl::curl_download(url = url, destfile = flpth)
  release <- readChar(con = flpth, nchars = 10)
  file.remove(flpth)
  gsub(pattern = '[^0-9]', replacement = '', x = release)
}

#' @name identify_downloadable_files
#' @title Identify downloadable files
#' @description Searches through the release notes
#' for a GenBank release to find all listed .seq files.
#' Returns a data.frame for all .seq files and their
#' description.
#' @return data.frame
#' @family private
identify_downloadable_files <- function() {
  # TODO: identify file sizes
  flpth <- file.path(dwnld_path_get(), 'latest_release_notes.txt')
  lines <- readLines(con = flpth)
  filesize_section <- filesize <- kill_switch <- descript <-
    descript_section <- FALSE
  filesize_lines <- descript_lines <- NULL
  for (line in lines) {
    if (grepl(pattern = '^[0-9\\.]+\\sFile Descriptions', x = line)) {
      descript_section <- TRUE
      next
    }
    if (grepl(pattern = '^File Size\\s+File Name', x = line)) {
      filesize_section <- TRUE
      next
    }
    if (grepl(pattern = '^[0-9]+\\.\\s', x = line)) {
      descript <- TRUE
    } else {
      descript <- FALSE
    }
    if (grepl(pattern = '^(\\s+)?[0-9]+\\s+gb[a-z]{1,4}[0-9]{1,4}\\.seq{0,1}$',
              x = line)) {
      filesize <- TRUE
    } else {
      filesize <- FALSE
    }
    if (descript_section & descript) {
      descript_lines <- c(descript_lines, line)
    }
    if (filesize_section & filesize) {
      filesize_lines <- c(filesize_lines, line)
      kill_switch <- TRUE
    }
    if (kill_switch & line == '') {
      break
    }
  }
  # break up
  pull <- grepl(pattern = '\\.seq', x = descript_lines)
  seq_files_descripts <- sub('^[0-9]+\\.\\s', '', descript_lines[pull])
  seq_files_descripts <- strsplit(x = seq_files_descripts, split = ' - ')
  seq_files <- unlist(lapply(seq_files_descripts, '[', 1))
  descripts <- unlist(lapply(seq_files_descripts, '[', 2))
  descripts <- sub(pattern = ' sequence entries', replacement = '',
                   x = descripts)
  descripts <- sub(pattern = ', part [0-9]+\\.', replacement = '',
                   x = descripts)
  filesize_info <- strsplit(x = filesize_lines, split = '\\s')
  filesize_info <- lapply(X = filesize_info, function(x) x[x != ''])
  filesizes <- as.numeric(unlist(lapply(filesize_info, '[', 1)))
  names(filesizes) <- unlist(lapply(filesize_info, '[', 2))
  # repair truncated names (name of flatfile in some cases got truncated
  # e.g. from "gbpln1000.seq" to "gbpln1000.se")
  truncated_names <- names(filesizes)[grepl("\\.se$", names(filesizes))]
  if (length(truncated_names) > 0) {
    names(filesizes)[grepl("\\.se$", names(filesizes))] <-
      paste0(truncated_names, "q")
  }
  res <- data.frame(seq_files = seq_files, descripts = descripts,
             filesizes = filesizes[seq_files])
  if (any(is.na(res))) {
    warning('Not all file information could be ascertained.')
  }
  res
}

#' @name file_download
#' @title Download a file
#' @description Download a GenBank .seq.tar file. Check
#' the file has downloaded properly. If not, returns FALSE.
#' If overwrite is true, any previous file will be overwritten.
#' @param fl character, base filename (e.g. gbpri9.seq) to be
#' downloaded
#' @param overwrite T/F
#' @return T/F
#' @family private
# based upon: biomartr::download.database
file_download <- function(fl, overwrite=FALSE) {
  remove <- function(fl) {
    cat_line('... ... deleting ', char(fl))
    if (file.exists(fl)) {
      file.remove(fl)
    }
    FALSE
  }
  base_url <- 'https://ftp.ncbi.nlm.nih.gov/genbank/'
  gzfl <- paste0(fl, '.gz')
  gzurl <- paste0(base_url, gzfl)
  gzdest <- file.path(dwnld_path_get(), gzfl)
  if (overwrite) {
    remove(gzdest)
  }
  if (file.exists(gzdest)) {
    cat_line('... ... already downloaded')
    return(TRUE)
  }
  curl::curl_download(url = gzurl, destfile = gzdest, quiet = FALSE)
  dwnld_rcrd_log(fl)
  TRUE
}
