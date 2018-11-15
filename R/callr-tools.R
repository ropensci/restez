#' @name custom_download2
#' @title Callr version of custom_download()
#' @description Runs \code{\link{custom_download}} as an independent R process.
#' This allows the user to kill the process. Additionally, the process will
#' print spinning dots to indicate it is still active.
#' @param url URL of source file, character.
#' @param destfile filepath to where the file should be saved.
#' @return NULL
#' @family private
custom_download2 <- function(url, destfile) {
  callr_args <- list(custom_download, url, destfile)
  callr::r(func = function(custom_download, url, destfile) {
    custom_download(url = url, destfile = destfile)
  }, args = callr_args, show = TRUE)
}

#' @name gb_build2
#' @title Callr version of gb_build()
#' @description Runs \code{\link{gb_build}} in callr.
#' This allows the user to kill the process. Additionally, the process will
#' print spinning dots to indicate it is still active.
#' @param dpth Download path (where seq_files are stored)
#' @param seq_files .seq.tar seq file names
#' @param min_length Minimum sequence length.
#' @param max_length Maximum sequence length.
#' @return Logical
#' @family private
gb_build2 <- function(dpth, seq_files, max_length, min_length) {
  restez_path <- restez_path_get()
  callr_args <- list(restez_path, gb_build, dpth, seq_files, max_length,
                     min_length)
  read_errors <- callr::r(func = function(restez_path, gb_build, dpth,
                                          seq_files, max_length, min_length) {
    options(restez_path = restez_path)
    gb_build(dpth = dpth, seq_files = seq_files, max_length = max_length,
             min_length = min_length)
  }, args = callr_args, show = TRUE)
  read_errors
}
