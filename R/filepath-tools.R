#' @name restez_path_unset
#' @title Unset restez path
#' @family setup
#' @description Set the restez path to NULL
#' @return NULL
#' @export
restez_path_unset <- function() {
  options(restez_path = NULL)
}

#' @name restez_path_set
#' @title Set restez path
#' @family setup
#' @description Specify the filepath for the local GenBank database.
#' @details Adds 'restez_path' to options(). In this path
#' the folder 'restez' will be created and all downloaded and
#' database files will be stored there.
#' @param filepath character, valid filepath to the folder where the
#' database should be stored.
#' @return NULL
#' @export
#' @examples
#' \dontrun{
#' library(restez)
#' restez_path_set(filepath = 'path/to/where/you/want/files/to/download')
#' }
restez_path_set <- function(filepath) {
  if (!dir.exists(filepath)) {
    stop('Invalid filepath.', call. = FALSE)
  }
  restez_path <- file.path(filepath, 'restez')
  options(restez_path = file.path(filepath, 'restez'))
  if (!dir.exists(restez_path)) {
    cat_line('... Creating ', char(restez_path))
    dir.create(restez_path)
  }
  dwnld_path <- dwnld_path_get()
  if (!dir.exists(dwnld_path)) {
    cat_line('... Creating ', char(dwnld_path))
    dir.create(dwnld_path)
  }
  fls <- list.files(path = restez_path, pattern = '.txt')
  if (!'README.txt' %in% fls) readme_log()
  if (!'session_info.txt' %in% fls) seshinfo_log()
}

#' @name restez_path_get
#' @title Get restez path
#' @family setup
#' @description Return filepath to where the restez
#' database is stored.
#' @return character
#' @export
#' @example examples/restez_path_get.R
restez_path_get <- function() {
  getOption('restez_path')
}

#' @name sql_path_get
#' @title Get SQL path
#' @description Return path to where SQL database is stored.
#' @return character
#' @family private
sql_path_get <- function() {
  fp <- restez_path_get()
  file.path(fp, 'sql_db')
}

#' @name dwnld_path_get
#' @title Get dwnld path
#' @description Return path to folder where raw .seq files
#' are stored.
#' @return character
#' @family private
dwnld_path_get <- function() {
  fp <- restez_path_get()
  file.path(fp, 'downloads')
}

#' @name restez_path_check
#' @title Check restez filepath
#' @description Raises error if restez path does
#' not exist.
#' @return NULL
#' @family private
restez_path_check <- function() {
  fp <- restez_path_get()
  if (is.null(fp)) {
    stop('Restez path not set. Use restez_path_set().', .call = FALSE)
  }
  if (!dir.exists(fp)) {
    msg <- paste0('Restez path [', fp, '] does not exist.')
    stop(msg, .call = FALSE)
  }
}

#' @name db_delete
#' @title Delete database
#' @family setup
#' @description Delete the local SQL database and/or restez
#' folder.
#' @param everything T/F, delete the whole restez folder as well?
#' @return NULL
#' @export
#' @example examples/db_delete.R
db_delete <- function(everything = TRUE) {
  if (length(sql_path_get()) > 0 && dir.exists(sql_path_get())) {
    unlink(sql_path_get(), recursive = TRUE)
  }
  if (everything) {
    if (length(restez_path_get()) > 0 && dir.exists(restez_path_get())) {
      unlink(restez_path_get(), recursive = TRUE)
      restez_path_unset()
    }
  }
  invisible(NULL)
}

#' @name restez_status
#' @title Check restez status
#' @family setup
#' @description Report to console current setup status of restez. If SQL
#' database available, returns TRUE else FALSE.
#' @param gb_check Check whether last download was from latest GenBank release?
#' Default FALSE.
#' @details If the function returns TRUE, then querying can begin. Always
#' remember to run \code{\link{restez_connect}} before running this function.
#' Set gb_check=TRUE to see if your downloads are up-to-date.
#' @return T/F
#' @export
#' @example examples/restez_status.R
restez_status <- function(gb_check = FALSE) {
  # TODO: return a structured list
  no_downloads <- FALSE
  no_database <- FALSE
  latest <- TRUE
  fp <- restez_path_get()
  cat_line(cli::rule())
  cat_line('Checking setup status at ', char(fp), ' ...')
  cat_line(cli::rule())
  if (is.null(fp)) {
    cat_line('... restez path not set')
    message('You need to use restez_path_set()')
    return(FALSE)
  }
  if (!dir.exists(fp)) {
    cat_line('... restez path ', char(fp), ' does not exist')
    message('restez_path_set() filepath must be a valid filepath')
    return(FALSE)
  }
  fp <- dwnld_path_get()
  if (!dir.exists(fp)) {
    cat_line('... ', char('downloads/'), ' does not exist')
    message('Use restez_path_set() to recreate the folder')
    return(FALSE)
  }
  dwn_fls <- list.files(path = fp)
  if (length(dwn_fls) == 0) {
    cat_line('... no files in ', char('downloads/'))
    no_downloads <- TRUE
  } else {
    dwn_fls <- file.path(fp, dwn_fls)
    cat_line('... found ', stat(length(dwn_fls)), ' files in ',
             char('downloads/'))
    cat_line('... totalling ', stat(dir_size(dwnld_path_get()), 'GB'))
    cat_line('... of sequences representing:')
    for (slctn in slctn_get()) {
      cat_line('... ... ', char(slctn))
    }
    cat_line('... last download was made on ', char(last_dwnld_get()))
    cat_line('... GenBank relase number ', stat(gbrelease_get()))
    if (gb_check) {
      latest <- gbrelease_check()
    }
  }
  cat_line(cli::rule())
  if (!restez_ready()) {
    cat_line('... ', char('sql_db'), ' does not exist or is not connected')
    no_database <- TRUE
  } else {
    cat_line('... found ', char('sql_db'), ' of ',
             stat(dir_size(sql_path_get()), 'GB'))
    cat_line('... and ', stat(db_nrows_get()), ' rows')
    sqlngths <- db_sqlngths_get()
    cat_line('... and sequence length limits of ',
             stat(sqlngths[['min']], 'bp'), ' to ',
             stat(sqlngths[['max']], 'bp'))
    cat_line('... last sequence was added on ', char(last_add_get()))
  }
  cat_line(cli::rule())
  res <- FALSE
  if (no_database & no_downloads) {
    message('You need to run db_download() and db_create()')
  } else if (no_database) {
    message('You need to run db_create()')
  } else {
    res <- TRUE
  }
  if (!latest) {
    msg <- paste0('Not the latest GenBank release. ',
                  'Consider re-running `db_download()` with overwrite=TRUE.')
    message(msg)
  }
  res
}

#' @name restez_ready
#' @title Is restez ready?
#' @family setup
#' @description Returns TRUE if a restez SQL database is available. Use
#' restez_status() for more information.
#' @return T/F
restez_ready <- function() {
  # TODO: separate into is_connected + has input
  has_tables <- function() {
    connection <- getOption('restez_connection')
    res <- tryCatch({
      length(DBI::dbListTables(conn = connection)) > 0
      }, error = function(e) {
        FALSE
      })
    res
  }
  fp <- sql_path_get()
  inherits(fp, 'character') && length(fp) == 1 && dir.exists(fp) &&
    has_tables()
}

#' @name restez_connect
#' @title Connect to the restez database
#' @family setup
#' @description Returns a connection to the local database. If database
#' connection cannot be made, an error is returned.
#' @return NULL
#' @example examples/restez_connect.R
#' @export
restez_connect <- function() {
  if (!DBI::dbCanConnect(drv = MonetDBLite::MonetDBLite(),
                         dbname = sql_path_get())) {
    stop('Unable to connect, is the restez path set?')
  }
  message('Remember to run `restez_disconnect()`')
  connection <- DBI::dbConnect(drv = MonetDBLite::MonetDBLite(),
                               dbname = sql_path_get())
  options('restez_connection' = connection)
  invisible(NULL)
}

#' @name restez_disconnect
#' @title Disconnect from restez database
#' @family setup
#' @description Safely disconnect from the restez connection
#' @return NULL
#' @example examples/restez_disconnect.R
#' @export
restez_disconnect <- function() {
  connection <- getOption('restez_connection')
  if (!is.null(connection)) {
    DBI::dbDisconnect(conn = connection, shutdown = TRUE)
    options('restez_connection' = NULL)
  }
  invisible(NULL)
}

#' @name connection_get
#' @title Retrieve restez connection
#' @family private
#' @description Safely acquire the restez connection. Raises error if no
#' connection set.
#' @return connection
connection_get <- function() {
  connection <- getOption('restez_connection')
  if (is.null(connection)) {
    stop('No restez connection. Did you run `restez_connect`?', call. = FALSE)
  }
  connection
}
