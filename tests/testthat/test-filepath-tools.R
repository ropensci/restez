# LIBS
library(testthat)

# RUNNING
cleanup()
context('Testing \'filepath-tools\'')
test_that('restez_path_set() works', {
  setup()
  on.exit(cleanup())
  expect_true(restez_path_get() == file.path('test_db_fldr', 'restez'))
})
test_that('restez_path_unset() works', {
  setup()
  on.exit(cleanup())
  restez_path_unset()
  expect_null(restez_path_get())
})
test_that('restez_path_get() works', {
  setup()
  on.exit(cleanup())
  expect_true(grepl('test_db_fldr', restez_path_get()))
})
test_that('sql_path_get() works', {
  setup()
  on.exit(cleanup())
  expect_true(is.character(sql_path_get()))
})
test_that('dwnld_path_get() works', {
  setup()
  on.exit(cleanup())
  expect_true(is.character(dwnld_path_get()))
})
test_that('restez_path_check() works', {
  expect_error(restez_path_check())
  setup()
  on.exit(cleanup())
  expect_null(restez_path_check())
  unlink('test_db_fldr', recursive = TRUE)
  expect_error(restez_path_check())
})
cleanup()
