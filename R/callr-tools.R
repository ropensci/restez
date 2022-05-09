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
