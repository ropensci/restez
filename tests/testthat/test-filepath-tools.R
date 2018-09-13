# LIBS
library(restez)
library(testthat)

# RUNNING
restez:::cleanup()
context('Testing \'filepath-tools\'')
test_that('restez_path_set() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_true(restez_path_get() == file.path('test_db_fldr', 'restez'))
})
test_that('restez_path_unset() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  restez_path_unset()
  expect_null(restez_path_get())
})
test_that('restez_path_get() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_true(grepl('test_db_fldr', restez_path_get()))
})
test_that('sql_path_get() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_true(is.character(restez:::sql_path_get()))
})
test_that('dwnld_path_get() works', {
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_true(is.character(restez:::dwnld_path_get()))
})
test_that('restez_path_check() works', {
  expect_error(restez:::restez_path_check())
  restez:::setup()
  on.exit(restez:::cleanup())
  expect_null(restez:::restez_path_check())
  unlink('test_db_fldr', recursive = TRUE)
  expect_error(restez:::restez_path_check())
})
restez:::cleanup()
