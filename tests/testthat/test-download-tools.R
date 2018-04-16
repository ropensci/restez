# LIBS
library(restez)
library(testthat)

# VARS
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
