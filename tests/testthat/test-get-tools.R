# LIBS
library(testthat)

# VARS
nrcrds <- 10  # how many fake records to test on?
data_d <- testdatadir_get()

# DATA
records <- readRDS(file = file.path(data_d, 'records.RData'))

# SETUP
cleanup()
setup()
df <- gb_df_generate(records = sample(records, size = nrcrds))
ids <- as.character(df[['accession']])
gb_sql_add(df = df)

# RUNNING
context('Testing \'get-tools\'')
test_that('gb_sql_query() works', {
  id <- sample(ids, 1)
  res <- gb_sql_query(nm = 'accession', id = id)
  expect_true(res[[1]] == id)
  expect_error(gb_sql_query(nm = 'notathing', id = id))
})
test_that('gb_sequence_get() works', {
  id <- sample(ids, 1)
  sequence <- gb_sequence_get(id = id)
  expect_true(grepl('[atcgn]*', sequence[[1]]))
  seq_dnabin_1 <- gb_sequence_get(id = id, dnabin = TRUE)
  expect_s3_class(seq_dnabin_1, "DNAbin")
  id_2 <- sample(ids, 2)
  seq_dnabin_2 <- gb_sequence_get(id = id_2, dnabin = TRUE)
  expect_s3_class(seq_dnabin_2, "DNAbin")
  expect_equal(length(seq_dnabin_2), 2)
  expect_equal(names(seq_dnabin_2), id_2)
  # Test that order of sequences matches order of names
  # https://github.com/ropensci/restez/issues/64
  # Reverse the order of the query; output sequence name order should match
  id_3 <- id_2[c(2, 1)]
  seq_dnabin_3 <- gb_sequence_get(id = id_3, dnabin = TRUE)
  expect_equal(names(seq_dnabin_3), id_3)
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
  expect_warning(list_db_ids(db = 'nucleotide'))
  res <- suppressWarnings(list_db_ids(db = 'nucleotide'))
  expect_true(all(ids %in% res))
})
test_that('count_db_ids() works', {
  res <- count_db_ids()
  expect_true(res == nrcrds)
})
cleanup()
