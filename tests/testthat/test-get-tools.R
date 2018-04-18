# LIBS
library(restez)
library(testthat)

# VARS
test_filepath <- 'test_get'
nrcrds <- 10  # how many fake records to test on?
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

# FUNCTIONS
clean <- function() {
  if (dir.exists(test_filepath)) {
    unlink(test_filepath, recursive = TRUE)
  }
}

# SETUP
dir.create(test_filepath)
set_restez_path(filepath = test_filepath)
df <- restez:::generate_dataframe(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::add_to_database(df = df, database = 'nucleotide')

# RUNNING
context('Testing \'get-tools\'')
test_that('query_sql() works', {
  id <- sample(ids, 1)
  res <- restez:::query_sql(nm = 'accession', id = id)
  expect_true(res[[1]] == id)
  expect_error(restez:::query_sql(nm = 'notathing', id = id))
})
test_that('get_sequence() works', {
  id <- sample(ids, 1)
  sequence <- get_sequence(id = id)
  expect_true(grepl('[atcgn]*', sequence[[1]]))
})
test_that('get_record() works', {
  id <- sample(ids, 1)
  record <- get_record(id = id)
  expect_true(inherits(record, 'list'))
  expect_true(is.character(record[[1]]))
})
test_that('get_definition() works', {
  id <- sample(ids, 1)
  definition <- get_definition(id = id)
  expect_true(inherits(definition, 'list'))
  expect_true(is.character(definition[[1]]))
})
test_that('get_organism() works', {
  id <- sample(ids, 1)
  organism <- get_organism(id = id)
  expect_true(inherits(organism, 'list'))
  expect_true(is.character(organism[[1]]))
})
test_that('list_db_ids() works', {
  res <- restez:::list_db_ids(db = 'nucleotide')
  expect_true(all(ids %in% res))
})
clean()
