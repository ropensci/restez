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
  on.exit(restez_disconnect())
  # first close any connection if one exists
  restez_disconnect()
  restez_connect(read_only = TRUE)
  connection <- connection_get()
  if (db == 'nucleotide') {
    sttmnt <- "SELECT accession FROM nucleotide"
    if (!is.null(n)) {
      sttmnt <- paste(sttmnt, 'LIMIT', as.integer(n))
    }
    res <- DBI::dbGetQuery(conn = connection, statement = sttmnt)
  }
  if (!is.null(n)) {
    msg <- paste0('Number of ids returned was limited to [', n, '].\n',
                  'Set `n=NULL` to return all ids.')
    warning(msg)
  }
  restez_disconnect()
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
  on.exit(restez_disconnect())
  if (!restez_ready()) {
    warning('No database detected. Did you run `db_create()`?')
    return(0L)
  }
  # first close any connection if one exists
  restez_disconnect()
  restez_connect(read_only = TRUE)
  connection <- connection_get()
  res <- DBI::dbGetQuery(connection, "SELECT count(*) FROM nucleotide")
  restez_disconnect()
  as.integer(res[[1]])
}
