# LIBS
library(restez)
library(testthat)

# RUNNING
restez:::cleanup()
context('Testing \'log-tools\'')
# log ----
restez:::cleanup()
restez:::setup()
test_that('readme_log() works', {
  restez:::readme_log()
  expect_true(file.exists(file.path(restez_path_get(), 'README.txt')))
})
test_that('seshinfo_log() works', {
  restez:::seshinfo_log()
  expect_true(file.exists(file.path(restez_path_get(), 'session_info.txt')))
})
test_that('db_sqlngths_log() works', {
  restez:::db_sqlngths_log(min_lngth = 0, max_lngth = 100)
  expect_true(file.exists(file.path(restez_path_get(), 'seqlengths.tsv')))
})
test_that('slctn_log() works', {
  restez:::slctn_log(selection = c('bats' = 10))
  expect_true(file.exists(file.path(restez_path_get(), 'selection_log.tsv')))
})
test_that('filename_log() works', {
  restez:::filename_log(fl = 'filename.extension',
                        fp = file.path(restez_path_get(),'test_log.tsv'))
  expect_true(file.exists(file.path(restez_path_get(), 'test_log.tsv')))
})
test_that('dwnld_rcrd_log() works', {
  restez:::dwnld_rcrd_log(fl = 'filename.extension')
  expect_true(file.exists(file.path(restez_path_get(), 'download_log.tsv')))
})
test_that('add_rcrd_log() works', {
  restez:::add_rcrd_log(fl = 'filename.extension')
  expect_true(file.exists(file.path(restez_path_get(), 'add_log.tsv')))
})
test_that('gbrelease_log() works', {
  restez:::gbrelease_log(release = '255')
  expect_true(file.exists(file.path(restez_path_get(), 'gb_release.txt')))
})
# get ----
restez:::cleanup()
restez:::setup()
test_that('slctn_get() works', {
  expect_true(restez:::slctn_get() == '')
  restez:::slctn_log(selection = c('bats' = 10))
  expect_true(restez:::slctn_get() == 'bats')
})
test_that('gbrelease_get() works', {
  expect_true(restez:::gbrelease_get() == '0')
  restez:::gbrelease_log(release = 'gb.release.255')
  expect_true(restez:::gbrelease_get() == '255')
})
test_that('last_entry_get() works', {
  mock_df <- data.frame('l' = sample(letters, size = 100, replace = TRUE))
  fp <- file.path(restez_path_get(), 'test_log.tsv')
  write.table(x = mock_df, file = fp, sep = '\t')
  res <- restez:::last_entry_get(fp)[[2]]
  expect_true(res == mock_df[nrow(mock_df), 1])
})
test_that('last_dwnld_get() works', {
  expect_true(restez:::last_dwnld_get() == '')
  restez:::dwnld_rcrd_log(fl = 'filename.extension')
  dwnld_time <- restez:::last_dwnld_get()
  expect_true(grepl(pattern = Sys.Date(), x = dwnld_time))
})
test_that('last_add_get() works', {
  expect_true(restez:::last_add_get() == '')
  restez:::add_rcrd_log(fl = 'filename.extension')
  add_time <- restez:::last_add_get()
  expect_true(grepl(pattern = Sys.Date(), x = add_time))
})
test_that('db_sqlngths_get() works', {
  expect_true(restez:::db_sqlngths_get()[[1]] == '0')
  restez:::db_sqlngths_log(min_lngth = 0, max_lngth = 100)
  sqlngths <- restez:::db_sqlngths_get()
  expect_true(sqlngths[['min']] == 0)
  expect_true(sqlngths[['max']] == 100)
})
# special ----
restez:::cleanup()
restez:::setup()
test_that('dir_size() works', {
  size_before <- restez:::dir_size(restez_path_get())
  demo_db_create(n = 1E4)  # smallest number to have a noticable size
  size_after <- restez:::dir_size(restez_path_get())
  expect_true(size_after > size_before)
})
test_that('gbrelease_check() works', {
  restez:::gbrelease_log(release = 'gb.release.255')
  res <- with_mock(
    `restez::latest_genbank_release` = function(...) 256,
    restez:::gbrelease_check()
  )
  expect_false(res)
  res <- with_mock(
    `restez::latest_genbank_release` = function(...) 255,
    restez:::gbrelease_check()
  )
  expect_true(res)
})
restez:::cleanup()
