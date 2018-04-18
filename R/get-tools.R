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

#' @name get_record
#' @title Get record
#' @description Return the entire GenBank record
#' for an accession ID.
#' @param id sequence accession ID(s)
#' @return list of records
#' @export
get_record <- function(id) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT raw_record FROM nucleotide WHERE accession in ",
                qry_id)
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  res <- DBI::dbFetch(res = qry)
  DBI::dbClearResult(res = qry)
  DBI::dbDisconnect(conn = connection)
  lapply(res[['raw_record']], rawToChar)
}

#' @name get_definition
#' @title Get definition
#' @description Return the definition line
#' for an accession ID.
#' @param id sequence accession ID(s)
#' @return list of definitions
#' @export
get_definition <- function(id) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT raw_definition FROM nucleotide WHERE accession in ",
                qry_id)
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  res <- DBI::dbFetch(res = qry)
  DBI::dbClearResult(res = qry)
  DBI::dbDisconnect(conn = connection)
  lapply(res[['raw_definition']], rawToChar)
}

#' @name get_organism
#' @title Get organism
#' @description Return the organism name
#' for an accession ID.
#' @param id sequence accession ID(s)
#' @return list of definitions
#' @export
get_organism <- function(id) {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT organism FROM nucleotide WHERE accession in ",
                qry_id)
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  res <- DBI::dbFetch(res = qry)
  DBI::dbClearResult(res = qry)
  DBI::dbDisconnect(conn = connection)
  as.list(res[['organism']])
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
