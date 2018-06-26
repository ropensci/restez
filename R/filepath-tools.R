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
    stop('Invalid filepath.')
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
#' @noRd
sql_path_get <- function() {
  fp <- restez_path_get()
  file.path(fp, 'sql_db')
}

#' @name dwnld_path_get
#' @title Get dwnld path
#' @description Return path to folder where raw .seq files
#' are stored.
#' @return character
#' @noRd
dwnld_path_get <- function() {
  fp <- restez_path_get()
  file.path(fp, 'downloads')
}

#' @name restez_path_check
#' @title Check restez filepath
#' @description Raises error if restez path does
#' not exist.
#' @return NULL
#' @noRd
restez_path_check <- function() {
  fp <- restez_path_get()
  if (is.null(fp)) {
    stop('Restez path not set. Use restez_path_set().')
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
  if (file.exists(sql_path_get())) {
    file.remove(sql_path_get())
  }
  if (everything) {
    if (dir.exists(restez_path_get())) {
      unlink(restez_path_get(), recursive = TRUE)
      restez_path_unset()
    }
  }
  NULL
}

#' @name restez_status
#' @title Check restez status
#' @family setup
#' @description Report to console current setup status of restez.
#' Determines if the restez path is set, how many downloaded files
#' there are, if there is an SQL database. If SQL database available, returns
#' TRUE else FALSE.
#' @return T/F
#' @export
#' @example examples/restez_status.R
restez_status <- function() {
  no_downloads <- FALSE
  no_database <- FALSE
  fp <- restez_path_get()
  cat_line('Checking setup status at ', char(fp), ' ...')
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
    totsz <- sum(vapply(X = dwn_fls, FUN = file.size,
                        FUN.VALUE = double(1)))
    totsz <- round(x = totsz / 1E9, digits = 2)
    cat_line('... totalling ', stat(totsz, 'GB'))
  }
  if (!restez_ready()) {
    cat_line('... ', char('sql_db'), ' does not exist')
    no_database <- TRUE
  } else {
    dbsz <- file.size(sql_path_get())
    dbsz <- round(x = dbsz / 1E9, digits = 2)
    cat_line('... found ', char('sql_db'), ' of ', stat(dbsz, 'GB'))
  }
  res <- FALSE
  if (no_database & no_downloads) {
    message('You need to run db_download() and db_create()')
  } else if (no_database) {
    message('You need to run db_create()')
  } else {
    res <- TRUE
  }
  res
}

#' @name restez_ready
#' @title Is restez ready?
#' @family setup
#' @description Returns TRUE if a restez SQL database is available. Use
#' restez_status() for more information.
#' @return T/F
#' @export
#' @example examples/restez_ready.R
restez_ready <- function() {
  fp <- sql_path_get()
  inherits(fp, 'character') && length(fp) == 1 && file.exists(fp)
}
