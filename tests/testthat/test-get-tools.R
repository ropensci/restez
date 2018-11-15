# LIBS
library(restez)
library(testthat)

# VARS
nrcrds <- 10  # how many fake records to test on?
data_d <- restez:::testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# SETUP
restez:::cleanup()
restez:::setup()
restez_connect()
df <- restez:::gb_df_generate(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
restez:::gb_sql_add(df = df)

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
  # ensure conversion to fasta does not impact sequence
  sq <- gb_sequence_get(id = id[[1]])
  expctd_sq <- sub(pattern = '^>[^\n]*', replacement = '', x = fasta[id[[1]]])
  expctd_sq <- gsub(pattern = '\n', replacement = '', x = expctd_sq)
  sq[[1]] == expctd_sq[[1]]
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
context('Testing \'db-get-tools\'')
test_that('is_in_db() works', {
  id <- sample(ids, 3)
  id <- c('notanid', id)
  res <- is_in_db(id = id, db = 'nucleotide')
  expect_true(all(res == c(FALSE, TRUE, TRUE, TRUE)))
})
test_that('list_db_ids() works', {
  expect_warning(restez:::list_db_ids(db = 'nucleotide'))
  res <- suppressWarnings(restez:::list_db_ids(db = 'nucleotide'))
  expect_true(all(ids %in% res))
})
test_that('count_db_ids() works', {
  res <- count_db_ids()
  expect_true(res == nrcrds)
})
restez:::cleanup()
