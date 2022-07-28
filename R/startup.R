.onAttach <- function(...) {
  v <- utils::packageVersion("restez")
  v_msg <- paste0('restez v', v)
  v_msg_bar <- paste0(rep(x = '-', nchar(v_msg)), collapse = '')
  v_msg <- paste0(v_msg_bar, '\n', v_msg, '\n', v_msg_bar, '\n')
  fp <- restez_path_get()
  if (is.null(fp)) {
    msg <- paste0(v_msg, 'Remember to restez_path_set()')
  } else {
    msg <- NULL
  }
  packageStartupMessage(msg)
}
