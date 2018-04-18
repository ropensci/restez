# Framework copied from pkgdown
stat <- function(x) {
  crayon::blue(encodeString(x, quote = "'"))
}

path <- function(x) {
  crayon::green(encodeString(x, quote = "'"))
}

cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}
