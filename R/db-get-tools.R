#' @name list_db_ids
#' @title List database IDs
#' @family database
#' @description Return a vector of all IDs in
#' a database.
#' @details Warning: can return very large vectors
#' for large databases.
#' @param db character, database name
#' @param n Maximum number of IDs to return, if NULL returns all
#' @return vector of characters
#' @export
#' @example examples/list_db_ids.R
list_db_ids <- function(db = 'nucleotide', n=100) {
  connection <- connection_get()
  if (db == 'nucleotide') {
    sttmnt <- "SELECT accession from nucleotide"
    if (!is.null(n)) {
      sttmnt <- paste0(sttmnt, '\nLIMIT ', as.integer(n))
    }
    res <- DBI::dbGetQuery(conn = connection, statement = sttmnt)
  }
  if (!is.null(n)) {
    msg <- paste0('Number of ids returned was limited to [', n, '].\n',
                  'Set `n=NULL` to return all ids.')
    warning(msg)
  }
  res[[1]]
}

#' @name is_in_db
#' @title Is in db
#' @family database
#' @description Determine whether an id(s)
#' is/are present in a database.
#' @param id character, sequence accession ID(s)
#' @param db character, database name
#' @return named vector of booleans
#' @export
#' @example examples/is_in_db.R
is_in_db <- function(id, db = 'nucleotide') {
  accssns <- sub(pattern = '\\.[0-9]+', replacement = '',
                 x = id)
  db_res <- gb_sql_query(nm = 'version', id = id)
  res <- accssns %in% db_res[['accession']]
  names(res) <- id
  res
}

#' @name count_db_ids
#' @title Return the number of ids
#' @description Return the number of ids in a user's restez database.
#' @details Requires an open connection. If no connection or db 0 is returned.
#' @param db character, database name
#' @return integer
#' @family database
#' @export
#' @example examples/count_db_ids.R
count_db_ids <- function(db = 'nucleotide') {
  if (!restez_ready()) {
    warning('No database connection. Did you run `restez_connect`?')
    return(0L)
  }
  connection <- connection_get()
  qry <- "SELECT count(*) FROM nucleotide"
  qry_res <- DBI::dbSendQuery(conn = connection, statement = qry)
  on.exit(expr = {
    DBI::dbClearResult(res = qry_res)
  })
  res <- DBI::dbFetch(res = qry_res)
  as.integer(res[[1]])
}
