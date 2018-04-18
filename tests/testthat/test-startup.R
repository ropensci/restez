# LIBS
library(restez)
library(testthat)

# RUNNING
context('Testing \'startup\'')
test_that('.onAttach() works', {
  res <- restez:::.onAttach()
  expect_null(res)
})
