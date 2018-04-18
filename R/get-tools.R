#' @name query_sql
#' @title Query SQL
#' @description Generic query function for retrieving
#' data from the SQL database for the get functions.
#' @param nm character, column name
#' @param id character, sequence accession ID(s)
#' @return data.frame
#' @noRd
query_sql <- function(nm, id) {
  qry_id <- paste0('(', paste0(paste0("'", id, "'"), collapse = ','), ')')
  qry <- paste0("SELECT ", nm, " FROM nucleotide WHERE accession in ",
                qry_id)
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = get_sql_path())
  on.exit(DBI::dbDisconnect(conn = connection))
  qry <- DBI::dbSendQuery(conn = connection, statement = qry)
  on.exit(expr = {
    DBI::dbClearResult(res = qry)
    DBI::dbDisconnect(conn = connection)
    })
  res <- DBI::dbFetch(res = qry)
  res
}

#' @name get_sequence
#' @title Get sequence
#' @description Return the sequence(s) for a record(s)
#' from the accession ID(s).
#' @param id character, sequence accession ID(s)
#' @return list of sequences
#' @export
get_sequence <- function(id) {
  res <- query_sql(nm = 'raw_sequence', id = id)
  lapply(res[['raw_sequence']], rawToChar)
}

#' @name get_record
#' @title Get record
#' @description Return the entire GenBank record
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return list of records
#' @export
get_record <- function(id) {
  res <- query_sql(nm = 'raw_record', id = id)
  lapply(res[['raw_record']], rawToChar)
}

#' @name get_definition
#' @title Get definition
#' @description Return the definition line
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return list of definitions
#' @export
get_definition <- function(id) {
  res <- query_sql(nm = 'raw_definition', id = id)
  lapply(res[['raw_definition']], rawToChar)
}

#' @name get_organism
#' @title Get organism
#' @description Return the organism name
#' for an accession ID.
#' @param id character, sequence accession ID(s)
#' @return list of definitions
#' @export
get_organism <- function(id) {
  res <- query_sql(nm = 'organism', id = id)
  as.list(res[['organism']])
}

#' @name list_db_ids
#' @title List database IDs
#' @description Return a vector of all IDs in
#' a database.
#' @details Warning: can return very large vectors
#' for large databases.
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
  on.exit(DBI::dbDisconnect(conn = connection))
  res[[1]]
}
