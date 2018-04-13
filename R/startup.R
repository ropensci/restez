#' @name set_database_filepath
#' @title Set database filepath
#' @description Specify the filepath for the local GenBank database.
#' @details Adds 'restez_database_filepath' to options(). In this path
#' the database will be created and called 'restez_database'
#' @param filepath character, valid filepath to the folder where the
#' database should be stored.
#' @return NULL
#' @export
set_database_filepath <- function(filepath) {
  if (!dir.exists(filepath)) {
    stop('Invalid filepath.')
  }
  options(restez_database_filepath =
            file.path(filepath, 'restez_database'))
}

.onAttach <- function(...) {
  v <- utils::packageVersion("restez")
  fp <- getOption('restez_database_filepath')
  if (is.null(fp)) {
    msg <- paste0('restez ', v, '\n',
                  'Remember to set_database_filepath()')
  } else {
    msg <- paste0('restez ', v, '\n',
                  'Database filepath = [', fp,
                  ']\n')
  }
  packageStartupMessage(msg)
}
