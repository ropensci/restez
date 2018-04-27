#' @name list_db_ids
#' @title List database IDs
#' @family get
#' @description Return a vector of all IDs in
#' a database.
#' @details Warning: can return very large vectors
#' for large databases.
#' @param db character, database name
#' @return vector of characters
#' @export
#' @example examples/list_db_ids.R
list_db_ids <- function(db = 'nucleotide') {
  connection <- DBI::dbConnect(drv = RSQLite::SQLite(),
                               dbname = sql_path_get())
  if (db == 'nucleotide') {
    res <- DBI::dbGetQuery(conn = connection,
                           statement =
                             "SELECT accession from nucleotide")
  }
  on.exit(DBI::dbDisconnect(conn = connection))
  res[[1]]
}

#' @name is_in_db
#' @title Is in db
#' @family get
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
