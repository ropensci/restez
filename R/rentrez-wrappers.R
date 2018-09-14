#' @name entrez_fetch
#' @title Entrez fetch
#' @family entrez
#' @description Wrapper for rentrez::entrez_fetch.
#' @details Attempts to first search local database with user-specified
#' parameters, if the record is missing in the database, the function then
#' calls rentrez::entrez_fetch to search GenBank remotely.
#' 
#' \code{rettype='fasta'} and \code{rettype='gb'} are respectively equivalent to 
#' \code{\link{gb_fasta_get}} and \code{\link{gb_record_get}}.
#' 
#' @note It is advisable to call restez and rentrez functions with '::' notation
#' rather than library() calls to avoid namespace issues. e.g.
#' restez::entrez_fetch().
#'
#' @section Supported return types and modes:
#' XML retmode is not supported. Rettypes 'seqid', 'ft', 'acc' and 'uilist'
#' are also not supported.
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
  # NCBI table https://tinyurl.com/yb5e7q9b
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
  message('Invalid args for restez, searching online ....')
  rentrez::entrez_fetch(db = db, id = id, rettype = rettype,
                        retmode = retmode, ...)
}
