#' @name set_database_filepath
#' @title Set database filepath
#' @description Specify the filepath for the local GenBank database.
#' @details Adds 'restez_database_filepath' to options().
#' @param filepath character, valid filepath
#' @return NULL
#' @export
set_database_filepath <- function(filepath) {
  if (!dir.exists(filepath)) {
    dir.create(filepath)
  }
  options(restez_database_filepath = filepath)
}

.onAttach <- function(...) {
  v <- packageVersion("restez")
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
