rodents_path <- file.path(getwd(), 'rodents')
if (!dir.exists(rodents_path)) {
  dir.create(rodents_path)
}
# set the restez path to a memorable location
restez_path_set(rodents_path)
# download domain 15.
# Wrap in a while loop to repeat download attempt until finishes.
tries <- 0
dwntm <- system.time({
  while (TRUE) {
    x <- try(db_download(preselection = 15))
      if (inherits(x, "try-error")) {
        cat("ERROR: ", x, "\n")
        tries <- tries + 1
        message(paste("Trying again, attempt number", tries))
        Sys.sleep(10)
        } else {
         break
        }
    }
  })

crttm <- system.time(db_create(min_length = 100, max_length = 1000))
