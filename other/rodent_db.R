rodents_path <- file.path(getwd(), 'rodents')
if (!dir.exists(rodents_path)) {
  dir.create(rodents_path)
}
# set the restez path to a memorable location
restez_path_set(rodents_path)
# download domain 10 and build db, record times
# if max_tries > 1, should set overwrite to FALSE or will start over again
dl_time <- system.time(
  db_download(preselection = 10, max_tries = 100, overwrite = FALSE))

db_time <- system.time(db_create(min_length = 100, max_length = 1000))

# save times to RDS for documentation in vignette
rodent_times <- list(
  dl_time = dl_time,
  db_time = db_time
)

saveRDS(rodent_times, "other/rodent_build_times.rds")