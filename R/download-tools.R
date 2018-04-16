#' @name identify_latest_genbank_release_notes
#' @title Identify the latest GenBank Release Notes
#' @description Searches through all release notes
#' to find the latest. Returns the entire release notes.
#' @return character
identify_latest_genbank_release_notes <- function() {
  url <- 'ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/'
  all_release_notes <- RCurl::getURL(url = url, dirlistonly = TRUE)
  all_release_notes <- strsplit(x = all_release_notes, split = '\n')[[1]]
  all_release_numbers <- gsub(pattern = "[^0-9]+", replacement = "",
                              x = all_release_notes)
  all_release_numbers <- as.numeric(all_release_numbers)
  max_release <- max(all_release_numbers, na.rm = TRUE)
  cat('... found release [', max_release, ']\n', sep = '')
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

#' @name download_genbank
#' @title Download GenBank
#' @description Download .seq files from the latest GenBank
#' release. The user interacitvely selects the parts of
#' GenBank to download (e.g. primates, plants, bacteria ...)
#' @details
#' The downloaded files will appear in the restez filepath under
#' downloads.
#' The downloaded files will be .tar compressed and will need
#' extraction for inspection. (setup() does this itself.)
#' Warning: this function will overwrite pre-exisitng files.
#' @return NULL
#' @export
download_genbank <- function() {
  # ping google to test for internet
  connected.to.internet()
  cat('Looking up latest GenBank release ...\n')
  release <- identify_latest_genbank_release_notes()
  release_url <- paste0('ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/',
                        release)
  release_notes <- RCurl::getURL(url = release_url)
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
  response <- readline(prompt = '(Press Esc to quit)')
  selected_types <- as.numeric(strsplit(x = response,
                                        split = '\\s')[[1]])
  cat('Downloading [', sum(types[selected_types]),
      '] files for:\n',paste0(names(types)[selected_types],
                              collapse = ', '), ' ...\n', sep = '')
  pull <- downloadable_table[['descripts']] %in% names(types)[selected_types]
  files_to_download <- as.character(downloadable_table[['seq_files']][pull])
  for (i in seq_along(files_to_download)) {
    fl <- files_to_download[[i]]
    cat('... ', fl, ' (', i, '/', length(files_to_download),
        ')\n', sep = '')
    fl <- paste0(fl, '.gz')
    # TODO: update restez filepath to a folder
    flpth <- file.path('restez_test_downloads', fl)
    url <- paste0('ftp://ftp.ncbi.nlm.nih.gov/genbank/', fl)
    # custom_download chooses the best download protocol given
    # the OS
    custom_download(url = url, destfile = flpth,
                    mode = "wb")
  }
}
