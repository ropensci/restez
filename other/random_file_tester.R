# Vars
n <- 2
wd <- '.'
restez_lib_path <- '~/Coding/restez'

# restez setup
devtools::load_all(restez_lib_path)
restez_path_set(wd)
db_delete(everything = TRUE)
restez_path_set(wd)

# Identify random seq files
release <- identify_latest_genbank_release_notes()
release_url <- paste0('ftp://ftp.ncbi.nlm.nih.gov/genbank/release.notes/',
                      release)
release_notes <- RCurl::getURL(url = release_url)
downloadable_table <- identify_downloadable_files(release_notes)
seq_files <- as.character(sample(downloadable_table[['seq_files']], n))

# Download them
for (i in seq_along(seq_files)) {
  fl <- seq_files[[i]]
  stat_i <- paste0(i, '/', length(seq_files))
  cat_line('... ', char(fl), ' (', stat(stat_i), ')')
  # TODO: move overwrite to here
  success <- file_download(fl, overwrite = FALSE)
  if (!success) {
    cat_line('... Hmmmm, unable to download that file.')
    any_fails <- TRUE
  }
}

# Create db
restez_connect()
db_create()
cat('Done!\n')
