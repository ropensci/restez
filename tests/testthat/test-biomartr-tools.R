# LIBS
library(restez)
library(testthat)

# RUNNING
context('Testing \'biomartr-tools\'')
test_that('check_connection() works', {
  skip("skip until switch to duckdb")
  with_mock(
    `url_exists` = function(...) FALSE,
    expect_error(restez:::check_connection())
  )
  with_mock(
    `url_exists` = function(...) TRUE,
    expect_true(restez:::check_connection())
  )
})

