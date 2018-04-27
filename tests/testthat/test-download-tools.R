# LIBS
library(restez)
library(testthat)

# VARS
test_db_fldr <- 'test_db_fldr'
wd <- getwd()
if (grepl('testthat', wd)) {
  data_d <- file.path('data')
} else {
  # for running test at package level
  data_d <- file.path('tests', 'testthat',
                      'data')
}

# DATA
release_notes <- readRDS(file = file.path(data_d,
                                          'release_notes_gb224.RData'))

# FUNCTIONS
clean <- function() {
  if (dir.exists(test_db_fldr)) {
    unlink(test_db_fldr, recursive = TRUE)
  }
}

# MOCKS
mockGetUrl <- function(...) {
  # fake releases, 500 is latest
  releases <- c(paste0(paste0('gb', 1:100), 'release.notes'),
                'gb500.release.notes', 'README.genbank.release.notes')
  releases <- sample(releases)
  paste0(paste0(releases, collapse = '\n'), '\n')
}

# RUNNING
context('Testing \'download-tools\'')
test_that('identify_latest_genbank_release_notes() works', {
  res <- with_mock(
    `RCurl::getURL` = mockGetUrl,
    restez:::identify_latest_genbank_release_notes()
  )
  expect_true(res == "gb500.release.notes")
})
test_that('identify_downloadable_files() works', {
  downloadable <- restez:::identify_downloadable_files(release_notes =
                                                         release_notes)
  expect_true(nrow(downloadable) == 3057)
  expect_true(all(grepl('\\.seq$', downloadable[['seq_files']])))
})
test_that('file_download() works', {
  dir.create(test_db_fldr)
  restez_path_set(test_db_fldr)
  res <- with_mock(
    `restez:::custom_download` = function(...) stop(),
    restez:::file_download(fl = 'test.seq')
  )
  expect_false(res)
  res <- with_mock(
    `restez:::custom_download` = function(...) NULL,
    restez:::file_download(fl = 'test.seq')
  )
  expect_true(res)
  clean()
})
clean()
