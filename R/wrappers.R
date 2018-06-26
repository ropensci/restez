#' @name restez_rl
#' @title Restez readline
#' @description Wrapper for base readline.
#' @param prompt character, display text
#' @return character
#' @family private
restez_rl <- function(prompt) {
  base::readline(prompt)
}
