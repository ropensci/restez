#' @name restez_ready
#' @title Is restez ready?
#' @family setup
#' @description Returns TRUE if a restez SQL database is available.
#' Use restez_status() for more information.
#' @return Logical
#' @export
#' @example examples/restez_ready.R
restez_ready <- function() {
  fp <- sql_path_get()
  inherits(fp, 'character') && length(fp) == 1 && file.exists(fp)
}

#' @name connected
#' @title Is restez connected?
#' @family private
#' @description Returns TRUE if a restez SQL database has been connected.
#' @return Logical
connected <- function() {
  res <- FALSE
  connection <- getOption('restez_connection')
  if (is.null(connection)) return(FALSE)
  if (inherits(x = connection, what = 'duckdb_connection')) {
    res <- TRUE
  }
  res
}

#' @name has_data
#' @title Does the connected database have data?
#' @family private
#' @description Returns TRUE if a restez SQL database has data.
#' @return Logical
has_data <- function() {
  tryCatch(expr = {
    suppressWarnings(list_db_ids(n = 1))
    TRUE
    }, error = function(e) FALSE)
}

#' @name restez_connect
#' @title Connect to the restez database
#' @family private
#' @description Sets a connection to the local database.
#' @param read_only Logical; should the connection be made in read-only
#' mode? Read-only mode is required for multiple R processes to access
#' the database simultaneously. Default FALSE.
#' @return NULL
#' @export
restez_connect <- function(read_only = FALSE) {
  restez_path_check()
  connection <- DBI::dbConnect(
    drv = duckdb::duckdb(),
    dbdir = sql_path_get(),
    read_only = read_only)
  options('restez_connection' = connection)
  invisible(NULL)
}

#' @name restez_disconnect
#' @title Disconnect from restez database
#' @family private
#' @description Safely disconnect from the restez connection
#' @return NULL
#' @export
restez_disconnect <- function() {
  if (connected()) {
    connection <- getOption('restez_connection')
    DBI::dbDisconnect(conn = connection, shutdown = TRUE)
  }
  options('restez_connection' = NULL)
  invisible(NULL)
}

#' @name connection_get
#' @title Retrieve restez connection
#' @family private
#' @description Safely acquire the restez connection. Raises error if no
#' connection set.
#' @return connection
connection_get <- function() {
  if (!connected()) {
    stop('No restez connection. Did you run `restez_connect`?', call. = FALSE)
  }
  getOption('restez_connection')
}
