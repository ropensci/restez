#' @name get_sequence_from_id
#' @title Get sequence from ID
#' @description Return the sequence for a record
#' from the accession ID.
#' @param id sequence accession ID
#' @param filepath Database filepath
#' @return character
#' @export
get_sequence_from_id <- function(id, filepath) {
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
