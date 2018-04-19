#' @name unset_restez_path
#' @title Unset restez path
#' @family setup
#' @description Set the restez path to NULL
#' @return NULL
#' @export
unset_restez_path <- function() {
  options(restez_path = NULL)
}

#' @name set_restez_path
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
#' set_restez_path(filepath = 'path/to/where/you/want/files/to/download')
#' }
set_restez_path <- function(filepath) {
  if (!dir.exists(filepath)) {
    stop('Invalid filepath.')
  }
  restez_path <- file.path(filepath, 'restez')
  options(restez_path = file.path(filepath, 'restez'))
  if (!dir.exists(restez_path)) {
    cat_line('... Creating ', char(restez_path))
    dir.create(restez_path)
  }
  dwnld_path <- get_dwnld_path()
  if (!dir.exists(dwnld_path)) {
    cat_line('... Creating ', char(dwnld_path))
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
#' @family setup
#' @description Return filepath to where the restez
#' database is stored.
#' @return character
#' @export
#' @example examples/get_restez_path.R
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
    stop(msg, .call = FALSE)
  }
}

#' @name delete_database
#' @title Delete database
#' @family setup
#' @description Delete the local SQL database and/or restez
#' folder.
#' @param everything T/F, delete the whole restez folder as well?
#' @return NULL
#' @export
#' @example examples/delete_database.R
delete_database <- function(everything = TRUE) {
  if (file.exists(get_sql_path())) {
    file.remove(get_sql_path())
  }
  if (everything) {
    if (dir.exists(get_restez_path())) {
      unlink(get_restez_path(), recursive = TRUE)
      unset_restez_path()
    }
  }
  NULL
}

#' @name check_status
#' @title Check status
#' @family setup
#' @description Report to console current setup status of restez.
#' Determines if the restez path is set, how many downloaded files
#' there are, if there is an SQL database.
#' @return NULL
#' @export
#' @example examples/check_status.R
check_status <- function() {
  no_downloads <- FALSE
  no_database <- FALSE
  cat_line('Checking setup status ...')
  fp <- get_restez_path()
  if (is.null(fp)) {
    cat_line('... restez path not set')
    message('You need to use set_restez_path()')
  } else if (!dir.exists(fp)) {
    cat_line('... restez path ', char(fp),
             ' does not exist')
    message('set_restez_path() filepath must be a valid filepath')
  } else {
    fp <- get_dwnld_path()
    if (!dir.exists(fp)) {
      cat_line('... ', char('downloads/'),
               ' does not exist')
      message('Use set_restez_path() to recreate the folder')
    } else {
      dwn_fls <- list.files(path = fp)
      if (length(dwn_fls) == 0) {
        cat_line('... no files in ', char('downloads/'))
        no_downloads <- TRUE
      } else {
        dwn_fls <- file.path(fp, dwn_fls)
        cat_line('... found ', stat(length(dwn_fls)),
                 ' files in ', char('downloads/'))
        totsz <- sum(vapply(X = dwn_fls, FUN = file.size,
                            FUN.VALUE = double(1)))
        totsz <- round(x = totsz / 1E9, digits = 2)
        cat_line('... totalling ', stat(totsz, 'GB'))
      }
    }
    fp <- get_sql_path()
    if (!file.exists(fp)) {
      cat_line('... ', char('sql_db'),
               ' does not exist')
      no_database <- TRUE
    } else {
      dbsz <- file.size(fp)
      dbsz <- round(x = dbsz / 1E9, digits = 2)
      cat_line('... found ', char('sql_db'),
               ' of ', stat(dbsz, 'GB'))
    }
  }
  if (no_database & no_downloads) {
    message('You need to run download_genbank() and create_database()')
  }
  if (no_database) {
    message('You need to run create_database()')
  }
  NULL
}
