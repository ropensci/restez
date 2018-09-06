#' @name identify_latest_genbank_release_notes
#' @title Identify the latest GenBank Release Notes
#' @description Searches through all release notes to find the latest. Returns
#' "gb[release number].release.notes".
#' @return character
#' @family private
identify_latest_genbank_release_notes <- function() {
  url <- 'ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/'
  all_release_notes <- RCurl::getURL(url = url, dirlistonly = TRUE)
  all_release_notes <- strsplit(x = all_release_notes, split = '\n')[[1]]
  all_release_numbers <- gsub(pattern = "[^0-9]+", replacement = "",
                              x = all_release_notes)
  all_release_numbers <- as.numeric(all_release_numbers)
  #max_release <- max(all_release_numbers, na.rm = TRUE)
  #cat_line('... found release ', stat(max_release))
  all_release_notes[which.max(all_release_numbers)]
}

#' @name identify_downloadable_files
#' @title Identify downloadable files
#' @description Searches through the release notes
#' for a GenBank release to find all listed .seq files.
#' Returns a data.frame for all .seq files and their
#' description.
#' @param release_notes character, GenBank release notes
#' @return data.frame
#' @family private
identify_downloadable_files <- function(release_notes) {
  lines <- strsplit(x = release_notes, split = '\n')[[1]]
  descript_section <- FALSE
  descript <- FALSE
  kill_switch <- FALSE
  descript_lines <- NULL
  for (line in lines) {
    if (grepl(pattern = '^[0-9\\.]+\\sFile Descriptions',
              x = line)) {
      descript_section <- TRUE
      next
    }
    if (grepl(pattern = '^[0-9\\.]', x = line)) {
      descript <- TRUE
    } else {
      descript <- FALSE
    }
    if (descript_section & descript) {
      descript_lines <- c(descript_lines, line)
      kill_switch <- TRUE
    }
    if (kill_switch & !descript) {
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
  data.frame(seq_files, descripts)
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
