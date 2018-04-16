#' @title Helper function to test if a stable internet connection
#' can be established.
#' @description All retrieval functions need a stable
#' internet connection to work properly. This internal function pings
#' the google homepage and throws an error if it cannot be reached.
#' @author Hajk-Georg Drost
#' @noRd
connected.to.internet <- function() {
  if (is.character(RCurl::getURL("www.google.com"))) {
    TRUE
  } else {
    stop(
      "It seems that you are not connected to the internet.
            Could you please check?",
      call. = FALSE
    )
  }
}

#' @title Helper function to perform customized downloads
#' @description To achieve the most stable download experience,
#' ftp file downloads are customized for each operating system.
#' @param ... additional arguments that shall be passed to
#' \code{\link[downloader]{download}}
#' @author Hajk-Georg Drost
#' @noRd
custom_download <- function(...) {

  operating_sys <- Sys.info()[1]

  if (operating_sys == "Darwin") {
    downloader::download(
      ...,
      method = "curl",
      extra = "--connect-timeout 120 --retry 3",
      cacheOK = FALSE,
      quiet = TRUE
    )

  }

  if (operating_sys == "Linux") {
    downloader::download(
      ...,
      method = "wget",
      extra = "--timeout 120 --tries 3 --continue",
      cacheOK = FALSE,
      quiet = TRUE
    )
  }

  if (operating_sys == "Windows") {
    downloader::download(...,
                         method = "internal",
                         cacheOK = FALSE,
                         quiet = TRUE)
  }
}
