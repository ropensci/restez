
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
dot_spinner()

pid <- sys::exec_background(cmd = 'Rscript', args=list('downloader.R'))
while (!file.exists('downloaded_file')) {
  dot_spinner()
}
