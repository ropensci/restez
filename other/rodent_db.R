rodents_path <- file.path(getwd(), 'rodents')
if (!dir.exists(rodents_path)) {
  dir.create(rodents_path)
}

# Dynamically get Rodent index (may change with future GenBank updates)
restez_path_set(tempdir())
latest_genbank_release_notes()
downloadable_table <- identify_downloadable_files()
types <- sort(table(downloadable_table[['descripts']]), decreasing = TRUE)
rodent_index <- grep("Rodent|rodent", names(types))

if (length(rodent_index) != 1) stop("multiple rodent indexes detected")
if (!is.numeric(rodent_index)) stop("rodent index should be numeric")

# set the restez path to a memorable location
restez_path_set(rodents_path)
# download domain 10 and build db, record times
dl_time <- system.time(
  db_download(preselection = rodent_index, max_tries = 100))

db_time <- system.time(db_create(min_length = 100, max_length = 1000))

# save times to RDS for documentation in vignette
rodent_times <- list(
  dl_time = dl_time,
  db_time = db_time
)

saveRDS(rodent_times, "other/rodent_build_times.rds")