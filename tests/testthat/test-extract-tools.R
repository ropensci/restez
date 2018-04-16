# LIBS
library(restez)
library(testthat)

# VARS
wd <- getwd()
if (grepl('testthat', wd)) {
  data_d <- file.path('data')
} else {
  # for running test at package level
  data_d <- file.path('tests', 'testthat',
                      'data')
}

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# RUNNING
context('Testing \'extract-tools\'')
test_that('extract_by_keyword() works', {
  res <- restez:::extract_by_keyword(sample(records, 1),
                                     keyword = 'FEATURES',
                                     end_pattern = 'ORIGIN')
  expect_true(grepl('Location/Qualifiers', res))
})
test_that('extract_version() works', {
  accession_version <- restez:::extract_version(sample(records, 1))
  expect_true(grepl('^[a-z0-9]+\\.[0-9]+$', accession_version,
                    ignore.case = TRUE))
})
test_that('extract_organism() works', {
  organism <- restez:::extract_organism(sample(records, 1))
  expect_false(grepl('\\s{2,}', organism,
                    ignore.case = TRUE))
  expect_false(grepl('\n', organism, ignore.case = TRUE))
})
test_that('extract_definition() works', {
  definition <- restez:::extract_definition(sample(records, 1))
  expect_false(grepl('\\s{2,}', definition,
                     ignore.case = TRUE))
  expect_false(grepl('\n', definition, ignore.case = TRUE))
})
test_that('extract_sequence() works', {
  sequence <- restez:::extract_sequence(sample(records, 1))
  expect_false(grepl('[0-9]', sequence,
                     ignore.case = TRUE))
})