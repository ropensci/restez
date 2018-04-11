# LIBS
library(restez)
library(testthat)

# DATA
data("records")

# RUNNING
context('Testing \'get-tools\'')
test_that('extract_by_keyword() works', {
  res <- restez:::extract_by_keyword(sample(records, 1),
                                     keyword = 'FEATURES',
                                     end_pattern = 'ORIGIN')
  expect_true(grepl('Location/Qualifiers', res))
})
test_that('get_version() works', {
  accession_version <- restez:::get_version(sample(records, 1))
  expect_true(grepl('^[a-z0-9]+\\.[0-9]+$', accession_version,
                    ignore.case = TRUE))
})
test_that('get_organism() works', {
  organism <- restez:::get_organism(sample(records, 1))
  expect_false(grepl('\\s{2,}', organism,
                    ignore.case = TRUE))
  expect_false(grepl('\n', organism, ignore.case = TRUE))
})
test_that('get_definition() works', {
  definition <- restez:::get_definition(sample(records, 1))
  expect_false(grepl('\\s{2,}', definition,
                     ignore.case = TRUE))
  expect_false(grepl('\n', definition, ignore.case = TRUE))
})
test_that('get_sequence() works', {
  sequence <- restez:::get_sequence(sample(records, 1))
  expect_false(grepl('[0-9]', sequence,
                     ignore.case = TRUE))
})
