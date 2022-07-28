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
