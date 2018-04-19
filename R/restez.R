#' restez: Create and Query a Local Copy of GenBank in R
#'
#' The restez package comes with three sets of functions:
#' setup, get and entrez.
#'
#' @section setup functions:
#' These functions allow a user to set the filepath for
#' where the GenBank files should be stored, to download
#' specific parts of GenBank and to create a local SQLite
#' database.
#'
#' @section get functions:
#' The get functions allow a user to query the local SQLite
#' database. A user can use an NCBI accession ID to retrieve
#' sequences or whole GenBank records.
#'
#' @section entrez functions:
#' The entrez functions are wrappers to the \code{entrez_*}
#' functions in the rentrez package. e.g the restez's entrez_fetch
#' will first try to search the local database, if it fails it will
#' then call rentrez's \code{\link[rentrez]{entrez_fetch}} with the
#' same arguments.
#'
#' @docType package
#' @name restez
NULL
