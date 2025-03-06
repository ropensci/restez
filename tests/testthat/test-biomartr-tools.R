# LIBS
library(testthat)

# RUNNING
test_that("check_connection() works", {
  local_mocked_bindings(
    check_connection = function(...) TRUE
  )
  expect_true(check_connection())
})

test_that("url_exists() works", {
  local_mocked_bindings(
    url_exists = function(...) FALSE
  )
  expect_error(
    check_connection(),
    "Unable to connect to"
  )
})
