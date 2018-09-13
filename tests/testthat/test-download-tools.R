# LIBS
library(restez)
library(testthat)

# VARS
data_d <- restez:::testdatadir_get()

# DATA
release_notes <- readRDS(file = file.path(data_d, 'release_notes_gb224.RData'))

# MOCKS
mock_releasenotes <- function(destfile, ...) {
  # fake releases, 500 is latest
  releases <- c(paste0(paste0('gb', 1:100), 'release.notes'),
                'gb500.release.notes', 'README.genbank.release.notes')
  releases <- sample(releases)
  releases <- paste0(paste0(releases, collapse = '\n'), '\n')
  write(x = releases, file = destfile)
}

# RUNNING
restez:::cleanup()
context('Testing \'download-tools\'')
test_that('predict_datasizes() works', {
  expect_null(restez:::predict_datasizes(10))
})
test_that('latest_genbank_release() works', {
  res <- with_mock(
    `restez::custom_download2` = function(destfile, ...) write(x = '227',
                                                               file = destfile),
    restez:::latest_genbank_release()
  )
  expect_true(res == '227')
})
test_that('latest_genbank_release_notes() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  with_mock(
    `restez::custom_download2` = mock_releasenotes,
    restez:::latest_genbank_release_notes()
  )
  expect_true(file.exists(file.path(restez:::dwnld_path_get(),
                                    'latest_release_notes.txt')))
})
test_that('identify_downloadable_files() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  write(x = release_notes, file = file.path(restez:::dwnld_path_get(),
                                            'latest_release_notes.txt'))
  downloadable <- restez:::identify_downloadable_files()
  expect_true(nrow(downloadable) == 3057)
  expect_true(all(grepl('\\.seq$', downloadable[['seq_files']])))
})
restez:::cleanup()
test_that('file_download() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  res <- with_mock(
    `restez:::custom_download2` = function(...) stop(),
    restez:::file_download(fl = 'test.seq')
  )
  expect_false(res)
  res <- with_mock(
    `restez:::custom_download2` = function(...) NULL,
    restez:::file_download(fl = 'test.seq')
  )
  expect_true(res)
})
restez:::cleanup()
