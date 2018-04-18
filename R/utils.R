# Framework copied from pkgdown
stat <- function(...) {
  crayon::blue(...)
}

char <- function(x) {
  crayon::green(encodeString(x, quote = "'"))
}

cat_line <- function(...) {
  cat(paste0(..., "\n"), sep = "")
}
