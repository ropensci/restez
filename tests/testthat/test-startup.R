# LIBS
library(testthat)

# RUNNING
context('Testing \'startup\'')
test_that('.onAttach() works', {
  res <- .onAttach()
  expect_null(res)
})
