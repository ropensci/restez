.onAttach <- function(...) {
  v <- utils::packageVersion("restez")
  fp <- restez_path_get()
  if (is.null(fp)) {
    msg <- paste0('restez ', v, '\n',
                  'Remember to restez_path_set()')
  } else {
    msg <- paste0('restez v', v, '\n',
                  'path = [', fp, ']\n')
  }
  packageStartupMessage(msg)
}
