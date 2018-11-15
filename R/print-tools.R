# Framework copied from pkgdown
#' @name stat
#' @title Print blue
#' @description Print to console blue text to indicate a number/statistic.
#' @param ... Any number of text arguments to print, character
#' @return coloured character encoding, character
#' @family private
stat <- function(...) {
  crayon::blue(...)
}

#' @name char
#' @title Print green
#' @description Print to console green text to indicate a name/filepath/text
#' @param x Text to print, character
#' @return coloured character encoding, character
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
