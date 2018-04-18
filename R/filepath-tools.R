#' @name set_restez_path
#' @title Set restez path
#' @description Specify the filepath for the local GenBank database.
#' @details Adds 'restez_path' to options(). In this path
#' the folder 'restez' will be created and all downloaded and
#' database files will be stored there.
#' @param filepath character, valid filepath to the folder where the
#' database should be stored.
#' @return NULL
#' @export
set_restez_path <- function(filepath) {
  if (!dir.exists(filepath)) {
    stop('Invalid filepath.')
  }
  restez_path <- file.path(filepath, 'restez')
  options(restez_path = file.path(filepath, 'restez'))
  if (!dir.exists(restez_path)) {
    cat('... Creating [', restez_path, ']\n', sep = '')
    dir.create(restez_path)
  }
  dwnld_path <- get_dwnld_path()
  if (!dir.exists(dwnld_path)) {
    cat('... Creating [', dwnld_path, ']\n', sep = '')
    dir.create(dwnld_path)
  }
  readme_fl <- file.path(restez_path, 'README.txt')
  if (!file.exists(readme_fl)) {
    v <- utils::packageVersion("restez")
    readme_msg <- paste0('restez ', v, '\n',
                         'Created: ', Sys.time(), '\n\n',
                         'This is the database folder. ',
                         'It contains all downloaded files ',
                         'from GenBank and the SQL database.')
    write(x = readme_msg, file = readme_fl)
  }
}

#' @name get_restez_path
#' @title Get restez path
#' @description Return filepath to where the restez
#' database is stored.
#' @return character
#' @export
get_restez_path <- function() {
  getOption('restez_path')
}

#' @name get_sql_path
#' @title Get SQL path
#' @description Return path to where SQL database is stored.
#' @return character
#' @noRd
get_sql_path <- function() {
  fp <- get_restez_path()
  file.path(fp, 'sql_db')
}

#' @name get_dwnld_path
#' @title Get dwnld path
#' @description Return path to folder where raw .seq files
#' are stored.
#' @return character
#' @noRd
get_dwnld_path <- function() {
  fp <- get_restez_path()
  file.path(fp, 'downloads')
}

#' @name check_restez_fp
#' @title Check restez fp
#' @description Raises error if restez path does
#' not exist.
#' @return NULL
#' @noRd
check_restez_fp <- function() {
  fp <- get_restez_path()
  if (is.null(fp)) {
    stop('Restez path not set. Use set_restez_path().')
  }
  if (!dir.exists(fp)) {
    msg <- paste0('Restez path [', fp,
                  '] does not exist.')
    stop(msg)
  }
}

#' @name delete_database
#' @title Delete database
#' @description Delete the local SQL database.
#' @return NULL
#' @export
delete_database <- function() {
  file.remove(get_sql_path())
}

