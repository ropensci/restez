# LIBS
library(testthat)

# RUNNING
cleanup()
context('Testing \'status-tools\'')
test_that('restez_status() works', {
  on.exit(cleanup())
  expect_error(restez_status(gb_check = FALSE))
  setup()
  status_obj <- restez_status(gb_check = FALSE)
  expect_true(status_obj$`Restez path`$`Does path exist?`)
  demo_db_create(n = 10)
  status_obj <- restez_status(gb_check = FALSE)
  expect_true(status_obj$Database$`Does path exist?`)
  expect_equal(as.character(status_obj$Database$`Total size`), "1.01M")
  expect_true(status_obj$Database$`Does the database have data?`)
  expect_equal(status_obj$Database$`Number of sequences`, 10)
  expect_equal(status_obj$Database$`Min. sequence length`, "0")
  expect_equal(status_obj$Database$`Max. sequence length`, "Inf")
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
