
dot_spinner <- function(expr) {
  sp <- cli::get_spinner('dots')
  interval <- sp$interval/1000
  frames <- sp$frames
  cycles <- 1
  do.call(expr)
  for (i in 1:(length(frames) * cycles) - 1) {
    fr <- unclass(frames[i %% length(frames) + 1])
    cat("\r", fr, sep = "")
    Sys.sleep(interval)
  }

}
dot_spinner()

myfunc <- function() {
  Sys.sleep(5)
  TRUE
}
