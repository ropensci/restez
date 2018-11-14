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
  callr_args <- list(url, destfile)
  callr::r(func = function(url, destfile) {
    custom_download(url = url, destfile = destfile)
  }, args = callr_args, show = TRUE)
}

