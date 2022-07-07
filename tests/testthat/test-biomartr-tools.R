# LIBS
library(testthat)
library(mockery)

# RUNNING
test_that('check_connection() works', {
  stub(check_connection, "url_exists", TRUE)
  expect_true(check_connection())
  stub(check_connection, "url_exists", FALSE)
  expect_error(
    check_connection(),
    "Unable to connect to")
})