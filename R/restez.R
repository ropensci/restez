#' restez: Create and Query a Local Copy of GenBank in R
#'
#' The restez package comes with five families of functions:
#' setup, database, get, entrez and internal/private.
#'
#' @section Setup functions:
#' These functions allow a user to set the filepath for where the GenBank files
#' should be stored, create connections and verify these settings.
#'
#' @section Database functions:
#' These functions download specific parts of GenBank and create the local
#' SQL-like database.
#'
#' @section GenBank functions:
#' These functions allow a user to query the local SQL-like database. A
#' user can use an NCBI accession ID to retrieve sequences or whole GenBank
#' records.
#'
#' @section Entrez functions:
#' The entrez functions are wrappers to the `entrez_*` functions in the
#' rentrez package. e.g the restez's entrez_fetch will first try to search the
#' local database, if it fails it will then call rentrez's
#' [rentrez::entrez_fetch()] with the same arguments.
#' 
#' @section Private/internal functions:
#' These functions work behind the scenes to make everything work. If you're
#' curious you can read their documentation using the form
#' `?restez:::functionname`.
#'
#' @name restez
#' @keywords internal
"_PACKAGE"
