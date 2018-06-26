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
    res <- paste(fastas, collapse = '\n\n')
    res <- paste0(res, '\n\n')
    mssng <- id[!id %in% names(fastas)]
  } else {
    mssng <- id
    res <- ''
  }
  if (length(mssng) > 0) {
    rentrez_fastas <- rentrez::entrez_fetch(id = mssng, ...)
    res <- paste0(res, rentrez_fastas)
  }
  paste0(res, '\n\n')
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
    rentrez_recs <- rentrez::entrez_fetch(id = mssng, ...)
    res <- paste0(res, rentrez_recs)
  }
  res
}
