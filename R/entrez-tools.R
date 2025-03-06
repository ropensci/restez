#' @name message_missing
#' @title Produce message of missing IDs
#' @description Sends message to console stating number of missing IDs.
#' @param n Number of missing IDs
#' @return NULL
#' @family private
message_missing <- function(n) {
  msg <- paste0('[', n, '] id(s) are unavailable locally, searching online.')
  message(msg)
}

#' Wrapper for rentrez::entrez_fetch(), used for mocking during tests
#' @noRd
entrez_fetch_wrap <- function(...) {
  rentrez::entrez_fetch(...)
}

#' @name entrez_fasta_get
#' @title Get Entrez fasta
#' @description Return fasta format as expected from
#' an Entrez call. If not all IDs are returned, will
#' run rentrez::entrez_fetch.
#' @param id vector, unique ID(s) for record(s)
#' @param ... arguments passed on to rentrez
#' @return character string containing the file created
#' @family private
entrez_fasta_get <- function(id, ...) {
  id <- sub(pattern = '\\.[0-9]+', replacement = '', x = id)
  fastas <- gb_fasta_get(id = id)
  if (length(fastas) > 0) {
    res <- paste(fastas, collapse = '')
    mssng <- id[!id %in% names(fastas)]
  } else {
    mssng <- id
    res <- ''
  }
  if (length(mssng) > 0) {
    message_missing(length(mssng))
    rentrez_fastas <- entrez_fetch_wrap(id = mssng, ...)
    res <- paste0(res, rentrez_fastas)
  }
  res
}

#' @name entrez_gb_get
#' @title Get Entrez GenBank record
#' @description Return gb and gbwithparts format as expected from
#' an Entrez call. If not all IDs are returned, will
#' run rentrez::entrez_fetch.
#' @param id vector, unique ID(s) for record(s)
#' @param ... arguments passed on to rentrez
#' @return character string containing the file created
#' @family private
entrez_gb_get <- function(id, ...) {
  id <- sub(pattern = '\\.[0-9]+', replacement = '', x = id)
  recs <- gb_record_get(id = id)
  if (length(recs) > 0) {
    res <- paste(recs, collapse = '\n\n')
    res <- paste0(res, '\n\n')
    mssng <- id[!id %in% names(recs)]
  } else {
    mssng <- id
    res <- ''
  }
  if (length(mssng) > 0) {
    message_missing(length(mssng))
    rentrez_recs <- entrez_fetch_wrap(id = mssng, ...)
    res <- paste0(res, rentrez_recs)
  }
  res
}
