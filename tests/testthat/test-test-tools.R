# LIBS
library(testthat)

# RUNNING
context('Testing \'test-tools\'')
test_that('cleanup() works', {
  dir.create('test_db_fldr')
  cleanup()
  expect_false(dir.exists('test_db_fldr'))
})
test_that('testdatadir_get() works', {
  expect_true(dir.exists(testdatadir_get()))
})
