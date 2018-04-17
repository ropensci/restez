#' @name get_sequence
#' @title Get sequence
#' @description Return the sequence(s) for a record(s)
#' from the accession ID(s).
#' @param id sequence accession ID(s)
#' @return list of sequences
#' @export
get_sequence <- function(id) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT raw_sequence FROM nucleotide WHERE accession in ",
                qry_id)
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  res <- DBI::dbFetch(res = qry)
  DBI::dbClearResult(res = qry)
  DBI::dbDisconnect(conn = connection)
  lapply(res[['raw_sequence']], rawToChar)
}

#' @name list_db_ids
#' @title List database IDs
#' @description Return a vector of all IDs in
#' a database.
#' @param db character, database name
#' @return vector of characters
#' @export
list_db_ids <- function(db) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  if (db == 'nucleotide') {
    res <- DBI::dbGetQuery(conn = connection,
                           statement =
                             "SELECT accession from nucleotide")
  }
  DBI::dbDisconnect(conn = connection)
  res[[1]]
}
