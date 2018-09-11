#' @name identify_latest_genbank_release_notes
#' @title Identify the latest GenBank Release Notes
#' @description Searches through all release notes to find the latest. Returns
#' "gb[release number].release.notes".
#' @return character
#' @family private
identify_latest_genbank_release_notes <- function() {
  url <- 'ftp://ftp.ncbi.nlm.nih.gov/genbank/gbrel.txt'
  flpth <- file.path(dwnld_path_get(), 'latest_release_notes.txt')
  custom_download2(url = url, destfile = flpth)
  
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
    if (grepl(pattern = '^[0-9\\.]', x = line)) {
      descript <- TRUE
    } else {
      descript <- FALSE
    }
    if (grepl(pattern = '^\\s+[0-9]+\\s+gb', x = line)) {
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
    if (kill_switch & !filesize) {
      break
    }
  }
  # break up
  pull <- grepl(pattern = '\\.seq', x = descript_lines)
  seq_files_descripts <- sub('^[0-9]+\\.\\s', '', descript_lines[pull])
  seq_files_descripts <- strsplit(x = seq_files_descripts, split = ' - ')
  seq_files <- unlist(lapply(seq_files_descripts, '[[', 1))
  descripts <- unlist(lapply(seq_files_descripts, '[[', 2))
  descripts <- sub(pattern = ' sequence entries,', replacement = '',
                   x = descripts)
  descripts <- sub(pattern = ' part [0-9]+\\.', replacement = '',
                   x = descripts)
  filesize_info <- strsplit(x = filesize_lines, split = '\\s')
  filesize_info <- lapply(X = filesize_info, function(x) x[x != ''])
  filesizes <- as.integer(vapply(X = filesize_info, FUN = '[[', i = 1,
                                 FUN.VALUE = character(1)))
  names(filesizes) <- vapply(X = filesize_info, FUN = '[[', i = 2,
                             FUN.VALUE = character(1))
  data.frame(seq_files = seq_files, descripts = descripts,
             filesizes = filesizes[seq_files])
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
  base_url <- 'ftp://ftp.ncbi.nlm.nih.gov/genbank/'
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
  success <- tryCatch({
    # can switch to custom_download() to avoid subprocess
    custom_download2(url = gzurl, destfile = gzdest)
    TRUE
  }, error = function(e) {
    cat_line('... ... ', char(gzurl), ' cannot be reached.')
    remove(gzdest)
  }, interrupt = function(e) {
    remove(gzdest)
    stop('User halted', call. = FALSE)
  })
  if (success) {
    dwnld_rcrd_log(fl)
  }
  success
}
