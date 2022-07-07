# LIBS
library(testthat)

# RUNNING
cleanup()
context('Testing \'status-tools\'')
test_that('restez_status() works', {
  expect_error(restez_status(gb_check = FALSE))
  setup()
  on.exit(cleanup())
  status_obj <- restez_status(gb_check = FALSE)
  expect_true(status_obj$`Restez path`$`Does path exist?`)
  demo_db_create(n = 10)
  restez_connect()
  status_obj <- restez_status(gb_check = FALSE)
  expect_true(status_obj$Database$`Does path exist?`)
  expect_true(status_obj$Database$`Is database connected?`)
  expect_true(status_obj$Database$`Does the database have data?`)
})
test_that('status_class() works', {
  cleanup()
  setup()
  expect_true(inherits(status_class(), 'status'))
})
test_that('print.status() works', {
  cleanup()
  setup()
  expect_null(print.status(status_class()))
})
cleanup()
