#' @name restez_status
#' @title Check restez status
#' @family setup
#' @description Report to console current setup status of restez.
#' @param gb_check Check whether last download was from latest GenBank release?
#' Default FALSE.
#' @details Always remember to run \code{\link{restez_connect}} before running
#' this function. Set gb_check=TRUE to see if your downloads are up-to-date.
#' @return Status class
#' @export
#' @example examples/restez_status.R
restez_status <- function(gb_check = FALSE) {
  cat_line('Checking setup status at  ...')
  restez_path_check()
  status_obj <- status_class()
  print(status_obj)
  with_downloads <- status_obj$Download$`N. files` > 0
  if (with_downloads && gb_check) {
    cat_line(cli::rule())
    cat_line('Checking latest GenBank release ...')
    latest <- gbrelease_check()
  }
  is_connected <- status_obj$Database$`Is database connected?`
  with_database <- status_obj$Database$`Does path exist?` &&
    status_obj$Database$`Is database connected?` &&
    status_obj$Database$`Does the database have data?`
  if (!with_database & !with_downloads) {
    message('You need to run `db_download()` and `db_create()`')
  }
  if (is_connected) {
    if (with_downloads & !with_database) {
      message('You need to run `db_create()` and then run `restez_connect()`')
    }
  } else {
    message('You need to run `restez_connect()`')
  }
  if (gb_check && !latest) {
    msg <- paste0('Not the latest GenBank release. ',
                  'Consider re-running `db_download()` with overwrite=TRUE.')
    message(msg)
  }
  invisible(status_obj)
}

#' @name status_class
#' @title Generate a list class for storing status information
#' @family private
#' @description Creates a three-part list for holding information on the
#' status of the restez file path.
#' @return Status class
status_class <- function() {
  # path
  flpth <- restez_path_get()
  path_info <- list('Path' = flpth, 'Does path exist?' = dir.exists(flpth))
  # download
  flpth <- dwnld_path_get()
  dwn_fls <- list.files(path = flpth)
  slctns <- paste0(slctn_get(), collapse = ', ')
  download_info <- list('Path' = flpth, 'Does path exist?' = dir.exists(flpth),
                        'N. files' = length(dwn_fls),
                        'N. GBs' = dir_size(flpth),
                        'GenBank division selections' = slctns,
                        'GenBank Release' = gbrelease_get(),
                        'Last updated' = last_dwnld_get())
  # database
  flpth <- sql_path_get()
  sqlngths <- db_sqlngths_get()
  nseqs <- suppressWarnings(count_db_ids())
  database_info <- list('Path' = flpth, 'Does path exist?' = dir.exists(flpth),
                        'N. GBs' = dir_size(flpth),
                        'Is database connected?' = connected(),
                        'Does the database have data?' = has_data(),
                        'Number of sequences' = nseqs,
                        'Min. sequence length' = sqlngths[['min']],
                        'Max. sequence length' = sqlngths[['max']],
                        'Last_updated' = last_add_get())
  res <- list('Restez path' = path_info, 'Download' = download_info,
              'Database' = database_info)
  structure(res, class = "status")
}

#' @name print.status
#' @title Print method for status class
#' @family private
#' @description Prints to screen the three sections of the status class.
#' @param x Status object
#' @return NULL
print.status <- function(x) {
  for (nm in names(x)) {
    cat_line(cli::rule())
    cat_line(nm, ' ...')
    x_part <- x[[nm]]
    nms <- names(x_part)
    for (i in seq_along(nms)) {
      item <- x_part[[i]]
      if (is.character(item)) {
        for_cat_line <- char(item)
      } else if (is.logical(item)) {
        for_cat_line <- char(ifelse(item, 'Yes', 'No'))
      } else {
        for_cat_line <- stat(item)
      }
      cat_line('... ', nms[[i]], ' ', for_cat_line)
    }
  }
}
