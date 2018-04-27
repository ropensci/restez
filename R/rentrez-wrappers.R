#' @name entrez_fetch
#' @title Entrez fetch
#' @family entrez
#' @description Wrapper for rentrez::entrez_fetch.
#' @details Attempts to first search local database with user-specified
#' parameters, if the record is missing in the database, the function then
#' calls rentrez::entrez_fetch to search GenBank remotely.
#'
#' @section Supported return types and modes:
#' XML retmode is not supported. Rettypes 'seqid', 'ft', 'acc' and 'uilist'
#' are also not supported.
#' @note rentrez::entrez_fetch is always called silently.
#' @param db character, name of the database
#' @param id vector, unique ID(s) for record(s)
#' @param rettype character, data format
#' @param retmode character, data mode
#' @param ... Arguments to be passed on to rentrez
#' @seealso \code{\link[rentrez]{entrez_fetch}}
#' @return character string containing the file created
#' @example examples/entrez_fetch.R
#' @export
entrez_fetch <- function(db, id=NULL, rettype, retmode="", ...) {
  # https://www.ncbi.nlm.nih.gov/books/NBK25499/table/chapter4.T._valid_values_of__retmode_and/
  if (db %in% c('nucleotide', 'nuccore')) {
    if (rettype == 'fasta' & retmode != 'xml') {
      return(entrez_fasta_get(db = db, id = id, rettype = rettype,
                              retmode = retmode, ...))
    }
    if (rettype == 'gb' & retmode != 'xml') {
      return(entrez_gb_get(db = db, id = id, rettype = rettype,
                           retmode = retmode, ...))
    }
    if (rettype == 'gbwithparts' & retmode != 'xml') {
      # TODO: I have detected no difference between gb and gbwithparts
      return(entrez_gb_get(db = db, id = id, rettype = rettype,
                           retmode = retmode, ...))
    }
    # TODO
    # if (rettype == 'ft' & rettype != 'xml') {
    #   return(entrez_ft_get(id = id))
    # }
  }
  rentrez::entrez_fetch(db = db, id = id, rettype = rettype,
                        retmode = retmode, ...)
}
