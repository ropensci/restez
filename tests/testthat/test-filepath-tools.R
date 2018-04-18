# LIBS
library(restez)
library(testthat)

# VARS
test_filepath <- 'test_startup'

# FUNCTIONS
clean_up <- function() {
  if (dir.exists(test_filepath)) {
    unlink(test_filepath, recursive = TRUE)
  }
}

# RUNNING
clean_up()
context('Testing \'filepath-tools\'')
test_that('set_restez_path() works', {
  dir.create(test_filepath)
  set_restez_path(filepath = test_filepath)
  expect_true(get_restez_path() ==
                file.path(test_filepath, 'restez'))
  clean_up()
})
test_that('get_restez_path() works', {
  dir.create(test_filepath)
  set_restez_path(filepath = test_filepath)
  expect_true(grepl(test_filepath, get_restez_path()))
  clean_up()
})
test_that('get_sql_path() works', {
  dir.create(test_filepath)
  set_restez_path(filepath = test_filepath)
  expect_true(is.character(restez:::get_sql_path()))
  clean_up()
})
test_that('get_dwnld_path() works', {
  dir.create(test_filepath)
  set_restez_path(filepath = test_filepath)
  expect_true(is.character(restez:::get_dwnld_path()))
  clean_up()
})
test_that('check_restez_fp() works', {
  expect_error(restez:::check_restez_fp())
  dir.create(test_filepath)
  set_restez_path(filepath = test_filepath)
  expect_null(restez:::check_restez_fp())
  unlink(test_filepath, recursive = TRUE)
  expect_error(restez:::check_restez_fp())
  clean_up()
})
clean_up()
