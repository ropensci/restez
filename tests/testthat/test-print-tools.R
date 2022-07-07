# LIBS
library(testthat)

# RUNNING
context('Testing \'print-tools\'')
test_that('stat() works', {
  coloured_text <- stat('example text', 'example text')
  cat(coloured_text)
  expect_true(inherits(coloured_text, 'character'))
})
test_that('char() works', {
  coloured_text <- char(x = 'example text')
  cat(coloured_text)
  expect_true(inherits(coloured_text, 'character'))
})
test_that('cat_line() works', {
  nores <- cat_line('example text')
  expect_null(nores)
})
