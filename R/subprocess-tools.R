
#' @name handle_run
#' @title Run a command external to user's session
#' @description Takes a running subprocess handle and runs command. While
#' command is running prints spinning dots to console. Will raise an error if
#' any output stream in STDERR discovered.
#' @param handle subprocess handle
#' @param cmd command, character
#' @return NULL
#' @family private
handle_run <- function(handle, cmd) {
  subprocess::process_write(handle, cmd)
  # monitor: raise errors and spin dots
  while (subprocess::process_state(handle) == 'running') {
    dot_spinner()
    stderr <- subprocess::process_read(handle = handle,
                                       pipe = subprocess::PIPE_STDERR)
    if (length(stderr) > 0) {
      stop(stderr, call. = FALSE)
    }
  }
  cat('\n')
}

#' @name download_cmd_generate
#' @title Generate the command to download
#' @description Create a character string to download sequences using
#' \code{\link{custom_download}} in R. The command will also quit the session
#' after having complete.
#' @param url URL of source file, character.
#' @param destfile filepath to where the file should be saved.
#' @return character
#' @family private
download_cmd_generate <- function(url, destfile) {
  paste0("restez:::custom_download(url = '", url, "', destfile = '",
         destfile, "')\n", 'q(save = "no")\n')
}

#' @name rhandle_generate
#' @title Generate a subprocess handle for R
#' @description Returns an independent, running subprocess handle to R.
#' @details The R process will not store or restore any saved data.
#' @return subrocess handle
#' @family private
rhandle_generate <- function() {
  # framework below copied from intro to subprocess
  R_binary <- function() {
    if (tolower(.Platform$OS.type) == "windows") {
      R_exe <- 'R.exe'
    } else {
      R_exe <- 'R'
    }
    file.path(R.home("bin"), R_exe)
  }
  # launch subprocess
  # '--vanilla' prevents saving/restoring any session data
  subprocess::spawn_process(command = R_binary(), arguments = c('--vanilla'))
}

#' @name custom_download2
#' @title Subprocess version of custom_download()
#' @description Runs \code{\link{custom_download}} as an independent R process.
#' This allows the user to kill the process. Additionally, the process will
#' print spinning dots to indicate it is still active.
#' @param url URL of source file, character.
#' @param destfile filepath to where the file should be saved.
#' @return NULL
#' @family private
custom_download2 <- function(url, destfile) {
  cmd <- download_cmd_generate(url = url, destfile = destfile)
  handle <- rhandle_generate()
  tryCatch(expr = {
    handle_run(handle = handle, cmd = cmd)
    }, interrupt = function(e) {
      killed <- subprocess::process_kill(handle = handle)
      stop(e)
      })
}
