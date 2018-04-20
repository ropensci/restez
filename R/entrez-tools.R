#' @name get_entrez_fasta
#' @title Get Entrez fasta
#' @description Return fasta format as expected from
#' an Entrez call. If not all IDs are returned, will
#' run rentrez::entrez_fetch.
#' @param id vector, unique ID(s) for record(s)
#' @param ... arguments passed on to rentrez
#' @return character string containing the file created
#' @noRd
get_entrez_fasta <- function(id, ...) {
  fastas <- get_fasta(id = id)
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

#' @name get_entrez_fasta
#' @title Get Entrez fasta
#' @description Return gb and gbwithparts format as expected from
#' an Entrez call. If not all IDs are returned, will
#' run rentrez::entrez_fetch.
#' @param id vector, unique ID(s) for record(s)
#' @param ... arguments passed on to rentrez
#' @return character string containing the file created
#' @noRd
get_entrez_gb <- function(id, ...) {
  recs <- get_record(id = id)
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
