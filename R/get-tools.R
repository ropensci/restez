#' @name get_sequence
#' @title Get sequence
#' @description Return the sequence for a record
#' from the accession ID.
#' @param id sequence accession ID
#' @return character
#' @export
get_sequence <- function(id) {
  filepath <- getOption('restez_database_filepath')
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = filepath)
  qry <- paste0("SELECT * FROM nucleotide WHERE accession = '",
                id, "'")
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  res <- DBI::dbFetch(res = qry)
  DBI::dbClearResult(res = qry)
  DBI::dbDisconnect(conn = connection)
  rawToChar(res[['raw_sequence']][[1]])
}

get_records <- function(id, db, filepath) {

}
