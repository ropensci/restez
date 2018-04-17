.onAttach <- function(...) {
  v <- utils::packageVersion("restez")
  fp <- get_restez_path()
  if (is.null(fp)) {
    msg <- paste0('restez ', v, '\n',
                  'Remember to set_restez_path()')
  } else {
    msg <- paste0('restez v', v, '\n',
                  'path = [', fp, ']\n')
  }
  packageStartupMessage(msg)
}
