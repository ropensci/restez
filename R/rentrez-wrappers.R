#' @name entrez_fetch
#' @title Entrez fetch
#' @description Wrapper for rentrez::entrez_fetch.
#' @details Attempts to first search local database with user-sepcified
#' parameters, if the record is missing in the database, the function then
#' calls rentrez::entrez_fetch to search GenBank remotely.
#' @param db character, name of the database
#' @param id vector, unique ID(s) for record(s)
#' @param rettype character, data format
#' @param retmode character, data mode
#' @param ... Arguments to be passed on to rentrez
#' @seealso \code{\link[rentrez]{entrez_fetch}}
#' @return character string containing the file created
#' @export
entrez_fetch <- function(db, id=NULL, rettype, retmode="", ...) {

}

#rettype='gbwithparts',
#retmode='xml'
