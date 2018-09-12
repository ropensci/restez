# Framework copied from pkgdown
#' @name stat
#' @title Print blue
#' @description Print to console blue text to indicate a number/statistic.
#' @param ... Any number of text arguments to print, character
#' @return coloured chracter encoding, character
#' @family private
stat <- function(...) {
  crayon::blue(...)
}

#' @name char
#' @title Print green
#' @description Print to console green text to indicate a name/filepath/text
#' @param x Text to print, character
#' @return coloured chracter encoding, character
#' @family private
char <- function(x) {
  crayon::green(encodeString(x, quote = "'"))
}

#' @name cat_line
#' @title Cat lines
#' @description Helper function for printing lines to console. Automatically
#' formats lines by adding newlines.
#' @param ... Text to print, character
#' @return NULL
#' @family private
cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}

#' @name line_spinner
#' @title Spin the lines
#' @description Prints cool little spinning lines to console to indicate a
#' running process. Used in conjunction with a while loop.
#' @return NULL
#' @family private
line_spinner <- function() {
  # switch to lines because dots stopped working in RStudio
  #sp <- cli::get_spinner(which = 'line')
  interval <- 130/1000
  frames <- c("\\", "|", "/", "-")
  for (i in seq_along(frames) - 1) {
    fr <- unclass(frames[i %% length(frames) + 1])
    cat("\r", crayon::red(fr), sep = "")
    Sys.sleep(interval)
  }
}
