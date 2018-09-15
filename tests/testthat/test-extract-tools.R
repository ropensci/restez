# LIBS
library(restez)
library(testthat)

# VARS
data_d <- restez:::testdatadir_get()

# DATA
# TODO: get ten random records of each NCBI domain
records <- readRDS(file = file.path(data_d, 'records.RData'))

# RUNNING
context('Testing \'extract-tools\'')
test_that('extract_by_patterns() works', {
  record <- sample(records, 1)[[1]]
  res <- restez:::extract_by_patterns(record = record,
                                      start_pattern = '\nFEATURES\\s{2,}')
  expect_true(grepl('Location/Qualifiers', res))
})
test_that('extract_version() works', {
  record <- sample(records, 1)[[1]]
  accession_version <- restez:::extract_version(record = record)
  # print(accession_version)
  expect_true(grepl('^[a-z0-9_]+\\.[0-9]+$', accession_version,
                    ignore.case = TRUE))
})
test_that('extract_organism() works', {
  record <- sample(records, 1)[[1]]
  organism <- restez:::extract_organism(record = record)
  # print(organism)
  expect_false(grepl('\\s{2,}', organism,
                    ignore.case = TRUE))
  expect_false(grepl('\n', organism, ignore.case = TRUE))
})
test_that('extract_definition() works', {
  record <- sample(records, 1)[[1]]
  definition <- restez:::extract_definition(record = record)
  #print(definition)
  expect_false(grepl('\\s{2,}', definition,
                     ignore.case = TRUE))
  expect_false(grepl('\n', definition, ignore.case = TRUE))
})
test_that('extract_sequence() works', {
  record <- sample(records, 1)[[1]]
  sequence <- restez:::extract_sequence(record = record)
  expect_false(grepl('[0-9]', sequence,
                     ignore.case = TRUE))
})
test_that('extract_features() works', {
  record <- sample(records, 1)[[1]]
  features <- restez:::extract_features(record = record)
  # print(features)
  expect_true(inherits(features, 'list'))
})
test_that('extract_locus() works', {
  record <- sample(records, 1)[[1]]
  locus <- restez:::extract_locus(record = record)
  # print(locus)
  expect_true(inherits(locus, 'character'))
})
test_that('extract_keywords() works', {
  record <- sample(records, 1)[[1]]
  keywords <- restez:::extract_keywords(record = record)
  # print(keywords)
  expect_true(inherits(keywords, 'character'))
})
test_that('gb_extract() works', {
  opts <- c('accession', 'version', 'organism','sequence', 'definition',
            'locus', 'features', 'keywords')
  what <- sample(opts, 1)
  record <- sample(records, 1)[[1]]
  res <- gb_extract(record = record, what = what)
  if (what == 'features') {
    expect_true(inherits(res, 'list'))
  } else {
    expect_true(inherits(res, 'character'))
  }
})
