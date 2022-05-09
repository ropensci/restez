#' @title Helper function to test if a stable internet connection
#' can be established.
#' @description All retrieval functions need a stable
#' internet connection to work properly. This internal function pings
#' the google homepage and throws an error if it cannot be reached.
#' @author Hajk-Georg Drost
#' @family private
# originally connected.to.internet
check_connection <- function() {
  check_url <- "https://www.ncbi.nlm.nih.gov/"
  if (url_exists(check_url)) {
    TRUE
  } else {
    msg <- paste0("Unable to connect to ", char(check_url),
                  "Are you connected to the internet?")
    stop(msg, call. = FALSE)
  }
}

url_exists <- function(url){
  h <- curl::new_handle(nobody = TRUE)
  tryCatch({
    req <- curl::curl_fetch_memory(url, handle = h)
    return(req$status_code < 400)
  }, error = function(e){FALSE})
}
