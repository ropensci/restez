#' @name restez_ready
#' @title Is restez ready?
#' @family setup
#' @description Returns TRUE if a restez SQL database is available, connected
#' and has data. Use restez_status() for more information.
#' @return Logical
#' @export
#' @example examples/restez_ready.R
restez_ready <- function() {
  fp <- sql_path_get()
  inherits(fp, 'character') && length(fp) == 1 && dir.exists(fp) &&
    connected() && has_data()
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
  if (inherits(x = connection, what = 'MonetDBEmbeddedConnection')) {
    res <- connection@connenv$open
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
#' @family setup
#' @description Sets a connection to the local database. If database
#' connection cannot be made, an error is returned.
#' @return NULL
#' @example examples/restez_connect.R
#' @export
restez_connect <- function() {
  restez_path_check()
  if (!DBI::dbCanConnect(drv = MonetDBLite::MonetDBLite(),
                         dbname = sql_path_get())) {
    stop('Unable to connect to restez db. Did you run `restez_path_set`?')
  }
  message('Remember to run `restez_disconnect()`')
  connection <- DBI::dbConnect(drv = MonetDBLite::MonetDBLite(),
                               dbname = sql_path_get())
  options('restez_connection' = connection)
  invisible(NULL)
}

#' @name quiet_connect
#' @title Quiely connect to the restez database
#' @family private
#' @description Quiet version of restez_connect for automatic connections.
#' @return NULL
quiet_connect <- function() {
  restez_disconnect()
  suppressMessages(restez_connect())
}

#' @name restez_disconnect
#' @title Disconnect from restez database
#' @family setup
#' @description Safely disconnect from the restez connection
#' @return NULL
#' @example examples/restez_disconnect.R
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
