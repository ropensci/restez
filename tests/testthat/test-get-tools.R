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
clean()
dir.create(test_filepath)
restez_path_set(filepath = test_filepath)
df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::gb_sql_add(df = df, database = 'nucleotide')

# RUNNING
context('Testing \'get-tools\'')
test_that('gb_sql_query() works', {
  id <- sample(ids, 1)
  res <- restez:::gb_sql_query(nm = 'accession', id = id)
  expect_true(res[[1]] == id)
  expect_error(restez:::gb_sql_query(nm = 'notathing', id = id))
})
test_that('gb_sequence_get() works', {
  id <- sample(ids, 1)
  sequence <- gb_sequence_get(id = id)
  expect_true(grepl('[atcgn]*', sequence[[1]]))
})
test_that('gb_record_get() works', {
  id <- sample(ids, 1)
  record <- gb_record_get(id = id)
  expect_true(is.character(record))
})
test_that('gb_definition_get() works', {
  id <- sample(ids, 1)
  definition <- gb_definition_get(id = id)
  expect_true(is.character(definition))
})
test_that('gb_fasta_get() works', {
  id <- sample(ids, 2)
  fasta <- gb_fasta_get(id = id)
  expect_true(length(fasta) == 2)
  expect_true(is.character(fasta[[1]]))
})
test_that('gb_version_get() works', {
  id <- sample(ids, 1)
  version <- gb_version_get(id = id)
  expect_true(is.character(version))
})
test_that('gb_organism_get() works', {
  id <- sample(ids, 1)
  organism <- gb_organism_get(id = id)
  expect_true(is.character(organism))
})
test_that('is_in_db() works', {
  id <- sample(ids, 3)
  id <- c('notanid', id)
  res <- is_in_db(id = id, db = 'nucleotide')
  expect_true(all(res == c(FALSE, TRUE, TRUE, TRUE)))
})
test_that('list_db_ids() works', {
  res <- restez:::list_db_ids(db = 'nucleotide')
  expect_true(all(ids %in% res))
})
clean()
