# LIBS
library(restez)
library(testthat)

# RUNNING
context('Testing \'print-tools\'')
test_that('stat() works', {
  coloured_text <- restez:::stat('example text', 'example text')
  cat(coloured_text)
  expect_true(inherits(coloured_text, 'character'))
})
test_that('char() works', {
  coloured_text <- restez:::char(x = 'example text')
  cat(coloured_text)
  expect_true(inherits(coloured_text, 'character'))
})
test_that('cat_line() works', {
  nores <- restez:::cat_line('example text')
  expect_null(nores)
})
