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
test_that('restez_path_set() works', {
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  expect_true(restez_path_get() ==
                file.path(test_filepath, 'restez'))
  clean_up()
})
test_that('restez_path_unset() works', {
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  restez_path_unset()
  expect_null(restez_path_get())
  clean_up()
})
test_that('restez_path_get() works', {
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  expect_true(grepl(test_filepath, restez_path_get()))
  clean_up()
})
test_that('sql_path_get() works', {
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  expect_true(is.character(restez:::sql_path_get()))
  clean_up()
})
test_that('dwnld_path_get() works', {
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  expect_true(is.character(restez:::dwnld_path_get()))
  clean_up()
})
test_that('restez_path_check() works', {
  expect_error(restez:::restez_path_check())
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  expect_null(restez:::restez_path_check())
  unlink(test_filepath, recursive = TRUE)
  expect_error(restez:::restez_path_check())
  clean_up()
})
test_that('db_delete() works', {
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  demo_db_create()
  db_delete(everything = FALSE)
  expect_false(file.exists(restez:::sql_path_get()))
  expect_true(file.exists(restez_path_get()))
  db_delete(everything = TRUE)
  expect_false(file.exists(file.path(test_filepath,
                                     'restez')))
  expect_null(restez_path_get())
  clean_up()
})
test_that('status_check() works', {
  status_check()
  dir.create(test_filepath)
  restez_path_set(filepath = test_filepath)
  status_check()
  demo_db_create()
  expect_null(status_check())
  clean_up()
})
clean_up()
