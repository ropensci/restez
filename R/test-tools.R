#' @name cleanup
#' @title Clean up test data
#' @description Removes all temporary test data created.
#' @return NULL
#' @family private
cleanup <- function() {
  restez_disconnect()
  restez_path_unset()
  if (dir.exists('test_db_fldr')) {
    unlink('test_db_fldr', recursive = TRUE)
  }
  if (file.exists('test_records.txt')) {
    file.remove('test_records.txt')
  }
}

#' @name setup
#' @title Set up test common test data
#' @description Creates temporary test folders.
#' @return NULL
#' @family private
setup <- function() {
  dir.create('test_db_fldr')
  restez_path_set(filepath = 'test_db_fldr')
}

#' @name testdatadir_get
#' @title Get test data directory
#' @description Get the folder containing test data.
#' @return NULL
#' @family private
testdatadir_get <- function() {
  wd <- getwd()
  if (grepl('testthat', wd)) {
    data_d <- file.path('data')
  } else {
    # for running test at package level
    data_d <- file.path('tests', 'testthat', 'data')
  }
  data_d
}
