
is_windows <- function() (tolower(.Platform$OS.type) == "windows")

R_binary <- function() {
  R_exe <- ifelse(is_windows(), "R.exe", "R")
  return(file.path(R.home("bin"), R_exe))
}

dot_spinner <- function() {
  sp <- cli::get_spinner('dots')
  interval <- sp$interval/1000
  frames <- sp$frames
  cycles <- 1
  for (i in 1:(length(frames) * cycles) - 1) {
    fr <- unclass(frames[i %% length(frames) + 1])
    cat("\r", fr, sep = "")
    Sys.sleep(interval)
  }
}

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
}

cmd_generate <- function(url, destfile) {
  paste0("restez:::custom_download(url = '", url, "', destfile = '",
         destfile, "')\n", 'q(save = "no")\n')
}

handle_generate <- function() {
  # launch subprocess
  subprocess::spawn_process(command = R_binary(), arguments = c('--vanilla'))
}

custom_download2 <- function(url, destfile) {
  cmd <- cmd_generate(url = url, destfile = destfile)
  handle <- handle_generate()
  tryCatch(expr = {
    handle_run(handle = handle, cmd = cmd)
    }, interrupt = function(e) {
      killed <- subprocess::process_kill(handle = handle)
      stop(e, call. = FALSE)
      })
}
