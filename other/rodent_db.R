rodents_path <- file.path(getwd(), 'rodents')
if (!dir.exists(rodents_path)) {
  dir.create(rodents_path)
}
library(restez)
# set the restez path to a memorable location
restez_path_set(rodents_path)
# download for domain 15
dwntm <- system.time(db_download(preselection = '15'))
crttm <- system.time(db_create(min_length = 100, max_length = 1000))
